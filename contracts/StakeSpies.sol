// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./support/IERC721A.sol";

interface IEspionage is IERC20 {
    function mint(address _to, uint256 _amount) external;
}

error StakeSpies__AlreadyInitialised();
error StakeSpies__NotStarted();
error StakeSpies__NotTokenOwner();
error StakeSpies__NotTokenStaker();
error StakeSpies__TokenReleaseWithheld();
error StakeSpies__CantStake();

contract StakeSpies is Ownable, Pausable, IERC721Receiver {
    IEspionage public espionageToken;
    IERC721A public avaxSpiesNFT;

    uint256 public totalStaked;
    uint256 public stakeStart;
    uint256 public constant stakingTime = 1 days;

    struct SpiesStaked {
        uint256 balance;
        uint256 rewardsReleased;
        uint256 coolDownTimestamp;
        address spyOwner;
    }

    constructor(IERC721A _nftAddress, IEspionage _tokenAddress) {
        avaxSpiesNFT = _nftAddress;
        espionageToken = _tokenAddress;
    }

    mapping(uint256 => SpiesStaked) public stakedSpies;

    bool public releaseTokens;
    bool initialised;

    event Staked(address owner, uint256 tokenId);
    event Unstaked(address owner, uint256 tokenId);
    event RewardPaid(address indexed user, uint256 reward);
    event ReleaseTokens(bool status);

    function initialise() public onlyOwner {
        if (initialised) revert StakeSpies__AlreadyInitialised();
        stakeStart = block.timestamp;
        initialised = true;
    }

    function setReleaseTokens(bool _enabled) public onlyOwner {
        releaseTokens = _enabled;
        emit ReleaseTokens(_enabled);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function stake(uint256 tokenId) public whenNotPaused {
        _stake(tokenId);
    }

    function stakeMany(uint256[] memory tokenIds) public whenNotPaused {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _stake(tokenIds[i]);
        }
    }

    function unstake(uint256 _tokenId) public {
        uint256[] memory wrapped = new uint256[](1);
        wrapped[0] = _tokenId;
        releaseReward(wrapped);
        _unstake(_tokenId);
    }

    function unstakeMany(uint256[] memory tokenIds) public {
        releaseReward(tokenIds);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (avaxSpiesNFT.ownerOf(tokenIds[i]) == msg.sender) {
                _unstake(tokenIds[i]);
            }
        }
    }

    function _stake(uint256 _tokenId) internal {
        if (!initialised) revert StakeSpies__NotStarted();
        if (avaxSpiesNFT.ownerOf(_tokenId) != msg.sender)
            revert StakeSpies__NotTokenOwner();

        avaxSpiesNFT.transferFrom(msg.sender, address(this), _tokenId);
        SpiesStaked storage stakedSpy = stakedSpies[_tokenId];

        stakedSpy.coolDownTimestamp = block.timestamp;
        stakedSpy.spyOwner = msg.sender;

        emit Staked(msg.sender, _tokenId);
        totalStaked++;
    }

    function _unstake(uint256 _tokenId) internal {
        if (!initialised) revert StakeSpies__NotStarted();
        if (stakedSpies[_tokenId].spyOwner != msg.sender)
            revert StakeSpies__NotTokenStaker();

        if (stakedSpies[_tokenId].coolDownTimestamp > 0) {
            address spyOwner = stakedSpies[_tokenId].spyOwner;
            delete stakedSpies[_tokenId];
            avaxSpiesNFT.transferFrom(address(this), spyOwner, _tokenId);
            emit Unstaked(msg.sender, _tokenId);
            totalStaked--;
        }
    }

    function calculateReward(
        uint256[] memory _tokenIds
    ) public view returns (uint256) {
        uint256 reward = 0;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            SpiesStaked storage stakedSpy = stakedSpies[_tokenIds[i]];
            if (
                stakedSpy.coolDownTimestamp < block.timestamp + stakingTime &&
                stakedSpy.coolDownTimestamp > 0
            ) {
                uint256 tierReward = 1e18;
                uint256 stakedDays = (
                    (block.timestamp - uint(stakedSpy.coolDownTimestamp))
                ) / stakingTime;

                reward += tierReward * stakedDays;
            }
        }
        return reward;
    }

    function _updateReward(uint256[] memory _tokenIds) internal {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            SpiesStaked storage stakedSpy = stakedSpies[_tokenIds[i]];
            if (
                stakedSpy.coolDownTimestamp < block.timestamp + stakingTime &&
                stakedSpy.coolDownTimestamp > 0
            ) {
                uint256 tierReward = 1e18;
                uint256 stakedDays = (
                    (block.timestamp - uint(stakedSpy.coolDownTimestamp))
                ) / stakingTime;
                uint256 partialTime = (
                    (block.timestamp - uint(stakedSpy.coolDownTimestamp))
                ) % stakingTime;

                stakedSpy.balance += tierReward * stakedDays;

                stakedSpy.coolDownTimestamp = block.timestamp + partialTime;
            }
        }
    }

    function releaseReward(uint256[] memory _tokenIds) public whenNotPaused {
        if (!releaseTokens) revert StakeSpies__TokenReleaseWithheld();

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            if (stakedSpies[_tokenIds[i]].spyOwner != msg.sender)
                revert StakeSpies__NotTokenStaker();
        }

        _updateReward(_tokenIds);

        uint256 reward = 0;
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            SpiesStaked storage stakedSpy = stakedSpies[_tokenIds[i]];
            reward += stakedSpy.balance;
            stakedSpy.rewardsReleased += stakedSpy.balance;
            stakedSpy.balance = 0;
        }

        if (reward > 0) {
            espionageToken.mint(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        if (from != address(0)) revert StakeSpies__CantStake();
        return IERC721Receiver.onERC721Received.selector;
    }
}
