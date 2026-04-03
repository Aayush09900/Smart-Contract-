// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CourseEnrollment {

    // 🔹 State Variables
    address public owner;
    uint public totalStudents;

    // 🔹 Struct
    struct Student {
        string name;
        uint age;
        string university;
        string course;
        bool isRegistered;
    }

    // 🔹 Mapping
    mapping(address => Student) public student_address;

    // 🔹 Array
    address[] private students;

    // 🔹 Constructor
    constructor() {
        owner = msg.sender;
    }

    // 🔹 Modifier: Only Owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }

    // 🔹 Modifier: Check Registration
    modifier isRegisteredUser() {
        require(student_address[msg.sender].isRegistered, "Not registered");
        _;
    }

    // 🔹 Function: Register Student
    function set_details(
        string memory name,
        uint age,
        string memory university
    ) public {
        require(!student_address[msg.sender].isRegistered, "Already registered");

        student_address[msg.sender] = Student(
            name,
            age,
            university,
            "",
            true
        );

        students.push(msg.sender);
        totalStudents++;
    }

    // 🔹 Course Selection Functions
    function AI() public isRegisteredUser {
        student_address[msg.sender].course = "AI";
    }

    function Web_Development() public isRegisteredUser {
        student_address[msg.sender].course = "Web Development";
    }

    function Blockchain() public isRegisteredUser {
        student_address[msg.sender].course = "Blockchain";
    }

    function Datascience() public isRegisteredUser {
        student_address[msg.sender].course = "Data Science";
    }

    // 🔹 View Functions
    function get_all_students() public view returns (address[] memory) {
        return students;
    }

    function getMyDetails()
        public
        view
        returns (string memory, uint, string memory, string memory)
    {
        Student memory s = student_address[msg.sender];
        return (s.name, s.age, s.university, s.course);
    }
}