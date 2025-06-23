// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {CrossChainRouter} from "src/services/CrossChainRouter.sol";
import {OptionVault} from "src/core/OptionVault.sol";
import {ICCIPReceiver} from "src/interfaces/ICCIPReceiver.sol";

contract MockVault is OptionVault {
    bool public optionCreated;

    constructor(address _priceFeed) OptionVault(_priceFeed) {}

    function createOption(bool, uint256, uint256) public payable override {
        optionCreated = true;
    }
}

contract CrossChainRouterTest is Test {
    CrossChainRouter public router;
    MockVault public vault;

    function setUp() public {
        vault = new MockVault(address(0x123));
        router = new CrossChainRouter(address(this), address(vault));
    }

    function testSetTrustedSenderAndReceive() public {
        uint64 sourceChain = 43113;
        address mockSender = address(0x456);

        router.setTrustedSender(sourceChain, mockSender);

        bytes memory encodedPayload = abi.encode(true, 3600, 500);

        ICCIPReceiver.Any2EVMMessage memory msgData = ICCIPReceiver.Any2EVMMessage({
            messageId: bytes32(0),
            sourceChainSelector: sourceChain,
            sender: abi.encode(mockSender),
            data: encodedPayload,
            destTokenAmounts: new ICCIPReceiver.EVMTokenAmount 
        });

        router.ccipReceive(msgData);

        assertTrue(vault.optionCreated);
    }
}
