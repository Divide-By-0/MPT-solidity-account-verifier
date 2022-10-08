pragma solidity ^0.8.0;

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
        MPT.MerkleProof memory accountdata,
        uint256 balance,
        uint256 codeHash,
        uint256 storageHash,
        address contractAddress
    )
        pure public override returns (bool valid, string memory reason)
    {
        bytes[] memory accountState = new bytes[](4);
        accountState[0] = RLPEncode.encodeUint(0);
        accountState[1] = RLPEncode.encodeUint(balance);
        accountState[2] = RLPEncode.encodeUint(codeHash);
        accountState[3] = RLPEncode.encodeUint(storageHash);

        if (header.stateRoot != accountdata.expectedRoot) return (false, "verifyAccount - different trie roots");
        if(keccak256(RLPEncode.encodeList(accountState)) != keccak256(accountdata.expectedValue)) return (false, "verifyAccount - different account data");
        if(keccak256(contractAddress) != accountdata.key) return (false, "verifyAccount - different contract address");
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
        return EthereumDecoder.toBlockHeader(data);
    }

    function toAccount(bytes memory data) public pure returns (EthereumDecoder.Account memory account) {
        return EthereumDecoder.toAccount(data);
    }
}
