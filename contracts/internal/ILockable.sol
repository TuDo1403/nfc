// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface ILockable {
    function setBlockUser(address account_, bool status_) external;

    function isBlocked(address account_) external view returns (bool);
}
