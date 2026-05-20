
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract CurrencyConverter {

    uint public usdToInrRate = 94;

    function convertToINR(uint usdAmount) public view returns(string memory){
        uint conv = usdAmount * usdToInrRate; 
        string memory toStr = Strings.toString(conv);
        return string(abi.encodePacked(toStr," ","INR"));
    }
}
// return string(abi.encodePacked(tens[t], " ", units[u]));