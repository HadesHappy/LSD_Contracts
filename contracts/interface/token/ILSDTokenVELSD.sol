// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILSDTokenVELSD is IERC20 {
    function mint(address _address, uint256 _amount) external;

    function burn(address _address, uint256 _amount) external;
}
