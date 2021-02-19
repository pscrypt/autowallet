const { expect } = require("chai");

describe("RouterFactory", () => {
    it("Should deploy the contract correctly", async () => {
        const [deployer] = await ethers.getSigners();

        const bscswapTestnetRouterAddr = "0xd954551853F55deb4Ae31407c423e67B1621424A";

        const Factory = await hre.ethers.getContractFactory("Factory");

        const factory = await Factory.deploy(
            deployer.address,
            bscswapTestnetRouterAddr,
        );

        await factory.deployed();
        expect(await factory.offchainExecutor()).to.equal(deployer.address);
    });
});
