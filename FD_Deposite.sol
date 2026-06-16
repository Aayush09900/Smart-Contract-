// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FixedDeposit {
    struct FD {
        uint256 amount;
        uint256 startTime;
        uint256 duration;
        bool withdrawn;
    }

    mapping(address => FD) public deposits;
    uint256 public constant INTEREST_RATE = 10;

    function createFD(uint256 _duration) external payable {
        require(msg.value > 0, "Deposit ETH");

        deposits[msg.sender] = FD({amount: msg.value,startTime: block.timestamp,duration: _duration,withdrawn: false });
    }

    function withdrawFD() external {
        FD storage fd = deposits[msg.sender];
        require(!fd.withdrawn, "Already withdrawn");
        require( block.timestamp >= fd.startTime + fd.duration, "FD not matured" );
         uint256 interest = (fd.amount * INTEREST_RATE) / 100;
        uint256 payout = fd.amount + interest;
        fd.withdrawn = true;
        payable(msg.sender).transfer(payout);
    }
}
