// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    address payable[] public players; // Anyone will be able to see the registered players

    address public manager;

    constructor() {
        manager = msg.sender;
    }
}
