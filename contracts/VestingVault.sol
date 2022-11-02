// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error AlreadyFundedError(bool locked);
error BeneficiaryZeroAddressError(address beneficiary);
error TokenZeroAddressError(address token);
error InsufficientFundAmountError(uint256 amount);
error InsufficientLockedTimeError(uint256 lockedTime);
error WithdrawerNotBeneficiaryError(address beneficiary);
error VaultNotFundedError();
error UnlockTimeNotPassedError();

contract VestingVault is Ownable{
    // event EtherFunded(uint256 amount);
    // event EtherWithdrawn(uint256 amount);
    event ERC20Funded(address token ,uint256 amount);
    event ERC20RWithdrawn(address token, uint256 amount);

    address private immutable _beneficiary;
    address public tokenVestedAddress;
    uint256 public amountVested;
    uint256 public unlockTime;
    bool public locked;

    modifier isLocked() {
        if(locked) revert AlreadyFundedError(locked);
        _;
    }

    constructor(address beneficiary) {
        if(beneficiary == address(0)) revert BeneficiaryZeroAddressError(beneficiary);
        _beneficiary = beneficiary;
    }

    function getBeneficiary() public view returns (address) {
        return _beneficiary;
    }

    function getAmountVested() public view returns (uint256) {
        return amountVested;
    }

    function getUnlockTime() public view returns (uint256) {
        return unlockTime;
    }

    function fund(address tokenAddress, uint256 amount, uint256 lockedTime) public onlyOwner isLocked {
        if(tokenAddress == address(0)) revert TokenZeroAddressError(address(tokenAddress));
        if(amount <= 0) revert InsufficientFundAmountError(amount);
        if(lockedTime <= 0) revert InsufficientLockedTimeError(lockedTime);

        assert(IERC20(tokenAddress).balanceOf(msg.sender) >= amount);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        emit ERC20Funded(tokenAddress, amount);

        locked = true;
        tokenVestedAddress = tokenAddress;
        amountVested = amount;
        unlockTime = block.timestamp + lockedTime;
    }

    function withdraw() public {
        if(msg.sender != getBeneficiary()) revert WithdrawerNotBeneficiaryError(getBeneficiary());
        if(!locked) revert VaultNotFundedError();
        if(block.timestamp < unlockTime) revert UnlockTimeNotPassedError();

        IERC20(tokenVestedAddress).transfer(getBeneficiary(), amountVested);
        emit ERC20RWithdrawn(tokenVestedAddress, amountVested);
    }
}
