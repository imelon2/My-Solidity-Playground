// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract dkanrjsk {
    uint public minMultiplier = 100;
    uint public maxMultiplier = 10000;

    function amountToBettableAmountConverter(uint amount) public pure returns(uint) {
        return amount * (10000 - 300) / 10000;
    }

    function amountToWinnableAmount(uint _amount, uint multiplier) public pure returns (uint) {
        uint bettableAmount = amountToBettableAmountConverter(_amount);
        return bettableAmount * multiplier / 100;
    }

    function test(uint256 randomNumber)
        public view returns(uint) {
        uint H = randomNumber % (maxMultiplier - minMultiplier + 1);
        uint E = maxMultiplier / 100;
        uint multiplierOutcome = (E * maxMultiplier - H) / (E * 100 - H);

        return (multiplierOutcome);
    }

    function test2(uint a,uint b) public pure returns(uint) {
        return a / b;
    }
    
}