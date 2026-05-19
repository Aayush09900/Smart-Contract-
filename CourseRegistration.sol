// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Course 
// courseId
// courseName
// teacherName
// totalSeats
// enrolledStudents
// Student 
// studentId
// name
// enrolled

contract CourseRegistration{

    struct course{
     
    uint courseId;
    string courseName;
    string teacherName;
    uint totalSeats;
    uint enrolledStudents;
    }

    struct student{

    uint studentId;
    string name;
    bool enrolled;
    }

    
}
