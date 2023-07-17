// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./IERC5484BurnAuth.sol";

interface ISBT is IERC721Enumerable,IERC5484BurnAuth {
    function safeMint(address to, string memory uri) external;

    function setTokenURI(uint256 _tokenId,string calldata _tokenURI) external;
}