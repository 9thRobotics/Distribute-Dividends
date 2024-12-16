// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DividendDistributor {
    mapping(address => uint256) public balances;
    address[] public holders;
    uint256 public totalSupply;

    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function distributeDividends(uint256 amount) external onlyAdmin {
        require(amount <= address(this).balance, "Insufficient funds");
        for (uint256 i = 0; i < holders.length; i++) {
            uint256 share = (balances[holders[i]] * amount) / totalSupply;
            payable(holders[i]).transfer(share);
        }
    }

    function deposit() external payable onlyAdmin {}

    function registerHolder(address holder, uint256 balance) external onlyAdmin {
        if (balances[holder] == 0) {
            holders.push(holder);
        }
        balances[holder] = balance;
        totalSupply += balance;
    }
}
