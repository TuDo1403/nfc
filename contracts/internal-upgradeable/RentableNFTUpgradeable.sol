// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../external-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import "./IERC4907Upgradeable.sol";

import "../external-upgradeable/utils/math/SafeCastUpgradeable.sol";

abstract contract RentableNFTUpgradeable is
    ERC721Upgradeable,
    IERC4907Upgradeable
{
    using SafeCastUpgradeable for uint256;

    mapping(uint256 => UserInfo) internal _users;

    function __RentableNFT_init() internal onlyInitializing {}

    function __RentableNFT_init_unchained() internal onlyInitializing {}

    function setUser(
        uint256 tokenId,
        address user,
        uint256 expires
    ) external virtual override {
        if (!_isApprovedOrOwner(_msgSender(), tokenId))
            revert Rentable__OnlyOwnerOrApproved();

        UserInfo memory info = _users[tokenId];
        info.user = user;
        unchecked {
            info.expires = (block.timestamp + expires).toUint96();
        }

        _users[tokenId] = info;

        emit UserUpdated(tokenId, user, expires);
    }

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
            interfaceId == type(IERC4907Upgradeable).interfaceId ||
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
