// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "./ERC20.sol";

contract MintableERC20 is ERC20 {
    constructor(string memory name, string memory symbol, uint8 decimals) ERC20(name, symbol, decimals) {}

    function mint() external payable {
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
    }

    function burn() external {
        (bool success, ) = payable(msg.sender).call{value: balanceOf[msg.sender]}(""); // <-- Reentrancy opening. Needs "call" as "transfer" limits the gas forwarded
        balanceOf[msg.sender] = 0;
        totalSupply -= balanceOf[msg.sender];
    }
}
