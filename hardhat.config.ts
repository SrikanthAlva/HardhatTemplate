import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import "hardhat-deploy"
import "hardhat-contract-sizer"
import "dotenv/config"
import "@openzeppelin/hardhat-upgrades"

const PRIVATE_KEY = process.env.PRIVATE_KEY
const TESTNET_RPC_URL = process.env.TESTNET_RPC_URL || ""
const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL || ""
const EXPLORER_API_KEY = process.env.EXPLORER_API_KEY || ""

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: "0.8.17",
            },
        ],
    },
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            chainId: 31337,
        },
        localhost: {
            chainId: 31337,
        },
        avalancheFujiTestnet: {
            url: TESTNET_RPC_URL,
            accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
            saveDeployments: true,
            chainId: 43113,
        },
        avalanche: {
            url: MAINNET_RPC_URL,
            accounts: PRIVATE_KEY !== undefined ? [PRIVATE_KEY] : [],
            saveDeployments: true,
            chainId: 43114,
        },
    },
    etherscan: {
        apiKey: {
            avalanche: EXPLORER_API_KEY,
            avalancheFujiTestnet: EXPLORER_API_KEY,
        },
    },

    gasReporter: {
        enabled: false,
        currency: "USD",
        outputFile: "gas-report.txt",
        noColors: true,
        coinmarketcap: process.env.COINMARKETCAP_API_KEY,
        token: "AVAX",
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
        player: {
            default: 1,
        },
    },
    mocha: {
        timeout: 300000,
    },
}

export default config
