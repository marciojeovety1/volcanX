// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts-ccip/src/v0.8/CCIPReceiver.sol";
import "@chainlink/contracts-ccip/src/v0.8/interfaces/CCIPRouterInterface.sol";

interface IRemoteOptionVault {
    function createOption(bool, uint256, uint256) external payable;
}

contract CrossChainRouter is CCIPReceiver {
    address public localVault;
    mapping(string => address) public trustedSenders; // remoteChainName => address

    event RemoteBetPlaced(address indexed user, bool directionUp, uint256 duration, uint256 threshold);

    constructor(address _router, address _vault) CCIPReceiver(_router) {
        localVault = _vault;
    }

    function setTrustedSender(string calldata chain, address sender) external {
        trustedSenders[chain] = sender;
    }

    // Handle CCIP Messages
    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        (bool directionUp, uint256 duration, uint256 threshold) = abi.decode(message.data, (bool, uint256, uint256));
        string memory chain = string(message.sourceChainSelector);
        require(msg.sender == address(ROUTER), "Not CCIP Router");
        require(trustedSenders[chain] == message.sender, "Untrusted sender");

        IRemoteOptionVault(localVault).createOption{value: message.destTokenAmounts[0].amount}(directionUp, duration, threshold);

        emit RemoteBetPlaced(tx.origin, directionUp, duration, threshold);
    }

    receive() external payable {}
}