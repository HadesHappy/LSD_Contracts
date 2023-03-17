// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILSDLIDOVault {
    function depositEther() external payable;

    function withdrawEther(uint256 _ethAmount, address _address) external;

    function getStETHBalance() external view returns (uint256);

    function claimToken(uint256 _amount) external;

    function claimAll() external;

    function getSharesOfStETH(uint256 _ethAmount) external returns (uint256);
}
