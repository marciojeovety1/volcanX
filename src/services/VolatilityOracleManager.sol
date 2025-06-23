// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract VolatilityOracleManager {
    AggregatorV3Interface public priceFeed;

    struct PriceSnapshot {
        uint256 timestamp;
        uint256 price;
    }

    mapping(bytes32 => PriceSnapshot) public snapshots;

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function recordSnapshot(string memory label) external {
        (, int price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");

        snapshots[keccak256(abi.encodePacked(label))] = PriceSnapshot({
            timestamp: block.timestamp,
            price: uint256(price)
        });
    }

    function getSnapshot(string memory label) external view returns (uint256, uint256) {
        PriceSnapshot memory snap = snapshots[keccak256(abi.encodePacked(label))];
        return (snap.timestamp, snap.price);
    }
}