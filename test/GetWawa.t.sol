// SPDX-License-Identifier: CC0 1.0 Universal
pragma solidity 0.8.19;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "prb-test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import "../src/GetWawa.sol";
import "../src/WawaNFT.sol";
import { Trait, Faction } from "../src/types/Wawa.sol";

contract GetWawaTest is PRBTest, StdCheats {
    GetWawa getWawa;
    WawaNFT wawaNFT;
    address admin = vm.addr(1);
    address testAddress = address(0x5037e7747fAa78fc0ECF8DFC526DcD19f73076ce);
    address constant adminSigner = 0xAA9bD7C35be4915dC1F18Afad6E631f0AfCF2461;
    address payable constant treasuryAddress = payable(address(0xe35E5f8B912C25cDb6B00B347cb856467e4112A3));
    uint256 tempExpiresIn = 1_696_032_000;

    function setUp() public {
        vm.startPrank(admin);
        wawaNFT = new WawaNFT(treasuryAddress);
        getWawa = new GetWawa(adminSigner, address(wawaNFT));

        wawaNFT.setOwner(address(getWawa));
        vm.stopPrank();
    }

    function test_Constructor() external {
        assertTrue(address(getWawa) != address(0));
        assertEq(getWawa.adminSigner(), adminSigner);
        assertEq(wawaNFT.totalSupply(), 0);
    }

    function test_ClaimWawa() external {
        string memory tokenURI = "https://arweave.net/rL5L2H5BLDwyojZtOi-7TSCqFM7ISlsDOIlAfTUs5es";
        Faction faction = Faction.Prima;
        Trait memory trait = Trait({ headwear: 3, eyes: 4, chest: 7, legs: 3 });
        uint8 pet = 6;
        GetWawa.Coupon memory goodCoupon = GetWawa.Coupon({
            r: bytes32(0xe5d8c0e223dc6861fd681f03e4edea783ddfa93a71f156d77c7caab3a2752117),
            s: bytes32(0x1bd0d4a75f356d860f9b8afaf53f65d9eca40421e0ac42fde3b9d5a102d246cf),
            v: 27
        });
        bytes32 gene = 0x0001110101110100110110011001101101010100001010111000001100010010;
        vm.deal(testAddress, 0.05 ether);
        vm.prank(testAddress);
        getWawa.claimWawa{ value: 0.05 ether }(tokenURI, faction, trait, pet, gene, tempExpiresIn, goodCoupon);
    }

    function test_RevertIf_SetAdminSigner_WithZeroAddress() external {
        vm.prank(admin);
        vm.expectRevert(GetWawa.ZeroAddressNotAllowed.selector);
        getWawa.setAdminSigner(address(0));
    }

    function testFail_ClaimWawa_WithInvalidCoupon() external {
        string memory tokenURI = "uri";
        Faction faction = Faction.Prima;
        Trait memory trait;
        uint8 pet = 1;
        GetWawa.Coupon memory invalidCoupon = GetWawa.Coupon({ r: bytes32(0), s: bytes32(0), v: 0 });
        bytes32 gene = 0x0110111111110101001111100000000101010011001000011000101011010110;

        getWawa.claimWawa(tokenURI, faction, trait, pet, gene, tempExpiresIn, invalidCoupon);
    }

    function test_SetOwner() public {
        // Ensure a new owner can be added
        vm.startPrank(admin);
        getWawa.setOwner(address(0x1));
        vm.stopPrank();
        assertTrue(getWawa.ownerCheck(address(0x1)));
    }

    function test_RemoveOwner() public {
        // Add a new owner, then remove them
        vm.startPrank(admin);
        getWawa.setOwner(address(0x1));
        getWawa.removeOwner(address(0x1));
        vm.stopPrank();
        assertFalse(getWawa.ownerCheck(address(0x1)));
    }

    function trySetOwner(address newOwner) external {
        getWawa.setOwner(newOwner);
    }

    function tryRemoveOwner(address oldOwner) external {
        getWawa.removeOwner(oldOwner);
    }

    function test_ValidAdminSigner() external {
        address newAdminSigner = address(0xbB9BD7c35Be4915DC1F18aFaD6e631F0afcf2462);
        vm.prank(admin);
        getWawa.setAdminSigner(newAdminSigner);
        assertEq(getWawa.adminSigner(), newAdminSigner);
    }

    function test_RevertIf_ValidAdminSigner_WithoutPermission() external {
        address newAdminSigner = address(0xbB9BD7c35Be4915DC1F18aFaD6e631F0afcf2462);
        vm.prank(testAddress);
        vm.expectRevert(MultiOwner.InvalidOwner.selector);
        getWawa.setAdminSigner(newAdminSigner);
    }

    function test_hasClaimed() external {
        string memory tokenURI = "https://arweave.net/rL5L2H5BLDwyojZtOi-7TSCqFM7ISlsDOIlAfTUs5es";
        Faction faction = Faction.Prima;
        Trait memory trait = Trait({ headwear: 3, eyes: 4, chest: 7, legs: 3 });
        uint8 pet = 6;
        GetWawa.Coupon memory goodCoupon = GetWawa.Coupon({
            r: bytes32(0xe5d8c0e223dc6861fd681f03e4edea783ddfa93a71f156d77c7caab3a2752117),
            s: bytes32(0x1bd0d4a75f356d860f9b8afaf53f65d9eca40421e0ac42fde3b9d5a102d246cf),
            v: 27
        });
        bytes32 gene = 0x0001110101110100110110011001101101010100001010111000001100010010;
        vm.deal(testAddress, 0.05 ether);
        vm.prank(testAddress);
        getWawa.claimWawa{ value: 0.05 ether }(tokenURI, faction, trait, pet, gene, tempExpiresIn, goodCoupon);
        assertEq(getWawa.hasClaimed(testAddress, faction), 1);
    }

    function test_RevertIf_hasClaimed_WithoutPayment() external {
        string memory tokenURI = "https://arweave.net/rL5L2H5BLDwyojZtOi-7TSCqFM7ISlsDOIlAfTUs5es";
        Faction faction = Faction.Prima;
        Trait memory trait = Trait({ headwear: 3, eyes: 4, chest: 7, legs: 3 });
        uint8 pet = 6;
        GetWawa.Coupon memory goodCoupon = GetWawa.Coupon({
            r: bytes32(0xe5d8c0e223dc6861fd681f03e4edea783ddfa93a71f156d77c7caab3a2752117),
            s: bytes32(0x1bd0d4a75f356d860f9b8afaf53f65d9eca40421e0ac42fde3b9d5a102d246cf),
            v: 27
        });
        bytes32 gene = 0x0001110101110100110110011001101101010100001010111000001100010010;
        vm.prank(testAddress);
        vm.expectRevert(WawaNFT.SentAmountDoesNotMatch.selector);
        getWawa.claimWawa(tokenURI, faction, trait, pet, gene, tempExpiresIn, goodCoupon);
    }

    function test_RevertIf_hasClaimed_InvalidCoupon() external {
        string memory tokenURI = "https://arweave.net/P5kBDZVB5_PYppwCZPggvR5OZLh8yAq_DGwjf0cQenM";
        Faction faction = Faction.Prima;
        Trait memory trait = Trait({ headwear: 3, eyes: 4, chest: 6, legs: 3 });
        uint8 pet = 6;
        GetWawa.Coupon memory badCoupon = GetWawa.Coupon({
            r: bytes32(0xf2f0807b8e3615e80670e3bfa1ea2a4b0cc0b91109a01d9a9731aca364cce485),
            s: bytes32(0x67cabeb63c99f45211ff500d5c5b5b20e143bb938a2cc8cf3c8c5b50004536e4),
            v: 28 // Invalid 'v'
         });
        bytes32 gene = 0x1001111111000010101000110110011101011101111100111010110101110110;
        vm.deal(testAddress, 0.05 ether);
        vm.prank(testAddress);
        vm.expectRevert(GetWawa.InvalidCoupon.selector);
        getWawa.claimWawa{ value: 0.05 ether }(tokenURI, faction, trait, pet, gene, tempExpiresIn, badCoupon);
    }
}
