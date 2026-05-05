// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Array_Demo{

    uint []  numbers= [10,20,30,40];
    string [] names = ["saurabh","yogesh","rohit"];
   

    function add_numbers (uint number) public {
        numbers.push(number);
    }

    function add_name (string memory name) public {
        names.push(name);
    }

    function get_numbers () public view returns (uint [] memory) {
        return numbers;
    }
    function get_names () public view returns (string [] memory) {
        return names;
    }
}