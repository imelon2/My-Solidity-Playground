// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FallbackExample {
    fallback() external  payable {
    	// 컨트렉트에 포함되지 않은 기능이 호출될 경우
        // 전부 revert()
        revert();
    }
}

contract ReceiveExample {

    receive() external  payable {
        revert();
    }
}