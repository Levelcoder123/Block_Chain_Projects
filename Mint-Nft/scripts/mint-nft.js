require("dotenv").config();
const API_URL = process.env.API_URL;
const PUBLIC_KEY = process.env.PUBLIC_KEY;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const { createAlchemyWeb3 } = require("@alch/alchemy-web3");
const web3 = createAlchemyWeb3(API_URL);

const contract = require("../artifacts/contracts/MyNFT.sol/MyNFT.json");

const contractAddress = "0x031ac728C205DAbCF3a2b0E53cDD12E625451eAb";
const nftContract = new web3.eth.Contract(contract.abi, contractAddress);

console.log(JSON.stringify(contract.abi));

async function mintNFT(tokenURI) {
  try {
    const nonce = await web3.eth.getTransactionCount(PUBLIC_KEY, "latest");
    const gasPrice = await web3.eth.getGasPrice();

    const tx = {
      from: PUBLIC_KEY,
      to: contractAddress,
      nonce: nonce,
      gasPrice: gasPrice,
      data: nftContract.methods.mintNFT(PUBLIC_KEY, tokenURI).encodeABI(),
    };

    const gas = await web3.eth.estimateGas(tx);

    tx.gas = gas;

    const signedTx = await web3.eth.accounts.signTransaction(tx, PRIVATE_KEY);

    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);

    console.log(
      "The hash of your transaction is: ",
      receipt.transactionHash,
      "\nCheck Alchemy's Mempool to view the status of your transaction!"
    );
  } catch (err) {
    console.log("Something went wrong when submitting your transaction:", err);
  }
}

(async () => {
  await mintNFT(
    "https://app.pinata.cloud/pinmanager#/QmQ2Pq6hY44VPUTjRq2yLkgwD7c8wiTXwH8K2ajtb1PLM2"
  );
})();
