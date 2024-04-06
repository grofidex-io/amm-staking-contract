async function main() {
  const MyNFT = await ethers.getContractFactory("Vault");

  // Start deployment, returning a promise that resolves to a contract object
  const myNFT = await MyNFT.deploy(
    // "NFT_Stake",
    // "NFT_Stake",
    // "0xFC00FACE00000000000000000000000000000000",
    "0xE4B8f63C111EF118587D30401e1Db99f4CfBD900"
    // "1"
  );
  await myNFT.deployed();
  console.log("Contract deployed to address:", myNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
