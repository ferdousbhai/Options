// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Option.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Call option contract
 * @dev An ERC20 token that represents a call option contract of an asset with a specific strike and expiry.
 * This contract will be called by a DAO contract that governs which strikes/assets/expiry time to issue contracts for.
 */
contract OptionFactory is Ownable {
    Option[] public optionList;

    event NewOption {
        optionType _type,
        address _a,
        uint256 _t,
        uint256 _k,
        string _symbol,
        string _name
    }

    function createOption(
        optionType _type,
        address _a,
        uint256 _t,
        uint256 _k,
        string _symbol,
        string _name
    ) public onlyOwner {
        // Owner is the account that deployed this contract, i.e., the DAO contract.
        optionList.push(Option(_type, _a, _t, _k, _symbol, _name));
        emit NewOption(_type, _a, _t, _k, _symbol, _name);
    }
}
