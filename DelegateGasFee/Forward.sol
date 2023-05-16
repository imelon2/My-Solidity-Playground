// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;
import {ERC2770} from "./ERC2770.sol";

contract Forwarder is ERC2770 {
    constructor(string memory name,string memory version) ERC2770(name, version) {}

    
}