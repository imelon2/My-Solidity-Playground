// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract ERCLootBox is ERC20 {
    address factoryAddress;

    constructor(address _factoryAddress)
	ERC20("ERCLootBox", "ELB")
    {
        factoryAddress = _factoryAddress;
        _mint(msg.sender, 100000000e18);
    }
}
contract BadCodeSmarx {
    address public owner;
    constructor(address _owner) {
        owner = _owner;
    }

   function name() external pure returns (bytes32) {
      return bytes32("smarx");
   }

}

contract ERCFactory is Ownable {

    // 1. Get bytecode of contract to be deployed
    // NOTE: _owner and _foo are arguments of the TestContract's constructor
    function getBytecode(address _owner) public pure returns (bytes memory) {
        bytes memory bytecode = type(BadCodeSmarx).creationCode;

        return abi.encodePacked(bytecode, abi.encode(_owner));
    }

    // 2. Compute the address of the contract to be deployed
    // NOTE: _salt is a random number used to create an address
    function getAddress(bytes memory bytecode, uint _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), _salt, keccak256(bytecode))
        );

        // NOTE: cast last 20 bytes of hash to address
        return address(uint160(uint(hash)));
    }

  function deploy(bytes calldata _bytescode, uint _salt) public returns(address addr) {
    bytes memory bytecode = _bytescode;

        /*
        NOTE: How to call create2

        create2(v, p, n, s)
        create new contract with code at memory p to p + n
        and send v wei
        and return the new address
        where new address = first 20 bytes of keccak256(0xff + address(this) + s + keccak256(mem[p…(p+n)))
              s = big-endian 256-bit value
        */

    assembly {
      addr := create2(callvalue(), add(bytecode, 0x20), mload(bytecode), _salt)
    }
  }
}

