const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("Deploying SpaceVerse contract...");

  const SpaceVerse = await hre.ethers.getContractFactory("SpaceVerse");
  const spaceVerse = await SpaceVerse.deploy();

  await spaceVerse.deployed();

  console.log(`SpaceVerse deployed to: ${spaceVerse.address}`);

  // Save contract address and ABI to the Flutter app
  const contractInfo = {
    address: spaceVerse.address,
    abi: spaceVerse.interface.format(ethers.utils.FormatTypes.json),
  };

  // This path assumes your Flutter project is in a sibling directory.
  // Adjust the path as necessary for your project structure.
  const outputDir = path.join(__dirname, "..", "..", "spaceverse", "assets", "contracts");
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  fs.writeFileSync(
    path.join(outputDir, "SpaceVerse.json"),
    JSON.stringify(contractInfo, null, 2)
  );

  console.log(`Contract info saved to ${outputDir}/SpaceVerse.json`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});