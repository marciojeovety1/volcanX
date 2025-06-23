// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library VolatilityMath {
    /// @notice Returns the absolute percentage difference between a and b, scaled by 1e4 (e.g. 5% = 500)
    function percentageDiff(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) return 0;
        if (a > b) {
            return ((a - b) * 10000) / a;
        } else {
            return ((b - a) * 10000) / a;
        }
    }

    /// @notice Simple utility for checking if price moved up or down
    function movedUp(uint256 start, uint256 end) internal pure returns (bool) {
        return end > start;
    }

    /// @notice Return true if percent move is above threshold
    function exceededThreshold(uint256 a, uint256 b, uint256 thresholdPct) internal pure returns (bool) {
        return percentageDiff(a, b) >= thresholdPct;
    }
}
