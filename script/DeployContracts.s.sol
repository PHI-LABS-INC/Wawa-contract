// SPDX-License-Identifier: CC0 1.0 Universal
pragma solidity 0.8.19;

import { Script } from "forge-std/Script.sol";
import { WawaNFT } from "../src/WawaNFT.sol";
import { GetWawa } from "../src/GetWawa.sol";

contract DeployContracts is Script {
    address internal deployer;

    WawaNFT internal wawaNFT;
    GetWawa internal getWawa;

    address constant adminSigner = 0xAA9bD7C35be4915dC1F18Afad6E631f0AfCF2461;
    address payable constant treasuryAddress = payable(address(0xDa6B83796cFb3958e709B96282c4f45E861D6E85));

    function setUp() public virtual {
        string memory mnemonic = vm.envString("MNEMONIC");
        (deployer,) = deriveRememberKey(mnemonic, 0);
    }

    function run() public {
        vm.startBroadcast(deployer);
        wawaNFT = new WawaNFT(treasuryAddress);
        getWawa = new GetWawa(adminSigner, address(wawaNFT));
        wawaNFT.setOwner(address(getWawa));
        vm.stopBroadcast();
    }
}
