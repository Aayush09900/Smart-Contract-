// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@account-abstraction/contracts/interfaces/IAccount.sol";
import "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import "@account-abstraction/contracts/core/Helpers.sol";

/// @title AyuAccount
/// @notice ERC-4337 smart contract wallet with owner-based control + guardian
///         social recovery. One instance is deployed per user (via AyuFactory),
///         counterfactually addressed so it can receive funds before deployment.
contract AyuAccount is IAccount, Initializable {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    // ── Storage ──────────────────────────────────────────────────────────
    address public owner;
    address public immutable entryPoint;

    // Guardians for social recovery (e.g. trusted contacts, hardware key, backup device)
    mapping(address => bool) public isGuardian;
    address[] public guardians;
    uint256 public guardianThreshold; // how many guardians must approve a recovery

    // Active recovery request, if any
    struct RecoveryRequest {
        address proposedOwner;
        uint256 approvals;
        uint256 executeAfter; // timelock — recovery cannot execute before this timestamp
        bool active;
    }
    RecoveryRequest public pendingRecovery;
    mapping(address => mapping(uint256 => bool)) private _hasApprovedRecovery; // guardian => recoveryNonce => approved
    uint256 public recoveryNonce;
    uint256 public constant RECOVERY_TIMELOCK = 2 days;

    // Spending limit guardrail (optional safety net — separate from guardian recovery)
    uint256 public dailySpendLimit; // in wei, 0 = unlimited
    uint256 public spentToday;
    uint256 public spendWindowStart;

    // ── Events ───────────────────────────────────────────────────────────
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event GuardianAdded(address indexed guardian);
    event GuardianRemoved(address indexed guardian);
    event GuardianThresholdChanged(uint256 newThreshold);
    event RecoveryInitiated(
        address indexed proposedOwner,
        uint256 executeAfter,
        uint256 nonce
    );
    event RecoveryApproved(address indexed guardian, uint256 nonce);
    event RecoveryExecuted(address indexed newOwner);
    event RecoveryCancelled(uint256 nonce);
    event Executed(address indexed target, uint256 value, bytes data);
    event SpendLimitChanged(uint256 newLimit);

    // ── Errors ───────────────────────────────────────────────────────────
    error NotOwner();
    error NotEntryPoint();
    error NotOwnerOrEntryPoint();
    error NotGuardian();
    error InvalidThreshold();
    error NoActiveRecovery();
    error TimelockNotExpired();
    error AlreadyApproved();
    error InsufficientApprovals();
    error ExceedsSpendLimit();
    error ExecutionFailed(bytes returnData);
    error ZeroAddress();
    error DuplicateGuardian();

    // ── Modifiers ────────────────────────────────────────────────────────
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyEntryPoint() {
        if (msg.sender != entryPoint) revert NotEntryPoint();
        _;
    }

    /// @dev Allows calls either from a signed UserOperation routed via EntryPoint,
    ///      or directly from the owner (e.g. for non-gasless convenience calls).
    modifier onlyOwnerOrEntryPoint() {
        if (msg.sender != owner && msg.sender != entryPoint)
            revert NotOwnerOrEntryPoint();
        _;
    }

    modifier onlyGuardian() {
        if (!isGuardian[msg.sender]) revert NotGuardian();
        _;
    }

    constructor(address _entryPoint) {
        entryPoint = _entryPoint;
        _disableInitializers(); // implementation contract itself is never initialized directly
    }

    /// @notice Called once by the factory right after CREATE2 deployment.
    function initialize(
        address _owner,
        address[] calldata _guardians,
        uint256 _threshold
    ) external initializer {
        if (_owner == address(0)) revert ZeroAddress();
        owner = _owner;

        for (uint256 i = 0; i < _guardians.length; i++) {
            if (_guardians[i] == address(0)) revert ZeroAddress();
            if (isGuardian[_guardians[i]]) revert DuplicateGuardian();
            isGuardian[_guardians[i]] = true;
            guardians.push(_guardians[i]);
        }
        if (_threshold == 0 || _threshold > _guardians.length)
            revert InvalidThreshold();
        guardianThreshold = _threshold;

        emit OwnerChanged(address(0), _owner);
    }

    receive() external payable {}

    // ── ERC-4337 required entrypoint hook ───────────────────────────────

    /// @notice Validates a UserOperation's signature against `owner`. Called only by EntryPoint.
    function validateUserOp(
        PackedUserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external onlyEntryPoint returns (uint256 validationData) {
        bytes32 signedHash = userOpHash.toEthSignedMessageHash();
        address recovered = signedHash.recover(userOp.signature);

        if (recovered != owner) {
            validationData = SIG_VALIDATION_FAILED;
        } else {
            validationData = SIG_VALIDATION_SUCCESS;
        }

        // Pre-fund the EntryPoint for gas if it requests it
        if (missingAccountFunds > 0) {
            (bool ok, ) = payable(msg.sender).call{value: missingAccountFunds}(
                ""
            );
            // intentionally not reverting on failure — EntryPoint handles shortfall
            ok;
        }
    }

    // ── Core execution ───────────────────────────────────────────────────

    /// @notice Execute an arbitrary call from this account. Used for sends, swaps,
    ///         contract interactions — anything the owner (or a UserOp) authorizes.
    function execute(
        address target,
        uint256 value,
        bytes calldata data
    ) external onlyOwnerOrEntryPoint {
        _enforceSpendLimit(value);
        (bool success, bytes memory ret) = target.call{value: value}(data);
        if (!success) revert ExecutionFailed(ret);
        emit Executed(target, value, data);
    }

    /// @notice Batch multiple calls in a single UserOperation (e.g. approve + swap).
    function executeBatch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata datas
    ) external onlyOwnerOrEntryPoint {
        require(
            targets.length == values.length && values.length == datas.length,
            "length mismatch"
        );
        for (uint256 i = 0; i < targets.length; i++) {
            _enforceSpendLimit(values[i]);
            (bool success, bytes memory ret) = targets[i].call{
                value: values[i]
            }(datas[i]);
            if (!success) revert ExecutionFailed(ret);
            emit Executed(targets[i], values[i], datas[i]);
        }
    }

    function _enforceSpendLimit(uint256 value) internal {
        if (dailySpendLimit == 0 || value == 0) return;
        if (block.timestamp >= spendWindowStart + 1 days) {
            spendWindowStart = block.timestamp;
            spentToday = 0;
        }
        if (spentToday + value > dailySpendLimit) revert ExceedsSpendLimit();
        spentToday += value;
    }

    function setDailySpendLimit(uint256 newLimit) external onlyOwner {
        dailySpendLimit = newLimit;
        emit SpendLimitChanged(newLimit);
    }

    // ── Guardian management (owner-controlled) ──────────────────────────

    function addGuardian(address guardian) external onlyOwner {
        if (guardian == address(0)) revert ZeroAddress();
        if (isGuardian[guardian]) revert DuplicateGuardian();
        isGuardian[guardian] = true;
        guardians.push(guardian);
        emit GuardianAdded(guardian);
    }

    function removeGuardian(address guardian) external onlyOwner {
        if (!isGuardian[guardian]) revert NotGuardian();
        isGuardian[guardian] = false;
        for (uint256 i = 0; i < guardians.length; i++) {
            if (guardians[i] == guardian) {
                guardians[i] = guardians[guardians.length - 1];
                guardians.pop();
                break;
            }
        }
        if (guardianThreshold > guardians.length) {
            guardianThreshold = guardians.length;
        }
        emit GuardianRemoved(guardian);
    }

    function setGuardianThreshold(uint256 newThreshold) external onlyOwner {
        if (newThreshold == 0 || newThreshold > guardians.length)
            revert InvalidThreshold();
        guardianThreshold = newThreshold;
        emit GuardianThresholdChanged(newThreshold);
    }

    function getGuardians() external view returns (address[] memory) {
        return guardians;
    }

    // ── Social recovery flow (guardian-controlled, timelocked) ─────────
    //
    // Flow:
    //  1. Any guardian calls initiateRecovery(newOwner) — starts the clock.
    //  2. Other guardians call approveRecovery() until threshold is met.
    //  3. After RECOVERY_TIMELOCK has elapsed AND threshold is met,
    //     anyone calls executeRecovery() to swap in the new owner.
    //  4. The real owner can call cancelRecovery() at any time before
    //     execution to block a malicious/compromised-guardian takeover —
    //     this is the safety valve that makes timelock meaningful.

    function initiateRecovery(address proposedOwner) external onlyGuardian {
        if (proposedOwner == address(0)) revert ZeroAddress();

        recoveryNonce++;
        pendingRecovery = RecoveryRequest({
            proposedOwner: proposedOwner,
            approvals: 1,
            executeAfter: block.timestamp + RECOVERY_TIMELOCK,
            active: true
        });
        _hasApprovedRecovery[msg.sender][recoveryNonce] = true;

        emit RecoveryInitiated(
            proposedOwner,
            pendingRecovery.executeAfter,
            recoveryNonce
        );
        emit RecoveryApproved(msg.sender, recoveryNonce);
    }

    function approveRecovery() external onlyGuardian {
        if (!pendingRecovery.active) revert NoActiveRecovery();
        if (_hasApprovedRecovery[msg.sender][recoveryNonce])
            revert AlreadyApproved();

        _hasApprovedRecovery[msg.sender][recoveryNonce] = true;
        pendingRecovery.approvals++;

        emit RecoveryApproved(msg.sender, recoveryNonce);
    }

    function executeRecovery() external {
        RecoveryRequest memory req = pendingRecovery;
        if (!req.active) revert NoActiveRecovery();
        if (block.timestamp < req.executeAfter) revert TimelockNotExpired();
        if (req.approvals < guardianThreshold) revert InsufficientApprovals();

        address oldOwner = owner;
        owner = req.proposedOwner;
        delete pendingRecovery;

        emit OwnerChanged(oldOwner, owner);
        emit RecoveryExecuted(owner);
    }

    /// @notice The legitimate owner's escape hatch — cancels any in-flight
    ///         recovery attempt, e.g. if guardians are colluding or were phished.
    function cancelRecovery() external onlyOwner {
        if (!pendingRecovery.active) revert NoActiveRecovery();
        emit RecoveryCancelled(recoveryNonce);
        delete pendingRecovery;
    }

    // ── ERC-1271 signature validation (so DApps can verify "is this signed
    //    by the wallet" for things like off-chain order signing / login) ──
    function isValidSignature(
        bytes32 hash,
        bytes memory signature
    ) external view returns (bytes4) {
        address recovered = hash.toEthSignedMessageHash().recover(signature);
        if (recovered == owner) {
            return 0x1626ba7e; // ERC-1271 magic value
        }
        return 0xffffffff;
    }

    // Lets the account hold/transfer NFTs safely
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }
}
