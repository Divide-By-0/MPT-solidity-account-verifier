pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./interface/iProver.sol";
import "./lib/ECVerify.sol";

contract Prover is iProver {
    using MPT for MPT.MerkleProof;

    constructor() {}

    function verifyTrieProof(MPT.MerkleProof memory data) pure public override returns (bool) {
        return data.verifyTrieProof();
    }

    function verifyAccount(
        EthereumDecoder.BlockHeader memory header,
        MPT.MerkleProof memory accountdata
    )
        pure public override returns (bool valid, string memory reason)
    {
        if (header.stateRoot != accountdata.expectedRoot) return (false, "verifyAccount - different trie roots");

        valid = accountdata.verifyTrieProof();
        if (!valid) return (false, "verifyAccount - invalid proof");

        return (true, "");
    }

    function verifyAccount(
        EthereumDecoder.BlockHeader memory header,
        MPT.MerkleProof memory accountdata,
        uint256 balance,
        uint256 codeHash,
        uint256 storageHash
    )
        pure public override returns (bool valid, string memory reason)
    {
        if (header.stateRoot != accountdata.expectedRoot) return (false, "verifyAccount - different trie roots");
        if(RLPEncode.encodeList([0, balance, codeHash, storageHash]) != accountdata.expectedValue) return (false, "verifyAccount - different account data");

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
        return EthereumDecoder.toBlockHeader(data);
    }

    function toAccount(bytes memory data) public pure returns (EthereumDecoder.Account memory account) {
        return EthereumDecoder.toAccount(data);
    }
}
