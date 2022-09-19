// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./external/access/AccessControl.sol";
import "./external/security/Pausable.sol";
import "./external/security/ReentrancyGuard.sol";

import "./internal/Withdrawable.sol";

import "./utils/NoProxy.sol";
import "./utils/Lockable.sol";

import "./interfaces/ITreasury.sol";

import "./libraries/AddressLib.sol";
import "./libraries/BitMap256.sol";

contract Treasury is
    NoProxy,
    Lockable,
    Pausable,
    ITreasury,
    Withdrawable,
    AccessControl,
    ReentrancyGuard
{
    using AddressLib for uint256;
    using AddressLib for address;
    using AddressLib for bytes32;
    using BitMap256 for BitMap256.BitMap;

    ///@dev value is equal to keccak256("Treasury_v1")
    bytes32 public constant VERSION =
        0xea88ed743f2d0583b98ad2b145c450d84d46c8e4d6425d9e0c7cd0e4930fce2f;

    ///@dev value is equal to keccak256("PAUSER_ROLE")
    bytes32 public constant PAUSER_ROLE =
        0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a;
    ///@dev value is equal to keccak256("VERIFIER_ROLE")
    bytes32 public constant VERIFIER_ROLE =
        0x0ce23c3e399818cfee81a7ab0880f714e53d7672b08df0fa62f2843416e1ea09;
    ///@dev value is equal to keccak256("TREASURER_ROLE")
    bytes32 public constant TREASURER_ROLE =
        0x3496e2e73c4d42b75d702e60d9e48102720b8691234415963a5a857b86425d07;

    bytes32 private _verifier;

    BitMap256.BitMap private _acceptedPayments;

    constructor(address verifier_) payable EIP712(type(Treasury).name, "1") {
        __updateVerifier(verifier_);

        address sender = _msgSender();
        _grantRole(PAUSER_ROLE, sender);
        _grantRole(TREASURER_ROLE, sender);
        _grantRole(VERIFIER_ROLE, sender);
        _grantRole(VERIFIER_ROLE, verifier_);
        _grantRole(DEFAULT_ADMIN_ROLE, sender);
    }

    function setBlockUser(address account_, bool status_)
        external
        override
        onlyRole(PAUSER_ROLE)
    {
        _setBlockUser(account_, status_);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function withdraw(address to_, uint256 amount_)
        external
        override
        onlyRole(TREASURER_ROLE)
    {
        _safeNativeTransfer(to_, amount_);
    }

    function withdraw(
        address token_,
        uint256 amount_,
        uint256 deadline_,
        bytes calldata signature_
    ) external nonReentrant whenNotPaused {
        address to = _msgSender();
        _onlyEOA(to);
        _checkLock(to);

        _withdraw(
            _verifier.fromFirst20Bytes(),
            token_,
            to,
            amount_,
            deadline_,
            signature_
        );
    }

    function updateVerifier(address verifier_)
        external
        override
        onlyRole(VERIFIER_ROLE)
    {
        emit VerifierUpdated(_verifier.fromFirst20Bytes(), verifier_);
        __updateVerifier(verifier_);
    }

    function updatePaymentToken(address token_, bool isSet_)
        external
        override
        onlyRole(TREASURER_ROLE)
    {
        __updatePaymentToken(token_, isSet_);
        emit PaymentUpdated(token_, isSet_);
    }

    function registerTokens(address[] calldata tokens_)
        external
        override
        onlyRole(TREASURER_ROLE)
    {
        uint256 length = tokens_.length;
        for (uint256 i; i < length; ) {
            __updatePaymentToken(tokens_[i], true);
            unchecked {
                ++i;
            }
        }
        emit MultiPaymentRegistered(tokens_);
    }

    function acceptedPayment(address token_)
        external
        view
        override
        returns (bool)
    {
        return _acceptedPayments.get(token_.fillLast96Bits());
    }

    function verifier() external view override returns (address) {
        return _verifier.fromFirst20Bytes();
    }

    function __updatePaymentToken(address token_, bool isSet_) internal {
        _acceptedPayments.setTo(token_.fillLast96Bits(), isSet_);
    }

    function __updateVerifier(address verifier_) internal {
        _verifier = verifier_.fillLast12Bytes();
    }
}
