// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

contract Recoverability {

	address recoveryAddress;
    address burnAddress = 0x0000000000000000000000000000000000000000;

    constructor(address _recoveryAddress){
        recoveryAddress = _recoveryAddress;
    }

    function _setRecoveryAddress(address newRecoveryAddress) internal {
        recoveryAddress = newRecoveryAddress;
    }

    function _setBurnAddress(address newBurnAddress) internal {
        burnAddress = newBurnAddress;
    }
}