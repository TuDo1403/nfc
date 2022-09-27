// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./ITreasuryUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IRentableNFCUpgradeable {
    error RentableNFC__Rented();
    error RentableNFC__Expired();
    error RentableNFC__AlreadySet();
    error RentableNFC__Unauthorized();
    error RentableNFC__LimitExceeded();

    event Redeemed(
        uint256 id,
        address user,
        IERC20Upgradeable reward,
        uint256 amount
    );

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
