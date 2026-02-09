// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/*
 * Mock contract for Chainlink AggregatorV3Interface
 * Used for local testing (anvil, hardhat, foundry)
 */
contract MockV3Aggregator {

    uint256 public constant VERSION = 6;
    uint8 public decimals;
    int256 private answer;

    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals = _decimals;
        answer = _initialAnswer;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 _answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (
            0,
            answer,
            block.timestamp,
            block.timestamp,
            0
        );
    }

    function updateAnswer(int256 _answer) external {
        answer = _answer;
    }

    function version() external pure returns (uint256) {
        return VERSION;
    }
}
