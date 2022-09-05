// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../utils/Origin.sol";

contract Treasury is Origin {
    bool private _locked;
    address private _treasury;

    event MoveTreasury(address indexed previousAddress, address indexed newAddress);
    event LockTreasury(address indexed provenance);

    modifier onlyAdmin() {
        bool active = _treasury == msg.sender && _treasury != address(0);
        require(active, "Caller is not the treasury");
        _;
    }

    function transferFromTreasury(address to, uint amount) external onlyAdmin {
        require(address(this).balance >= amount, "Amount exceeds treasury balance");
        payable(to).transfer(amount);
    }

    function adminAddress() public view returns (address) { 
        return _treasury; 
    }    

    function moveTreasury(address to) external onlyOrigin {
        require(!_locked, "Treasury has been locked");
        address from = _treasury;
        _treasury = to;
        emit MoveTreasury(from, to);
    }

    function lockTreasury() external onlyOrigin {
        _locked = true;
        address oa = originAddress();
        emit LockTreasury(oa);
    }

    constructor(
        address adminAddress_, 
        address originAddress_
    ) Origin(originAddress_) {
        _treasury = adminAddress_;
    }
}
