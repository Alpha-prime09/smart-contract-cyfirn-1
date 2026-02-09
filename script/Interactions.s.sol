//SPDX-License-Identifier:MIT

pragma solidity ^0.8.24;

//we need to interact with our contract in script format
//we will do it for funding and withdrawing
import {Script,console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
contract FundFundMeInteraction is Script{
    
  uint256 constant SENDING_VALUE = 1 ether;

  function FundFundMe(address mostRecentlyDeployed) public {
    
    FundMe(payable(mostRecentlyDeployed)).fund{value: SENDING_VALUE}();
    console.log("Funded %s contract with %s",mostRecentlyDeployed,SENDING_VALUE);

    }
  function run() external {
    vm.startBroadcast();
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
    FundFundMe(mostRecentlyDeployed);
    vm.stopBroadcast();
    }
}


contract WithdrawFundMe is Script{
  function WithdrawFromFundMe(address mostRecentlyDeployed) public {
    vm.startBroadcast();
    FundMe(payable(mostRecentlyDeployed)).withdraw();
    console.log("Withdrew from %s contract",mostRecentlyDeployed);
    vm.stopBroadcast();
  }
  function run() external {
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
    WithdrawFromFundMe(mostRecentlyDeployed);
  
  }


}