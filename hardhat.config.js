require("@nomiclabs/hardhat-waffle");

module.exports = {
    defaultNetwork: "localhost",
    networks: {
        localhost: {
            url: "http://127.0.0.1:8545",
            loggingEnabled: true,
        },
        hardhat: {
        },
        rinkeby: {
            url: "https://rinkeby.infura.io/v3/123abc123abc123abc123abc123abcde",
            accounts: []
        }
    },
    solidity: {
        version: "0.7.6",
        settings: {
            optimizer: {
                enabled: false,
                runs: 200
            }
        }
    },
    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts"
    },
    mocha: {
        timeout: 20000
    }
}
