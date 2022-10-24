// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract VestingVault is Ownable {
    address private immutable _beneficiary;
    uint64 private immutable _startTimestamp;
    uint64 private immutable _durationSeconds;
    uint256 private _released;
    mapping(address => uint256) private _releasedToken;

    event EtherReleased(uint256 amount);
    event ERC20Released(address token, uint256 amount);

    constructor(
        address beneficiary,
        uint64 startTimestamp,
        uint64 durationSeconds
    ) {
        _beneficiary = beneficiary;
        _startTimestamp = startTimestamp;
        _durationSeconds = durationSeconds;
    }

    receive() external payable onlyOwner {}

    function getBeneficiary() public view returns (address) {
        return _beneficiary;
    }

    function getStart() public view returns (uint256) {
        return _startTimestamp;
    }

    function getDuration() public view returns (uint256) {
        return _durationSeconds;
    }

    function getReleasedETH() public view returns (uint256) {
        return _released;
    }

    function getReleasedToken(address token) public view returns (uint256) {
        return _releasedToken[token];
    }
}
