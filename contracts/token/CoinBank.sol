// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./CoinMint.sol";
import "./CoinToken.sol";

abstract contract CoinBank {
    CoinMint private _mint;
    mapping(uint => CoinToken) private _tokens;

    function canonicalToken(uint coinId) external view returns (CoinToken) {
        CoinToken token = _tokens[coinId];
        _requireDeployed(token);
        return token;
    }

    function _deployToken(
        uint coinId_, 
        string memory name_, 
        string memory symbol_
    ) internal {
        CoinToken token = _tokens[coinId_];
        _requireNotDeployed(token);
        _tokens[coinId_] = new CoinToken(_mint, coinId_, name_, symbol_);
    }

    function _requireNotDeployed(CoinToken token) internal pure {
        require(!_isDeployed(token), "CoinBank: token has already been deployed");
    }

    function _requireDeployed(CoinToken token) internal pure {
        require(_isDeployed(token), "CoinBank: token has not been deployed");
    }

    function _isDeployed(CoinToken token) internal pure returns (bool) {
        return address(token) != address(0);
    }

    constructor(CoinMint mint_) {
        _mint = mint_;
    }
}


