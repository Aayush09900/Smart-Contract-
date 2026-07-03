// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title ETHLendingPool
 * @notice Users deposit ETH as collateral and borrow a whitelisted ERC20 stablecoin
 *         against it. Borrow limit, liquidation threshold and liquidation logic are
 *         all driven by a live Chainlink ETH/USD price feed.
 *
 * @dev Design notes (senior-dev rationale):
 *  - Solidity has no background execution. "Continuous monitoring" is implemented as:
 *      1) Inline health checks on every state-changing call (borrow/withdraw).
 *      2) A permissionless `liquidate()` anyone (bot or human) can call on an unhealthy
 *         position — this is how Aave/Compound actually do it.
 *      3) A bounded `checkPositions()` batch helper meant to be called by an off-chain
 *         keeper (Chainlink Automation / Gelato) on a loop, which only *reads* state and
 *         returns which users are liquidatable, so the keeper can then call liquidate()
 *         on just those users. Looping over an unbounded user array inside a single
 *         transaction is a classic gas-DoS bug, so it is deliberately NOT done here.
 *  - All money math is in basis points (BPS) to avoid floating point.
 *  - Collateral and debt prices/amounts are normalized to 18 decimals internally and
 *    the borrowed asset is assumed to be a USD-pegged stablecoin for simplicity. Swap
 *    in a different oracle if you support non-USD-pegged debt assets.
 */
