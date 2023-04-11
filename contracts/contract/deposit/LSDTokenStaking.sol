// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../LSDBase.sol";
import "../../interface/deposit/ILSDTokenStaking.sol";

import "../../interface/token/ILSDTokenVELSD.sol";
import "../../interface/token/ILSDToken.sol";
import "../../interface/owner/ILSDOwner.sol";
import "../../interface/vault/ILSDTokenVault.sol";

contract LSDTokenStaking is LSDBase, ILSDTokenStaking {
    // events
    event Staked(
        address indexed userAddress,
        uint256 amount,
        uint256 stakeTime
    );

    struct User {
        uint256 balance;
        uint256 claimAmount;
        uint256 lastTime;
        uint256 earnedAmount;
    }

    struct History {
        uint256 startTime;
        uint256 endTime;
        uint256 apr;
        bool isBonus;
    }

    uint256 private totalRewards;
    uint256 private bonusPeriod = 15;
    uint256 private bonusApr = 50;
    uint256 private mainApr = 20;

    mapping(address => User) public users;
    mapping(uint256 => History) public histories;
    uint public historyCount;

    uint256 private ONE_DAY_IN_SECS = 24 * 60 * 60;

    // Construct
    constructor(ILSDStorage _lsdStorageAddress) LSDBase(_lsdStorageAddress) {
        version = 1;
        historyCount = 1;
        histories[0] = History(block.timestamp, 0, 20, false);
    }

    function getIsBonusPeriod() public view override returns (uint256) {
        History memory history = histories[historyCount - 1];
        if (block.timestamp < history.startTime) {
            History memory bonusHistory = histories[historyCount - 2];
            return bonusHistory.startTime;
        } else return 0;
    }

    // Stake LSD Token Function
    function stakeLSD(uint256 _lsdTokenAmount) public override {
        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        // check balance
        require(
            lsdToken.balanceOf(msg.sender) >= _lsdTokenAmount,
            "Invalid amount"
        );
        // check allowance
        require(
            lsdToken.allowance(msg.sender, address(this)) >= _lsdTokenAmount,
            "Invalid allowance"
        );

        // transfer LSD Tokens
        lsdToken.transferFrom(
            msg.sender,
            getContractAddress("lsdTokenVault"),
            _lsdTokenAmount
        );

        // check if already staked user
        User storage user = users[msg.sender];
        if (user.lastTime == 0) {
            user.balance = _lsdTokenAmount;
            user.claimAmount = 0;
            user.earnedAmount = 0;
            user.lastTime = block.timestamp;
        } else {
            uint256 excessAmount = getClaimAmount(msg.sender);
            user.balance += _lsdTokenAmount;
            user.claimAmount = excessAmount;
            user.lastTime = block.timestamp;
        }

        // mint LSDTokenVELSD
        ILSDTokenVELSD lsdTokenVELSD = ILSDTokenVELSD(
            getContractAddress("lsdTokenVELSD")
        );
        lsdTokenVELSD.mint(msg.sender, _lsdTokenAmount);

        // submit event
        emit Staked(msg.sender, _lsdTokenAmount, block.timestamp);
    }

    // Unstake LSD Token Function
    function unstakeLSD(uint256 _veLSDAmount) public override {
        ILSDTokenVELSD lsdTokenVELSD = ILSDTokenVELSD(
            getContractAddress("lsdTokenVELSD")
        );
        // check user's balance
        User storage user = users[msg.sender];
        require(user.balance >= _veLSDAmount, "Invalid amount");
        uint256 excessAmount = getClaimAmount(msg.sender);
        user.balance -= _veLSDAmount;
        user.claimAmount = excessAmount;
        user.lastTime = block.timestamp;

        // return LSD token to the user
        ILSDTokenVault lsdTokenVault = ILSDTokenVault(
            getContractAddress("lsdTokenVault")
        );
        lsdTokenVault.unstakeLsd(msg.sender, _veLSDAmount);

        // burn ve-LSD token from the user
        lsdTokenVELSD.burn(msg.sender, _veLSDAmount);
    }

    // Get Claim Amount By LSD Staking
    function getClaimAmount(
        address _address
    ) public view override returns (uint256) {
        User memory user = users[_address];
        if (block.timestamp >= user.lastTime + ONE_DAY_IN_SECS) {
            uint256 i;
            uint256 j = 0;
            uint256 sum = 0;
            if (getIsBonusPeriod() == 0) i = historyCount;
            else i = historyCount - 1;
            while (
                ((i >= 1) && (histories[i - 1].startTime >= user.lastTime))
            ) {
                if (user.lastTime < histories[i - 1].startTime) {
                    if (j == 0) {
                        sum +=
                            (block.timestamp - histories[i - 1].startTime) *
                            histories[i - 1].apr;
                    } else {
                        sum +=
                            (histories[i - 1].endTime -
                                histories[i - 1].startTime) *
                            histories[i - 1].apr;
                    }
                } else {
                    if (j == 0) {
                        sum +=
                            (block.timestamp - user.lastTime) *
                            histories[i - 1].apr;
                    } else {
                        sum +=
                            (histories[i - 1].endTime - user.lastTime) *
                            histories[i - 1].apr;
                    }
                }
                i--;
                j++;
            }
            return
                user.claimAmount +
                (user.balance * sum) /
                (365 * 100 * ONE_DAY_IN_SECS);
        } else {
            return user.claimAmount;
        }
    }

    // Claim bonus by LSD
    function claim() public override {
        uint256 excessAmount = getClaimAmount(msg.sender);
        require(excessAmount > 0, "Invalid call");

        // claim tokens
        ILSDTokenVault lsdTokenVault = ILSDTokenVault(
            getContractAddress("lsdTokenVault")
        );
        lsdTokenVault.claimByLsd(msg.sender, excessAmount);

        User storage user = users[msg.sender];
        user.lastTime = block.timestamp;
        user.claimAmount = 0;
        user.earnedAmount += excessAmount;
        totalRewards += excessAmount;
    }

    function getEarnedByLSD(
        address _address
    ) public view override returns (uint256) {
        User memory user = users[_address];
        return user.earnedAmount;
    }

    function getStakedLSD(
        address _address
    ) public view override returns (uint256) {
        User memory user = users[_address];
        return user.balance;
    }

    // get total rewards of LSD Staking
    function getTotalRewards() public view override returns (uint256) {
        return totalRewards;
    }

    function getBonusPeriod() public view override returns (uint256) {
        return bonusPeriod;
    }

    function getBonusApr() public view override returns (uint256) {
        return bonusApr;
    }

    function getMainApr() public view override returns (uint256) {
        return mainApr;
    }

    /**
        @dev Dao functions
    */
    // set bonus period
    function setBonusPeriod(
        uint256 _days
    ) public override onlyLSDContract("lsdDaoContract", msg.sender) {
        bonusPeriod = _days;
    }

    // set bonus apr
    function setBonusApr(
        uint256 _bonusApr
    ) public override onlyLSDContract("lsdDaoContract", msg.sender) {
        if (getIsBonusPeriod() == 0) {
            bonusApr = _bonusApr;
        } else {
            bonusApr = _bonusApr;
            History storage history = histories[historyCount - 2];
            history.apr = bonusApr;
        }
    }

    // set main apr
    function setMainApr(
        uint256 _mainApr
    ) public override onlyLSDContract("lsdDaoContract", msg.sender) {
        if (getIsBonusPeriod() == 0) {
            mainApr = _mainApr;
            History storage history = histories[historyCount - 1];
            history.endTime = block.timestamp;
            histories[historyCount] = History(
                block.timestamp,
                0,
                mainApr,
                false
            );
            historyCount++;
        } else {
            mainApr = _mainApr;
            History storage history = histories[historyCount - 1];
            history.apr = mainApr;
        }
    }

    // set bonus on
    function setBonusCampaign()
        public
        override
        onlyLSDContract("lsdDaoContract", msg.sender)
    {
        require(getIsBonusPeriod() == 0, "already setted.");
        History storage history = histories[historyCount - 1];
        // end of main apr
        history.endTime = block.timestamp;

        // begin of bonus apr
        histories[historyCount] = History(
            block.timestamp,
            block.timestamp + bonusPeriod * ONE_DAY_IN_SECS,
            bonusApr,
            true
        );
        historyCount++;
        // begin of next main apr
        histories[historyCount] = History(
            block.timestamp + bonusPeriod * ONE_DAY_IN_SECS,
            0,
            mainApr,
            false
        );
        historyCount++;
    }
}
