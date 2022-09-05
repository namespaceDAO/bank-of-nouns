// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../treasury/CoinReserve.sol";
import "./PropHouse.sol";

struct Vote {
    uint propId;
    uint coinId;
    uint amount;
    uint castAt;
    bool support;
}

abstract contract CoinBox is PropHouse {
    CoinReserve private _coin;

    mapping(address => mapping(uint => Vote)) _votes;
    mapping(uint => uint) _totalSupport;
    mapping(uint => uint) _totalAgainst;

    function _meetsQuorum(uint prop, bool start) internal view returns (bool) {
        uint support = _totalSupport[prop];
        uint against = _totalAgainst[prop];

        if (against >= support) {
            return false;
        }

        uint startCash; uint endCash;
        (startCash, endCash) = _getCash(prop);
        uint ask = start ? startCash : endCash;
        uint bid = support - against;

        return bid > ask;
    }

    function _requireBalance(address owner, uint coinId, uint amount) internal view {
        require(
            _coin.balanceOf(owner, coinId) >= amount, 
            "You do not have enough of that coin"
        );
    }

    function _castVote(Vote memory vote) internal {
        address voter = msg.sender;

        _requireBalance(voter, vote.coinId, vote.amount);
        require(vote.propId <= propCount(), "That proposal was not found");

        // TODO: check if proposal has ended
        Vote storage v = _votes[voter][vote.propId];
        v.propId = vote.propId;
        v.coinId = vote.coinId;
        v.amount = vote.amount;
        v.castAt = block.timestamp;
        v.support = vote.support;

        // TODO: ensure that we dont allow double counting of votes
        uint total = _coin.conversionRate(v.coinId, v.amount);
        if (vote.support) {
            _totalSupport[vote.propId] += total;
        } else {
            _totalAgainst[vote.propId] += total;
        }
    }
}
