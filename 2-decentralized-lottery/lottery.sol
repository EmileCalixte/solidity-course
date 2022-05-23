// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.6.0 <0.9.0;

contract Lottery {
    address payable[] public players; // Anyone will be able to see the registered players

    address public manager;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        require(msg.value == 0.1 ether, "You have to send exactly 0.1 ETH to participate");
        require(msg.sender != manager, "The manager cannot participate");

        // Convert plain address to payable address
        players.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint) {
        require(msg.sender == manager, "Only the manager can get the lottery balance");

        return address(this).balance;
    }

    function pickWinner() public {
        require(msg.sender == manager, "Only the manager can pick a winner");
        require(players.length >= 3, "At least 3 players are required to pick a winner");

        uint r = random();
        uint index = r % players.length;
        
        address payable winner = players[index];

        winner.transfer(getBalance());

        reset();
    }

    // This function generates a pseudorandom integer which is not secure. We shouldn't use it in a real application.
    function random() internal view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function reset() internal {
        players = new address payable[](0);
    }
}
