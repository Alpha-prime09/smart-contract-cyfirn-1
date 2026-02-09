//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

//contract to write tests for FundMe contract
import {FundMe} from "../../src/FundMe.sol";
import {Test,console} from "forge-std/Test.sol";
import {priceConvertor} from "../../src/PriceConvertor.sol";
import {DeployFundme} from "../../script/DeployFundme.s.sol";

contract FundMeTest is Test{
    FundMe public fundMe;
    address USER = makeAddr("user"); //we create a fk address using forge std library
    uint256 constant ETH_TO_SEND = 1 ether;
    uint256 constant STARTING_BALANCE=100 ether;
    uint256 constant GAS_PRICE=1;

    function setUp() external{
        DeployFundme deployer = new DeployFundme();
        fundMe = deployer.run();
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.deal(USER,STARTING_BALANCE); // we fund the user with 100 ether
    }
    
    function testMinimumUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(),5e18);
        console.log(fundMe.MINIMUM_USD());
    }

    function testOwnerIsMsgSender() public view {
        console.log(address(this));
        console.log(fundMe.getOwner());
        assertEq(fundMe.getOwner(),msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        // we can use console.log to print values to the terminal
        //if we run tes without an rpc url forge spins new
        //anvil thus our getversion always reverts because we are hoping for sepolia

        console.log(fundMe.getVersion());
        assertEq(fundMe.getVersion(),4);
    }

    function testFundFailsWithoutEnoughEth() public {
        // we expect this call to revert thus we use vm.expectRevert
        //it expects a revert at the next line after vm.expectRevert
       vm.expectRevert();
       fundMe.fund();
    }
    
    function testFundUpdatesFundedDataStructure() public {
      /**
       * we would like to test if the funders list update and you get the fund amount base on address
       * so we pass in a fund amount with and address and assert if the mappings and arrays are updated with the amount funded
       * which will pass in the assertEq function
       */
        vm.prank(USER);// Now the next tx will be sent by USER
        fundMe.fund{value:ETH_TO_SEND}();
        uint256 amountFunded = fundMe.getAddresstoAmountFunded(USER);
        assertEq(amountFunded,ETH_TO_SEND);
    }
    function testAddressIsAddedToFundersArray() public funded{
    
        address funder=fundMe.getFunder(0);
        assertEq(funder,USER);

    }
    modifier funded(){
        vm.prank(USER);
        fundMe.fund{value:ETH_TO_SEND}();
        _;}

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

   function testWithdrwaAsSingleFunder() public funded {
    //we look at these 3 things to begin tests
    /**
     * 1.Arrange
     * 2.Act
     * 3.Assert
     */


    //arrange
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance=address(fundMe).balance;

    //act is where we are testing the withdraw function
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();
   
    //assert
    uint256 endingOwnerBalance=fundMe.getOwner().balance;
    uint256 endingFundMeBalance=address(fundMe).balance;

    assertEq(endingFundMeBalance,0);
    assertEq(startingOwnerBalance + startingFundMeBalance,endingOwnerBalance);
   }

   function testWithdrawfromMultipleFunders() public funded{

   //arrange
   uint160 numberOfFunders =10;
   uint160 startingFunderIndex=1;
    for (uint160 i=startingFunderIndex; i<numberOfFunders; i++){
        /**
         * naturally we want to do a vm.prank here to simulate different funders
         * but we also want to fund them with some ether thus we use vm.deal to
         * fund them with some ether and then we prank them to call the fund function
         * in this case we can use hoax which combines vm.deal and vm.prank
         */
        hoax(address(i),ETH_TO_SEND);
        fundMe.fund{value:ETH_TO_SEND}();
         
    }

    uint256 startingOwnerBalance = fundMe.getOwner().balance;   
    uint256 startingFundMeBalance=address(fundMe).balance;
    
    //Act

    /**
     * uint256 gasStart = gasleft();// gasleft() returns the amount of gas remaining in the transaction
       vm.txGasPrice(GAS_PRICE)
    */
    
    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();  
    vm.stopPrank();

/** 
 * uint256 gasEnd = gasleft();
   uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;//tx.gasprice gets the gas price set for the transaction or the current gas price if not set
   console.log("Gas Used:",gasUsed);
*/
    
    //assert
   assertEq(address(fundMe).balance,0);
   assertEq(startingOwnerBalance + startingFundMeBalance,fundMe.getOwner().balance);
   }

}   