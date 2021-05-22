// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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
        string _symbol,
        string _name
    ) ERC20(_symbol, _name) {
        optionType = _type;
        asset_address = _a;
        time = _t;
        strike = _k;
    }

    function issue() public payable {
        require(block.timestamp < time);
        _mint(msg.sender, msg.value / 100); //How to specify that caller is sending underlying asset instead of ETH?
    }

    function exercise() public payable {
        require(block.timestamp < self.expiryTime);
        // receive strike price * unit of asset
        // check that msg.sender owns the call contract token
        // check that uniswap price of asset is more than strike
        // send back the asset
        // destroy call contract token
    }

    function finalize() public payable {
        require (block.timestamp >= self.expiryTime);
        // send back the locked assets
        selfdestruct(daoAddress);
    }
}


\



