const { getAccountProof } = require("./scripts/utils");
const utils = require("./scripts/utils");
const web3 = require("web3");
const ethers = require("ethers");
const fs = require("fs");
const { assert } = require("console");
const { rlp } = require("ethereumjs-util");
module.exports = utils;

const alchemyGoerliRpc = "https://eth-goerli.g.alchemy.com/v2/DZ-tfEUh76nkrIxPSXIvhaPVAffEUPRd";
const alchemyMainnetRpc = "https://eth-mainnet.g.alchemy.com/v2/4pnRSHy5RXC-MU61gzArGDuZCylZfOgU";
const localRpc = "http://127.0.0.1:8548";
const proverAbiPath = "../out/Prover.sol/Prover.json";

const goerliAddress = "0xa8498374E96cD68EEc7F857f4baFd681BEBd1D5b";
const anvilAddress = "0x06b3244b086cecc40f1e5a826f736ded68068a0f";

async function getAccountProofEthers(accountAddress, blockNumber) {
  const rpc = alchemyGoerliRpc;
  const provider = new ethers.providers.JsonRpcProvider(rpc);

  const abiFile = fs.readFileSync(proverAbiPath, "utf8");
  const abiJson = JSON.parse(abiFile);
  const abi = abiJson.abi;

  const contractInstance = new ethers.Contract(goerliAddress, abi, provider);

  const blockHash = (await provider.getBlock(blockNumber)).hash;
  const rpcProof = await provider.send("eth_getProof", [accountAddress, [], "0x" + blockNumber.toString(16)]);

  const fullAccountProof = await getAccountProof(web3, rpc, contractInstance, accountAddress, blockHash);
  console.log(blockHash, rpcProof);
  console.log(fullAccountProof);
  const header = JSON.parse(JSON.stringify(fullAccountProof.header)); // Make JS copy hack

  delete fullAccountProof.header;
  const accountState = rlp.decode(fullAccountProof.expectedValue);
  const returnValue = await contractInstance.verifyAccount(
    header,
    fullAccountProof,
    utils.buffer2hex(accountState[1]),
    utils.buffer2hex(accountState[2]),
    utils.buffer2hex(accountState[3])
  );
  console.log(returnValue);
}

const accountAddress = "0x0000000000000000000000000000000000000000"; // the CREATE2 address
const forkedBlockNumber = 15697814;
const goerliBlockNumber = 7731377;
getAccountProofEthers(accountAddress, goerliBlockNumber);
