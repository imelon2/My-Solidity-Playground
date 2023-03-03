// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SWAR {

    // // These are constants that make O(1) population count.
    uint constant public POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant public POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant public POPCNT_MODULO = 0x3F;

    function POPCOUNT(uint num) public pure returns(uint40) {
        return uint40(((num * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO);
    }

    function MUL(uint _betChoice) public pure returns(uint) {
        return _betChoice * POPCNT_MULT;
    }

    function MASK(uint _betChoice) public pure returns(uint) {
        return ((_betChoice * POPCNT_MULT) & POPCNT_MASK);
    }

    function MOD(uint _betChoice) public pure returns(uint) {
        return _betChoice % 63;
    }

}