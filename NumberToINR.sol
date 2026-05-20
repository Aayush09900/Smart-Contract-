// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NumberToINR {
    string[10] ones = [
        "Zero",
        "One",
        "Two",
        "Three",
        "Four",
        "Five",
        "Six",
        "Seven",
        "Eight",
        "Nine"
    ];

    string[10] tens = [
        "",
        "Ten",
        "Twenty",
        "Thirty",
        "Forty",
        "Fifty",
        "Sixty",
        "Seventy",
        "Eighty",
        "Ninety"
    ];

    function convert(uint num) public view returns (string memory) {
        uint hundred = num / 100;
        uint remaining = num % 100;
        uint ten = remaining / 10;
        uint one = remaining % 10;return string(abi.encodePacked(ones[hundred], " Hundred ", tens[ten], " ",ones[one], " Rupees"));
    }
}
