//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../ERC7629.sol";

contract ERC7629Example is Ownable, ERC7629 {
    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 units_)
        ERC7629(name_, symbol_, decimals_, units_)
        Ownable(msg.sender)
    {
        _mintERC20(msg.sender, 10_000 * units_ * 10 ** decimals_);
    }

    function tokenURI(uint256 id_) public pure override returns (string memory) {
        return string.concat("https://example.com/token/", Strings.toString(id_));
    }
}
