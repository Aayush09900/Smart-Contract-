// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentIDGenerator {

    function generateStudentID(string memory _name,uint _rollNumber) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name, _rollNumber));
    }
}
