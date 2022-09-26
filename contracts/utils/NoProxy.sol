// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

error NoProxy__ProxyNotAllowed();

abstract contract NoProxy {
    modifier onlyEOA() {
        _onlyEOA(msg.sender);
        _;
    }

    function _onlyEOA(address sender_) internal view {
        if (sender_ != tx.origin || sender_.code.length != 0)
            revert NoProxy__ProxyNotAllowed();
    }
}
