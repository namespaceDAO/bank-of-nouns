// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./CoinMint.sol";

contract CoinToken is IERC20 {
    CoinMint private _mint;

    uint private _coinId;
    string private _name;
    string private _symbol;

    mapping(address => mapping(address => mapping(uint => uint))) private _allowances;

    function id() external view returns (uint) {
        return _coinId;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() external view returns (uint) {
        return _mint.totalSupplyOf(_coinId);
    }

    function balanceOf(address account) external view returns (uint) {
        return _mint.balanceOf(account, _coinId);
    }

    function transfer(address to, uint amount) external returns (bool) {
        bytes memory data;
        _mint.safeTransferFrom(msg.sender, to, _coinId, amount, data);
        return true;
    }

    function transferFrom(address from, address to, uint amount) external returns (bool) {
        bytes memory data;
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _mint.safeTransferFrom(from, to, _coinId, amount, data);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint) {
        return _allowances[owner][spender][_coinId];
    }

    function approve(address spender, uint amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender, 
        uint amount
    ) internal returns (bool) {
        require(owner != address(0), "CoinApproval: approve from the zero address");
        require(spender != address(0), "CoinApproval: approve to the zero address");

        _allowances[owner][spender][_coinId] = amount;
        
        emit Approval(owner, spender, amount);

        return true;
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint amount
    ) internal virtual {
        uint currentAllowance = _allowances[owner][spender][_coinId];
        if (currentAllowance != type(uint).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    constructor(
        CoinMint mint_, 
        uint coinId_,
        string memory name_,
        string memory symbol_
    ) {
        _mint = mint_;
        _coinId = coinId_;
        _name = name_;
        _symbol = symbol_;
    }
}
