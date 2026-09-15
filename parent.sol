// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract parent{
    string public name ="aayush";

    function greeet()public pure returns (string memory){
        return "welcome";
    }
}

contract child is parent {
    function greeeting ()public pure returns (string memory){
        return "welcome";
    }

}
contract parents1 is child  {
    function childs ()public pure returns (string memory){
        return "welcome";
    }

}
