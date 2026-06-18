// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommonValues {
    uint[] public arrayA = [1, 2, 3, 4, 5];
    uint[] public arrayB = [3, 4, 5, 6, 7];

    function getCommonValues() public view returns (uint[] memory) {
        uint count = 0;
        for (uint i = 0; i < arrayA.length; i++) {
            for (uint j = 0; j < arrayB.length; j++) {
                if (arrayA[i] == arrayB[j]) {
                    count++;
                }
            }
        }
     uint[] memory common = new uint[](count);
        uint index = 0;
        for (uint i = 0; i < arrayA.length; i++) {
            for (uint j = 0; j < arrayB.length; j++) {
                if (arrayA[i] == arrayB[j]) {
                    common[index] = arrayA[i];
                    index++;
                }
            }
        }
        return common;
    }
}
