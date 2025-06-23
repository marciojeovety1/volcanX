// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {OptionVault} from "src/core/OptionVault.sol";
import {VolatilityOracleManager} from "src/services/VolatilityOracleManager.sol";
import {AutomationResolver} from "src/services/AutomationResolver.sol";
import {VRFRewardDistributor} from "src/services/VRFRewardDistributor.sol";
import {CrossChainRouter} from "src/services/CrossChainRouter.sol";

contract DeployVolcanX is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address priceFeed = 0x0000000000000000000000000000000000000000; // replace with real feed
        address vrfCoordinator = 0x0000000000000000000000000000000000000000; // replace
        address linkToken = 0x0000000000000000000000000000000000000000; // replace
        bytes32 keyHash = 0x0; // replace
        uint256 fee = 0.1 ether;
        address ccipRouter = 0x0000000000000000000000000000000000000000; // replace

        OptionVault vault = new OptionVault(priceFeed);
        VolatilityOracleManager oracleManager = new VolatilityOracleManager();
        AutomationResolver resolver = new AutomationResolver(address(vault));
        VRFRewardDistributor vrf = new VRFRewardDistributor(
            address(vault), vrfCoordinator, linkToken, keyHash, fee
        );
        CrossChainRouter router = new CrossChainRouter(ccipRouter, address(vault));

        vm.stopBroadcast();
    }
}
