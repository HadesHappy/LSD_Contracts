// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILSDDepositPool {
    function deposit() external payable;

    function getCurrentProvider() external pure returns (uint256);

    function withdrawEther(uint256 _amount, address _address) external;
}
