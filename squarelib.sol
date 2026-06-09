// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract library_square{

    function _square(uint a)public pure returns (uint){
    return a*a; 
    }
    function get_square(uint A)public pure returns (uint){
    return library_square._square(A);
     }
}