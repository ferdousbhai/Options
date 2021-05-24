// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Option.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Creates and maintains a list of available option contracts.
 * @dev Owned by the OptionFactory contract that governs which strikes/assets/expiry time to issue contracts for.
 */
contract OptionFactory is Ownable {
    Option[] optionList;

    function createOption(
        OptionType _type,
        address _a,
        uint256 _t,
        uint256 _k,
        string memory _symbol,
        string memory _name
    ) external onlyOwner {
        // create an option contract and push it to list of options:
        optionList.push(new Option(_type, _a, _t, _k, _symbol, _name));
    }
}
