// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./external-upgradeable/access/OwnableUpgradeable.sol";
import "./external-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces-upgradeable/IBusinessUpgradeable.sol";

import "./libraries/AddressLib.sol";
import "./external-upgradeable/utils/structs/BitMapsUpgradeable.sol";

contract BusinessUpgradeable is OwnableUpgradeable, IBusinessUpgradeable, UUPSUpgradeable {
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;
    using AddressLib for address;

    ///@dev value is equal to keccak256("BusinessUpgradeable_v1")
    bytes32 public constant VERSION =
        0xea321455eb5f54c86f9ff7d23275c13e3657c147111c7cdbfbcaa9fc7f4e8c3d;

    BitMapsUpgradeable.BitMap private _businesses;

    function init() external initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
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
        onlyOwner
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
        onlyOwner
    {
        uint256 length = addrs_.length;
        for (uint256 i; i < length; ) {
            _businesses.setTo(addrs_[i].fillLast96Bits(), status_);
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
        onlyOwner
    {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
