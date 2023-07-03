    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
    import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
contract testERC165 {
        function supportsInterface() public pure returns (bytes4) {
        return type(IERC721).interfaceId ;
    }

}