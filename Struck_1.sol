// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Studentstruck{

    struct student{
        uint roll ;
        string name;
    }

    student public student1;
    // student [] public student_arr;

    function setname (uint _roll, string memory _name) public {
      student1.roll = _roll;
      student1.name = _name;
    }
    
    // function store_name (uint _roll, string memory _name) public {
    //     student_arr.push(student(_roll,_name));

    // }

}