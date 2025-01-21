// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {OwnableImmutable} from "./OwnableImmutable.sol";

abstract contract Roles is OwnableImmutable {
    address public signer;

    constructor(address _signer) {
        signer = _signer;
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }
}
