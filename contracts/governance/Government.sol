// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../token/CoinReserve.sol";
import "./CoinBox.sol";

contract Government is CoinBox, Pausable, Ownable {
    CoinReserve private _coin;

    function createProp(PropArgs memory prop) external whenNotPaused {
        _createProp(prop);
    }

    function startProp(uint id) external {
        require(_isStartable(id), "Government: prop cannot be started");
        _startProp(id);
    }

    function completeProp(uint id) external {
        bool completed = _isCompleted(id);
        _completeProp(id, completed);
    }
    
    function castVote(Vote memory vote) external {
        return _castVote(vote);
    }

    function castManyVotes(Vote[] memory votes) external {
        for (uint i = 0; i < votes.length; i += 1) {
            _castVote(votes[i]);
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    constructor(CoinReserve coin_) {
        _coin = coin_;
    }
}
