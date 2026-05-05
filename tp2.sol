// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Proposal {
        string name;
        uint256 voteCount;
        uint256 deadline;
    }

    Proposal[] public proposals;

    mapping(uint256 => mapping(address => bool)) public hasVoted;

    mapping(address => uint256) public tokenBalance;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function createProposal(string memory _name, uint256 _duration) public onlyOwner {
        proposals.push(Proposal({
            name: _name,
            voteCount: 0,
            deadline: block.timestamp + _duration //uniepoxtime
        }));
    }

    function giveTokens(address _user, uint256 _amount) public onlyOwner {
        tokenBalance[_user] += _amount;
    }

    function vote(uint256 _proposalId) public {
        Proposal storage p = proposals[_proposalId];

        require(block.timestamp < p.deadline, "Voting ended");
        require(!hasVoted[_proposalId][msg.sender], "Already voted");

        uint256 weight = tokenBalance[msg.sender];
        require(weight > 0, "No voting power");

        p.voteCount += weight;
        hasVoted[_proposalId][msg.sender] = true;
    }

    function getWinner() public view returns (uint256 winnerId) {
        uint256 maxVotes = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > maxVotes) {
                maxVotes = proposals[i].voteCount;
                winnerId = i;
            }
        }
    }
}