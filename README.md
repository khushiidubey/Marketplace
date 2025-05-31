# Marketplace Contract for Trading Credits

## Project Description
This project implements a blockchain-based marketplace for trading various types of credits, such as carbon credits, renewable energy credits, or other forms of digital assets representing value or environmental benefits. The marketplace allows users to list their credits for sale, purchase credits from others, and manage their credit listings.

## Project Vision
The vision for this marketplace is to create a transparent, decentralized platform where credits can be traded efficiently without intermediaries. By leveraging blockchain technology, we aim to provide a trustless environment where credit ownership and transactions are immutably recorded, verifiable, and secure.

This marketplace can be particularly useful for environmental credits trading, where transparency and traceability are crucial for validating the authenticity of credits and preventing double-counting. The system ensures that credits are properly transferred and that all transactions are recorded on the blockchain.

## Key Features
- **Credit Listing**: Users can list their credits for sale by specifying credit type, amount, and price per unit.
- **Credit Purchase**: Users can purchase credits directly from the marketplace, with automatic transfer of funds to the seller.
- **Delisting Option**: Sellers can remove their credit listings if they choose not to sell.
- **Credit Details**: Users can query detailed information about any credit listing.
- **Transparent Transactions**: All credit transfers and purchases are recorded on the blockchain, providing complete transparency.
- **Automatic Payment Processing**: The smart contract automatically handles the payment and transfer process between buyers and sellers.

## Future Scope
- **Credit Verification System**: Implement a verification mechanism to validate the authenticity of credits before they are listed.
- **Credit Categories and Filtering**: Add support for categorizing credits and filtering based on various attributes.
- **Fractional Ownership**: Allow partial ownership of credits to enable smaller investments.
- **Bidding System**: Implement a bidding mechanism where buyers can make offers on listed credits.
- **Batch Transactions**: Support for buying or selling multiple credits in a single transaction.
- **Integration with External Credit Registries**: Connect with established credit registries for additional verification.
- **Credit Rating System**: Implement a rating system for credits based on quality and reliability.
- **Secondary Market**: Enable trading of previously purchased credits.
- **Analytics Dashboard**: Provide insights into market trends, popular credit types, and price histories.
- **Cross-Chain Functionality**: Extend to support trading credits across different blockchain networks.

## Setup and Usage
1. Clone this repository
2. Install dependencies with `npm install`
3. Create a `.env` file based on `.env.example` and add your private key
4. Compile the contracts with `npm run compile`
5. Deploy to Core Testnet 2 with `npm run deploy`

## Network Configuration
This project is configured to work with Core Testnet 2 at RPC URL: https://rpc.test2.btcs.network


Contract Address : 0x3f7b9814e46828F098aB6Fb6a25823005CE2f487
![image](https://github.com/user-attachments/assets/1cc400b1-d4af-4c2a-bfa6-285b5ddb355d)


