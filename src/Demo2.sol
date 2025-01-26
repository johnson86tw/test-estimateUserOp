// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IAccount} from "@account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {ECDSA} from "solady/utils/ECDSA.sol";

contract Demo2 is IAccount {
    error NotFromEntryPoint();
    error ZeroAddress();

    address public callerFromValidation;
    address public caller;

    function setCaller() public {
        if (callerFromValidation == address(0)) {
            revert ZeroAddress();
        }

        caller = callerFromValidation;
    }

    error InvalidSigner();

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        onlyEntryPoint
        payPrefund(missingAccountFunds)
        returns (uint256 validationData)
    {
        bytes32 ethHash = ECDSA.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(ethHash, userOp.signature);

        // (1) pass
        // callerFromValidation = signer;
        // return 0;

        // (2) fail to estimateUserOp with error ZeroAddress()
        if (signer == 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266) {
            callerFromValidation = signer;
            return 0;
        }
        return 1;

        // (3) fail to estimateUserOp with error InvalidSigner()
        // if (signer == 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266) {
        //     callerFromValidation = signer;
        //     return 0;
        // }
        // revert InvalidSigner();
    }

    modifier payPrefund(uint256 missingAccountFunds) {
        _;
        /// @solidity memory-safe-assembly
        assembly {
            if missingAccountFunds {
                // Ignore failure (it's EntryPoint's job to verify, not the account's).
                pop(call(gas(), caller(), missingAccountFunds, codesize(), 0x00, codesize(), 0x00))
            }
        }
    }

    modifier onlyEntryPoint() virtual {
        if (msg.sender != entryPoint()) {
            revert NotFromEntryPoint();
        }
        _;
    }

    function entryPoint() public pure returns (address) {
        return 0x0000000071727De22E5E9d8BAf0edAc6f37da032; // v0.7
    }
}
