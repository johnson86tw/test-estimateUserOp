// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IAccount} from "@account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {ECDSA} from "solady/utils/ECDSA.sol";

contract Demo3 is IAccount {
    error NotFromEntryPoint();
    error ZeroAddress();
    error InvalidSigner();

    /// @dev cast index-erc7201 demo3.transient.signer
    bytes32 private constant TRANSIENT_SIGNER_SLOT = 0xf30e21ec4256e7bcdea3cd539c9ea8e63d168c7223f65ecbb5ec52fc5a887000;

    address public callerFromValidation;
    address public caller;

    function setCaller() public {
        address signer;
        assembly {
            signer := tload(TRANSIENT_SIGNER_SLOT)
        }

        if (signer == address(0)) {
            revert ZeroAddress();
        }

        caller = signer;
    }

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        onlyEntryPoint
        payPrefund(missingAccountFunds)
        returns (uint256 validationData)
    {
        bytes32 ethHash = ECDSA.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(ethHash, userOp.signature);
        uint192 nonceKey = uint192(userOp.nonce >> 64);
        address signerAddress = address(uint160(nonceKey));

        // 權限驗證
        if (signerAddress == 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266) {
            assembly {
                tstore(TRANSIENT_SIGNER_SLOT, signerAddress)
            }

            // 簽章驗證
            if (signer != signerAddress) {
                return 1;
            }

            return 0;
        }

        revert InvalidSigner();
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
