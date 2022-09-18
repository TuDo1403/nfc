// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IBusiness {
    event BusinessesSet(address[] indexed addrs);

    function isBusiness(address account_) external view returns (bool);

    function setBusinessAddress(uint256 data_) external;

    function setBusinessAddress(address[] calldata addrs_) external;
}
