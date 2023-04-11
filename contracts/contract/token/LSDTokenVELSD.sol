// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../LSDBase.sol";
import "../../interface/token/ILSDTokenVELSD.sol";

contract LSDTokenVELSD is LSDBase, ERC20, ILSDTokenVELSD {
    // Events
    event TokenMinted(address indexed to, uint256 amount, uint256 time);
    event TokenBurned(address indexed from, uint256 amount, uint256 time);

    // Construct with veLSD Token
    constructor(
        ILSDStorage _lsdStorageAddress
    ) LSDBase(_lsdStorageAddress) ERC20("VE-LSD", "veLSD") {
        // Version
        version = 1;
    }

    function decimals() public pure override returns (uint8) {
        return 9;
    }

    function mint(
        address _address,
        uint256 _amount
    ) public override onlyLSDContract("lsdTokenStaking", msg.sender) {
        _mint(_address, _amount);
    } 

    function burn(
        address _address,
        uint256 _amount
    ) public override onlyLSDContract("lsdTokenStaking", msg.sender) {
        _burn(_address, _amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal pure override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        require(0 > 1, "This token is not transferable");
    }
}
