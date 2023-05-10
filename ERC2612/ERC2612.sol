// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract EIP712 {

    // domain data
    bytes32 private  immutable nameHash; // name
    bytes32 private immutable versionHash; // version
    uint256 private immutable chainid; // chain id
    address private immutable verifyingContract; // verifyingContract

	// type hash
    bytes32 private immutable domainTypeHash;

	// domain separator
    bytes32 private immutable domainSeparator;


    constructor(string memory name,string memory version) {
		// enc(valueₙ): 32바이트 길이 고정
        nameHash = keccak256(bytes("Dkargo"));
        versionHash = keccak256(bytes("1"));

        // example :
        chainid = 1; // block.chainid;

        // example :
        verifyingContract = 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC; // address(this);

		// type hash 
        domainTypeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

		// domain separator : keccak256(abi.encode(typeHash ‖ encodeData(s)))
        domainSeparator = keccak256(abi.encode(domainTypeHash,nameHash,versionHash,chainid,verifyingContract));
    }

    function getDomainSeparator() public view returns(bytes32) {
        return domainSeparator;
    }
   
}

abstract contract ERC2612 is EIP712, ERC20 {
    mapping(address => uint) private _nonces;

    bytes32 private constant _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name) EIP712(name, "1") { }


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));

        bytes32 hash = toTypedDataHash(getDomainSeparator(),structHash);

        address signer = ecrecover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _approve(owner, spender, value);
    }

    function nonces(address owner) public view returns (uint256) {
        return _nonces[owner];
    }


    function _useNonce(address owner) internal virtual returns (uint256 current) {
        current = _nonces[owner];
        _nonces[owner]++;
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }

}
