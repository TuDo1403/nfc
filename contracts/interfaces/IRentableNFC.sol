// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IRentableNFC {
    error RentableNFC__Rented();
    error RentableNFC__Expired();
    error RentableNFC__AlreadySet();
    error RentableNFC__Unauthorized();
    error RentableNFC__LimitExceeded();
    error RentableNFC__NotValidTransfer();

    event LimitSet(uint256 indexed from, uint256 indexed to);

    function setLimit(uint256 limit_) external;

    function setUser(uint256 tokenId, address user) external;

    function deposit(
        address user_,
        uint256 tokenId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external;

    function limitOf(uint256 tokenId) external view returns (uint256);
}
