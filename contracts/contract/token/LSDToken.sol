// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../interface/token/ILSDToken.sol";

contract LSDToken is ERC20 {
    constructor() ERC20("lsdToken", "LSD") {}

    function decimals() public pure override returns (uint8) {
        return 9;
    }

    function mint(uint256 _amount) public {
        _mint(msg.sender, _amount);
    }

    function burn(uint256 _amount) public {
        _burn(msg.sender, _amount);
    }
}
