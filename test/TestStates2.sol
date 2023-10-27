// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/******************************************************************************\
* Authors: Timo Neumann <timo@fyde.fi>, Rohan Sundar <rohan@fyde.fi>
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
* Abstract Contracts for the shared setup of the tests
/******************************************************************************/

import "../../shared/interfaces/IDiamondCut.sol";
import "../../shared/facets/DiamondCutFacet.sol";
import "../../shared/facets/DiamondLoupeFacet.sol";
import "../../shared/facets/OwnershipFacet.sol";
import "../src/facets/FundMeFacet.sol";
import "../src/Diamond.sol";
import "./HelperContract.sol";


abstract contract StateFundDeployDiamond is HelperContract {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;

    //interfaces with Facet ABI connected to diamond address
    IDiamondLoupe ILoupe;
    IDiamondCut ICut;

    string[] facetNames;
    address[] facetAddressList;

    // deploys diamond and connects facets
    function setUp() public virtual {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        facetNames = ["DiamondCutFacet", "DiamondLoupeFacet", "OwnershipFacet"];
        // diamod arguments
        DiamondArgs memory _args = DiamondArgs({
            owner: address(this),
            init: address(0),
            initCalldata: " "
        });
        // FacetCut with CutFacet for initialisation
        FacetCut[] memory cut0 = new FacetCut[](1);
        cut0[0] = FacetCut ({
            facetAddress: address(dCutFacet),
            action: IDiamond.FacetCutAction.Add,
            functionSelectors: generateSelectors("DiamondCutFacet")
        });
        // deploy diamond
        diamond = new Diamond(cut0, _args);
        //upgrade diamond with facets
        //build cut struct
        FacetCut[] memory cut = new FacetCut[](2);
        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );
        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );
        // initialise interfaces
        ILoupe = IDiamondLoupe(address(diamond));
        ICut = IDiamondCut(address(diamond));
        //upgrade diamond
        ICut.diamondCut(cut, address(0x0), "");
        // get all addresses
        facetAddressList = ILoupe.facetAddresses();
    }
}

// tests proper upgrade of diamond when adding a facet
abstract contract StateFundAddFacet1 is StateFundDeployDiamond{
    FundMeFacet fundMeFacet;

    function setUp() public virtual override {
        super.setUp();
        //deploy FundMeFacet
        fundMeFacet = new FundMeFacet();
        // get functions selectors but remove first element (supportsInterface)
        // bytes4[] memory fromGenSelectors = removeElement(uint(0), generateSelectors("FundMeFacet"));
        bytes4[] memory fromGenSelectors = generateSelectors("FundMeFacet");
        // array of functions to add
        // CONSOLE LOG STATEFUNDADDFACET1
        console.log("TESTSTATES2.SOL FundMeTest.t.sol");
        console.log("fromGenSelectors[0]:");
        console.logBytes4(fromGenSelectors[0]);   
        FacetCut[] memory facetCut = new FacetCut[](1);
        facetCut[0] =
        FacetCut({
            facetAddress: address(fundMeFacet),
            action: FacetCutAction.Add,
            functionSelectors: fromGenSelectors
        });
        // add functions to diamond
        ICut.diamondCut(facetCut, address(0x0), "");
    }
}

abstract contract StateCacheBug is StateFundDeployDiamond {
    FundMeFacet fundMeFacet;
    bytes4 ownerSel = hex'8da5cb5b'; // owner()
    bytes4[] selectors;
    function setUp() public virtual override {
        super.setUp();
        fundMeFacet = new FundMeFacet();
        selectors.push(hex'b60d4288'); // fund()
        selectors.push(hex'0d8e6e2c'); // getVersion()
        selectors.push(hex'3ccfd60b'); // withdraw()
        // selectors.push(hex'585582fb'); // supportsInterface()

        FacetCut[] memory cut = new FacetCut[](1);
        bytes4[] memory selectorsAdd = new bytes4[](3);
        
        console.log("StateCacheBug selectorsAdd[0]:");
        // console.logBytes4(selectorsAdd[0]);
        // console.logBytes4(selectorsAdd[1]);
        // console.logBytes4(selectorsAdd[2]);
        
        for(uint i = 0; i < selectorsAdd.length; i++){
            selectorsAdd[i] = selectors[i];
        }

        cut[0] = FacetCut({
            facetAddress: address(fundMeFacet),
            action: FacetCutAction.Add,
            functionSelectors: selectorsAdd
        });

        // add test1Facet to diamond
        ICut.diamondCut(cut, address(0x0), "");

        // Remove selectors from diamond
        bytes4[] memory newSelectors = new bytes4[](3);
        newSelectors[0] = ownerSel;
        newSelectors[1] = selectors[2];
        newSelectors[2] = selectors[1];

        cut[0] = FacetCut({
            facetAddress: address(0x0),
            action: FacetCutAction.Remove,
            functionSelectors: newSelectors
        });

        ICut.diamondCut(cut, address(0x0), "");
    }

}