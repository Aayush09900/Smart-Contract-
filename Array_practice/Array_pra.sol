// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Array_practice {

    uint[] public numbers;

    function addNumber(uint num) public {
        numbers.push(num);
    }

    function getLength() public view returns(uint) {
        return numbers.length;
    }

    function get_byindex(uint index) public view returns (uint) {
        return numbers[index];
    }

    function update_byindex(uint index, uint num) public {
        numbers[index] = num;
    }

    function delete_byindex(uint index) public {
        delete numbers[index];
    }

    function remove_last() public view {
        numbers.pop;
    }

    function sum_ofall() public view returns (uint num) {
         uint sum = 0;

        for(uint i = 0; i < numbers.length; i++) {
            sum += numbers[i];
        }

        return sum;
    }

    function getLargest() public view returns (uint) {

        uint largest = numbers[0];

        for(uint i = 1; i < numbers.length; i++) {

            if(numbers[i] > largest) {
                largest = numbers[i];
            }

        }

        return largest;
    }

}