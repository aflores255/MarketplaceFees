// 1. License
//SPDX-License-Identifier: UNLICENSED

//2. Solidity
pragma solidity 0.8.28;

//3. Contract

import {Script} from "forge-std/Script.sol";
import {FloMarketplaceFees} from "../src/FloMarketplaceFees.sol";

contract FloMarketplaceDeploy is Script {
    function run() external returns (FloMarketplaceFees) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 listingFee = 1 wei;
        uint256 purchaseFee = 2 wei;
        address owner = vm.envAddress("OWNER_ADDRESS");
        vm.startBroadcast(deployerPrivateKey);
        FloMarketplaceFees marketPlace = new FloMarketplaceFees(owner, listingFee, purchaseFee);
        vm.stopBroadcast();
        return marketPlace;
    }
}
