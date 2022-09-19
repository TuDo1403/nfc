// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../external-upgradeable/proxy/utils/Initializable.sol";

import "../external-upgradeable/utils/structs/BitMapsUpgradeable.sol";

import "./ILockableUpgradeable.sol";

import "../libraries/AddressLib.sol";

abstract contract LockableUpgradeable is Initializable, ILockableUpgradeable {
    using AddressLib for address;
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    BitMapsUpgradeable.BitMap private _blockedUsers;

    modifier onlyUnlocked(
        address sender_,
        address from_,
        address to_
    ) {
        _onlyUnlocked(sender_, from_, to_);
        _;
    }

    function __Lockable_init() internal onlyInitializing {}

    function __Lockable_init_unchained() internal onlyInitializing {}

    function setBlockUser(address account_, bool status_)
        external
        virtual
        override;

    function isBlocked(address account_) external view override returns (bool) {
        return _blockedUsers.get(account_.fillFirst96Bits());
    }

    function _setBlockUser(address account_, bool status_) internal {
        _blockedUsers.setTo(account_.fillLast96Bits(), status_);
    }

    function _checkLock(address account_) internal view {
        if (!_blockedUsers.get(account_.fillFirst96Bits()))
            revert Lockable__UserIsLocked();
    }

    function _onlyUnlocked(
        address sender_,
        address from_,
        address to_
    ) internal view {
        _checkLock(sender_);
        _checkLock(from_);
        _checkLock(to_);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
