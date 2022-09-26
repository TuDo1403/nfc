// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "oz-custom/contracts/oz-upgradeable/utils/ContextUpgradeable.sol";

import "../interfaces-upgradeable/ITreasuryUpgradeable.sol";

error FundForwarder__ForwardError();

abstract contract FundForwarderUpgradeable is ContextUpgradeable {
    bytes32 private _treasury;

    function __FundForwarder_init(ITreasuryUpgradeable treasury_)
        internal
        onlyInitializing
    {
        __FundForwarder_init_unchained(treasury_);
    }

    function __FundForwarder_init_unchained(ITreasuryUpgradeable treasury_)
        internal
    {
        assembly {
            sstore(_treasury.slot, treasury_)
        }
    }

    receive() external virtual payable {
        address treasury;
        assembly {
            treasury := sload(_treasury.slot)
        }
        (bool success, ) = payable(treasury).call{value: msg.value}("");
        if (!success) revert FundForwarder__ForwardError();
    }
}
