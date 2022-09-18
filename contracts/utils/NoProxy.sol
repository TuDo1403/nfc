// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../external/utils/Context.sol";

error NoProxy__ProxyNotAllowed();

abstract contract NoProxy is Context {
    modifier onlyEOA() {
        _onlyEOA(_msgSender());
        _;
    }

    function _onlyEOA(address sender_) internal view {
        if (sender_ != tx.origin || sender_.code.length != 0)
            revert NoProxy__ProxyNotAllowed();
    }
}
