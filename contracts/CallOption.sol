// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @title A call option contract. European options: no early exercise.
 * @dev An ERC20 token that represents a call option.
 * The end user can issue new supply by locking in the underlying asset.
 */
contract CallOption is ERC20Burnable {
    IERC20 underlyingAsset; // the underlying asset
    ERC20Burnable lockedUnderlyingAsset =
        new ERC20Burnable(
            "Locked " & underlyingAsset.name(),
            "L" & underlyingAsset.symbol()
        );
    IERC20 DAI = IERC20(0x6b175474e89094c44da98b954eedeac495271d0f);

    uint256 expiryTime; // expiry time
    uint256 strike; // strike price in DAI
    uint256 expiryPrice; // price at expiry time

    uint256 fee; // fee per contract issuance in DAI

    address daoAddress; // fees are sent here

    constructor(
        address _underlyingAssetAddress,
        uint256 _t,
        uint256 _k,
        string memory _symbol,
        string memory _name
    ) IERC20(_symbol, _name) {
        underlyingAsset = IERC20(_underlyingAssetAddress);
        expiryTime = _t;
        strike = _k;
    }

    modifier notExpired() {
        require(block.timestamp < expiryTime, "Contract expired.");
        _;
    }

    modifier expired() {
        require(block.timestamp >= expiryTime, "Contract has not expired yet!");
        _;
    }

    function issue(uint256 _n) external notExpired {
        uint256 _a = _n * 100;
        underlyingAsset.transferFrom(msg.sender, address(this), _a);
        _mint(msg.sender, _n);
        // TODO: Issue '_a' unit of locked assets to 'msg.sender': lockedUnderlyingAsset.???
    }

    function exercise(uint256 _n) external expired {
        // TO DO: get 'expiryPrice' from an oracle
        require(expiryPrice > strike);
        uint256 _a = _n * 100;
        this(msg.sender).burn(_n);
        DAI.transferFrom(msg.sender, address(this), _a * strike);
        underlyingAsset.transfer(msg.sender, _a);
    }

    function redeemAsset(uint256 _a) external expired {
        lockedUnderlyingAsset.burn(_a);
        underlyingAsset.transfer(msg.sender, _a);
    }
}
