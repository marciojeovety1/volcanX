// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {OptionVault} from "src/core/OptionVault.sol";
import {IPriceFeed} from "src/interfaces/IPriceFeed.sol";

contract MockPriceFeed is IPriceFeed {
    int256 public answer;
    uint8 public override decimals = 8;
    string public override description = "MOCK";
    uint256 public override version = 1;

    constructor(int256 _answer) {
        answer = _answer;
    }

    function latestRoundData()
        external
        view
        override
        returns (
            uint80, int256, uint256, uint256, uint80
        )
    {
        return (0, answer, block.timestamp, block.timestamp, 0);
    }

    function getRoundData(uint80)
        external
        pure
        override
        returns (
            uint80, int256, uint256, uint256, uint80
        ) {
        revert("Not implemented");
    }

    function latestAnswer() external view override returns (int256) {
        return answer;
    }

    function latestTimestamp() external view override returns (uint256) {
        return block.timestamp;
    }

    function latestRound() external view override returns (uint256) {
        return 0;
    }

    function getAnswer(uint256) external view override returns (int256) {
        return answer;
    }

    function getTimestamp(uint256) external view override returns (uint256) {
        return block.timestamp;
    }
}

contract OptionVaultTest is Test {
    OptionVault public vault;
    MockPriceFeed public mockFeed;
    address public lp;
    address public trader;

    function setUp() public {
        mockFeed = new MockPriceFeed(1000e8); // 1000.00 price
        vault = new OptionVault(address(mockFeed));

        lp = address(0x123);
        trader = address(0x456);

        vm.deal(lp, 10 ether);
        vm.deal(trader, 10 ether);
    }

    function testDepositLiquidity() public {
        vm.prank(lp);
        vault.depositLiquidity{value: 5 ether}();

        assertEq(vault.totalLiquidity(), 5 ether);
        assertEq(vault.lpBalances(lp), 5 ether);
    }

    function testCreateOption() public {
        vm.prank(lp);
        vault.depositLiquidity{value: 5 ether}();

        vm.prank(trader);
        vault.createOption{value: 1 ether}(true, 1 hours, 500);

        assertEq(vault.totalLiquidity(), 6 ether);
        assertEq(address(vault).balance, 6 ether);
    }

    function testSettleOptions() public {
        vm.prank(lp);
        vault.depositLiquidity{value: 5 ether}();

        vm.prank(trader);
        vault.createOption{value: 1 ether}(true, 1 hours, 500);

        vm.warp(block.timestamp + 3600);
        vault.settleExpiredOptions();

        assertTrue(true); // Just to ensure it runs without revert
    }
}