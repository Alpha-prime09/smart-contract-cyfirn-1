// we will be creating a library
// functions inside it will be internal

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


library priceConvertor {

     
    function getPrice(AggregatorV3Interface priceFeed) internal view  returns (uint256) {
    // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
    // ABI
    ( ,int256 price, , , )= priceFeed.latestRoundData(); // returns price of eth in usd
    return uint256 (price * 1e10);
    } 

    function getConversionRate(uint256 ethAmount,AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // ask for an eth, multiply by eth price in usd from get price and ensure everything in 1e18
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/1e18;
        return ethAmountInUsd;
    }

       

}