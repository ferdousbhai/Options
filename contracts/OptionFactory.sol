// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Option.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Creates and maintains a list of available option contracts.
 * @dev Owned by the OptionFactory contract that governs which strikes/assets/expiry time to issue contracts for.
 */
contract OptionFactory is Ownable {
    enum OptionType {Call, Put}

    Option[] public optionList;

    event NewOption(
        optionType _type,
        address _a,
        uint256 _t,
        uint256 _k,
        string _symbol,
        string _name
    );

    function createOption(
        optionType _type,
        address _a,
        uint256 _t,
        uint256 _k,
        string _symbol,
        string _name
    ) public onlyOwner {
        // create an option contract and push it to list of options:
        optionList.push(Option(_type, _a, _t, _k, _symbol, _name));
        emit NewOption(_type, _a, _t, _k, _symbol, _name);
    }
}
