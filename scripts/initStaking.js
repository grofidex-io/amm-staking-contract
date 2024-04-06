require("dotenv").config();
const path = require("path");
const API_URL = process.env.NEL_URL;
const PUBLIC_KEY = "0xe4b8f63c111ef118587d30401e1db99f4cfbd900";
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(API_URL);
// const inboxPath = path.resolve(__dirname, 'contracts','MyNFT.json', 'MyNFT.json');
const contract = require("../artifacts/contracts/GroFiStakingManager.sol/GroFiStakingManager.json");
const contractAddress = "0x3828Ed7aBc3c6E61d3Fc3B074e13901A4311d36e";
const nftContract = new web3.eth.Contract(contract.abi, contractAddress);
async function mintNFT(tokenURI) {
  const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, "latest"); //get latest nonce
  console.log(nonce);
  //the transaction
  // const tx = {
  //   value: web3.utils.toWei('0.5', 'ether'),
  //   from: PUBLIC_KEY,
  //   to: contractAddress,
  //   nonce: nonce,
  //   gas: 1000000,
  //   data: nftContract.methods.mintNFT(tokenURI, 'mint').encodeABI(),
  // }

  console.log(
    nftContract.methods
      .initialize(
        "0xFC00FACE00000000000000000000000000000000",
        "0xE4B8f63C111EF118587D30401e1Db99f4CfBD900",
        "0x4012e1E304B3a125ABAa51D5B7191f1FD34C8bFC",
        "0x49A5Eae6FD71A7FaeF24c52899012738B70e3DBa",
        "1",
        "5"
      )
      .encodeABI()
  );

  // console.log(await nftContract.methods.tokenURI('0x3828Ed7aBc3c6E61d3Fc3B074e13901A4311d36e', '1').call())

  // console.log(await nftContract.methods.getStake('0xe4b8f63c111ef118587d30401e1db99f4cfbd900', '1').call())
  return;
  const signPromise = web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);
  signPromise
    .then((signedTx) => {
      web3.eth.sendSignedTransaction(
        signedTx.rawTransaction,
        function (err, hash) {
          if (!err) {
            console.log(
              "The hash of your transaction is: ",
              hash,
              "\nCheck Alchemy's Mempool to view the status of your transaction!"
            );
          } else {
            console.log(
              "Something went wrong when submitting your transaction:",
              err
            );
          }
        }
      );
    })
    .catch((err) => {
      console.log("Promise failed:", err);
    });
}

mintNFT(
  "https://gateway.pinata.cloud/ipfs/QmQhr6s1zVBMb4bm2AECp2n62XxvB16xnF96LD6B6zLYTL"
);
