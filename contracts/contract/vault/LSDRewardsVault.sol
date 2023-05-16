// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../LSDBase.sol";
import "../../interface/vault/ILSDRewardsVault.sol";

import "../../interface/token/ILSDToken.sol";
import "../../interface/utils/uniswap/IUniswapV2Pair.sol";

contract LSDRewardsVault is LSDBase, ILSDRewardsVault {
    event LSDTokenClaimed(
        address indexed userAddress,
        uint256 amount,
        uint256 claimTime
    );

    // Construct
    constructor(ILSDStorage _lsdStorageAddress) LSDBase(_lsdStorageAddress) {
        version = 1;
    }

    function claimByLsd(
        address _address,
        uint256 amount
    ) public override onlyLSDContract("lsdStakingPool", msg.sender) {
        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        require(lsdToken.balanceOf(address(this)) >= amount, "Invalid amount");

        lsdToken.transfer(_address, amount);

        // submit event
        emit LSDTokenClaimed(_address, amount, block.timestamp);
    }

    function claimByLp(
        address _address,
        uint256 amount
    ) public override onlyLSDContract("lsdLpTokenStaking", msg.sender) {
        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        require(lsdToken.balanceOf(address(this)) >= amount, "Invalid amount");

        lsdToken.transfer(_address, amount);

        // submit event
        emit LSDTokenClaimed(_address, amount, block.timestamp);
    }
}
