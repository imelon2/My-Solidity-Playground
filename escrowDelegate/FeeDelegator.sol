// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;
import {ERC2770} from "./ERC2770.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FeeDelegator is ERC2770 {
    // constructor(string memory name,string memory version) ERC2770(name, version) {}
    constructor() ERC2770("FeeDelegator", "1") {}

    // function execute(ForwardRequest calldata req, bytes calldata signature) public payable override onlyOwner returns(bool,bytes memory) {
    //     return super.execute(req,signature);
    // }
}