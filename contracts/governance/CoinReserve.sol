// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./Treasury.sol";

abstract contract CoinReserve is ERC1155, Treasury {
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

    function _mintCoin(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal {
        require(amount > 0, "CoinTreasury: must mint some coins");
        _mint(to, id, amount, data);
        _totalSupplies[id] += amount;
        _totalSupply += amount;
    }

    constructor(string memory baseURI_) ERC1155(baseURI_) {}  
}
