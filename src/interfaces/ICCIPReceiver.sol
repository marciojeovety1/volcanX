// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ICCIPReceiver - Interface for Chainlink CCIP Receiver-compatible contracts
interface ICCIPReceiver {
    struct Any2EVMMessage {
        bytes32 messageId;
        uint64 sourceChainSelector;
        bytes sender;
        bytes data;
        EVMTokenAmount[] destTokenAmounts;
    }

    struct EVMTokenAmount {
        address token;
        uint256 amount;
    }

    /// @notice Handles an incoming CCIP message
    /// @param message Full message from a source chain
    function ccipReceive(Any2EVMMessage calldata message) external;
}