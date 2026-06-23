// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@account-abstraction/contracts/core/BasePaymaster.sol";
import "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";

/// @title AyuPaymaster
/// @notice Lets the Ayu app sponsor gas for specific users/operations so they
///         can transact without holding ETH (classic "gasless onboarding" UX).
///         Funded by the Ayu team via EntryPoint deposit; whitelists which
///         accounts it's willing to sponsor.
contract AyuPaymaster is BasePaymaster {
    mapping(address => bool) public sponsoredAccounts;
    uint256 public maxSponsoredGasPerOp;

    event AccountSponsorshipUpdated(address indexed account, bool sponsored);
    event MaxGasUpdated(uint256 newMax);
    event GasSponsored(
        address indexed account,
        uint256 actualGasCost,
        PostOpMode mode
    );

    constructor(
        address entryPoint,
        uint256 _maxSponsoredGasPerOp
    ) BasePaymaster(IEntryPoint(entryPoint)) {
        maxSponsoredGasPerOp = _maxSponsoredGasPerOp;
    }

    function setSponsored(address account, bool sponsored) external onlyOwner {
        sponsoredAccounts[account] = sponsored;
        emit AccountSponsorshipUpdated(account, sponsored);
    }

    function setMaxSponsoredGas(uint256 newMax) external onlyOwner {
        maxSponsoredGasPerOp = newMax;
        emit MaxGasUpdated(newMax);
    }

    function _validatePaymasterUserOp(
        PackedUserOperation calldata userOp,
        bytes32,
        uint256 maxCost
    )
        internal
        view
        override
        returns (bytes memory context, uint256 validationData)
    {
        require(
            sponsoredAccounts[userOp.sender],
            "AyuPaymaster: account not sponsored"
        );
        require(
            maxCost <= maxSponsoredGasPerOp,
            "AyuPaymaster: exceeds sponsorship cap"
        );
        // Pass the sponsored account forward so _postOp can attribute gas cost to them
        return (abi.encode(userOp.sender), 0); // 0 = signature/time-range valid indefinitely
    }

    /// @dev Emits per-account gas accounting. Decoding `context` and emitting
    ///      here (rather than discarding the params) is what lets an indexer
    ///      build a per-user sponsorship-spend dashboard off-chain.
    function _postOp(
        PostOpMode mode,
        bytes calldata context,
        uint256 actualGasCost,
        uint256
    ) internal override {
        address account = abi.decode(context, (address));
        emit GasSponsored(account, actualGasCost, mode);
    }
}
