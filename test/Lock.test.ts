import { expect } from "chai"
import { ethers, network } from "hardhat"
import { developmentChains } from "../helper-hardhat-config"
import { time } from "@nomicfoundation/hardhat-network-helpers"
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs"

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Lock", () => {
          let lock: any,
              unlockTime: any,
              lockedAmount: any,
              owner: any,
              otherAccount: any

          beforeEach(async () => {
              const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60
              const ONE_GWEI = 1_000_000_000

              lockedAmount = ONE_GWEI
              unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS

              // Contracts are deployed using the first signer/account by default
              ;[owner, otherAccount] = await ethers.getSigners()

              const Lock = await ethers.getContractFactory("Lock")
              lock = await Lock.deploy(unlockTime, { value: lockedAmount })
          })

          describe("Deployment", function () {
              it("Should set the right unlockTime", async function () {
                  expect(await lock.unlockTime()).to.equal(unlockTime)
              })

              it("Should set the right owner", async function () {
                  expect(await lock.owner()).to.equal(owner.address)
              })

              it("Should receive and store the funds to lock", async function () {
                  expect(
                      await ethers.provider.getBalance(lock.address)
                  ).to.equal(lockedAmount)
              })

              it("Should fail if the unlockTime is not in the future", async function () {
                  // We don't use the fixture here because we want a different deployment
                  const latestTime = await time.latest()
                  const Lock = await ethers.getContractFactory("Lock")
                  await expect(
                      Lock.deploy(latestTime, { value: 1 })
                  ).to.be.revertedWith("Unlock time should be in the future")
              })
          })

          describe("Withdrawals", function () {
              describe("Validations", function () {
                  it("Should revert with the right error if called too soon", async function () {
                      await expect(lock.withdraw()).to.be.revertedWith(
                          "You can't withdraw yet"
                      )
                  })

                  it("Should revert with the right error if called from another account", async function () {
                      // We can increase the time in Hardhat Network
                      await time.increaseTo(unlockTime)

                      // We use lock.connect() to send a transaction from another account
                      await expect(
                          lock.connect(otherAccount).withdraw()
                      ).to.be.revertedWith("You aren't the owner")
                  })

                  it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
                      // Transactions are sent using the first signer by default
                      await time.increaseTo(unlockTime)

                      await expect(lock.withdraw()).not.to.be.reverted
                  })
              })

              describe("Events", function () {
                  it("Should emit an event on withdrawals", async function () {
                      await time.increaseTo(unlockTime)

                      await expect(lock.withdraw())
                          .to.emit(lock, "Withdrawal")
                          .withArgs(lockedAmount, anyValue) // We accept any value as `when` arg
                  })
              })

              describe("Transfers", function () {
                  it("Should transfer the funds to the owner", async function () {
                      await time.increaseTo(unlockTime)

                      await expect(lock.withdraw()).to.changeEtherBalances(
                          [owner, lock],
                          [lockedAmount, -lockedAmount]
                      )
                  })
              })
          })
      })
