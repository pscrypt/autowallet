const { expect } = require("chai");

describe("RouterFactory", () => {
    it("Should return the new greeting once it's changed", async () => {
        const [deployer] = await ethers.getSigners();
        console.log(
            "Deploying contracts with the account:",
            deployer.address,
        );

        // We get the contract to deploy
        const RouterFactory = await hre.ethers.getContractFactory("RouterFactory");
        const routerFactory = await RouterFactory.deploy(deployer.address);

        await routerFactory.deployed();
        expect(await routerFactory.offchainExecutor()).to.equal(deployer.address);
    });
});
