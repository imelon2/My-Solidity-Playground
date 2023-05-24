// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC5528 {

    function escrowFund(address _to, uint256 _value) external  returns (bool);

    function escrowRefund(address _from, uint256 _value) external returns (bool);

    function escrowWithdraw() external returns (bool);

}