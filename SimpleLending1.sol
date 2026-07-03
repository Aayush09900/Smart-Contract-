// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title SimpleLending — a beginner-friendly ETH lending contract
 * @notice This is a TEACHING version. No external libraries, no Chainlink,
 *         no OpenZeppelin — every line is here so you can read top to bottom
 *         and understand exactly what is happening. It is NOT production
 *         safe (see notes at the bottom).
 *
 * Concepts you will learn from this contract:
 *  1. Holding ETH in a contract (payable, msg.value)
 *  2. A simple ERC20-style internal token used as "the thing you borrow"
 *  3. Collateral accounting with a mapping
 *  4. LTV (loan-to-value) math in basis points
 *  5. Health Factor = how safe a loan is
 *  6. Liquidation = what happens when a loan becomes unsafe
 *  7. A separate "just deposit and withdraw" function (not collateral)
 */
contract SimpleLending {

    // ------------------------------------------------------------------
    // 1. SETUP
    // ------------------------------------------------------------------

    address public owner;

    // The "price" of ETH in USD, with 2 decimals (e.g. 200000 = $2000.00).
    // In a real protocol this comes from Chainlink. Here, for learning,
    // the owner sets it manually so you can simulate price drops yourself.
    uint256 public ethPriceUsd = 200000; // starts at $2000.00

    // Risk settings, in basis points (BPS). 10000 BPS = 100%.
    uint256 public constant BPS = 10000;
    uint256 public maxLTV = 5000;              // can borrow up to 50% of collateral value
    uint256 public liquidationThreshold = 6000; // gets liquidated above 60%
    uint256 public liquidationBonus = 1000;     // liquidator gets a 10% bonus

    // The simple internal "loan token" (like a mini stablecoin, $1 = 1 token)
    string public constant LOAN_TOKEN_NAME = "SimpleUSD";
    mapping(address => uint256) public loanTokenBalance;
    uint256 public loanTokenTotalSupply;

    // ------------------------------------------------------------------
    // 2. STORAGE — who has deposited / borrowed what
    // ------------------------------------------------------------------

    // ETH used AS COLLATERAL (backs a loan)
    mapping(address => uint256) public collateralEth;

    // ETH borrowed, valued in SimpleUSD (1 token = $1)
    mapping(address => uint256) public debtUsd;

    // ETH deposited that is NOT collateral — just a simple savings balance
    mapping(address => uint256) public savingsEth;

    // ------------------------------------------------------------------
    // 3. EVENTS — so you can see activity in the console / Remix logs
    // ------------------------------------------------------------------

    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amountUsd);
    event Repaid(address indexed user, uint256 amountUsd);
    event Liquidated(address indexed user, address indexed liquidator, uint256 debtRepaidUsd, uint256 collateralSeizedEth);
    event SavingsDeposited(address indexed user, uint256 amount);
    event SavingsWithdrawn(address indexed user, uint256 amount);
    event PriceUpdated(uint256 newPrice);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    // ------------------------------------------------------------------
    // 4. COLLATERAL — deposit ETH to be able to borrow against it
    // ------------------------------------------------------------------

    function depositCollateral() external payable {
        require(msg.value > 0, "send some ETH");
        collateralEth[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    // ------------------------------------------------------------------
    // 5. BORROW — take out a loan against your collateral
    // ------------------------------------------------------------------

    function borrow(uint256 amountUsd) external {
        require(amountUsd > 0, "amount must be > 0");
        require(collateralEth[msg.sender] > 0, "deposit collateral first");

        // How much is the user's collateral worth right now?
        uint256 collateralValueUsd = _collateralValueUsd(collateralEth[msg.sender]);

        // How much would they owe in total after this new loan?
        uint256 newDebt = debtUsd[msg.sender] + amountUsd;

        // Max you're allowed to owe = 50% of collateral value
        uint256 maxAllowedDebt = (collateralValueUsd * maxLTV) / BPS;
        require(newDebt <= maxAllowedDebt, "would exceed max LTV (50%)");

        debtUsd[msg.sender] = newDebt;

        // "Mint" the borrowed SimpleUSD tokens to the user
        loanTokenBalance[msg.sender] += amountUsd;
        loanTokenTotalSupply += amountUsd;

        emit Borrowed(msg.sender, amountUsd);
    }

    // ------------------------------------------------------------------
    // 6. REPAY — pay back your loan
    // ------------------------------------------------------------------

    function repay(uint256 amountUsd) external {
        require(debtUsd[msg.sender] > 0, "you have no debt");
        require(loanTokenBalance[msg.sender] >= amountUsd, "not enough SimpleUSD to repay");

        uint256 payAmount = amountUsd > debtUsd[msg.sender] ? debtUsd[msg.sender] : amountUsd;

        debtUsd[msg.sender] -= payAmount;
        loanTokenBalance[msg.sender] -= payAmount;
        loanTokenTotalSupply -= payAmount;

        emit Repaid(msg.sender, payAmount);
    }

    // ------------------------------------------------------------------
    // 7. WITHDRAW COLLATERAL — only if you stay safe afterwards
    // ------------------------------------------------------------------

    function withdrawCollateral(uint256 amount) external {
        require(amount > 0 && amount <= collateralEth[msg.sender], "bad amount");

        collateralEth[msg.sender] -= amount;

        // If they still have debt, make sure they're still healthy
        if (debtUsd[msg.sender] > 0) {
            require(healthFactor(msg.sender) >= 100, "would become unsafe, reduce debt first");
        }

        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    // ------------------------------------------------------------------
    // 8. SEPARATE DEPOSIT — plain ETH, NOT collateral, no loan math at all
    // ------------------------------------------------------------------

    function depositEth() external payable {
        require(msg.value > 0, "send some ETH");
        savingsEth[msg.sender] += msg.value;
        emit SavingsDeposited(msg.sender, msg.value);
    }

    function withdrawEth(uint256 amount) external {
        require(amount > 0 && amount <= savingsEth[msg.sender], "bad amount");
        savingsEth[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit SavingsWithdrawn(msg.sender, amount);
    }

    // ------------------------------------------------------------------
    // 9. HEALTH FACTOR — the most important number in lending
    // ------------------------------------------------------------------

    /**
     * @notice Returns health factor as a percentage (e.g. 120 = 120%).
     *         Above 100 = safe. Below 100 = liquidatable.
     *
     *         Formula: (collateral value * liquidation threshold) / debt
     */
    function healthFactor(address user) public view returns (uint256) {
        if (debtUsd[user] == 0) return type(uint256).max; // no debt = infinitely safe

        uint256 collateralValueUsd = _collateralValueUsd(collateralEth[user]);
        uint256 adjustedCollateral = (collateralValueUsd * liquidationThreshold) / BPS;

        // multiply by 100 so the result reads as a percentage
        return (adjustedCollateral * 100) / debtUsd[user];
    }

    function currentLTV(address user) external view returns (uint256) {
        if (collateralEth[user] == 0) return 0;
        uint256 collateralValueUsd = _collateralValueUsd(collateralEth[user]);
        return (debtUsd[user] * BPS) / collateralValueUsd;
    }

    function isLiquidatable(address user) public view returns (bool) {
        return debtUsd[user] > 0 && healthFactor(user) < 100;
    }

    // ------------------------------------------------------------------
    // 10. LIQUIDATION — what happens if collateral value drops too much
    // ------------------------------------------------------------------

    /**
     * @notice Anyone can call this on an unsafe position. The liquidator
     *         pays off the user's debt in SimpleUSD and receives the user's
     *         ETH collateral (worth the debt + a 10% bonus) in return.
     *         Whatever ETH is left over goes back to the original user.
     */
    function liquidate(address user) external {
        require(isLiquidatable(user), "position is healthy, cannot liquidate");

        uint256 debtToCover = debtUsd[user];
        require(loanTokenBalance[msg.sender] >= debtToCover, "liquidator needs enough SimpleUSD");

        // Work out how much ETH the liquidator should receive
        uint256 seizeValueUsd = debtToCover + (debtToCover * liquidationBonus) / BPS;
        uint256 collateralToSeize = (seizeValueUsd * 1e18) / ethPriceUsd; // wei

        if (collateralToSeize > collateralEth[user]) {
            collateralToSeize = collateralEth[user];
        }

        // Liquidator pays off the debt
        loanTokenBalance[msg.sender] -= debtToCover;
        loanTokenTotalSupply -= debtToCover;

        // Clear the user's debt and reduce their collateral
        debtUsd[user] = 0;
        collateralEth[user] -= collateralToSeize;

        // Send seized ETH to the liquidator
        payable(msg.sender).transfer(collateralToSeize);

        emit Liquidated(user, msg.sender, debtToCover, collateralToSeize);
    }

    // ------------------------------------------------------------------
    // 11. ADMIN — for the classroom/demo only
    // ------------------------------------------------------------------

    /// @notice In a real protocol this would be a Chainlink price feed.
    ///         Here, the owner sets it manually so students can simulate
    ///         a market crash and watch liquidation trigger.
    function setEthPrice(uint256 newPriceUsd) external onlyOwner {
        ethPriceUsd = newPriceUsd;
        emit PriceUpdated(newPriceUsd);
    }

    /// @notice Lets the owner hand out test SimpleUSD so students can try
    ///         borrowing/repaying/liquidating without a real stablecoin.
    function faucetLoanToken(address to, uint256 amount) external onlyOwner {
        loanTokenBalance[to] += amount;
        loanTokenTotalSupply += amount;
    }

    // ------------------------------------------------------------------
    // 12. INTERNAL HELPER
    // ------------------------------------------------------------------

    function _collateralValueUsd(uint256 weiAmount) internal view returns (uint256) {
        // weiAmount (1e18) * price (2 decimals) / 1e18 = USD with 2 decimals
        return (weiAmount * ethPriceUsd) / 1e18;
    }
}

/*
 * ------------------------------------------------------------------
 * WHAT'S SIMPLIFIED HERE (compared to a real protocol) — read this!
 * ------------------------------------------------------------------
 * 1. Price is set manually by the owner instead of a live Chainlink feed.
 *    -> In production this is a huge attack surface if not decentralized.
 * 2. The "loan token" is internal and mintable by the owner via faucet.
 *    -> A real protocol would use a real ERC20 with proper supply control.
 * 3. No reentrancy guard. ETH transfers use .transfer() which is safer
 *    against reentrancy than .call() but still: always think about
 *    "effects before interactions" (notice debt/collateral are updated
 *    BEFORE the ETH is sent in withdrawCollateral/liquidate).
 * 4. No interest accrues on loans over time.
 * 5. Liquidation pays the full debt in one go (no partial liquidation).
 *
 * Good next exercises for you:
 *  - Add interest that grows debtUsd[user] over time.
 *  - Swap the manual price for a Chainlink AggregatorV3Interface.
 *  - Add a reentrancy guard and explain in a comment why it's needed.
 *  - Allow partial liquidation instead of always clearing full debt.
 */
