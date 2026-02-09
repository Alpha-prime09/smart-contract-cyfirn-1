//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

//contract to write tests for FundMe contract
import {FundMe} from "../../src/FundMe.sol";
import {Test,console} from "forge-std/Test.sol";
import {priceConvertor} from "../../src/PriceConvertor.sol";
import {DeployFundme} from "../../script/DeployFundme.s.sol";
import {FundFundMeInteraction} from "../../script/Interactions.s.sol";
import {WithdrawFundMe} from "../../script/Interactions.s.sol";

contract testFundMeIntegration is Test{
    address USER = makeAddr("user"); //we create a fk address using forge std library
    uint256 constant ETH_TO_SEND = 1 ether;
    uint256 constant STARTING_BALANCE=100 ether;
    FundMe public fundMe;
    uint256 constant GAS_PRICE=1;

    function setUp() external {
        DeployFundme deployer = new DeployFundme();
        fundMe = deployer.run();
        vm.deal(USER,STARTING_BALANCE); // we fund the user with 100 ether
    }

    function testUserCanFund () public{
        FundFundMeInteraction fundFundMe= new FundFundMeInteraction();
        vm.deal(address(fundFundMe),STARTING_BALANCE);
        fundFundMe.FundFundMe(address(fundMe));


        WithdrawFundMe withdrawFromFundMe = new WithdrawFundMe();
        withdrawFromFundMe.WithdrawFromFundMe(address(fundMe));

        assert(address(fundMe).balance==0);

    }
}