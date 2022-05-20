//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Deposit {
    address private immutable admin;

    constructor() {
        admin = msg.sender;
    }

    receive() external payable {}

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function transferBalance(address payable to) public {
        require(msg.sender == admin, "You must be the contract admin to transfer balance");

        uint amount = address(this).balance; // We can also use directly the getBalance() global function
        to.transfer(amount);
    }
}
