// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../external/token/ERC721/ERC721.sol";

import "./IERC4907.sol";

import "../external/utils/math/SafeCast.sol";

abstract contract RentableNFT is ERC721, IERC4907 {
    using SafeCast for uint256;

    mapping(uint256 => UserInfo) internal _users;

    function userOf(uint256 tokenId)
        external
        view
        virtual
        override
        returns (address user)
    {
        UserInfo memory info = _users[tokenId];
        user = info.expires > block.timestamp ? info.user : address(0);
    }

    function userExpires(uint256 tokenId)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _users[tokenId].expires;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC4907).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        UserInfo memory info = _users[tokenId];
        if (block.timestamp > info.expires) revert Rentable__NotValidTransfer();
        if (from != to && info.user != address(0)) {
            delete _users[tokenId];

            emit UserUpdated(tokenId, address(0), 0);
        }
    }
}
