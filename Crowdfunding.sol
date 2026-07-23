import { expect } from "chai";
import { network } from "hardhat";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe("CrowdFundX", function () {

    async function deployFixture() {

        const connection = await network.create();
        const { ethers } = connection;

        const [
            owner,
            user1,
            user2,
            user3
        ] = await ethers.getSigners();

        const Crowdfunding =
            await ethers.getContractFactory("Crowdfunding");

        const crowdfunding =
            await Crowdfunding.deploy();

        await crowdfunding.waitForDeployment();

        return {
            crowdfunding,
            owner,
            user1,
            user2,
            user3,
            ethers
        };
    }    

     describe("Deployment", function () {

        it("Should deploy successfully", async function () {

            const {
                crowdfunding
            } = await deployFixture();

            expect(
                await crowdfunding.getAddress()
            ).to.not.equal("");

        });

        it("Campaign count should start at zero", async function () {

            const {
                crowdfunding
            } = await deployFixture();

            expect(
                await crowdfunding.getCampaignCount()
            ).to.equal(0);

        });

        it("Contract balance should initially be zero", async function () {

            const {
                crowdfunding
            } = await deployFixture();

            expect(
                await crowdfunding.contractBalance()
            ).to.equal(0);

        });

    });
        describe("Create Campaign", function () {

        it("Should create a campaign", async function () {

            const {
                crowdfunding,
                owner,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Medical Fund",
                "Hospital Expenses",
                ethers.parseEther("5"),
                30
            );

            expect(
                await crowdfunding.getCampaignCount()
            ).to.equal(1);

            const campaign =
                await crowdfunding.getCampaign(0);

            expect(campaign.owner)
                .to.equal(owner.address);

            expect(campaign.title)
                .to.equal("Medical Fund");

            expect(campaign.description)
                .to.equal("Hospital Expenses");

            expect(campaign.goal)
                .to.equal(
                    ethers.parseEther("5")
                );

        });

        it("Should assign campaign IDs correctly", async function () {

            const {
                crowdfunding,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Campaign 1",
                "Description",
                ethers.parseEther("1"),
                30
            );

            await crowdfunding.createCampaign(
                "Campaign 2",
                "Description",
                ethers.parseEther("2"),
                30
            );

            const first =
                await crowdfunding.getCampaign(0);

            const second =
                await crowdfunding.getCampaign(1);

            expect(first.id).to.equal(0);
            expect(second.id).to.equal(1);

        });

        it("Should emit CampaignCreated event", async function () {

            const {
                crowdfunding,
                owner,
                ethers
            } = await deployFixture();

            await expect(

                crowdfunding.createCampaign(
                    "Education",
                    "Help Students",
                    ethers.parseEther("10"),
                    15
                )

            )
                .to.emit(crowdfunding, "CampaignCreated")
                .withArgs(
                    0,
                    owner.address,
                    "Education",
                    ethers.parseEther("10")
                );

        });

        it("Should reject zero goal", async function () {

            const {
                crowdfunding
            } = await deployFixture();

            await expect(

                crowdfunding.createCampaign(
                    "Test",
                    "Test",
                    0,
                    10
                )

            ).to.be.revertedWithCustomError(
                crowdfunding,
                "InvalidGoal"
            );

        });

        it("Should reject zero duration", async function () {

            const {
                crowdfunding,
                ethers
            } = await deployFixture();

            await expect(

                crowdfunding.createCampaign(
                    "Medical",
                    "Emergency",
                    ethers.parseEther("2"),
                    0
                )

            ).to.be.revertedWithCustomError(
                crowdfunding,
                "InvalidDeadline"
            );

        });

    });
        describe("View Functions", function () {

        beforeEach(async function () {

            const {
                crowdfunding,
                ethers
            } = await deployFixture();

            this.crowdfunding = crowdfunding;
            this.ethers = ethers;

            await crowdfunding.createCampaign(
                "Project A",
                "Description A",
                ethers.parseEther("2"),
                30
            );

            await crowdfunding.createCampaign(
                "Project B",
                "Description B",
                ethers.parseEther("4"),
                60
            );

        });

        it("Should return campaign details", async function () {

            const campaign =
                await this.crowdfunding.getCampaign(0);

            expect(campaign.id).to.equal(0);
            expect(campaign.title).to.equal("Project A");
            expect(campaign.description).to.equal("Description A");

        });

        it("Should return owner campaigns", async function () {

            const {
                owner
            } = await deployFixture();

            const campaigns =
                await this.crowdfunding.getOwnerCampaigns(
                    owner.address
                );

            expect(campaigns.length).to.equal(2);

        });

        it("Should return campaign status", async function () {

            expect(
                await this.crowdfunding.getCampaignStatus(0)
            ).to.equal(0);

        });

        it("Should return zero donation initially", async function () {

            const {
                user1
            } = await deployFixture();

            expect(
                await this.crowdfunding.getDonation(
                    0,
                    user1.address
                )
            ).to.equal(0);

        });

        it("Should return donors array", async function () {

            const donors =
                await this.crowdfunding.getDonors(0);

            expect(donors.length).to.equal(0);

        });

    });
        describe("Donation", function () {

        it("Should accept donation", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Medical",
                "Help",
                ethers.parseEther("5"),
                30
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("1")
                }
            );

            expect(
                await crowdfunding.getDonation(
                    0,
                    user1.address
                )
            ).to.equal(
                ethers.parseEther("1")
            );

        });

        it("Should update campaign balance", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "School",
                "Education",
                ethers.parseEther("5"),
                30
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("2")
                }
            );

            const campaign =
                await crowdfunding.getCampaign(0);

            expect(
                campaign.amountCollected
            ).to.equal(
                ethers.parseEther("2")
            );

        });

        it("Should update contract balance", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Animal",
                "Shelter",
                ethers.parseEther("10"),
                30
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("3")
                }
            );

            expect(
                await crowdfunding.contractBalance()
            ).to.equal(
                ethers.parseEther("3")
            );

        });

        it("Should count unique donors", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Medical",
                "Help",
                ethers.parseEther("5"),
                30
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("1")
                }
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("2")
                }
            );

            const campaign =
                await crowdfunding.getCampaign(0);

            expect(campaign.totalDonors)
                .to.equal(1);

        });

        it("Should accept multiple donors", async function () {

            const {
                crowdfunding,
                user1,
                user2,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Hospital",
                "Emergency",
                ethers.parseEther("10"),
                30
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("2")
                }
            );

            await crowdfunding.connect(user2).donate(
                0,
                {
                    value: ethers.parseEther("3")
                }
            );

            const campaign =
                await crowdfunding.getCampaign(0);

            expect(campaign.totalDonors)
                .to.equal(2);

            expect(campaign.amountCollected)
                .to.equal(
                    ethers.parseEther("5")
                );

        });

        it("Should emit Donated event", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Fund",
                "Fund",
                ethers.parseEther("5"),
                30
            );

            await expect(

                crowdfunding.connect(user1).donate(
                    0,
                    {
                        value: ethers.parseEther("1")
                    }
                )

            )
            .to.emit(crowdfunding, "Donated")
            .withArgs(
                0,
                user1.address,
                ethers.parseEther("1")
            );

        });

        it("Should reject zero donation", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Fund",
                "Help",
                ethers.parseEther("5"),
                30
            );

            await expect(

                crowdfunding.connect(user1).donate(
                    0,
                    {
                        value: 0
                    }
                )

            ).to.be.revertedWithCustomError(
                crowdfunding,
                "ZeroAmount"
            );

        });

        it("Should reject invalid campaign", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await expect(

                crowdfunding.connect(user1).donate(
                    99,
                    {
                        value: ethers.parseEther("1")
                    }
                )

            ).to.be.revertedWithCustomError(
                crowdfunding,
                "InvalidCampaign"
            );

        });

        it("Should mark campaign successful", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Goal",
                "Reach Goal",
                ethers.parseEther("5"),
                30
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("5")
                }
            );

            expect(
                await crowdfunding.getCampaignStatus(0)
            ).to.equal(1);

        });

    });
        describe("Withdraw", function () {

        it("Owner should withdraw successfully", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Medical",
                "Emergency",
                ethers.parseEther("5"),
                1
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("5")
                }
            );

            await time.increase(
                2 * 24 * 60 * 60
            );

            await expect(

                crowdfunding.withdrawFunds(0)

            ).to.emit(
                crowdfunding,
                "Withdrawn"
            );

        });

        it("Non-owner cannot withdraw", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Fund",
                "Desc",
                ethers.parseEther("5"),
                1
            );

            await time.increase(
                2 * 24 * 60 * 60
            );

            await expect(

                crowdfunding
                    .connect(user1)
                    .withdrawFunds(0)

            ).to.be.revertedWithCustomError(
                crowdfunding,
                "NotOwner"
            );

        });

        it("Cannot withdraw before deadline", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Fund",
                "Desc",
                ethers.parseEther("5"),
                10
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("5")
                }
            );

            await expect(

                crowdfunding.withdrawFunds(0)

            ).to.be.revertedWithCustomError(
                crowdfunding,
                "CampaignStillActive"
            );

        });

        it("Cannot withdraw if goal not reached", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Fund",
                "Desc",
                ethers.parseEther("10"),
                1
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("2")
                }
            );

            await time.increase(
                2 * 24 * 60 * 60
            );

            await expect(

                crowdfunding.withdrawFunds(0)

            ).to.be.revertedWithCustomError(
                crowdfunding,
                "GoalNotReached"
            );

        });

        it("Cannot withdraw twice", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Fund",
                "Desc",
                ethers.parseEther("5"),
                1
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("5")
                }
            );

            await time.increase(
                2 * 24 * 60 * 60
            );

            await crowdfunding.withdrawFunds(0);

            await expect(

                crowdfunding.withdrawFunds(0)

            ).to.be.revertedWithCustomError(
                crowdfunding,
                "AlreadyWithdrawn"
            );

        });

    });
        describe("Refund", function () {

        it("Contributor should receive refund", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Refund Campaign",
                "Testing refund",
                ethers.parseEther("10"),
                1
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("2")
                }
            );

            await time.increase(
                2 * 24 * 60 * 60
            );

            await expect(

                crowdfunding
                    .connect(user1)
                    .claimRefund(0)

            )
            .to.emit(crowdfunding, "Refunded")
            .withArgs(
                0,
                user1.address,
                ethers.parseEther("2")
            );

        });

        it("Donation should become zero after refund", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Refund",
                "Refund Test",
                ethers.parseEther("10"),
                1
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("3")
                }
            );

            await time.increase(
                2 * 24 * 60 * 60
            );

            await crowdfunding
                .connect(user1)
                .claimRefund(0);

            expect(

                await crowdfunding.getDonation(
                    0,
                    user1.address
                )

            ).to.equal(0);

        });

        it("Cannot refund before deadline", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Refund",
                "Case",
                ethers.parseEther("10"),
                10
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("2")
                }
            );

            await expect(

                crowdfunding
                    .connect(user1)
                    .claimRefund(0)

            ).to.be.revertedWithCustomError(
                crowdfunding,
                "CampaignStillActive"
            );

        });

        it("Cannot refund successful campaign", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Success",
                "Goal reached",
                ethers.parseEther("5"),
                1
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("5")
                }
            );

            await time.increase(
                2 * 24 * 60 * 60
            );

            await expect(

                crowdfunding
                    .connect(user1)
                    .claimRefund(0)

            ).to.be.revertedWithCustomError(
                crowdfunding,
                "CampaignSuccessful"
            );

        });

        it("Cannot refund without donation", async function () {

            const {
                crowdfunding,
                user1,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Refund",
                "Case",
                ethers.parseEther("10"),
                1
            );

            await time.increase(
                2 * 24 * 60 * 60
            );

            await expect(

                crowdfunding
                    .connect(user1)
                    .claimRefund(0)

            ).to.be.revertedWithCustomError(crowdfunding,"NothingToRefund" );

        });

        it("Second refund should fail", async function () {

            const { crowdfunding, user1,ethers} = await deployFixture();

            await crowdfunding.createCampaign("Refund","Multiple refund",ethers.parseEther("10"),1);
            await crowdfunding.connect(user1).donate(0,{value: ethers.parseEther("2")}
            );
            await time.increase(2 * 24 * 60 * 60);
            await crowdfunding
                .connect(user1)
                .claimRefund(0);

            await expect(

                crowdfunding
                    .connect(user1)
                    .claimRefund(0)

            ).to.be.revertedWithCustomError(
                crowdfunding,
                "NothingToRefund"
            );

        });

        it("Multiple users should receive independent refunds", async function () {

            const {
                crowdfunding,
                user1,
                user2,
                ethers
            } = await deployFixture();

            await crowdfunding.createCampaign(
                "Community",
                "Independent Refund",
                ethers.parseEther("20"),
                1
            );

            await crowdfunding.connect(user1).donate(
                0,
                {
                    value: ethers.parseEther("2")
                }
            );

            await crowdfunding.connect(user2).donate(
                0,
                {
                    value: ethers.parseEther("3")
                }
            );

            await time.increase(
                2 * 24 * 60 * 60
            );

            await crowdfunding
                .connect(user1)
                .claimRefund(0);

            await crowdfunding
                .connect(user2)
                .claimRefund(0);

            expect(
                await crowdfunding.getDonation(
                    0,
                    user1.address
                )
            ).to.equal(0);

            expect(
                await crowdfunding.getDonation(
                    0,
                    user2.address
                )
            ).to.equal(0);

        });

    });

