// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./Treasury.sol";

abstract contract CoinMint is ERC1155, Treasury {
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

    function _afterTokenTransfer(
        address,
        address from,
        address,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory
    ) internal override {
        if (from == address(0)) {
            for (uint i = 0; i < ids.length; i++) {
                uint id = ids[i];
                uint amount = amounts[i];
                _totalSupplies[id] += amount;
                _totalSupply += amount;
            }
        }
    }

    constructor(
        string memory baseURI_
    ) ERC1155(baseURI_) {}  
}
