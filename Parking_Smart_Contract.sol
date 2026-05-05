// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Parking {

    struct Vehicle {
        uint startTime;
        bool isParked;
    }

    mapping(address => Vehicle) public vehicles;

    uint public hourlyRate = 1 ether; // example rate

    // Park vehicle
    function park() public {
        require(!vehicles[msg.sender].isParked, "Already parked");

        vehicles[msg.sender] = Vehicle(block.timestamp, true);
    }

    // Remove vehicle & calculate fee
    function unpark() public payable {
        Vehicle storage v = vehicles[msg.sender];
        require(v.isParked, "Not parked");

        uint duration = block.timestamp - v.startTime;
        uint hoursParked = duration / 3600;

        if (hoursParked == 0) {
            hoursParked = 1; // minimum 1 hour
        }

        uint fee = hoursParked * hourlyRate;

        require(msg.value >= fee, "Insufficient payment");

        v.isParked = false;

        // refund extra
        if (msg.value > fee) {
           (bool success, ) = payable(msg.sender).call{value: msg.value - fee}("");
              require(success, "Refund failed");
        }
    }
}