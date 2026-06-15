// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DeFiLending {
    struct Loan {
        address borrower;
        uint256 collateral;
        uint256 borrowedAmount;
        uint256 repaymentAmount;
        uint256 borrowTime;
        bool active;
        bool repaid;
    }
    mapping(address => Loan) public loans;
    uint256 public constant MIN_COLLATERAL = 5 ether;
    uint256 public constant INTEREST_RATE = 10;
    uint256 public constant LOAN_PERIOD = 180 days;
    event CollateralDeposited(address indexed borrower, uint256 amount);
    event LoanBorrowed(address indexed borrower, uint256 amount);
    event LoanRepaid(address indexed borrower, uint256 amount);
    event CollateralWithdrawn(address indexed borrower, uint256 amount);
    

    // Deposit ETH as collateral
    function depositCollateral() external payable {
        require(msg.value >= MIN_COLLATERAL, "Minimum collateral is 5 ETH");
        require(!loans[msg.sender].active, "Loan already exists");
        loans[msg.sender] = Loan({borrower: msg.sender,collateral: msg.value,borrowedAmount: 0,repaymentAmount: 0,borrowTime: 0,active: true,repaid: false});
        emit CollateralDeposited(msg.sender, msg.value);
    }
    // Borrow 50% of collateral value
    function borrow() external {
        Loan storage loan = loans[msg.sender];
        require(loan.active, "Deposit collateral first");
        require(loan.borrowedAmount == 0, "Already borrowed");
        uint256 borrowAmount = loan.collateral / 2;
        uint256 interest = (borrowAmount * INTEREST_RATE) / 100;
        loan.borrowedAmount = borrowAmount;
        loan.repaymentAmount = borrowAmount + interest;
        loan.borrowTime = block.timestamp;
        emit LoanBorrowed(msg.sender, borrowAmount);
    }
    function oneWei()public pure returns(uint){
        return 1 wei;
    }
    function oneGwei() public pure returns(uint){
        return 1 gwei;
    }
    function oneEther() public pure returns(uint){
        return 1 ether;
    }
    function fiveEther() public pure returns(uint){
        return 5 ether;
    }

    // Repay loan after 6 months
    function repayLoan() external payable {
        Loan storage loan = loans[msg.sender];
        require(loan.active, "No active loan");
        require(!loan.repaid, "Already repaid");
        require( block.timestamp >= loan.borrowTime + LOAN_PERIOD, "Repayment locked for 6 months" );
        require(msg.value == loan.repaymentAmount,"Incorrect repayment amount");
         loan.repaid = true;
        emit LoanRepaid(msg.sender, msg.value);
    }

    // Withdraw collateral after repayment
    function withdrawCollateral() external {
        Loan storage loan = loans[msg.sender];
        require(loan.repaid, "Repay loan first");
        uint256 amount = loan.collateral;
        delete loans[msg.sender];
        (bool success, ) = payable(msg.sender).call{value: amount}("");

        require(success, "Transfer failed");
        emit CollateralWithdrawn(msg.sender, amount);
    }

    // View loan details
    function getLoanDetails()external view returns (address, uint256, uint256, uint256, uint256, bool, bool){
        Loan memory loan = loans[msg.sender];
        return (loan.borrower,loan.collateral,loan.borrowedAmount,loan.repaymentAmount,loan.borrowTime,loan.active,loan.repaid);
    }
}
