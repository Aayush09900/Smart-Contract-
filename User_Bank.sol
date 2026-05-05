// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract userbank{

    address owner;
    uint totalbalance;

    function deposit (uint amount) public {
        require(amount > 100,"add above than INR 100");
        totalbalance += amount;
    }

    function withdraw_cash (uint _amount) public {
        require(100 <= _amount, "Minimum Withdrawal Should be above 100");
        totalbalance -= _amount;
    }
    
    function get_balance() public view returns (uint){
        return totalbalance;
    }
}