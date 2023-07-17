// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC5192Lock} from "./interface/IERC5192Lock.sol";

abstract contract ERC5192Lock is ERC721, IERC5192Lock {
  bool private isLocked;

  error ErrLocked();
  error ErrNotFound();

  constructor(string memory _name, string memory _symbol, bool _isLocked)
    ERC721(_name, _symbol)
  {
    isLocked = _isLocked;
  }

  modifier checkLock() {
    if (isLocked) revert ErrLocked();
    _;
  }

  function locked(uint256 tokenId) external view returns (bool) {
    if (!_exists(tokenId)) revert ErrNotFound();
    return isLocked;
  }

}