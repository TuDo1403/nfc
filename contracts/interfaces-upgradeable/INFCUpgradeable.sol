// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../external-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";

interface INFCUpgradeable {
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

    event Deposited(
        uint256 indexed tokenId,
        address indexed from,
        uint256 indexed priceFee
    );

    function deposit(
        uint256 tokenId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external payable;

    function mint(address to_, uint256 type_) external;

    function setTypeFee(
        IERC20PermitUpgradeable feeToken_,
        uint256 type_,
        uint256 price_,
        address[] calldata takers_,
        uint256[] calldata takerPercents_
    ) external;

    function royaltyInfoOf(uint256 type_)
        external
        view
        returns (
            address token,
            uint256 price,
            address[] memory takers,
            uint256[] memory takerPercents
        );

    function typeOf(uint256 tokenId_) external view returns (uint256);
}
