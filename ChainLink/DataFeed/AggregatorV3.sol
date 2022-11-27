// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MaticToUSD {
    AggregatorV3Interface internal priceFeed = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada); // mumbai;

    // polygon data feed heartbeat is 27 seconds.
    // Apply the quote within about 54 seconds.
    uint80 public minRoundId = 2;

    struct PriceData {
        uint80 roundID;
        uint256 price;
        uint startedAt;
        uint timeStamp;
        uint80 answeredInRound;
    }

    // [ChainLink] MATIC / USD
    function getLatestPrice() private view returns(PriceData memory) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        )  = priceFeed.latestRoundData();

        return PriceData(roundID,uint256(price),startedAt,timeStamp,answeredInRound);
    }
    
    // [ChainLink]] MATIC / USD : (need roundId)
    function getRoundData(uint80 _roundId) private view returns(PriceData memory)  {
        (
        uint80 roundID,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
        ) = priceFeed.getRoundData(_roundId);

        return PriceData(roundID,uint256(price),startedAt,timeStamp,answeredInRound);
    }
}