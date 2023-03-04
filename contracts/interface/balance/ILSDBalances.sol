// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILSDBalances {
    function getVirtualETHBalance() external view returns (uint256);

    function getTotalETHBalance() external view returns (uint256);

    function getTotalLSETHSupply() external view returns (uint256);
    function getTotalVELSDSupply() external view returns (uint256);
    // Rocket Pool Staking ETH Balance
    function getTotalETHInRP()
        external
        view
        returns (uint256);

    // Rocket Pool RETH Balance
    function getTotalRETHInRP() external view returns (uint256);

    // LIDO Staking ETH Balance
    function getTotalETHInLIDO() external view returns (uint256);

    // LIDO STETH Balance
    function getTotalSTETHBalance() external view returns (uint256);

    // SWISE Staking ETH Balance
    function getTotalETHInSWISE() external view returns (uint256);

    // SWISE SETH2 Balance
    function getTotalSETH2Balance() external view returns (uint256);

    // SWISE RETH2 Balance
    function getTotalRETH2Balance() external view returns (uint256);
}
