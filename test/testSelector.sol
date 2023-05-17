// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;


contract test {
// meta data
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
    }

    function CallData1(address _to,uint256 _amount,bytes memory _data) public pure returns(bytes memory) {
        return abi.encodeWithSignature("transferFromAndCall(address,uint256)", _to,_amount);
    }

    function CallData2(address _to) public pure returns(bytes memory) {
        return abi.encodeWithSignature("countNum(address)", _to);
    }

}
//["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xBBa767f31960394B6c57705A5e1F0B2Aa97f0Ce8","0","30000","0","0x01"]
// "transferAndCall(address,uint256,bytes)"