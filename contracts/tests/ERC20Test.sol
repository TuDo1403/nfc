// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-custom/contracts/oz/token/ERC20/extensions/draft-ERC20Permit.sol";

contract ERC20Test is ERC20Permit {
    constructor(string memory name_, string memory symbol_)
        payable
        ERC20(name_, symbol_, 18)
        ERC20Permit(name_)
    {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount * 10**decimals);
    }
}
