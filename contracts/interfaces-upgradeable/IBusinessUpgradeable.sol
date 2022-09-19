// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IBusinessUpgradeable {
    event BusinessesSet(address[] indexed addrs);

    function isBusiness(address account_) external view returns (bool);

    function updateBusinessAddress(address addr_, bool status_) external;

    function updateBusinessAddresses(address[] calldata addrs_, bool status_)
        external;
}
