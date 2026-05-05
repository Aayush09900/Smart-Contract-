// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
 contract ReceiveEther{
    address private owner;
    
    constructor (){
        owner = msg.sender;
    }
    function withdraw(uint amount) public {
        require(msg.sender == owner, "Not owner");
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner).transfer(amount);
    }

 }