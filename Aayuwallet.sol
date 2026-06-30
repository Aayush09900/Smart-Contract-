// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract AyuWallet {
    address public owner;

    bool public frozen;

    uint256 public dailyLimit = 5 ether;

    uint256 public totalTransactions;
    uint256 public totalVolume;

    address public nominee;

    uint256 public lastActivity;

    mapping(address => bool) public trustedAddresses;

    mapping(address => uint256) public balances;

    // -------------------------
    // EVENTS
    // -------------------------

    event Deposit(address indexed user, uint256 amount);

    event Withdraw(address indexed user, uint256 amount);

    event TransferETH(address indexed from, address indexed to, uint256 amount);

    event WalletFrozen(bool status);

    event TrustedAddressAdded(address indexed trusted);

    event TrustedAddressRemoved(address indexed trusted);

    event NomineeChanged(address nominee);

    // -------------------------
    // MULTISIG
    // -------------------------

    struct TransactionRequest {
        address to;
        uint256 amount;
        uint256 approvals;
        bool executed;
    }

    address[] public owners;

    uint256 public requiredApprovals;

    TransactionRequest[] public requests;

    mapping(uint256 => mapping(address => bool)) public approved;

    // -------------------------
    // SOCIAL RECOVERY
    // -------------------------

    mapping(address => bool) public guardians;

    mapping(address => uint256) public recoveryVotes;

    // -------------------------
    // MODIFIERS
    // -------------------------

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier notFrozen() {
        require(!frozen, "Wallet frozen");
        _;
    }

    constructor(address[] memory _owners, uint256 _requiredApprovals) {
        owner = msg.sender;

        owners = _owners;

        requiredApprovals = _requiredApprovals;

        lastActivity = block.timestamp;
    }

    // =========================
    // ETH FUNCTIONS
    // =========================

    function deposit() external payable notFrozen {
        balances[msg.sender] += msg.value;

        totalTransactions++;

        totalVolume += msg.value;

        lastActivity = block.timestamp;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external notFrozen {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");

        require(success, "Transfer failed");

        emit Withdraw(msg.sender, amount);
    }

    function transferETH(address receiver, uint256 amount) external notFrozen {
        require(trustedAddresses[receiver], "Not trusted");

        require(amount <= dailyLimit, "Daily limit exceeded");

        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        balances[receiver] += amount;

        totalTransactions++;

        totalVolume += amount;

        emit TransferETH(msg.sender, receiver, amount);
    }

    // =========================
    // TRUSTED ADDRESSES
    // =========================

    function addTrustedAddress(address user) external onlyOwner {
        trustedAddresses[user] = true;

        emit TrustedAddressAdded(user);
    }

    function removeTrustedAddress(address user) external onlyOwner {
        trustedAddresses[user] = false;

        emit TrustedAddressRemoved(user);
    }

    // =========================
    // FREEZE
    // =========================

    function freezeWallet() external onlyOwner {
        frozen = true;

        emit WalletFrozen(true);
    }

    function unfreezeWallet() external onlyOwner {
        frozen = false;

        emit WalletFrozen(false);
    }

    // =========================
    // NOMINEE
    // =========================

    function setNominee(address _nominee) external onlyOwner {
        nominee = _nominee;

        emit NomineeChanged(_nominee);
    }

    // =========================
    // MULTISIG
    // =========================

    function submitTransaction(address to, uint256 amount) external {
        requests.push(TransactionRequest(to, amount, 0, false));
    }

    function approveTransaction(uint256 txId) external {
        require(!approved[txId][msg.sender], "Already approved");

        approved[txId][msg.sender] = true;

        requests[txId].approvals++;
    }

    function executeTransaction(uint256 txId) external {
        TransactionRequest storage txn = requests[txId];

        require(txn.approvals >= requiredApprovals, "Not enough approvals");

        require(!txn.executed, "Already executed");

        txn.executed = true;

        payable(txn.to).transfer(txn.amount);
    }

    // =========================
    // SOCIAL RECOVERY
    // =========================

    function addGuardian(address guardian) external onlyOwner {
        guardians[guardian] = true;
    }

    function voteRecovery(address newOwner) external {
        require(guardians[msg.sender], "Not guardian");

        recoveryVotes[newOwner]++;
    }

    function recoverWallet(address newOwner) external {
        require(recoveryVotes[newOwner] >= 2, "Not enough votes");

        owner = newOwner;
    }

    // =========================
    // ERC20 SUPPORT
    // =========================

    function transferToken(address token, address to, uint256 amount) external {
        IERC20(token).transfer(to, amount);
    }

    // =========================
    // NFT SUPPORT
    // =========================

    function transferNFT(address nft, address to, uint256 tokenId) external {
        IERC721(nft).safeTransferFrom(address(this), to, tokenId);
    }

    // =========================
    // ANALYTICS
    // =========================

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
