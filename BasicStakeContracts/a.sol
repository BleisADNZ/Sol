// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.7.6;

// SafeMath library provided by the OpenZeppelin Group on Github

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b;require(c >= a, "SafeMath: addition overflow");return c;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return sub(a, b, "SafeMath: subtraction overflow");}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {require(b <= a, errorMessage);uint256 c = a - b;return c;}
}

contract A {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    string public constant name = "A";
    string public constant symbol = "a";
    uint8 public constant decimals = 18;
    mapping(address => uint256) private balances;
    mapping(address => mapping (address => uint256)) private allowed;
    uint256 private totalSupply_ = 100000000000000000000;
    address private o;
    using SafeMath for uint256;
    
    constructor() {
        balances[msg.sender] = totalSupply_;
        o = msg.sender;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }
    function totalSupply() public view returns (uint256) {return totalSupply_;}
    function balanceOf(address tokenOwner) public view returns (uint) {return balances[tokenOwner];}
    function getOwner() public view returns (address) {return o;}
    function transfer(address receiver, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender], 'Amount exceeds balance');
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner], 'Amount exceeds balance');
        require(numTokens <= allowed[owner][msg.sender], 'Amount exceeds allowance');
        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(msg.sender, buyer, numTokens);
        return true;
    }
}
