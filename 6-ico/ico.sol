// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.9.0;

// ----------------------------------------------------------------------------
// EIP-20: ERC-20 Token Standard
// https://eips.ethereum.org/EIPS/eip-20
// -----------------------------------------
interface ERC20Token {
    function totalSupply() external view returns (uint);

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance the balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value)  external returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender  , uint256 _value) external returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Cryptos is ERC20Token {
    string public name = "Cryptos";
    string public symbol = "CRPT";
    uint public decimals = 0; // Usually, 18 is used. Here, we keep it simple.
    uint public override totalSupply;

    // Not part of the ERC20 standard, but useful
    address public founder;

    mapping(address => uint) public balances;

    // 0x1111 (owner) allows 0x2222 (spender) to spend 100 tokens
    // allowed[0x1111][0x2222] = 100
    mapping(address => mapping(address => uint)) allowed;

    // MANDATORY FUNCTIONS FOR THE STANDARD
    // These functions are sufficient to represent an ERC20 token that can be owned and transferred

    constructor() {
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }

    function balanceOf(address _owner) public view override returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balances[msg.sender] >= _value);

        balances[_to] += _value;
        balances[msg.sender] -= _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    // OPTIONAL FUNCTIONS TO BE FULLY COMPLIANT

    function allowance(address _owner, address _spender) public view override returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender  , uint256 _value) public override returns (bool success) {
        require(balances[msg.sender] >= _value);
        require(_value > 0);

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(allowed[_from][msg.sender] >= _value);
        require(balances[_from] >= _value);
        
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value);

        return true;
    }
}

contract CryptosICO is Cryptos {
    address public admin;
    address payable public deposit;

    uint tokenPrice = 0.001 ether;

    uint public hardCap = 300 ether;
    uint public raisedAmount;

    uint public saleStart = block.timestamp;
    uint public saleEnd = block.timestamp + 604800; // In a week after saleStart
    uint public tokenTradeStart = saleEnd + 604800; // In a week after saleEnd

    uint public minInvestment = 0.1 ether;
    uint public maxInvestment = 5 ether;

    enum ICOState {beforeStart, running, afterEnd, halted}
    ICOState public state;

    event Invest(address investor, uint value, uint tokens);

    constructor(address payable _deposit) {
        admin = msg.sender;
        deposit = _deposit;
        state = ICOState.beforeStart;
    }

    receive() payable external {
        invest();
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function halt() public onlyAdmin {
        state = ICOState.halted;
    }

    function resume() public onlyAdmin {
        state = ICOState.running;
    }

    function changeDeposit(address payable _deposit) public onlyAdmin {
        deposit = _deposit;
    }

    function getCurrentState() public view returns(ICOState) {
        if (state == ICOState.halted) {
            return state;
        } else if (block.timestamp < saleStart) {
            return ICOState.beforeStart;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return ICOState.running;
        } else {
            return ICOState.afterEnd;
        }
    }

    function invest() payable public returns (bool) {
        require(getCurrentState() == ICOState.running);
        require(msg.value >= minInvestment && msg.value <= maxInvestment);

        raisedAmount += msg.value;
        
        require(raisedAmount <= hardCap);

        uint tokens = msg.value / tokenPrice;

        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);

        emit Invest(msg.sender, msg.value, tokens);

        return true;
    }
}
