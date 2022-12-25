// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Test {
    uint256 public testvalue;

    function testFunc(uint amount) public returns(uint) {
        testvalue = testvalue + amount;
        return testvalue;
    }

    function testByte(bytes32 _a) public pure returns(bool) {
        // if(_a.length == 0) {
        //     return true;
        // } else {
        //     return false;
        // }
        return _a == 0;
    }
}

// 0xa8694da46a1160f181da73e8b7b3fc57c74ea4a9cf5c2f03edb58c4a244ad90a
// 0x0000000000000000000000000000000000000000000000000000000000000000