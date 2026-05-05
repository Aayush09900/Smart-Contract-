// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Eventpassing {
 address wallet;
 uint balance;

 event deposite(uint amount);
 event account (address indexed acc , uint amount);

 function depositeAmount(uint amount) public {
  balance += amount;

  emit deposite(amount);

 } 
 function withdrwalamount(uint amount) public {
    balance -= amount;
 }
 function accounts() public payable {
    emit account (msg.sender,msg.value);
 }
}