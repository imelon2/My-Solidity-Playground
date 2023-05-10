// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ERC5192} from "./ERC5192.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SBTDkargo is ERC5192, Ownable {
    constructor() ERC5192("SBTDkargo", "SBTD",true) {}

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
}