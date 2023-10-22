// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {FundMeFacet} from "../src/facets/FundMeFacet.sol";

contract DeployFundMe is Script {
    function run() external {
        vm.startBroadcast();
        new FundMeFacet ();
        vm.stopBroadcast();
    }
}
