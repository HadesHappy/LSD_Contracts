// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Test {
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
    uint256 private bonusPeriod = 182;
    uint256 private bonusApr = 50;
    uint256 private mainApr = 20;

    mapping(address => User) public users;
    mapping(uint256 => History) public histories;
    uint public historyCount;

    uint256 private ONE_DAY_IN_SECS = 24 * 60 * 60;

    // Construct
    constructor() {
        historyCount = 1;
        histories[0] = History(block.timestamp, 0, 20, false);
    }

    function getIsBonusPeriod() public view returns (uint256) {
        History memory history = histories[historyCount - 1];
        if (block.timestamp < history.startTime) {
            History memory bonusHistory = histories[historyCount - 2];
            return bonusHistory.startTime;
        } else return 0;
    }

    function stake(uint256 _amount) public {
        users[msg.sender] = User(_amount, 0, block.timestamp, 0);
    }

    // Get Claim Amount By LSD Staking
    function getClaimAmount(address _address) public view returns (uint256) {
        User memory user = users[_address];
        if (block.timestamp >= user.lastTime + ONE_DAY_IN_SECS) {
            uint256 i;
            uint256 j = 0;
            uint256 sum = 0;
            if (getIsBonusPeriod() == 0) i = historyCount;
            else i = historyCount - 1;
            while (i >= 1) {
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
                if (
                    ((user.lastTime > histories[i - 1].startTime) &&
                    (user.lastTime <= histories[i - 1].endTime)) || ((user.lastTime > histories[i - 1].startTime) &&
                    (histories[i - 1].endTime == 0))
                ) break;
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
    function claim() public {
        uint256 excessAmount = getClaimAmount(msg.sender);
        require(excessAmount > 0, "Invalid call");

        User storage user = users[msg.sender];
        user.lastTime = block.timestamp;
        user.claimAmount = 0;
        user.earnedAmount += excessAmount;
        totalRewards += excessAmount;
    }

    function getEarnedByLSD(address _address) public view returns (uint256) {
        User memory user = users[_address];
        return user.earnedAmount;
    }

    function getStakedLSD(address _address) public view returns (uint256) {
        User memory user = users[_address];
        return user.balance;
    }

    // get total rewards of LSD Staking
    function getTotalRewards() public view returns (uint256) {
        return totalRewards;
    }

    function getBonusPeriod() public view returns (uint256) {
        return bonusPeriod;
    }

    function getBonusApr() public view returns (uint256) {
        return bonusApr;
    }

    function getMainApr() public view returns (uint256) {
        return mainApr;
    }

    /**
        @dev Dao functions
    */
    // set bonus period
    function setBonusPeriod(uint256 _days) public {
        bonusPeriod = _days;
    }

    // set bonus apr
    function setBonusApr(uint256 _bonusApr) public {
        if (getIsBonusPeriod() == 0) {
            bonusApr = _bonusApr;
        } else {
            bonusApr = _bonusApr;
            History storage history = histories[historyCount - 2];
            history.apr = bonusApr;
        }
    }

    // set main apr
    function setMainApr(uint256 _mainApr) public {
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
    function setBonusCampaign() public {
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

    function getHistories(uint256 _index) public view returns (History memory) {
        return histories[_index];
    }
}
