// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IRentableNFTUpgradeable {
    error Rentable__PaymentFailed();
    error Rentable__NotValidTransfer();
    error Rentable__OnlyOwnerOrApproved();
    // Logged when the user of a NFT is changed or expires is changed
    /// @notice Emitted when the `user` of an NFT or the `expires` of the `user` is changed
    /// The zero address for user indicates that there is no user address
    event UserUpdated(uint256 indexed tokenId, address indexed user);

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) external view returns (address);
}
