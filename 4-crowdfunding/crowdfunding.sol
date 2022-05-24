// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract Crowdfunding {
    struct Request {
        string description;
        address payable recipient;
        uint amount;
        bool completed;
        uint votersCount;
        mapping(address => bool) voters;
    }

    address public admin;

    mapping(address => uint) public contributors;
    uint public contributorsCount;

    uint public minimumContribution = 100 wei;

    uint public deadline; // timestamp
    uint public contributionGoal;

    uint public raisedAmount;

    mapping(uint => Request) public requests;
    uint public numRequests;

    constructor(uint _contributionGoal, uint campaignDuration) { // campaignDuration in seconds
        contributionGoal = _contributionGoal;
        deadline = block.timestamp + campaignDuration;
        
        admin = msg.sender;
    }

    receive() payable external {
        contribute();
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
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

    function getRefund() public {
        require(block.timestamp >= deadline, "Deadline has not passed");
        require(raisedAmount < contributionGoal, "The goal was reached");

        require(contributors[msg.sender] > 0);

        address payable recipient = payable(msg.sender);
        uint value = contributors[msg.sender];

        contributors[msg.sender] = 0;
        recipient.transfer(value);
    }

    function createRequest(string memory _description, address payable _recipient, uint _amount) public onlyAdmin {
        Request storage newRequest = requests[numRequests];
        ++numRequests;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.amount = _amount;
        newRequest.votersCount = 0;
        newRequest.completed = false;
    }

    function voteForRequest(uint _requestNumber) public {
        require(contributors[msg.sender] > 0, "Only contributors can vote for a request");

        Request storage request = requests[_requestNumber];

        require(request.voters[msg.sender] == false, "You have already voted");
        
        request.voters[msg.sender] = true;
        ++request.votersCount;
    }
}
