// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LoanEligibility {
    mapping(address => uint256) public collateral;

    function depositCollateral() external payable {
        collateral[msg.sender] += msg.value;
    }

    function checkEligibility() external view returns (bool) {
        return collateral[msg.sender] >= 5 ether;
    }
}

