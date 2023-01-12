// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract IsContract {

    function isContract1(address account) public view returns (uint) {
        return account.code.length;
    }

    function isContract2(address account) public view returns (uint) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size;
    }

    function isContract(address account) public view returns(bool) {
        return account.code.length > 0;
    }
}

