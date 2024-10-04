// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title This is our generated token using the OpenZeppelin contracts.
 * @author Soumil Vavikar
 * @notice NA
 */
contract SV15Token is ERC20 {
    /**
     * The instance of ERC20 token from the Openzeppelin libarary contains all the functions implemented.
     */
    constructor(
        uint256 initialSupply
    ) ERC20(/* Name */ "SV15Token", /* Symbol */ "SV15T") {
        _mint(msg.sender, initialSupply);
    }

    /**
     * Implementing a new burnAmount function which calls the internal _burn function of the ERC20 contract
     *  - The _burn is implemented BUT is marked internal, hence we need to expose a new method in our contract to be able to call it.
     */
    function burnToken(address account, uint256 value) public {
        super._burn(account, value);
    }
}
