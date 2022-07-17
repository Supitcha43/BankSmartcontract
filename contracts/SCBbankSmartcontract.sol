// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract owned {
    address public owner;
    address public newOwner;
    
    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }    

    modifier onlyOwner {
        require(msg.sender == newOwner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptionOwnership() public {
        require(msg.sender == newOwner);
        
        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);
    }

}

contract BankContractSystem is owned {
    mapping (address => string) public users;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) allowed;
    address[] accounts;
    uint256 public totalSupply;

    string public name = "DAI";
    string public symbol = "DAI";
    uint8 public constant decimals = 18;

    event DepositMade(address accountAddress, uint amount);
    event WithdrawMade(address indexed accountAddress, uint amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event SystemDepositMade(address indexed admin, uint amount);
    event SystemWithdrawMade(address indexed admin, uint amount);


    constructor(uint _value) public {
        totalSupply = _value;
        balances[msg.sender] = _value;
    }

    function CreateUser (string memory username) public {
        users[msg.sender] = username;
    }

    function GetUsername (address userAddress) public view returns (string memory){
        return users[userAddress];
    }

    function transferFrom (address _from,address _to, uint256 _value) public returns (bool success) {
        balances[_from] -= _value;
        allowed[_from][msg.sender] += _value;
        balances[_to] == _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve (address _spender, uint256 _value) public returns (bool success){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance (address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function balanceOf(address owner) view public returns (uint256) {
        return balances[owner];
    }

    function Deposit(uint256 value) public payable returns(uint256){
        if (0 == balances[msg.sender]) {
            accounts.push(msg.sender);
        }
        balances[msg.sender] = balances[msg.sender] + msg.value;

        emit DepositMade(msg.sender, msg.value);
        return balances[msg.sender];
    }

    function withdraw(uint withdrawAmount) public returns (uint256) {
        require(balances[msg.sender] >= withdrawAmount, "Your balance is not enough");
        balances[msg.sender] = balances[msg.sender] - withdrawAmount;

        payable(msg.sender).transfer(withdrawAmount);
        
        emit WithdrawMade(msg.sender, withdrawAmount);
        
        return balances[msg.sender];
    }

    function transfer (address to , uint256 _value) external returns (bool) {
        require(balances[msg.sender] >= _value);
        balances[to] = balances[to] + _value;
        balances[msg.sender] = balances[msg.sender] - _value;

        emit Transfer(msg.sender, to, _value);

        return true;
    }

    function systemBalance(uint256 userAddress) public view returns(uint256) {
        return address(this).balance;
    }

}