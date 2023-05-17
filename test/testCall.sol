// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;

contract test1 {

    mapping (address => uint256) public _count;
    function countNum(address sender) public {
        _count[sender] ++; 
    }

}

contract test2 {
    function call(address _address,bytes memory data) public {
        _address.call(data);
    }

    function getdata1(bytes memory data,address from) public pure returns(bytes memory) {
        return abi.encodePacked(data,from);
    }

    function getdata2(address _spender) public pure returns(bytes memory) {
        return abi.encodeWithSignature("countNum(address)", _spender);
    }
}