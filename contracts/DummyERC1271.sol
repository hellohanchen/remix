// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC1271.sol";

contract DummyERC1271 is IERC1271 {
    function isValidSignature(bytes32 hash, bytes memory signature) external pure returns (bytes4 magicValue) {
        return 0x1626ba7e;
    }
}
