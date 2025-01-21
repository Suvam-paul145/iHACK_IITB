// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
Code taken & adapted from https://github.com/smartcontractkit/ccip-defi-lending/blob/main/contracts/Protocol.sol
Currently being used to research for future implementations for our lending contractcs
*/

contract MockUSDC is ERC20, ERC20Burnable, Ownable {
  constructor() ERC20("MockUSDC", "MUSDC") {}

  function mint(address to, uint256 amount) public onlyOwner {
    _mint(to, amount);
  }
}