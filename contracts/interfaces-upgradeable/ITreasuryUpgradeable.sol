// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface ITreasuryUpgradeable {
    function paymentTokens() external view returns (address[] memory);

    function setPaymentTokens(address[] calldata tokens_) external;

    function pause() external;

    function unpause() external;

    function acceptedPayment(address token_) external view returns (bool);
}
