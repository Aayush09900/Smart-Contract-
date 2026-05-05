// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EmployeeManagement {

    struct Employee {
        string name;
        uint salary;
        string role;
        bool isActive;
    }

    mapping(address => Employee) public employees;

    address public admin;

    constructor() {
        admin = msg.sender; // HR/Admin
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    // Add or update employee
    function setEmployee(
        address _emp,
        string memory _name,
        uint _salary,
        string memory _role
    ) public onlyAdmin {
        employees[_emp] = Employee(_name, _salary, _role, true);
    }

    // Activate/Deactivate employee
    function setStatus(address _emp, bool _status) public onlyAdmin {
        employees[_emp].isActive = _status;
    }

    // View employee
    function getEmployee(address _emp) public view returns (Employee memory) {
        return employees[_emp];
    }
}