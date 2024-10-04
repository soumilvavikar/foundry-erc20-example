// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "../src/ManualToken.sol";

/**
 *
 * @title ManualTokenTest
 * @author Soumil Vavikar
 * @notice This test file is auto generated using AI and on top, made changes to make it work as expected.
 */
contract ManualTokenTest is Test {
    ManualToken public token;
    address public owner;
    address public user1;
    address public user2;
    uint256 public constant INITIAL_SUPPLY = 1000000;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        token = new ManualToken(INITIAL_SUPPLY, "ManualToken", "MT");
    }

    function testInitialSupply() public view {
        assertEq(
            token.totalSupply(),
            INITIAL_SUPPLY * 10 ** uint256(token.decimals()),
            "Initial supply should be set correctly"
        );
    }

    function testTokenNameAndSymbol() public view {
        assertEq(
            token.name(),
            "ManualToken",
            "Token name should be set correctly"
        );
        assertEq(token.symbol(), "MT", "Token symbol should be set correctly");
    }

    function testBalanceOf() public view {
        assertEq(
            token.balanceOf(owner),
            token.totalSupply(),
            "Owner should have all initial tokens"
        );
    }

    function testTransfer() public {
        uint256 amount = 100 * 10 ** uint256(token.decimals());

        bool success = token.transfer(user1, amount);

        assertTrue(success, "Transfer should be successful");
        assertEq(
            token.balanceOf(user1),
            amount,
            "Recipient should receive correct amount"
        );
        assertEq(
            token.balanceOf(owner),
            token.totalSupply() - amount,
            "Sender balance should be reduced"
        );
    }

    function testApproveAndTransferFrom() public {
        uint256 amount = 100 * 10 ** uint256(token.decimals());
        token.approve(user1, amount);

        assertEq(
            token.allowance(owner, user1),
            amount,
            "Allowance should be set correctly"
        );

        vm.prank(user1);
        bool success = token.transferFrom(owner, user2, amount);

        assertTrue(success, "TransferFrom should be successful");
        assertEq(
            token.balanceOf(user2),
            amount,
            "Recipient should receive correct amount"
        );
        assertEq(
            token.balanceOf(owner),
            token.totalSupply() - amount,
            "Owner balance should be reduced"
        );
        assertEq(token.allowance(owner, user1), 0, "Allowance should be spent");
    }

    function testBurn() public {
        uint256 amount = 100 * 10 ** uint256(token.decimals());
        uint256 initialSupply = token.totalSupply();

        bool success = token.burn(amount);

        assertTrue(success, "Burn should be successful");
        assertEq(
            token.totalSupply(),
            initialSupply - amount,
            "Total supply should be reduced"
        );
        assertEq(
            token.balanceOf(owner),
            initialSupply - amount,
            "Owner balance should be reduced"
        );
    }

    function testBurnFrom() public {
        uint256 amount = 100 * 10 ** uint256(token.decimals());
        uint256 totalSupplyBeforeBurn = token.totalSupply();
        uint256 ownerBalancneBeforeBurn = token.balanceOf(owner);

        token.approve(user1, amount);
        vm.prank(user1);
        bool success = token.burnFrom(owner, amount);

        assertTrue(success, "BurnFrom should be successful");
        assertEq(
            token.totalSupply(),
            totalSupplyBeforeBurn - amount,
            "Total supply should be reduced"
        );
        assertEq(
            token.balanceOf(owner),
            ownerBalancneBeforeBurn - amount,
            "Owner balance should be reduced"
        );
        assertEq(token.allowance(owner, user1), 0, "Allowance should be spent");
    }

    function testTransferEvent() public {
        uint256 amount = 100 * 10 ** uint256(token.decimals());
        vm.expectEmit(true, true, false, true);
        emit ManualToken.Transfer(owner, user1, amount);
        token.transfer(user1, amount);
    }

    function testApprovalEvent() public {
        uint256 amount = 100 * 10 ** uint256(token.decimals());
        vm.expectEmit(true, true, false, true);
        emit ManualToken.Approval(owner, user1, amount);
        token.approve(user1, amount);
    }

    function testBurnEvent() public {
        uint256 amount = 100 * 10 ** uint256(token.decimals());
        vm.expectEmit(true, false, false, true);
        emit ManualToken.Burn(owner, amount);
        token.burn(amount);
    }
}
