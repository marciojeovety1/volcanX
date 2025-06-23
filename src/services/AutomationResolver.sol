// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";

interface IOptionVault {
    function nextOptionId() external view returns (uint256);
    function options(uint256) external view returns (
        address user,
        uint256 amount,
        uint256 strikePrice,
        uint256 expiry,
        bool executed,
        bool directionUp,
        uint256 thresholdPct
    );
    function settleOption(uint256 id) external;
}

contract AutomationResolver is KeeperCompatibleInterface {
    IOptionVault public vault;
    uint256 public lastCheckedId;

    constructor(address _vault) {
        vault = IOptionVault(_vault);
    }

    // Chainlink Automation-compatible
    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory performData) {
        uint256 current = lastCheckedId;
        uint256 max = vault.nextOptionId();

        for (uint256 i = current; i < max; i++) {
            (, , , uint256 expiry, bool executed, , ) = vault.options(i);
            if (!executed && block.timestamp >= expiry) {
                upkeepNeeded = true;
                performData = abi.encode(i);
                break;
            }
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        uint256 id = abi.decode(performData, (uint256));
        vault.settleOption(id);
        lastCheckedId = id + 1;
    }
}