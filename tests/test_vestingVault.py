from brownie import VestingVault, accounts, chain
import pytest


@pytest.fixture
def contract():
    vestingvault = VestingVault.deploy(accounts[1], {"from": accounts[0]})
    return vestingvault
