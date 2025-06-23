// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {VRFRewardDistributor} from "src/services/VRFRewardDistributor.sol";
import {OptionVault} from "src/core/OptionVault.sol";

contract MockVaultForVRF is OptionVault {
    address public winner;

    constructor(address _priceFeed) OptionVault(_priceFeed) {}

    function getLPRandomWinner() external view returns (address) {
        return winner;
    }

    function mockSetWinner(address _winner) external {
        winner = _winner;
    }
}

contract VRFRewardDistributorTest is Test {
    VRFRewardDistributor public distributor;
    MockVaultForVRF public mockVault;

    function setUp() public {
        mockVault = new MockVaultForVRF(address(0x123));
        distributor = new VRFRewardDistributor(
            address(mockVault),
            address(0),
            address(0),
            bytes32(0),
            0.1 ether
        );
    }

    function testRequestRandomness() public {
        // We just want to confirm the function is callable
        distributor.requestRandomWinner();
        assertTrue(true); // If no revert, test passes
    }

    function testFulfillRandomnessAccessControl() public {
        vm.expectRevert();
        distributor.rawFulfillRandomWords(1, new uint256 );
    }
}
