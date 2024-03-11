pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC7629Mock} from "./mock/ERC7629Mock.sol";

contract ERC7629Test is Test {
    ERC7629Mock erc7629;

    function setUp() public {
        erc7629 = new ERC7629Mock("Test", "TST", 18, 10_000);
    }

    function test_erc20_to_erc721() public {
        uint256 unit = erc7629.getUnit();
        uint256 expectedAmount = 1;
        uint256 amountToConvert = expectedAmount * unit;

        address user = address(0x1);

        erc7629.mintERC20(user, amountToConvert);

        uint256 balance = erc7629.erc20BalanceOf(user);

        assertEq(balance, amountToConvert);

        vm.prank(user);
        erc7629.erc20ToERC721(amountToConvert);

        uint256[] memory tokenIds = erc7629.owned(user);
        uint256 tokenId = tokenIds[0];

        assertEq(tokenIds.length, 1);
        assertEq(tokenId, 1);

        balance = erc7629.erc20BalanceOf(user);

        assertEq(balance, 0);

        // convert multiple

        expectedAmount = 10;
        amountToConvert = expectedAmount * unit;

        vm.prank(address(this));

        erc7629.mintERC20(user, amountToConvert);

        balance = erc7629.erc20BalanceOf(user);

        assertEq(balance, amountToConvert);

        vm.prank(user);

        erc7629.erc20ToERC721(amountToConvert);

        tokenIds = erc7629.owned(user);

        assertEq(tokenIds.length, 11);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertEq(tokenIds[i], i + 1);
        }

        balance = erc7629.erc20BalanceOf(user);

        assertEq(balance, 0);
    }

    function test_erc721_to_erc20() public {
        uint256 unit = erc7629.getUnit();
        uint256 tokenId = 1;

        address user = address(0x1);

        // mint erc271
        erc7629.mintERC721(user, tokenId);

        uint256[] memory ownedTokenIds = erc7629.owned(user);
        uint256 ownedTokenId = ownedTokenIds[0];

        assertEq(ownedTokenIds.length, 1);
        assertEq(ownedTokenId, tokenId);

        // convert single
        vm.prank(user);
        erc7629.erc721ToERC20(tokenId);

        ownedTokenIds = erc7629.owned(user);
        uint256 balance = erc7629.erc20BalanceOf(user);

        assertEq(ownedTokenIds.length, 0);
        assertEq(balance, unit);

        // // contract erc721 vault checking
        uint256[] memory contractTokenIds = erc7629.owned(address(erc7629));
        uint256 contractTokenId = contractTokenIds[0];

        assertEq(contractTokenIds.length, 1);
        assertEq(contractTokenId, 1);
    }
}
