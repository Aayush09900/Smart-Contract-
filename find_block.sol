// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract find_block{

     uint a = 10;

    function block_height() public view returns (uint ) {
    return block.number ;
    }
    function block_height1()public view returns (uint) {
        return block.number;
    }
   function getPreviousBlock() public view returns (bytes32) {
    return blockhash(block.number - 1);
    } 
   function getBlockInfo() public view returns (uint, bytes32) {
    return (block.number, blockhash(block.number - 1));
    }
}