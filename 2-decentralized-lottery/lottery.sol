// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.6.0 <0.9.0;

contract Lottery {
    address payable[] public players; // Anyone will be able to see the registered players

    address public manager;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        require(msg.value == 0.1 ether);

        // Convert plain address to payable address
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint) {
        require(msg.sender == manager);

        return address(this).balance;
    }
}
