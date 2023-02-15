# Spy Financial HQ

## Contracts List

```
├── AvaxSpies.sol   -> NFT
├── Espionage.sol   -> ERC20 Token
├── StakeSpies.sol  -> Custodial NFT Staking Contract 
└── support
    ├── ERC721A.sol
    ├── ERC721A__IERC721Receiver.sol
    ├── IERC2981Royalties.sol
    ├── IERC721A.sol
    └── ISTIK.sol
```

### Steps

1. Create a folder on your device and enter the folder
```
mkdir SpyFinancials
cd SpyFinancials
```
2. Clone this repo on to your folder.
```
git clone https://github.com/SrikanthAlva/HardhatTemplate.git .
```
3. Download dependencies
```
yarn 
OR
npm install
```
4. Create .env file and copy content from .env.example folder

Fill up the env file with the Testnet and Mainnet RPC URLs, PrivateKey, Explorer API Key[Optional]
5. General Commands
```
yarn hardhat compile - to compile your smart contract
yarn hardhat deploy --network avalanche - executes all scripts in deploy folder to avalanche network
```


