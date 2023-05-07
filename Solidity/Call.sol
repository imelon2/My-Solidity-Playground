// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Receiver {
    event Received(address caller, uint amount);

    fallback() external payable {
        emit Received(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public payable returns (uint) {
        emit Received(msg.sender, amount);

        return amount + 1;
    }
}

contract Caller {
    event Response(bool success, bytes data);

    function testCallFoo(address payable _addr) public payable {
        (bool success, bytes memory data) = _addr.call{value: msg.value, gas: 5000}(
            abi.encodeWithSignature("withdraw(uint256)", 0.01 ether)
        );

        emit Response(success, data);
    }

    function testCallDoesNotExist(address payable _addr) public payable {
        (bool success, bytes memory data) = _addr.call{value: msg.value}(
            abi.encodeWithSignature("doesNotExist()")
        );

        emit Response(success, data);
    }
}
