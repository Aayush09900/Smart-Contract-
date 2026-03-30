// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AddNumbers {

    uint[]public numbers=[0,5];
    
    function addNumbers(uint num) public {
        numbers.push(num);
    }

}