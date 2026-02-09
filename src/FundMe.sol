//SPDX-License-Identifier: MIT

// contract to send funds in usdc
// withdraw funds in usdc
// set a minimun values for users to send



pragma solidity ^0.8.24;

import {priceConvertor} from "./PriceConvertor.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundeMe_NotOwner(address caller);
// current contract costs 784248 gas would love to reduce it
// we will be doing this using the const and immutable keyword
// for state values you will not change you can add const to it
contract FundMe {
     using priceConvertor for uint256;
    
    address private immutable i_owner;// the owner variable

    uint256 public constant MINIMUM_USD=5e18; // because minimumUsd wont change we make it constant reducing gas
    address [] private s_funders;
    mapping ( address funders => uint256 amountFunded) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    function fund() public payable  {
            require(msg.value.getConversionRate(s_priceFeed)>=MINIMUM_USD, "Not enough ETH");
            s_funders.push(msg.sender);
            s_addressToAmountFunded[msg.sender]=s_addressToAmountFunded[msg.sender]+msg.value;
            
    }

    constructor (address priceFeedAddres) {
         i_owner=msg.sender;
         s_priceFeed= AggregatorV3Interface(priceFeedAddres);
    }

    /**we would like to optimize the withdraw function
     * we would like to reduce the gas cost of the withdraw function
     * when we call withdraw function we loop through and always read s_funders.length which is a storage variable
     * reading from storage is expensive thus we can reduce gas by reading it once and storing it
     */
    
    function withdraw() public onlyOwner{
        uint256 fundersLength = s_funders.length; 

        /**
         * instead of  fundIndex < s_funders.length we use fundersLength
         * thus reducing gas cost by storing the length of the array in a variable
         */
        for (uint256 fundIndex= 0; fundIndex< fundersLength; fundIndex++) 
        {
            address funder = s_funders[fundIndex];
            s_addressToAmountFunded[funder]=0;
             
        }
         //now we go ahead and reset the array

         s_funders= new address[] (0);

         // now we are goig to withdraw and we can do this with
         // transfer, call, or send

         //transfer
         //for this msg.sender is of type address
         // but to make it sendable we need to make it a payable address
         // transfer automatically reverts if transfer fails
         //payable(msg.sender).transfer(address(this).balance);

         //send 
         //for sending we will need a require statement with a bool
         // send does not return any notification
         //send doesnt automatically reverts if send fails thus we need a require statement to revert the transaction

        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess,"Failed to send ETH");

        //call
        // call returns two variables a bool and data from your call
        //call doesnt automatically reverts if send fails thus we need a require statement to revert the transaction
        // call is the most gas efficient function
         (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
         require(callSuccess,"Call Failed, Failed to send ETH");

    }

   

    modifier  onlyOwner (){
        if (msg.sender != i_owner){
            revert FundeMe_NotOwner(msg.sender);}
        
        _;
     //require(msg.sender== i_owner, "You are not the owner"); // setting up the owner
     // underscore it the body or the code of the function you added the modifier too
     // if _; is before the code it runs it before it and if after it it runs the code before the modifier itself
    }

// what if someone sends a funds to a contract without our knowledge
// we can use recieve() for that and it can be used once
// must be external payabble and works when sender doest use fund in calldata
// fallback is either you call the wrong function or functio doesnt exist

function getVersion() public view returns (uint256){
        return s_priceFeed.version();
    } 

receive() external payable { fund(); }
fallback() external payable { fund();}


/**
 * View / Pure functions
 * view functions dont modify the state of the blockchain
 * pure functions dont read or modify the state of the blockchain
 * because our state variables are private we need to create getter functions for them
 */
 function getAddresstoAmountFunded(address fundingAddress) external view returns(uint256){
    return s_addressToAmountFunded[fundingAddress];
 }

 function getFunder(uint256 indexofFunder) external view returns(address){
    return s_funders[indexofFunder];

 }
 function getOwner() external view returns (address){
    return i_owner;
 }

}