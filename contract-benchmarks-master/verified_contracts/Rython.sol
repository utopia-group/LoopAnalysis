/* 
@title Rython Project
 */
pragma solidity ^0.4.18;

/*
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /*
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /*
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    // Copyright (c) 2018
    // Contract Signed by: Rython Support Team <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b5c6c0c5c5dac7c1f5c7ccc1dddadb9bdcda">[email protected]</a>&#13;
&#13;
    /*&#13;
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
    */&#13;
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
    }&#13;
      &#13;
    /*&#13;
    * @dev Adds two numbers, throws on overflow.&#13;
    */&#13;
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
        c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
}&#13;
&#13;
contract ForeignToken {&#13;
    function balanceOf(address _owner) constant public returns (uint256);&#13;
    function transfer(address _to, uint256 _value) public returns (bool);&#13;
}&#13;
&#13;
contract ERC20Basic {&#13;
    uint256 public totalSupply;&#13;
    function balanceOf(address who) public constant returns (uint256);&#13;
    function transfer(address to, uint256 value) public returns (bool);&#13;
    event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
contract ERC20 is ERC20Basic {&#13;
    function allowance(address owner, address spender) public constant returns (uint256);&#13;
    function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
    function approve(address spender, uint256 value) public returns (bool);&#13;
    event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
contract Rython is ERC20 {&#13;
    &#13;
    using SafeMath for uint256;&#13;
    address owner = msg.sender;&#13;
&#13;
    mapping (address =&gt; uint256) balances;&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed;    &#13;
&#13;
    string public constant name = "Rython";&#13;
    string public constant symbol = "RYTN";&#13;
    uint public constant decimals = 8;&#13;
    &#13;
    uint256 public totalSupply = 10000000000e8;&#13;
    uint256 public totalDistributed = 0;    &#13;
    uint256 public constant MIN_PURCHASE = 1 ether / 100;&#13;
    uint256 public tokensPerEth = 15000000e8;&#13;
&#13;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);&#13;
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);&#13;
    &#13;
    event Distr(address indexed to, uint256 amount);&#13;
    event DistrFinished();&#13;
&#13;
    event Airdrop(address indexed _owner, uint _amount, uint _balance);&#13;
&#13;
    event TokensPerEthUpdated(uint _tokensPerEth);&#13;
    &#13;
    event Burn(address indexed burner, uint256 value);&#13;
&#13;
    bool public distributionFinished = false;&#13;
    &#13;
    modifier canDistr() {&#13;
        require(!distributionFinished);&#13;
        _;&#13;
    }&#13;
    &#13;
    modifier onlyOwner() {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
    &#13;
    &#13;
    constructor () public {&#13;
        owner = msg.sender;&#13;
        uint256 devTokens = 2500000000e8;&#13;
        distr(owner, devTokens);        &#13;
    }&#13;
    &#13;
    function transferOwnership(address newOwner) onlyOwner public {&#13;
        if (newOwner != address(0)) {&#13;
            owner = newOwner;&#13;
        }&#13;
    }&#13;
&#13;
function finishDistribution() onlyOwner canDistr public returns (bool) {&#13;
        distributionFinished = true;&#13;
        emit DistrFinished();&#13;
        return true;&#13;
    }&#13;
    &#13;
    function distr(address _to, uint256 _amount) canDistr private returns (bool) {&#13;
        totalDistributed = totalDistributed.add(_amount);        &#13;
        balances[_to] = balances[_to].add(_amount);&#13;
        emit Distr(_to, _amount);&#13;
        emit Transfer(address(0), _to, _amount);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    function doAirdrop(address _participant, uint _amount) internal {&#13;
&#13;
        require( _amount &gt; 0 );      &#13;
&#13;
        require( totalDistributed &lt; totalSupply );&#13;
        &#13;
        balances[_participant] = balances[_participant].add(_amount);&#13;
        totalDistributed = totalDistributed.add(_amount);&#13;
&#13;
        if (totalDistributed &gt;= totalSupply) {&#13;
            distributionFinished = true;&#13;
        }&#13;
&#13;
        // log&#13;
        emit Airdrop(_participant, _amount, balances[_participant]);&#13;
        emit Transfer(address(0), _participant, _amount);&#13;
    }&#13;
&#13;
    function transferTokenTo(address _participant, uint _amount) public onlyOwner {        &#13;
        doAirdrop(_participant, _amount);&#13;
    }&#13;
&#13;
    function transferTokenToMultiple(address[] _addresses, uint _amount) public onlyOwner {        &#13;
        for (uint i = 0; i &lt; _addresses.length; i++) doAirdrop(_addresses[i], _amount);&#13;
    }&#13;
&#13;
    &#13;
&#13;
    function updateTokensPerEth(uint _tokensPerEth) public onlyOwner {        &#13;
        tokensPerEth = _tokensPerEth;&#13;
        emit TokensPerEthUpdated(_tokensPerEth);&#13;
    }&#13;
           &#13;
    function () external payable {&#13;
        getTokens();&#13;
     }&#13;
    &#13;
    function getTokens() payable canDistr  public {&#13;
        uint256 tokens = 0;&#13;
&#13;
        // minimum contribution&#13;
        require( msg.value &gt;= MIN_PURCHASE );&#13;
&#13;
        require( msg.value &gt; 0 );&#13;
&#13;
        // get baseline number of tokens&#13;
        tokens = tokensPerEth.mul(msg.value) / 1 ether;        &#13;
        address investor = msg.sender;&#13;
        &#13;
        if (tokens &gt; 0) {&#13;
            distr(investor, tokens);&#13;
        }&#13;
&#13;
        if (totalDistributed &gt;= totalSupply) {&#13;
            distributionFinished = true;&#13;
        }&#13;
    }&#13;
&#13;
    function balanceOf(address _owner) constant public returns (uint256) {&#13;
        return balances[_owner];&#13;
    }&#13;
&#13;
    // mitigates the ERC20 short address attack&#13;
    modifier onlyPayloadSize(uint size) {&#13;
        assert(msg.data.length &gt;= size + 4);&#13;
        _;&#13;
    }&#13;
    &#13;
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {&#13;
&#13;
        require(_to != address(0));&#13;
        require(_amount &lt;= balances[msg.sender]);&#13;
        &#13;
        balances[msg.sender] = balances[msg.sender].sub(_amount);&#13;
        balances[_to] = balances[_to].add(_amount);&#13;
        emit Transfer(msg.sender, _to, _amount);&#13;
        return true;&#13;
    }&#13;
    &#13;
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {&#13;
&#13;
require(_to != address(0));&#13;
        require(_amount &lt;= balances[_from]);&#13;
        require(_amount &lt;= allowed[_from][msg.sender]);&#13;
        &#13;
        balances[_from] = balances[_from].sub(_amount);&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);&#13;
        balances[_to] = balances[_to].add(_amount);&#13;
        emit Transfer(_from, _to, _amount);&#13;
        return true;&#13;
    }&#13;
    &#13;
&#13;
    function approve(address _spender, uint256 _value) public returns (bool success) {&#13;
        // mitigates the ERC20 spend/approval race condition&#13;
        if (_value != 0 &amp;&amp; allowed[msg.sender][_spender] != 0) { return false; }&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
    &#13;
    function allowance(address _owner, address _spender) constant public returns (uint256) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
    &#13;
    function getTokenBalance(address tokenAddress, address who) constant public returns (uint){&#13;
        ForeignToken t = ForeignToken(tokenAddress);&#13;
        uint bal = t.balanceOf(who);&#13;
        return bal;&#13;
    }&#13;
    &#13;
    &#13;
    function withdraw() onlyOwner public {&#13;
        address myAddress = this;&#13;
        uint256 etherBalance = myAddress.balance;&#13;
        owner.transfer(etherBalance);&#13;
    }&#13;
    &#13;
    function burn(uint256 _value) onlyOwner public {&#13;
        require(_value &lt;= balances[msg.sender]);&#13;
        // no need to require value &lt;= totalSupply, since that would imply the&#13;
        // sender's balance is greater than the totalSupply, which should be an assertion failure&#13;
&#13;
        address burner = msg.sender;&#13;
        balances[burner] = balances[burner].sub(_value);&#13;
        totalSupply = totalSupply.sub(_value);&#13;
        totalDistributed = totalDistributed.sub(_value);&#13;
        emit Burn(burner, _value);&#13;
    }&#13;
    &#13;
    function withdrawForeignTokens(address _tokenContract) onlyOwner public returns (bool) {&#13;
        ForeignToken token = ForeignToken(_tokenContract);&#13;
        uint256 amount = token.balanceOf(address(this));&#13;
        return token.transfer(owner, amount);&#13;
    }&#13;
}