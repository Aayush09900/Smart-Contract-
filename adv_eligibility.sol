// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LoanEligibility {

    mapping(address => uint256) public collateral;

    function checkEligibility() external view returns (bool, uint256) {
    bool eligible = collateral[msg.sender] >= 5 ether;

    return (eligible, collateral[msg.sender]);
}
}