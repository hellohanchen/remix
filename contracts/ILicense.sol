// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVideoLicense {
    function getName() external view returns (string memory);

    function getDuration() external view returns (string memory);

    function getTemplate() external view returns (string memory);

    function composeAgreement(
        string memory videoId,
        address licensor,
        address licensee,
        uint256 price,
        uint256 signTimestamp
    ) external view returns (string memory);
}
