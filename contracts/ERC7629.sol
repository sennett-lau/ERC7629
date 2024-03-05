//SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import "./interfaces/IERC7629.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

abstract contract ERC7629 is IERC7629 {

    // ERC-721 related errors
    error ERC721InvalidApprover(address approver);
    error ERC721InvalidOperator(address operator);
    error ERC721InvalidSender(address receiver);
    error ERC721InvalidReceiver(address receiver);
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);
    error ERC721NonexistentToken(uint256 tokenId);

    // ERC-20 related errors
    error ERC20InvalidSpender(address spender);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Token decimals
    uint8 private immutable _decimals;

    // Token unit (for ERC-20 conversion)
    uint256 private immutable _units;

    // ERC-20 balance mapping
    mapping(address => uint256) private _erc20BalanceOf;

    // ERC-20 allowances mapping
    mapping(address => mapping(address => uint256)) private _allowances;

    // Total supply of ERC-20 tokens
    uint256 private _totalSupply;

    // ERC-721 balance mapping
    mapping(address => uint256) private _erc721BalanceOf;

    // ERC-721 token owners mapping
    mapping(uint256 => address) private _owners;

    // ERC-721 token approvals mapping
    mapping(uint256 => address) private _tokenApprovals;

    // ERC-721 operator approvals mapping
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // ERC-721 owned tokens mapping
    mapping(address => uint256[]) internal _owned;

    // ERC-721 owned token index mapping
    mapping(uint256 => uint256) internal _ownedIndex;

    // Counter for minted ERC-721 tokens
    uint256 public minted;

    /**
     * @dev Constructor for the ERC-7629 Hybrid Token.
     * @param name_ The name of the token.
     * @param symbol_ The symbol of the token.
     * @param decimals_ The number of decimals used in the token.
     * @param units_ The unit value for ERC-20 conversion.
     */
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 units_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _units = units_ * 10 ** _decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used in the token.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the total supply of the ERC-20 tokens.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the balance of an address for ERC-20 tokens.
     * @param owner The address to query the balance of.
     */
    function balanceOf(address owner) public view virtual returns (uint256) {
        return _erc20BalanceOf[owner];
    }

    /**
     * @dev Returns the total supply of ERC-20 tokens.
     */
    function erc20TotalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the balance of an address for ERC-20 tokens.
     * @param owner The address to query the balance of.
     */
    function erc20BalanceOf(address owner) external view returns (uint256) {
        return _erc20BalanceOf[owner];
    }

    /**
     * @dev Returns the total supply of ERC-721 tokens.
     */
    function erc721TotalSupply() external view returns (uint256) {
        return minted;
    }

    /**
     * @dev Returns the balance of an address for ERC-721 tokens.
     * @param owner The address to query the balance of.
     */
    function erc721BalanceOf(address owner) external view returns (uint256) {
        return _owned[owner].length;
    }

    /**
     * @dev Checks if an operator is approved for all tokens of a given owner.
     * @param owner The address of the token owner.
     * @param operator The address of the operator to check.
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner.
     * @param owner The address of the token owner.
     * @param spender The address of the spender.
     */
    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Returns the array of ERC-721 token IDs owned by a specific address.
     * @param owner The address to query the tokens of.
     */
    function owned(address owner) external view returns (uint256[] memory) {
        return _owned[owner];
    }

    /**
     * @dev Returns the address that owns a specific ERC-721 token.
     * @param tokenId The token ID.
     */
    function ownerOf(uint256 tokenId) public view returns (address erc721Owner) {
        return _owners[tokenId];
    }

    /**
     * @dev Approve or disapprove the operator to spend or transfer all of the sender's tokens.
     * @param spender The address of the spender.
     * @param amountOrId The amount of ERC-20 tokens or ID of ERC-721 tokens.
     */
    function approve(
        address spender,
        uint256 amountOrId
    ) external returns (bool) {
        if ( amountOrId > 0 && amountOrId <= minted) {
            _erc721Approve(spender, amountOrId);
        } else {
            return _erc20Approve(spender, amountOrId);
        }
        return true;
    }

    /**
     * @dev Approve the specified address to spend the specified amount of tokens on behalf of the sender.
     * @param spender The address to be approved.
     * @param value The amount of tokens to be approved for spending.
     * @return True if the approval was successful.
     */
    function _erc20Approve(
        address spender,
        uint256 value
    ) internal returns (bool) {
        if (spender == address(0)) {
          revert ERC20InvalidSpender(spender);
        }

        _allowances[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    /**
     * @dev Approve the specified address to spend the specified ERC-721 token on behalf of the sender.
     * @param spender The address to be approved.
     * @param tokenId The ID of the ERC-721 token to be approved.
     */
    function _erc721Approve(address spender, uint256 tokenId) internal {
        _approveERC721(spender, tokenId, msg.sender, true);
    }

    /**
     * @dev Internal function to handle ERC-721 approvals.
     * @param to The address to be approved.
     * @param tokenId The ID of the ERC-721 token to be approved.
     * @param auth The address authorizing the approval.
     * @param emitEvent A boolean indicating whether to emit the Approval event.
     */
    function _approveERC721(address to, uint256 tokenId, address auth, bool emitEvent) internal virtual {
        if (emitEvent || auth != address(0)) {
            address owner = ownerOf(tokenId);

            // We do not use _isAuthorized because single-token approvals should not be able to call approve
            if (owner != auth && !isApprovedForAll(owner, auth)) {
                revert ERC721InvalidApprover(auth);
            }

            if (emitEvent) {
                emit Approval(owner, to, tokenId);
            }
        }

        _tokenApprovals[tokenId] = to;
    }

    /**
     * @dev Set or unset the approval of a given operator.
     * @param operator The address of the operator to approve or revoke.
     * @param approved A boolean indicating whether to approve or revoke the operator.
     */
    function setApprovalForAll(address operator, bool approved) external {
        if (operator == address(0)) {
            revert ERC721InvalidOperator(operator);
        }

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);

    }

    /**
    * @dev Returns the address approved to transfer the given token ID.
    * @param tokenId The ID of the token to query.
    * @return The address approved to transfer the token.
    * @notice Throws an error if the token does not exist.
    */
    function getApproved(uint256 tokenId) public view virtual returns (address) {
        address owner = ownerOf(tokenId);
        if (owner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
        return _tokenApprovals[tokenId];
    }

    /**
    * @dev Transfers a token from one address to another, checking if the recipient is a smart contract.
    * @param from The address to transfer the token from.
    * @param to The address to transfer the token to.
    * @param tokenId The ID of the token to transfer.
    */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
    * @dev Transfers a token from one address to another, checking if the recipient is a smart contract.
    * @param from The address to transfer the token from.
    * @param to The address to transfer the token to.
    * @param tokenId The ID of the token to transfer.
    * @param data Additional data with no specified format, sent in call to `to`.
    */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }


    /**
    * @dev Checks if the recipient is a smart contract by calling onERC721Received, if implemented.
    * @param from The address from which the token is transferred.
    * @param to The address to which the token is transferred.
    * @param tokenId The ID of the token being transferred.
    * @param data Additional data with no specified format, sent in call to `to`.
    * @notice Throws an error if the recipient is a smart contract and does not implement onERC721Received.
    */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    /**
     * @dev Transfer tokens or NFTs from one address to another.
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param amountOrId The amount of tokens (for ERC-20) or the ID of the NFT (for ERC-721) to transfer.
     * @return True if the transfer was successful.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amountOrId
    ) public returns (bool) {
        if (amountOrId <= minted) {
            _erc721TransferFrom(from, to, amountOrId);
        } else {
            return _erc20TransferFrom(from, to, amountOrId);
        }

        return true;
    }

    /**
     * @dev Internal function to handle ERC-20 transfers.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param value The amount of tokens to transfer.
     * @return True if the transfer was successful.
     */
    function _erc20TransferFrom(
        address from,
        address to,
        uint256 value
    ) internal returns (bool) {
        address spender = msg.sender;

        uint256 currentAllowance = allowance(from, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _allowances[msg.sender][spender] = currentAllowance - value;
            }
        }
        _transferERC20(from, to, value);
        return true;
    }

    /**
     * @dev Internal function to handle ERC-20 transfers.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param value The amount of tokens to transfer.
     */
    function _transferERC20(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _updateERC20(from, to, value);
    }

    /**
    * @dev Updates ERC-20 token balances during a transfer.
    * @param from The address from which tokens are transferred.
    * @param to The address to which tokens are transferred.
    * @param value The amount of ERC-20 tokens to transfer.
    * @notice Handles minting and burning tokens, preventing overflow and emitting transfer events.
    */
    function _updateERC20(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _erc20BalanceOf[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _erc20BalanceOf[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _erc20BalanceOf[to] += value;
            }
        }

        emit ERC20Transfer(from, to, value);
    }

    /**
     * @dev Transfer ERC-721 token from one address to another.
     * @param from The address to transfer ERC-721 token from.
     * @param to The address to transfer ERC-721 token to.
     * @param tokenId The ID of the ERC-721 token to transfer.
     */
    function _erc721TransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }

        address previousOwner = _updateERC721(to, tokenId);
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        } else if (previousOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
        }
    }

    /**
    * @dev Updates the ownership of an ERC-721 token during a transfer.
    * @param to The address to which the token is being transferred.
    * @param tokenId The ID of the ERC-721 token being transferred.
    * @return The address from which the token is transferred.
    * @notice Clears approval, updates balances, and emits transfer events.
    */
    function _updateERC721(address to, uint256 tokenId) internal virtual returns (address) {
        address from = ownerOf(tokenId);

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            _approveERC721(address(0), tokenId, address(0), false);

            unchecked {
                _erc721BalanceOf[from] -= 1;
            }

            uint256 updatedId = _owned[from][_owned[from].length - 1];
            if (tokenId != updatedId) {
                _owned[from][_ownedIndex[tokenId]] = updatedId;
                _ownedIndex[updatedId] = _ownedIndex[tokenId];
            }
            _owned[from].pop();
            
        }

        if (to != address(0)) {
            unchecked {
                _erc721BalanceOf[to] += 1;
            }

            _owned[to].push(tokenId);
            _ownedIndex[tokenId] = _owned[to].length - 1;
        }

        _owners[tokenId] = to;

        emit ERC721Transfer(from, to, tokenId);
        emit Transfer(from, to, tokenId);

        return from;
    }

    /**
    * @dev Transfers ERC-20 tokens from one address to another.
    * @param to The address to transfer the tokens to.
    * @param amount The amount of ERC-20 tokens to transfer.
    * @return A boolean indicating success.
    * @notice Prevents burning tokens to address(0).
    */
    function transfer(address to, uint256 amount) external returns (bool) {
        // Prevent burning tokens to 0x0.
        if (to == address(0)) {
            revert ERC20InvalidReceiver(to);
        }

        _transferERC20(msg.sender, to, amount);
        return true;
    }

    /**
    * @dev Mints new ERC-20 tokens to the specified account.
    * @param account The account to which new ERC-20 tokens are minted.
    * @param value The amount of ERC-20 tokens to mint.
    * @notice Prevents minting tokens to address(0).
    */
    function _mintERC20(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _updateERC20(address(0), account, value);
    }


    /**
    * @dev Burns ERC-20 tokens from the specified account.
    * @param account The account from which ERC-20 tokens are burned.
    * @param value The amount of ERC-20 tokens to burn.
    * @notice Prevents burning tokens from address(0).
    */
    function _burnERC20(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _updateERC20(account, address(0), value);
    }

    /**
     * @dev Mint a new ERC-721 token and assign ownership to the specified address.
     * @param to The address to receive the minted ERC-721 token.
     * @param tokenId The ID of the ERC-721 token to be minted.
     */
    function _mintERC721(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }
        address previousOwner = _updateERC721(to, tokenId);
        if (previousOwner != address(0)) {
            revert ERC721InvalidSender(address(0));
        }
    }

    /**
     * @dev Burn an existing ERC-721 token, removing it from circulation.
     * @param tokenId The ID of the ERC-721 token to be burned.
     */
    function _burnERC721(uint256 tokenId) internal {
        address previousOwner = _updateERC721(address(0), tokenId);
        if (previousOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
    }

    /**
     * @dev Converts ERC-721 token to ERC-20 tokens.
     * @param tokenId The unique identifier of the ERC-721 token.
     */
    function erc721ToERC20(uint256 tokenId) external {
        address from = msg.sender;
        address to = address(this);

        _erc721TransferFrom(from, to, tokenId);
        _mintERC20(from , _units);
        emit ERC721ToERC20(to, tokenId, _units);
    }

    /**
     * @dev Converts ERC-20 tokens to an ERC-721 token.
     * @param amount The amount of ERC-20 tokens to convert.
     */
    function erc20ToERC721(uint256 amount) external {

        uint256 nftAmount = amount / _units;
        uint256 ftAmount = nftAmount * _units;

        _burnERC20(msg.sender, ftAmount);

        uint256 nftMintAmount = _owned[address(this)].length < nftAmount ? nftAmount-_owned[address(this)].length : 0;
        uint256 nftTransferAmount= nftAmount - nftMintAmount;

        uint256[] memory tokenIds= new uint256[](nftAmount);

        for (uint256 i=0; i<nftMintAmount; i++){
            unchecked {
                minted++;
            }
            uint256 tokenId = minted;
            _mintERC721(msg.sender, tokenId);
            tokenIds[i] = tokenId;
        }
        
        for (uint256 i=0; i<nftTransferAmount; i++){
            uint256 tokenId=_owned[address(this)][_owned[address(this)].length - 1];
            _updateERC721(msg.sender, tokenId);
            tokenIds[i+nftMintAmount] = tokenId;
        }
        emit ERC20ToERC721(msg.sender, ftAmount, tokenIds);
    }

    /**
     * @dev Retrieves the unit value associated with the token.
     * @return The unit value.
     */
    function getUnit() external view returns (uint256){
        return _units;
    }

    /**
     * @dev Checks if the contract supports a given interface.
     * @param interfaceId The interface identifier.
     * @return True if the contract supports the given interface, false otherwise.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual returns (bool) {
        return
        interfaceId == type(IERC7629).interfaceId ||
        interfaceId == type(IERC165).interfaceId;
    }

}