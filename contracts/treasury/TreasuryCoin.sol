// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./Treasury.sol";

abstract contract TreasuryCoin is Treasury, ERC1155 {
    uint private _totalSupply;
    mapping(uint => uint) _totalSupplies;

    function conversionRate(
        uint coinId, 
        uint amount
    ) virtual public view returns (uint);

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function totalSupplyOf(uint coinId) public view returns (uint) {
        return _totalSupplies[coinId];
    }

    function mint(address to, uint coinId) external payable {
        uint amount = conversionRate(coinId, msg.value);

        bytes memory data;
        _mint(to, coinId, amount, data);

        _totalSupplies[coinId] += amount;
        _totalSupply += amount;
    }

    constructor(
        string memory baseURI_,
        address adminAddress_, 
        address originAddress_
    ) 
    Treasury(adminAddress_, originAddress_)
    ERC1155(baseURI_) {}  
}
