// Patient Details
// patientId
// name
// disease
// doctorAssigned
// admitted
// billAmount
// Add patient
// Update disease
// Assign doctor
// Discharge patient
// Generate hospital bill
// Prevent updating discharged patient
// Count admitted patients
// Get patient details

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HospitalManagement {
    struct Patient {
        uint patientId;
        string name;
        string disease;
        string doctorAssigned;
        bool admitted;
        uint billAmount;
    }

    // Store patients
    mapping(uint => Patient) public patients;

    // Track admitted patients count
    uint public admittedCount;

    function addPatient(
        uint _patientId,
        string memory _name,
        string memory _disease
    ) public {
        patients[_patientId] = Patient(
            _patientId,
            _name,
            _disease,
            "",
            true,
            0
        );

        admittedCount++;
    }

    function updateDisease(uint _patientId, string memory _newDisease) public {
        require(patients[_patientId].admitted, "Patient discharged");

        patients[_patientId].disease = _newDisease;
    }

    function assignDoctor(uint _patientId, string memory _doctor) public {
        require(patients[_patientId].admitted, "Patient discharged");

        patients[_patientId].doctorAssigned = _doctor;
    }

    function generateBill(uint _patientId, uint _amount) public {
        require(patients[_patientId].admitted, "Patient discharged");

        patients[_patientId].billAmount += _amount;
    }

    function dischargePatient(uint _patientId) public {
        require(patients[_patientId].admitted, "Already discharged");

        patients[_patientId].admitted = false;

        admittedCount--;
    }

    function getPatientDetails(uint _patientId)public view returns (uint, string memory, string memory, string memory, bool, uint){
        Patient memory p = patients[_patientId];

        return (p.patientId,p.name,p.disease,p.doctorAssigned,p.admitted,p.billAmount);
    }
}
