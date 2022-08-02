// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

const sleep = (ms) => new Promise((res) => setTimeout(res, ms));

async function main() {
  const UPIToAddressContract = await hre.ethers.getContractFactory(
    "UPIToAddress"
  );
  const upiToAddress = await UPIToAddressContract.deploy();
  // await upiToAddress.deployed();
  await upiToAddress.deployTransaction.wait(6);
  console.log(`UPIToAddress address: ${upiToAddress.address}`);

  // await sleep(10000);

  await hre.run("verify:verify", {
    address: upiToAddress.address,
    constructorArgs: [],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