contract ETHLendingPool is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    // ---------------------------------------------------------------------
    // Constants / risk parameters
    // ---------------------------------------------------------------------

    uint256 public constant BPS = 10_000;

    /// @notice Max amount a user can borrow relative to collateral value at open time.
    uint256 public maxLTV = 7_000; // 70%

    /// @notice Threshold at which a position becomes liquidatable.
    uint256 public liquidationThreshold = 7_500; // 75%

    /// @notice Bonus paid to liquidators, taken out of the borrower's seized collateral.
    uint256 public liquidationBonus = 1_000; // 10%

    /// @notice Health factor is expressed *1e18. Below 1e18 == liquidatable.
    uint256 public constant HEALTH_FACTOR_PRECISION = 1e18;

    /// @notice Max age of a price feed answer before it's considered stale.
    uint256 public maxPriceAge = 1 hours;

    // ---------------------------------------------------------------------
    // State
    // ---------------------------------------------------------------------

    IERC20 public immutable debtToken;            // e.g. USDC, 6 decimals
    uint8 public immutable debtTokenDecimals;
    AggregatorV3Interface public priceFeed;        // ETH/USD

    struct Position {
        uint256 collateralEth;   // wei
        uint256 debtAmount;      // in debtToken's native decimals
    }

    mapping(address => Position) public positions;
    address[] public borrowers;            // tracked for keeper batch scanning
    mapping(address => bool) private _isTrackedBorrower;

    uint256 public totalCollateralEth;
    uint256 public totalDebt;

    /// @notice Plain ETH deposits NOT used as collateral, NOT counted in health
    ///         factor / LTV / liquidation math. Purely a separate balance a user
    ///         can deposit and withdraw freely at any time.
    mapping(address => uint256) public savingsBalance;
    uint256 public totalSavingsEth;

    // ---------------------------------------------------------------------
    // Events
    // ---------------------------------------------------------------------

    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event SavingsDeposited(address indexed user, uint256 amount);
    event SavingsWithdrawn(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event Liquidated(
        address indexed user,
        address indexed liquidator,
        uint256 debtRepaid,
        uint256 collateralSeized,
        uint256 bonusPaid
    );
    event RiskParamsUpdated(uint256 maxLTV, uint256 liquidationThreshold, uint256 liquidationBonus);
    event PriceFeedUpdated(address feed);

    // ---------------------------------------------------------------------
    // Constructor
    // ---------------------------------------------------------------------

    constructor(address _debtToken, address _priceFeed, address initialOwner)
        Ownable(initialOwner)
    {
        require(_debtToken != address(0) && _priceFeed != address(0), "zero address");
        debtToken = IERC20(_debtToken);
        debtTokenDecimals = IERC20Metadata(_debtToken).decimals();
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // ---------------------------------------------------------------------
    // Core user actions
    // ---------------------------------------------------------------------

    /// @notice Deposit ETH as collateral.
    function depositCollateral() external payable nonReentrant {
        require(msg.value > 0, "zero deposit");

        Position storage pos = positions[msg.sender];
        pos.collateralEth += msg.value;
        totalCollateralEth += msg.value;

        _trackBorrower(msg.sender);

        emit CollateralDeposited(msg.sender, msg.value);
    }

    /**
     * @notice Deposit plain ETH that is NOT collateral — not used in LTV,
     *         health factor, or liquidation calculations at all. Use this for
     *         a simple "wallet inside the contract" / savings-style balance.
     */
    function depositEth() external payable nonReentrant {
        require(msg.value > 0, "zero deposit");
        savingsBalance[msg.sender] += msg.value;
        totalSavingsEth += msg.value;
        emit SavingsDeposited(msg.sender, msg.value);
    }

    /// @notice Withdraw from the non-collateral savings balance. No health
    ///         factor check needed since this ETH was never borrowed against.
    function withdrawEth(uint256 amount) external nonReentrant {
        require(amount > 0 && amount <= savingsBalance[msg.sender], "bad amount");

        savingsBalance[msg.sender] -= amount;
        totalSavingsEth -= amount;

        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "ETH transfer failed");

        emit SavingsWithdrawn(msg.sender, amount);
    }

    /// @notice Borrow `amount` of debtToken against deposited ETH collateral.
    function borrow(uint256 amount) external nonReentrant {
        require(amount > 0, "zero borrow");

        Position storage pos = positions[msg.sender];
        require(pos.collateralEth > 0, "no collateral");

        pos.debtAmount += amount;
        totalDebt += amount;

        // LTV check at the moment of borrowing
        uint256 collateralValueUsd = _collateralValueUsd(pos.collateralEth);
        uint256 debtValueUsd = _toUsd18(pos.debtAmount);
        require(
            debtValueUsd <= (collateralValueUsd * maxLTV) / BPS,
            "exceeds max LTV"
        );

        // Defensive: also confirm resulting health factor is safe
        require(_healthFactor(pos) >= HEALTH_FACTOR_PRECISION, "unsafe health factor");

        debtToken.safeTransfer(msg.sender, amount);
        emit Borrowed(msg.sender, amount);
    }

    /// @notice Repay outstanding debt. Pass type(uint256).max to repay in full.
    function repay(uint256 amount) external nonReentrant {
        Position storage pos = positions[msg.sender];
        require(pos.debtAmount > 0, "no debt");

        uint256 payAmount = amount > pos.debtAmount ? pos.debtAmount : amount;
        require(payAmount > 0, "zero repay");

        pos.debtAmount -= payAmount;
        totalDebt -= payAmount;

        debtToken.safeTransferFrom(msg.sender, address(this), payAmount);
        emit Repaid(msg.sender, payAmount);
    }

    /// @notice Withdraw ETH collateral, as long as remaining position stays healthy.
    function withdraw(uint256 amount) external nonReentrant {
        Position storage pos = positions[msg.sender];
        require(amount > 0 && amount <= pos.collateralEth, "bad amount");

        pos.collateralEth -= amount;
        totalCollateralEth -= amount;

        if (pos.debtAmount > 0) {
            require(_healthFactor(pos) >= HEALTH_FACTOR_PRECISION, "would become unsafe");
        }

        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "ETH transfer failed");

        emit CollateralWithdrawn(msg.sender, amount);
    }

    // ---------------------------------------------------------------------
    // Liquidation
    // ---------------------------------------------------------------------

    /**
     * @notice Liquidate an unhealthy position. Caller (liquidator) repays the
     *         borrower's debt in debtToken and receives seized ETH collateral
     *         equal in USD value to the debt repaid plus the liquidation bonus.
     *         Any collateral left over after covering debt + bonus is returned
     *         to the original borrower (not burned, not kept by protocol).
     * @param user The borrower being liquidated.
     * @param repayAmount How much debt the liquidator wants to repay (can be partial).
     */
    function liquidate(address user, uint256 repayAmount) external nonReentrant {
        Position storage pos = positions[user];
        require(pos.debtAmount > 0, "no debt");
        require(_healthFactor(pos) < HEALTH_FACTOR_PRECISION, "position healthy");

        uint256 actualRepay = repayAmount > pos.debtAmount ? pos.debtAmount : repayAmount;
        require(actualRepay > 0, "zero repay");

        // USD value of debt being repaid
        uint256 repayValueUsd = _toUsd18(actualRepay);

        // Collateral seized = debt value + liquidation bonus, converted to ETH
        uint256 seizeValueUsd = repayValueUsd + (repayValueUsd * liquidationBonus) / BPS;
        uint256 ethPrice = _ethPriceUsd18();
        uint256 collateralToSeize = (seizeValueUsd * 1e18) / ethPrice; // wei

        if (collateralToSeize > pos.collateralEth) {
            collateralToSeize = pos.collateralEth; // can't seize more than they have
        }

        // Effects
        pos.debtAmount -= actualRepay;
        totalDebt -= actualRepay;
        pos.collateralEth -= collateralToSeize;
        totalCollateralEth -= collateralToSeize;

        // Interactions
        debtToken.safeTransferFrom(msg.sender, address(this), actualRepay);

        uint256 bonusEth = collateralToSeize > 0
            ? (collateralToSeize * liquidationBonus) / (BPS + liquidationBonus)
            : 0;

        (bool ok1, ) = msg.sender.call{value: collateralToSeize}("");
        require(ok1, "collateral transfer failed");

        emit Liquidated(user, msg.sender, actualRepay, collateralToSeize, bonusEth);
    }

    // ---------------------------------------------------------------------
    // Health factor / LTV views
    // ---------------------------------------------------------------------

    /// @notice Health factor *1e18. >= 1e18 is safe, < 1e18 is liquidatable.
    function getHealthFactor(address user) external view returns (uint256) {
        return _healthFactor(positions[user]);
    }

    /// @notice Current LTV of a position in BPS (debt/collateral value).
    function getCurrentLTV(address user) external view returns (uint256) {
        Position storage pos = positions[user];
        if (pos.collateralEth == 0) return 0;
        uint256 collateralValueUsd = _collateralValueUsd(pos.collateralEth);
        if (collateralValueUsd == 0) return type(uint256).max;
        uint256 debtValueUsd = _toUsd18(pos.debtAmount);
        return (debtValueUsd * BPS) / collateralValueUsd;
    }

    /// @notice Max additional amount a user can still borrow right now.
    function getAvailableBorrow(address user) external view returns (uint256) {
        Position storage pos = positions[user];
        uint256 collateralValueUsd = _collateralValueUsd(pos.collateralEth);
        uint256 maxDebtUsd = (collateralValueUsd * maxLTV) / BPS;
        uint256 currentDebtUsd = _toUsd18(pos.debtAmount);
        if (currentDebtUsd >= maxDebtUsd) return 0;
        uint256 availableUsd = maxDebtUsd - currentDebtUsd;
        return _fromUsd18(availableUsd);
    }

    function isLiquidatable(address user) external view returns (bool) {
        Position storage pos = positions[user];
        if (pos.debtAmount == 0) return false;
        return _healthFactor(pos) < HEALTH_FACTOR_PRECISION;
    }

    /**
     * @notice Bounded batch scan for an off-chain keeper to call on a loop
     *         (e.g. every block / every N minutes via Chainlink Automation).
     *         Returns which addresses in [offset, offset+limit) are currently
     *         liquidatable, so the keeper can fire `liquidate()` only on those.
     */
    function checkPositions(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory liquidatableUsers, uint256 nextOffset)
    {
        uint256 end = offset + limit;
        if (end > borrowers.length) end = borrowers.length;

        address[] memory temp = new address[](end - offset);
        uint256 count;

        for (uint256 i = offset; i < end; i++) {
            address user = borrowers[i];
            Position storage pos = positions[user];
            if (pos.debtAmount > 0 && _healthFactor(pos) < HEALTH_FACTOR_PRECISION) {
                temp[count++] = user;
            }
        }

        liquidatableUsers = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            liquidatableUsers[i] = temp[i];
        }
        nextOffset = end >= borrowers.length ? 0 : end;
    }

    function borrowersCount() external view returns (uint256) {
        return borrowers.length;
    }

    // ---------------------------------------------------------------------
    // Internal pricing / math
    // ---------------------------------------------------------------------

    function _ethPriceUsd18() internal view returns (uint256) {
        (, int256 answer, , uint256 updatedAt, ) = priceFeed.latestRoundData();
        require(answer > 0, "invalid price");
        require(block.timestamp - updatedAt <= maxPriceAge, "stale price");

        uint8 feedDecimals = priceFeed.decimals();
        return _scaleTo18(uint256(answer), feedDecimals);
    }

    function _collateralValueUsd(uint256 collateralEth) internal view returns (uint256) {
        uint256 ethPrice = _ethPriceUsd18(); // USD per ETH, 1e18
        return (collateralEth * ethPrice) / 1e18; // 1e18-scaled USD
    }

    function _healthFactor(Position storage pos) internal view returns (uint256) {
        if (pos.debtAmount == 0) return type(uint256).max;
        uint256 collateralValueUsd = _collateralValueUsd(pos.collateralEth);
        uint256 adjustedCollateral = (collateralValueUsd * liquidationThreshold) / BPS;
        uint256 debtValueUsd = _toUsd18(pos.debtAmount);
        if (debtValueUsd == 0) return type(uint256).max;
        return (adjustedCollateral * HEALTH_FACTOR_PRECISION) / debtValueUsd;
    }

    function _toUsd18(uint256 debtAmount) internal view returns (uint256) {
        return _scaleTo18(debtAmount, debtTokenDecimals);
    }

    function _fromUsd18(uint256 amount18) internal view returns (uint256) {
        if (debtTokenDecimals == 18) return amount18;
        if (debtTokenDecimals < 18) return amount18 / (10 ** (18 - debtTokenDecimals));
        return amount18 * (10 ** (debtTokenDecimals - 18));
    }

    function _scaleTo18(uint256 amount, uint8 decimals) internal pure returns (uint256) {
        if (decimals == 18) return amount;
        if (decimals < 18) return amount * (10 ** (18 - decimals));
        return amount / (10 ** (decimals - 18));
    }

    function _trackBorrower(address user) internal {
        if (!_isTrackedBorrower[user]) {
            _isTrackedBorrower[user] = true;
            borrowers.push(user);
        }
    }

    // ---------------------------------------------------------------------
    // Admin
    // ---------------------------------------------------------------------

    function setRiskParams(uint256 _maxLTV, uint256 _liquidationThreshold, uint256 _liquidationBonus)
        external
        onlyOwner
    {
        require(_maxLTV < _liquidationThreshold, "LTV must be < threshold");
        require(_liquidationThreshold < BPS, "threshold must be < 100%");
        maxLTV = _maxLTV;
        liquidationThreshold = _liquidationThreshold;
        liquidationBonus = _liquidationBonus;
        emit RiskParamsUpdated(_maxLTV, _liquidationThreshold, _liquidationBonus);
    }

    function setPriceFeed(address _feed) external onlyOwner {
        require(_feed != address(0), "zero address");
        priceFeed = AggregatorV3Interface(_feed);
        emit PriceFeedUpdated(_feed);
    }

    function setMaxPriceAge(uint256 _seconds) external onlyOwner {
        maxPriceAge = _seconds;
    }

    /// @notice Protocol-owned reserve withdrawal (e.g. fees), not user funds.
    function rescueDebtToken(uint256 amount, address to) external onlyOwner {
        uint256 reserve = debtToken.balanceOf(address(this));
        uint256 obligated = totalDebt > 0 ? 0 : 0; // placeholder for future reserve accounting
        require(amount <= reserve, "exceeds reserve");
        debtToken.safeTransfer(to, amount);
    }

    receive() external payable {
        revert("use depositCollateral()");
    }
}

interface IERC20Metadata {
    function decimals() external view returns (uint8);
}
