// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/oz/security/ReentrancyGuard.sol";
import "oz-custom/contracts/oz/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

import "oz-custom/contracts/internal/Signable.sol";

import "./internal/Lockable.sol";
import "./internal/Withdrawable.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";
import "oz-custom/contracts/oz/utils/math/SafeCast.sol";

import "./interfaces/INFC.sol";

import "oz-custom/contracts/libraries/StringLib.sol";

contract NFC is
    INFC,
    Lockable,
    Signable,
    Withdrawable,
    ReentrancyGuard,
    ERC721PresetMinterPauserAutoId
{
    using Math for uint256;
    using SafeCast for uint256;
    using StringLib for uint256;
    using Bytes32Address for uint256;
    using Bytes32Address for address;

    uint8 public immutable decimals;
    bytes32 public immutable version;

    mapping(uint256 => RoyaltyInfo) private _typeRoyalty;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint256 decimals_,
        bytes32 version_
    )
        payable
        Signable(name_, "1")
        ERC721PresetMinterPauserAutoId(name_, symbol_, baseURI_)
    {
        version = version_;

        uint8 _decimals;
        assembly {
            _decimals := decimals_
        }
        decimals = _decimals;
    }

    function withdraw(
        address token_,
        address to_,
        uint256 amount_
    ) external virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        _safeTransfer(IERC20(token_), to_, amount_);
    }

    function mint(address to_, uint256 type_)
        external
        override
        onlyRole(MINTER_ROLE)
        returns (uint256 id)
    {
        unchecked {
            _mint(to_, id = (++_tokenIdTracker << 8) | (type_ & ~uint8(0)));
        }
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) external override {
        _setRoleAdmin(role, adminRole);
    }

    function setTypeFee(
        IERC20Permit feeToken_,
        uint256 type_,
        uint256 price_,
        address[] calldata takers_,
        uint256[] calldata takerPercents_
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 nTaker;
        unchecked {
            nTaker = takerPercents_.length % 32;
        }
        uint256 percentMask;
        for (uint256 i; i < nTaker; ) {
            percentMask |= takerPercents_[i] << (i << 3);
            unchecked {
                ++i;
            }
        }
        bytes32[] memory bytes32Addrs;
        address[] memory takers = takers_;
        assembly {
            bytes32Addrs := takers
        }
        RoyaltyInfo memory royaltyInfo;
        royaltyInfo.feeData =
            address(feeToken_).fillFirst96Bits() |
            price_.toUint96();
        royaltyInfo.takers = bytes32Addrs;
        royaltyInfo.takerPercents = (percentMask << 8) | nTaker;
        _typeRoyalty[type_] = royaltyInfo;
    }

    function setBlockUser(address account_, bool status_)
        external
        override
        onlyRole(PAUSER_ROLE)
    {
        _setBlockUser(account_, status_);
    }

    function royaltyInfoOf(uint256 type_)
        public
        view
        override
        returns (
            address token,
            uint256 price,
            uint256 nTakers,
            address[] memory takers,
            uint256[] memory takerPercents
        )
    {
        RoyaltyInfo memory royaltyInfo = _typeRoyalty[type_];
        bytes32[] memory bytes32Takers = royaltyInfo.takers;
        assembly {
            takers := bytes32Takers
        }
        uint256 feeData = royaltyInfo.feeData;
        price = feeData & ~uint96(0);
        token = feeData.fromLast160Bits();
        uint256 _takerPercents = royaltyInfo.takerPercents;
        nTakers = _takerPercents & 0xff;
        uint256 percentMask = _takerPercents >> 8;
        takerPercents = new uint256[](nTakers);
        for (uint256 i; i < nTakers; ) {
            takerPercents[i] = (percentMask >> (i << 3)) & 0xff;
            unchecked {
                ++i;
            }
        }
    }

    function typeOf(uint256 tokenId_) public view override returns (uint256) {
        ownerOf(tokenId_);
        return tokenId_ & ~uint8(0);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        ownerOf(tokenId);
        return string(abi.encodePacked(_baseURI(), tokenId.toString()));
    }

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            type(IERC165).interfaceId == interfaceId_ ||
            super.supportsInterface(interfaceId_);
    }

    function _deposit(
        address sender_,
        uint256 tokenId_,
        uint256 deadline_,
        bytes calldata signature_
    ) internal virtual {
        (
            address token,
            uint256 price,
            uint256 nTakers,
            address[] memory takers,
            uint256[] memory takerPercents
        ) = royaltyInfoOf(typeOf(tokenId_));

        if (signature_.length == 65) {
            if (block.timestamp > deadline_) revert NFC__Expired();
            (bytes32 r, bytes32 s, uint8 v) = _splitSignature(signature_);
            IERC20Permit(token).permit(
                sender_,
                address(this),
                price *= 10**decimals, // convert to wei
                deadline_,
                v,
                r,
                s
            );
        }
        emit Deposited(tokenId_, sender_, price);
        price *= 100; // convert percentage to 1e4
        for (uint256 i; i < nTakers; ) {
            _safeTransferFrom(
                IERC20(token),
                sender_,
                takers[i],
                price.mulDiv(takerPercents[i], 1e4, Math.Rounding.Zero)
            );
            unchecked {
                ++i;
            }
        }
    }
}
