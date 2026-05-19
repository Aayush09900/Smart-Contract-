// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentRecords{

    struct studentrecord{
        uint roll;
        string name;
        uint marks;
        bool present;
    }

studentrecord public s1;

constructor(uint _roll, string memory _name , uint _marks, bool _present){
 s1.roll= _roll;
 s1.name=_name;
 s1.marks=_marks;
 s1.present=_present;
}

}