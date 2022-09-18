// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../external/access/IAccessControl.sol";

interface ITreasury is IAccessControl {
    error Treasury__PendingRequest();
    struct Request {
        address to;
        uint96 amount;
    }

    event LargeWithdrawalRequest(address indexed to, uint256 indexed amount);
    event VerifierUpdated(address indexed from, address indexed to);
    event MultiPaymentRegistered(address[] indexed tokens);
    event PaymentUpdated(address indexed token, bool indexed isSet);

    function updateVerifier(address verifier_) external;

    function updatePaymentToken(address token_, bool isSet_) external;

    function registerTokens(address[] calldata tokens_) external;

    function verifier() external view returns (address);

    function acceptedPayment(address token_) external view returns (bool);
}
