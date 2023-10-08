// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {LibDiamond} from "../../../shared/libraries/LibDiamond.sol";
import {LibMeta} from "../../../shared/libraries/LibMeta.sol";
// import {ILink} from "../../../shared/interfaces/ILink.sol";
// import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// uint256 constant NUMERIC = 6;

struct DiamondFoundry {
    string name;
    uint256 randomNumber;
    address owner;
    uint8 status; // 0 == , 1 == VRF_PENDING,
    bool locked;
    address escrow; //The escrow address thismanages.
}

struct AppStorage {
    // mapping(address => uint32[]) ownerTokenIds;
    // mapping(address => mapping(uint256 => uint256)) ownerTokenIdIndexes;
    string name;
    // string symbol;
    // //Addresses
    // address aContract;
    // bytes32 keyHash;
    // uint144 fee;
    // address vrfCoordinator;
    // ILink link;
    // // Marketplace
    // uint256 nextERC1155ListingId;
    // mapping(uint256 => ERC1155Listing) erc1155Listings;  
}

library LibAppStorage {
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}

contract Modifiers {
    AppStorage internal s;

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }
}