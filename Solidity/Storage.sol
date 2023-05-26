// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Timers.sol";

contract TimeWatch {
    // using Timers for *;
    Timers.Timestamp timer;
    
    // function startTimer(uint64 _deadline) public {
    //     Timers.Timestamp memory timer = Timers.Timestamp(0);
    //     timer.setDeadline(_deadline);
    // }
    function startTimer(uint64 _deadline) public {
        Timers.setDeadline(timer, _deadline);
    }

}

library StorageArg {
    struct Timestamp {
        uint64 _deadline;
    }

    function get(Timestamp storage _Timestamp) public {
        _Timestamp._deadline = 10;
    }
}

contract StorageBody {
    struct Info {
        uint256 count;
        address who;
    }
    
    mapping(address => Info) public numByAddr;

    function setInfo(address _to,uint256 _num) public {
        Info storage _info = numByAddr[_to];
        _info.count = _num;
        _info.who = msg.sender;
    }

}

contract StotageMapping {
    mapping(address => uint256) public numAddr;


    function getSlot() public pure returns(uint256 slot) {
        assembly {
            slot := numAddr.slot
        }
    }
}

contract MappingStorage {

    mapping(address => uint) public balances;
    uint8 constant balancesMappingIndex = 0;

    constructor() {
        balances[0x6827b8f6cc60497d9bf5210d602C0EcaFDF7C405] = 678;
        balances[0x66B0b1d2930059407DcC30F1A2305435fc37315E] = 501;
    }

    function getStorageLocationForKey(address _key) public pure returns(bytes32) {
        // This works pretty well as concatenation. For the address 0x6827b8f6cc60497d9bf5210d602C0EcaFDF7C405, 
        // the storage slot index hash would be: 0x86dfc0930cb222883cc0138873d68c1c9864fc2fe59d208c17f3484f489bef04
        return keccak256(abi.encode(_key, balancesMappingIndex));
    }

    function getKeyEncodedWithMappingIndex(address _key) public pure returns(bytes memory) {
        // For the address 0x6827b8f6cc60497d9bf5210d602C0EcaFDF7C405, the encoded data would be:
        // 0x0000000000000000000000006827b8f6cc60497d9bf5210d602c0ecafdf7c4050000000000000000000000000000000000000000000000000000000000000000
      return abi.encode(_key, balancesMappingIndex);
    }

}