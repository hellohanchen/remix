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

    string constant public agreement = "I agree to sign the contract at [address]"; 

    function getMessageHash(
        string memory vid,
        uint256 price,
        uint256 nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(vid, price, agreement, nonce));
    }

    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }

    function verify(
        address signer,
        string memory vid,
        uint256 price,
        uint256 nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(vid, price, nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
