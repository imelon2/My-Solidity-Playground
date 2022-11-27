// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract ERCLootBox is ERC20 {
    address factoryAddress;

    constructor(address _factoryAddress)
	ERC20("ERCLootBox", "ELB")
    {
        factoryAddress = _factoryAddress;
        _mint(msg.sender, 100000000e18);
    }
}

contract ERCFactory is Ownable {
    address public lootBoxERCAddress;

    function deploy() external {
        lootBoxERCAddress = address(new ERCLootBox{salt:"0x1234"}(address(this)));
    }
}

