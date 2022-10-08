const { getAccountProof } = require("./scripts/utils");
const utils = require("./scripts/utils");
const web3 = require("web3");
const ethers = require("ethers");
const fs = require("fs");
const { assert } = require("console");
// const prover = artifacts.require("./contracts/Prover.sol");
module.exports = utils;

// async function getAccountProof(web3, getProof, prover, address, blockHash) {
//     if (typeof getProof === 'string') getProof = new GetProof(getProof);
//     const proof = await _getAccountProof(getProof, address, blockHash);
//     const proofData = proof.proof.map(node => buffer2hex(rlp.encode(node)));
//     const block = await prover.toBlockHeader(proof.headerData);
//     return {
//         expectedRoot: block.stateRoot,
//         key: '0x' + expandkey(web3.utils.soliditySha3(address)),
//         proof: proofData,
//         keyIndex: proof.keyIndex,
//         proofIndex: proof.proofIndex,
//         expectedValue: proof.receiptData[1],
//         header: block,
//     }
// }
const alchemyGoerliRpc = "https://eth-goerli.g.alchemy.com/v2/DZ-tfEUh76nkrIxPSXIvhaPVAffEUPRd";
const alchemyMainnetRpc = "https://eth-mainnet.g.alchemy.com/v2/4pnRSHy5RXC-MU61gzArGDuZCylZfOgU";
const localRpc = "http://127.0.0.1:8548";

const goerliAddress = "0x2f74D16a776b19d058e40652Cc1F88792660E2fe";
const anvilAddress = "0x06b3244b086cecc40f1e5a826f736ded68068a0f";

async function getAccountProofEthers(accountAddress, blockNumber) {
  const rpc = alchemyGoerliRpc;
  const provider = new ethers.providers.JsonRpcProvider(rpc);

  const abiFile = fs.readFileSync("../out/Prover.sol/Prover.json", "utf8");
  const abiJson = JSON.parse(abiFile);
  const abi = abiJson.abi;

  const contractInstance = new ethers.Contract(goerliAddress, abi, provider);

  const blockHash = (await provider.getBlock(blockNumber)).hash;
  const rpcProof = await provider.send("eth_getProof", [accountAddress, [], "0x" + blockNumber.toString(16)]);

  const fullAccountProof = await getAccountProof(web3, rpc, contractInstance, accountAddress, blockHash);
  console.log(blockHash, rpcProof);
  console.log(fullAccountProof);
  const header = JSON.parse(JSON.stringify(fullAccountProof.header)); // Make JS copy hack
  //   expectedRoot: block.stateRoot,
  //   key: "0x" + expandkey(web3.utils.soliditySha3(address)),
  //   proof: proofData,
  //   keyIndex: proof.keyIndex,
  //   proofIndex: proof.proofIndex,
  //   expectedValue: proof.receiptData[1],
  //   header: block,

  //   EthereumDecoder.BlockHeader memory header,
  //   MPT.MerkleProof memory accountdata
  delete fullAccountProof.header;
  const returnValue = await contractInstance.verifyAccount(header, fullAccountProof, balance);
  console.log(returnValue);
}

const accountAddress = "0x0000000000000000000000000000000000000000"; // the CREATE2 address
const forkedBlockNumber = 15697814;
const goerliBlockNumber = 7731377;
getAccountProofEthers(accountAddress, goerliBlockNumber);
