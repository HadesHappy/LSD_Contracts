// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILSDTokenStaking {
    function stakeLSD(uint256 _lsdTokenAmount) external;

    function unstakeLSD(uint256 _veLSDAmount) external;

    function claim() external;

    function getClaimAmount(address _address) external view returns (uint256);

    function getEarnedByLSD(address _address) external view returns (uint256);

    function getStakedLSD(address _address) external view returns (uint256);

    function getTotalRewards() external view returns (uint256);

    function getBonusApr() external view returns (uint256);

    function getBonusPeriod() external view returns (uint256);

    function getMainApr() external view returns (uint256);

    function getIsBonusPeriod() external view returns (uint256);

    function setBonusApr(uint256 _bonusApr) external;

    function setBonusPeriod(uint256 _bonusPerios) external;

    function setMainApr(uint256 _mainApr) external;

    function setBonusCampaign() external;
}
