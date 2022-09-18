// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./external/access/Ownable.sol";

import "./interfaces/IBusiness.sol";

import "./libraries/AddressLib.sol";
import "./libraries/BitMap256.sol";

contract Business is Ownable, IBusiness {
    using AddressLib for address;
    using BitMap256 for uint256;
    using BitMap256 for BitMap256.BitMap;

    ///@dev value is equal to keccak256("Business_v1")
    bytes32 public constant VERSION =
        0x76b07dcd98549e38947b0da2f27dd575fcde72bfc5ceccc9684d3f6a40f840c2;

    BitMap256.BitMap private _businesses;

    constructor(uint256 bitmap_) payable {
        _setBusinesses(bitmap_);
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

    function setBusinessAddress(uint256 data_) external override onlyOwner {
        _setBusinesses(data_);
    }

    function setBusiness(address addr) external onlyOwner {
        _businesses.set(addr.fillLast96Bits());
    }

    function setBusinessAddress(address[] calldata addrs_)
        external
        override
        onlyOwner
    {
        address[] memory addrs = addrs_;
        uint256[] memory uintAddrs;
        assembly {
            uintAddrs := addrs
        }
        uint256 length = addrs_.length;
        uint256 bitmap = _businesses.data;
        for (uint256 i; i < length; ) {
            bitmap = bitmap.set(uintAddrs[i]);
            unchecked {
                ++i;
            }
        }

        _businesses.data = bitmap;
        emit BusinessesSet(addrs_);
    }

    function _setBusinesses(uint256 bitmap_) internal {
        _businesses.setData(bitmap_);
    }
}
