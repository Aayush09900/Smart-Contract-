// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;

    address[] public players;

    address public winner;

    mapping(address => bool) public entered;

    constructor() {
        manager = msg.sender;
    }

    // Enter Lottery
    function enter() public payable {
        // require(msg.value == 1 ether, "Lottery amount must be 1 ETH");

        require(!entered[msg.sender], "You already entered");

        // New lottery started
        if (players.length == 0) {
            winner = address(0);
        }

        players.push(msg.sender);

        entered[msg.sender] = true;
    }

    // Get Players
    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    // Random Number
    function random() private view returns (uint) {
        return
            uint(keccak256(abi.encodePacked(block.timestamp, players.length)));
    }

    // Pick Winner
    function pickWinner() public {
        require(msg.sender == manager, "Only manager can pick winner");

        require(players.length > 0, "No players joined");

        uint index = random() % players.length;

        winner = players[index];

        payable(winner).transfer(address(this).balance);

        // Reset entered mapping
        for (uint i = 0; i < players.length; i++) {
            entered[players[i]] = false;
        }

        players = new address[](0);
    }

    // Get Winner
    function getWinner() public view returns (address) {
        return winner;
    }
}
