// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./NFCUpgradeable.sol";

import "./internal-upgradeable/RentableNFTUpgradeable.sol";

import "./interfaces-upgradeable/IBusinessUpgradeable.sol";
import "./interfaces-upgradeable/IRentableNFCUpgradeable.sol";

contract RentableNFCUpgradeable is
    NFCUpgradeable,
    RentableNFTUpgradeable,
    IRentableNFCUpgradeable
{
    using SafeCastUpgradeable for uint256;

    ///@dev value is equal to keccak256("Permit(address user,uint256 deadline,uint256 nonce)")
    bytes32 private constant _PERMIT_TYPE_HASH =
        0x39efe69afd3743a48f05ca7e519cd9c63bc23964bc52bbc8af1f9438d4e5a177;

    uint256 public limit;

    function init(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 limit_,
        uint256 feeAmount_,
        address feeToken_,
        ITreasuryUpgradeable treasury_,
        IBusinessUpgradeable business_
    ) external initializer {
        __NFC_init(
            name_,
            symbol_,
            baseURI_,
            18,
            feeAmount_,
            feeToken_,
            treasury_,
            business_,
            ///@dev value is equal to keccak256("RentableNFCUpgradeable")
            0x8f0d2d8abbd7c54281bae66528ef94d45e2883ff8bcc0f44d38a570078d4694d
        );

        _setLimit(limit_);
    }

    function deposit(
        uint256 tokenId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external payable override nonReentrant whenNotPaused {
        address sender = _msgSender();
        _checkLock(sender);
        _deposit(sender, tokenId_, deadline_, signature_);

        _setUser(tokenId_, sender);
    }

    function setLimit(uint256 limit_)
        external
        override
        onlyRole(OPERATOR_ROLE)
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
        _checkLock(sender);
        _verify(
            sender,
            ownerOf(tokenId_),
            keccak256(
                abi.encode(
                    _PERMIT_TYPE_HASH,
                    sender,
                    deadline_,
                    _useNonce(sender)
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
        override(NFCUpgradeable, RentableNFTUpgradeable)
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
    ) internal override(NFCUpgradeable, RentableNFTUpgradeable) {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
