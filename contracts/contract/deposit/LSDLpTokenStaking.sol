// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../LSDBase.sol";
import "../../interface/token/ILSDTokenVELSD.sol";
import "../../interface/token/ILSDToken.sol";
import "../../interface/deposit/ILSDLpTokenStaking.sol";
import "../../interface/owner/ILSDOwner.sol";
import "../../interface/vault/ILSDTokenVault.sol";

import "../../interface/utils/uniswap/IUniswapV2Pair.sol";
import "../../interface/utils/uniswap/IUniswapV2Router02.sol";

contract LSDLpTokenStaking is LSDBase, ILSDLpTokenStaking {
    //events
    event AddLiquidity(
        address indexed userAddress,
        uint256 amount,
        uint256 addTime
    );

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
    uint256 private stakers = 0;

    mapping(address => User) private users;
    mapping(uint256 => History) private histories;
    uint private historyCount;

    uint256 private ONE_DAY_IN_SECS = 24 * 60 * 60;
    uint constant MAX_UINT = 2 ** 256 - 1;
    address uniLPAddress = 0xB92FE026Bd8F5539079c06F4e44f88515E7304C9;
    address uniswapRouterAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    // Construct
    constructor(ILSDStorage _lsdStorageAddress) LSDBase(_lsdStorageAddress) {
        version = 1;
        historyCount = 1;
        histories[0] = History(block.timestamp, 0, 20, false);
    }

    receive() external payable {}

    function stakeLP(uint256 _amount) public override {
        IUniswapV2Pair pair = IUniswapV2Pair(uniLPAddress);
        // check balance
        require(pair.balanceOf(msg.sender) >= _amount, "Invalid amount");
        // check allowance
        require(
            pair.allowance(msg.sender, address(this)) >= _amount,
            "Invalid allowance"
        );

        // transfer LSD Tokens
        pair.transferFrom(
            msg.sender,
            getContractAddress("lsdTokenVault"),
            _amount
        );

        // check if already staked user
        User storage user = users[msg.sender];
        if (user.lastTime == 0) {
            user.balance = _amount;
            user.claimAmount = 0;
            user.earnedAmount = 0;
            user.lastTime = block.timestamp;
            stakers++;
        } else {
            uint256 excessAmount = getClaimAmount(msg.sender);
            user.balance += _amount;
            user.claimAmount = excessAmount;
            user.lastTime = block.timestamp;
        }

        // submit event
        emit Staked(msg.sender, _amount, block.timestamp);
    }

    function addLiquidity(uint256 _lsdTokenAmount) public payable override {
        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        // check the balance
        require(lsdToken.balanceOf(msg.sender) >= _lsdTokenAmount);

        // check allowance
        require(
            lsdToken.allowance(msg.sender, address(this)) >= _lsdTokenAmount,
            "Invalid allowance"
        );

        // transfer tokens to this contract.
        lsdToken.transferFrom(msg.sender, address(this), _lsdTokenAmount);

        if (
            lsdToken.allowance(address(this), uniswapRouterAddress) <
            _lsdTokenAmount
        ) {
            lsdToken.approve(uniswapRouterAddress, MAX_UINT);
        }

        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(
            uniswapRouterAddress
        );

        (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        ) = uniswapRouter.addLiquidityETH{value: msg.value}(
                getContractAddress("lsdToken"),
                _lsdTokenAmount,
                0,
                0,
                getContractAddress("lsdTokenVault"),
                block.timestamp + 15
            );

        if (msg.value > amountETH) {
            payable(msg.sender).transfer(msg.value - amountETH);
        }

        if (_lsdTokenAmount > amountToken) {
            lsdToken.transfer(msg.sender, _lsdTokenAmount - amountToken);
        }

        // check if already staked user
        User storage user = users[msg.sender];
        if (user.lastTime == 0) {
            user.balance = liquidity;
            user.claimAmount = 0;
            user.earnedAmount = 0;
            user.lastTime = block.timestamp;
            stakers++;
        } else {
            uint256 excessAmount = getClaimAmount(msg.sender);
            user.balance += liquidity;
            user.claimAmount = excessAmount;
            user.lastTime = block.timestamp;
        }

        // submit event
        emit AddLiquidity(msg.sender, liquidity, block.timestamp);
    }

    // Remove LP
    function unstakeLP(uint256 _amount) public override {
        User storage user = users[msg.sender];
        require(user.balance >= _amount, "Invalid amount");

        uint256 excessAmount = getClaimAmount(msg.sender);
        user.balance -= _amount;
        user.claimAmount = excessAmount;
        user.lastTime = block.timestamp;

        ILSDTokenVault lsdTokenVault = ILSDTokenVault(
            getContractAddress("lsdTokenVault")
        );
        lsdTokenVault.unstakeLp(msg.sender, _amount);
    }

    function getIsBonusPeriod() public view override returns (uint256) {
        History memory history = histories[historyCount - 1];
        if (block.timestamp < history.startTime) {
            History memory bonusHistory = histories[historyCount - 2];
            return bonusHistory.startTime;
        } else return 0;
    }

    // Get Claim Amount By LP Staking
    function getClaimAmount(
        address _address
    ) public view override returns (uint256) {
        User memory user = users[_address];

        if (block.timestamp >= user.lastTime + ONE_DAY_IN_SECS) {
            IUniswapV2Pair pair = IUniswapV2Pair(uniLPAddress);
            (
                uint112 _reserve0,
                uint112 _reserve1,
                uint32 _blockTimestampLast
            ) = pair.getReserves();
            uint256 totalSupply = pair.totalSupply();

            uint256 balance = (user.balance * _reserve0 * 2) / totalSupply;

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
                        (user.lastTime <= histories[i - 1].endTime)) ||
                    ((user.lastTime > histories[i - 1].startTime) &&
                        (histories[i - 1].endTime == 0))
                ) break;
                i--;
                j++;
            }
            return
                user.claimAmount +
                (balance * sum) /
                (365 * 100 * ONE_DAY_IN_SECS);
        } else {
            return user.claimAmount;
        }
    }

    function getTotalLPTokenBalance() public view override returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(uniLPAddress);
        return pair.balanceOf(getContractAddress("lsdTokenVault"));
    }

    // Claim bonus by LP
    function claim() public override {
        uint256 excessAmount = getClaimAmount(msg.sender);
        require(excessAmount > 0, "Invalid call");

        ILSDTokenVault lsdTokenVault = ILSDTokenVault(
            getContractAddress("lsdTokenVault")
        );
        lsdTokenVault.claimByLp(msg.sender, excessAmount);

        User storage user = users[msg.sender];
        user.lastTime = block.timestamp;
        user.claimAmount = 0;
        user.earnedAmount += excessAmount;
        totalRewards += excessAmount;
    }

    // Get total rewards by LP
    function getTotalRewards() public view override returns (uint256) {
        return totalRewards;
    }

    // Get Staked LP
    function getStakedLP(
        address _address
    ) public view override returns (uint256) {
        User memory user = users[_address];
        return user.balance;
    }

    function getEarnedByLP(
        address _address
    ) public view override returns (uint256) {
        User memory user = users[_address];
        return user.earnedAmount;
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

    function getStakers() public view override returns(uint256){
        return stakers;
    }

    /**@dev 
        DAO contract functions
    */
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
