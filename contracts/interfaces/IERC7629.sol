//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC165.sol";

/**
 * @title ERC-7629 Unify Token Interface
 * @dev This interface defines the ERC-7629 Unify Token, which unifies ERC-721 and ERC-20 assets.
 */
interface IERC7629  is IERC165 {
    // ERC-20 Transfer event
    event ERC20Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    // ERC-721 Transfer event
    event ERC721Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    // Approval event for ERC-20 and ERC-721
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    // ApprovalForAll event for ERC-721
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // ERC-20 to ERC-721 Conversion event
    event ERC20ToERC721(address indexed to, uint256 amount, uint256[] tokenIds);

    // ERC-721 to ERC-20 Conversion event
    event ERC721ToERC20(address indexed to, uint256 tokenId, uint256 amount);

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the number of decimals used in the token.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the total supply of the ERC-20 tokens.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the balance of an address for ERC-20 tokens.
     * @param owner The address to query the balance of.
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Returns the total supply of ERC-20 tokens.
     */
    function erc20TotalSupply() external view returns (uint256);

    /**
     * @dev Returns the balance of an address for ERC-20 tokens.
     * @param owner The address to query the balance of.
     */
    function erc20BalanceOf(address owner) external view returns (uint256);

    /**
     * @dev Returns the total supply of ERC-721 tokens.
     */
    function erc721TotalSupply() external view returns (uint256);

    /**
     * @dev Returns the balance of an address for ERC-721 tokens.
     * @param owner The address to query the balance of.
     */
    function erc721BalanceOf(address owner) external view returns (uint256);

    /**
     * @dev Checks if an operator is approved for all tokens of a given owner.
     * @param owner The address of the token owner.
     * @param operator The address of the operator to check.
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);

    /**
     * @dev Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner.
     * @param owner The address of the token owner.
     * @param spender The address of the spender.
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Returns the array of ERC-721 token IDs owned by a specific address.
     * @param owner The address to query the tokens of.
     */
    function owned(address owner) external view returns (uint256[] memory);

    /**
     * @dev Returns the address that owns a specific ERC-721 token.
     * @param tokenId The token ID.
     */
    function ownerOf(uint256 tokenId) external view returns (address erc721Owner);

    /**
     * @dev Returns the URI for a specific ERC-721 token.
     * @param tokenId The token ID.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    /**
     * @dev Approve or disapprove the operator to spend or transfer all of the sender's tokens.
     * @param spender The address of the spender.
     * @param amountOrId The amount of ERC-20 tokens or ID of ERC-721 tokens.
     */
    function approve(
        address spender,
        uint256 amountOrId
    ) external returns (bool);

    /**
     * @dev Approve the spender to spend the specified amount of ERC-20 tokens.
     * @param spender The address of the spender.
     * @param value The amount of ERC-20 tokens to approve.
     */
    function erc20Approve(
        address spender,
        uint256 value
    ) external returns (bool);

    /**
     * @dev Approve the operator to spend the specified ERC-721 token.
     * @param spender The address of the spender.
     * @param tokenId The ID of the ERC-721 token to approve.
     */
    function erc721Approve(address spender, uint256 tokenId) external payable;

    /**
     * @dev Set or unset the approval of an operator for all tokens.
     * @param operator The address of the operator.
     * @param approved The approval status.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Transfer ERC-20 tokens or ERC-721 token from one address to another.
     * @param from The address to transfer ERC-20 tokens or ERC-721 token from.
     * @param to The address to transfer ERC-20 tokens or ERC-721 token to.
     * @param amountOrId The amount of ERC-20 tokens or ID of ERC-721 tokens to transfer.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amountOrId
    ) external returns (bool);

    /**
     * @dev Transfer ERC-20 tokens from one address to another.
     * @param from The address to transfer ERC-20 tokens from.
     * @param to The address to transfer ERC-20 tokens to.
     * @param value The amount of ERC-20 tokens to transfer.
     */
    function erc20TransferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    /**
     * @dev Transfer ERC-721 token from one address to another.
     * @param from The address to transfer ERC-721 token from.
     * @param to The address to transfer ERC-721 token to.
     * @param tokenId The ID of the ERC-721 token to transfer.
     */
    function erc721TransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable;
    
    /**
     * @notice Transfers the ownership of an NFT from one address to another address
     * @dev Throws unless `msg.sender` is the current owner, an authorized
     *  operator, or the approved address for this NFT. Throws if `_rom` is
     *  not the current owner. Throws if `_to` is the zero address. Throws if
     *  `tokenId` is not a valid NFT. When transfer is complete, this function
     *  checks if `to` is a smart contract (code size > 0). If so, it calls
     *  `onERC721Received` on `to` and throws if the return value is not
     *  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
     * @param from The current owner of the NFT
     * @param to The new owner
     * @param tokenId The NFT to transfer
     * @param data Additional data with no specified format, sent in call to `to`
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external payable;

    /**
     * @notice Transfers the ownership of an NFT from one address to another address
     * @dev This works identically to the other function with an extra data parameter,
     *  except this function just sets data to "".
     * @param from The current owner of the NFT
     * @param to The new owner
     * @param tokenId The NFT to transfer
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external payable;

    /**
     * @dev Transfer ERC-20 tokens to an address.
     * @param to The address to transfer ERC-20 tokens to.
     * @param amount The amount of ERC-20 tokens to transfer.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Retrieves the unit value associated with the token.
     * @return The unit value.
     */
    function getUnit() external view returns (uint256);

    /**
     * @dev Converts ERC-721 token to ERC-20 tokens.
     * @param tokenId The unique identifier of the ERC-721 token.
     */
    function erc721ToERC20(uint256 tokenId) external;

    /**
     * @dev Converts ERC-20 tokens to an ERC-721 token.
     * @param amount The amount of ERC-20 tokens to convert.
     */
    function erc20ToERC721(uint256 amount) external;
}
