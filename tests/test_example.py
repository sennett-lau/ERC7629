
def test_erc20_to_erc721(deployer, example_token, accounts):

    units = example_token.getUnit()
    example_token.erc20ToERC721(3*units, sender=deployer)
    assert example_token.erc721BalanceOf(deployer) == 3


def test_erc721_to_erc20(deployer, example_token, accounts):

    units = example_token.getUnit()
    example_token.erc20ToERC721(3*units, sender=deployer)

    owned = example_token.owned(deployer)
    assert len(owned) == 3

    before_bal = example_token.erc20BalanceOf(deployer)
    example_token.erc721ToERC20(owned[0], sender=deployer)
    example_token.erc721ToERC20(owned[2], sender=deployer)
    after_bal = before_bal + 2*units
    assert example_token.erc20BalanceOf(deployer) == after_bal
    assert example_token.erc721BalanceOf(example_token.address) == 2
    assert example_token.owned(example_token.address) == [owned[0], owned[2]]

    example_token.erc20ToERC721(1*units, sender=deployer)
    assert example_token.owned(example_token.address) == [owned[0]]
    assert example_token.owned(deployer) == [owned[1], owned[2]]
