import { run } from "hardhat"

const verify = async (contractAddresses: string, args: any[]) => {
    console.log("Verifying Contract...")
    try {
        await run("verify:verify", {
            address: contractAddresses,
            constructorArguments: args,
        })
    } catch (err: any) {
        if (err.message.toLowerCase().includes("already verified")) {
            console.log("Contract Already Verfied!")
        } else {
            console.log(err)
        }
    }
}

export default verify
