# Vesting contract

This contract handles the vesting of Eth and ERC20 tokens for a given beneficiary. Custody of multiple tokens can be given to this contract, which will release the token to the beneficiary following a given vesting schedule.

### Functions

* constructor 
    * should be owned by the deployer of the contract
    * should be deployed with a set recipient (beneficiery)
* receive()
* beneficiary()
* start()
* duration()
* released()
* released(token)
* release()
* release(token)
* vestedAmount(timestamp)
* vestedAmount(token, timestamp)
* _vestingSchedule(totalAllocation, timestamp)

### Events

* EtherReleased(amount)
* ERC20Released(token, amount)
