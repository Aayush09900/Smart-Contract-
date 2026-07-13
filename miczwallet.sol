// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MiczWallet {
    address public owner;

    event Deposited(address indexed from, uint256 amount);
    event Transferred(address indexed to, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Accept ETH directly
    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }

    // Deposit ETH into the wallet
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        emit Deposited(msg.sender, msg.value);
    }

    // Show wallet balance
    function showBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Transfer ETH from wallet to another address
    function transfer(address payable _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "Invalid receiver address");
        require(address(this).balance >= _amount, "Insufficient balance");

        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");

        emit Transferred(_to, _amount);
    }
}
