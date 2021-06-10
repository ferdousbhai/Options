// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./LockedAsset.sol";

/**
 * @title A call option contract. European options: no early exercise.
 * @dev An ERC20 token that represents a call option.
 * The end user can issue new supply by locking in the underlying asset.
 * TO DO: Handle decimals.
 */
contract CallOption is ERC20, ERC20Burnable {
    ERC20 underlyingAsset; // The underlying asset
    uint256 expiryTime; // expiry time
    uint256 strike; // strike price (in DAI)
    uint256 expiryPrice; // price at expiry time

    AggregatorV3Interface private priceFeed; // Chainlink oracle for determining price at expirty time

    ERC20 private DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    LockedAsset lockedAsset; // a mintable, burnable ERC20 that represents ownership of locked asset

    uint256 fee; // fee per contract issuance (in DAI)
    address daoAddress; // fees are sent here

    constructor(
        address _underlyingAssetAddress,
        address _priceFeed,
        uint256 _t,
        uint256 _k,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {
        underlyingAsset = ERC20(_underlyingAssetAddress);
        expiryTime = _t;
        strike = _k;
        lockedAsset = new LockedAsset(_name, _symbol);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    modifier notExpired() {
        require(block.timestamp < expiryTime, "Contract expired.");
        _;
    }

    modifier expired() {
        require(block.timestamp >= expiryTime, "Contract has not expired yet!");
        _;
    }

    function _getExpiryPrice() private view returns (uint256) {
        // 1. get the round ID of the latest round:
        (
            uint80 roundId,
            int256 _answer,
            uint256 _startedAt,
            uint256 roundTimestamp,
            uint80 _answeredInRound
        ) = priceFeed.latestRoundData();

        // 2. get the price right before 'expiryTime' by looping backward:
        int256 price;
        while (roundTimestamp > expiryTime) {
            roundId--;
            (
                uint80 _roundId_,
                int256 _price,
                uint256 _startedAt_,
                uint256 _updatedAt_,
                uint80 _answeredInRound_
            ) = priceFeed.getRoundData(roundId);
            roundTimestamp = _updatedAt_;
            price = _price;
        }

        // 3. Return 'price'
        return uint256(price);
    }

    function issue(uint256 _n) external notExpired {
        uint256 _a = _n * 100;
        underlyingAsset.transferFrom(msg.sender, address(this), _a);
        _mint(msg.sender, _n);
        lockedAsset.mint(msg.sender, _n);
    }

    function exercise(uint256 _n) external expired {
        if (expiryPrice == 0) {
            expiryPrice = _getExpiryPrice();
        }
        require(expiryPrice > strike);
        uint256 _a = _n * 100;
        this.burnFrom(msg.sender, _a);
        DAI.transferFrom(msg.sender, address(this), _a * strike);
        underlyingAsset.transfer(msg.sender, _a);
    }

    function redeemAsset(uint256 _a) external expired {
        lockedAsset.burnFrom(msg.sender, _a);
        if (expiryPrice > strike) {
            DAI.transfer(msg.sender, _a * strike);
        } else {
            underlyingAsset.transfer(msg.sender, _a);
        }
    }
}
