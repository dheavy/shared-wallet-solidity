// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.11;

import "./Allowance.sol";

contract SharedWallet is Allowance {

    event MoneySent(address indexed _beneficiary, uint _amount);
    event MoneyReceived(address indexed _from, uint _amount);

    function withdraw(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, "Not enough funds in contract");

        if (!isOwner()) {
            reduceAllowance(msg.sender, _amount);
        }
        emit MoneySent(_to, _amount);

        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Withdrawal failed");
    }

    function renounceOwnership() public override view onlyOwner {
        revert("Can't renounce ownership here");
    }

    receive() external payable {
        emit MoneyReceived(msg.sender, msg.value);
    }
}
