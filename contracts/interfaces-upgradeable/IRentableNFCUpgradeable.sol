// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IRentableNFCUpgradeable {
    error RentableNFC__Rented();
    error RentableNFC__Expired();
    error RentableNFC__Unauthorized();
    error RentableNFC__LimitExceeded();

    event LimitSet(uint256 indexed from, uint256 indexed to);

    function setLimit(uint256 limit_) external;

    function setUser(
        uint256 tokenId,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
