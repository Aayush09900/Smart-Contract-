// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UniqueValues {
    uint[] public A = [1, 2, 3, 4];
    uint[] public B = [3, 4, 5, 6];

    function getUniqueValues() public view returns (uint[] memory) {
        uint[] memory temp = new uint[](A.length + B.length);
        uint count = 0;
        for (uint i = 0; i < A.length; i++) {
            bool found = false;
            for (uint j = 0; j < B.length; j++) {
                if (A[i] == B[j]) {found = true;}
            }
            if (!found) { temp[count] = A[i];count++;}
        }
        for (uint i = 0; i < B.length; i++) {
            bool found = false;
            for (uint j = 0; j < A.length; j++) {if (B[i] == A[j]) { found = true;}
            }
            if (!found) { temp[count] = B[i];count++;}
        }
        uint[] memory unique = new uint[](count);
        for (uint i = 0; i < count; i++) {
            unique[i] = temp[i];
        }
        return unique;
    }
}
