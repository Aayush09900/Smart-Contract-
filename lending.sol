// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RealDeFiLending {
    struct Position {
        uint256 collateralETH;
        uint256 borrowedETH;
        uint256 repaymentAmount;
        uint256 borrowTime;
        bool active;
        bool repaid;
    }

    mapping(address => uint256) public lenderBalance;
    mapping(address => Position) public positions;
    uint256 public totalLiquidity;
    uint256 public constant LTV = 75;
    uint256 public constant INTEREST_RATE = 10;
    uint256 public constant LOAN_PERIOD = 180 days;
    event LiquidityDeposited(address indexed lender, uint256 amount);
    event LiquidityWithdrawn(address indexed lender, uint256 amount);
    event CollateralDeposited(address indexed borrower, uint256 amount);
    event LoanBorrowed(address indexed borrower, uint256 amount);
    event LoanRepaid(address indexed borrower, uint256 amount);
    event CollateralWithdrawn(address indexed borrower, uint256 amount);
    // ====================================
    // LENDER FUNCTIONS
    // ====================================
    function depositLiquidity() external payable {
        require(msg.value > 0, "Send ETH");
        lenderBalance[msg.sender] += msg.value;
        totalLiquidity += msg.value;
        emit LiquidityDeposited(msg.sender, msg.value);
    }
    function withdrawLiquidity(uint256 amount) external {
        require(lenderBalance[msg.sender] >= amount, "Insufficient balance");
        require(totalLiquidity >= amount, "Pool shortage");
        lenderBalance[msg.sender] -= amount;
        totalLiquidity -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        emit LiquidityWithdrawn(msg.sender, amount);
    }
    // ====================================
    // BORROWER FUNCTIONS
    // ====================================
    function depositCollateral() external payable {
        require(msg.value > 0, "Send collateral");
        Position storage p = positions[msg.sender];
        p.collateralETH += msg.value;
        p.active = true;
        emit CollateralDeposited(msg.sender, msg.value);
    }
    function borrow() external {
        Position storage p = positions[msg.sender];
        require(p.active, "No collateral");
        require(p.borrowedETH == 0, "Already borrowed");
        uint256 borrowLimit = (p.collateralETH * LTV) / 100;
        require(totalLiquidity >= borrowLimit, "Not enough liquidity");
        uint256 interest = (borrowLimit * INTEREST_RATE) / 100;
        p.borrowedETH = borrowLimit;
        p.repaymentAmount = borrowLimit + interest;
        p.borrowTime = block.timestamp;
        totalLiquidity -= borrowLimit;
        (bool success, ) = payable(msg.sender).call{value: borrowLimit}("");
        require(success, "Loan transfer failed");
        emit LoanBorrowed(msg.sender, borrowLimit);
    }
    function repayLoan() external payable {
        Position storage p = positions[msg.sender];
        require(p.active, "No active loan");
        require(!p.repaid, "Already repaid");
        require(block.timestamp >= p.borrowTime + LOAN_PERIOD, "6 month lock");
        require(msg.value == p.repaymentAmount, "Incorrect repayment");
        p.repaid = true;
        totalLiquidity += msg.value;
        emit LoanRepaid(msg.sender, msg.value);
    }
    function withdrawCollateral() external {
        Position storage p = positions[msg.sender];
        require(p.repaid, "Repay loan first");
        uint256 amount = p.collateralETH;
        delete positions[msg.sender];
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");
        emit CollateralWithdrawn(msg.sender, amount);
    }
    // ====================================
    // VIEW FUNCTIONS
    // ====================================
    function getPoolBalance() external view returns (uint256) {
        return totalLiquidity;
    }
    function getMyCollateral() external view returns (uint256) {
        return positions[msg.sender].collateralETH;
    }
    function getLoanDetails()   external view returns ( uint256 collateral,uint256 borrowed,uint256 repayment, uint256 borrowTime, bool active,  bool repaid ){
        Position memory p = positions[msg.sender];
        return (
            p.collateralETH,
            p.borrowedETH,
            p.repaymentAmount,
            p.borrowTime,
            p.active,
            p.repaid
        );
    }
}
