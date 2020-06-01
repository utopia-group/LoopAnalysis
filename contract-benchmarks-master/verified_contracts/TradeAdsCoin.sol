pragma solidity ^0.4.24;

/*
--------------------------------------------------------------------------------
TradeAds Coin Smart Contract

Credit	: Rejean Leclerc 
Mail 	: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="addfc8c7c8ccc383c1c8cec1c8dfce9c9f9eedcac0ccc4c183cec2c0">[email protected]</a>&#13;
&#13;
--------------------------------------------------------------------------------&#13;
*/&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
    uint256 c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
contract TradeAdsCoin {&#13;
           &#13;
    using SafeMath for uint256;&#13;
    &#13;
    string public constant name = "TradeAds Coin";&#13;
    string public constant symbol = "TRD";&#13;
    uint8 public constant decimals = 18;&#13;
    /* The initially/total supply is 100,000,000 TRD with 18 decimals */&#13;
    uint256 public constant _totalSupply  = 100000000000000000000000000;&#13;
    &#13;
    address public owner;&#13;
    mapping(address =&gt; uint256) public balances;&#13;
    mapping(address =&gt; mapping (address =&gt; uint256)) public allowed;&#13;
    &#13;
	event Transfer(address indexed from, address indexed to, uint256 value);&#13;
    event Approval(address indexed from, address indexed to, uint256 value);&#13;
	&#13;
    function TradeAdsCoin() public {&#13;
        owner = msg.sender;&#13;
        balances[owner] = _totalSupply;&#13;
    }&#13;
    &#13;
   function () public payable {&#13;
        tTokens();&#13;
    }&#13;
    &#13;
	function tTokens() public payable {&#13;
        require(msg.value &gt; 0);&#13;
		balances[msg.sender] = balances[msg.sender].add(msg.value);&#13;
		balances[owner] = balances[owner].sub(msg.value);&#13;
		owner.transfer(msg.value);&#13;
    }&#13;
&#13;
    /* Transfer the balance from the sender's address to the address _to */&#13;
    function transfer(address _to, uint256 _value) public returns (bool success) {&#13;
        if (balances[msg.sender] &gt;= _value&#13;
            &amp;&amp; _value &gt; 0&#13;
            &amp;&amp; balances[_to] + _value &gt; balances[_to]) {&#13;
			balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
            balances[_to] = balances[_to].add(_value);&#13;
            Transfer(msg.sender, _to, _value);&#13;
            return true;&#13;
        } else {&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    /* Withdraws to address _to form the address _from up to the amount _value */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {&#13;
        if (balances[_from] &gt;= _value&#13;
            &amp;&amp; allowed[_from][msg.sender] &gt;= _value&#13;
            &amp;&amp; _value &gt; 0&#13;
            &amp;&amp; balances[_to] + _value &gt; balances[_to]) {&#13;
            balances[_from] = balances[_from].sub(_value);&#13;
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
            balances[_to] = balances[_to].add(_value);&#13;
            Transfer(_from, _to, _value);&#13;
            return true;&#13;
        } else {&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    /* Allows _spender to withdraw the _allowance amount form sender */&#13;
    function approve(address _spender, uint256 _value) public returns (bool success) {&#13;
        if (balances[msg.sender] &gt;= _value) {&#13;
            allowed[msg.sender][_spender] = _value;&#13;
            Approval(msg.sender, _spender, _value);&#13;
            return true;&#13;
        } else {&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    /* Checks how much _spender can withdraw from _owner */&#13;
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
   function balanceOf(address _address) public constant returns (uint256 balance) {&#13;
        return balances[_address];&#13;
    }&#13;
    &#13;
    function totalSupply() public constant returns (uint256 totalSupply) {&#13;
        return _totalSupply;&#13;
    }&#13;
    &#13;
}