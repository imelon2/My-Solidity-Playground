// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Fallback {
    event Log(string func, uint gas);

    // msg.data 존재하는 경우
    fallback() external payable {
        // send / transfer (forwards 2300 gas to this fallback function)
        emit Log("fallback", gasleft());
    }

    // msg.data 비어있는 경우
    receive() external payable {
        emit Log("receive", gasleft());
    }

    // 실행 결과를 확인하기 위한 잔액조회 기능
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract SendToFallback {
    function transferToFallback(address payable _to) public payable {
    	// calldata 없이 트랜잭션 보내는 경우
        _to.transfer(msg.value);
    }

    function callFallback(address payable _to) public payable {
    	// calldata를 담아서 보내는 경우
        (bool sent, ) = _to.call{value: msg.value}("data msg");
        require(sent, "Failed to send Ether");
    }
}