// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./Treasury.sol";

abstract contract CoinReserve is ERC1155, Treasury {
    uint private _totalSupply;
    uint private _totalMinted;
    uint private _originClaim;
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
        require(amount > 0, "CoinReserve: must mint some coins");
        _mint(to, id, amount, data);
        _totalSupplies[id] += amount;
        _totalSupply += amount;
        _totalMinted += msg.value;
    }

    function originClaim(address to, uint amount) external onlyOwner {
        uint max = _totalMinted / 10 - _originClaim;
        require(amount <= max, "CoinReserve: origin claim is too large");
        (bool success, ) = to.call{value:amount}("");
        require(success, "CoinReserve: transfer failed");
        _originClaim += amount;
    }

    constructor(string memory baseURI_) ERC1155(baseURI_) {}  
}
