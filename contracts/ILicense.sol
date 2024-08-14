// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILicense {
    function getName() external view returns (string memory);

    function getDuration() external view returns (uint256);

    function getTemplate() external view returns (string memory);

    function compose(
        string memory identifier,
        address licensor,
        address licensee,
        uint256 price,
        uint256 signTimestamp
    ) external view returns (string memory);
}
