// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./NFCUpgradeable.sol";
import "./internal-upgradeable/RentableNFTUpgradeable.sol";
import "./internal-upgradeable/FundForwarderUpgradeable.sol";
import "./interfaces-upgradeable/IRentableNFCUpgradeable.sol";
import "./internal-upgradeable/IWithdrawableUpgradeable.sol";

contract RentableNFCUpgradeable is
    NFCUpgradeable,
    RentableNFTUpgradeable,
    IRentableNFCUpgradeable,
    FundForwarderUpgradeable
{
    using Bytes32Address for address;
    using Bytes32Address for uint256;
    using Bytes32Address for bytes32;
    using SafeCastUpgradeable for uint256;

    uint256 public limit;
    bytes32 private _treasury;

    function init(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 limit_,
        ITreasuryUpgradeable treasury_
    ) external initializer {
        __NFC_init(
            name_,
            symbol_,
            baseURI_,
            18,
            ///@dev value is equal to keccak256("RentableNFCUpgradeable")
            0x8f0d2d8abbd7c54281bae66528ef94d45e2883ff8bcc0f44d38a570078d4694d
        );
        __FundForwarder_init(treasury_);
        bytes32 treasury;
        assembly {
            treasury := treasury_
        }
        _treasury = treasury;
        _setLimit(limit_);
    }

    function setTreasury(ITreasuryUpgradeable treasury_)
        external
        onlyRole(OPERATOR_ROLE)
    {
        bytes32 treasury;
        assembly {
            treasury := treasury_
        }
        _treasury = treasury;
    }

    function redeem(
        address to_,
        address user_,
        uint256 type_,
        IERC20Upgradeable reward_,
        uint256 amount_
    ) external onlyRole(OPERATOR_ROLE) {
        _checkLock(user_);
        uint256 id;
        if (_ownerOf[id].fromFirst20Bytes() == address(0)) {
            unchecked {
                _mint(to_, id = (++_tokenIdTracker << 8) | (type_ & ~uint8(0)));
            }
        }
        _setUser(id, user_);
        IWithdrawableUpgradeable treasury;
        assembly {
            treasury := sload(_treasury.slot)
        }
        treasury.withdraw(address(reward_), user_, amount_);

        emit Redeemed(id, user_, reward_, amount_);
    }

    function deposit(
        address user_,
        uint256 tokenId_,
        uint256 deadline_,
        bytes calldata signature_
    ) external override onlyRole(OPERATOR_ROLE) {
        _checkLock(user_);
        _deposit(user_, tokenId_, deadline_, signature_);

        _setUser(tokenId_, user_);
    }

    function setLimit(uint256 limit_)
        external
        override
        onlyRole(OPERATOR_ROLE)
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
        ownerOf(tokenId);
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
        user = _userInfos[tokenId].fromLast160Bits();
    }

    function limitOf(uint256 tokenId) external view override returns (uint256) {
        return _userInfos[tokenId] & ~uint96(0);
    }

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        override(ERC721Upgradeable, NFCUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId_);
    }

    function _setUser(uint256 tokenId_, address user_) internal {
        uint256 userInfo = _userInfos[tokenId_];
        if (userInfo.fromLast160Bits() == user_)
            revert RentableNFC__AlreadySet();
        uint256 _limit = userInfo & ~uint96(0);
        unchecked {
            if (_limit++ >= limit) revert RentableNFC__LimitExceeded();
        }

        emit UserUpdated(tokenId_, user_);

        _userInfos[tokenId_] = user_.fillFirst96Bits() | _limit;
    }

    function _setLimit(uint256 limit_) internal {
        limit = limit_;
    }

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    )
        internal
        override(ERC721Upgradeable, ERC721PresetMinterPauserAutoIdUpgradeable)
    {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}
