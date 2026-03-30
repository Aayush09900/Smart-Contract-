// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

 contract Calcultor {
    function multi (uint num1, uint num2) external pure returns (uint){
        return num1*num2;
    }
    function divi (uint num1, uint num2) external pure returns (uint){
        return (num1)/num2;
    }
    function sub (uint num1, uint num2)external pure returns (uint){
        return num1-num2;
    }
    function add (uint num1,uint num2)external pure returns (uint){
        return num1+num2;
    }
    function modu( uint num1, uint num2)external pure returns(uint){
        return num1%num2;
    }
 }