// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MessageBoard {
    struct Message {
        string username;
        string message;
        address userAddress;
        uint256 timestamp;
    }

    Message[] public messages;

    event MessagePosted(
        string username,
        string message,
        address indexed user,
        uint256 timestamp
    );

    function postMessage(
        string memory _username,
        string memory _message
    ) public {
        require(bytes(_username).length > 0, "Username required");
        require(bytes(_message).length > 0, "Message required");

        messages.push(
            Message(_username, _message, msg.sender, block.timestamp)
        );

        emit MessagePosted(_username, _message, msg.sender, block.timestamp);
    }

    function getAllMessages() public view returns (Message[] memory) {
        return messages;
    }

    function getMessageCount() public view returns (uint256) {
        return messages.length;
    }
}
