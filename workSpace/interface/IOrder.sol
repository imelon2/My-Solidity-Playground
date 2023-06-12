// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IOrder {
    struct TrackContributions {
        uint256 completeOrder; //배송 성공 케이스
        uint256 expiredOrder; //배송 실패 (딜레이) 케이스
        uint256 failOrder; //배송 취소 (귀책사유 존재) 케이스
    }

    function getRecord(address user) external view returns (TrackContributions memory);
}