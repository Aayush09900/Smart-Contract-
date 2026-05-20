// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CreateUsername {
    function createUsername(string memory firstName,string memory lastName,uint birthYear) public pure returns (string memory) {
        return string(abi.encodePacked(firstName, lastName, uintToString(birthYear)));
    }

    // Convert uint to string
    function uintToString(uint num) internal pure returns (string memory) {
        if (num == 0) {
            return "0";
        }

        uint temp = num;
        uint digits;

        // count digits
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (num != 0) {
            digits -= 1;

            buffer[digits] = bytes1(uint8(48 + (num % 10)));

            num /= 10;
        }

        return string(buffer);
    }
}
