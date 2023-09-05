// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "../contracts/Lottery.sol";
//import {MockDapiProxy} from "../contracts/Mocks/MockDapi.sol";

contract DeployLottery is Script {
    function run() external returns (Lottery) {
        vm.startBroadcast();
        // MockDapiProxy mockDapiProxy = new MockDapiProxy();
        Lottery lottery = new Lottery(address(0x6238772544f029ecaBfDED4300f13A3c4FE84E1D));
        vm.stopBroadcast();
        return (lottery);
    }
}