import pytest


## Accounts ##
@pytest.fixture
def deployer(accounts):
    return accounts[0]


@pytest.fixture
def example_token(project, deployer, accounts):

    token = deployer.deploy(project.ERC7629Example,
                            "test", "test", 18, 10_000)

    return token
