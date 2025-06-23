// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IAutomationCompatible - Chainlink Automation (Keepers) interface
interface IAutomationCompatible {
    /**
     * @notice Checks if upkeep is needed.
     * @param checkData custom input data for check logic
     * @return upkeepNeeded true if upkeep needed
     * @return performData data to pass to performUpkeep
     */
    function checkUpkeep(bytes calldata checkData) external view returns (bool upkeepNeeded, bytes memory performData);

    /**
     * @notice Performs the automated task
     * @param performData data returned from checkUpkeep
     */
    function performUpkeep(bytes calldata performData) external;
}
