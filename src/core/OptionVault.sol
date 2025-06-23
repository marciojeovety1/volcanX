// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract OptionVault {
    // ----- STRUCTS -----
    struct Option {
        address user;
        uint256 amount;
        uint256 strikePrice;
        uint256 expiry;
        bool executed;
        bool directionUp; // true: bet on increase, false: decrease
        uint256 thresholdPct; // e.g., 5% move => 500 (with 2 decimals)
    }

    // ----- STATE -----
    AggregatorV3Interface public priceFeed;
    mapping(uint256 => Option) public options;
    mapping(address => uint256[]) public userOptions;
    mapping(address => uint256) public lpBalances;
    address[] public lps;

    uint256 public totalLiquidity;
    uint256 public nextOptionId;

    // ----- EVENTS -----
    event OptionCreated(uint256 id, address indexed user, uint256 amount, bool directionUp, uint256 thresholdPct);
    event OptionSettled(uint256 id, bool success, uint256 payout);
    event LPDeposited(address indexed user, uint256 amount);
    event LPWithdrawn(address indexed user, uint256 amount);

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // ----- LP FUNCTIONS -----
    function depositLiquidity() external payable {
        require(msg.value > 0, "Deposit must be > 0");
        if (lpBalances[msg.sender] == 0) lps.push(msg.sender);
        lpBalances[msg.sender] += msg.value;
        totalLiquidity += msg.value;
        emit LPDeposited(msg.sender, msg.value);
    }

    function withdrawLiquidity(uint256 amount) external {
        require(lpBalances[msg.sender] >= amount, "Not enough balance");
        lpBalances[msg.sender] -= amount;
        totalLiquidity -= amount;
        payable(msg.sender).transfer(amount);
        emit LPWithdrawn(msg.sender, amount);
    }

    // ----- OPTION CREATION -----
    function createOption(bool directionUp, uint256 durationSeconds, uint256 thresholdPct) external payable {
        require(msg.value > 0, "Stake must be > 0");
        require(durationSeconds > 0, "Duration must be > 0");
        require(thresholdPct > 0, "Threshold must be > 0");

        (, int price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");

        uint256 id = nextOptionId++;
        options[id] = Option({
            user: msg.sender,
            amount: msg.value,
            strikePrice: uint256(price),
            expiry: block.timestamp + durationSeconds,
            executed: false,
            directionUp: directionUp,
            thresholdPct: thresholdPct
        });
        userOptions[msg.sender].push(id);
        emit OptionCreated(id, msg.sender, msg.value, directionUp, thresholdPct);
    }

    // ----- SETTLEMENT (to be called by Automation) -----
    function settleOption(uint256 id) public {
        Option storage opt = options[id];
        require(!opt.executed, "Already settled");
        require(block.timestamp >= opt.expiry, "Not expired yet");

        (, int price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");

        uint256 expiryPrice = uint256(price);
        uint256 pctMove = _percentageDiff(opt.strikePrice, expiryPrice);

        bool directionCorrect = (expiryPrice > opt.strikePrice) == opt.directionUp;
        bool movedEnough = pctMove >= opt.thresholdPct;

        if (directionCorrect && movedEnough) {
            uint256 payout = opt.amount * 2;
            require(totalLiquidity >= payout, "Insufficient liquidity");
            payable(opt.user).transfer(payout);
            totalLiquidity -= payout;
            lpBalances[address(this)] -= payout;
            emit OptionSettled(id, true, payout);
        } else {
            // LPs keep the stake
            totalLiquidity += opt.amount;
            lpBalances[address(this)] += opt.amount;
            emit OptionSettled(id, false, 0);
        }

        opt.executed = true;
    }

    // ----- HELPERS -----
    function _percentageDiff(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a > b) {
            return ((a - b) * 10000) / a; // 2 decimals (e.g. 5% = 500)
        } else {
            return ((b - a) * 10000) / a;
        }
    }

    function getLPRandomWinner() external view returns (address) {
        if (lps.length == 0) return address(0);
        return lps[block.timestamp % lps.length];
}

}