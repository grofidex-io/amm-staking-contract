async function main() {
  const MyNFT = await ethers.getContractFactory("TreasuryBorrow");

  // Start deployment, returning a promise that resolves to a contract object
  const myNFT = await MyNFT.deploy();
  // const myNFT = await MyNFT.deploy('0x8DFcF2a8bcB5bfECD91083af72e548E6da34e411', '0x3D84c3065c667b29b05C8F685cD589CCCd70c3cC')
  await myNFT.deployed();
  console.log("Contract deployed to address:", myNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
