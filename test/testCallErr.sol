// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

contract SourceContract {

    // function pingMessage1(TargetContract target) public returns(string memory) {
    //     // test if accept can accept requests
    //     string memory result = target.ping(1);

    //     // we will never reach this line of code, 
    //     // because the external call reverts
    //     return result;
    // }

    function pingMessage2(TargetContract target,uint256 _a) public returns(bool,bytes memory) {
        (bool success,bytes memory result) = address(target).call(abi.encodeWithSignature("ping(uint256)", _a));
        return (success,result);
    }

    function pingMessage3(TargetContract target,uint256 _a,uint256 _gas) public returns(bool,bytes memory) {
        (bool success,bytes memory result) = address(target).call{gas:_gas}(abi.encodeWithSignature("ping(uint256)", _a));
        return (success,result);
    }

    function getBytes(string memory _string) public pure returns(bytes memory) {
        return bytes(_string);
    }
}

contract TargetContract {

    uint256 public save;
    function ping(uint a) public returns (uint256) {
        if(a == 0) {
            save = a;

            return a;
        } else if(a == 1) {
            return a;
        }  else if(a == 2) {
            require( a != 2,"require ping connection refused!");
        } else {
            revert("ping connection refused!");
        }
    
    }
}
//0x18366cd00000000000000000000000000498b7c793d7432cd9db27fb02fc9cfdbafa1fd30000000000000000000000000000000000000000000000000000000000000003

// 0x
//0000000000000000000000000000000000000000000000000000000000000020
//0000000000000000000000000000000000000000000000000000000000000007
//7375636365737300000000000000000000000000000000000000000000000000


//0x
//08c379a0 == keccak256(byte4("Error(string)"))
//0000000000000000000000000000000000000000000000000000000000000020
//0000000000000000000000000000000000000000000000000000000000000018
//70696e6720636f6e6e656374696f6e2072656675736564210000000000000000