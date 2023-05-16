// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILSDRewardsVault {
    function claimByLsd(address _address, uint256 amount) external;

    function claimByLp(address _address, uint256 amount) external;
}
