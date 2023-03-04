// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @dev Interface of the FeesEscrow contract.
 */
interface IFeesEscrow {
    /**
    * @dev Event for tracking fees withdrawals to Pool contract.
    * @param amount - the number of fees.
    */
    event FeesTransferred(uint256 amount);

    /**
    * @dev Function is used to transfer accumulated rewards to Pool contract.
    * Can only be executed by the RewardEthToken contract.
    */
    function transferToPool() external returns (uint256);
}