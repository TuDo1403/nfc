// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../external/utils/structs/BitMaps.sol";

import "./ILockable.sol";

import "../libraries/AddressLib.sol";

error Lockable__UserIsLocked();

abstract contract Lockable is ILockable {
    using AddressLib for address;
    using BitMaps for BitMaps.BitMap;

    BitMaps.BitMap private _blockedUsers;

    modifier onlyUnlocked(
        address sender_,
        address from_,
        address to_
    ) {
        _onlyUnlocked(sender_, from_, to_);
        _;
    }

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
        if (_blockedUsers.get(account_.fillFirst96Bits()))
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
}
