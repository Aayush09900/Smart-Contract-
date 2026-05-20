// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract combinename{

    string india;
    string haryana;
    

    function _combinename(string memory _india,string memory _haryana) public pure returns (string memory){
        return string (abi.encodePacked(_india," ",_haryana));
    }
}