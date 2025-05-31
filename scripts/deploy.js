const hre = require("hardhat");

async function main() {
  console.log("📦 Deploying CreditMarketplace contract...");

  // Get the contract factory
  const CreditMarketplaceFactory = await hre.ethers.getContractFactory("CreditMarketplace");

  // Deploy the contract
  const creditMarketplace = await CreditMarketplaceFactory.deploy();

  // Wait for the deployment to complete
  await creditMarketplace.deployed();

  // Output the deployed contract address
  console.log(`✅ CreditMarketplace deployed to: ${creditMarketplace.address}`);
}

// Run the deployment script
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
