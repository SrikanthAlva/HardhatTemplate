import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import "hardhat-deploy"
import "hardhat-contract-sizer"
import "dotenv/config"

const FUJI_PRIVATE_KEY = process.env.FUJI_PRIVATE_KEY
const AVALANCHE_PRIVATE_KEY = process.env.AVALANCHE_PRIVATE_KEY
const FUJI_RPC_URL = process.env.FUJI_RPC_URL || ""
const SNOWTRACE_API_KEY = process.env.SNOWTRACE_API_KEY || ""
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || ""
const AVALANCHE_RPC_URL = process.env.AVALANCHE_RPC_URL || ""

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
        fuji: {
            url: FUJI_RPC_URL,
            accounts: FUJI_PRIVATE_KEY !== undefined ? [FUJI_PRIVATE_KEY] : [],
            saveDeployments: true,
            chainId: 43113,
            gasPrice: 25600000000,
        },
        avalanche: {
            url: AVALANCHE_RPC_URL,
            accounts:
                AVALANCHE_PRIVATE_KEY !== undefined
                    ? [AVALANCHE_PRIVATE_KEY]
                    : [],
            saveDeployments: true,
            chainId: 43114,
            gasPrice: 25600000000,
        },
    },
    etherscan: {
        // npx hardhat verify --network <NETWORK> <CONTRACT_ADDRESS> <CONSTRUCTOR_PARAMETERS>
        apiKey: {
            // rinkeby: ETHERSCAN_API_KEY,
            // kovan: ETHERSCAN_API_KEY,
            avalanche: SNOWTRACE_API_KEY,
            avalancheFujiTestnet: SNOWTRACE_API_KEY,
            // polygon: POLYGONSCAN_API_KEY,
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
        timeout: 300000, // 200 Seconds
    },
}

export default config
