// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import "remix_tests.sol"; 

import "../token.sol";

contract testSuite {
    XZTOKEN XZ;

    function before_all() public {
        XZ = new XZTOKEN();
    }

    function test_supply() public {
        Assert.equal(XZ.totalSupply(), 21000000 ether, "Supply is not 21 million;");
    }

    function test_mint_burn() public {

        // Add new client and burn all tokens
        XZ.client_add(address(this));
        XZ.burn(21000000 ether);

        // Reaching the spread limit
        XZ.mint(100000 ether);
        Assert.equal(XZ.balanceOf(address(this)),  100000 ether, "Amount is not 100000 token;");

        // Zero out spread
        XZ.client_zero(address(this));

        // Reaching the spread limit again
        XZ.mint(100000 ether);
        Assert.equal(XZ.balanceOf(address(this)),  200000 ether, "Amount is not 200000 token;");

        // Burn all tokens
        XZ.burn(200000 ether);
        Assert.equal(XZ.balanceOf(address(this)),  0 ether, "Amount is not 0 token;");
    }

    function test_overmint() public {

        // Hit the spread limit
        XZ.mint(100000 ether);
        Assert.equal(XZ.balanceOf(address(this)),  100000 ether, "Amount is not 100000 token;");

        try XZ.mint(1 ether) {
            Assert.ok(false, "Mint success;");
        } catch {
            Assert.ok(true, "Mint failed;");
        }
        Assert.equal(XZ.balanceOf(address(this)),  100000 ether, "Amount is not 100000 token;");

        // Zero out spread
        XZ.client_zero(address(this));

        // Mint more then spread
        try XZ.mint(100001 ether) {
            Assert.ok(false, "Mint success;");
        } catch {
            Assert.ok(true, "Mint failed;");
        } 
        Assert.equal(XZ.balanceOf(address(this)),  100000 ether, "Amount is not 100000 token;");

        // Burn all tokens
        XZ.burn(100000 ether);
    }

    function test_unauthorized() public {
        // remove client
        XZ.client_remove(address(this));

        // Try to mint
        try XZ.mint(1 ether) {
            Assert.ok(false, "Mint success;");
        } catch {
            Assert.ok(true, "Mint failed;");
        }
        Assert.equal(XZ.balanceOf(address(this)),  0, "Amount is not 0 token;");
    }
}
