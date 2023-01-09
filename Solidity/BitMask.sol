// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BitMask {
    /* 
    * What is BitMask ??
    * 1 = 0001 = 0 + 0 + 0 + 2^0 = 1 
    * 2 = 0010 = 0 + 0 + 2^1 + 0 = 2
    * 3 = 0011 = 0 + 0 + 2^1 + 2^0 = 3
    * 10 = 1010 = 2^3 + 0 + 2^1 + 0 = 8 + 2 = 10
    */


    /*
    * x     = 1110 = 8 + 4 + 2 + 0 = 14
    * y     = 1011 = 8 + 0 + 2 + 1 = 11
    * x & y = 1010 = 8 + 0 + 2 + 0 = 10
    */
    function and(uint x, uint y) external pure returns(uint) {
        return x & y; // 10
    }

    /*
    * x     = 1100 = 8 + 4 + 0 + 0 = 12
    * y     = 1001 = 8 + 0 + 0 + 1 = 9
    * x | y = 1101 = 8 + 4 + 0 + 1 = 13
    */
    function or(uint x, uint y) external pure returns(uint) {
        return x | y; // 13
    }

    /*
    * x     = 1100 = 8 + 4 + 0 + 0 = 12
    * y     = 0101 = 0 + 4 + 0 + 1 = 5
    * x ^ y = 1001 = 8 + 0 + 0 + 1 = 9
    */
    function xor(uint x, uint y) external pure returns(uint) {
        return x ^ y; // 9
    }

    /*
    * x  = 00001100 = 0 + 0 + 0 + 0 + 8 + 4 + 0 + 0 = 12
    * ~x = 11110011 = 123 + 64 + 32 + 16 + 0 + 0 + 2 + 1 = 243
    */
    function not(uint x) external pure returns(uint) {
        return ~x; // 243
    }

    /*
    * Example :
    * 1 << 0 = 0001 --> 0001 = 1
    * 1 << 1 = 0001 --> 0010 = 2
    * 1 << 2 = 0001 --> 0100 = 4
    * 1 << 3 = 0001 --> 1000 = 8
    * 3 << 2 = 0011 --> 1100 = 12
    * 
    * x = 0101 = 5
    * bits = 2
    * x << bits = 0101 --> 10100 = 16 + 0 + 4 + 0 + 0 = 20
    */
    function shiftLeft(uint x,uint bits) external pure returns(uint) {
        return x << bits; // 20
    }

    /*
    * Example :
    * 8 >> 0 = 1000 --> 1000 = 8
    * 8 >> 1 = 1000 --> 0100 = 4
    * 8 >> 2 = 1000 --> 0010 = 2
    * 8 >> 3 = 1000 --> 0001 = 1
    * 8 >> 4 = 1000 --> 0000 = 0 // no Position, 0
    * 
    * x = 0101 = 5
    * bits = 2
    * x >> bits = 0101 --> 0001 = 1
    */
    function shiftRight(uint x,uint bits) external pure returns(uint) {
        return x >> bits; // 1
    }

}