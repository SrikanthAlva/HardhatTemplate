// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

error Espionage_Unauthorized();
error Espionage_ZeroAddress();
error Espionage_TransferExceedsBalance();
error Espionage_NotExtensionAddress();

contract Espionage is ERC20, Ownable, Pausable {
    string private constant _name = "Espionage";
    string private constant _symbol = "ESP";
    uint256 public constant _OneESP = 1e18;
    uint256 public totalMinted = 0;
    uint256 public totalBurned = 0;
    address public StakeAddress;
    mapping(address => bool) public ExtensionAddresses;

    event Burned(address _from, uint256 _amount);
    event Minted(address _to, uint256 _amount);
    event TransferSent(address _from, address _to, uint256 _amount);

    constructor() ERC20(_name, _symbol) {
        _mint(address(this), 100 * _OneESP);
        totalMinted = 100 * _OneESP;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address _to, uint256 _amount) external whenNotPaused {
        if (_to == address(0) || StakeAddress == address(0))
            revert Espionage_ZeroAddress();

        if (
            _msgSender() != StakeAddress ||
            ExtensionAddresses[_msgSender()] == false
        ) revert Espionage_Unauthorized();

        totalMinted = totalMinted + _amount;
        _mint(_to, _amount);
        emit Minted(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external whenNotPaused {
        if (_from == address(0) || StakeAddress == address(0))
            revert Espionage_ZeroAddress();

        if (
            _msgSender() != StakeAddress ||
            ExtensionAddresses[_msgSender()] == false
        ) revert Espionage_Unauthorized();

        totalBurned = totalBurned + _amount;
        _burn(_from, _amount);
        emit Burned(_from, _amount);
    }

    function transferTokens(address to, uint256 amount) external onlyOwner {
        if (amount > totalBalance()) revert Espionage_TransferExceedsBalance();

        address token = address(this);
        _transfer(token, to, amount);
        emit TransferSent(msg.sender, to, amount);
    }

    function transferESP(address to, uint256 amount) external onlyOwner {
        if (amount > totalBalance()) revert Espionage_TransferExceedsBalance();

        address token = address(this);
        uint256 espAmount = amount * _OneESP;
        _transfer(token, to, espAmount);
        emit TransferSent(msg.sender, to, espAmount);
    }

    function setStakeAddress(address _stakeAddress) external onlyOwner {
        if (_stakeAddress == address(0)) revert Espionage_ZeroAddress();

        StakeAddress = _stakeAddress;
    }

    function AddExtensionAddress(address _extensionAddress) external onlyOwner {
        if (_extensionAddress == address(0)) revert Espionage_ZeroAddress();

        ExtensionAddresses[_extensionAddress] = true;
    }

    function RemoveExtensionAddress(address _address) external onlyOwner {
        if (_address == address(0)) revert Espionage_ZeroAddress();
        if (ExtensionAddresses[_address] == false)
            revert Espionage_NotExtensionAddress();

        delete ExtensionAddresses[_address];
    }

    function totalBalance() public view returns (uint256) {
        return balanceOf(address(this));
    }
}
