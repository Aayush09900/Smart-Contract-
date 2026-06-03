// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LandRegistry {

    uint256 public propertyCount;

    struct Property {
        uint256 propertyId;
        string location;
        uint256 area;
        string documentCID;
        address owner;
        bool exists;
    }

    mapping(uint256 => Property) public properties;

    modifier onlyOwner(uint256 _propertyId) {
        require(
            properties[_propertyId].owner == msg.sender,
            "Not property owner"
        );
        _;
    }

    function registerProperty(string memory _location,uint256 _area,string memory _documentCID) public {

        propertyCount++;

        properties[propertyCount] = Property({
            propertyId: propertyCount,
            location: _location,
            area: _area,
            documentCID: _documentCID,
            owner: msg.sender,
            exists: true
        });
    }

    function transferOwnership(uint256 _propertyId, address _newOwner) public onlyOwner(_propertyId) {

        require(
            properties[_propertyId].exists,
            "Property does not exist"
        );

        properties[_propertyId].owner = _newOwner;
    }

    function getProperty(uint256 _propertyId) public view returns (
            uint256,
            string memory,
            uint256,
            string memory,
            address
        )
    {
        Property memory p = properties[_propertyId];

        return (
            p.propertyId,
            p.location,
            p.area,
            p.documentCID,
            p.owner
        );
    }

    function getDocumentURL(uint256 _propertyId) public view returns (string memory){
        require(
            properties[_propertyId].exists,
            "Property does not exist"
        );

        return string(
            abi.encodePacked(
                "https://ipfs.io/ipfs/",
                properties[_propertyId].documentCID
            )
        );
    }
}