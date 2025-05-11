# 🛒 MarketPlaceFees - ERC-721 NFT Marketplace with Customizable Listing and Purchase Fees

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
| `constructor(address owner)` | Initializes the contract by transferring ownership to the specified `owner` address. This enables access control over owner-only functions using OpenZeppelin's `Ownable` module. |

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
