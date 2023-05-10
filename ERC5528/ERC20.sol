// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


// ERC20 Contract
contract Dkargo is ERC20 {
    constructor() ERC20("Dkargo", "DKA") {
        _mint(msg.sender, 100 * 10 ** decimals());
    }
}

contract ERC20Contract {

}