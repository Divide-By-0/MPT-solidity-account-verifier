# Ethereum State Bridge

```
anvil --fork-url https://eth-mainnet.alchemyapi.io/v2/_0H4h-q3niV2xTE3HmLOcZamI3plIeEd --port 8548 # Run in tmux
export ETH_RPC_URL=http://localhost:8548
forge build --force
export ETH_RPC_URL=https://eth-goerli.g.alchemy.com/v2/DZ-tfEUh76nkrIxPSXIvhaPVAffEUPRd
forge create --rpc-url $ETH_RPC_URL Prover --constructor-args 0x0000000000000000000000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
# This is a public Anvil sk

forge create --rpc-url $ETH_RPC_URL Prover --constructor-args 0x0000000000000000000000000000000000000000 --private-key 0x7ad52917a92672e3247c11c34206b99cccaf72f4d68abc3b1f53c964355232ba
```

Example alchemy calls
```
curl https://eth-mainnet.g.alchemy.com/v2/4pnRSHy5RXC-MU61gzArGDuZCylZfOgU -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_getTransactionReceipt","params":["0xd67af112ad813df69acd306dbecb4a6f2ea0c2fa8a7c79c1fc10c34549b66b00"],"id":0}'
curl https://eth-mainnet.g.alchemy.com/v2/4pnRSHy5RXC-MU61gzArGDuZCylZfOgU -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_getStorageAt","params":["0x9EF756060e28384Cc078FD72CDf18070269a9B45"],"id":0}'
```

Taken from https://github.com/pipeos-one/goldengate/.
