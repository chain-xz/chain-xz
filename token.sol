// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract XZTOKEN is ERC20, ERC20Burnable, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private CLIENTS;
    mapping(address => uint256) private SPREADS;

    uint256 MINT = 21000000 ether;
    uint256 SPREAD = 100000 ether;

    constructor() ERC20("XZ Token", "XZ") Ownable(msg.sender) {
        _mint(msg.sender, MINT);
    }

    function mint(uint256 amount) public {
        SPREADS[msg.sender] += amount;
        mint_checks(msg.sender);
        _mint(msg.sender, amount);
    }

    function mint_checks(address client) private view {
        require(CLIENTS.contains(client), "Client is not trusted;");
        require(SPREADS[client] <= SPREAD, "Client already reached the SPREADS limit;" );
    }

    function burn(uint256 amount) public override {
        SPREADS[msg.sender] = SPREADS[msg.sender] > amount ?  SPREADS[msg.sender] - amount : 0;
        super.burn(amount);
    }

    function client_add(address client) public onlyOwner {
        CLIENTS.add(client);
    }

    function client_remove(address client) public onlyOwner {
        CLIENTS.remove(client);
    }

    function client_show() public view returns (address[] memory) {
        return CLIENTS.values();
    }

    function client_zero(address client) public onlyOwner {
        SPREADS[client] = 0;
    }

    function client_spreads(address client) public view returns (uint256) {
        return SPREADS[client];
    }

    function renounceOwnership() public view override onlyOwner {
        revert("renounceOwnership is disabled;");
    }

    function transferOwnership(address) public view override onlyOwner {
        revert("transferOwnership is disabled;");
    }
}
