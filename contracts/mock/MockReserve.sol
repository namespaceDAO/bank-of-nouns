// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../treasury/CoinReserve.sol";

contract MockReserve is CoinReserve {
    function mint(
        address to, 
        uint coinId, 
        bytes memory data
    ) external payable {
        _mintCoin(to, coinId, msg.value, data);
    }

    function conversionRate(uint, uint) override public pure returns (uint) {
        return 1;
    }

    constructor(string memory baseURI_) CoinReserve(baseURI_) {}    
}