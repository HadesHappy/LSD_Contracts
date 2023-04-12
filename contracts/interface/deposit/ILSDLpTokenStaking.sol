// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILSDLpTokenStaking {
    function stakeLP(uint256 _amount) external;

    function addLiquidity(uint256 _lsdTokenAmount) external payable;

    function unstakeLP(uint256 _amount) external;

    function getTotalLPTokenBalance() external view returns (uint256);

    function getClaimAmount(address _address) external view returns (uint256);

    function claim() external;

    function getTotalRewards() external view returns (uint256);

    function getStakedLP(address _address) external view returns (uint256);

    function getEarnedByLP(address _address) external view returns (uint256);

    function getBonusApr() external view returns (uint256);

    function getBonusPeriod() external view returns (uint256);

    function getMainApr() external view returns (uint256);

    function getIsBonusPeriod() external view returns (uint256);

    function getStakers() external view returns (uint256);

    function setBonusApr(uint256 _bonusApr) external;

    function setBonusPeriod(uint256 _bonusPerios) external;

    function setMainApr(uint256 _mainApr) external;

    function setBonusCampaign() external;
}
