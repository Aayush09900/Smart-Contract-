// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract greetingmessagr{

    string hello;
    string name;

    function message(string memory _hello,string memory _name) public pure returns (string memory){
        return string (abi.encodePacked(_hello,"",_name));
    }
}