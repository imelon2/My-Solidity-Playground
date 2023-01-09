// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address, address, uint) external;
}

contract Token {
    mapping(address => uint) balance;

    constructor() {
        balance[msg.sender] = 1000;
    }

    function transfer(address from, address to, uint amount) external {
        require(balance[from] >= amount,"Not Enough Balance");
        balance[from] -= amount;
        balance[to] += amount;
    }
}

contract EncodeData {
    function testCallEncodeData(address _contract, bytes calldata data) external {
        (bool ok, ) = _contract.call(data);
        require(ok, "call failed");
    }

    function encodeWithSignature(
        address form,
        address to,
        uint amount
    ) external pure returns (bytes memory) {
        // Typo is not checked - "transfer(address, uint)"
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    function encodeWithSelector(
        address from,
        address to,
        uint amount
    ) external pure returns (bytes memory) {
        // Type is not checked - (IERC20.transfer.selector, true, amount)
        return abi.encodeWithSelector(IERC20.transfer.selector,from, to, amount);
    }

    function encodeCall(address from, address to, uint amount) external pure returns (bytes memory) {
        // Typo and type errors will not compile
        return abi.encodeCall(IERC20.transfer, (from, to, amount));
    }
}
