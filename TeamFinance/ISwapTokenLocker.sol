// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface ISwapTokenLocker {
    function claimToken(uint128 _amount) external returns(uint256);
    function emergencyWithdraw(address _tokenAddress) external;
    function getLockData(address _user) external view returns(uint128,uint128,uint64,uint64,uint32);
    function getToken() external view returns(address);
    function lockData(address) external view returns(uint128 amount,uint128 claimedAmount,uint64 lockTimestamp,uint64 lastUpdated,uint32 lockHours);
    function sendLockTokenMany(address[] memory _users,uint128[] memory _amounts,uint32[] memory _lockHours,uint256 _sendAmount) external ;
    function owner (  ) external view returns ( address );
} 