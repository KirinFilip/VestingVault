# Vesting contract

Vesting is the process of locking and distributing purchased tokens within a given timeframe. A particular timeframe that determines vesting is known as the "Vesting Period" - It basically delays the access to the assets being offered.

This contract handles the vesting of Eth and ERC20 tokens for a given beneficiary. Custody of multiple tokens can be given to this contract, which will release the token to the beneficiary following a given vesting schedule.

### Functions

- constructor
  - owned by the deployer of the contract
  - deployed with a set recipient (beneficiery)
- fundToken
  - one time function to fund the vault with ERC-20 tokens
  - sets an unlock time
  - only owner can call
- withdrawToken
  - only beneficiary can withdraw tokens after unlock time
- getBeneficiary
  - returns the address of the beneficiary
- getAmountVested
  - returns the amount of vested tokens
- getUnlockTime
  - returns the time the tokens are locked

### Events

- ERC20Funded(token, amount)
- ERC20Withdrawn(token, amount)
