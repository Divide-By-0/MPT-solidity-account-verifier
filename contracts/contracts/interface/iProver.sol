pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "../lib/EthereumDecoder.sol";
import "../lib/MPT.sol";

interface iProver {
    function verifyTrieProof(MPT.MerkleProof memory data) pure external returns (bool);

    function verifyAccount(
        EthereumDecoder.BlockHeader memory header,
        MPT.MerkleProof memory accountdata
    ) view external returns (bool valid, string memory reason);
}
