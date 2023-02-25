# Hardhat Project Template

Steps

1. Create a folder on your device and enter the folder
```
mkdir projectTemplate
cd projectTemplate
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
5. Get Goerli RPC URL
```
Create an account in alchemy.com
Create New App
Enter an App Name
Select ETHEREUM as Chain and GOERLI as Network
Click on Create App. App will be displayed on your Dashboard
Click on View Details of the App
Clcik on View Key > Copy the HTTPS URL
Paste the URL next to GOERLI_RPC_URL in .env file 
```
6. Get Goerli Ethers
```
Go to https://goerlifaucet.com/
Login with your Alchemy Account
Copy your wallet address from Metamask and Paste it in the input box
Click on Send ETH
You will receive 0.05 ETH in your wallet in a few mins.
```
7. Get GOERLI_PRIVATE_KEY
```
Open Metamask
Click on the Right Menu Next to your Wallet Address
Click on Account Details > Export Private Key > Enter your Metamask Password  > Confirm
Copy the Private Key and Paste it under GOERLI_PRIVATE_KEY in .env file
```
8. Get ETHERSCAN_API_KEY
```
Go to https://etherscan.io/
Create an Account and Login to your Account
Click on your Name to open a Drop down menu > Select API KEYS
Create New API Key and Paste the API KEY under ETHERSCAN_API_KEY in .env file.
```
9. General Commands
```
yarn hardhat compile - to compile your smart contract
yarn hardhat test - to execute tests of the smart contract
yarn hardhat node - to start persistent hardhat environment 
yarn hardhat run scripts/* - execute all scripts under scripts folder.
yarn hardhat run scripts/sample.ts - execute script in smaple.ts in the scripts folder.
yarn hardhat deploy - executes all scripts in deploy folder to hardhat network
yarn hardhat deploy --network localhost - executes all scripts in deploy folder to persistent hardhat network
yarn hardhat deploy --network localhost --tags all - executes all scripts in deploy folder with tag "all" to persistent hardhat network
yarn hardhat deploy --network goerli - executes all scripts in deploy folder to goerli network
```


