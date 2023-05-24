// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;

contract test1 {
    mapping(uint256 => mapping(address => uint256)) private _nonces;

    mapping (address => uint256) public _count;
    function countNum(address sender,uint256 _id) public {
        _useNonce(_id,sender);
    }

    function _useNonce(uint256 _orderId, address owner) internal virtual returns (uint256 current) {
        uint256 nonce = _nonces[_orderId][owner];
        current = nonce;
        nonce++;
    }

    function getNonce(uint256 _orderId, address owner) public view returns(uint256 current) {
        current = _nonces[_orderId][owner];
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