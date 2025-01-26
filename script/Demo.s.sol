// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Demo} from "../src/Demo.sol";
import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract DemoScript is Script {
    Demo public demo;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        demo = new Demo{salt: bytes32(0)}();

        console.log("demo address", address(demo));

        IEntryPoint(0x0000000071727De22E5E9d8BAf0edAc6f37da032).depositTo{value: 1 ether}(address(demo));

        vm.stopBroadcast();
    }
}
