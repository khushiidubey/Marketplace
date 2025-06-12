# CreditMarketplace: Blockchain-Based Marketplace for Trading Credits

## 📄 Project Description

CreditMarketplace is a decentralized smart contract for securely listing, purchasing, transferring, and managing credits such as carbon credits, renewable energy credits, or other tokenized environmental and financial assets. The contract provides a comprehensive infrastructure for peer-to-peer trading of credits with immutable records and verifiable ownership.

## 🎯 Project Vision

The vision behind CreditMarketplace is to offer a transparent, efficient, and trustworthy platform for trading digital credits without intermediaries. With all transactions and ownership details recorded immutably on-chain, the system helps eliminate fraud, ensures traceability, and democratizes access to environmental markets and tokenized resources.

It is particularly designed for high-integrity applications like environmental credit markets, where validating authenticity, avoiding double-counting, and ensuring transparency are essential.

## ✨ Key Features

* **Credit Listing**: Sellers can list credits by specifying type, amount, and price per unit.
* **Purchase Credits**: Buyers can purchase listed credits directly with automated fund transfer and change refunds.
* **Delisting Credits**: Sellers can remove their listings from the marketplace at any time.
* **Dynamic Pricing**: Sellers can update or re-list their credits with new pricing.
* **Ownership Transfer**: Credit ownership can be directly transferred outside of sales (e.g., gifts, delegations).
* **Burning Credits**: Owners can destroy a portion or all of their credits, useful for offset purposes.
* **Query Capabilities**:

  * Fetch full credit details by ID
  * List all active listings
  * Filter by owner or credit type
  * Get the total credit value for an address
  * View marketplace valuation (listed credits)
* **Transparency & Security**: Every change in ownership, pricing, and listing status is recorded on-chain with event logs for full traceability.

## 🔮 Future Scope

* **Verified Credit Registry Integration**: Connect with off-chain environmental or financial credit verifiers.
* **Batch Listing & Purchasing**: Add support for atomic multi-credit transactions.
* **Bidding System**: Allow buyers to submit offers for listed credits.
* **Credit Category Metadata**: Extend support for categorization and richer metadata per credit.
* **Fractionalization**: Enable ownership splits between multiple users.
* **Market Analytics**: Track historical prices, volumes, and trends using oracles or subgraphs.
* **Cross-Chain Compatibility**: Extend the protocol to support multi-chain trading.
* **User Reputation System**: Add seller/buyer trust scores.
* **UI Dashboard**: A frontend dApp to visualize and interact with credits.

## 🛠 Setup and Usage

1. Clone this repository:

   ```bash
   git clone <repository-url>
   cd credit-marketplace
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Create a `.env` file and add your wallet’s private key:

   ```
   PRIVATE_KEY=your_private_key_here
   ```

4. Compile contracts:

   ```bash
   npx hardhat compile
   ```

5. Deploy to Core Testnet:

   ```bash
   npx hardhat run scripts/deploy.js --network coreTestnet
   ```

## 🌐 Network Configuration

* **Network**: Core Testnet 2
* **Chain ID**: 1114
* **RPC URL**: `https://rpc.test2.btcs.network`

## 📜 Contract Details

* **Contract Name**: `CreditMarketplace`
* **Deployed Address**: `0x3f7b9814e46828F098aB6Fb6a25823005CE2f487`
* **Source Code**: See `contracts/CreditMarketplace.sol`
* **Verified On**: [BTCS Explorer](https://explorer.test.btcs.network/address/0x3f7b9814e46828F098aB6Fb6a25823005CE2f487)

![Contract Screenshot](https://github.com/user-attachments/assets/1cc400b1-d4af-4c2a-bfa6-285b5ddb355d)
