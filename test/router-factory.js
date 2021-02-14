const { expect } = require("chai");

describe("RouterFactory", () => {
    it("Should deploy the contract correctly", async () => {
        const [deployer] = await ethers.getSigners();

        const uniswapKovanRouterAddr = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";

        const Factory = await hre.ethers.getContractFactory("Factory");

        const factory = await Factory.deploy(
            deployer.address,
            uniswapKovanRouterAddr,
        );

        await factory.deployed();
        expect(await factory.offchainExecutor()).to.equal(deployer.address);
    });
});
