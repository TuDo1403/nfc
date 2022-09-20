// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./NFC.sol";

import "./internal/RentableNFT.sol";

import "./interfaces/IRentableNFC.sol";

contract RentableNFC is NFC, RentableNFT, IRentableNFC {
    using SafeCast for uint256;

    uint256 public limit;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint256 limit_
    )
        payable
        NFC(
            name_,
            symbol_,
            baseURI_,
            18,
            ///@dev value is equal to keccak256("RentableNFC_v1")
            0x94853ebc602a26ed326beee3ed781c1719447aa3075a7acd18a2640e416a1bb6
        )
    {
        _setLimit(limit_);
    }

    function deposit(
        uint256 tokenId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external payable override nonReentrant whenNotPaused {
        address sender = _msgSender();
        _onlyEOA(sender);
        _checkLock(sender);
        _deposit(sender, tokenId_, deadline_, signature_);
        _setUser(tokenId_, sender);
    }

    function setLimit(uint256 limit_)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        emit LimitSet(limit, limit_);
        _setLimit(limit_);
    }

    function setUser(uint256 tokenId, address user)
        external
        override
        whenNotPaused
        onlyRole(MINTER_ROLE)
    {
        _checkLock(user);
        _setUser(tokenId, user);
    }

    function userOf(uint256 tokenId)
        external
        view
        override
        returns (address user)
    {
        user = _users[tokenId].user;
    }

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        override(NFC, RentableNFT)
        returns (bool)
    {
        return super.supportsInterface(interfaceId_);
    }

    function _setUser(uint256 tokenId_, address user_) internal {
        UserInfo memory userInfo = _users[tokenId_];
        unchecked {
            if (++userInfo.expires > limit) revert RentableNFC__LimitExceeded();
        }
        emit UserUpdated(tokenId_, userInfo.user = user_, userInfo.expires);

        _users[tokenId_] = userInfo;
    }

    function _setLimit(uint256 limit_) internal {
        limit = limit_;
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal override(ERC721PresetMinterPauserAutoId, RentableNFT) {
        ERC721PresetMinterPauserAutoId._beforeTokenTransfer(
            from_,
            to_,
            tokenId_
        );
    }
}
