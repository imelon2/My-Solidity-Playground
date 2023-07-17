// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IOrderRules {
    /**
     * @notice LODIS 플랫폼 수수료(DKA) 호출하는 함수
     * @dev decimals 적용 O
     * @return (example)플랫폼 수수료 = 40 DKA, return 40 ether(uint256)
     */
    function getPlatformFee() external view returns(uint256);

    /**
     * @notice Shipper 수수료(%) 호출하는 함수
     * @dev decimals 적용 x
     * @return (example)Shipper 수수료(%) = 10% , return 10(uint256)
     */
    function getShipperFee() external view returns(uint256);

    /**
     * @notice Carrier 수수료(%) 호출하는 함수
     * @dev decimals 적용 x
     * @return (example)Carrier 수수료(%) = 3% , return 3(uint256)
     */
    function getCarrierFee() external view returns(uint256);

    /**
     * @notice 픽업지연 시간 호출하는 함수
     * @dev millisecond 적용 o
     * @return (example) 픽업지연 시간 3시간 , return 3 * 60 * 60 = 10800(uint256)
     */
    function getTimeExpiredDelayedPick() external view returns(uint256);

    /// @notice 배송실패 시간 호출하는 함수
    function getTimeExpiredDeliveryFault() external view returns(uint256);

    /// @notice 주문등록 후 매칭되기까지 기다리는 최대시간
    function getTimeExpiredWaitMatching() external view returns(uint256);

    /// @notice DKA contract address 호출하는 함수
    function getDKATokenAddress() external view returns(address);

    /// @notice SBTMinter contract address 호출하는 함수
    function getSBTMinterAddress() external view returns(address);

    /// @notice Treasury contract address 호출하는 함수
    function getTreasuryAddress() external view returns(address);

    /// @notice DKA contract address 호출하는 함수
    function getShipperSBTAddress() external view returns(address);

    /// @notice SBTMinter contract address 호출하는 함수
    function getCarrierSBTAddress() external view returns(address);

    /// @notice Treasury contract address 호출하는 함수
    function getDefaultSBTAddress() external view returns(address);


} 