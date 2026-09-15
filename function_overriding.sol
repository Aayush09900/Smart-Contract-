// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract parent{
    
    function message() public pure virtual returns (string memory){
        return "hello from parent";
    }
}
contract child is parent{

    function message() public pure virtual override returns (string memory){
    return "hello from parent";
    }
}
contract grandchild is child{

    function message() public pure virtual override returns (string memory){
    return "hello from grandchild";
    }
}