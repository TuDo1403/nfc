// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../external/token/ERC20/extensions/draft-IERC20Permit.sol";
import "../external/utils/cryptography/ECDSA.sol";
import "../internal/ISignable.sol";
import "../external/token/ERC721/IERC721.sol";

contract SigUtil {
    ISignable public rentalNFC;
    IERC20Permit public paymentToken;

    bytes32 private constant ERC20PERMIT_TYPE_HASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    constructor(ISignable rentalNFC_, IERC20Permit paymentToken_) payable {
        rentalNFC = rentalNFC_;
        paymentToken = paymentToken_;
    }

    function setRentalNFC(ISignable rentalNFC_) external {
        rentalNFC = rentalNFC_;
    }

    function setPaymentToken(IERC20Permit paymentToken_) external {
        paymentToken = paymentToken_;
    }

    function permitHash(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline
    ) external view returns (bytes32) {
        bytes32 domainSeparator = paymentToken.DOMAIN_SEPARATOR();
        uint256 nonce = paymentToken.nonces(owner);
        return
            ECDSA.toTypedDataHash(
                domainSeparator,
                keccak256(
                    abi.encode(
                        ERC20PERMIT_TYPE_HASH,
                        owner,
                        spender,
                        value,
                        nonce,
                        deadline
                    )
                )
            );
    }

    function splitSignature(bytes calldata signature_)
        external
        pure
        returns (
            uint8 v,
            bytes32 r,
            bytes32 s
        )
    {
        assembly {
            r := calldataload(add(signature_.offset, 0x20))
            s := calldataload(add(signature_.offset, 0x40))
            v := byte(0, calldataload(add(signature_.offset, 0x60)))
        }
    }
}
