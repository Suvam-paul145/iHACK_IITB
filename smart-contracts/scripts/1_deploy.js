const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  // const LendingBorrowingContract = await ethers.getContractFactory(
  //   "LendingBorrowingContract"
  // );
  // const contract = await LendingBorrowingContract.deploy(
  //   "0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846",
  //   150,
  //   500
  // );

  // await contract.waitForDeployment();

  // let contractAddress = contract.getAddress();

  // console.log("Contract deployed to:", await contractAddress);

  await hre.run("verify:verify", {
    address: "0x14e5fac02c986b117f4abf1a0fed0686c3641921",
    constructorArguments: [
      "0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846",
      150,
      500,
    ],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
