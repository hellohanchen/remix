// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ILicense} from "./ILicense.sol";

contract VideoLicenseAgreement is ILicense {
    string constant public agreement = "" 
        "Licensing Agreement\n\n" 
        "1. Grant of License\n" 
        "- You are granted a non-exclusive, non-transferable license to use the video [VIDEO_ID] for the purpose of creating derivative video content.\n\n" 
        "2. Usage Limitations\n" 
        "- This license is for non-commercial use only.\n" 
        "- You must provide attribution to the original video in any derivative works.\n\n" 
        "3. Duration\n" 
        "- The license is valid for [Duration] from the date of purchase.\n\n" 
        "4. Payment Terms\n" 
        "- The license fee is [Amount], payable via [Payment Method].\n\n" 
        "5. Prohibited Uses\n" 
        "- You may not redistribute, sublicense, or resell the video.\n" 
        "- The video may not be used in any content that promotes hate speech, violence, or illegal activities.\n\n" 
        "6. Termination\n" 
        "- This agreement will terminate automatically if you breach any of its terms.\n\n" 
        "7. Governing Law\n" 
        "- This agreement shall be governed by the laws of [Your Country/State].\n\n" 
        "8. Contact Information\n" 
        "- For any questions regarding this agreement, please contact [Your Contact Information].\n\n" 
        "Signature\n" 
        "- [Your Signature/Your Company's Signature]\n\n";

    constructor() {}

    function getName() external pure returns (string memory) {
        return "Test License";
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
        return agreement;
    }
}