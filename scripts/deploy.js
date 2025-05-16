const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying CreditMarketplace contract...");

  // Get the ContractFactory
  const CreditMarketplace = await ethers.getContractFactory("CreditMarketplace");
  
  // Deploy the contract
  const creditMarketplace = await CreditMarketplace.deploy();

  // Wait for deployment to finish
  await creditMarketplace.waitForDeployment();

  const address = await creditMarketplace.getAddress();
  console.log(`CreditMarketplace deployed to: ${address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
