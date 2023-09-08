// SPDX-License-Identifier: CC0 1.0 Universal
pragma solidity 0.8.19;

import { console2 } from "forge-std/console2.sol";
import { PRBTest } from "prb-test/PRBTest.sol";
import { StdCheats } from "forge-std/StdCheats.sol";
import "../src/WawaNFT.sol";
import { Wawa, Trait, Faction } from "../src/types/Wawa.sol";

contract WawaNFTTest is PRBTest, StdCheats {
    WawaNFT wawaNFT;
    address testAddress = address(0x5037e7747fAa78fc0ECF8DFC526DcD19f73076ce);

    function setUp() public {
        wawaNFT = new WawaNFT(payable(msg.sender));
    }

    function testDeployment() public {
        assertTrue(wawaNFT.ownerCheck(address(this)));
    }

    function testFail_GetAvatar() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        wawaNFT.getWawa(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
    }

    function test_GetAvatar() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });

        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        assertEq(wawaNFT.ownerOf(1), testAddress);
        assertEq(uint8(wawaNFT.getFaction(1)), uint8(Faction.Prima));
        assertEq(wawaNFT.getTokenURI(1), "https://token.uri/1");
    }

    function test_GetFactionCount() public {
        Trait memory trait1 = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        Trait memory trait2 = Trait({ headwear: 2, eyes: 2, chest: 2, legs: 2 });
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait1,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            2,
            "https://token.uri/2",
            Faction.Prima,
            trait2,
            2,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        assertEq(wawaNFT.getFactionCount(Faction.Prima), 2);
    }

    function test_GetWawaInfo() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        Wawa memory wawa = wawaNFT.getWawaInfo(1);
        assertEq(uint8(wawa.faction), uint8(Faction.Prima));
        assertEq(wawa.tokenURI, "https://token.uri/1");
        assertEq(wawa.petId, 1);
    }

    function testFail_SetFaction() public {
        vm.prank(testAddress);
        wawaNFT.setFaction(1, Faction.Zook);
    }

    function test_SetFaction() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        wawaNFT.setFaction(1, Faction.Zook);
        assertEq(uint8(wawaNFT.getFaction(1)), uint8(Faction.Zook));
    }

    function test_SetTokenURI() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        wawaNFT.setTokenURI(1, "https://token.uri/changed");
        assertEq(wawaNFT.getTokenURI(1), "https://token.uri/changed");
    }

    function test_RevertIf_setTokenURI_TokenURIAlreadyUsed() public {
        vm.prank(address(this));
        wawaNFT.setTokenURI(1, "https://token.uri/changed");

        vm.expectRevert(WawaNFT.TokenURIAlreadyUsed.selector);
        wawaNFT.setTokenURI(2, "https://token.uri/changed");
    }

    function test_SetPet() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        wawaNFT.setPet(1, 2);
        Wawa memory wawa = wawaNFT.getWawaInfo(1);
        assertEq(wawa.petId, 2);
        // Check the pet counts after setting the new petId
        assertEq(wawaNFT.getPetCount(1), 0);
        assertEq(wawaNFT.getPetCount(2), 1);
    }

    function test_SetGene() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        wawaNFT.setGene(1, 0x0220222222220202002222200000000202020022002000022000202022020220);
        Wawa memory wawa = wawaNFT.getWawaInfo(1);
        assertEq(wawa.gene, 0x0220222222220202002222200000000202020022002000022000202022020220);
    }

    function test_SetTrait() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        Trait memory newTrait = Trait({ headwear: 2, eyes: 2, chest: 2, legs: 2 });
        wawaNFT.setTrait(1, newTrait);
        Wawa memory wawa = wawaNFT.getWawaInfo(1);
        assertEq(wawa.trait.headwear, 2);
        assertEq(wawa.trait.eyes, 2);
        assertEq(wawa.trait.chest, 2);
        assertEq(wawa.trait.legs, 2);
    }

    function test_RevertIf_setTokenURI_NotOwner() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        vm.prank(testAddress);
        vm.expectRevert(MultiOwner.InvalidOwner.selector);
        wawaNFT.setTokenURI(1, "https://token.uri/changed"); // should fail
    }

    function test_RevertIf_setPet_NotOwner() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        vm.prank(testAddress);
        vm.expectRevert(MultiOwner.InvalidOwner.selector);
        wawaNFT.setPet(1, 2); // should fail
    }

    function test_RevertIf_setGene_NotOwner() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        vm.prank(testAddress);
        vm.expectRevert(MultiOwner.InvalidOwner.selector);
        wawaNFT.setGene(1, 0x0220222222220202002222200000000202020022002000022000202022020220); // should fail
    }

    function test_RevertIf_setTrait_NotOwner() public {
        Trait memory trait = Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 });
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            trait,
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );
        vm.prank(testAddress);
        Trait memory newTrait = Trait({ headwear: 2, eyes: 2, chest: 2, legs: 2 });
        vm.expectRevert(MultiOwner.InvalidOwner.selector);
        wawaNFT.setTrait(1, newTrait); // should fail
    }

    function testUri_ValidTokenID() public {
        // Mint a new token
        wawaNFT.getWawa{ value: 0.05 ether }(
            testAddress,
            1,
            "https://token.uri/1",
            Faction.Prima,
            Trait({ headwear: 1, eyes: 1, chest: 1, legs: 1 }),
            1,
            0x0110111111110101001111100000000101010011001000011000101011010110
        );

        // Check the token URI
        assertEq(wawaNFT.tokenURI(1), "https://token.uri/1");
    }

    function test_RevertIf_uri_NotCreatedTokenID() public {
        // An attempt to access a non-existent token should fail
        vm.expectRevert(WawaNFT.InvalidTokenID.selector);
        wawaNFT.tokenURI(1000);
    }

    function test_setSecondaryRoyalityFee() public {
        uint256 newSecondaryRoyalty = 2000; // 20%
        wawaNFT.setSecondaryRoyalityFee(newSecondaryRoyalty);
        assertEq(wawaNFT.secondaryRoyalty(), newSecondaryRoyalty, "The new secondary royalty should be set");
    }

    function test_receive() public {
        uint256 amount = 10 ether;
        vm.deal(testAddress, amount);
        uint256 initialBalance = wawaNFT.paymentBalanceOwner();
        (bool success,) = address(wawaNFT).call{ value: amount }("");
        require(success, "error");
        assertEq(
            wawaNFT.paymentBalanceOwner(),
            initialBalance + amount,
            "The payment balance should increase by the sent amount"
        );
    }

    function test_withdrawOwnerBalance() public {
        uint256 amount = 10 ether;
        (bool success,) = address(wawaNFT).call{ value: amount }("");
        require(success, "error");
        uint256 initialBalance = address(msg.sender).balance;
        wawaNFT.withdrawOwnerBalance(address(msg.sender));
        assertEq(
            address(msg.sender).balance,
            initialBalance + amount,
            "The owner balance should be withdrawn to the owner's address"
        );
    }

    function testFail_uri_NonExistentTokenId() public view {
        uint256 nonExistentTokenId = 999_999; // This token ID does not exist
        wawaNFT.tokenURI(nonExistentTokenId); // This should fail
    }

    function testFail_setSecondaryRoyalityFee_NotAdmin() public {
        uint256 newSecondaryRoyalty = 2000; // 20%
        vm.expectRevert("InvalidOwner()");
        wawaNFT.setSecondaryRoyalityFee(newSecondaryRoyalty); // This should fail because only the admin can set
            // the secondary royalty
    }

    function testFail_withdrawOwnerBalance_NotAdmin() public {
        vm.expectRevert("InvalidOwner()");
        wawaNFT.withdrawOwnerBalance(address(this)); // This should fail because only the admin can withdraw the
            // owner balance
    }
}
