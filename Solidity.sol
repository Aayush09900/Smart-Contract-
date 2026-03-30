// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CourseEnrollment {

    address public owner;
    uint public totalCourses;

    struct Course {
        string name;
        uint enrolledCount;
    }

    mapping(uint => Course) public courses;
    mapping(address => mapping(uint => bool)) public enrolled;

    constructor() {
        owner = msg.sender;
    }

    function addCourse(uint _id, string memory _name) public {
        require(msg.sender == owner, "Only owner");
        courses[_id] = Course(_name, 0);
        totalCourses++;
    }

    function enroll(uint _id) public {
        require(!enrolled[msg.sender][_id], "Already enrolled");

        courses[_id].enrolledCount++;
        enrolled[msg.sender][_id] = true;
    }
}
