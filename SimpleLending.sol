/*Lending Protocol (Like Compound/Aave)

Design a lending protocol where:

Users can deposit ETH as collateral.
Users can borrow USDC against their collateral.
Loan-to-Value (LTV) ratio is 75%.*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleLending {
    struct User {
        uint256 collateral;
        uint256 borrowed;
    }

    mapping(address => User) public users;

    uint256 public constant LTV = 75; // 75%

    // Deposit ETH as collateral
    function depositCollateral() external payable {
        require(msg.value > 0, "Deposit ETH");

        users[msg.sender].collateral += msg.value;
    }

    // Borrow against collateral
    function borrow(uint256 amount) external {
        User storage user = users[msg.sender];

        uint256 maxBorrow = (user.collateral * LTV) / 100;

        require(user.borrowed + amount <= maxBorrow, "Exceeds borrow limit");

        user.borrowed += amount;

        payable(msg.sender).transfer(amount);
    }

    // Repay loan
    function repayLoan() external payable {
        User storage user = users[msg.sender];

        require(user.borrowed > 0, "No loan");

        user.borrowed -= msg.value;
    }

    // Withdraw collateral
    function withdrawCollateral(uint256 amount) external {
        User storage user = users[msg.sender];

        require(user.collateral >= amount, "Not enough collateral");

        uint256 remainingCollateral = user.collateral - amount;

        uint256 maxBorrow = (remainingCollateral * LTV) / 100;

        require(user.borrowed <= maxBorrow, "Loan would become unsafe");

        user.collateral -= amount;

        payable(msg.sender).transfer(amount);
    }

    // Liquidate unsafe position
    function liquidate(address borrower) external {
        User storage user = users[borrower];

        uint256 maxBorrow = (user.collateral * LTV) / 100;

        require(user.borrowed > maxBorrow, "Position is healthy");

        uint256 collateralToSeize = user.collateral;

        user.collateral = 0;
        user.borrowed = 0;

        payable(msg.sender).transfer(collateralToSeize);
    }

    function getBorrowLimit(
        address userAddress
    ) external view returns (uint256) {
        return (users[userAddress].collateral * LTV) / 100;
    }
}
