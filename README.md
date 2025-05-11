# 🛒 MarketPlaceFees - ERC-721 NFT Marketplace

## 📌 Description
**MarketPlaceFees** is a Solidity-based smart contract that enables users to list, buy, and cancel NFTs using Ether, with fully configurable fees for listing and purchasing. Compatible with any ERC-721 collection, this marketplace allows secure peer-to-peer NFT trading.

The contract is built using **OpenZeppelin** libraries for best security practices and is thoroughly tested using **Foundry**.

---

## 🚀 Features

| **Feature** | **Description** |
|------------|-----------------|
| 🧱 **ERC-721 Compatible** | Works with any collection implementing the ERC-721 standard. |
| 💸 **Configurable Fees** | Listing and purchase fees can be set by the contract owner. |
| 📝 **NFT Listing** | Users can list their NFTs with a specified price in Ether. |
| 🛒 **Buy NFTs** | Buyers can purchase listed NFTs by sending the exact total price. |
| ❌ **Cancel Listings** | Sellers can cancel their listings at any time. |
| 🔒 **Security** | Protected with `ReentrancyGuard` to avoid reentrancy attacks. |
| 🏦 **Withdraw Fees** | The contract owner can withdraw accumulated fees. |

---

## 📜 Contract Details

### 🏗️ Constructor

| **Component** | **Description** |
|---------------|-----------------|
| `constructor(address owner, uint256 listingFee_, uint256 purchaseFee_)` | Initializes the contract by transferring ownership to the specified `owner` address and setting initial listing and purchase fees. This enables access control over owner-only functions using OpenZeppelin's `Ownable` module. |

### 📡 Events

| **Event** | **Description** |
|----------|-----------------|
| `NFTListing(address seller, address nftAddress, uint256 tokenId, uint256 price)` | Emitted when an NFT is listed. |
| `cancelNFT(address seller, address nftAddress, uint256 tokenId)` | Emitted when a listing is cancelled. |
| `NFTSold(address buyer, address seller, address nftAddress, uint256 tokenId, uint256 price)` | Emitted upon a successful purchase. |
| `FeesUpdated(uint256 newListingFee, uint256 newPurchaseFee)` | Emitted when fees are updated by the owner. |
| `FeesWithdrawn(address recipient, uint256 amount)` | Emitted when the owner withdraws collected fees. |

### 🔧 Functions

| **Function** | **Description** |
|-------------|------------------|
| `listNFT(address nftAddress, uint256 tokenId, uint256 price)` | List an NFT with a price (requires listing fee). |
| `buyNFTEther(address nftAddress, uint256 tokenId)` | Purchase an NFT (requires price + purchase fee). |
| `cancelList(address nftAddress, uint256 tokenId)` | Cancel a listing (only by seller). |
| `setFees(uint256 listingFee, uint256 purchaseFee)` | Set new listing and purchase fees (only owner). |
| `withdrawFees()` | Withdraw collected fees (only owner). |

---

## 🚀 Deployment & Usage

This section outlines how to interact with the `FloMarketplaceFees` smart contract deployed on the **Arbitrum One** network. It includes instructions to list and buy NFTs using the live marketplace, and explains how fee withdrawals work for the contract owner.

