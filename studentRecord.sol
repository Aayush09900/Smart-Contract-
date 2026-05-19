// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Studentrecordsstruct{

struct students{
    uint rollno;
    string name;
    uint marks;
}

students public studentss1;
students[] public students1;

function set_arr (uint _rollno, string memory _name,uint _marks) public {
    students1.push(students(_rollno,_name,_marks));
}


}