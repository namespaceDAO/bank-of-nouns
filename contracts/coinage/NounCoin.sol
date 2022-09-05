// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../treasury/TreasuryCoin.sol";
import "./NounsDescriptor.sol";

contract NounCoin is TreasuryCoin {
    uint private _amplBPS = 20000;
    NounsDescriptor private _desc;

    function conversionRate(
        uint coinId, uint value
    ) public view override returns (uint) {
        uint heads = _desc.headCount();
        require(heads > 0 && coinId <= heads, "Not enough heads");

        uint totalSupply = totalSupply();
        if (totalSupply == 0) {
            require(value * 2 >= heads, "Not enough coins");
            return value;  // seppuku mint;
        }

        uint amp = _amplBPS / 10000;
        uint avgSupply = totalSupply / heads;
        uint tokenSupply = _totalSupplies[coinId];

        if (tokenSupply > avgSupply * amp) {
            return value / amp;
        }

        if (avgSupply > tokenSupply * amp) {
            return value * amp;
        }

        return value * avgSupply / tokenSupply;
    }

    function descriptor() public view returns (NounsDescriptor) {
        return _desc;
    }

    function amplBPS() public view returns (uint) {
        return _amplBPS;
    }

    function setAmpl(uint amplBPS_) external onlyOrigin {
        _amplBPS = amplBPS_;
    }

    function setDescriptor(NounsDescriptor desc_) external onlyOrigin {
        _desc = desc_;
    }

    constructor(
        NounsDescriptor desc_,
        string memory baseURI_,
        address adminAddress_, 
        address originAddress_
    ) TreasuryCoin(baseURI_, adminAddress_, originAddress_) { 
        _desc = desc_; 
    }    
}