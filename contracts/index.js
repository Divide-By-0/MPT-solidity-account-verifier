const { getAccountProof } = require("./scripts/utils");
const utils = require("./scripts/utils");
const web3 = require("web3");
const ethers = require("ethers");
const fs = require("fs");
const { assert } = require("console");
const { rlp } = require("ethereumjs-util");
// const dotenv = ;
require("dotenv").config();
module.exports = utils;

const alchemyGoerliKey = process.env.ALCHEMY_GOERLI_KEY;
const alchemyMainnetKey = process.env.ALCHEMY_MAINNET_KEY;
console.log(alchemyGoerliKey, alchemyMainnetKey);
const alchemyGoerliRpc = "https://eth-goerli.g.alchemy.com/v2/" + alchemyGoerliKey;
const alchemyMainnetRpc = "https://eth-mainnet.g.alchemy.com/v2/" + alchemyMainnetKey;
const localRpc = "http://127.0.0.1:8548";
const proverAbiPath = "../out/Prover.sol/Prover.json";

const goerliAddress = "0x43d31189eaBFb20E0494Cf9f4994DEE0644307dB";
const anvilAddress = "0x06b3244b086cecc40f1e5a826f736ded68068a0f";

async function getAccountProofEthers(accountAddress, blockNumber) {
  const rpc = alchemyGoerliRpc;
  const provider = new ethers.providers.JsonRpcProvider(rpc);

  const abiFile = fs.readFileSync(proverAbiPath, "utf8");
  const abiJson = JSON.parse(abiFile);
  const abi = abiJson.abi;

  const contractInstance = new ethers.Contract(goerliAddress, abi, provider);

  const blockHash = (await provider.getBlock(blockNumber)).hash;
  console.log(blockHash);

  const rpcProof = await provider.send("eth_getProof", [accountAddress, [], "0x" + blockNumber.toString(16)]);
  console.log(rpcProof);

  const fullAccountProof = await getAccountProof(web3, rpc, contractInstance, accountAddress, blockHash);
  console.log(fullAccountProof);
  const header = JSON.parse(JSON.stringify(fullAccountProof.header)); // Make JS copy hack

  delete fullAccountProof.header;
  const accountState = rlp.decode(fullAccountProof.expectedValue);
  const returnValue = await contractInstance.verifyAccount(
    header,
    fullAccountProof,
    utils.buffer2hex(accountState[1]),
    utils.buffer2hex(accountState[2]),
    utils.buffer2hex(accountState[3]),
    accountAddress
  );
  console.log(returnValue);
  // expandkey(web3.utils.soliditySha3(address))
  // 0x050308000c070b070a0e08010a05080e0b09080d090c07080d0e040a010f0d070f0d090503050f0c0905030e0d020b0e0600020d0a0a0a04010706070301020a
  // 0x5380c7b7ae81a58eb98d9c78de4a1fd7fd9535fc953ed2be602daaa41767312a
  // Testing in replit: https://replit.com/@AJGupta/WarmheartedUncommonNlp#contract.sol and https://warmhearteduncommonnlp.ajgupta.repl.co/
}

const accountAddress = "0x0000000000000000000000000000000000000000"; // the CREATE2 address
const forkedBlockNumber = 15697814;
const goerliBlockNumber = 7731377;
getAccountProofEthers(accountAddress, goerliBlockNumber);
