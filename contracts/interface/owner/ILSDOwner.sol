// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILSDOwner {
    function getApy() external view returns (uint256);

    function getStakeApr() external view returns (uint256);

    function getMultiplier() external view returns (uint256);

    function getLIDOApy() external view returns (uint256);

    function getRPApy() external view returns (uint256);

    function getSWISEApy() external view returns (uint256);

    function getProtocolFee() external view returns (uint256);

    function getMinimumDepositAmount() external view returns (uint256);

    function setApy(uint256 _apy) external;

    function setStakeApr(uint256 _stakeApr) external;

    function setMultiplier(uint256 _multiplier) external;

    function setRPApy(uint256 _rpApy) external;

    function setLIDOApy(uint256 _lidoApy) external;

    function setSWISEApy(uint256 _swiseApy) external;

    function setProtocolFee(uint256 _protocalFee) external;

    function setMinimumDepositAmount(uint256 _minimumDepositAmount) external;

    function upgrade(string memory _type, string memory _name, string memory _contractAbi, address _contractAddress) external;
}
