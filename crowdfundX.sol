// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Crowdfunding {
    /*//////////////////////////////////////////////////////////////
                            ENUMS
    //////////////////////////////////////////////////////////////*/

    enum CampaignStatus {
        Active,
        Successful,
        Failed,
        Withdrawn
    }

    /*//////////////////////////////////////////////////////////////
                        CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/

    error InvalidGoal();
    error InvalidDeadline();
    error InvalidCampaign();
    error CampaignExpired();
    error CampaignStillActive();
    error CampaignSuccessful();
    error GoalNotReached();
    error AlreadyWithdrawn();
    error ZeroAmount();
    error NotOwner();
    error TransferFailed();
    error AlreadyRefunded();
    error NothingToRefund();

    /*//////////////////////////////////////////////////////////////
                        STRUCTS
    //////////////////////////////////////////////////////////////*/

    struct Campaign {
        uint256 id;
        address payable owner;
        string title;
        string description;
        uint256 goal;
        uint256 amountCollected;
        uint256 deadline;
        uint256 totalDonors;
        CampaignStatus status;
        bool withdrawn;
    }

    /*//////////////////////////////////////////////////////////////
                        STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// Total campaigns created
    uint256 private campaignCounter;

    /// Campaign ID => Campaign
    mapping(uint256 => Campaign) private campaigns;

    /// Campaign => User => Amount Donated
    mapping(uint256 => mapping(address => uint256)) private donations;

    /// Campaign => List of Donors
    mapping(uint256 => address[]) private campaignDonors;

    /// Owner => Campaign IDs
    mapping(address => uint256[]) private ownerCampaigns;

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    event CampaignCreated(
        uint256 indexed campaignId,
        address indexed owner,
        uint256 goal,
        uint256 deadline
    );

    event Donated(
        uint256 indexed campaignId,
        address indexed donor,
        uint256 amount
    );

    event Withdrawn(
        uint256 indexed campaignId,
        address indexed owner,
        uint256 amount
    );

    event Refunded(
        uint256 indexed campaignId,
        address indexed donor,
        uint256 amount
    );

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier campaignExists(uint256 campaignId) {
        if (campaignId >= campaignCounter) revert InvalidCampaign();

        _;
    }

    modifier onlyCampaignOwner(uint256 campaignId) {
        if (msg.sender != campaigns[campaignId].owner) revert NotOwner();

        _;
    }

    modifier campaignActive(uint256 campaignId) {
        if (block.timestamp >= campaigns[campaignId].deadline)
            revert CampaignExpired();

        _;
    }

    /*//////////////////////////////////////////////////////////////
                        CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        campaignCounter = 0;
    }

    /*//////////////////////////////////////////////////////////////
                    CREATE CAMPAIGN
    //////////////////////////////////////////////////////////////*/

    function createCampaign(
        string calldata _title,
        string calldata _description,
        uint256 _goal,
        uint256 _durationInDays
    ) external {
        if (_goal == 0) revert InvalidGoal();

        if (_durationInDays == 0) revert InvalidDeadline();

        uint256 campaignId = campaignCounter;

        Campaign storage campaign = campaigns[campaignId];

        campaign.id = campaignId;
        campaign.owner = payable(msg.sender);
        campaign.title = _title;
        campaign.description = _description;
        campaign.goal = _goal;
        campaign.deadline = block.timestamp + (_durationInDays * 1 days);

        campaign.status = CampaignStatus.Active;

        ownerCampaigns[msg.sender].push(campaignId);

        emit CampaignCreated(campaignId, msg.sender, _goal, campaign.deadline);

        campaignCounter++;
    }

    /*//////////////////////////////////////////////////////////////
                        DONATE
    //////////////////////////////////////////////////////////////*/

    function donate(
        uint256 campaignId
    ) external payable campaignExists(campaignId) campaignActive(campaignId) {
        if (msg.value == 0) revert ZeroAmount();

        Campaign storage campaign = campaigns[campaignId];

        if (donations[campaignId][msg.sender] == 0) {
            campaignDonors[campaignId].push(msg.sender);

            campaign.totalDonors++;
        }

        donations[campaignId][msg.sender] += msg.value;

        campaign.amountCollected += msg.value;

        if (campaign.amountCollected >= campaign.goal) {
            campaign.status = CampaignStatus.Successful;
        }

        emit Donated(campaignId, msg.sender, msg.value);
    }

    /*//////////////////////////////////////////////////////////////
                    INTERNAL HELPERS
    //////////////////////////////////////////////////////////////*/

    function _isExpired(uint256 campaignId) internal view returns (bool) {
        return block.timestamp >= campaigns[campaignId].deadline;
    }

    function _goalReached(uint256 campaignId) internal view returns (bool) {
        return
            campaigns[campaignId].amountCollected >= campaigns[campaignId].goal;
    }

    function _campaignStatus(
        uint256 campaignId
    ) internal view returns (CampaignStatus) {
        Campaign storage campaign = campaigns[campaignId];

        if (campaign.withdrawn) return CampaignStatus.Withdrawn;

        if (campaign.amountCollected >= campaign.goal)
            return CampaignStatus.Successful;

        if (block.timestamp >= campaign.deadline) return CampaignStatus.Failed;

        return CampaignStatus.Active;
    }

    /*//////////////////////////////////////////////////////////////
                        WITHDRAW FUNDS
    //////////////////////////////////////////////////////////////*/

    function withdrawFunds(
        uint256 campaignId
    ) external campaignExists(campaignId) onlyCampaignOwner(campaignId) {
        Campaign storage campaign = campaigns[campaignId];

        if (!_isExpired(campaignId)) revert CampaignStillActive();

        if (!_goalReached(campaignId)) revert GoalNotReached();

        if (campaign.withdrawn) revert AlreadyWithdrawn();

        campaign.withdrawn = true;
        campaign.status = CampaignStatus.Withdrawn;

        uint256 amount = campaign.amountCollected;

        (bool success, ) = campaign.owner.call{value: amount}("");

        if (!success) revert TransferFailed();

        emit Withdrawn(campaignId, campaign.owner, amount);
    }

    /*//////////////////////////////////////////////////////////////
                            REFUND
    //////////////////////////////////////////////////////////////*/

    function claimRefund(uint256 campaignId)
    external
    campaignExists(campaignId)
{
    if (!_isExpired(campaignId))
        revert CampaignStillActive();

    if (_goalReached(campaignId))
        revert CampaignSuccessful();

    uint256 donated = donations[campaignId][msg.sender];

    if (donated == 0)
        revert NothingToRefund();

    donations[campaignId][msg.sender] = 0;

    (bool success, ) = payable(msg.sender).call{value: donated}("");

    if (!success) revert TransferFailed();

    emit Refunded(campaignId, msg.sender, donated);
}
    /*//////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getCampaign(
        uint256 campaignId
    ) external view campaignExists(campaignId) returns (Campaign memory) {
        return campaigns[campaignId];
    }

    function getCampaignCount() external view returns (uint256) {
        return campaignCounter;
    }

    function getDonation(
        uint256 campaignId,
        address donor
    ) external view returns (uint256) {
        return donations[campaignId][donor];
    }

    function getDonors(
        uint256 campaignId
    ) external view returns (address[] memory) {
        return campaignDonors[campaignId];
    }

    function getOwnerCampaigns(
        address owner
    ) external view returns (uint256[] memory) {
        return ownerCampaigns[owner];
    }

    function getCampaignStatus(
        uint256 campaignId
    ) external view campaignExists(campaignId) returns (CampaignStatus) {
        return _campaignStatus(campaignId);
    }

    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /*//////////////////////////////////////////////////////////////
                        RECEIVE / FALLBACK
    //////////////////////////////////////////////////////////////*/

    receive() external payable {
        revert("Use donate()");
    }

    fallback() external payable {
        revert("Invalid function");
    }
}
