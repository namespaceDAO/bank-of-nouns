// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./Ledger.sol";
import "./Token.sol";

abstract contract Bank {
    Ledger private _ledger;
    mapping(uint => Token) private _tokens;

    function canonicalToken(uint coinId) external view returns (Token) {
        Token token = _tokens[coinId];
        _requireDeployed(token);
        return token;
    }

    function _deployToken(
        uint coinId_, 
        string memory symbol_
    ) internal {
        Token token = _tokens[coinId_];
        _requireNotDeployed(token);
        _tokens[coinId_] = new Token(_ledger, coinId_, symbol_);
    }

    function _requireNotDeployed(Token token) internal pure {
        require(!_isDeployed(token), "Bank: token has already been deployed");
    }

    function _requireDeployed(Token token) internal pure {
        require(_isDeployed(token), "Bank: token has not been deployed");
    }

    function _isDeployed(Token token) internal pure returns (bool) {
        return address(token) != address(0);
    }

    constructor(Ledger ledger_) {
        _ledger = ledger_;
    }
}


