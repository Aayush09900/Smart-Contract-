// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ecommerce {

    address public owner;
    uint public productCount;
    uint public orderCount;

    constructor() {
        owner = msg.sender;
    }

    //  Product structure
    struct Product {
        uint id;
        string name;
        uint price;
        address payable seller;
        bool available;
    }

    //  Order structure
    struct Order {
        uint id;
        uint productId;
        address buyer;
        uint amount;
    }

    // Storage
    mapping(uint => Product) public products;
    mapping(uint => Order) public orders;

    //  Events
    event ProductAdded(uint id, string name, uint price, address seller);
    event ProductPurchased(uint orderId, uint productId, address buyer, uint amount);
    event ProductRemoved(uint productId);

    //  Add Product
    function addProduct(string memory _name, uint _price) public {
        require(_price > 0, "Price must be greater than 0");

        productCount++;

        products[productCount] = Product(productCount, _name, _price, payable(msg.sender),true);

        emit ProductAdded(productCount, _name, _price, msg.sender);
    }

    //  Buy Product
    function buyProduct(uint _productId) public payable {
        Product storage product = products[_productId];

        require(product.available, "Product not available");
        require(msg.value == product.price, "Incorrect price");

        orderCount++;

        // Save order
        orders[orderCount] = Order(orderCount,_productId,msg.sender, msg.value);

        // Transfer ETH to seller
        product.seller.transfer(msg.value);

        emit ProductPurchased(orderCount, _productId, msg.sender, msg.value);
    }

    //  Remove Product
    function removeProduct(uint _productId) public {
        Product storage product = products[_productId];
 
        require(msg.sender == product.seller, "Not seller");

        product.available = false;

        emit ProductRemoved(_productId);
    }
}