// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {OptionVault} from "src/core/OptionVault.sol";
import {IPriceFeed} from "src/interfaces/IPriceFeed.sol";

contract SimulateOptionFlow is Script {
    OptionVault public vault;

    address user = vm.addr(1);
    address lp = vm.addr(2);

    function run() external {
        vm.startBroadcast();

        vault = new OptionVault(0x0000000000000000000000000000000000000000); // replace with real feed

        // LP deposits liquidity
        vm.deal(lp, 5 ether);
        vm.prank(lp);
        vault.depositLiquidity{value: 2 ether}();

        // User places option bet
        vm.deal(user, 1 ether);
        vm.prank(user);
        vault.createOption{value: 0.5 ether}(true, 3600, 500); // up bet, 1 hour, 5% threshold

        // Fast-forward time (simulate expiration)
        vm.warp(block.timestamp + 3600);

        // Manually settle expired option (assumes price feed set up)
        vault.settleExpiredOptions();

        vm.stopBroadcast();
    }
}