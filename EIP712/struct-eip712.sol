// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// tuple input data
// [["steve",["0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826","0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF"]],["alice",["0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB","0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57","0xB0B0b0b0b0b0B000000000000000000000000000"]]]
contract ExampleEip712 {

    
    // 데이터 구조 설계
    struct From {
        string name;
        address[] wallets;
    }
    struct To {
        string name;
        address[] wallets;    
    }
    struct Mail {
        From from;
        To to;
    }


    // domain data
    bytes32 private immutable nameHash; // name
    bytes32 private immutable versionHash; // version
    address private immutable verifyingContract; // verifyingContract
    uint256 private immutable chainid; // chain id

	// type hash
    bytes32 private immutable domainTypeHash;
    bytes32 private immutable mailTypeHash;
    bytes32 private immutable fromTypeHash;
    bytes32 private immutable toTypeHash;

	// domain separator
    bytes32 public immutable domainSeparator;

    // domain separator은 EIP712에서 구조화되어 고정값이니, 배포시 저장
    constructor(string  memory name,string memory version) {
        nameHash = keccak256(bytes(name));
        versionHash = keccak256(bytes(version));

        // example :
        chainid = 1;

        // example :
        verifyingContract = 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC;

        // type hash 저장
        domainTypeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        fromTypeHash = keccak256("From(string name,address[] wallets)");
        toTypeHash = keccak256("To(string name,address[] wallets)");
        mailTypeHash = keccak256("Mail(From from,To to)From(string name,address[] wallets)To(string name,address[] wallets)");

		// domain separator : keccak256(abi.encode(typeHash ‖ encodeData(s)))
        domainSeparator = keccak256(abi.encode(domainTypeHash,nameHash,versionHash,chainid,verifyingContract));
    }

    function getDomainSeparator() public view returns(bytes32) {
        return domainSeparator;
    }

    function encodeFrom(From memory from) public view returns(bytes memory) {
        // from.wallets 배열타입 인코딩 : keccak256(abi.encodePacked(from.wallets))
		return abi.encode(fromTypeHash,keccak256(bytes(from.name)),keccak256(abi.encodePacked(from.wallets)));
    }

    function encodeTo(To memory to) public view returns(bytes memory) {
        return abi.encode(fromTypeHash,keccak256(bytes(to.name)),keccak256(abi.encodePacked(to.wallets)));
    }

	// hashStruct
    function getHashStruct(Mail memory mail) public view returns(bytes32) {
        return keccak256(abi.encode(
            mailTypeHash,
            keccak256(encodeFrom(mail.from)),
            keccak256(encodeTo(mail.to))
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


