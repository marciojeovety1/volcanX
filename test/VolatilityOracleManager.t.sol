// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {VolatilityOracleManager} from "src/services/VolatilityOracleManager.sol";
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
        )
    {
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

contract VolatilityOracleManagerTest is Test {
    VolatilityOracleManager public manager;
    MockPriceFeed public mockFeed;

    function setUp() public {
        manager = new VolatilityOracleManager();
        mockFeed = new MockPriceFeed(1000e8); // 1000.00 price
    }

    function testRequestAndGetPrice() public {
        manager.requestPrice("AVAX/USD", address(mockFeed));
        uint256 price = manager.getPrice("AVAX/USD");
        assertEq(price, 1000e8);
    }
}
