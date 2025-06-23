// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

interface IOptionVaultForVRF {
    function lpBalances(address) external view returns (uint256);
    function lps(uint256) external view returns (address);
    function totalLiquidity() external view returns (uint256);
}

contract VRFRewardDistributor is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;

    IOptionVaultForVRF public vault;
    address public winner;
    uint256 public rewardAmount;

    event RequestedRandomness(bytes32 requestId);
    event WinnerSelected(address winner, uint256 amount);

    constructor(
        address _vault,
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _fee
    ) VRFConsumerBase(_vrfCoordinator, _link) {
        keyHash = _keyHash;
        fee = _fee;
        vault = IOptionVaultForVRF(_vault);
    }

    function triggerReward(uint256 _rewardAmount) external {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        rewardAmount = _rewardAmount;
        bytes32 requestId = requestRandomness(keyHash, fee);
        emit RequestedRandomness(requestId);
    }

    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        uint256 total = vault.totalLiquidity();
        require(total > 0, "No LPs");

        // Select random LP
        address selected;
        uint256 i = 0;
        while (true) {
            address lp = vault.lps(i);
            if (lp == address(0)) break;
            uint256 chance = (vault.lpBalances(lp) * 1e18) / total;
            if (randomness % 1e18 < chance) {
                selected = lp;
                break;
            }
            i++;
        }

        winner = selected;
        payable(winner).transfer(rewardAmount);
        emit WinnerSelected(winner, rewardAmount);
    }

    receive() external payable {}
}
