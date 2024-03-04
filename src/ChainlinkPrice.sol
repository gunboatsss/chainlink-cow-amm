// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import {AggregatorV3Interface} from "./interfaces/AggregatorV3Interface.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";

struct Data {
    address token0Feed;
    address token1Feed;
}

contract ChainlinkPrice is IPriceOracle {
    function getPrice(address, address, bytes calldata data)
        external
        view
        returns (uint256 priceNumerator, uint256 priceDenominator)
    {
        Data memory OracleData = abi.decode(data, (Data));
        AggregatorV3Interface token0Feed = AggregatorV3Interface(OracleData.token0Feed);
        AggregatorV3Interface token1Feed = AggregatorV3Interface(OracleData.token1Feed);
        ( /* uint80 roundId*/
            , int256 token0Answer, /* uint256 startedAt */, uint256 token0Timestamp, /* uint80 answerInRound */
        ) = token0Feed.latestRoundData();
        ( /* uint80 roundId*/
            , int256 token1Answer, /* uint256 startedAt */, uint256 token1Timestamp, /* uint80 answerInRound */
        ) = token1Feed.latestRoundData();
        uint256 timestamp = block.timestamp;
        require(timestamp - token0Timestamp < 86400 && timestamp - token1Timestamp < 86400, "stale oracle");
        uint256 token0Decimals = token0Feed.decimals();
        uint256 token1Decimals = token1Feed.decimals();
        // AMPL / USD has 18 decimals lol
        if (token0Decimals == token1Decimals) {
            priceNumerator = uint256(token0Answer);
            priceDenominator = uint256(token1Answer);
        } else {
            priceNumerator = uint256(token0Answer) * (10 ** (18 - token0Decimals));
            priceDenominator = uint256(token1Answer) * (10 ** (18 - token1Decimals));
        }
    }
}
