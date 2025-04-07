//1. License
//SPDX-License-Identifier: MIT

//2. Solidity
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../src/MarketPlaceFees.sol";

//Mock NFT
contract MockNFT is ERC721("MockNFT", "MNFT") {
    function mint(address to_, uint256 tokenId_) external {
        _mint(to_, tokenId_);
    }
}

contract MarketPlaceFeesTest is Test {
    //Variables
    address deployer = vm.addr(1);
    address randomUser1 = vm.addr(2);
    address randomUser2 = vm.addr(3);
    MarketPlaceFees marketPlace;
    MockNFT mockNFT;
    uint256 tokenId = 0;

    function setUp() public {
        mockNFT = new MockNFT();
        vm.startPrank(deployer);
        marketPlace = new MarketPlaceFees(deployer);
        vm.stopPrank();

        vm.startPrank(randomUser1);
        mockNFT.mint(randomUser1, 0);
        vm.stopPrank();
    }

    function testMintNFT() public view {
        address ownerOf = mockNFT.ownerOf(tokenId);
        assert(ownerOf == randomUser1);
    }

    function testPriceZero() public {
        uint256 price_ = 0;
        vm.startPrank(randomUser1);
        vm.expectRevert("Price must be above 0");
        marketPlace.listNFT(address(mockNFT), tokenId, price_);
        vm.stopPrank();
    }

    function testNotNFTOwner() public {
        uint256 price_ = 1 ether;
        uint256 tokenId_ = 1;
        mockNFT.mint(randomUser2, tokenId_);
        vm.startPrank(randomUser1);
        vm.expectRevert("Do not own NFT");
        marketPlace.listNFT(address(mockNFT), tokenId_, price_);
        vm.stopPrank();
    }

    function testListNFT() public {
        uint256 price_ = 10 ether;
        vm.startPrank(randomUser1);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);
        vm.stopPrank();
    }

    function testCancelNotOwner() public {
        uint256 price_ = 10 ether;
        vm.startPrank(randomUser1);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);
        vm.stopPrank();

        vm.startPrank(randomUser2);
        vm.expectRevert("Did not list this NFT");
        marketPlace.cancelList(address(mockNFT), tokenId);
        vm.stopPrank();
    }

    function testCancelListing() public {
        uint256 price_ = 10 ether;
        vm.startPrank(randomUser1);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);

        marketPlace.cancelList(address(mockNFT), tokenId);
        (address sellerAfterCancel,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerAfterCancel == address(0));

        vm.stopPrank();
    }

    function testBuyUnlistedNFT() public {
        uint256 userBalance = 50 ether;
        vm.startPrank(randomUser2);
        vm.deal(randomUser2, userBalance);
        vm.expectRevert("Listing does not exist");
        marketPlace.buyNFTEther(address(mockNFT), tokenId);

        vm.stopPrank();
    }

    function testBuyIncorrectPrice() public {
        uint256 price_ = 10 ether;
        uint256 userBalance = 50 ether;
        vm.startPrank(randomUser1);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);
        vm.stopPrank();

        vm.startPrank(randomUser2);
        vm.deal(randomUser2, userBalance);
        vm.expectRevert("Wrong price");
        marketPlace.buyNFTEther{value: price_ - 1 wei}(address(mockNFT), tokenId);

        vm.stopPrank();
    }

    function testBuyNFT() public {
        uint256 price_ = 10 ether;
        uint256 userBalance = 50 ether;
        vm.startPrank(randomUser1);
        (address sellerBefore,,,) = marketPlace.listing(address(mockNFT), tokenId);
        marketPlace.listNFT(address(mockNFT), tokenId, price_);
        (address sellerAfter,,,) = marketPlace.listing(address(mockNFT), tokenId);

        assert(sellerBefore == address(0) && sellerAfter == randomUser1);
        mockNFT.approve(address(marketPlace), tokenId);
        vm.stopPrank();

        vm.startPrank(randomUser2);
        vm.deal(randomUser2, userBalance);
        (address sellerBefore2,,,) = marketPlace.listing(address(mockNFT), tokenId);
        address OwnerBefore = mockNFT.ownerOf(tokenId);
        uint256 balanceBeforeUser1 = address(randomUser1).balance;
        uint256 balanceBeforeUser2 = address(randomUser2).balance;
        marketPlace.buyNFTEther{value: price_}(address(mockNFT), tokenId);
        (address sellerAfter2,,,) = marketPlace.listing(address(mockNFT), tokenId);
        address OwnerAfter = mockNFT.ownerOf(tokenId);
        uint256 balanceAfterUser1 = address(randomUser1).balance;
        uint256 balanceAfterUser2 = address(randomUser2).balance;
        assert(sellerBefore2 == randomUser1 && sellerAfter2 == address(0));
        assert(OwnerBefore == randomUser1 && OwnerAfter == randomUser2);
        assert(balanceAfterUser1 == balanceBeforeUser1 + price_);
        assert(balanceAfterUser2 == balanceBeforeUser2 - price_);
        vm.stopPrank();
    }
}
