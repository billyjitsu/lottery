// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "../contracts/Lottery.sol";
//import {MockDapiProxy} from "../contracts/Mocks/MockDapi.sol";

contract DeployLottery is Script {
    function run() external returns (Lottery) {
        vm.startBroadcast();
        // MockDapiProxy mockDapiProxy = new MockDapiProxy();
        Lottery lotteryContract = new Lottery(0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd);
        vm.stopBroadcast();
        return (lotteryContract);
    }
}