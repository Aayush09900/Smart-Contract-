// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title GuestBook
/// @notice A decentralized event guest book. Each wallet can sign in once,
///         storing its address, a display name, and the block timestamp.
contract GuestBook {
    struct Guest {
        address wallet;
        string name;
        uint256 timestamp;
    }

    // All registered guests, in the order they signed in.
    Guest[] private guests;

    // Quick lookup to enforce "one signature per wallet".
    mapping(address => bool) public hasSignedIn;

    // Emitted every time a new guest successfully registers.
    event GuestRegistered(address indexed wallet, string name, uint256 timestamp);

    /// @notice Register the caller's wallet in the guest book.
    /// @param _name The display name the guest wants to appear under.
    function signGuestBook(string calldata _name) external {
        require(!hasSignedIn[msg.sender], "This wallet has already signed in");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_name).length <= 64, "Name is too long");

        guests.push(Guest({
            wallet: msg.sender,
            name: _name,
            timestamp: block.timestamp
        }));

        hasSignedIn[msg.sender] = true;

        emit GuestRegistered(msg.sender, _name, block.timestamp);
    }

    /// @notice Return every guest that has ever signed in, oldest first.
    function getGuests() external view returns (Guest[] memory) {
        return guests;
    }

    /// @notice Convenience helper so the frontend can show "N people signed in"
    ///         without pulling the full array.
    function getGuestCount() external view returns (uint256) {
        return guests.length;
    }
}
