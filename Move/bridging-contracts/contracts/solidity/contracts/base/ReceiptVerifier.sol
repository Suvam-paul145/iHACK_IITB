// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Roles} from "./Roles.sol";

error AlreadyProcessed(bytes32);
error WrongSigner();
error WrongChain();

abstract contract ReceiptVerifier is Roles {
    using ECDSA for bytes32;

    struct Receipt {
        bytes from;
        bytes to;
        string tokenSymbol;
        uint256 amount;
        uint256 chainFrom;
        uint256 chainTo;
        uint256 nonce;
    }

    mapping(bytes32 => bool) public processed;

    function _useReceipt(Receipt memory _receipt, bytes memory _signature)
        internal
    {
        verifyChainId(_receipt);

        bytes32 hash = _buildHash(_receipt);

        doubleSpendGuard(hash);
        recoverOwner(hash, _signature);
    }

    function _buildHash(Receipt memory _receipt)
        private
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    _receipt.from,
                    _receipt.to,
                    _receipt.tokenSymbol,
                    _receipt.amount,
                    _receipt.chainFrom,
                    _receipt.chainTo,
                    _receipt.nonce
                )
            );
    }

    function doubleSpendGuard(bytes32 _processIdentifier) internal {
        if (processed[_processIdentifier])
            revert AlreadyProcessed(_processIdentifier);
        processed[_processIdentifier] = true;
    }

    function recoverOwner(bytes32 _hash, bytes memory _signature)
        internal
        view
    {
        address recovered = _hash.toEthSignedMessageHash().recover(_signature);
        if (recovered != signer) revert WrongSigner();
    }

    function verifyChainId(Receipt memory _receipt) internal view {
        if (_receipt.chainTo != block.chainid) revert WrongChain();
    }
}
