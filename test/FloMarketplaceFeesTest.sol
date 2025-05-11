//1. License
//SPDX-License-Identifier: MIT

//2. Solidity
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../src/FloMarketplaceFees.sol";

//Mock NFT
contract MockNFT is ERC721("MockNFT", "MNFT") {
    function mint(address to_, uint256 tokenId_) external {
        _mint(to_, tokenId_);
    }
}

contract FloMarketplaceFeesTest is Test {
    //Variables
    address deployer = vm.addr(1);
    address randomUser1 = vm.addr(2);
    address randomUser2 = vm.addr(3);
    FloMarketplaceFees marketPlace;
    MockNFT mockNFT;
    uint256 tokenId = 0;
    uint256 listingFee = 1e16;
    uint256 purchaseFee = 3e16;

    //Tests setUp
    function setUp() public {
        mockNFT = new MockNFT();
        vm.startPrank(deployer);
        marketPlace = new FloMarketplaceFees(deployer);
        marketPlace.setFees(listingFee, purchaseFee);
        vm.stopPrank();

        vm.startPrank(randomUser1);
        mockNFT.mint(randomUser1, 0);
        vm.stopPrank();
    }

    //Test to Mint a ERC-721 NFT
    function testMintNFT() public view {
        address ownerOf = mockNFT.ownerOf(tokenId);
        assert(ownerOf == randomUser1);
    }

    //Test to avoid price 0 when listing
    function testPriceZero() public {
        uint256 price_ = 0;
        vm.startPrank(randomUser1);
        vm.expectRevert("Price must be above 0");
        marketPlace.listNFT(address(mockNFT), tokenId, price_);
        vm.stopPrank();
    }

    //Test to ensure listing fee is sent
    function testIncorrectListingFee() public {
        uint256 price_ = 1 ether;
        uint256 userBalance = 1 ether;
        vm.startPrank(randomUser1);
        vm.deal(randomUser1, userBalance);
        vm.expectRevert("Incorrect listing fee");
        marketPlace.listNFT{value: listingFee - 1 wei}(address(mockNFT), tokenId, price_);
        vm.stopPrank();
    }

    //Test Owner's NFT
    function testNotNFTOwner() public {
        uint256 price_ = 1 ether;
        uint256 tokenId_ = 1;
        mockNFT.mint(randomUser2, tokenId_);
        vm.startPrank(randomUser1);
        vm.expectRevert("Do not own NFT");
        marketPlace.listNFT(address(mockNFT), tokenId_, price_);
        vm.stopPrank();
    }

    //Test listing of ERC-721 NFT
    function testListNFT() public {
        uint256 price_ = 10 ether;
        uint256 userBalance = 1 ether;
        vm.startPrank(randomUser1);
        vm.deal(randomUser1, userBalance);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT{value: listingFee}(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);
        vm.stopPrank();
    }

    //Test to cancel listing if the user is not the owner
    function testCancelNotOwner() public {
        uint256 price_ = 10 ether;
        uint256 userBalance = 1 ether;
        vm.startPrank(randomUser1);
        vm.deal(randomUser1, userBalance);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT{value: listingFee}(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);
        vm.stopPrank();

        vm.startPrank(randomUser2);
        vm.expectRevert("Did not list this NFT");
        marketPlace.cancelList(address(mockNFT), tokenId);
        vm.stopPrank();
    }

    //Test to cancel listing
    function testCancelListing() public {
        uint256 price_ = 10 ether;
        uint256 userBalance = 1 ether;
        vm.startPrank(randomUser1);
        vm.deal(randomUser1, userBalance);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT{value: listingFee}(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);

        marketPlace.cancelList(address(mockNFT), tokenId);
        (address sellerAfterCancel,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerAfterCancel == address(0));

        vm.stopPrank();
    }

    //Test to buy an unlisted NFT
    function testBuyUnlistedNFT() public {
        uint256 userBalance = 50 ether;
        vm.startPrank(randomUser2);
        vm.deal(randomUser2, userBalance);
        vm.expectRevert("Listing does not exist");
        marketPlace.buyNFTEther(address(mockNFT), tokenId);

        vm.stopPrank();
    }

    //Test to buy a NFT for the wrong price
    function testBuyIncorrectPrice() public {
        uint256 price_ = 10 ether;
        uint256 userBalance = 50 ether;
        vm.startPrank(randomUser1);
        vm.deal(randomUser1, userBalance);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT{value: listingFee}(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);
        vm.stopPrank();

        vm.startPrank(randomUser2);
        vm.deal(randomUser2, userBalance);
        vm.expectRevert("Incorrect amount");
        marketPlace.buyNFTEther{value: price_}(address(mockNFT), tokenId);

        vm.stopPrank();
    }

    //Test to buy a NFT
    function testBuyNFT() public {
        uint256 price_ = 10 ether;
        uint256 userBalance = 50 ether;
        vm.startPrank(randomUser1);
        vm.deal(randomUser1, userBalance);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT{value: listingFee}(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);
        mockNFT.approve(address(marketPlace), tokenId);
        uint256 balanceBeforeUser1 = address(randomUser1).balance;
        vm.stopPrank();

        vm.startPrank(randomUser2);
        vm.deal(randomUser2, userBalance);
        (address sellerBefore2,,,) = marketPlace.listing(address(mockNFT), tokenId);
        address OwnerBefore = mockNFT.ownerOf(tokenId);

        uint256 balanceBeforeUser2 = address(randomUser2).balance;
        marketPlace.buyNFTEther{value: price_ + purchaseFee}(address(mockNFT), tokenId);
        (address sellerAfter2,,,) = marketPlace.listing(address(mockNFT), tokenId);
        address OwnerAfter = mockNFT.ownerOf(tokenId);
        uint256 balanceAfterUser1 = address(randomUser1).balance;
        uint256 balanceAfterUser2 = address(randomUser2).balance;
        assert(sellerBefore2 == randomUser1 && sellerAfter2 == address(0));
        assert(OwnerBefore == randomUser1 && OwnerAfter == randomUser2);
        assert(address(marketPlace).balance == listingFee + purchaseFee);
        assert(balanceAfterUser1 == balanceBeforeUser1 + price_);
        assert(balanceAfterUser2 == balanceBeforeUser2 - price_ - purchaseFee);
        vm.stopPrank();
    }

    //Test to set new listing and purchase fees
    function testSetFeesOnlyOwner() public {
        uint256 newListingFee = 1 wei;
        uint256 newPurchaseFee = 2 wei;
        vm.startPrank(deployer);
        marketPlace.setFees(newListingFee, newPurchaseFee);

        assert(marketPlace.listingFee() == newListingFee);
        assert(marketPlace.purchaseFee() == newPurchaseFee);
        vm.stopPrank();
    }

    //Test to avoid new fees in case the user is not the owner
    function testSetFeesNotOwner() public {
        uint256 newListingFee = 1 wei;
        uint256 newPurchaseFee = 2 wei;
        vm.startPrank(randomUser1);
        vm.expectRevert();
        marketPlace.setFees(newListingFee, newPurchaseFee);
        vm.stopPrank();
    }

    //Test to withdraw funds if balance is zero
    function testWithdrawNoFunds() public {
        vm.startPrank(deployer);
        vm.expectRevert("No fees to withdraw");
        marketPlace.withdrawFees();
        vm.stopPrank();
    }

    //Test to withdraw funds in case the user is not the owner
    function testWithdrawNotOwner() public {
        uint256 price_ = 10 ether;
        uint256 userBalance = 1 ether;
        vm.startPrank(randomUser1);
        vm.deal(randomUser1, userBalance);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT{value: listingFee}(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);
        vm.expectRevert();
        marketPlace.withdrawFees();
        vm.stopPrank();
    }

    //Test to withdraw funds
    function testWithdrawOwner() public {
        uint256 price_ = 10 ether;
        uint256 userBalance = 50 ether;
        vm.startPrank(randomUser1);
        vm.deal(randomUser1, userBalance);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT{value: listingFee}(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);
        mockNFT.approve(address(marketPlace), tokenId);
        uint256 balanceBeforeUser1 = address(randomUser1).balance;
        vm.stopPrank();

        vm.startPrank(randomUser2);
        vm.deal(randomUser2, userBalance);
        (address sellerBefore2,,,) = marketPlace.listing(address(mockNFT), tokenId);
        address OwnerBefore = mockNFT.ownerOf(tokenId);

        uint256 balanceBeforeUser2 = address(randomUser2).balance;
        marketPlace.buyNFTEther{value: price_ + purchaseFee}(address(mockNFT), tokenId);
        (address sellerAfter2,,,) = marketPlace.listing(address(mockNFT), tokenId);
        address OwnerAfter = mockNFT.ownerOf(tokenId);
        uint256 balanceAfterUser1 = address(randomUser1).balance;
        uint256 balanceAfterUser2 = address(randomUser2).balance;
        assert(sellerBefore2 == randomUser1 && sellerAfter2 == address(0));
        assert(OwnerBefore == randomUser1 && OwnerAfter == randomUser2);
        assert(address(marketPlace).balance == listingFee + purchaseFee);
        assert(balanceAfterUser1 == balanceBeforeUser1 + price_);
        assert(balanceAfterUser2 == balanceBeforeUser2 - price_ - purchaseFee);
        vm.stopPrank();

        vm.startPrank(deployer);
        uint256 contractBalance = listingFee + purchaseFee;
        uint256 balanceBefore = address(deployer).balance;
        assert(address(marketPlace).balance == contractBalance);
        marketPlace.withdrawFees();
        uint256 balanceAfter = address(deployer).balance;
        assert(balanceAfter == balanceBefore + contractBalance);
        assert(address(marketPlace).balance == 0);
        vm.stopPrank();
    }
}
