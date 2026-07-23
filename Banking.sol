// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Banking {

    address public owner;

    mapping(address => uint256) private balances;

    event Deposited(
        address indexed user,
        uint256 amount
    );

    event Withdrawn(
        address indexed user,
        uint256 amount
    );

    event Transferred(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Deposit ETH
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than 0");

        balances[msg.sender] += msg.value;

        emit Deposited(msg.sender, msg.value);
    }

    // Withdraw ETH
    function withdraw(uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Effects
        balances[msg.sender] -= amount;

        // Interaction
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    // Internal transfer between users
    function transferBalance(address to, uint256 amount) external {

        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transferred(msg.sender, to, amount);
    }

    // Check own balance
    function getMyBalance() external view returns(uint256){
        return balances[msg.sender];
    }

    // Check any user's balance
    function getBalance(address user)
        external
        view
        returns(uint256)
    {
        return balances[user];
    }

    // Total ETH stored in contract
    function bankBalance()
        external
        view
        returns(uint256)
    {
        return address(this).balance;
    }

    // Emergency withdraw by owner
    function emergencyWithdraw()
        external
        onlyOwner
    {
        payable(owner).transfer(address(this).balance);
    }
}