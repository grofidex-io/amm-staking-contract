require("dotenv").config();
const path = require("path");
const API_URL = process.env.NEL_URL;
const PUBLIC_KEY = "0xe4b8f63c111ef118587d30401e1db99f4cfbd900";
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(API_URL);
// const inboxPath = path.resolve(__dirname, 'contracts','MyNFT.json', 'MyNFT.json');
const contract = require("../artifacts/contracts/borrow/TreasuryBorrow.sol/TreasuryBorrow.json");
const contractAddress = "0x49849fB9E16d146b310B20Bf7cEf5Cb479dcAc2A";
const nftContract = new web3.eth.Contract(contract.abi, contractAddress);
async function stake() {
  const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, "latest"); //get latest nonce
  //the transaction
  const tx = {
    // value: '1000000000000',
    from: PUBLIC_KEY,
    to: contractAddress,
    nonce: nonce,
    gas: 1500000,
    data: nftContract.methods.configPackageInfo([
      ['1', '259200', '98750000000000000000', '1250000000000000000', '1000000000000000000'],
      ['2', '604800', '97800000000000000000', '2200000000000000000', '1000000000000000000'],
      ['3', '1209600', '96600000000000000000', '3400000000000000000', '1000000000000000000'],
      ['4', '2592000', '95500000000000000000', '4500000000000000000', '1000000000000000000'],
      ['5', '5184000', '95150000000000000000', '4850000000000000000', '1000000000000000000'],
      ['6', '7776000', '93900000000000000000', '6100000000000000000', '1000000000000000000'],
      ['7', '10368000', '92500000000000000000', '7500000000000000000', '1000000000000000000'],
      ['8', '0', '0', '0', '0'],
      ['9', '0', '0', '0', '0'],
      ['10', '0', '0', '0', '0'],
      ['11', '0', '0', '0', '0'],

      // ['9', '300', '95000000000000000000', '5000000000000000000', '1000000000000000000'],
      // ['10', '900', '95000000000000000000', '5000000000000000000', '1000000000000000000'],
      // ['11', '25800', '95000000000000000000', '5000000000000000000', '1000000000000000000'],

    ]).encodeABI(),
  }

  const signPromise = await web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);
  await web3.eth.sendSignedTransaction(signPromise.rawTransaction)
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
  }

  const signPromise = await web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);
  await web3.eth.sendSignedTransaction(signPromise.rawTransaction)
}

async function run() {
    stake()
}

run()