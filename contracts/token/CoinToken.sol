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

    event CoinApproval(
        address indexed owner, 
        address indexed spender, 
        uint indexed coin, 
        uint value
    );

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint) {
        return _mint.totalSupplyOf(_coinId);
    }

    function balanceOf(address account) public view returns (uint) {
        return _mint.balanceOf(account, _coinId);
    }

    function transfer(address to, uint amount) public returns (bool) {
        bytes memory data;
        _mint.safeTransferFrom(msg.sender, to, _coinId, amount, data);
        return true;
    }

    function transferFrom(address from, address to, uint amount) public returns (bool) {
        // _spendAllowance(from, spender, amount);
        bytes memory data;
        _mint.safeTransferFrom(from, to, _coinId, amount, data);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender][_coinId];
    }

    function approve(address spender, uint amount) public returns (bool) {
        address owner = msg.sender;

        require(owner != address(0), "CoinApproval: approve from the zero address");
        require(spender != address(0), "CoinApproval: approve to the zero address");

        _allowances[owner][spender][_coinId] = amount;
        
        emit Approval(owner, spender, amount);
        emit CoinApproval(owner, spender, _coinId, amount);

        return true;
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
