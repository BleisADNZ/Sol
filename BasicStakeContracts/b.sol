// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.7.6;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b;require(c >= a, "SafeMath: addition overflow");return c;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return sub(a, b, "SafeMath: subtraction overflow");}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {require(b <= a, errorMessage);uint256 c = a - b;return c;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {if (a == 0) {return 0;}uint256 c = a * b;require(c / a == b, "SafeMath: multiplication overflow");return c;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return div(a, b, "SafeMath: division by zero");}
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {require(b > 0, errorMessage);uint256 c = a / b;return c;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return mod(a, b, "SafeMath: modulo by zero");}
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {require(b != 0, errorMessage);return a % b;}
}
interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
contract B is IBEP20 {
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Staked(address indexed user, uint256 amount, uint256 total);
    event Unstaked(address indexed user, uint256 amount, uint256 total);
    string public constant name = "B";
    string public constant symbol = "b";
    uint8 public constant decimals = 18;
    IBEP20 public cakeaddress;
    mapping(address => uint256) balances;
    mapping(address => uint256) private stakedbalances;
    mapping(address => uint256) public stakeMul;
    mapping(address => uint256) public stakeMulMax;
    mapping(address => uint) private staketimestamps;
    mapping(address => mapping (address => uint256)) private allowed;
    uint256 private timeBlock = 8064; // x300 gives 28 days in seconds
    uint256 private totalSupply_ = 0;
    uint256 private totalstaked = 0;
    address o;
    using SafeMath for uint256;
    
    constructor(IBEP20 tokenaddress) {cakeaddress = tokenaddress;o = msg.sender;}
    function burn(uint256 amount) internal {
        require(balances[msg.sender] >= amount, 'Amount exceeds balance');
        require(stakedbalances[msg.sender] != 0, "Nothing staked");
        require(stakeMul[msg.sender].add(amount) <= stakeMulMax[msg.sender], "Max burn multiplier reached");
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalSupply_ = totalSupply_.sub(amount);
        stakeMul[msg.sender] = stakeMul[msg.sender].add(amount);
    }
    function totalSupply() public view returns (uint256) {return totalSupply_;}
    function balanceOf(address tokenOwner) public override view returns (uint) {return balances[tokenOwner];}
    function uniBalance(address tokenOwner) public view returns (uint) {return cakeaddress.balanceOf(tokenOwner);}
    function getOwner() public view returns (address) {return o;}
    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender], 'Amount exceeds balance.');
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    function approve(address delegate, uint256 amount) public returns (bool) {
        require(amount <= balances[msg.sender], 'Amount exceeds balance.');
        allowed[msg.sender][delegate] = amount;
        emit Approval(msg.sender, delegate, amount);
        return true;
    }
    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(addedValue <= balances[msg.sender].sub(allowed[msg.sender][spender]), 'Amount exceeds balance.');
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(subtractedValue <= allowed[msg.sender][spender], 'Amount exceeds balance.');
        allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    function transferFrom(address owner, address buyer, uint amount) public override returns (bool) {
        require(amount <= balances[owner], 'Amount exceeds balance.');
        require(amount <= allowed[owner][msg.sender], 'Amount exceeds allowance.');
       
        balances[owner] = balances[owner].sub(amount);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(amount);
        balances[buyer] = balances[buyer].add(amount);
        emit Transfer(msg.sender, buyer, amount);
        return true;
    }
    function stake(uint256 amount) public returns (bool) {
        require(amount >= 100);
        require(amount <= uniBalance(msg.sender));
        require(amount <= cakeaddress.allowance(msg.sender, address(this)));
        cakeaddress.transferFrom(msg.sender, address(this), amount);
        stakedbalances[msg.sender] = stakedbalances[msg.sender].add(amount);
        totalstaked = totalstaked.add(amount);
        staketimestamps[msg.sender] = block.timestamp;
        stakeMul[msg.sender] = 0;
        stakeMulMax[msg.sender] = amount.div(10);
        emit Staked(msg.sender, amount, stakedbalances[msg.sender]);
        return true;
    }
    function unstake(uint256 amount) public returns (bool) {
        require(amount <= stakedbalances[msg.sender]);
        require(amount <= totalstaked);
        stakedbalances[msg.sender] = stakedbalances[msg.sender].sub(amount);
        totalstaked = totalstaked.sub(amount);
        staketimestamps[msg.sender] = block.timestamp;
        stakeMul[msg.sender] = 0;
        stakeMulMax[msg.sender] = 0;
        cakeaddress.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount, stakedbalances[msg.sender]);
        return true;
    }
    function mint() public {
        require(stakedbalances[msg.sender] >= 100, "Nothing staked to mine for");
        require(stakeTFor(msg.sender) > timeBlock, "Not enough time passed to mint");
        
        uint256 amount = calculate();
        stakeMul[msg.sender] = 0;
        staketimestamps[msg.sender] = block.timestamp;
        balances[msg.sender] = balances[msg.sender].add(amount);
        totalSupply_ = totalSupply_.add(amount);
    }
    function calculate() public view returns (uint256) {
        uint256 amount = stakedbalances[msg.sender];
        // Time Mint
        uint256 mintLoad = amount.div(100).mul(stakeTFor(msg.sender).div(timeBlock));
        // Multiplier
        mintLoad = mintLoad.add(
            mintLoad.div(100).mul(
                stakeMul[msg.sender].div(
                    stakeMulMax[msg.sender].div(100)
                ) 
            )
        );
        return mintLoad;
    }
    function stakeMultiplierFor(address addr) public view returns (uint256) {return stakeMul[addr];}
    function totalStakedFor(address addr) public view returns (uint256) {return stakedbalances[addr];}
    function stakeTimestampFor(address addr) public view returns (uint256) {return staketimestamps[addr];}
    function stakeTFor(address addr) public view returns (uint256) {return block.timestamp.sub(staketimestamps[addr]);}
    function totalStaked() public view returns (uint256) {return totalstaked;}
}
