// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC1363.sol";

contract Dkargo is ERC1363 {
    constructor() ERC20("Dkargo", "DKA") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}