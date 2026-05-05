// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserRegistry {

    mapping(address => bool) public registeredUsers;

    event UserRegistered(address user);

    function register() public {
        require(!registeredUsers[msg.sender], "Already registered");

        registeredUsers[msg.sender] = true;

        emit UserRegistered(msg.sender);
    }
}