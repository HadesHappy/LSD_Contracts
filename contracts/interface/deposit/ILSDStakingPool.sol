// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILSDStakingPool {
    function stakeLSD(uint256 _amount) external;

    function unstakeLSD(uint256 _amount) external;

    function claim() external;

    function getClaimAmount(address _address) external view returns (uint256);

    function getTotalRewards() external view returns (uint256);

    function getTotalLSD() external view returns (uint256);
}
