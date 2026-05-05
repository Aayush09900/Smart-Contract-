// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProductLifecycle {

    enum Stage { Created, Shipped, Delivered }

    struct Product {
        string name;
        address owner;
        Stage stage;
    }

    mapping(uint => Product) public products;
    uint public productCount;

    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    // Create product
    function createProduct(string memory _name) public onlyAdmin {
        products[productCount] = Product(_name, msg.sender, Stage.Created);
        productCount++;
    }

    // Update stage
    function updateStage(uint _id, Stage _stage) public onlyAdmin {
        Product storage p = products[_id];

        // Prevent invalid transitions
        require(uint(_stage) == uint(p.stage) + 1, "Invalid stage transition");

        p.stage = _stage;
    }

    // Get product
    function getProduct(uint _id) public view returns (Product memory) {
        return products[_id];
    }
}