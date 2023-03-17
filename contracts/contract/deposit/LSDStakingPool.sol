// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../LSDBase.sol";
import "../../interface/token/ILSDTokenVELSD.sol";
import "../../interface/token/ILSDToken.sol";
import "../../interface/deposit/ILSDStakingPool.sol";
import "../../interface/owner/ILSDOwner.sol";

// The main entry to stake LSD token.

contract LSDStakingPool is LSDBase, ILSDStakingPool {
    // events
    event Claimed(
        address indexed userAddress,
        uint256 amount,
        uint256 claimTime
    );

    struct User {
        uint256 balance;
        uint256 claimAmount;
        uint256 lastTime;
    }

    uint256 private totalRewards;
    mapping(address => User) public users;
    uint256 private ONE_DAY_IN_SECS = 24 * 60 * 60;

    // Construct
    constructor(ILSDStorage _lsdStorageAddress) LSDBase(_lsdStorageAddress) {
        version = 1;
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
        lsdToken.transferFrom(msg.sender, address(this), _lsdTokenAmount);

        // check if already staked user
        User storage user = users[msg.sender];
        uint256 excessAmount = getClaimAmount(msg.sender);
        user.balance += _lsdTokenAmount;
        user.claimAmount = excessAmount;
        user.lastTime = block.timestamp;

        // mint LSDTokenVELSD
        ILSDTokenVELSD lsdTokenVELSD = ILSDTokenVELSD(
            getContractAddress("lsdTokenVELSD")
        );
        lsdTokenVELSD.mint(msg.sender, _lsdTokenAmount);
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
    
        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        lsdToken.transfer(msg.sender, _veLSDAmount);
        lsdTokenVELSD.burn(msg.sender, _veLSDAmount);
    }

    // Get Claim Amount
    function getClaimAmount(
        address _address
    ) public view override returns (uint256) {
        User memory user = users[_address];
        if (block.timestamp >= user.lastTime + ONE_DAY_IN_SECS) {
            uint256 dayPassed = (block.timestamp - user.lastTime) /
                ONE_DAY_IN_SECS;
            ILSDOwner lsdOwner = ILSDOwner(getContractAddress("lsdOwner"));
            uint256 apr = lsdOwner.getStakeApr();
            return
                user.claimAmount +
                (user.balance * dayPassed * apr) /
                (365 * 100);
        } else {
            return user.claimAmount;
        }
    }

    // Claim bonus
    function claim() public override {
        uint256 excessAmount = getClaimAmount(msg.sender);
        require(excessAmount > 0, "Invalid call");
        require(excessAmount <= getTotalLSD());

        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        lsdToken.transfer(msg.sender, excessAmount);

        User storage user = users[msg.sender];
        user.lastTime = block.timestamp;
        user.claimAmount = 0;
        totalRewards += excessAmount;
        // emit claim event
        emit Claimed(msg.sender, excessAmount, block.timestamp);
    }

    // get total staking LSD
    function getTotalLSD() public view override returns (uint256) {
        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        return lsdToken.balanceOf(address(this));
    }

    // get total rewards of this platform
    function getTotalRewards() public view override returns (uint256) {
        return totalRewards;
    }

    // remove LSD
    function removeLSD(uint256 amount) public onlyLSDContract("lsdDaoContract", msg.sender){
        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        lsdToken.transfer(msg.sender, amount);
    }
}
