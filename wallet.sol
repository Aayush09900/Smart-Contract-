// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Aayu_Wallet {

    uint public Total_Balance;

    function Deposite (uint amount) public {
          require(amount>=100,"add 100");
        Total_Balance += amount;
    }

    function Withdrawal_Balance (uint amount) public {
        require(amount>=500,"withdrwal upto 500");
        Total_Balance -= amount;
    }

    function view_Balance () public view returns (uint) {
        return Total_Balance;
    }
}