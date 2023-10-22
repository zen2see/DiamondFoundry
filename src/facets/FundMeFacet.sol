// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AppStorage, Modifiers} from "../libraries/LibAppStorage.sol";
import {LibMeta} from "../../../shared/libraries/LibMeta.sol";
import {LibConstants} from "../libraries/LibConstants.sol";
import {LibPriceConverter} from "../libraries/LibPriceConverter.sol";

error not_Owner();

contract FundMeFacet is Modifiers {
    using LibPriceConverter for uint256;

    function fund() payable external {
        require(msg.value.getConversionRate() >= LibConstants.MINIMUM_USD, "Didn't send enough ETH");
        s.addressToAmountFunded[msg.sender] += msg.value;
        s.funders.push(msg.sender);
    }

    function getVersion() external view returns (uint256) {

    }

    function withdraw() external onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s.funders.length; funderIndex++) {
            address funder = s.funders[funderIndex];
            s.addressToAmountFunded[funder] = 0;
        }
        s.funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed"); 
    }

    // function supportsInterface(bytes4 _interfaceID) external view returns (bool) {}

    // fallback() external payable {
    //     this.fund();
    // }

    // receive() external payable {
    //     this.fund();
    // }
    
}