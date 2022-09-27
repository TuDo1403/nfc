// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "oz-custom/contracts/oz-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";

import "oz-custom/contracts/internal-upgradeable/SignableUpgradeable.sol";

import "./internal-upgradeable/LockableUpgradeable.sol";
import "./internal-upgradeable/TransferableUpgradeable.sol";
import "./internal-upgradeable/FundForwarderUpgradeable.sol";

import "oz-custom/contracts/oz-upgradeable/utils/math/MathUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/utils/math/SafeCastUpgradeable.sol";

import "./interfaces-upgradeable/INFCUpgradeable.sol";
import "oz-custom/contracts/oz-upgradeable/token/ERC20/extensions/draft-IERC20PermitUpgradeable.sol";

import "oz-custom/contracts/libraries/SSTORE2.sol";
import "oz-custom/contracts/libraries/StringLib.sol";

contract NFCUpgradeable is
    INFCUpgradeable,
    UUPSUpgradeable,
    LockableUpgradeable,
    SignableUpgradeable,
    TransferableUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC721PresetMinterPauserAutoIdUpgradeable
{
    using SSTORE2 for bytes;
    using SSTORE2 for bytes32;
    using StringLib for uint256;
    using Bytes32Address for uint256;
    using Bytes32Address for address;
    using MathUpgradeable for uint256;
    using SafeCastUpgradeable for uint256;

    ///@dev value is equal to keccak256("UPGRADER_ROLE")
    bytes32 public constant UPGRADER_ROLE =
        0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3;

    ///@dev value is equal to keccak256("OPERATOR_ROLE")
    bytes32 public constant OPERATOR_ROLE =
        0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929;

    uint256 public decimals;
    bytes32 public version;
    bytes32 private _business;
    bytes32 private _treasury;

    uint256 private _defaultFeeTokenInfo;
    mapping(uint256 => RoyaltyInfoV2) private _typeRoyaltyV2;

    function resetData() external {
        address sender = _msgSender();
        _grantRole(DEFAULT_ADMIN_ROLE, sender);
        _grantRole(MINTER_ROLE, sender);
        _grantRole(OPERATOR_ROLE, sender);
        _grantRole(UPGRADER_ROLE, sender);
        _grantRole(PAUSER_ROLE, sender);
        _setRoleAdmin(MINTER_ROLE, OPERATOR_ROLE);
        _setRoleAdmin(PAUSER_ROLE, OPERATOR_ROLE);
    }

    function setTypeFee(
        IERC20Upgradeable feeToken_,
        uint256 type_,
        uint256 price_,
        address[] calldata takers_,
        uint256[] calldata takerPercents_
    ) external override onlyRole(OPERATOR_ROLE) {
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

        RoyaltyInfoV2 memory royaltyInfo;
        royaltyInfo.feeData =
            address(feeToken_).fillFirst96Bits() |
            price_.toUint96();
        royaltyInfo.takersPtr = abi.encode(takers_).write();
        royaltyInfo.takerPercents = (percentMask << 8) | nTaker;
        _typeRoyaltyV2[type_] = royaltyInfo;
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) external override {
        _setRoleAdmin(role, adminRole);
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
        RoyaltyInfoV2 memory royaltyInfo = _typeRoyaltyV2[type_];
        takers = abi.decode(royaltyInfo.takersPtr.read(), (address[]));
        uint256 feeData = royaltyInfo.feeData;
        price = royaltyInfo.feeData & ~uint96(0);
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
            type(IERC165Upgradeable).interfaceId == interfaceId_ ||
            super.supportsInterface(interfaceId_);
    }

    function __NFC_init(
        string calldata name_,
        string calldata symbol_,
        string calldata baseURI_,
        uint256 decimals_,
        bytes32 version_
    ) internal onlyInitializing {
        __ReentrancyGuard_init();
        __EIP712_init(name_, "1");
        __ERC721PresetMinterPauserAutoId_init(name_, symbol_, baseURI_);

        address sender = _msgSender();
        _grantRole(OPERATOR_ROLE, sender);
        _grantRole(UPGRADER_ROLE, sender);

        version = version_;
        decimals = decimals_ & ~uint8(0);
    }

    function _deposit(
        address user_,
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
        price *= 10**decimals;
        if (signature_.length == 65) {
            if (block.timestamp > deadline_) revert NFC__Expired();
            (bytes32 r, bytes32 s, uint8 v) = _splitSignature(signature_);
            IERC20PermitUpgradeable(token).permit(
                user_,
                address(this),
                price, // convert to wei
                deadline_,
                v,
                r,
                s
            );
        }
        emit Deposited(tokenId_, user_, price);
        price *= 100; // convert percentage to 1e4
        for (uint256 i; i < nTakers; ) {
            _safeTransferFrom(
                token,
                user_,
                takers[i],
                price.mulDiv(
                    takerPercents[i],
                    1e4,
                    MathUpgradeable.Rounding.Zero
                )
            );
            unchecked {
                ++i;
            }
        }
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        virtual
        override
        onlyRole(UPGRADER_ROLE)
    {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[44] private __gap;
}
