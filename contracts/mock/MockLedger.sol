// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../token/Ledger.sol";

contract MockLedger is Ledger {
    function mint(
        address to, 
        uint coinId, 
        bytes memory data
    ) external payable {
        _mint(to, coinId, msg.value, data);
    }

    function conversionRate(uint, uint) override public pure returns (uint) {
        return 1;
    }

    function deployedTokenTransfer(
        address from, 
        address to, 
        uint coinId, 
        uint amount
    ) override external {}

    constructor(string memory baseURI_) Ledger(baseURI_) {}    
}