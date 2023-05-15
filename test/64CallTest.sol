// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Receiver {
    event Received(address caller, uint amount);

    uint public a;

    // fallback() external payable {
    //     emit Received(msg.sender, msg.value);
    // }

    // function withdraw(uint256 amount) public payable returns (uint) {
    //     emit Received(msg.sender, amount);

    //     return amount + 1;
    // }

    function test() public {
        a = gasleft();
    }
}

contract Caller {

    uint256 public isGas;
    event Response(bool success, bytes data,uint256 leftGas);

    function testCallFoo(address payable _addr,uint256 reqGas) public payable {
        isGas = gasleft();
        (bool success, bytes memory data) = _addr.call{value: msg.value, gas: reqGas}(
            abi.encodeWithSignature("withdraw(uint256)", 0.01 ether)
        );
        emit Response(success, data,gasleft());

        if (gasleft() <= reqGas/ 63) {
            // We explicitly trigger invalid opcode to consume all gas and bubble-up the effects, since
            // neither revert or assert consume all gas since Solidity 0.8.0
            // https://docs.soliditylang.org/en/v0.8.0/control-structures.html#panic-via-assert-and-error-via-require
            /// @solidity memory-safe-assembly
            assembly {
                invalid()
            }
        }

    }

    function test(address _addr,uint reqGas) public {
        (bool success, bytes memory data) = _addr.call{gas: reqGas}(
            abi.encodeWithSignature("test()")
        );

        emit Response(success, data,gasleft());
    }

}
//100000
//31648