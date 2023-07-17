// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Treasury is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    address private tokenAddress;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _tokenAddress) initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();

        tokenAddress=_tokenAddress;
    }

    function getTotalAmount() external view returns(uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).transfer(to,amount);
    }

    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}