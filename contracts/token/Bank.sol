// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./Deployable.sol";
import "./Ledger.sol";

abstract contract Bank is Deployable {
    constructor(string memory baseURI_) Ledger(baseURI_) {}
}


