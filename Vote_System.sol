// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {

    // 🔹 State Variables
    address public owner;
    uint public totalVoters;

    // 🔹 Struct
    struct Voter {
        string name;
        uint age;
        string party;
        bool hasVoted;
        bool isRegistered;
    }

    // 🔹 Mapping
    mapping(address => Voter) public voters;

    // 🔹 Array
    address[] public votersList;

    // 🔹 Vote Count Mapping
    mapping(string => uint) public voteCount;

    // 🔹 Constructor
    constructor() {
        owner = msg.sender;
    }

    // 🔹 Modifier: Only Owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // 🔹 Modifier: Only Registered
    modifier onlyRegistered() {
        require(voters[msg.sender].isRegistered, "Not registered");
        _;
    }

    // 🔹 Modifier: Vote Only Once
    modifier notVoted() {
        require(!voters[msg.sender].hasVoted, "Already voted");
        _;
    }

    // 🔹 Register Voter
    function register(string memory _name, uint _age) public {
        require(_age >= 18, "Not eligible to vote");
        require(!voters[msg.sender].isRegistered, "Already registered");

        voters[msg.sender] = Voter(_name, _age, "", false, true);
        votersList.push(msg.sender);
        totalVoters++;
    }

    // 🔹 Internal Voting Logic
    function _vote(string memory _party) internal onlyRegistered notVoted {
        voters[msg.sender].party = _party;
        voters[msg.sender].hasVoted = true;
        voteCount[_party]++;
    }

    // 🔹 Vote Functions
    function voteBJP() public {
        _vote("BJP");
    }

    function voteCongress() public {
        _vote("Congress");
    }

    function voteAAP() public {
        _vote("AAP");
    }

    function voteINLD() public {
        _vote("INLD");
    }

    // 🔹 Get My Details
    function getMyDetails()
        public
        view
        returns (string memory, uint, string memory, bool)
    {
        Voter memory v = voters[msg.sender];
        return (v.name, v.age, v.party, v.hasVoted);
    }

    // 🔹 Get All Voters
    function getAllVoters() public view returns (address[] memory) {
        return votersList;
    }

    // 🔹 Get Results
    function getVotes(string memory _party) public view returns (uint) {
        return voteCount[_party];
    }
}