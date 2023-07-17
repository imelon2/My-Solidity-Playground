// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract testCul {
    function test() public pure returns(uint) {
        if(true && true && !false) {
            return 1;
        }
         return 0;
    }

    function concatSig(uint8 v, bytes32 r, bytes32 s) public pure returns(bytes memory signature) {
        // assembly {
        //     v := byte(0, mload(add(signature, 0x60)))
        //     r := mload(add(signature, 0x20))
        //     s := mload(add(signature, 0x40))
        // }
        return abi.encodePacked(r,s,v);
    }

    function get() public pure returns(uint) {
        return 1 hours;
    }
}

//0x1029ff0e2a19ecf897c8abbac652025475d39c966e9d502e9fda28ba6615559d3683f094086026b1f247e3ecf7ba134d65017268afa93466d423d24c473c277c1b
//0x1029ff0e2a19ecf897c8abbac652025475d39c966e9d502e9fda28ba6615559d3683f094086026b1f247e3ecf7ba134d65017268afa93466d423d24c473c277c1b