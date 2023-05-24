// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;
import {ERC2770} from "./ERC2770.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FeeDelegatoer is ERC2770,Ownable {
    constructor(string memory name,string memory version) ERC2770(name, version) {}

    function execute(ForwardRequest calldata req, bytes calldata signature) public payable override onlyOwner returns(bool,bytes memory) {
        return super.execute(req,signature);
    }
}