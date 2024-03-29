// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../LSDBase.sol";
import "../../interface/vault/ILSDTokenVault.sol";

import "../../interface/token/ILSDToken.sol";
import "../../interface/utils/uniswap/IUniswapV2Pair.sol";

contract LSDTokenVault is LSDBase, ILSDTokenVault {
    // Events
    event LSDTokenUnstaked(
        address indexed userAddress,
        uint256 amount,
        uint256 unstakeTime
    );

    event LPTokenUnstaked(
        address indexed userAddress,
        uint256 amount,
        uint256 unstakeTime
    );

    address uniLPAddress = 0xB92FE026Bd8F5539079c06F4e44f88515E7304C9;

    // Construct
    constructor(ILSDStorage _lsdStorageAddress) LSDBase(_lsdStorageAddress) {
        version = 1;
    }

    function unstakeLsd(
        address _address,
        uint256 amount
    ) public override onlyLSDContract("lsdStakingPool", msg.sender) {
        ILSDToken lsdToken = ILSDToken(getContractAddress("lsdToken"));
        require(lsdToken.balanceOf(address(this)) >= amount, "Invalid amount");

        lsdToken.transfer(_address, amount);

        // submit event
        emit LSDTokenUnstaked(_address, amount, block.timestamp);
    }

    function unstakeLp(
        address _address,
        uint256 amount
    ) public override onlyLSDContract("lsdLpTokenStaking", msg.sender) {
        IUniswapV2Pair pairToken = IUniswapV2Pair(uniLPAddress);
        require(pairToken.balanceOf(address(this)) >= amount, "Invalid amount");

        pairToken.transfer(_address, amount);

        // submit event
        emit LPTokenUnstaked(_address, amount, block.timestamp);
    }

}
