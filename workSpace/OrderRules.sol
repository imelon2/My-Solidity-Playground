// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract OrderRules is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    //@notice LODIS 플랫폼 수수료 
    uint256 private platformFee;
    uint256 private shipperFee;
    uint256 private carrierFee;
    uint256 private timeExpiredDelayedPick; // 픽업지연 시간
    uint256 private timeExpiredDeliveryFault; // 배송실패 시간
    uint256 private timeExpiredWaitMatching; // 주문등록 후 매칭되기까지 기다리는 최대시간

    address private DKAToken;
    address private SBTMinter;
    address private Treasury;


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();

        platformFee = 40;
        shipperFee = 10;
        carrierFee = 3;
        timeExpiredDelayedPick = 3 hours;
        timeExpiredDeliveryFault = 4 hours;
        timeExpiredWaitMatching = 30 minutes;
    }

    // GET() Fee
    function getPlatformFee() external view returns(uint256) {
        return platformFee;
    }
    function getShipperFee() external view returns(uint256) {
        return shipperFee;
    }
    function getCarrierFee() external view returns(uint256) {
        return carrierFee;
    }

    // GET() Expired Time
    function getTimeExpiredDelayedPick() external view returns(uint256) {
        return timeExpiredDelayedPick;
    }
    function getTimeExpiredDeliveryFault() external view returns(uint256) {
        return timeExpiredDeliveryFault;
    }
    function getTimeExpiredWaitMatching() external view returns(uint256) {
        return timeExpiredWaitMatching;
    }

    // GET() Dkargo Contract Address
    function getDKATokenAddress() external view returns(address) {
        return DKAToken;
    }
    function getSBTMinterAddress() external view returns(address) {
        return SBTMinter;
    }
    function getTreasuryddress() external view returns(address) {
        return Treasury;
    }


    // SET() Fee
    function setPlatformFee(uint256 _platformFee) external onlyOwner {
        platformFee = _platformFee;
    }
    function setShipperFee(uint256 _shipperFee) external onlyOwner {
        shipperFee = _shipperFee;
    }
    function setCarrierFee(uint256 _carrierFee) external onlyOwner {
        carrierFee = _carrierFee;
    }

    // SET() Expired Time
    function setTimeExpiredDelayedPick(uint256 _timeExpiredDelayedPick) external onlyOwner {
        timeExpiredDelayedPick = _timeExpiredDelayedPick;
    }
    function setTimeExpiredDeliveryFault(uint256 _timeExpiredDeliveryFault) external onlyOwner {
        timeExpiredDeliveryFault = _timeExpiredDeliveryFault;
    }
    function setTimeExpiredWaitMatching(uint256 _timeExpiredWaitMatching) external onlyOwner {
        timeExpiredWaitMatching = _timeExpiredWaitMatching;
    }

    // SET() Dkargo Contract Address
    function setDKATokenAddress(address _DKAToken) external onlyOwner {
        DKAToken = _DKAToken;
    }
    function setSBTMinterAddress(address _SBTMinter) external onlyOwner {
        SBTMinter = _SBTMinter;
    }
    function setTreasuryddress(address _Treasury) external onlyOwner {
        Treasury = _Treasury;
    }


    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}