// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Unchecked {
    function getMaxUint() public pure returns(uint) {
        return type(uint256).max;
    }

    function getMinUint() public pure returns(uint) {
        return type(uint256).min;
    }

    // Execution cost : 22285
    function JustdAdd(uint x, uint y) public pure returns(uint) {
            return x + y;
    }
    // Execution cost : 22125 gas
    function UncheckedAdd(uint x, uint y) public pure returns(uint) {
        unchecked {
            return x + y;
        }
    }
}