// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract SBT is ERC721 {

    enum BurnAuth {
        IssuerOnly,
        OwnerOnly,
        Both,
        Neither
    }

    //토큰 id로 소유자 확인
    mapping(uint256 => address) private owners;
    //address의 토큰 소유 갯수 확인
    mapping(address => uint256) private balances;
    mapping(uint256 => bool) private lock;
    mapping(uint256 => BurnAuth) private auth;
    //minting을 진행할 Lodis 컨트랙트 주소, Lodis가 직접 발행하지 않는다면 변경 필요
    address immutable LODIS;

    event Issued (
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        BurnAuth burnAuth
    );

    //토큰 발행후 lock 처리한 토큰 event
    event Locked(uint256 tokenId);

    event Unlocked(uint256 tokenId);

    constructor(address lodis) ERC721("SBT", "SBT") {
        LODIS = lodis;
    }

    //@notice 유저가 주문 종료 처리(성공, 실패, 취소) 시 조건 확인 후 토큰발행
    //@dev 토큰 발행에 필요한 데이터 인자로 추가 필요, 오더컨트랙트만 실행가능. minting직후 lock
    //@param to 발행될 토큰 소유주
    //@param tokenId 
    function mint(address to, uint256 tokenId, BurnAuth _auth) external returns(uint256) {
        _mint(to, tokenId);
        lock[tokenId] = true;
        auth[tokenId] = _auth;

        emit Locked(tokenId);
        return tokenId;
    }

    //@notic 토큰 lock 여부 확인
    //@dev 기본적으로 모든 토큰은 발행 직후 lock 상태
    //@param tokenId 확인할 tokenId
    function locked(uint256 tokenId) external view returns(bool) {
        return lock[tokenId];
    }


    //@notic 토큰 소각 허용자 확인
    //@dev 발행 당시 지정된 소각 허용자를 반환
    //@param tokenId 확인할 tokenId
    function burnAuth(uint256 tokenId) external view returns(BurnAuth) {
        return auth[tokenId];
    }
}