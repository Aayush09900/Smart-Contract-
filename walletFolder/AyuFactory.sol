// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./AyuAccount.sol";

/// @title AyuFactory
/// @notice Deploys AyuAccount smart wallets deterministically (CREATE2) so a
///         user's wallet address is known and can receive funds *before* the
///         contract is actually deployed. Deployment is triggered lazily by
///         the first UserOperation (standard ERC-4337 "initCode" pattern).
contract AyuFactory {
    address public immutable accountImplementation;

    event AccountCreated(
        address indexed account,
        address indexed owner,
        uint256 salt
    );

    constructor(address entryPoint) {
        accountImplementation = address(new AyuAccount(entryPoint));
    }

    /// @notice Returns the deterministic address for a given owner + salt,
    ///         WITHOUT deploying anything. Used by the frontend to show the
    ///         user their wallet address immediately after sign-up.
    function getAddress(
        address owner,
        address[] calldata guardians,
        uint256 threshold,
        uint256 salt
    ) external view returns (address) {
        bytes32 saltHash = _salt(owner, guardians, threshold, salt);
        return
            Clones.predictDeterministicAddress(
                accountImplementation,
                saltHash,
                address(this)
            );
    }

    /// @notice Deploys the account if it doesn't exist yet, and returns its address.
    ///         Safe to call multiple times — returns existing address if already deployed.
    function createAccount(
        address owner,
        address[] calldata guardians,
        uint256 threshold,
        uint256 salt
    ) external returns (address account) {
        bytes32 saltHash = _salt(owner, guardians, threshold, salt);
        address predicted = Clones.predictDeterministicAddress(
            accountImplementation,
            saltHash,
            address(this)
        );

        if (predicted.code.length > 0) {
            return predicted; // already deployed
        }

        account = Clones.cloneDeterministic(accountImplementation, saltHash);
        AyuAccount(payable(account)).initialize(owner, guardians, threshold);

        emit AccountCreated(account, owner, salt);
    }

    function _salt(
        address owner,
        address[] calldata guardians,
        uint256 threshold,
        uint256 salt
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(owner, guardians, threshold, salt));
    }
}
