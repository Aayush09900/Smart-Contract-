// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery{

    address owner;

    constructor(){
        owner=msg.sender;
    }

    struct Participant{
        uint id;
        address user;
        uint amount;
        bool winner;
    }

    mapping(uint => Participant) public participants;
    uint[] totalParti;
    uint Ids;

    function addLottery() public payable{
        uint amount = msg.value;
        require(amount == 1 ether, "You can only send 1 ether");
        Ids++;
        participants[Ids] = Participant(Ids, msg.sender, amount, false);
        totalParti.push(Ids);
    }
    address public winner;

    function selectWinner() public{
           require(msg.sender == owner,"Access Denied");

           uint index = block.timestamp % totalParti.length;
            winner = participants[totalParti[index]].user;
            participants[totalParti[index]].winner = true;
            uint winningAmount = address(this).balance;
            participants[totalParti[index]].amount += winningAmount;
            payable(winner).call{value: address(this).balance};
    }
}