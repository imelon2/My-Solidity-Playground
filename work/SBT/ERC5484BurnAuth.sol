// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;

import {IERC5484BurnAuth} from "./interface/IERC5484BurnAuth.sol";

abstract contract ERC5484BurnAuth is IERC5484BurnAuth {
    
    mapping(uint256 => BurnAuth) internal auth;

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