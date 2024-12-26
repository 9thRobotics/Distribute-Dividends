// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DividendDistributor is ReentrancyGuard {
    mapping(address => uint256) public balances;
    address[] public holders;
    uint256 public totalSupply;

    address public admin;

    event DividendsDistributed(uint256 amount);
    event DepositReceived(uint256 amount);
    event HolderRegistered(address indexed holder, uint256 balance);
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function distributeDividends(uint256 amount) external onlyAdmin nonReentrant {
        require(amount <= address(this).balance, "Insufficient funds");
        for (uint256 i = 0; i < holders.length; i++) {
            uint256 share = (balances[holders[i]] * amount) / totalSupply;
            payable(holders[i]).transfer(share);
        }
        emit DividendsDistributed(amount);
    }

    function deposit() external payable onlyAdmin nonReentrant {
        emit DepositReceived(msg.value);
    }

    function registerHolder(address holder, uint256 balance) external onlyAdmin nonReentrant {
        if (balances[holder] == 0) {
            holders.push(holder);
        }
        balances[holder] = balance;
        totalSupply += balance;
        emit HolderRegistered(holder, balance);
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "New admin is the zero address");
        emit AdminTransferred(admin, newAdmin);
        admin = newAdmin;
    }
}
