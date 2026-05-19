// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract CourseRegistration {
    struct Course {
        uint courseId;
        string courseName;
        string teacherName;
        uint totalSeats;
        uint enrolledStudents;
    }

    struct Student {
        uint studentId;
        string name;
        uint courseId;
        bool enrolled;
    }
    uint totalCourses;
    uint totalStudents;
    mapping(uint => Course) public courses;
    mapping(uint => Student) public students;
    mapping(uint => bool) public isStudentExist;

    function addCourse(
        string memory _courseName,
        string memory _teacherName,
        uint _totalseats
    ) public {
        totalCourses++;
        courses[totalCourses] = Course(
            totalCourses,
            _courseName,
            _teacherName,
            _totalseats,
            0
        );
    }

    function addStudent_Course(
        uint _courseId,
        uint _studentId,
        string memory _Name
    ) public {
        require(
            courses[_courseId].totalSeats > courses[_courseId].enrolledStudents,
            "No seat available"
        );
        require(isStudentExist[_studentId] == false, "Already Existed");
        totalStudents++;
        students[_studentId] = Student(_studentId, _Name, _courseId, true);
        courses[_courseId].enrolledStudents++;
        isStudentExist[_studentId] = true;
    }

    function getCourseDetails(
        uint _courseId
    ) public view returns (uint Id, string memory Name, string memory Teacher_Name, uint Total_seats, uint Enrolled_Students) {
        Course memory c = courses[_courseId];
        return (
            c.courseId,
            c.courseName,
            c.teacherName,
            c.totalSeats,
            c.enrolledStudents
        );
    }

    function getStudentDetails(
        uint _studentId
    ) public view returns (uint Id, string memory Name,uint CourseId, bool Enrolled) {
        Student memory s = students[_studentId];
        return (s.studentId, s.name,s.courseId, s.enrolled);
    }
}
