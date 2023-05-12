// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;


// DO NOT USE!!!
contract Auction {
    address public highestBidder;
    uint256 public highestBid;

    function bid() external payable {
        if (msg.value < highestBid) revert();

        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBid); // refund previous bidder
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
    }
}