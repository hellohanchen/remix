// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyToken {
    address private _owner;
    
    mapping(string => address) private _owners;
    mapping(string => uint256) private _prices;
    mapping(string => mapping(address => bool)) private _approvals;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(_owner == msg.sender, "owner access only");
        
        _;
    }

    modifier videoExist(string memory vid) {
        require(_prices[vid] > 0, "video doesn't exist");

        _;
    }

    // TODO: use signature verification
    function addVideo(string memory vid, address creator, uint256 price) public onlyOwner {
        require(_prices[vid] == 0, "video already exist");
        require(price > 0, "price should be greater than 0 wei");

        _owners[vid] = creator;
        _prices[vid] = price;
    }

    function 
}
