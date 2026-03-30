// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentData {
     
    struct Student {
        string name;
        uint age;
    }

    Student public s1;

    function setStudent(string memory _name,uint _age) public {
    s1=Student(_name,_age);
    }
}
