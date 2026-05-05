// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiUserWallet {

    address public owner;

    mapping(address => uint) public balances;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function deposit() public payable {
        require(msg.value > 0, "Send some ETH");

        balances[msg.sender] += msg.value;
    }

    function getMyBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
    }

    function getContractBalance() public view onlyOwner returns (uint) {
        return address(this).balance;
    }
}
