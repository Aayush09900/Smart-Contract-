// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Student{
    string name;
    uint age;

    function details(string memory _name, uint _age) public returns(string memory, uint){
          name= _name;
          age= _age;
          return (name, age);
    }
}

contract Result is Student{
    uint marks;

    function Marks(string memory _name, uint _age,uint _marks) public  returns(string memory, uint){
        marks = _marks;
        details(_name, _age);
        return (name, marks);
    }
}

    contract DetailsMarks is Student{
       uint Marks;
       

    function _DetailsMarks(string memory _name, uint _marks) public  returns(string memory, uint){
        _marks = 25;
        details("Aayush", 18);
        return (_name, _marks);
    }
}


