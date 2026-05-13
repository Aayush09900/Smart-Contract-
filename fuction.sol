// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract set {


//2511 without constant gas fee 
// with constant gas fee 378
    address public constant  addres = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 ;


//2500 without constant gas fee
// with constant gas fee 364
    function setvariable () public view returns (address){
        return addres;
    }
}