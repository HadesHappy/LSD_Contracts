// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IRP {
    function deposit() external payable;

    function withdraw(uint256 _amount) external;

    function getContractBalance() external view returns (uint256);
}
