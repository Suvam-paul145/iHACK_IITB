// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

error NotOwner();

abstract contract OwnableImmutable {
    address private immutable __owner;

    constructor(address _owner) {
        __owner = _owner;
    }

    modifier onlyOwner() {
        checkOwner(msg.sender);
        _;
    }

    function checkOwner(address _operator) internal view {
        if (_operator != owner()) revert NotOwner();
    }

    function owner() public view returns (address) {
        return __owner;
    }
}
