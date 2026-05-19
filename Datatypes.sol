// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Assign_Datatypes {
    string names = "aayush,rahul";
    uint []numbers = [70,80,90,85];
    bool present = true;
    address owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    bytes _names = "Aayush";
}{
    
}
}
  // Constructor runs once during deployment
    constructor() {
        owner = msg.sender;
    }

    // Add a new number into array
    function addNumber(uint _num) public {
        numbers.push(_num);
    }

    // Change names
    function updateNames(string memory _newNames) public {
        names = _newNames;
    }

    // Change attendance
    function changeStatus(bool _status) public {
        present = _status;
    }

    // Get total numbers count
    function totalNumbers() public view returns(uint) {
        return numbers.length;
    }

    // Get a number using index
    function getNumber(uint _index) public view returns(uint) {
        return numbers[_index];
    }
    

 