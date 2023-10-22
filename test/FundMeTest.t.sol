// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/******************************************************************************\
* Authors: Timo Neumann <timo@fyde.fi>, Rohan Sundar <rohan@fyde.fi>
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
/******************************************************************************/
import "./TestStates2.sol";

// test proper deployment of diamond
contract TestFundDeployDiamond is StateFundDeployDiamond {
    // TEST CASES

    function test1HasThreeFacets() public {
        assertEq(facetAddressList.length, 3);
        console.log("TestFundDeployDiamond: in test1");
    }

    function test2FacetsHaveCorrectSelectors() public {
        for (uint i = 0; i < facetAddressList.length; i++) {
            bytes4[] memory fromLoupeFacet = ILoupe.facetFunctionSelectors(facetAddressList[i]);
            bytes4[] memory fromGenSelectors =  generateSelectors(facetNames[i]);
            assertTrue(sameMembers(fromLoupeFacet, fromGenSelectors));
        }
    }

    function test3SelectorsAssociatedWithCorrectFacet() public {
        for (uint i = 0; i < facetAddressList.length; i++) {
            bytes4[] memory fromGenSelectors =  generateSelectors(facetNames[i]);
            for (uint j = 0; i < fromGenSelectors.length; i++) {
                assertEq(facetAddressList[i], ILoupe.facetAddress(fromGenSelectors[j]));
            }
        }
    }
}

contract TestFundAddFacet1 is StateFundAddFacet1{
    function test4AddTest1FacetFunctions() public {
        console.log("TestFundAddFacet1: in test4");
        // check if functions added to diamond
        bytes4[] memory fromLoupeFacet = ILoupe.facetFunctionSelectors(address(fundMeFacet));
        bytes4[] memory fromGenSelectors = removeElement(uint(0), generateSelectors("FundMeFacet"));
        assertTrue(sameMembers(fromLoupeFacet, fromGenSelectors));
    }

    function test5CanCallTest1FacetFunction() public {
         // try to call function on new Facet
        FundMeFacet(address(diamond)).fund();
    }

    function test6ReplaceSupportsInterfaceFunction() public {
        // get supportsInterface selector from positon 0
        bytes4[] memory fromGenSelectors =  new bytes4[](1);
        fromGenSelectors[0] = generateSelectors("FundMeFacet")[0];
        // struct to replace function
        FacetCut[] memory cutTest1 = new FacetCut[](1);
        cutTest1[0] =
        FacetCut({
            facetAddress: address(fundMeFacet),
            action: FacetCutAction.Replace,
            functionSelectors: fromGenSelectors
        });
        // replace function by function on Test1 facet
        ICut.diamondCut(cutTest1, address(0x0), "");
        // check supportsInterface method connected to test1Facet
        assertEq(address(fundMeFacet), ILoupe.facetAddress(fromGenSelectors[0]));
    }

    function test9RemoveSomeTest1FacetFunctions() public {
        bytes4[] memory functionsToKeep = new bytes4[](3);
        functionsToKeep[0] = fundMeFacet.getVersion.selector;
        functionsToKeep[1] = fundMeFacet.withdraw.selector;
        bytes4[] memory selectors = ILoupe.facetFunctionSelectors(address(fundMeFacet));
        for (uint i = 0; i < functionsToKeep.length; i++){
            selectors = removeElement(functionsToKeep[i], selectors);
        }
        // array of functions to remove
        FacetCut[] memory facetCut = new FacetCut[](1);
        facetCut[0] =
        FacetCut({
            facetAddress: address(0x0),
            action: FacetCutAction.Remove,
            functionSelectors: selectors
        });
        // add functions to diamond
        ICut.diamondCut(facetCut, address(0x0), "");
        bytes4[] memory fromLoupeFacet = ILoupe.facetFunctionSelectors(address(fundMeFacet));
        assertTrue(sameMembers(fromLoupeFacet, functionsToKeep));
    }

    function test10RemoveAllExceptDiamondCutAndFacetFunction() public {
        bytes4[] memory selectors = getAllSelectors(address(diamond));
        bytes4[] memory functionsToKeep = new bytes4[](2);
        functionsToKeep[0] = DiamondCutFacet.diamondCut.selector;
        functionsToKeep[1] = DiamondLoupeFacet.facets.selector;
        selectors = removeElement(functionsToKeep[0], selectors);
        selectors = removeElement(functionsToKeep[1], selectors);
        // array of functions to remove
        FacetCut[] memory facetCut = new FacetCut[](1);
        facetCut[0] =
        FacetCut({
            facetAddress: address(0x0),
            action: FacetCutAction.Remove,
            functionSelectors: selectors
        });
        
        // remove functions from diamond
        ICut.diamondCut(facetCut, address(0x0), "");
        Facet[] memory facets = ILoupe.facets();
        bytes4[] memory testselector = new bytes4[](1);
        assertEq(facets.length, 2);
        assertEq(facets[0].facetAddress, address(dCutFacet));
        testselector[0] = functionsToKeep[0];
        assertTrue(sameMembers(facets[0].functionSelectors, testselector));
        assertEq(facets[1].facetAddress, address(dLoupe));
        testselector[0] = functionsToKeep[1];
        assertTrue(sameMembers(facets[1].functionSelectors, testselector));
    }
}

// contract TestCacheBug is StateCacheBug {
//     function testNoCacheBug() public {
//         bytes4[] memory fromLoupeSelectors = ILoupe.facetFunctionSelectors(address(fundMeFacet));
//          assertTrue(containsElement(fromLoupeSelectors, selectors[0]));
//          assertTrue(containsElement(fromLoupeSelectors, selectors[1]));
//         // assertTrue(containsElement(fromLoupeSelectors, selectors[2]));
//         // assertTrue(containsElement(fromLoupeSelectors, selectors[3]));
//         // assertTrue(containsElement(fromLoupeSelectors, selectors[4]));
//         // assertTrue(containsElement(fromLoupeSelectors, selectors[6]));
//         // assertTrue(containsElement(fromLoupeSelectors, selectors[7]));
//         // assertTrue(containsElement(fromLoupeSelectors, selectors[8]));
//         // assertTrue(containsElement(fromLoupeSelectors, selectors[9]));
//         assertFalse(containsElement(fromLoupeSelectors, ownerSel));
//         // assertFalse(containsElement(fromLoupeSelectors, selectors[10]));
//         // assertFalse(containsElement(fromLoupeSelectors, selectors[5]));
//     }
// }