// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ERC5192} from "./ERC5192.sol";
import {IERC5484} from "./IERC5484.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SBTDkargo is ERC5192, Ownable,IERC5484 {

    constructor() ERC5192("SBTDkargo", "SBTD",true) {}

    mapping(uint256 => BurnAuth) private auth;

    function safeMint(address to, uint256 tokenId,BurnAuth _auth) public onlyOwner {
        _safeMint(to, tokenId);
        auth[tokenId] = _auth;
    }

    function burnAuth(uint256 tokenId) external view returns (BurnAuth) {
        return auth[tokenId];
    }
}