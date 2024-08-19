// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ILicense} from "./ILicense.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Returns the decimal string representation of value
function itoa(uint256 value) pure returns (string memory) {
    // Count the length of the decimal string representation
    uint256 length = 1;
    uint256 v = value;
    while ((v /= 10) != 0) {
        length++;
    }

    // Allocated enough bytes
    bytes memory result = new bytes(length);

    // Place each ASCII string character in the string,
    // right to left
    while (true) {
        length--;

        // The ASCII value of the modulo 10 value
        result[length] = bytes1(uint8(0x30 + (value % 10)));

        value /= 10;

        if (length == 0) {
            break;
        }
    }

    return string(result);
}

type LID is uint256;

contract LicenseManager {
    address private _owner;

    constructor(address owner) {
        _owner = owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "owner access only");

        _;
    }

    function transferOwnership(address owner) public onlyOwner {
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

    string public constant licensorAgreement =
        "I certify that I am the licensor of the video agreement and agree to all terms defined in the agreement.";

    // all videos and licenses
    mapping(string => address payable) private _videoOwners;
    mapping(string => uint256) private _videoLicenseCounts;
    mapping(string => mapping(uint256 => LID)) private _videoLicenseIDs;

    mapping(LID => bool) private _licenseCreated;
    mapping(LID => bool) private _licenseActivated;
    mapping(LID => string) private _licenseVideos;
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

    function getVideoOwner(string memory vid) public view returns (address) {
        return _videoOwners[vid];
    }

    function addVideo(
        string memory vid,
        address payable licensor,
        bytes calldata signature
    ) public onlyOwner {
        bytes memory vidBytes = bytes(vid); // Uses memory
        require(vidBytes.length > 0, "invalid video id");
        require(
            verifyLicensor(licensor, vid, signature),
            "invalid licensor signature"
        );

        if (_videoOwners[vid] == address(0)) {
            _videoOwners[vid] = licensor;
        }
    }

    function createLicense(
        string memory vid,
        address template,
        uint256 price,
        LID licenseId
    ) private {
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

    function addLicense(
        string memory vid,
        address template,
        uint256 price,
        LID licenseId
    ) public videoExist(vid) templateExists(template) {
        require(_videoOwners[vid] == msg.sender, "invalid licensor");
        require(!_licenseCreated[licenseId], "unavailable license id");

        createLicense(vid, template, price, licenseId);
    }

    function addVideoWithLicense(
        string memory vid,
        address payable licensor,
        bytes calldata signature,
        address template,
        uint256 price,
        LID licenseId
    ) public onlyOwner templateExists(template) {
        require(!_licenseCreated[licenseId], "unavailable license id");

        addVideo(vid, licensor, signature);
        createLicense(vid, template, price, licenseId);
    }

    function removeLicense(LID licenseId) public licenseActive(licenseId) {
        require(
            this.getLicenseOwner(licenseId) == msg.sender,
            "invalid licensor"
        );
        _licenseActivated[licenseId] = false;
    }

    // get license info
    function getLicenseVideo(LID licenseId)
        public
        view
        licenseActive(licenseId)
        returns (string memory)
    {
        return _licenseVideos[licenseId];
    }

    function getLicenseOwner(LID licenseId)
        public
        view
        licenseActive(licenseId)
        returns (address payable)
    {
        return _videoOwners[_licenseVideos[licenseId]];
    }

    function getLicensePrice(LID licenseId)
        public
        view
        licenseActive(licenseId)
        returns (uint256)
    {
        return _licensePrices[licenseId];
    }

    function getLicenseTemplate(LID licenseId)
        public
        view
        licenseActive(licenseId)
        returns (address)
    {
        return _licenseTemplates[licenseId];
    }

    // purchases
    string public constant licenseeAgreement =
        "I certify that I am the licensee of the video agreement and agree to all terms defined in the agreement.";

    mapping(LID => mapping(address => uint256)) private _licenseLicensees;

    function buyLicense(
        LID licenseId,
        bytes calldata signature
    ) public payable licenseActive(licenseId) {
        require(
            msg.value >= this.getLicensePrice(licenseId),
            "not enough ether"
        );
        require(
            verifyLicensee(msg.sender, licenseId, signature),
            "invalid licensee signature"
        );

        uint256 price = this.getLicensePrice(licenseId);
        address payable to = this.getLicenseOwner(licenseId);
        (bool sent, ) = to.call{value: price}("");
        require(sent, "failed to send ether");

        _licenseLicensees[licenseId][msg.sender] = block.timestamp;
    }

    function getLicenseeLicenses(string memory vid, address licensee)
        public
        view
        videoExist(vid)
        returns (LID[] memory)
    {
        LID[] memory purchased = new LID[](_videoLicenseCounts[vid]);

        for (uint256 i = 0; i < _videoLicenseCounts[vid]; i++) {
            LID licenseId = _videoLicenseIDs[vid][i];

            if (_licenseLicensees[licenseId][licensee] != 0) {
                purchased[i] = licenseId;
            }
        }

        return purchased;
    }

    function composeLicense(LID licenseId, address licensee)
        public
        view
        licenseActive(licenseId)
        returns (string memory)
    {
        require(
            _licenseLicensees[licenseId][licensee] != 0,
            "invalid licensee"
        );

        string memory vid = _licenseVideos[licenseId];
        address licensor = _videoOwners[vid];
        address template = _licenseTemplates[licenseId];

        uint256 price = _licensePrices[licenseId];
        uint256 timestamp = _licenseLicensees[licenseId][licensee];

        ILicense license = ILicense(template);
        return license.compose(vid, licensor, licensee, price, timestamp);
    }

    function verifyLicensor(
        address signer,
        string memory vid,
        bytes calldata signature
    ) public pure returns (bool) {

        return recoverSigner(vid, signature) == signer;
    }

    function verifyLicensee(
        address signer,
        LID licenseId,
        bytes calldata signature
    ) public pure returns (bool) {
        return recoverSigner(Strings.toString(LID.unwrap(licenseId)), signature) == signer;
    }

    // Helper function
    function _ecrecover(
        string memory message,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        // Compute the EIP-191 prefixed message
        bytes memory prefixedMessage = abi.encodePacked(
            "\x19Ethereum Signed Message:\n",
            itoa(bytes(message).length),
            message
        );

        // Compute the message digest
        bytes32 digest = keccak256(prefixedMessage);

        // Use the native ecrecover provided by the EVM
        return ecrecover(digest, v, r, s);
    }

    function recoverSigner(string memory message, bytes calldata sig)
        public
        pure
        returns (address)
    {
        // Sanity check before using assembly
        require(sig.length == 65, "invalid signature");

        // Decompose the raw signature into r, s and v (note the order)
        uint8 v;
        bytes32 r;
        bytes32 s;
        assembly {
            r := calldataload(sig.offset)
            s := calldataload(add(sig.offset, 0x20))
            v := calldataload(add(sig.offset, 0x21))
        }

        return _ecrecover(message, v, r, s);
    }
}
