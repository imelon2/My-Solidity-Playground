// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "./ERC1363.sol";

contract Dkargo is ERC20, ERC20Permit,ERC1363{
    constructor() ERC20("Dkargo", "DKA") ERC20Permit("Dkargo") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

    // function transferFromAndCall(address owner, address spender, uint256 value,bytes memory data, uint256 deadline,uint8 v,bytes32 r, bytes32 s) public returns(bool) {
    //     permit(owner, spender, value, deadline, v, r, s);
    //     return transferFromAndCall(owner, spender, value, data);
    // }
}