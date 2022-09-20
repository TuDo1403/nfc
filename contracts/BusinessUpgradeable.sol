// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./external-upgradeable/access/AccessControlUpgradeable.sol";
import "./external-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces-upgradeable/IBusinessUpgradeable.sol";

import "./external-upgradeable/utils/structs/BitMapsUpgradeable.sol";

contract BusinessUpgradeable is
    UUPSUpgradeable,
    IBusinessUpgradeable,
    AccessControlUpgradeable
{
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;

    ///@dev value is equal to keccak256("BusinessUpgradeable_v1")
    bytes32 public constant VERSION =
        0xea321455eb5f54c86f9ff7d23275c13e3657c147111c7cdbfbcaa9fc7f4e8c3d;

    ///@dev value is equal to keccak256("OPERATOR_ROLE")
    bytes32 public constant OPERATOR_ROLE =
        0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929;

    ///@dev value is equal to keccak256("UPGRADER_ROLE")
    bytes32 public constant UPGRADER_ROLE =
        0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3;

    BitMapsUpgradeable.BitMap private _businesses;

    function init() external initializer {
        address sender = _msgSender();
        _grantRole(OPERATOR_ROLE, sender);
        _grantRole(UPGRADER_ROLE, sender);
        _grantRole(DEFAULT_ADMIN_ROLE, sender);
    }

    function isBusiness(address account_)
        external
        view
        override
        returns (bool)
    {
        uint256 uintAccount;
        assembly {
            uintAccount := account_
        }
        return _businesses.get(uintAccount);
    }

    function updateBusinessAddress(address addr_, bool status_)
        external
        override
        onlyRole(OPERATOR_ROLE)
    {
        uint256 uintAddr;
        assembly {
            uintAddr := addr_
        }
        _businesses.setTo(uintAddr, status_);
    }

    function updateBusinessAddresses(address[] calldata addrs_, bool status_)
        external
        override
        onlyRole(OPERATOR_ROLE)
    {
        address[] memory addrs = addrs_;
        uint256 length = addrs.length;
        uint256[] memory uintAddrs;
        assembly {
            uintAddrs := addrs
        }
        for (uint256 i; i < length; ) {
            _businesses.setTo(uintAddrs[i], status_);
            unchecked {
                ++i;
            }
        }
        emit BusinessesSet(addrs_);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyRole(UPGRADER_ROLE)
    {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
