// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title An option contract.
 * @dev An ERC20 token that represents either a call or a put option contract of an asset with a specific strike and expiry.
 * The ERC20 contracts are initiated by the OptionFactory contract.
 * TO DO: Use DAI as base currency + charge a flat fee for issuing contracts.
 * TO DO: Handle puts.
 */
contract Option is ERC20 {
    enum OptionType {Call, Put}

    OptionType optionType;
    IERC20 underlyingAsset; // the underlying asset
    IERC20 DAI = IERC20(0x6b175474e89094c44da98b954eedeac495271d0f);
    uint256 expiryTime; // expiry time
    uint256 strike; // strike price in DAI

    mapping(address => uint256) asset_balances; // This is expensive. Is there a better way?
    uint256 total_asset_balance; // Keeps track of amount of assets locked in to issue options.
    uint256 outstanding_asset_balance; // Keeps track of amount of assets not exercised yet.
    uint256 fee; // fee per contract issuance in DAI
    uint256 total_fees; // total fees collected in DAI

    address daoAddress; // fees will be sent here after contract expiry

    constructor(
        OptionType _type,
        address _underlyingAssetAddress,
        uint256 _t,
        uint256 _k,
        string memory _symbol,
        string memory _name
    ) IERC20(_symbol, _name) {
        optionType = _type;
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

    function issue() external notExpired {
        //TO DO: receive the underlying asset
        _mint(msg.sender, msg.value / 100);
        asset_balances[msg.sender] += msg.value;
        total_asset_balance += msg.value;
        outstanding_asset_balance += msg.value;
    }

    function exercise() external notExpired {
        // TO DO: require that the uniswap price (TWAP) of asset in DAI is more than the strike price.
        // TO DO: receive strike price * unit of asset in DAI.
        // TO DO: receive call contract tokens, 'c'
        uint256 a = c * 100; // 'c' is the number of call contract tokens. 'a' is the units of asset to send back.
        underlyingAsset.transfer(msg.sender, a);
        outstanding_asset_balance -= a;
        // TO DO: burn the call contract tokens receiveed, 'c'
    }

    function redeem() external expired {
        underlyingAsset.transfer(
            msg.sender,
            asset_balances[msg.sender] *
                (outstanding_asset_balance / total_asset_balance)
        );
        total_asset_balance -= asset_balances[msg.sender];
        outstanding_asset_balance -= asset_balances[msg.sender];
        asset_balances[msg.sender] = 0;
    }

    function collectFees() external expired {
        require(total_fees > 0, "Fees were already withdrawn!");
        require(msg.sender == daoAddress);
        DAI.transfer(daoAddress, total_fees);
        total_fees = 0;
    }
}
