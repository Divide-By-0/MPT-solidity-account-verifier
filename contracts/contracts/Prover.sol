pragma solidity ^0.8.0;

import "./interface/iProver.sol";
import "./lib/ECVerify.sol";

contract Prover is iProver {
  using MPT for MPT.MerkleProof;

  constructor() {}

  function verifyTrieProof(MPT.MerkleProof memory data) public view override returns (bool) {
    return data.verifyTrieProof();
  }

  function verifyAccount(
    EthereumDecoder.BlockHeader memory header,
    MPT.MerkleProof memory accountdata,
    uint256 balance,
    uint256 codeHash,
    uint256 storageHash,
    address contractAddress
  ) public override returns (bool valid, string memory reason) {
    bytes[] memory accountState = new bytes[](4);
    accountState[0] = RLPEncode.encodeUint(0);
    accountState[1] = RLPEncode.encodeUint(balance);
    accountState[2] = RLPEncode.encodeUint(codeHash);
    accountState[3] = RLPEncode.encodeUint(storageHash);

    if (header.stateRoot != accountdata.expectedRoot) return (false, "verifyAccount - different trie roots");
    if (keccak256(RLPEncode.encodeList(accountState)) != keccak256(accountdata.expectedValue)) return (false, "verifyAccount - different account data");
    if (bytesToBytes32(removeEveryTwo(accountdata.key)) != keccak256(abi.encodePacked(contractAddress))) return (false, "verifyAccount - different account address");

    // if(keccak256(keccak256(contractAddress)) != keccak256(accountdata.key)) return (false, "verifyAccount - different contract address");
    // if(getBlockHash(header) != storedBlockHash) return (false, "verifyAccount - different block hashes");
    valid = accountdata.verifyTrieProof();
    if (!valid) return (false, "verifyAccount - invalid proof");

    return (true, "");
  }

  // Exposing encoder & decoder functions
  function getTransactionHash(bytes memory signedTransaction) public pure returns (bytes32 hash) {
    hash = keccak256(signedTransaction);
  }

  function getBlockHash(EthereumDecoder.BlockHeader memory header) public pure returns (bytes32 hash) {
    return keccak256(getBlockRlpData(header));
  }

  function getBlockRlpData(EthereumDecoder.BlockHeader memory header) public pure returns (bytes memory data) {
    return EthereumDecoder.getBlockRlpData(header);
  }

  function toBlockHeader(bytes memory data) public pure returns (EthereumDecoder.BlockHeader memory header) {
    unchecked {
      return EthereumDecoder.toBlockHeader(data);
    }
  }

  function toAccount(bytes memory data) public pure returns (EthereumDecoder.Account memory account) {
    return EthereumDecoder.toAccount(data);
  }

  function removeEveryTwo(bytes memory b) internal returns (bytes memory out) {
    assembly {
      out := mload(0x40)
      let lenB := mload(b)
      for {
        let i := 0
      } lt(i, lenB) {
        i := add(i, 2)
      } {
        // Isolates every 2 bytes (by rightshifting the next word by 240/256 bits), then extract the last 4 bits and keep them around, and add them to a 4 bit-right shifted middle 4 bits, to remove the 0s in between
        mstore8(add(out, add(0x20, shr(1, i))), add(mod(shr(240, mload(add(b, add(0x20, i)))), 16), shr(4, and(0x0f00, shr(240, mload(add(b, add(0x20, i))))))))
      }
      let lenOut := div(lenB, 2)
      mstore(out, lenOut)
      mstore(0x40, add(out, add(0x20, shl(5, shr(5, add(lenOut, 0x1f))))))
    }
  }

  function bytesToBytes32(bytes memory value) public returns (bytes32 result) {
    assembly {
      result := mload(add(value, 32))
    }
  }
}
