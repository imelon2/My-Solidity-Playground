// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ERC2771.sol";


contract Recipient is ERC2771Context { 
    constructor(address forwarder) ERC2771Context(forwarder) {}
}

contract Dkargo is ERC20,ERC2771Context {
    constructor(address forwarder) ERC20("Dkargo", "DKA") ERC2771Context(forwarder) {
        _mint(msg.sender, 100000000 * 10 ** decimals());
    }

    function _msgSender() internal view override(Context, ERC2771Context)
      returns (address sender) {
      sender = ERC2771Context._msgSender();
    }

    function _msgData() internal view override(Context, ERC2771Context)
        returns (bytes calldata) {
        return ERC2771Context._msgData();
    }
}