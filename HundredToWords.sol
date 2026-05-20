// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HundredToWords {

    string[30] private units = [
        "Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine",
        "Ten","Eleven","Twelve","Thirteen","Fourteen","Fifteen","Sixteen","Seventeen","Eighteen","Nineteen"
        ,"Twenty","Twenty one","Twenty Two","Twenty Three","Twenty Four","Twenty Five","Twenty Six","Twenty Seven","Twenty Eight","Twenty Nine"
    ];

    string[10] private tens = [
        "", "", "Twenty","Thirty","Forty","Fifty","Sixty","Seventy","Eighty","Ninety"
    ];

    // Convert numbers from 0 to 100 into words
    function numberToWords(uint256 num) public view returns (string memory) {

        require(num <= 100, "Only numbers from 0 to 100 allowed");

        // 0 - 29
        if (num < 30) {
            return units[num];
        }

        // 100
        if (num == 100) {
            return "One Hundred";
        }

        // 30 - 99
        uint256 t = num / 10;
        uint256 u = num % 10;

        if (u == 0) {
            return tens[t];
        }

        return string(abi.encodePacked(tens[t], " ", units[u]));
    }
}