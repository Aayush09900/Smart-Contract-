// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract productstruct{

    struct product{
        uint Batch_no ;
        string names;
        bool expired;
    }

    product[] public products;
    product public productss;

    // function setname (uint _Batch_no, string memory _names, bool _expired) public {
    //   productss.Batch_no = _Batch_no;
    //   productss.names = _names;
    //   productss.expired = _expired;
    //   }

      function set_arr (uint _Batch_no, string memory _names, bool _expired) public {
        products.push(product(_Batch_no,_names,_expired));
      }

    //   function getall () public returns ( product [] memory){
    //         return products[];
    //   }
}