// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract FeePlanner is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    //@notice LODIS 플랫폼 수수료 
    uint256 private platformFee;
    uint256 private shipperFee;
    uint256 private carrierFee;

    /// @custom:oz-upgrades-unsafe-allow constructor
    // constructor() {
    //     _disableInitializers();
    // }

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();

        platformFee = 40;
        shipperFee = 10;
        carrierFee = 3;
    }

    // getter
    function getPlatformFee() external view returns(uint256) {
        return platformFee;
    }

    function getShipperFee() external view returns(uint256) {
        return shipperFee;
    }

    function getCarrierFee() external view returns(uint256) {
        return carrierFee;
    }

    // setter
    function setPlatformFee(uint256 _platformFee) external onlyOwner {
        platformFee = _platformFee;
    }
    function setShipperFee(uint256 _shipperFee) external onlyOwner {
        shipperFee = _shipperFee;
    }
    function setCarrierFee(uint256 _carrierFee) external onlyOwner {
        carrierFee = _carrierFee;
    }

    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}