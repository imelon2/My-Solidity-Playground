// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IERC1155Permit.sol";

/** 
 * @dev Implementation of the ERC1155 Permit allowing approvals({_setApprovalForAll} method) to be made via signatures,
 * as based in OpenZeppelin Contract(https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC20/extensions/draft-ERC20Permit.sol)
 *
 * Add the {permit} method, which can be used to change an account`s ERC1155 allowance by presenting a message signed by account key.
 * By not relying on {_setApprovalForAll}, the ERC1155 token holder account doesn`t need to send transaction, 
 * thus is not required to pay for gas from holder.
 *
 * Attention : ERC1155Permit is not discussed in EIP, and this code created by personally (by. CHOI) based on EIP2612 and EIP712.
 * Create by CHOI (Link )
 */
abstract contract ERC1155Permit is ERC1155, EIP712,IERC1155Permit {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

        bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("PermitERC1155(address owner,address operator,bool approved,uint256 nonce,uint256 deadline)");
        
        constructor(string memory name) EIP712(name, "1") {}

        function permit(
            address owner,
            address operator,
            bool approved,
            uint256 deadline,
            uint8 v,
            bytes32 r,
            bytes32 s
            ) public virtual override {
            require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

            bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, operator, approved, _useNonce(owner), deadline));
            bytes32 hash = _hashTypedDataV4(structHash);
            address signer = ECDSA.recover(hash, v, r, s);

            require(signer == owner, "ERC20Permit: invalid signature");

            _setApprovalForAll(owner,operator,approved);
            }

        function nonces(address owner) virtual override public view returns (uint256) {
            return _nonces[owner].current();
        }

        function DOMAIN_SEPARATOR() virtual override external view  returns (bytes32) {
            return _domainSeparatorV4();
        }

        function _useNonce(address owner) internal virtual returns (uint256 current) {
            Counters.Counter storage nonce = _nonces[owner];
            current = nonce.current();
            nonce.increment();
        }

}