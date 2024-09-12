
// File: contracts/ILicense.sol


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

// File: @openzeppelin/contracts/utils/math/Math.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/Math.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

// File: @openzeppelin/contracts/utils/math/SignedMath.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SignedMath.sol)

pragma solidity ^0.8.20;

/**
 * @dev Standard signed math utilities missing in the Solidity language.
 */
library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(int256 a, int256 b) internal pure returns (int256) {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

// File: @openzeppelin/contracts/utils/Strings.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Strings.sol)

pragma solidity ^0.8.20;



/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(uint256 value, uint256 length);

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// File: @openzeppelin/contracts/interfaces/IERC1271.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC1271.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 */
interface IERC1271 {
    /**
     * @dev Should return whether the signature provided is valid for the provided data
     * @param hash      Hash of the data to be signed
     * @param signature Signature byte array associated with _data
     */
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

// File: contracts/LicenseManager.sol


pragma solidity ^0.8.20;




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
        _licenseCreated[LID.wrap(0)] = true; // reserve license id as invalid id
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
            _verifyLicensor(licensor, vid, signature),
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
    function getVideoLicenses(string memory vid)
        public
        view
        videoExist(vid)
        returns (LID[] memory)
    {
        LID[] memory licenses = new LID[](_videoLicenseCounts[vid]);

        for (uint256 i = 0; i < _videoLicenseCounts[vid]; i++) {
            LID licenseId = _videoLicenseIDs[vid][i];

            if (_licenseActivated[licenseId]) {
                licenses[i] = licenseId;
            }
        }

        return licenses;
    }

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

    function buyLicense(LID licenseId, bytes calldata signature)
        public
        payable
        licenseActive(licenseId)
    {
        require(
            msg.value >= this.getLicensePrice(licenseId),
            "not enough ether"
        );
        require(
            _verifyLicensee(msg.sender, licenseId, signature),
            "invalid licensee signature"
        );

        uint256 price = this.getLicensePrice(licenseId);
        address payable to = this.getLicenseOwner(licenseId);
        (bool sent, ) = to.call{value: price}("");
        require(sent, "failed to send ether");

        _licenseLicensees[licenseId][msg.sender] = block.timestamp;
    }

    function getLicensesOfVideoAndLicensee(string memory vid, address licensee)
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

    function getPurchaseTime(LID licenseId, address licensee)
        public
        view
        returns (uint256)
    {
        return _licenseLicensees[licenseId][licensee];
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
    function _getMessageHash(string memory message) internal pure returns (bytes32) {
        // Compute the EIP-191 prefixed message
        bytes memory prefixedMessage = abi.encodePacked(
            "\x19Ethereum Signed Message:\n",
            itoa(bytes(message).length),
            message
        );

        // Compute the message digest
        bytes32 digest = keccak256(prefixedMessage);

        return digest;
    }

    // Helper function
    function _ecrecover(
        string memory message,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        bytes32 digest = _getMessageHash(message);

        // Use the native ecrecover provided by the EVM
        return ecrecover(digest, v, r, s);
    }

    function _recoverSigner(string memory message, bytes calldata sig)
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

    function verifySigner(
        address signer,
        string memory message,
        bytes calldata signature
    ) public view returns (bool) {
        // Try EOA verification
        address eoaSigner = _recoverSigner(message, signature);

        if (eoaSigner == signer) {
            return true;
        }

        // Try EIP1271 verification
        bytes32 digest = _getMessageHash(message);
        IERC1271 contractSigner = IERC1271(signer);
        bytes4 result = contractSigner.isValidSignature(digest, signature);

        return result == 0x1626ba7e;
    }

    function _verifyLicensor(
        address signer,
        string memory vid,
        bytes calldata signature
    ) internal view returns (bool) {
        return verifySigner(signer, vid, signature);
    }

    function _verifyLicensee(
        address signer,
        LID licenseId,
        bytes calldata signature
    ) internal view returns (bool) {
        return verifySigner(signer, Strings.toString(LID.unwrap(licenseId)), signature);
    }
}
