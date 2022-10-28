// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VestingVault is Ownable {
    event EtherReleased(uint256 amount);
    event ERC20Released(address token, uint256 amount);

    address private immutable _beneficiary;
    uint64 private immutable _startTimestamp;
    uint64 private immutable _durationSeconds;

    uint256 private _releasedETH;
    mapping(address => uint256) private _releasedToken;

    bool public locked;

    modifier isLocked() {
        require(!locked, "Vesting Vault already funded");
        _;
    }

    constructor(
        address beneficiary,
        uint64 startTimestamp,
        uint64 durationSeconds
    ) {
        require(
            beneficiary != address(0),
            "Beneficiary can not be a zero address"
        );
        _beneficiary = beneficiary;
        _startTimestamp = startTimestamp;
        _durationSeconds = durationSeconds;
    }

    function getBeneficiary() public view returns (address) {
        return _beneficiary;
    }

    function getStartTime() public view returns (uint256) {
        return _startTimestamp;
    }

    function getDuration() public view returns (uint256) {
        return _durationSeconds;
    }

    function getReleasedETH() public view returns (uint256) {
        return _releasedETH;
    }

    function getReleasedToken(address token) public view returns (uint256) {
        return _releasedToken[token];
    }

    function fund() public onlyOwner isLocked {}

    function withdraw() public {}
}
