// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract InterestCalculator {
    function calculateInterest(uint256 principal,uint256 rate,uint256 time) public pure returns (uint256) {
        return (principal * rate * time) / 100;
    }
}
