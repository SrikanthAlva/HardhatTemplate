// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./support/ERC721A.sol";
import "./support/IERC2981Royalties.sol";
import "./support/ISTIK.sol";

error AvaxSpies__BelowMinimumLimit();
error AvaxSpies__MaxNFTsMinted();
error AvaxSpies__ExceedsMaxMintPerTx();
error AvaxSpies__InsufficientFunds();
error AvaxSpies__NotOwner();
error AvaxSpies__TransferFailed();

contract AvaxSpies is ERC721A, Ownable, Pausable, ReentrancyGuard {
    using Strings for uint256;
    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant ROYALTY = 1000; // 10% Percent Royalty
    uint256 public constant MINT_PRICE = 1 ether;
    uint256 public constant MAX_MINT_PER_TX = 10;

    string public baseExtension = ".json";
    string public baseURI = "";
    string public maskedURI = "";
    bool public revealed = false;
    ISTIK public stikNFT;
    address public royaltyRecipient =
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4; // Needs to be updated
    mapping(address => uint256) public mintedWallets;

    constructor(
        string memory _baseURI,
        string memory _maskedURI,
        address _stik_address
    ) ERC721A("AVAX Spies", "SPIES") {
        updateBaseURI(_baseURI);
        updateMaskedURI(_maskedURI);
        stikNFT = ISTIK(_stik_address);
    }

    function mint(
        uint[] memory tokenIds
    ) public payable nonReentrant whenNotPaused {
        if (tokenIds.length == 0) revert AvaxSpies__BelowMinimumLimit();

        if (totalSupply() + tokenIds.length > MAX_SUPPLY)
            revert AvaxSpies__MaxNFTsMinted();
        if (tokenIds.length > MAX_MINT_PER_TX)
            revert AvaxSpies__ExceedsMaxMintPerTx();
        if (tokenIds.length * MINT_PRICE <= msg.value)
            revert AvaxSpies__InsufficientFunds();

        for (uint256 i; i < tokenIds.length; ) {
            if (stikNFT.ownerOf(tokenIds[i]) != msg.sender)
                revert AvaxSpies__NotOwner();
            stikNFT.transferFrom(msg.sender, address(this), tokenIds[i]);
            stikNFT.burn(tokenIds[i]);
            i++;
        }
        mintedWallets[msg.sender] += tokenIds.length;
        _safeMint(msg.sender, tokenIds.length);
    }

    function withdrawTokens() external payable onlyOwner {
        uint256 balance = address(this).balance;
        uint256 balanceOne = (balance * 100) / 100;
        (bool transferOne, ) = payable(
            0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
        ).call{value: balanceOne}("");
        if (!transferOne) revert AvaxSpies__TransferFailed();
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        if (!revealed) return maskedURI;
        return
            string(
                abi.encodePacked(baseURI, tokenId.toString(), baseExtension)
            );
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

    function updateBaseURI(string memory _newURI) public onlyOwner {
        baseURI = _newURI;
    }

    function updateMaskedURI(string memory _maskedURI) public onlyOwner {
        maskedURI = _maskedURI;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function updateRoyaltyRecipient(address newRecipient) public onlyOwner {
        royaltyRecipient = newRecipient;
    }

    // royalties
    function supportsInterface(
        bytes4 interfaceID
    ) public view override returns (bool) {
        return
            interfaceID == type(IERC2981Royalties).interfaceId ||
            super.supportsInterface(interfaceID);
    }

    function royaltyInfo(
        uint256,
        uint256 value
    ) external view returns (address, uint256) {
        return (royaltyRecipient, (value * ROYALTY) / 10000);
    }
}
