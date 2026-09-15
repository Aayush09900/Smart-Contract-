// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract parent_su{

    function greet() public pure virtual returns  (string memory){
        return "hello";
    }
}
 contract child is parent_su{

    function greet() public pure override returns (string memory){
      return string .concat(super.greet(), "aayush");
    }
 }