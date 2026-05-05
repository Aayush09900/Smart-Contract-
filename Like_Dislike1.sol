// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LikeDislike {

    uint public likeCount;
    uint public dislikeCount;

    // Track if a user has already voted
    mapping(address => bool) public hasVoted;

    // Track user choice (true = like, false = dislike)
    mapping(address => bool) public userChoice;

    // Like function
    function like() public {
        require(!hasVoted[msg.sender], "You have already voted");

        likeCount++;
        hasVoted[msg.sender] = true;
        userChoice[msg.sender] = true;
    }

    // Dislike function
    function dislike() public {
        require(!hasVoted[msg.sender], "You have already voted");

        dislikeCount++;
        hasVoted[msg.sender] = true;
        userChoice[msg.sender] = false;
    }

    // Change vote
    function changeVote() public {
        require(hasVoted[msg.sender], "You haven't voted yet");

        if (userChoice[msg.sender]) {
            likeCount--;
            dislikeCount++;
            userChoice[msg.sender] = false;
        } else {
            dislikeCount--;
            likeCount++;
            userChoice[msg.sender] = true;
        }
    }

    // Get total votes
    function totalVotes() public view returns (uint) {
        return likeCount + dislikeCount;
    }
}