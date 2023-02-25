import { ethers, network } from "hardhat"
import { Storage } from "../typechain-types"

// yarn hardhat run scripts/interact.ts
// npx hardhat run scripts/interact.ts
// hh run scripts/interact.ts

async function sampleScript() {
    // Script Body

    const accounts = await ethers.getSigners()

    const deployer = accounts[0]
    const bidder1 = accounts[1]

    const storageContract: Storage = await ethers.getContract("Storage")
    const storeTx = await storageContract.store(12)
    await storeTx.wait(1)

    const retrieveValue = await storageContract.retrieve()
    console.log("Stored Value", retrieveValue.toString())

    // Connect with Different Account with the Smart Contract

    const bidderConnectedContract = await storageContract.connect(bidder1)
    const storeTx2 = await bidderConnectedContract.store(21)
    await storeTx2.wait(1)
    const retrieveValue2 = await bidderConnectedContract.retrieve()
    console.log("Stored Value ", retrieveValue2.toString())
}

sampleScript()
    .then(() => process.exit(0))
    .catch((error: any) => {
        console.error(error)
        process.exit(1)
    })
