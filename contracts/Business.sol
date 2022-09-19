// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./external/access/Ownable.sol";

import "./interfaces/IBusiness.sol";

import "./libraries/AddressLib.sol";
import "./external/utils/structs/BitMaps.sol";

contract Business is Ownable, IBusiness {
    using BitMaps for BitMaps.BitMap;
    using AddressLib for address;

    ///@dev value is equal to keccak256("Business_v1")
    bytes32 public constant VERSION =
        0x76b07dcd98549e38947b0da2f27dd575fcde72bfc5ceccc9684d3f6a40f840c2;

    BitMaps.BitMap private _businesses;

    constructor() payable {}

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
}
