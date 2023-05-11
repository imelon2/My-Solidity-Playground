// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC5528} from "./IERC5528.sol";
import "@openzeppelin/contracts/utils/Address.sol";

// ERC20 Contract
contract Dkargo is ERC20 {
    using Address for address;


    constructor() ERC20("Dkargo", "DKA") {
        _mint(msg.sender, 100 * 10 ** decimals());
    }

    function escrowFund(address to,uint256 amount) public {
        if(!to.isContract()) revert("ERC5528: transfer to non contract address");

        transfer(to, amount);
        IERC5528(to).escrowFund(msg.sender,amount);
    }
}

contract tUSDT is ERC20 {
    using Address for address;


    constructor() ERC20("tUSDT", "tUSDT") {
        _mint(msg.sender, 100 * 10 ** decimals());
    }

    function escrowFund(address to,uint256 amount) public {
        if(!to.isContract()) revert("ERC5528: transfer to non contract address");
        
        transfer(to, amount);
        IERC5528(to).escrowFund(msg.sender,amount);
    }
}
