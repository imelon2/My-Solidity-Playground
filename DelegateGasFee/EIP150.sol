// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;


// DO NOT USE!!!
contract Auction {
    address public highestBidder;
    uint256 public highestBid;

    uint256 public depth;

    function attack(uint i) public {
        if(i>1) {
            this.attack(i-1);
        }

        Auction.bid();
    }

    function bid() public payable {
        if (msg.value < highestBid) revert();

        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid); // refund previous bidder
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
    }
}


contract Recurse {

    function recurse(uint256 depth) external {

        // Each call takes at least 3 slots in the stack
        // uint256 placeHolder1 = 1;
        // uint256 placeHolder2 = 2;
        // uint256 placeHolder3 = 3;

        if(depth > 0) {
            this.recurse(depth - 1);
        }
    }
}

contract StackDepthTest {
    function a() internal {

    }

    function b() external {
        a();
    }

    function test(address _to) public payable {
        payable(_to).transfer(msg.value);
    }

    function _call() public {
        this.b();
    }
}

contract StackDepthAttack {
    StackDepthAttack stackDepthAttack;

    function setAddr(address addr) external {
        stackDepthAttack = StackDepthAttack(addr);
    }


    function callOther() external pure returns(bool) {
        return true;
    }

    function attack(uint i) public {
        if(i>1) {
            this.attack(i-1);
        }

        stackDepthAttack.callOther();
    }
}

