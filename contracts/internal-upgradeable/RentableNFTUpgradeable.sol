// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/oz-upgradeable/token/ERC721/ERC721Upgradeable.sol";

import "./IRentableNFTUpgradeable.sol";

import "oz-custom/contracts/oz-upgradeable/utils/math/SafeCastUpgradeable.sol";

abstract contract RentableNFTUpgradeable is
    ERC721Upgradeable,
    IRentableNFTUpgradeable
{
    using SafeCastUpgradeable for uint256;

    struct UserInfo {
        address user;
        uint96 expires;
    }

    mapping(uint256 => UserInfo) private _users;
    mapping(uint256 => uint256) internal _userInfos;

    function __RentableNFT_init() internal onlyInitializing {}

    function __RentableNFT_init_unchained() internal onlyInitializing {}

    function userOf(uint256 tokenId)
        external
        view
        virtual
        override
        returns (address user)
    {
        ownerOf(tokenId);
        uint256 value = _userInfos[tokenId];
        assembly {
            user := value
        }
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}
