// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MintableERC20} from "../src/MintableERC20.sol";
import {ReentrancyAttack, WITHDRAW_AMOUNT} from "../src/ReentrancyAttack.sol";

contract MintableERC20Test is Test {
    MintableERC20 public mintableERC20;
    ReentrancyAttack public reentrancyAttack;

    receive() external payable {}
    fallback () external payable {}

    function setUp() public {
        mintableERC20 = new MintableERC20("MintableERC20", "MINT", 18);
    }

    // MINT

    function test_mint() public {
        mintableERC20.mint{value: 1 wei}();
        assertEq(mintableERC20.balanceOf(address(this)), 1);
    }

    // BURN

    function testFuzz_burn(uint256 _amount) public {
        vm.assume(_amount <= address(this).balance);
        mintableERC20.mint{value: _amount}();
        mintableERC20.burn();
        assertEq(mintableERC20.balanceOf(address(this)), 0);
    }

    // REENTRANCY

    function test_ReentrancyAttack() public {
        // setup
        uint256 initialTreasury = WITHDRAW_AMOUNT * 2;
        address honestUser = address(0x69);
        vm.startPrank(honestUser);
        vm.deal(honestUser, initialTreasury);
        mintableERC20.mint{value: initialTreasury}();
        vm.stopPrank();

        // attempt reentrancy attack
        reentrancyAttack = new ReentrancyAttack(address(mintableERC20));
        reentrancyAttack.attack{value: WITHDRAW_AMOUNT}();
        assertEq(address(mintableERC20).balance, 0);
    }
}
