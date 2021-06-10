// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @title Option interface. European options: no early exercise.
 * @dev An ERC20 token that represents a call or a put option.
 */
abstract contract IOption is ERC20, ERC20Burnable {
    function issue(uint256 _n) external virtual;

    function exercise(uint256 _n) external virtual;

    function redeemAsset(uint256 _a) external virtual;
}
