//1. License
//SPDX-License-Identifier: MIT

//2. Solidity
pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

//3. Contract

contract FloMarketplaceFees is Ownable, ReentrancyGuard {
    // Variables
    struct Listing {
        address seller;
        address nftCollection;
        uint256 tokenId;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listing;

    uint256 public listingFee;
    uint256 public purchaseFee;

    //Events

    event NFTListing(address indexed seller_, address indexed nftAddress_, uint256 indexed tokenId_, uint256 price_);
    event cancelNFT(address indexed seller_, address indexed nftAddress_, uint256 indexed tokenId_);
    event NFTSold(
        address indexed buyer_, address indexed seller_, address indexed nftAddress_, uint256 tokenId_, uint256 price_
    );
    event FeesUpdated(uint256 newListingFee, uint256 newPurchaseFee);
    event FeesWithdrawn(address indexed recipient, uint256 amount);

    /**
     * @notice Initializes the contract and sets the initial owner.
     * @param owner The address that will be assigned as the initial contract owner.
     * @param listingFee_ initial listingFee
     * @param purchaseFee_ initial purchase fee
     */
    constructor(address owner, uint256 listingFee_, uint256 purchaseFee_) Ownable(owner) {
        listingFee = listingFee_;
        purchaseFee = purchaseFee_;
    }

    /**
     * @notice Lists an NFT for sale on the marketplace.
     * @param nftAddress_ The address of the ERC-721 contract.
     * @param tokenId_ The ID of the token to be listed.
     * @param price_ The listing price in wei.
     */
    function listNFT(address nftAddress_, uint256 tokenId_, uint256 price_) external payable nonReentrant {
        require(price_ > 0, "Price must be above 0");
        address owner_ = IERC721(nftAddress_).ownerOf(tokenId_);
        require(owner_ == msg.sender, "Do not own NFT");
        require(msg.value == listingFee, "Incorrect listing fee");

        Listing memory listing_ =
            Listing({seller: msg.sender, nftCollection: nftAddress_, tokenId: tokenId_, price: price_});

        listing[nftAddress_][tokenId_] = listing_;

        emit NFTListing(msg.sender, nftAddress_, tokenId_, price_);
    }

    /**
     * @notice Purchases an NFT listed on the marketplace.
     * @param nftAddress_ The address of the ERC-721 contract.
     * @param tokenId_ The ID of the token to purchase.
     */
    function buyNFTEther(address nftAddress_, uint256 tokenId_) external payable nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];
        uint256 totalPrice = listing_.price + purchaseFee;

        require(listing_.price > 0, "Listing does not exist");
        require(msg.value == totalPrice, "Incorrect amount");
        delete(listing[nftAddress_][tokenId_]);

        IERC721(nftAddress_).safeTransferFrom(listing_.seller, msg.sender, listing_.tokenId);

        (bool success,) = listing_.seller.call{value: listing_.price}("");
        require(success, "Transaction Error");

        emit NFTSold(msg.sender, listing_.seller, listing_.nftCollection, listing_.tokenId, listing_.price);
    }

    /**
     * @notice Cancels an active NFT listing.
     * @param nftAddress_ The address of the ERC-721 contract.
     * @param tokenId_ The ID of the token to cancel the listing for.
     */
    function cancelList(address nftAddress_, uint256 tokenId_) external nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];
        require(listing_.seller == msg.sender, "Did not list this NFT");

        delete(listing[nftAddress_][tokenId_]);

        emit cancelNFT(msg.sender, nftAddress_, tokenId_);
    }

    /**
     * @notice Sets the listing and purchase fees.
     * @param listingFee_ The fee charged for listing an NFT, in basis points (10000 = 100%)
     * @param purchaseFee_ The fee charged for purchasing an NFT, in basis points
     */
    function setFees(uint256 listingFee_, uint256 purchaseFee_) external onlyOwner {
        listingFee = listingFee_;
        purchaseFee = purchaseFee_;
        emit FeesUpdated(listingFee_, purchaseFee_);
    }

    /**
     * @notice Withdraws all accumulated ETH fees from the contract to the owner's address.
     */
    function withdrawFees() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No fees to withdraw");
        (bool success,) = msg.sender.call{value: balance}("");
        require(success, "Withdraw failed");

        emit FeesWithdrawn(owner(), balance);
    }
}
