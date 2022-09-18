// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface INFC {
    error NFC__Expired();
    error NFC__Unexisted();
    error NFC__Unauthorized();
    error NFC__NonZeroAddress();
    error NFC__LengthMismatch();

    struct RoyaltyInfo {
        uint256 feeData;
        uint256 takerPercents;
        bytes32[] takers;
    }
}
