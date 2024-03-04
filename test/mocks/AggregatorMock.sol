// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import {AggregatorV3Interface} from "../../src/interfaces/AggregatorV3Interface.sol";

contract AggregatorMock is AggregatorV3Interface {
    uint8 public immutable decimals;
    string public description;
    uint256 public version = 4;

    uint80 roundId;
    int256 answer;
    uint256 timestamp;

    constructor(uint8 _decimals, string memory _description) {
        decimals = _decimals;
        description = _description;
    }

    function setAnswer(uint80 round, int256 _answer, uint256 _timestamp) public {
        roundId = round;
        answer = _answer;
        timestamp = _timestamp;
    }

    function latestRoundData() external view returns (uint80 _roundId, int256 _answer, uint256 _startAt, uint256 _updatedAt, uint80 _answerInRound) {
        _roundId = roundId;
        _answer = answer;
        _startAt = timestamp;
        _updatedAt = timestamp;
        _answerInRound = roundId;
    }

}