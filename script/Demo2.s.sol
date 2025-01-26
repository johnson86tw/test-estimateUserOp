// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Demo2} from "../src/Demo2.sol";
import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract Demo2Script is Script {
    Demo2 public demo2;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        demo2 = new Demo2{salt: bytes32(0)}();

        console.log("demo2 address", address(demo2));

        IEntryPoint(0x0000000071727De22E5E9d8BAf0edAc6f37da032).depositTo{value: 1 ether}(address(demo2));

        vm.stopBroadcast();
    }
}
