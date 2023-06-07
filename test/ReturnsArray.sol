// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ReturnsArray {
    mapping(address => uint) public balance;
    uint256[100] private requirements;

    function getLength() public view returns(uint) {
        return requirements.length;
    }
    function getBalanceByAddressList(address[] calldata users) public view returns(uint[] memory) {
        uint _length = users.length;
        
        // uint[] memory results; // Not Good
        // uint[_length] memory results; // 정적 배열 설정 시, 변수 지정 불가능
        uint[] memory results = new uint[](_length);
        
        for(uint i = 0; i < _length; i++) {
            //   results.push(balance[users[i]]); 
             results[i] = balance[users[i]];
         }

        return results;
    }

    function testBool(bool a, bool b, bool c) public pure returns(bool) {
        return a && b || c;
    }
}
