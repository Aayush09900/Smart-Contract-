// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Car_showroom{

    enum Car_type{Hatchback, Coupe, Sedan, Suv, Micro_Suv}

    struct Details{
        uint id;
        Car_type Type;
    }

    mapping(uint => Details) private carss;

    Car_type public Car_types;

    function Default_type() public {
        Car_types = Car_type.Coupe;
    }

    function update_type(uint _id, uint _type) public {
        carss[_id].Type = Car_type(_type);
    }
}