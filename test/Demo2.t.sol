// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Demo2} from "../src/Demo2.sol";
import {PackedUserOperation} from "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {UserOperationLib} from "@account-abstraction/contracts/core/UserOperationLib.sol";
import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {EntryPoint} from "@account-abstraction/contracts/core/EntryPoint.sol";
import {ECDSA} from "solady/utils/ECDSA.sol";

contract Demo2Test is Test {
    using UserOperationLib for PackedUserOperation;

    IEntryPoint entryPoint;

    Demo2 public demo2;

    function setUp() public {
        EntryPoint ep = new EntryPoint();
        vm.etch(0x0000000071727De22E5E9d8BAf0edAc6f37da032, address(ep).code);
        entryPoint = IEntryPoint(0x0000000071727De22E5E9d8BAf0edAc6f37da032);

        demo2 = new Demo2();

        // deal demo
        deal(address(demo2), 1 ether);
    }

    function test_validateUserOp() public {
        uint256 privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        address signer = vm.addr(privateKey);
        PackedUserOperation memory userOp =
            _buildUserOp(privateKey, address(demo2), abi.encodeCall(demo2.setCaller, ()));
        _handleUserOp(userOp);

        assertEq(demo2.caller(), address(signer));
    }

    function _buildUserOp(uint256 privateKey, address sender, bytes memory callData)
        internal
        view
        returns (PackedUserOperation memory)
    {
        PackedUserOperation memory userOp = _createUserOp();
        userOp.sender = sender;
        userOp.nonce = entryPoint.getNonce(sender, 0);
        userOp.callData = callData;
        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(privateKey, ECDSA.toEthSignedMessageHash(entryPoint.getUserOpHash(userOp)));
        userOp.signature = abi.encodePacked(r, s, v);
        return userOp;
    }

    function _handleUserOp(PackedUserOperation memory userOp) internal {
        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = userOp;
        entryPoint.handleOps(ops, payable(msg.sender));
    }

    function _createUserOp() internal pure returns (PackedUserOperation memory) {
        return PackedUserOperation({
            sender: address(0),
            nonce: 0,
            initCode: bytes(""),
            callData: bytes(""),
            accountGasLimits: _pack(999_999, 999_999),
            preVerificationGas: 99_999,
            gasFees: _pack(999_999, 999_999),
            paymasterAndData: bytes(""),
            signature: bytes("")
        });
    }

    function _pack(uint256 a, uint256 b) internal pure returns (bytes32) {
        return bytes32((a << 128) | b);
    }

    function _logUserOp(PackedUserOperation memory userOp) internal pure {
        console.log("sender", userOp.sender);
        console.log("nonce", userOp.nonce);
        console.logBytes(userOp.initCode);
        console.logBytes(userOp.callData);
        console.logBytes32(userOp.accountGasLimits);
        console.log(_toHexString(userOp.preVerificationGas));
        console.logBytes32(userOp.gasFees);
        console.logBytes(userOp.paymasterAndData);
        console.logBytes(userOp.signature);
    }

    function _toHexString(uint256 a) internal pure returns (string memory) {
        uint256 count = 0;
        uint256 b = a;
        while (b != 0) {
            count++;
            b /= 16;
        }
        bytes memory res = new bytes(count);
        for (uint256 i = 0; i < count; ++i) {
            b = a % 16;
            res[count - i - 1] = _toHexDigit(uint8(b));
            a /= 16;
        }
        return string.concat("0x", string(res));
    }

    function _toHexDigit(uint8 d) internal pure returns (bytes1) {
        if (0 <= d && d <= 9) {
            return bytes1(uint8(bytes1("0")) + d);
        } else if (10 <= uint8(d) && uint8(d) <= 15) {
            return bytes1(uint8(bytes1("a")) + d - 10);
        }
        revert("Invalid hex digit");
    }
}
