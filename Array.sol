// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
 contract ArrayFunction{

    uint[] array = [10,20,30,40];

    function array_function () public view returns (uint sum) {
       sum =0;
       uint length = array.length;
       for(uint8 i =0;i<length;i++){
        sum += array[i];
       }
        return  sum ;
    } 
 }