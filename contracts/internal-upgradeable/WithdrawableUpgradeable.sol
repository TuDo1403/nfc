// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../external-upgradeable/utils/ContextUpgradeable.sol";

import "./SignableUpgradeable.sol";
import "../internal/Transferable.sol";

import "./IWithdrawableUpgradeable.sol";

error Withdrawable__Expired();

abstract contract WithdrawableUpgradeable is
    ContextUpgradeable,
    SignableUpgradeable,
    Transferable,
    IWithdrawableUpgradeable
{
    ///@dev value is equal to to Permit(address token,address to,uint256 amount,uint256 deadline,uint256 nonce)
    bytes32 private constant _PERMIT_TYPE_HASH =
        0x984451e1880855a56058ebd6b0f6c8dd534f21c83a8dedad93ab0e57c6c84c7a;

    receive() external payable virtual {
        emit Received(_msgSender(), msg.value);
    }

    function __Withdrawable_init() internal onlyInitializing {}

    function __Withdrawable_init_unchained() internal onlyInitializing {}

    function withdraw(address to_, uint256 amount_) external virtual override;

    function _withdraw(
        address verifier_,
        address token_,
        address to_,
        uint256 amount_,
        uint256 deadline_,
        bytes calldata signature_
    ) internal virtual {
        if (block.timestamp > deadline_) revert Withdrawable__Expired();

        _verify(
            to_,
            verifier_,
            keccak256(
                abi.encode(
                    _PERMIT_TYPE_HASH,
                    token_,
                    to_,
                    amount_,
                    deadline_,
                    _useNonce(to_)
                )
            ),
            signature_
        );

        _safeTransfer(token_, to_, amount_);
        emit Withdrawn(token_, to_, amount_);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
