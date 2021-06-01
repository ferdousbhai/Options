// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title An option contract.
 * @dev An ERC20 token that represents a call or a put option contract.
 * The ERC20 contracts are initiated by the OptionFactory contract.
 * TO DO: Charge a flat fee for issuing contracts.
 * TO DO: Handle puts.
 * TO DO: Use correct units in transfer functions.
 */
contract Option is ERC20 {
    enum OptionType {Call, Put}
    OptionType optionType;
    IERC20 underlyingAsset; // the underlying asset
    IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    uint256 expiryTime; // expiry time
    uint256 strike; // strike price in DAI

    mapping(address => uint256) underlyingAssetBalances; // This is expensive. Is there a better way?
    uint256 totalAssetBalance; // Keeps track of amount of assets locked in to issue options.
    uint256 outstandingAssetBalance; // Keeps track of amount of assets not exercised yet.
    uint256 fee; // fee per contract issuance in DAI
    uint256 totalFees; // total fees collected in DAI

    address daoAddress; // fees will be sent here after contract expiry

    constructor(
        OptionType _type,
        address _underlyingAssetAddress,
        uint256 _t,
        uint256 _k,
        string memory _symbol,
        string memory _name
    ) ERC20(_symbol, _name) {
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

    function issue(uint256 _n) external notExpired {
        uint256 _a = _n * 100;
        underlyingAsset.transferFrom(msg.sender, address(this), _a);
        _mint(msg.sender, _n);
        underlyingAssetBalances[msg.sender] += _a;
        totalAssetBalance += _a;
        outstandingAssetBalance += _a;
    }

    function exercise(uint256 _n) external notExpired {
        // TO DO: require that the uniswap price (TWAP) of asset in DAI is more than the strike price.
        uint256 _a = _n * 100;
        DAI.transferFrom(msg.sender, address(this), _a * strike);
        this.transferFrom(msg.sender, address(this), _n);
        underlyingAsset.transfer(msg.sender, _a);
        outstandingAssetBalance -= _a;
    }

    function redeem() external expired {
        underlyingAsset.transfer(
            msg.sender,
            underlyingAssetBalances[msg.sender] *
                (outstandingAssetBalance / totalAssetBalance)
        );
        totalAssetBalance -= underlyingAssetBalances[msg.sender];
        outstandingAssetBalance -= underlyingAssetBalances[msg.sender];
        underlyingAssetBalances[msg.sender] = 0;
    }

    function collectFees() external expired {
        require(totalFees > 0, "Fees were already withdrawn!");
        require(msg.sender == daoAddress);
        DAI.transfer(daoAddress, totalFees);
        totalFees = 0;
    }
}
