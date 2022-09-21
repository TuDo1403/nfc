// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../external/token/ERC721/ERC721.sol";

import "./IRentableNFT.sol";

import "../external/utils/math/SafeCast.sol";

abstract contract RentableNFT is ERC721, IRentableNFT {
    using SafeCast for uint256;

    mapping(uint256 => uint256) internal _users;

    function userOf(uint256 tokenId)
        external
        view
        virtual
        override
        returns (address user)
    {
        ownerOf(tokenId);
        uint256 value = _users[tokenId];
        assembly {
            user := value
        }
    }
}
