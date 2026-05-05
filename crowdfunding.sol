// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding {

  address  owner;
  uint public goal;
  uint public totalfund;
  uint deadline;

  constructor (uint _goal,uint _min){
   

  }

// event Funding(address user, uint _amount, string _message); // Event to log funding contributions)
uint public total_balance = 2000;

function fund (uint _amount) public  {
  total_balance += _amount;
 }
 function withdraw(uint _amount) public {
    total_balance -= _amount;
  }
  function getBalance() public view returns (uint) {
    return total_balance;
  }
  function refund(uint _amount) public view returns (uint) {
    return (total_balance - _amount); 
    
  }
}
