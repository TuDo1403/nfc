// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./NFC.sol";

import "./internal/RentableNFT.sol";

import "./interfaces/IBusiness.sol";
import "./interfaces/IRentableNFC.sol";

contract RentableNFC is NFC, RentableNFT, IRentableNFC {
    using SafeCast for uint256;

    ///@dev value is equal to keccak256("Permit(uint256 tokenId,address user,uint256 deadline,uint256 nonce)")
    bytes32 private constant _PERMIT_TYPE_HASH =
        0xc3c6d1ca0b709df6823691bfba44f3fa8fb23d2b1e1f205b3f4fade39169759b;

    uint256 public limit;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint256 limit_,
        uint256 feeAmount_,
        IERC20Permit feeToken_,
        ITreasury treasury_,
        IBusiness business_
    )
        payable
        NFC(
            name_,
            symbol_,
            baseURI_,
            18,
            feeAmount_,
            feeToken_,
            treasury_,
            business_,
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

    function setUser(
        uint256 tokenId,
        address user,
        uint256 expires
    ) external override whenNotPaused {
        _checkLock(user);
        expires = 0;
        if (!_isApprovedOrOwner(_msgSender(), tokenId))
            revert RentableNFC__Unauthorized();
        _setUser(tokenId, user);
    }

    function setUser(
        uint256 tokenId_,
        uint256 deadline_,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override whenNotPaused {
        if (block.timestamp > deadline_) revert RentableNFC__Expired();

        address sender = _msgSender();
        address owner = ownerOf(tokenId_);
        _checkLock(sender);
        _onlyEOA(sender);
        _verify(
            sender,
            owner,
            keccak256(
                abi.encode(
                    _PERMIT_TYPE_HASH,
                    tokenId_,
                    sender,
                    deadline_,
                    _useNonce(owner)
                )
            ),
            v,
            r,
            s
        );

        _setUser(tokenId_, sender);
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
        if (userInfo.expires > limit) revert RentableNFC__LimitExceeded();
        unchecked {
            emit UserUpdated(
                tokenId_,
                userInfo.user = user_,
                ++userInfo.expires
            );
        }

        _users[tokenId_] = userInfo;
    }

    function _setLimit(uint256 limit_) internal {
        limit = limit_;
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal override(NFC, RentableNFT) {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }
}
