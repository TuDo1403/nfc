// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./NFC.sol";

import "./internal/RentableNFT.sol";

import "./interfaces/IRentableNFC.sol";

contract RentableNFC is NFC, RentableNFT, IRentableNFC {
    using SafeCast for uint256;
    using AddressLib for uint256;
    using AddressLib for address;

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
        address user_,
        uint256 tokenId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external override onlyRole(MINTER_ROLE) {
        _checkLock(user_);
        _deposit(user_, tokenId_, deadline_, signature_);

        _setUser(tokenId_, user_);
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
        ownerOf(tokenId);
        user = _users[tokenId].fromLast160Bits();
    }

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        override(ERC721, NFC)
        returns (bool)
    {
        return super.supportsInterface(interfaceId_);
    }

    function _setUser(uint256 tokenId_, address user_) internal {
        uint256 userInfo = _users[tokenId_];
        uint256 _limit = userInfo & ~uint96(0);
        unchecked {
            if (_limit++ == limit) revert RentableNFC__LimitExceeded();
        }

        emit UserUpdated(tokenId_, user_);

        _users[tokenId_] = user_.fillLast96Bits() | (userInfo & ~uint96(0));
    }

    function _setLimit(uint256 limit_) internal {
        limit = limit_;
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal override(ERC721, ERC721PresetMinterPauserAutoId) {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }
}
