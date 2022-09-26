// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/access/AccessControlUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/security/PausableUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "./internal-upgradeable/WithdrawableUpgradeable.sol";

import "./interfaces-upgradeable/ITreasuryUpgradeable.sol";

import "oz-custom/contracts/libraries/Bytes32Address.sol";
import "oz-custom/contracts/libraries/EnumerableSetV2.sol";

contract TreasuryUpgradeable is
    UUPSUpgradeable,
    PausableUpgradeable,
    ITreasuryUpgradeable,
    WithdrawableUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable
{
    using Bytes32Address for uint256;
    using Bytes32Address for address;
    using Bytes32Address for bytes32;
    using EnumerableSetV2 for EnumerableSetV2.AddressSet;

    ///@dev value is equal to keccak256("Treasury_v1")
    bytes32 public constant VERSION =
        0xea88ed743f2d0583b98ad2b145c450d84d46c8e4d6425d9e0c7cd0e4930fce2f;
    ///@dev value is equal to keccak256("UPGRADER_ROLE")
    bytes32 public constant UPGRADER_ROLE =
        0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3;
    ///@dev value is equal to keccak256("PAUSER_ROLE")
    bytes32 public constant PAUSER_ROLE =
        0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a;
    ///@dev value is equal to keccak256("TREASURER_ROLE")
    bytes32 public constant TREASURER_ROLE =
        0x3496e2e73c4d42b75d702e60d9e48102720b8691234415963a5a857b86425d07;

    EnumerableSetV2.AddressSet private _acceptedPayments;

    function init()
        external
        initializer
    {
        address sender = _msgSender();
        _grantRole(UPGRADER_ROLE, sender);
        _grantRole(PAUSER_ROLE, sender);
        _grantRole(TREASURER_ROLE, sender);
        _grantRole(DEFAULT_ADMIN_ROLE, sender);
    }

    function paymentTokens() external view override returns (address[] memory) {
        return _acceptedPayments.values();
    }

    function setPaymentTokens(address[] calldata tokens_)
        external
        override
        onlyRole(TREASURER_ROLE)
    {
        __setPaymentTokens(tokens_);
    }

    function __setPaymentTokens(address[] calldata tokens_) private {
        _acceptedPayments.add(tokens_);
    }

    function pause() external override onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external override onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function withdraw(
        address token_,
        address to_,
        uint256 amount_
    ) external override onlyRole(TREASURER_ROLE) {
        _safeTransfer(token_, to_, amount_);
    }

    function acceptedPayment(address token_)
        external
        view
        override
        returns (bool)
    {
        return _acceptedPayments.contains(token_);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyRole(UPGRADER_ROLE) {}

    uint256[49] private __gap;
}
