// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ERC5192} from "./ERC5192.sol";
import {IERC5484} from "./IERC5484.sol";
// import {ERC5484} from "./ERC5484.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract SBTDkargo is ERC5192, Ownable, IERC5484 {

    mapping(uint256 => BurnAuth) internal auth;

    constructor() ERC5192("SBTDkargo", "SBTD",true) {}

    modifier checkAuth(uint256 tokenId) {
        if(auth[tokenId] == BurnAuth.IssuerOnly) {
            require(msg.sender == owner(),"ERC5484 : Only Issuer can burn SBT");
        } else if(auth[tokenId] == BurnAuth.OwnerOnly) {
            require(msg.sender == _ownerOf(tokenId),"ERC5484 : Only Token owner can burn SBT");
        } else if(auth[tokenId] == BurnAuth.Both) {
            require(msg.sender == _ownerOf(tokenId) || auth[tokenId] == BurnAuth.OwnerOnly,"ERC5484 : Only Token owner and Issuer can burn SBT");
        } else if(auth[tokenId] == BurnAuth.Neither) {
            revert("ERC5484 : Cant burn SBT");
        }
        _;
    }

    function safeMint(address to, uint256 tokenId,BurnAuth _auth) public onlyOwner {
        _safeMint(to, tokenId);
        _setAuth(msg.sender,to,tokenId,_auth);
    }

    function burn(uint256 tokenId) public virtual checkAuth(tokenId) {
        _burn(tokenId);
    }

    // getter
    function burnAuth(uint256 tokenId) public view returns (BurnAuth) {
        return auth[tokenId];
    }

    // setter
    function _setAuth(address from,address to, uint256 tokenId,BurnAuth _auth) internal  {
        auth[tokenId] = _auth;

        emit Issued(from, to, tokenId, _auth);
    }
}