// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BankAccountSystem {

    // Struct = group multiple values together
    struct Account {
        string holderName;
        uint balance;
        uint accountNumber;
    }

    // Store account data for each user address
    mapping(address => Account) public accounts;

    // Create account
    function createAccount(
        string memory _name,
        uint _accountNumber
    ) public {

        accounts[msg.sender] = Account({
            holderName: _name,
            balance: 0,
            accountNumber: _accountNumber
        });
    }

    // Deposit money
    function deposit(uint _amount) public {

        require(_amount > 0, "Amount should be greater than 0");

        accounts[msg.sender].balance += _amount;
    }

    // Withdraw money
    function withdraw(uint _amount) public {

        require(_amount > 0, "Amount should be greater than 0");

        require(
            accounts[msg.sender].balance >= _amount,
            "Insufficient balance"
        );

        accounts[msg.sender].balance -= _amount;
    }

    // View account details
    function getAccount() public view returns(
        string memory,
        uint,
        uint
    ){
        Account memory a = accounts[msg.sender];

        return (
            a.holderName,
            a.balance,
            a.accountNumber
        );
    }
}