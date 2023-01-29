//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Merkle {
    bytes32 public _merkleRoot;

    function setMerkleRoot(bytes32 root) external {
        _merkleRoot = root;
    }

    function canClaim(address claimer, bytes32[] calldata merkleProof)
        public
        view
        returns (bool)
    {
        return MerkleProof.verify(
                merkleProof,
                _merkleRoot,
                keccak256(abi.encodePacked(claimer))
            );
    }
}
