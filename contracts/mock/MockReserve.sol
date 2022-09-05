// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../token/CoinMint.sol";

contract MockReserve is CoinMint {
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

    constructor(string memory baseURI_) CoinMint(baseURI_) {}    
}