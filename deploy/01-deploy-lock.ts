import { HardhatRuntimeEnvironment } from "hardhat/types"
import { DeployFunction } from "hardhat-deploy/types"
import {
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} from "../helper-hardhat-config"
import verify from "../utils/verify"
import { ethers } from "hardhat"

const deployLock: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
    const { deployments, network, getNamedAccounts } = hre
    const { deployer } = await getNamedAccounts()
    const { deploy, log } = deployments
    const chainId = network.config.chainId || 31337

    const waitBlockConfirmations = developmentChains.includes(network.name)
        ? 1
        : VERIFICATION_BLOCK_CONFIRMATIONS

    if (developmentChains.includes(network.name)) {
        // Write code Specific to Local Network Testing
    }

    const currentTimestampInSeconds = Math.round(Date.now() / 1000)
    const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60
    const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS
    const lockedAmount = ethers.utils.parseEther("1")
    const args: any[] = [unlockTime]

    const lockContract = await deploy("Lock", {
        from: deployer,
        log: true,
        args: args,
        value: lockedAmount,
        waitConfirmations: waitBlockConfirmations,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.SNOWTRACE_API_KEY
    ) {
        log("Verifying...")
        await verify(lockContract.address, args)
    }
}

export default deployLock
deployLock.tags = ["all"]
