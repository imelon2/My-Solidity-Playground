// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Target {
    function doSomething() public returns(string memory) {
        revert("test error");
    }
}
contract Test {

    uint public can;
    bytes public err;

 function _revert(bytes memory returndata, string memory errorMessage) public pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }

    function bytesLength(bytes memory returndata) public pure returns(uint) {
        return returndata.length;
    }
    
    function mloadTest(string memory _string) public pure returns(uint a) {
        bytes memory returndata = bytes(_string);
        assembly {
                let returndata_size := mload(returndata)
                revert (add(32,returndata),returndata_size)
            }
    }

    function tryCatchExternalCall(address target) public {
    try Target(target).doSomething() returns (string memory) {
            uint256 a = 1;
        } catch (bytes memory data) {
            _revert(data,"");
        }
        // Does not compile
        // DeclarationError: Undeclared identifier
        // uint256 d = a;
        // uint256 e = b;
    }

}
// 6.977900552486188000
// 0xa8694da46a1160f181da73e8b7b3fc57c74ea4a9cf5c2f03edb58c4a244ad90a
// 0x0000000000000000000000000000000000000000000000000000000000000000
// 0.003492912724937999ㅇㅁㅈㅇ