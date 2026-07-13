// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract multisign_wallet{

    address[] public owner;

    mapping (address => bool) public isowner;

    uint public required;

struct transaction{
 address to;
 uint value;
 bool executed;
 uint approval_count;
}
transaction[] public transactions;

mapping (uint => mapping (address => bool)) public ED;

  // txId => owner => approved
    mapping(uint => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isowner[msg.sender], "Not owner");
        _;
    }

    modifier txExists(uint txId) {
        require(txId < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint txId) {
        require(!transactions[txId].executed, "Transaction already executed");
        _;
    }

    modifier notApproved(uint txId) {
        require(!approved[txId][msg.sender], "Already approved");
        _;
    }

constructor(address [] memory _owners, uint required){
    require(_owners.length > 0, "owners required");
    require(_owners.length > 0 && required <= _owners.length, "invalid required length");

 }


}
