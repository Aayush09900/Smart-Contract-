// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransactionHashGenerator {

    function generateTransactionHash(address _sender,address _receiver,uint _amount) public payable returns (bytes32) {
        return keccak256(bytes(abi.encodePacked(_sender, _receiver, _amount)));
    }
}
