export interface networkConfigItem {
    name?: string
    initBaseURI?: string
    initNotRevealedUri?: string
}

export interface networkConfigInfo {
    [key: number]: networkConfigItem
}

export const networkConfig: networkConfigInfo = {
    31337: {
        name: "localhost",
    },
    43113: {
        name: "avalancheFujiTestnet",
    },
    43114: {
        name: "avalanche",
    },
}

export const developmentChains = ["hardhat", "localhost"]
export const VERIFICATION_BLOCK_CONFIRMATIONS = 6
