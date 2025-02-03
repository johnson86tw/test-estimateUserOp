// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Demo3} from "../src/Demo3.sol";
import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract Demo3Script is Script {
    Demo3 public demo3;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        demo3 = new Demo3{salt: bytes32(0)}();

        console.log("demo3 address", address(demo3));

        IEntryPoint(0x0000000071727De22E5E9d8BAf0edAc6f37da032).depositTo{value: 1 ether}(address(demo3));

        vm.stopBroadcast();
    }
}
