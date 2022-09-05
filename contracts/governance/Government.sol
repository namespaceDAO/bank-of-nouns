// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/Pausable.sol";
import "../treasury/CoinReserve.sol";
import "../utils/Origin.sol";
import "./BallotBox.sol";

contract Government is BallotBox, Pausable, Origin {
    CoinReserve private _coin;

    function createProp(PropArgs memory prop) external whenNotPaused {
        _createProp(prop);
    }

    function startProp(uint id) external {
        if (_meetsQuorum(id, true)) {
            _startProp(id);
        }
    }

    function completeProp(uint id) external {
        _completeProp(id, _meetsQuorum(id, false));
    }
    
    function castVote(Vote memory vote) external {
        return _castVote(vote);
    }

    function castManyVotes(Vote[] memory votes) external {
        for (uint i = 0; i < votes.length; i += 1) {
            _castVote(votes[i]);
        }
    }

    function pause() external onlyOrigin {
        _pause();
    }

    function unpause() external onlyOrigin {
        _unpause();
    }

    constructor(
        address origin_,
        CoinReserve coin_
    ) Origin(origin_) {
        _coin = coin_;
    }
}
