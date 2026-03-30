// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
contract FixedArray {

    uint[] numbers = [10,20,30,40,50];

     function addNumbers(uint num) public {
        numbers.push(num);
    }

    function removeLast()public {
        numbers.pop();
    }

    function getlength() public view returns(uint){
        return numbers.length;
    }

    
    
}
