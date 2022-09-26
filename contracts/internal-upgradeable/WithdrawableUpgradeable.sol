// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/utils/ContextUpgradeable.sol";

import "./TransferableUpgradeable.sol";

import "./IWithdrawableUpgradeable.sol";

error Withdrawable__Expired();

abstract contract WithdrawableUpgradeable is
    ContextUpgradeable,
    TransferableUpgradeable,
    IWithdrawableUpgradeable
{
    receive() external payable virtual {
        emit Received(_msgSender(), msg.value);
    }

    function __Withdrawable_init() internal onlyInitializing {}

    function __Withdrawable_init_unchained() internal onlyInitializing {}

    function withdraw(address token_, address to_, uint256 amount_) external virtual override;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
