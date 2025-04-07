//1. License
//SPDX-License-Identifier: MIT

//2. Solidity
pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

//3. Contract

contract MarketPlaceFees is Ownable, ReentrancyGuard {
    // Variables
    struct Listing {
        address seller;
        address nftCollection;
        uint256 tokenId;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listing;

    //Events

    event NFTListing(address indexed seller_, address indexed nftAddress_, uint256 indexed tokenId_, uint256 price_);
    event cancelNFT(address indexed seller_, address indexed nftAddress_, uint256 indexed tokenId_);
    event NFTSold(
        address indexed buyer_, address indexed seller_, address indexed nftAddress_, uint256 tokenId_, uint256 price_
    );

    constructor(address owner) Ownable(owner) {}

    //List NFT
    function listNFT(address nftAddress_, uint256 tokenId_, uint256 price_) external nonReentrant {
        require(price_ > 0, "Price must be above 0");
        address owner_ = IERC721(nftAddress_).ownerOf(tokenId_);
        require(owner_ == msg.sender, "Do not own NFT");

        Listing memory listing_ =
            Listing({seller: msg.sender, nftCollection: nftAddress_, tokenId: tokenId_, price: price_});

        listing[nftAddress_][tokenId_] = listing_;

        emit NFTListing(msg.sender, nftAddress_, tokenId_, price_);
    }

    //Buy NFT

    function buyNFTEther(address nftAddress_, uint256 tokenId_) external payable nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];

        require(listing_.price > 0, "Listing does not exist");
        require(msg.value == listing_.price, "Wrong price");

        delete(listing[nftAddress_][tokenId_]);

        IERC721(nftAddress_).safeTransferFrom(listing_.seller, msg.sender, listing_.tokenId);

        (bool success,) = listing_.seller.call{value: msg.value}("");
        require(success, "Transaction Error");

        emit NFTSold(msg.sender, listing_.seller, listing_.nftCollection, listing_.tokenId, listing_.price);
    }

    //Cancel List

    function cancelList(address nftAddress_, uint256 tokenId_) external nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];
        require(listing_.seller == msg.sender, "Did not list this NFT");

        delete(listing[nftAddress_][tokenId_]);

        emit cancelNFT(msg.sender, nftAddress_, tokenId_);
    }
}
