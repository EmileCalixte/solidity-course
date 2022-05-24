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

    modifier onlyOwner() {
        require(owner == msg.sender);
        _; // <- Here comes the original function code
    }

    modifier notOwner() {
        require(owner != msg.sender);
        _;
    }

    modifier afterStart() {
        require(block.number >= startBlockNumber);
        _;
    }

    modifier beforeEnd() {
        require(block.number < endBlockNumber);
        _;
    }

    function changeOwner(address payable _owner) public onlyOwner {
        owner = _owner;
    }

    function cancelAuction() public onlyOwner {
        state = AuctionState.Cancelled;
    }

    function placeBid() public payable notOwner afterStart beforeEnd {
        require(state == AuctionState.Running, "The auction is not running");
        require(msg.value >= 100); // For our tests, 100 wei is fine. In real cases, we should put a greater value, like 0.01 Ether for example

        uint currentBid = bids[msg.sender] + msg.value; // The value already sent by the current address + the value sent with this transaction

        require(currentBid > highestBindingBid, "Your bid must be higher than the current highest bid");

        bids[msg.sender] = currentBid;

        if (currentBid <= bids[highestBidder]) {
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        } else {
            highestBindingBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
    }

    function min(uint a, uint b) internal pure returns(uint) {
        if (a <= b) {
            return a;
        } else {
            return b;
        }
    }
}
