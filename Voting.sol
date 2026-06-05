// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    address public owner;

    mapping(uint => Candidate) private candidates;
    mapping(address => bool) private hasVoted;

    uint public candidatesCount;
    uint private totalVoters;

    // 🏆 NEW STATE VARIABLES
    bool public resultDeclared;
    Candidate[3] private topWinners;

    event Voted(uint indexed candidateId);
    event ResultDeclared(
        string first,
        string second,
        string third
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier resultNotDeclared() {
        require(!resultDeclared, "Result already declared");
        _;
    }

    constructor() {
        owner = msg.sender;
        addCandidate("Bengaluru (Bangalore)");
        addCandidate("Hyderabad");
        addCandidate("Delhi-NCR (Gurugram & Noida)");
    }

    function addCandidate(string memory _name) private {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    function vote(uint _candidateId) public resultNotDeclared {
        require(!hasVoted[msg.sender], "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");

        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        totalVoters++;

        emit Voted(_candidateId);
    }

    //  DECLARE RESULT (TOP 3 STORED ON BLOCKCHAIN)
    function declareResult() public onlyOwner resultNotDeclared {

        Candidate memory first;
        Candidate memory second;
        Candidate memory third;

        for (uint i = 1; i <= candidatesCount; i++) {

            Candidate memory current = candidates[i];

            if (current.voteCount > first.voteCount) {
                third = second;
                second = first;
                first = current;

            } else if (current.voteCount > second.voteCount) {
                third = second;
                second = current;

            } else if (current.voteCount > third.voteCount) {
                third = current;
            }
        }

        topWinners[0] = first;
        topWinners[1] = second;
        topWinners[2] = third;

        resultDeclared = true;

        emit ResultDeclared(
            first.name,
            second.name,
            third.name
        );
    }

    //  GET TOP 3 WINNERS (BLOCKCHAIN STORED)
    function getTopWinners()
        public
        view
        returns (
            uint, string memory, uint,
            uint, string memory, uint,
            uint, string memory, uint
        )
    {
        require(resultDeclared, "Result not declared yet");

        Candidate memory first = topWinners[0];
        Candidate memory second = topWinners[1];
        Candidate memory third = topWinners[2];

        return (
            first.id, first.name, first.voteCount,
            second.id, second.name, second.voteCount,
            third.id, third.name, third.voteCount
        );
    }

    // Only owner can see total voters
    function getTotalVoters() public view onlyOwner returns (uint) {
        return totalVoters;
    }

    // Only owner can see vote count
    function getCandidate(uint _candidateId)
        public
        view
        onlyOwner
        returns (uint, string memory, uint)
    {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid ID");

        Candidate memory c = candidates[_candidateId];
        return (c.id, c.name, c.voteCount);
    }

    // Public function for normal users (NO vote count)
    function getCandidateBasic(uint _candidateId)
        public
        view
        returns (uint, string memory)
    {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid ID");

        Candidate memory c = candidates[_candidateId];
        return (c.id, c.name);
    }

    function getCandidateCount() public view returns(uint){
        return candidatesCount;
    }
}