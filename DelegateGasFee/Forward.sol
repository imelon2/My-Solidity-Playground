// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;
import {ERC2770} from "./ERC2770.sol";

contract Forwarder is ERC2770 {
    constructor(string memory name,string memory version) ERC2770(name, version) {}

    
}

//["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0x7EF2e0048f5bAeDe046f6BF797943daF4ED8CB47","0","300000","0","0xa9059cbb000000000000000000000000ab8483f64d9c6d1ecf9b849ae677dd3315835cb200000000000000000000000000000000000000000000000000000000000003e8"]
