// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console2} from "forge-std/Script.sol";
import {SV15Token} from "../src/SV15Token.sol";

contract DeploySV15Token is Script {
    uint256 public constant INITIAL_SUPPLY = 100000 ether;

    function run() external {
        vm.startBroadcast();
        new SV15Token(INITIAL_SUPPLY);
        vm.stopBroadcast();
    }
}
