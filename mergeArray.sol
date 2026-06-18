// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MergeArrays {
    uint[] public A = [1, 2, 3];
    uint[] public B = [4, 5, 6];

    function mergeArrays() public view returns (uint[] memory) {
        uint[] memory merged = new uint[](A.length + B.length);
        uint index = 0;
        for (uint i = 0; i < A.length; i++) {
            merged[index] = A[i];
            index++;
        }
        for (uint i = 0; i < B.length; i++) {
            merged[index] = B[i];
            index++;
        }
        return merged;
    }
}
