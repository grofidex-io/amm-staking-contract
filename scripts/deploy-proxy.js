async function main() {
  const MyNFT = await ethers.getContractFactory("TransparentUpgradeableProxy");

  // Start deployment, returning a promise that resolves to a contract object
  const myNFT = await MyNFT.deploy(
    "0xD3D8E1225A55a64B0DF975b534635f9E06ba0cD3",
    "0xFeE6cF659E522315f63703f9b9D42b81cB8f72dC",
    "0x334d5a93000000000000000000000000fc00face00000000000000000000000000000000000000000000000000000000e4b8f63c111ef118587d30401e1db99f4cfbd9000000000000000000000000004012e1e304b3a125abaa51d5b7191f1fd34c8bfc00000000000000000000000049a5eae6fd71a7faef24c52899012738b70e3dba00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000005"
  );
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
