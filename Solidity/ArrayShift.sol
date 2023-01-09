// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArrayShift {
    uint[] public arr;

    function initArr() public {
        arr = [1,2,3,4,5];
    }

    function deleteArray() public {
        delete arr[1]; // [1,2,3,4,5] -> [1,0,3,4,5]
    }

    /*
     * [Goal] : [1,2,3,4,5] -> [1,3,4,5]
     * [Alg] : [1,2,3,4,5] -- remove(1) -->  [1,3,4,5,5] -- pop() --> [1,3,4,5]
     */ 
    function remove(uint _index) public {
        require(_index < arr.length,"index out of bound");
        for(uint i = _index; i < arr.length -1; i++ ) {
            arr[i] = arr[i+1];
        }
        arr.pop();
    }
}