// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyToken {
    address private _owner;
    
    mapping(string => address) private videoOwners;
    mapping(string => uint256) private prices;
    mapping(string => mapping(address => bool)) private approvals;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(_owner == msg.sender, "owner access only");
        
        _;
    }

    
}
