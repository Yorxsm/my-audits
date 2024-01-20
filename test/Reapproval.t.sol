// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "./Interface.sol";
import "solmate/ERC20.sol";


contract ReApprovalExploit is DSTest {
    ERC20 public newERC20;
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    
    function setUp() public {
        newERC20 = new ERC20("My Token", "MTK", 18);
        newERC20.mint(address(this), 1000 * 10 ** newERC20.decimals());
        
    }

    function testReapprovalVulnerability() public {

    address Alice = address(0x93f7d5fACedAb9C4dD128835532ED3E6389d5f0A);
    address Bob = address(0x7456fE0C3A3C0bceB6E1ae268e855198C3C8EDd4);

    // Alice mints 10 tokens for herself
    newERC20.mint(Alice, 10);

    // Alice approves Bob to spend 5 tokens on her behalf
    cheats.prank(Alice);
    newERC20.approve(Bob, 5);

    // Check that Bob's allowance is 5
    assertEq(newERC20.allowance(Alice, Bob), 5);

    // Bob tries to transfer 0 tokens from Alice to himself
    // This should not change the allowance
    cheats.prank(Bob);
    newERC20.transferFrom(Alice, Bob, 0);

    // Check that Bob's allowance is still 5
    assertEq(newERC20.allowance(Alice, Bob), 5);

    // Alice decreases Bob's allowance to 3 tokens
    cheats.prank(Alice);
    newERC20.approve(Bob, 3);

    // Check that Bob's allowance is now 3
    assertEq(newERC20.allowance(Alice, Bob), 3);

    // Bob tries to transfer 4 tokens from Alice to himself
    // This should fail because Bob's allowance is less than the amount
    cheats.prank(Bob);
    (bool success, ) = address(newERC20).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", Alice, Bob, 4));
    assertTrue(!success);


    // Check that Bob's allowance is still 3
    assertEq(newERC20.allowance(Alice, Bob), 3);

    newERC20.balanceOf(Alice);
    newERC20.balanceOf(Bob);
}

    // function testReapprovalVulnerability() public {
    //     assertTrue(true);
    // }
}