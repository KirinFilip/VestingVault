from brownie import VestingVault, TestERC20, accounts, chain, exceptions
import pytest

### fixtures ###


@pytest.fixture
def vaultContract():
    vaultContract = VestingVault.deploy(accounts[1], {"from": accounts[0]})
    return vaultContract


@pytest.fixture
def tokenContract():
    tokenContract = TestERC20.deploy(100_000 * (10**18), {"from": accounts[2]})
    return tokenContract


### constructor ###


def test_vaultOwner(vaultContract):
    assert vaultContract.owner() == accounts[0]


def test_beneficiary(vaultContract):
    assert vaultContract.getBeneficiary() == accounts[1]


#### fundToken function ###


def test_AlreadyFunded(vaultContract, tokenContract):
    assert vaultContract.funded() == False
    tokenContract.transfer(accounts[0], 10000, {"from": accounts[2]})
    tokenContract.approve(vaultContract.address, 10000, {"from": accounts[0]})
    vaultContract.fundToken(tokenContract.address, 100, 10, {"from": accounts[0]})
    assert vaultContract.funded() == True
    assert vaultContract.tokenVestedAddress() == tokenContract.address
    assert vaultContract.amountVested() == 100
    assert vaultContract.unlockTime() == chain.time() + 10

    try:
        vaultContract.fundToken(tokenContract.address, 100, 10, {"from": accounts[0]})
    except exceptions.VirtualMachineError as ex:
        assert "VestingVault__AlreadyFunded" in str(ex)


def test_InsufficientFundAmount(vaultContract, tokenContract):
    assert vaultContract.funded() == False
    tokenContract.transfer(accounts[0], 10000, {"from": accounts[2]})
    tokenContract.approve(vaultContract.address, 10000, {"from": accounts[0]})
    try:
        vaultContract.fundToken(tokenContract.address, 0, 10, {"from": accounts[0]})
    except exceptions.VirtualMachineError as ex:
        assert "VestingVault__InsufficientFundAmount" in str(ex)


def test_InsufficientLockedTime(vaultContract, tokenContract):
    assert vaultContract.funded() == False
    tokenContract.transfer(accounts[0], 10000, {"from": accounts[2]})
    tokenContract.approve(vaultContract.address, 10000, {"from": accounts[0]})
    try:
        vaultContract.fundToken(tokenContract.address, 100, 0, {"from": accounts[0]})
    except exceptions.VirtualMachineError as ex:
        assert "VestingVault__InsufficientLockedTime" in str(ex)


#### withdrawToken function ###


def test_withdrawToken(vaultContract, tokenContract):
    assert vaultContract.funded() == False
    tokenContract.transfer(accounts[0], 10000, {"from": accounts[2]})
    tokenContract.approve(vaultContract.address, 10000, {"from": accounts[0]})
    vaultContract.fundToken(tokenContract.address, 100, 10, {"from": accounts[0]})
    assert vaultContract.funded() == True
    chain.sleep(10)
    vaultContract.withdrawToken({"from": accounts[1]})
    assert tokenContract.balanceOf(accounts[1]) == 100


def test_WithdrawerNotBeneficiary(vaultContract, tokenContract):
    assert vaultContract.funded() == False
    tokenContract.transfer(accounts[0], 10000, {"from": accounts[2]})
    tokenContract.approve(vaultContract.address, 10000, {"from": accounts[0]})
    vaultContract.fundToken(tokenContract.address, 100, 10, {"from": accounts[0]})
    assert vaultContract.funded() == True
    chain.sleep(10)
    try:
        vaultContract.withdrawToken({"from": accounts[1]})
    except exceptions.VirtualMachineError as ex:
        assert "VestingVault__WithdrawerNotBeneficiary" in str(ex)


# it raises VestingVault__AlreadyFunded not VestingVault__VaultNotFunded
def test_VaultNotFunded(vaultContract):
    vaultContract.withdrawToken({"from": accounts[1]})


def test_UnlockTimeNotPassed(vaultContract, tokenContract):
    assert vaultContract.funded() == False
    tokenContract.transfer(accounts[0], 10000, {"from": accounts[2]})
    tokenContract.approve(vaultContract.address, 10000, {"from": accounts[0]})
    vaultContract.fundToken(tokenContract.address, 100, 10, {"from": accounts[0]})
    assert vaultContract.funded() == True
    try:
        vaultContract.withdrawToken({"from": accounts[1]})
    except exceptions.VirtualMachineError as ex:
        assert "VestingVault__UnlockTimeNotPassed" in str(ex)


### view functions ###


def test_getAmountVested(vaultContract, tokenContract):
    assert vaultContract.funded() == False
    tokenContract.transfer(accounts[0], 10000, {"from": accounts[2]})
    tokenContract.approve(vaultContract.address, 10000, {"from": accounts[0]})
    vaultContract.fundToken(tokenContract.address, 100, 10, {"from": accounts[0]})
    assert vaultContract.getAmountVested() == 100


def test_getUnlockTime(vaultContract, tokenContract):
    assert vaultContract.funded() == False
    tokenContract.transfer(accounts[0], 10000, {"from": accounts[2]})
    tokenContract.approve(vaultContract.address, 10000, {"from": accounts[0]})
    vaultContract.fundToken(tokenContract.address, 100, 10, {"from": accounts[0]})
    assert vaultContract.getUnlockTime() == chain.time() + 10
