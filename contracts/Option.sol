// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title An option contract.
 * @dev An ERC20 token that represents either a call or a put option contract of an asset with a specific strike and expiry.
 * The ERC20 contracts are initiated by the OptionFactory contract.
 * TO DO: Use DAI as base currency + charge a flat fee for issuing and exercising contracts. $10?
 * TO DO: Handle puts.
 */
contract Option is ERC20 {
    enum OptionType {Call, Put}

    OptionType optionType;
    IERC20 asset; // the underlying asset
    uint256 time;
    uint256 strike;

    mapping(address => uint256) asset_balance;
    uint256 total_asset_balance;
    uint256 outstanding_asset_balance;

    address daoAddress;

    constructor(
        OptionType _type,
        IERC20 _a,
        uint256 _t,
        uint256 _k,
        string memory _symbol,
        string memory _name
    ) ERC20(_symbol, _name) {
        optionType = _type;
        asset = _a;
        time = _t;
        strike = _k;
    }

    modifier notExpired() {
        require(block.timestamp < time, "Contract expired.");
        _;
    }

    modifier expired() {
        require(block.timestamp >= time, "Contract has not expired yet!");
        _;
    }

    function issue() external notExpired {
        _mint(msg.sender, msg.value / 100); //TO DO: How to check that the caller is sending units of underlying asset?
        asset_balance[msg.sender] += msg.value;
        total_asset_balance += msg.value;
        outstanding_asset_balance += msg.value;
    }

    function exercise() external notExpired {
        // TO DO: check that the uniswap price of asset in DAI is more than the strike price.
        // TO DO: receive strike price * unit of asset in DAI.
        // TO DO: receive call contract tokens, 'c' + burn the tokens.
        uint256 a = c * 100; // 'c' is the number of call contract tokens. 'a' is the units of asset to send back.
        asset.transfer(msg.sender, a);
        outstanding_asset_balance -= a;
    }

    function redeem() external expired {
        uint256 v =
            asset_balance[msg.sender] *
                (outstanding_asset_balance / total_asset_balance);
        asset.transfer(msg.sender, v);
        total_asset_balance -= asset_balance[msg.sender];
        outstanding_asset_balance -= asset_balance[msg.sender];
        asset_balance[msg.sender] = 0;
    }
}
