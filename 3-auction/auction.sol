// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.6.0 <0.9.0;

contract Auction {
    enum AuctionState {Started, Running, Ended, Cancelled}

    address payable public owner;

    // In Solidity, time is tricky. `block.timestamp` can be spoofed by miners.
    // A good practice is to calculate the time based on the block number.
    uint public startBlockNumber;
    uint public endBlockNumber;

    // The auction description, images... are not stored directly in the blockchain because it's too expensive
    string public ipfsHash;

    AuctionState public state;

    uint public highestBindingBid;
    address payable public highestBidder;

    mapping(address => uint) public bids;

    uint bidIncrement;

    constructor() {
        owner = payable(msg.sender);
        state = AuctionState.Running;
        
        startBlockNumber = block.number;
        endBlockNumber = startBlockNumber + 40320; // The number of blocks created in a week in the Ethereum blockchain

        ipfsHash = "";
        bidIncrement = 100 wei;
    }
}
