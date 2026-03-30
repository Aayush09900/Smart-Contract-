// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentManagement {

    //  State Variables
    address public owner;
    uint public totalStudents;

    //  Struct
    struct Student {
        uint id;
        string name;
        uint age;
        bool isEnrolled;
    }

    //  Array
    Student[] public students;

    //  Mapping
    mapping(uint => Student) public studentById;
    mapping(address => bool) public registered;

    //  Constructor
    constructor() {
        owner = msg.sender;
    }

    //  Modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    //  Functions

    // Add Student (only owner)
    function addStudent(uint _id, string memory _name, uint _age) public onlyOwner {
        Student memory newStudent = Student(_id, _name, _age, true);

        students.push(newStudent);
        studentById[_id] = newStudent;

        totalStudents++;
    }

    // Get Student by ID
    function getStudent(uint _id) public view returns (string memory, uint, bool) {
        Student memory s = studentById[_id];
        return (s.name, s.age, s.isEnrolled);
    }

    // Enroll Student (by address)
    function register() public {
        require(!registered[msg.sender], "Already registered");
        registered[msg.sender] = true;
    }

    // Get Total Students
    function getTotalStudents() public view returns (uint) {
        return totalStudents;
    }
}