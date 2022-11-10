// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error VestingVault__BeneficiaryZeroAddress(address beneficiary);
error VestingVault__AlreadyFunded(bool funded);
error VestingVault__TokenZeroAddress(address token);
error VestingVault__InsufficientFundAmount(uint256 amount);
error VestingVault__InsufficientLockedTime(uint256 lockedTime);
error VestingVault__WithdrawerNotBeneficiary(address beneficiary);
error VestingVault__VaultNotFunded(bool funded);
error VestingVault__UnlockTimeNotPassed();

contract VestingVault is Ownable{
    event ERC20Funded(address token, uint256 amount);
    event ERC20Withdrawn(address token, uint256 amount);

    address private immutable _beneficiary;
    address public tokenVestedAddress;
    uint256 public amountVested;
    uint256 public unlockTime;
    bool public funded = false;
    IERC20 public token;

    constructor(address beneficiary) {
        if(beneficiary == address(0)) revert VestingVault__BeneficiaryZeroAddress(beneficiary);
        _beneficiary = beneficiary;
    }

    // public functions

    function fundToken(address tokenAddress, uint256 amount, uint256 lockedTime) public onlyOwner {
        if(funded) revert VestingVault__AlreadyFunded(funded);
        if(tokenAddress == address(0)) revert VestingVault__TokenZeroAddress(address(tokenAddress));
        if(amount <= 0) revert VestingVault__InsufficientFundAmount(amount);
        if(lockedTime == 0) revert VestingVault__InsufficientLockedTime(lockedTime);

        token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), amount);
        emit ERC20Funded(tokenAddress, amount);

        funded = true;
        tokenVestedAddress = tokenAddress;
        amountVested = amount;
        unlockTime = block.timestamp + lockedTime;
    }

    function withdrawToken() public {
        if(msg.sender != getBeneficiary()) revert VestingVault__WithdrawerNotBeneficiary(getBeneficiary());
        if(!funded) revert VestingVault__VaultNotFunded(funded);
        if(block.timestamp < unlockTime) revert VestingVault__UnlockTimeNotPassed();

        token = IERC20(tokenVestedAddress);
        token.transfer(getBeneficiary(), amountVested);
        emit ERC20Withdrawn(tokenVestedAddress, amountVested);
    }

    // view functions

    function getBeneficiary() public view returns (address) {
        return _beneficiary;
    }

    function getAmountVested() public view returns (uint256) {
        return amountVested;
    }

    function getUnlockTime() public view returns (uint256) {
        return unlockTime;
    }
}
