// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
// https://medium.com/@jeancvllr/solidity-tutorial-all-about-assembly-5acdfefde05c
contract add {
    function _delegate() public pure returns (bytes memory result1,bytes memory result2) {
        
        assembly {
            result1 := calldatasize()
            calldatacopy(0, 0, calldatasize())
            result2 := calldatasize()

        }
    }

    function msgData() public pure returns(bytes memory result) {
        result = msg.data;
    }
    function delegateCall(address _address,bytes memory data) public returns(bytes memory) {
        (bool success,bytes memory result)=_address.delegatecall(data);
    }
}