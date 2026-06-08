// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FlatTokenization {
    struct Flat {
        uint256 flatId;
        address owner;
        bool booked;
    }

    address public contractOwner;

    uint256 public constant TOTAL_FLATS = 300;

    uint256 public flatPrice = 1 wei;

    mapping(uint256 => Flat) public flats;

event Withdraw(address indexed owner, uint256 amount); 

    event FlatBooked(
        uint256 indexed flatId,
        address indexed buyer,
        uint256 amount
        
    );
    

    constructor() {
        contractOwner = msg.sender;

        for (uint256 i = 1; i <= TOTAL_FLATS; i++) {
            flats[i] = Flat({flatId: i, owner: address(0), booked: false});
        }
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only owner can call");
        _;
    }

    function bookFlat(uint256 _flatId) external payable {
        require(_flatId > 0 && _flatId <= TOTAL_FLATS, "Invalid flat id");

        require(!flats[_flatId].booked, "Flat already booked");

        require(msg.value == flatPrice, "Incorrect payment");

        flats[_flatId].owner = msg.sender;
        flats[_flatId].booked = true;

        emit FlatBooked(_flatId, msg.sender, msg.value);
    }

    function getFlatDetails(
        uint256 _flatId
    ) external view returns (uint256, address, bool) {
        Flat memory flat = flats[_flatId];

        return (flat.flatId, flat.owner, flat.booked);
    }

    function updateFlatPrice(uint256 _newPrice) external onlyOwner {
        flatPrice = _newPrice;
    }


    function withdraw() external onlyOwner {
    uint256 amount = address(this).balance;

    (bool success, ) = payable(contractOwner).call{value: amount}("");

    require(success, "Transfer failed");

    emit Withdraw(contractOwner, amount);
}

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
