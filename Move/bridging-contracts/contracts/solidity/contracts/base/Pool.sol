// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {OwnableImmutable} from "./OwnableImmutable.sol";
import {IMintableBurnable} from "contracts/interfaces/IMintableBurnable.sol";

error TokenIsNotSupported();

abstract contract Pool is OwnableImmutable {
    mapping(bytes32 => address) tokenSymbolHash2Address;

    function setTokenAddress(string calldata _tokenSymbol, address _address)
        external
        onlyOwner
    {
        tokenSymbolHash2Address[_symbol2hash(_tokenSymbol)] = _address;
    }

    function _mint(
        string memory _tokenSymbol,
        address _to,
        uint256 _amount
    ) internal {
        bytes32 hash = _symbol2hash(_tokenSymbol);

        if (tokenSymbolHash2Address[hash] == address(0))
            revert TokenIsNotSupported();

        IMintableBurnable(tokenSymbolHash2Address[hash]).mint(_to, _amount);
    }

    function _burn(
        string memory _tokenSymbol,
        address _from,
        uint256 _amount
    ) internal {
        bytes32 hash = _symbol2hash(_tokenSymbol);

        if (tokenSymbolHash2Address[hash] == address(0))
            revert TokenIsNotSupported();

        IMintableBurnable(tokenSymbolHash2Address[hash]).burn(_from, _amount);
    }

    function _symbol2hash(string memory _tokenSymbol)
        private
        pure
        returns (bytes32)
    {
        return keccak256(bytes(_tokenSymbol));
    }
}
