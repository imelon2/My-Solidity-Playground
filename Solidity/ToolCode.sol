// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Tool {
    function UintToBytes(uint256 x) public pure returns (bytes memory b) {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    } 
    
    function getMax() public pure returns(uint) {
        return type(uint256).max;
    }
}