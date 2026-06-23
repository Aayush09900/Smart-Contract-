// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
 Interface defines ONLY the functions
 that exist in UserBank and that ATM needs.
*/
interface IUserBank {
    function deposit(uint amount) external;
    function withdraw_cash(uint amount) external;
    function Get_Balance() external view returns (uint);
}

contract SBI_ATM_CASH {

    IUserBank public bank;

    // Pass UserBank contract address while deploying ATM
    constructor(address bank_address) {
        bank = IUserBank(bank_address);
    }

    function Add_Cash(uint amount) public {
        bank.deposit(amount);
    }

    function withdraw_Amount(uint amount) public {
        bank.withdraw_cash(amount);
    }

    function Available_Balance() public view returns (uint) {
        return bank.Get_Balance();
    }
}