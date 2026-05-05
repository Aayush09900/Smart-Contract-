// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReceiveEther {
    function deposit()public payable {

    }
    function getbalance () public view returns (uint){
        return address(this).balance;
    }
   
} 