//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//we dont need to be calling alchemy node all the time
// we can just deploy a helper contract that returns the address of the price feed
//specifically for our testing purposes in our anvil local blockchain

//1. we will mocks when we are on a local anvil chain
///2. we will keep contract address for different chains in a config file

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
             //if we are on a local anvil chain  we deploy mocks
            //otherwise we grab the existing address from the respective chain
    
    struct NetworkConfig {
        address priceFeed; //EthUsd price feed address
    }

   uint8 public constant DECIMALS = 8;
   int256 public constant INITIAL_ANSWER = 2400e8;

    NetworkConfig public activeNetworkConfig;
    constructor () {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } 
        else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        }
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig () public pure returns(NetworkConfig memory){
        //get price feed address from sepolia
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }
       function getMainnetEthConfig () public pure returns(NetworkConfig memory){
        //get price feed address from sepolia
        NetworkConfig memory MainnetEthConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return MainnetEthConfig;
    }

    function getOrCreateAnvilEthConfig () public returns(NetworkConfig memory){
        //deploy mocks on anvil
        
        //in an instance where we are on anvil we deploy mocks
        //we do not want to redeploy mocks if they are already deployed thus we check if pricefeed address is already set or is not 0
        if(activeNetworkConfig.priceFeed != address (0)){
            return activeNetworkConfig;
        }


        vm.startBroadcast();
        // Mock price feed deployment would go here
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS,INITIAL_ANSWER);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address (mockPriceFeed)
        });
        return anvilConfig;
    }
}