// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ILicense} from "./ILicense.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CreativeCommonAttribution4dot0 is ILicense {
    string constant public agreement = "" 
        "Licensing Agreement\n\n" 
        "This License Agreement (\"Agreement\") is entered into by and between:\n"
        "- Licensor: The individual or entity that holds the copyright for the video identified below (\"Licensor\").\n"
        "- Licensee: The individual or entity that will use the licensed material under the terms of this Agreement (\"Licensee\").\n\n"
        "1. Licensed Material\n" 
        "- Video ID: [video id]\n"
        "This Agreement applies to the video identified by the Video ID listed above, as hosted on YouTube or any other platform.\n\n" 
        "2. License Grant\n" 
        "The Licensor hereby grants the Licensee a non-exclusive, worldwide, royalty-free license to:\n"
        "- Share (copy and redistribute the material in any medium or format)\n" 
        "- Adapt (remix, transform, and build upon the material for any purpose, even commercially)\n"
        "Under the terms of this Agreement, provided that:\n"
        "- The Licensee must give appropriate credit to the Licensor, provide a link to the license, and indicate if changes were made."
        " The Licensee may do so in any reasonable manner, but not in any way that suggests the Licensor endorses the Licensee or the use of the material.\n\n" 
        "3. License Duration\n" 
        "- License Duration: Valid for a lifetime\n"
        "This Agreement is effective for the duration specified above, starting from the Signing Date.\n\n" 
        "4. Attribution Requirements\n" 
        "The Licensee must give appropriate credit to the Licensor, as follows:\n"
        "- Provide the wallet address of the Licensor.\n"
        "- Provide a link to the video.\n"
        "- Provide a link to this license.\n"
        "- Indicate if changes were made to the original material.\n\n" 
        "5. No Additional Restrictions\n" 
        "The Licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.\n\n" 
        "6. Termination\n" 
        "This Agreement will automatically terminate if the Licensee fails to comply with the terms herein."
        " However, the license will not terminate as a result of minor and reasonable deviations that do not fundamentally affect the terms of the Agreement.\n\n" 
        "7. Signatures\n" 
        "This Agreement is executed by the following parties:\n"
        "- Licensor: [licensor address]\n"
        "- Licensee: [licensee address]\n"
        "- Signing Date: [signing timestamp]";

    constructor() {}

    function getName() external pure returns (string memory) {
        return "Creative Commons Attribution 4.0 International License (CC BY 4.0)";
    }

    function getDuration() external pure returns (uint256) {
        return 0;
    }

    function getTemplate() external pure returns (string memory) {
        return agreement;
    }

    function compose(
        string memory identifier,
        address licensor,
        address licensee,
        uint256 price,
        uint256 signTimestamp
    ) external pure returns (string memory) {
        string memory part_a = "" 
        "Licensing Agreement\n\n" 
        "This License Agreement (\"Agreement\") is entered into by and between:\n"
        "- Licensor: The individual or entity that holds the copyright for the video identified below (\"Licensor\").\n"
        "- Licensee: The individual or entity that will use the licensed material under the terms of this Agreement (\"Licensee\").\n\n"
        "1. Licensed Material\n" 
        "- Video ID: ";

        string memory part_b = "\n"
        "This Agreement applies to the video identified by the Video ID listed above, as hosted on YouTube or any other platform.\n\n" 
        "2. License Grant\n" 
        "The Licensor hereby grants the Licensee a non-exclusive, worldwide, royalty-free license to:\n"
        "- Share (copy and redistribute the material in any medium or format)\n" 
        "- Adapt (remix, transform, and build upon the material for any purpose, even commercially)\n"
        "Under the terms of this Agreement, provided that:\n"
        "- The Licensee must give appropriate credit to the Licensor, provide a link to the license, and indicate if changes were made."
        " The Licensee may do so in any reasonable manner, but not in any way that suggests the Licensor endorses the Licensee or the use of the material.\n\n" 
        "3. License Duration\n" 
        "- License Duration: Valid for a lifetime\n"
        "This Agreement is effective for the duration specified above, starting from the Signing Date.\n\n" 
        "4. Attribution Requirements\n" 
        "The Licensee must give appropriate credit to the Licensor, as follows:\n"
        "- Provide the wallet address of the Licensor.\n"
        "- Provide a link to the video.\n"
        "- Provide a link to this license.\n"
        "- Indicate if changes were made to the original material.\n\n" 
        "5. No Additional Restrictions\n" 
        "The Licensee may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.\n\n" 
        "6. Termination\n" 
        "This Agreement will automatically terminate if the Licensee fails to comply with the terms herein."
        " However, the license will not terminate as a result of minor and reasonable deviations that do not fundamentally affect the terms of the Agreement.\n\n" 
        "7. Signatures\n" 
        "This Agreement is executed by the following parties:\n"
        "- Licensor: ";

        string memory part_c = "\n"
        "- Licensee: ";

        string memory part_d = "\n"
        "- Signing Date: ";

        return string(abi.encodePacked(part_a, identifier, part_b, Strings.toHexString(licensor), part_c, Strings.toHexString(licensee), part_d, Strings.toString(signTimestamp)));
    }
}