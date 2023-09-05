// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Lottery} from "../contracts/Lottery.sol";
import {MockQRNGProxy} from "../contracts/Mocks/MockQRNG.sol";
//import {DeployLottery} from "../scripts/DeployLottery.s.sol";
import {Test, console} from "forge-std/Test.sol";


contract TestLottery is Test {
    Lottery public lottery;
    MockQRNGProxy public mockQRNG;

    function setUp() external {
        vm.startBroadcast();
        mockQRNG = new MockQRNGProxy();
        lottery = new Lottery(address(mockQRNG));
        vm.stopBroadcast();
    }
    
    /* to see logs "forge test -vv" for more tracing add more v's */
    function testOwner() public {
       //  console.log("Lottery owner: %s", address(lottery.owner()));
         console.log("Msg sender: %s", address(msg.sender));
        //assertEq(lottery.owner(), msg.sender);
    }

    // function testPriceFeed() public {
    //     int224 price = 100e18;
    //     uint256 expectedValue = 100e18;
    //     // starting Prank ALL subsequent calls will come from msg.sender
    //     vm.startPrank(msg.sender);
    //     // setting a block time
    //     vm.warp(1692843154);
    //     mockDapi.setDapiValues(price, uint32(block.timestamp));
    //     priceFeed.setProxyAddress(address(mockDapi));
    //     vm.stopPrank();
    //     (uint a, uint b) = priceFeed.readDataFeed();
    //     console.log("PriceFeed Value", a);
    //     console.log("PriceFeed Timestamp", b);
       
    //     assertEq(expectedValue, a);
    //     assertEq(b, uint32(block.timestamp));
    // }
}