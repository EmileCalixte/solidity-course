// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract Crowdfunding {
    address public admin;

    mapping(address => uint) public contributors;
    uint public contributorsCount;

    uint public minimumContribution = 100 wei;

    uint public deadline; // timestamp
    uint public contributionGoal;

    uint public raisedAmount;

    constructor(uint _contributionGoal, uint campaignDuration) { // campaignDuration in seconds
        contributionGoal = _contributionGoal;
        deadline = block.timestamp + campaignDuration;
        
        admin = msg.sender;
    }

    receive() payable external {
        contribute();
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "Deadline has passed");
        require(msg.value >= minimumContribution, "Minimum contribution not met");

        if (contributors[msg.sender] == 0) {
            ++contributorsCount;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}
