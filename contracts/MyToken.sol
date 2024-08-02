// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyToken {
    address private _owner;
    
    mapping(string => address payable) private _owners;
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
    function addVideo(string memory vid, address payable creator, uint256 price) public onlyOwner {
        require(_prices[vid] == 0, "video already exist");
        require(price > 0, "price should be greater than 0 wei");

        _owners[vid] = creator;
        _prices[vid] = price;
    }

    function getPrice(string memory vid) public view videoExist(vid) returns(uint256) {
        return _prices[vid];
    }

    function getOwner(string memory vid) public view videoExist(vid) returns(address) {
        return _owners[vid];
    }

    // TODO: use signature verification
    function buyVideo(string memory vid) public payable videoExist(vid) {
        require(msg.value >= _prices[vid], "not enough ether");

        uint256 price = _prices[vid];
        address payable to = _owners[vid];
        (bool sent, ) = to.call{value: price}("");
        require(sent, "failed to send ether");

        _approvals[vid][msg.sender] = true;
    }

    function checkApproval(string memory vid, address payer) public view returns(bool) {
        return _approvals[vid][payer];
    }
}
