//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Merkle {
    // mapping (bytes32 => mapping (bytes32 => bytes32)) public m_merkleRoot;
    mapping (bytes32 => bytes32) public _merkleRoot;

    function setMerkleRoot(bytes32 title, bytes32 root) external {
        _merkleRoot[title] = root;
    }

    function getString(string memory title) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(title));
    }

    function canClaim(bytes32 title, address claimer, bytes32[] calldata merkleProof)
        public
        view
        returns (bool)
    {
        return MerkleProof.verify(
                merkleProof,
                _merkleRoot[title],
                keccak256(abi.encodePacked(claimer))
            );
    }
}
