// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILSDTokenVault {
    function unstakeLsd(address _address, uint256 amount) external;

    function unstakeLp(address _address, uint256 amount) external;
}
