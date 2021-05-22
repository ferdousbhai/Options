// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title An option contract.
 * @dev An ERC20 token that represents either call or a put option contract of an asset with a specific strike and expiry.
 * This contract is called by the OptionFactory contract.
 */
contract Option is ERC20 {
    enum OptionType {Call, Put}

    OptionType optionType;
    address asset_address; //underlying asset
    uint256 time;
    uint256 strike;

    address daoAddress;

    constructor(
        OptionType _type,
        address _a,
        uint256 _t,
        uint256 _k,
        string memory _symbol,
        string memory _name
    ) ERC20(_symbol, _name) {
        optionType = _type;
        asset_address = _a;
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

    function issue() public payable notExpired {
        _mint(msg.sender, msg.value / 100); //TO DO: How to specify that caller is sending underlying asset instead of 'msg.value'?
    }

    function exercise() public payable notExpired {
        // TO DO: receive strike price * unit of asset
        // TO DO: receive call contract token
        // TO DO: check that uniswap price of asset is more than strike
        // TO DO: send back the asset
    }

    function redeem() public payable expired {
        // TO DO: receive call contract token
        // TO DO: send back the asset to the user
    }
}
