// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Password {
    string private password = "1234";

    function login(string memory _pass) public view returns(string memory) {
        if(keccak256(bytes(_pass)) == keccak256(bytes(password))) {
            return "Access Granted";
        } else {
            return "Access Denied";
        }
    }

     function get_byte (string memory _pass) public pure returns (bytes memory){
       return (bytes(_pass));
    }
    function get_length (string memory _input) public pure returns (uint){
        return bytes(_input).length;
    }
    function back_string (bytes memory _byte) public pure returns (string memory){
        return string(_byte);
    }
   function toUppercase(string memory _input) public pure returns(string memory){
        bytes memory strByte = bytes(_input);
        uint strLength = strByte.length;
        bytes memory resStr= new bytes(strLength);

        for(uint i=0;i<strLength;i++){
            if(uint8(strByte[i])>=97 && uint8(strByte[i])<=122){
              resStr[i] = bytes1(uint8(strByte[i])-32);
            }else{
            resStr[i] = strByte[i];
        }
        }

        return string(resStr);
    }

    function toLowercase(string memory _input) public pure returns(string memory){
        bytes memory strByte = bytes(_input);
        uint strLength = strByte.length;
        bytes memory resStr= new bytes(strLength);

        for(uint i=0;i<strLength;i++){
            if(uint8(strByte[i])>=65 && uint8(strByte[i])<=90){
              resStr[i] = bytes1(uint8(strByte[i])+32);
            }else{
            resStr[i] = strByte[i];
        }
        }

        return string(resStr);
    }
    function reverse(string memory _input) public pure returns (string memory) {
    bytes memory str = bytes(_input);
    bytes memory reversed = new bytes(str.length);

    for (uint i = 0; i < str.length; i++) {
        reversed[i] = str[str.length - 1 - i];
    }

    return string(reversed);
}
   
}







   