async function main() {
  const MyNFT = await ethers.getContractFactory("TransparentUpgradeableProxy");

  // Start deployment, returning a promise that resolves to a contract object
  const myNFT = await MyNFT.deploy(
    "0x8C066205e0fd1DE47Eb082644Ef77412AD591260",
    "0xFeE6cF659E522315f63703f9b9D42b81cB8f72dC",
    "0xc0c53b8b0000000000000000000000006d3214efc611aaac0d87f760fff3fb441de389d00000000000000000000000004012e1e304b3a125abaa51d5b7191f1fd34c8bfc000000000000000000000000a91bbff2cd2797b7ec583308e2300a58c6936a59"
  );

  // const myNFT = await MyNFT.deploy('0xa5392Aa281BE85a4C72d1c6319c1F6B63Bb31c47', '0xFeE6cF659E522315f63703f9b9D42b81cB8f72dC', '0xc0c53b8b0000000000000000000000004a8ebd619d0ce9fd7ed896f455185b8067bf33980000000000000000000000004012e1e304b3a125abaa51d5b7191f1fd34c8bfc000000000000000000000000a91bbff2cd2797b7ec583308e2300a58c6936a59')
  // const myNFT = await MyNFT.deploy('0x1e31918ee78d1F6294Bc49D44d749e5b0F94e7Ff', '0x3D84c3065c667b29b05C8F685cD589CCCd70c3cC')
  await myNFT.deployed();
  console.log("Contract deployed to address:", myNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
