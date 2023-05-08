// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./ERC2612.sol";


// ERC20 Contract
contract Dkargo is ERC2612 {
    constructor() ERC20("Dkargo", "DKA") ERC2612("Dkargo") {
        _mint(0xd644352A429F3fF3d21128820DcBC53e063685b1, 100 * 10 ** decimals());
    }
}

contract Bank {
    // ERC20 Contract
    Dkargo ERC20Addr;

    constructor(address _mytoken) {
        ERC20Addr = Dkargo(_mytoken);
    }

    function depositNoPermit(address spender,uint256 amount) public {
        // must be pre-approve
        ERC20Addr.transferFrom(spender, address(this), amount);
    }

    function deposit(address spender,uint256 amount,uint256 deadline,uint8 v,bytes32 r, bytes32 s) public {
        ERC20Addr.permit(spender, address(this), amount, deadline, v, r, s);
        ERC20Addr.transferFrom(spender, address(this), amount);
    }
}