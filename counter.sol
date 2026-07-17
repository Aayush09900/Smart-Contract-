// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract counter{
    uint public num;

    function increment() public {
        num++;
    }
    function getall () public view {
        num;
    }
    function incrementby (uint _num) public {
        num = _num + num++;
    }

}