// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StudentAge {
    mapping(uint => uint) public studentAges;

    function setAge(uint studentId, uint age) public {
        studentAges[studentId] = age;
    }

    function getAge(uint studentId) public view returns (uint) {
        return studentAges[studentId];
    }
}
