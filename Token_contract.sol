// contracts/DEVToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // Using a modern 0.8.x version

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DEVsToken is ERC20 {
    
    constructor(uint256 initialSupply) ERC20("Devil", "DEV") {
        _mint(msg.sender, initialSupply);
    }
}