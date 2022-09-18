// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "../../utils/Context.sol";

import "../../../libraries/AddressLib.sol";

error ERC20__Expired();
error ERC20__StringTooLong();
error ERC20__InvalidSignature();

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 is Context {
    using AddressLib for address;
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(bytes32 => uint256) public balanceOf;

    mapping(bytes32 => mapping(bytes32 => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) payable {
        if (bytes(_symbol).length > 32 || bytes(_name).length > 32)
            revert ERC20__StringTooLong();

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        address sender = _msgSender();
        allowance[sender.fillLast12Bytes()][spender.fillLast12Bytes()] = amount;

        emit Approval(sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        address sender = _msgSender();
        _beforeTokenTransfer(sender, to, amount);
        balanceOf[sender.fillLast12Bytes()] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to.fillLast12Bytes()] += amount;
        }

        emit Transfer(sender, to, amount);

        _afterTokenTransfer(sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        _beforeTokenTransfer(from, to, amount);

        bytes32 sender = _msgSender().fillLast12Bytes();
        bytes32 _from = from.fillLast12Bytes();
        _spendAllowance(_from, sender, amount);

        balanceOf[_from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to.fillLast12Bytes()] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
        return true;
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/
    function _spendAllowance(
        bytes32 owner_,
        bytes32 spender_,
        uint256 amount_
    ) internal virtual {
        uint256 allowed = allowance[owner_][spender_]; // Saves gas for limited approvals.
        if (allowed != ~uint256(0))
            allowance[owner_][spender_] = allowed - amount_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _mint(address to, uint256 amount) internal virtual {
        _beforeTokenTransfer(address(0), to, amount);
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to.fillLast12Bytes()] += amount;
        }

        emit Transfer(address(0), to, amount);

        _afterTokenTransfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        _beforeTokenTransfer(from, address(0), amount);

        balanceOf[from.fillLast12Bytes()] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);

        _afterTokenTransfer(from, address(0), amount);
    }
}
