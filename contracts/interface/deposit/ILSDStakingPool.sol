// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILSDStakingPool {
    function stakeLSD(uint256 _lsdTokenAmount) external;

    function unstakeLSD(uint256 _veLSDAmount) external;

    function claimByLSD() external;

    function getClaimAmountByLSD(
        address _address
    ) external view returns (uint256);

    function getEarnedByLSD(address _address) external view returns (uint256);

    function getStakedLSD(address _address) external view returns (uint256);

    function getTotalRewardsByLSD() external view returns (uint256);

    function getTotalLSD() external view returns (uint256);

    //--------------------------------------------------
    function addLiquidity(uint256 _lsdTokenAmount) external payable;

    function removeLiquidity(uint256 _amount) external;

    function getTotalLPTokenBalance() external view returns (uint256);

    function getClaimAmountByLiquidity(
        address _address
    ) external view returns (uint256);

    function claimByLiquidity() external;

    function getTotalRewardsByLiquidity() external view returns (uint256);

    function getStakedLP(address _address) external view returns (uint256);

    function getEarnedByLiquidity(
        address _address
    ) external view returns (uint256);
}
