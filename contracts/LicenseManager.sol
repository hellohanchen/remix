// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ILicense} from "./ILicense.sol";

type LID is uint256;

contract LicenseManager {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(_owner == msg.sender, "owner access only");
        
        _;
    }

    function transferOwnership(address owner) public onlyOwner() {
        _owner = owner;
    }

    // all kinds of licenses
    mapping(address => bool) private _templates;

    modifier templateExists(address template) {
        require(_templates[template], "license doesn't exist");

        _;
    }

    function addTemplate(address template) public onlyOwner {
        _templates[template] = true;
    }

    function removeTemplate(address template) public onlyOwner {
        _templates[template] = false;
    }

    string constant public licensorAgreement = "I certify that I am the licensor of the video agreement and agree to all terms defined in the agreement.";

    // all videos and licenses
    mapping(string => address payable) private _videoOwners;
    mapping(string => uint256) private _videoLicenseCounts;
    mapping(string => mapping(uint256 => LID)) private _videoLicenseIDs;

    mapping(LID => bool) private _licenseCreated;
    mapping(LID => bool) private _licenseActivated;
    mapping(LID => string) private  _licenseVideos;
    mapping(LID => uint256) private _licensePrices;
    mapping(LID => address) private _licenseTemplates;

    modifier videoExist(string memory vid) {
        require(_videoOwners[vid] != address(0), "video doesn't exist");

        _;
    }

    modifier licenseActive(LID licenseId) {
        require(_licenseActivated[licenseId], "license doesn't exist");

        _;
    }

    function getVideoOwner(string memory vid) public view returns(address) {
        return _videoOwners[vid];
    }

    function addVideo(string memory vid, address payable licensor, uint256 nonce, bytes memory signature) public onlyOwner {
        bytes memory vidBytes = bytes(vid); // Uses memory
        require(vidBytes.length > 0, "invalid video id");
        require(this.verifyLicensor(licensor, vid, nonce, signature), "invalid licensor signature");

        if (_videoOwners[vid] == address(0)) {
            _videoOwners[vid] = licensor;
        }
    }

    function createLicense(string memory vid, address template, uint256 price, LID licenseId) private {
        _licenseCreated[licenseId] = true;
        _licenseActivated[licenseId] = true;

        // one more license for this video
        uint256 count = _videoLicenseCounts[vid];
        _videoLicenseIDs[vid][count] = licenseId;
        _videoLicenseCounts[vid] = count + 1;
        
        // store license info
        _licenseVideos[licenseId] = vid;
        _licensePrices[licenseId] = price;
        _licenseTemplates[licenseId] = template;
    }

    function addLicense(string memory vid, address template, uint256 price, LID licenseId) public videoExist(vid) templateExists(template) {
        require(_videoOwners[vid] == msg.sender, "invalid licensor");
        require(!_licenseCreated[licenseId], "unavailable license id");
        
        createLicense(vid, template, price, licenseId);
    }

    function addVideoWithLicense(string memory vid, address payable licensor, uint256 nonce, bytes memory signature, address template, uint256 price, LID licenseId) public onlyOwner templateExists(template) {
        require(!_licenseCreated[licenseId], "unavailable license id");

        this.addVideo(vid, licensor, nonce, signature);
        createLicense(vid, template, price, licenseId);
    }

    function removeLicense(LID licenseId) public licenseActive(licenseId) {
        require(this.getLicenseOwner(licenseId) == msg.sender, "invalid licensor");
        _licenseActivated[licenseId] = false;
    }

    // get license info
    function getLicenseVideo(LID licenseId) public view licenseActive(licenseId) returns(string memory) {
        return _licenseVideos[licenseId];
    }

    function getLicenseOwner(LID licenseId) public view licenseActive(licenseId) returns(address payable ) {
        return _videoOwners[_licenseVideos[licenseId]];
    }

    function getLicensePrice(LID licenseId) public view licenseActive(licenseId) returns(uint256) {
        return _licensePrices[licenseId];
    }

    function getLicenseTemplate(LID licenseId) public view licenseActive(licenseId) returns(address) {
        return _licenseTemplates[licenseId];
    }

    // purchases
    string constant public licenseeAgreement = "I certify that I am the licensee of the video agreement and agree to all terms defined in the agreement.";

    mapping(LID => mapping(address => uint256)) private _licenseLicensees;

    function buyLicense(LID licenseId, uint256 nonce, bytes memory signature) public payable licenseActive(licenseId) {
        require(msg.value >= this.getLicensePrice(licenseId), "not enough ether");
        require(this.verifyLicensee(msg.sender, licenseId, nonce, signature), "invalid licensee signature");

        uint256 price = this.getLicensePrice(licenseId);
        address payable to = this.getLicenseOwner(licenseId);
        (bool sent, ) = to.call{value: price}("");
        require(sent, "failed to send ether");

        _licenseLicensees[licenseId][msg.sender] = block.timestamp;
    }

    function getLicenseeLicenses(string memory vid, address licensee) public videoExist(vid) view returns(LID[] memory) {
        LID[] memory purchased = new LID[](_videoLicenseCounts[vid]);

        for (uint256 i = 0; i < _videoLicenseCounts[vid]; i++) {
            LID licenseId = _videoLicenseIDs[vid][i];
            
            if (_licenseLicensees[licenseId][licensee] != 0) {
                purchased[i] = licenseId;
            }
        }

        return purchased;
    }

    function composeLicense(LID licenseId, address licensee) public licenseActive(licenseId) view returns(string memory) {
        require(_licenseLicensees[licenseId][licensee] != 0, "invalid licensee");

        string memory vid = _licenseVideos[licenseId];
        address licensor = _videoOwners[vid];
        address template = _licenseTemplates[licenseId];

        uint256 price = _licensePrices[licenseId];
        uint256 timestamp = _licenseLicensees[licenseId][licensee];

        ILicense license = ILicense(template);
        return license.compose(vid, licensor, licensee, price, timestamp);
    }

    // signature section
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }

    function getLicensorMessageHash(string memory vid, uint256 nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(vid, licensorAgreement, nonce));
    }

    function verifyLicensor(address signer, string memory vid, uint256 nonce, bytes memory signature) public pure returns (bool) {
        bytes32 messageHash = getLicensorMessageHash(vid, nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    function getLicenseeMessageHash(LID licenseId, uint256 nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(licenseId, licenseeAgreement, nonce));
    }

    function verifyLicensee(address signer, LID licenseId, uint256 nonce, bytes memory signature) public pure returns (bool) {
        bytes32 messageHash = getLicenseeMessageHash(licenseId, nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
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
