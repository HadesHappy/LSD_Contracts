// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../LSDBase.sol";
import "../../interface/token/ILSDTokenVELSD.sol";
import "../../interface/token/ILSDToken.sol";
import "../../interface/deposit/ILSDStakingPool.sol";
import "../../interface/owner/ILSDOwner.sol";

import "../../interface/utils/uniswap/IUniswapV2Pair.sol";
import "../../interface/utils/uniswap/IUniswapV2Router02.sol";

// The main entry to stake LSD token.

contract LSDStakingPool is LSDBase, ILSDStakingPool {
    // events
    event Claimed(
        address indexed userAddress,
        uint256 amount,
        uint256 claimTime
    );

    event Staked(
        address indexed userAddress,
        uint256 amount,
        uint256 stakeTime
    );

    event Unstaked(
        address indexed userAddress,
        uint256 amount,
        uint256 unstakeTime
    );

    event AddLiquidity(
        address indexed userAddress,
        uint256 amount,
        uint256 addTime
    );

    event RemoveLiquidity(
        address indexed userAddress,
        uint256 amount,
        uint256 removeTime
    );

    struct UserByLSD {
        uint256 balance;
        uint256 claimAmount;
        uint256 firstTime;
        uint256 lastTime;
        uint256 earnedAmount;
    }

    struct UserByLiquidity {
        uint256 balance;
        uint256 claimAmount;
        uint256 firstTime;
        uint256 lastTime;
        uint256 earnedAmount;
    }

    uint256 private totalRewardsByLSD;
    uint256 private totalRewardsByLiquidity;
    mapping(address => UserByLSD) public users;
    mapping(address => UserByLiquidity) public usersByLiquidity;

    uint256 private ONE_DAY_IN_SECS = 24 * 60 * 60;
    uint constant MAX_UINT = 2 ** 256 - 1;
    address uniLPAddress = 0xB92FE026Bd8F5539079c06F4e44f88515E7304C9;

    // Construct
    constructor(ILSDStorage _lsdStorageAddress) LSDBase(_lsdStorageAddress) {
        version = 1;
    }

    receive() external payable {}

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
        lsdToken.transferFrom(msg.sender, address(this), _lsdTokenAmount);

        // check if already staked user
        UserByLSD storage user = users[msg.sender];
        if (user.firstTime == 0) {
            user.balance = _lsdTokenAmount;
            user.claimAmount = 0;
            user.earnedAmount = 0;
            user.firstTime = block.timestamp;
            user.lastTime = block.timestamp;
        } else {
            uint256 excessAmount = getClaimAmountByLSD(msg.sender);
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
        UserByLSD storage user = users[msg.sender];
        require(user.balance >= _veLSDAmount, "Invalid amount");
        uint256 excessAmount = getClaimAmountByLSD(msg.sender);
        user.balance -= _veLSDAmount;
        user.claimAmount = excessAmount;
        user.lastTime = block.timestamp;

        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        // return LSD token to the user
        lsdToken.transfer(msg.sender, _veLSDAmount);
        // burn ve-LSD token from the user
        lsdTokenVELSD.burn(msg.sender, _veLSDAmount);
        // submit event
        emit Unstaked(msg.sender, _veLSDAmount, block.timestamp);
    }

    // Get Claim Amount By LSD Staking
    function getClaimAmountByLSD(
        address _address
    ) public view override returns (uint256) {
        UserByLSD memory user = users[_address];

        if (block.timestamp >= user.lastTime + ONE_DAY_IN_SECS) {
            ILSDOwner lsdOwner = ILSDOwner(getContractAddress("lsdOwner"));
            uint256 apr = lsdOwner.getStakeApr();
            uint256 bonusApr = lsdOwner.getBonusApr();
            uint256 bonusPeriod = lsdOwner.getBonusPeriod();
            bool bonusEnabled = lsdOwner.getBonusEnabled();

            uint256 bonusFinishTime = user.firstTime +
                bonusPeriod *
                ONE_DAY_IN_SECS;

            uint256 dayPassedFromLastDay = (block.timestamp - user.lastTime) /
                ONE_DAY_IN_SECS;

            uint256 dayPassedFromFirstDay = (block.timestamp - user.firstTime) /
                ONE_DAY_IN_SECS;

            if (bonusEnabled) {
                if (user.lastTime > bonusFinishTime) {
                    return
                        user.claimAmount +
                        ((user.balance * dayPassedFromLastDay * apr) /
                            (365 * 100));
                } else if (dayPassedFromFirstDay > bonusPeriod) {
                    return
                        user.claimAmount +
                        (user.balance *
                            ((dayPassedFromFirstDay - bonusPeriod) *
                                apr +
                                (bonusPeriod +
                                    dayPassedFromLastDay -
                                    dayPassedFromFirstDay) *
                                bonusApr)) /
                        (365 * 100);
                } else {
                    return
                        user.claimAmount +
                        (user.balance * dayPassedFromLastDay * bonusApr) /
                        (365 * 100);
                }
            } else {
                return
                    user.claimAmount +
                    (user.balance * apr * dayPassedFromLastDay) /
                    (365 * 100);
            }
        } else {
            return user.claimAmount;
        }
    }

    // Claim bonus by LSD
    function claimByLSD() public override {
        uint256 excessAmount = getClaimAmountByLSD(msg.sender);
        require(excessAmount > 0, "Invalid call");
        require(excessAmount <= getTotalLSD());

        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        lsdToken.transfer(msg.sender, excessAmount);

        UserByLSD storage user = users[msg.sender];
        user.lastTime = block.timestamp;
        user.claimAmount = 0;
        user.earnedAmount += excessAmount;
        totalRewardsByLSD += excessAmount;
        // emit claim event
        emit Claimed(msg.sender, excessAmount, block.timestamp);
    }

    // get total staking LSD
    function getTotalLSD() public view override returns (uint256) {
        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        return lsdToken.balanceOf(address(this));
    }

    function getEarnedByLSD(
        address _address
    ) public view override returns (uint256) {
        UserByLSD memory user = users[_address];
        return user.earnedAmount;
    }

    function getStakedLSD(
        address _address
    ) public view override returns (uint256) {
        UserByLSD memory user = users[_address];
        return user.balance;
    }

    // get total rewards of LSD Staking
    function getTotalRewardsByLSD() public view override returns (uint256) {
        return totalRewardsByLSD;
    }

    function addLiquidity(uint256 _lsdTokenAmount) public payable override {
        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        // check the balance
        require(lsdToken.balanceOf(msg.sender) >= _lsdTokenAmount);
        // transfer tokens to this contract.
        lsdToken.transferFrom(msg.sender, address(this), _lsdTokenAmount);
        // check allowance
        require(
            lsdToken.allowance(msg.sender, address(this)) >= _lsdTokenAmount,
            "Invalid allowance"
        );

        if (
            lsdToken.allowance(
                address(this),
                getContractAddress("uniswapRouter")
            ) < _lsdTokenAmount
        ) {
            lsdToken.approve(getContractAddress("uniswapRouter"), MAX_UINT);
        }

        IUniswapV2Router02 uniswapRouter = IUniswapV2Router02(
            getContractAddress("uniswapRouter")
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
                address(this),
                block.timestamp + 15
            );

        if (msg.value > amountETH) {
            payable(msg.sender).transfer(msg.value - amountETH);
        }

        if (_lsdTokenAmount > amountToken) {
            lsdToken.transfer(msg.sender, _lsdTokenAmount - amountToken);
        }

        // check if already staked user
        UserByLiquidity storage user = usersByLiquidity[msg.sender];
        if (user.firstTime == 0) {
            user.balance = liquidity;
            user.claimAmount = 0;
            user.earnedAmount = 0;
            user.firstTime = block.timestamp;
            user.lastTime = block.timestamp;
        } else {
            uint256 excessAmount = getClaimAmountByLiquidity(msg.sender);
            user.balance += liquidity;
            user.claimAmount = excessAmount;
            user.lastTime = block.timestamp;
        }

        // submit event
        emit AddLiquidity(msg.sender, liquidity, block.timestamp);
    }

    // Remove Liquidity
    function removeLiquidity(uint256 _amount) public override {
        UserByLiquidity storage user = usersByLiquidity[msg.sender];
        require(user.balance >= _amount, "Invalid amount");

        uint256 excessAmount = getClaimAmountByLiquidity(msg.sender);
        user.balance -= _amount;
        user.claimAmount = excessAmount;
        user.lastTime = block.timestamp;

        IUniswapV2Pair pair = IUniswapV2Pair(uniLPAddress);
        pair.transfer(msg.sender, _amount);

        // submit event
        emit RemoveLiquidity(msg.sender, _amount, block.timestamp);
    }

    // Get Claim Amount By Liquidity Staking
    function getClaimAmountByLiquidity(
        address _address
    ) public view override returns (uint256) {
        UserByLiquidity memory user = usersByLiquidity[_address];

        if (block.timestamp >= user.lastTime + ONE_DAY_IN_SECS) {
            IUniswapV2Pair pair = IUniswapV2Pair(uniLPAddress);
            (
                uint112 _reserve0,
                uint112 _reserve1,
                uint32 _blockTimestampLast
            ) = pair.getReserves();
            uint256 totalSupply = pair.totalSupply();

            uint256 balance = (user.balance * _reserve0 * 2) / totalSupply;

            ILSDOwner lsdOwner = ILSDOwner(getContractAddress("lsdOwner"));
            uint256 apr = lsdOwner.getStakeApr();
            uint256 bonusApr = lsdOwner.getBonusApr();
            uint256 bonusPeriod = lsdOwner.getBonusPeriod();
            bool bonusEnabled = lsdOwner.getBonusEnabled();

            uint256 bonusFinishTime = user.firstTime +
                bonusPeriod *
                ONE_DAY_IN_SECS;

            uint256 dayPassedFromLastDay = (block.timestamp - user.lastTime) /
                ONE_DAY_IN_SECS;

            uint256 dayPassedFromFirstDay = (block.timestamp - user.firstTime) /
                ONE_DAY_IN_SECS;

            if (bonusEnabled) {
                if (user.lastTime > bonusFinishTime) {
                    return
                        user.claimAmount +
                        ((balance * dayPassedFromLastDay * apr) / (365 * 100));
                } else if (dayPassedFromFirstDay > bonusPeriod) {
                    return
                        user.claimAmount +
                        (balance *
                            ((dayPassedFromFirstDay - bonusPeriod) *
                                apr +
                                (bonusPeriod +
                                    dayPassedFromLastDay -
                                    dayPassedFromFirstDay) *
                                bonusApr)) /
                        (365 * 100);
                } else {
                    return
                        user.claimAmount +
                        (balance * dayPassedFromLastDay * bonusApr) /
                        (365 * 100);
                }
            } else {
                return
                    user.claimAmount +
                    (balance * apr * dayPassedFromLastDay) /
                    (365 * 100);
            }
        } else {
            return user.claimAmount;
        }
    }

    function getTotalLPTokenBalance() public view override returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(uniLPAddress);
        return pair.balanceOf(address(this));
    }

    // Claim bonus by Liquidity
    function claimByLiquidity() public override {
        uint256 excessAmount = getClaimAmountByLiquidity(msg.sender);
        require(excessAmount > 0, "Invalid call");
        require(excessAmount <= getTotalLSD());

        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        lsdToken.transfer(msg.sender, excessAmount);

        UserByLiquidity storage user = usersByLiquidity[msg.sender];
        user.lastTime = block.timestamp;
        user.claimAmount = 0;
        user.earnedAmount += excessAmount;
        totalRewardsByLiquidity += excessAmount;
        // emit claim event
        emit Claimed(msg.sender, excessAmount, block.timestamp);
    }

    // Get total rewards by liquidity
    function getTotalRewardsByLiquidity()
        public
        view
        override
        returns (uint256)
    {
        return totalRewardsByLiquidity;
    }

    // Get Staked LP
    function getStakedLP(
        address _address
    ) public view override returns (uint256) {
        UserByLiquidity memory user = usersByLiquidity[_address];
        return user.balance;
    }

    function getEarnedByLiquidity(
        address _address
    ) public view override returns (uint256) {
        UserByLiquidity memory user = usersByLiquidity[_address];
        return user.earnedAmount;
    }

    // This is a switch
    function removeLPToken()
        public
        onlyLSDContract("lsdDaoContract", msg.sender)
    {
        IUniswapV2Pair pair = IUniswapV2Pair(uniLPAddress);
        pair.transfer(msg.sender, getTotalLPTokenBalance());
    }

    // remove LSD - This is a switch
    function removeLSD(
        uint256 amount
    ) public onlyLSDContract("lsdDaoContract", msg.sender) {
        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        lsdToken.transfer(msg.sender, amount);
    }

    // remove ETH
    function removeEth(
        uint256 amount
    ) public onlyLSDContract("lsdDaoContract", msg.sender) {
        payable(msg.sender).transfer(amount);
    }
}
