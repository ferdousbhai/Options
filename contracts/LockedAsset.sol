// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; //why is it only an abstract contract?
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Mintable.sol"; //why is it missing in npm?

/**
 * @title Represents right to a token holder who locked an asset in exchange of a call option
 * @dev An ERC20 token that represents an asset locked to issue a call option against it.
 * The owner can return the token after expiry of the option to recoup the asset
 * (unless the asset was exercised - in which case the owner receives the strike price).
 */
contract LockedAsset is ERC20, ERC20Burnable, ERC20Mintable {

}
