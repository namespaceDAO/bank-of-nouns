// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

import "../token/CoinReserve.sol";
import "../token/Claimable.sol";
import "./NounsDescriptor.sol";

contract NounCoin is Claimable, CoinReserve {
    NounsDescriptor private _desc;
    uint private _ampl = 20000;  // basis points

    function mint(
        address to, 
        uint coinId, 
        bytes memory data
    ) external payable {
        require(msg.value > 0, "NounCoin: must mint some coins");
        uint amount = conversionRate(coinId, msg.value);
        _mint(to, coinId, amount, data);
        _updateTally(msg.value);
    }

    function mintBatch(
        address to,
        uint[] memory ids,
        bytes memory data
    ) external payable {
        require(msg.value > 0, "NounCoin: must mint some coins");
        
        uint split = msg.value / ids.length;
        uint[] memory amounts = new uint[](ids.length);
        
        for (uint i = 0; i < ids.length; i += 1) {
            amounts[i] = conversionRate(ids[i], split);
        }

        _mintBatch(to, ids, amounts, data);
        _updateTally(msg.value);
    }

    function conversionRate(
        uint coinId, 
        uint value
    ) public view override returns (uint) {
        uint heads = _desc.headCount();
        require(heads > 0 && coinId < heads, "Not enough heads");

        uint totalSupply = totalSupply();
        if (totalSupply == 0) {
            require(value * 2 >= heads, "Not enough coins");
            return value;  // seppuku mint;
        }

        uint amp = _ampl / 10000;
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

    function ampl() public view returns (uint) {
        return _ampl;
    }

    function setAmpl(uint ampl_) external onlyOwner {
        _ampl = ampl_;
    }

    function setDescriptor(NounsDescriptor desc_) external onlyOwner {
        _desc = desc_;
    }

    constructor(
        string memory baseURI_,
        NounsDescriptor desc_
    ) CoinReserve(baseURI_) { 
        _desc = desc_; 
    }
}