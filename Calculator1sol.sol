// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Calculator {

    // Addition
    function add(uint a, uint b) public pure returns (uint) {
        return a + b;
    }

    // Subtraction
    function subtract(uint a, uint b) public pure returns (uint) {
        require(b <= a, "Subtraction underflow");
        return a - b;
    }

    // Multiplication
    function multiply(uint a, uint b) public pure returns (uint) {
        return a * b;
    }

    // Division
    function divide(uint a, uint b) public pure returns (uint) {
        require(b != 0, "Division by zero not allowed");
        return a / b;
    }

    // Modulus
    function modulus(uint a, uint b) public pure returns (uint) {
        require(b != 0, "Modulo by zero not allowed");
        return a % b;
    }
}