🔗 **Deployed Contract:** [0x33085a5a14ACd29E162587fD702f055Fe5Ac131e on Arbiscan](https://arbiscan.io/address/0x33085a5a14ACd29E162587fD702f055Fe5Ac131e)

---

### 📤 How to List an NFT

To list your ERC-721 NFT on the marketplace:

1. **Approve the marketplace to transfer your NFT**  
   Go to your NFT contract on Arbiscan, for instance:  
   [DragonNFTCollection at 0xafFc28fD8DBDFBD17e6d47A98aa2b7A73ae39C33](https://arbiscan.io/address/0xafFc28fD8DBDFBD17e6d47A98aa2b7A73ae39C33)

   Navigate to **Write Contract → Connect to Web3**, then call:
   - `approve(address to, uint256 tokenId)`
   - Use:
     - `to`: `0x33085a5a14ACd29E162587fD702f055Fe5Ac131e`
     - `tokenId`: `0` (your token id)

2. **List the NFT via the marketplace contract**  
   Go to the marketplace’s [Write Contract tab](https://arbiscan.io/address/0x33085a5a14ACd29E162587fD702f055Fe5Ac131e#writeContract), connect your wallet, and call:

   - `listNFT(address _nft, uint256 _tokenId, uint256 _price)`
     - `nftAddress_`: `0xafFc28fD8DBDFBD17e6d47A98aa2b7A73ae39C33`
     - `tokenId_`: `0` (your token id)
     - `price_`: `1` (enter your price in wei)

✅ **Example Listing:**
- **Seller**: `0x36e985fd5fCD00F6a30a4c3291214a2d29e2B583`
- **NFT Collection**: `0xafFc28fD8DBDFBD17e6d47A98aa2b7A73ae39C33`
- **Token ID**: `0`
- **Price**: `1`

---

### 🛒 How to Buy a Listed NFT

To buy a listed NFT:

1. Go to the marketplace contract on Arbiscan:  
   [0x33085a5a14ACd29E162587fD702f055Fe5Ac131e](https://arbiscan.io/address/0x33085a5a14ACd29E162587fD702f055Fe5Ac131e)

2. Connect your wallet (on the Arbitrum One network), then call:

   - `buyNFTEther(address nftAddress_, uint256 tokenId_)`
   - Provide:
     - `nftAddress_`: `0xafFc28fD8DBDFBD17e6d47A98aa2b7A73ae39C33`
     - `tokenId_`: `0`
   - In the “Value” field, enter the total price including the purchase fee.  
     For example, if price is `1 wei` and purchase fee is `2 wei`, send `3 wei`.

3. Confirm and submit the transaction. The NFT will be transferred to your address.

---

### 📄 Check a Listing

To check if an NFT is listed:

- Go to the **Read Contract** tab of the marketplace.
- Call: `listing(address nftAddress_, uint256 tokenId_)`
- Example:
  - `nftAddress_`: `0xafFc28fD8DBDFBD17e6d47A98aa2b7A73ae39C33`
  - `tokenId_`: `0`

You’ll see:
- `seller`: `0x36e985fd5fCD00F6a30a4c3291214a2d29e2B583`
- `nftCollection`: `0xafFc28fD8DBDFBD17e6d47A98aa2b7A73ae39C33`
- `tokenId`: `1`
- `price`: `1`

---

### 💰 Fee Management (Owner Only)

The contract owner can withdraw all collected listing and purchase fees by calling:

- `withdrawFees()`

This sends the full ETH balance of the contract to the `owner` address defined at deployment.

---

### 🔗 Example Listing Transaction

An example listing created with this marketplace:

🔹 [Tx Hash: 0x... (example)](https://arbiscan.io/tx/0xe5608c3d62c417598bfa3639cd5375d8d29985d6f06f769689e53ea98b20ef7e)  
- NFT listed at: `1 wei`  
- Token ID: `0`  
- Seller: `0x36e9...`  
- NFT Contract: `0xafFc28...`  
- Marketplace: `0x33085a...`

---

## 🧪 Testing with Foundry

The contract has been thoroughly tested with **Foundry**. Tests include all core features, access control, and edge cases.

### ✅ Implemented Tests

| **Test** | **Description** |
|----------|------------------|
| `testMintNFT` | Checks mock NFT minting. |
| `testPriceZero` | Ensures zero-price listings are rejected. |
| `testIncorrectListingFee` | Rejects incorrect listing fees. |
| `testNotNFTOwner` | Prevents listing without ownership. |
| `testListNFT` | Tests successful listing. |
| `testCancelNotOwner` | Ensures only lister can cancel. |
| `testCancelListing` | Cancels a valid listing. |
| `testBuyUnlistedNFT` | Prevents buying unlisted NFTs. |
| `testBuyIncorrectPrice` | Fails if price sent is incorrect. |
| `testBuyNFT` | Tests full buy flow with fees and ownership transfer. |
| `testSetFeesOnlyOwner` | Owner can update listing and purchase fees. |
| `testSetFeesNotOwner` | Non-owner cannot update fees. |
| `testWithdrawNoFunds` | Reverts if there are no fees to withdraw. |
| `testWithdrawNotOwner` | Prevents non-owner from withdrawing fees. |
| `testWithdrawOwner` | Owner successfully withdraws fees. |

### 🧪 How to Run Tests

To run the test suite with Foundry:

```bash
forge test
```

### 📊 Coverage Report

| File                    | % Lines         | % Statements     | % Branches      | % Functions     |
|-------------------------|------------------|-------------------|------------------|------------------|
| `src/FloMarketPlaceFees.sol` | 100.00% (33/33) | 100.00% (32/32) | 88.89% (16/18) | 100.00% (5/5)   |

> 🔍 **Note**: Coverage is not 100% for branches due to one specific edge case — the branch that reverts with `"Transaction Error"` and `"Withdraw Failed"` on failed Ether transfers. Simulating that revert requires a test using a contract that intentionally rejects Ether. 

---

## 📄 License

This project is licensed under the **MIT License**. You are free to use, modify, and distribute it.

---
