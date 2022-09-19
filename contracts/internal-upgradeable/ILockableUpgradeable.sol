// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface ILockableUpgradeable {
    error Lockable__UserIsLocked();

    function setBlockUser(address account_, bool status_) external;

    function isBlocked(address account_) external view returns (bool);
}
