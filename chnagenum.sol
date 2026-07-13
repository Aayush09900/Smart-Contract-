// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract changenumber{
     
    uint public number = 50;

    function add() public {
     number = number + 20;
    }

}