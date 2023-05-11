// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ExampleEip712 {

    // 데이터 구조 설계
    struct Mail {
        address from;
        address to;
        string contents;
    }

    // domain data
    bytes32 private immutable nameHash; // name
    bytes32 private immutable versionHash; // version
    uint256 private immutable chainid; // chain id
    address private immutable verifyingContract; // verifyingContract

	// type hash
    bytes32 private immutable domainTypeHash;
    bytes32 private immutable mailTypeHash;

	// domain separator
    bytes32 private immutable domainSeparator;

    // domain separator은 EIP712에서 구조화되어 고정값이니, 배포시 저장
    constructor(string memory name,string memory version) {
		// type hash 
        domainTypeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

		// enc(valueₙ): 32바이트 길이 고정
        nameHash = keccak256(bytes("Ether Mail"));
        versionHash = keccak256(bytes("1"));

        // example :
        chainid = 1; // block.chainid;

        // example :
        verifyingContract = 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC; // address(this);

        mailTypeHash = keccak256(
            "Mail(address from,address to,string contents)"
        );

		// domain separator : keccak256(abi.encode(typeHash ‖ encodeData(s)))
        domainSeparator = keccak256(abi.encode(domainTypeHash,nameHash,versionHash,chainid,verifyingContract));
    }

    function getDomainSeparator() public view returns(bytes32) {
        return domainSeparator;
    }

	// hashStruct : keccak256(abi.encode(typeHash ‖ encodeData(s)))
    function getHashStruct(Mail memory mail) public view returns(bytes32) {
        return keccak256(abi.encode(
            mailTypeHash,
            mail.from,
            mail.to,
            keccak256(bytes(mail.contents)) // enc(valueₙ): 32바이트 길이 고정
            ));
    }

	// 최종 해시 : keccak256("\x19\x01" ‖ domainSeparator ‖ hashStruct(s : structured data 𝕊))
    function messageHash(bytes32 structHash) public view returns(bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }

    // 검증 코드
    // 검증 성공 시 : 서명한 개인키의 공개키 return
    // 검증 실패 시 : Zero address return
    function recover(bytes32 _messageHash, bytes memory _sig)
        public pure returns(address)
        {
            (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
            return ecrecover(_messageHash,v,r,s);
        }
    
    function _split(bytes memory _sig) public pure returns(bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65,"invalid signature length");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig,64))
            v := byte(0,mload(add(_sig,96)))
        }
    }
}



/* Test Tupple Data 
 * ["0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826","0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB","Hello, Bob!"]
*/