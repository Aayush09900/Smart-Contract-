// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract abiencodepacked{
  
    string firstname;
   string middlename;
   string lastname;

   function fullname( string memory _firstname, string memory _middlename , string memory _lastname) public pure  returns (string memory){
    return string(abi.encodePacked(_firstname,"",_middlename,_lastname));
   }
}

