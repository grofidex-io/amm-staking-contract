require("dotenv").config();
const path = require("path");
const API_URL = process.env.NEL_URL;
const PUBLIC_KEY = "0xe4b8f63c111ef118587d30401e1db99f4cfbd900";
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(API_URL);
// const inboxPath = path.resolve(__dirname, 'contracts','MyNFT.json', 'MyNFT.json');
const contract = require("../artifacts/contracts/GroFiStakingManager.sol/GroFiStakingManager.json");
const contractAddress = "0x64f372AA1DAc6fa41527DecEc2bC6Fe360e3DEf4";
const nftContract = new web3.eth.Contract(contract.abi, contractAddress);
async function stake() {
  const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, "latest"); //get latest nonce
  //the transaction
  const tx = {
    value: "1000000000000",
    from: PUBLIC_KEY,
    to: contractAddress,
    nonce: nonce,
    gas: 1500000,
    data: nftContract.methods
      .stake("0x0000000000000000000000000000000000000000")
      .encodeABI(),
  };

  const signPromise = await web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);
  await web3.eth.sendSignedTransaction(signPromise.rawTransaction);
}

async function snapshot() {
  const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, "latest"); //get latest nonce
  //the transaction
  const tx = {
    from: PUBLIC_KEY,
    to: contractAddress,
    nonce: nonce,
    gas: 200000,
    data: nftContract.methods.snapshot().encodeABI(),
  };

  const signPromise = await web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);
  await web3.eth.sendSignedTransaction(signPromise.rawTransaction);
}

async function run() {
  for (let i = 0; i <= 500; i++) {
    await stake();
    await snapshot();
  }
}

run();
