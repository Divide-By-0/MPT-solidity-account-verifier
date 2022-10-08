# Ethereum State Bridge

Taken from https://github.com/pipeos-one/goldengate/.

```
# anvil --fork-url https://eth-mainnet.alchemyapi.io/v2/$ALCHEMY_MAINNET_KEY --port 8548 # Run in tmux
# export ETH_RPC_URL=http://localhost:8548
npm install
forge install foundry-rs/forge-std
forge build --force
export ETH_RPC_URL=https://eth-goerli.g.alchemy.com/v2/$ALCHEMY_GOERLI_KEY
forge create --rpc-url $ETH_RPC_URL Prover --constructor-args 0x0000000000000000000000000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
# This is a public Anvil sk, replace with your own with some Goerli eth
node contracts/index.js
```

Example alchemy calls
```
curl https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_MAINNET_KEYs -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_getTransactionReceipt","params":["0x60a51bafca362dfa29fbfa277545e52748b1a23d8d8b6719844e16e78c6b0bf9"],"id":0}'
curl https://eth-mainnet.g.alchemy.com/v2/$ALCHEMY_MAINNET_KEYs -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_getStorageAt","params":["0x0000000000000000000000000000000000000000"],"id":0}'
```

Frontend: https://github.com/outdoteth/vickrey-auction-frontend
Auction Contracts: https://github.com/Philogy/create2-vickrey-contracts/
