// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MyToken is ERC20 {
    address factoryAddress;

    constructor(address _factoryAddress)
	ERC20("MyToken", "MyToken")
    {
        factoryAddress = _factoryAddress;
        _mint(msg.sender, 100000000e18);
    }
}

contract ERCFactory is Ownable {
    address public ERC20Address;

    function makeTx() external {
        ERC20Address = address(
            new MyToken(address(this))
        );
    }
}

