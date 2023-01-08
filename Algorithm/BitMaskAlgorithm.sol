// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BitMask {
    /*
    * Q1. 비트의 0~n 자리의 숫자를 구하시오.
    * Example : 
    * x = 13(1101), n = 3
    * output = 5(0101)
    */
    function getLastNBits1(uint x, uint n) external pure returns(uint) {
        // Exmaple, x = 13, n = 3
        // (1) 1 << 3 = 0001 --> 1000 = 8
        // (2) mask =  8 - 1 =  1000 - 0001 = 0111 = 7
        // (3) x & mask = 1101 & 0111 = 0101(5)
        uint mask = (1 << n) - 1;
        return x & mask;
    }

    function getLastNBits2(uint x, uint n) external pure returns(uint) {
        // Exmaple, x = 13, n = 3
        // (1) 1 << 3 = 2^3 = 8
        // (2) 13 % 8 = 5(0101)
        return x % (1 << n);
    }
}