pragma solidity ^0.4.13;


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BACA is ERC20,Ownable{
	using SafeMath for uint256;

	string public constant name="<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="274542426744484e49">[email protected]</a>";&#13;
	string public symbol="BACA";&#13;
	string public constant version = "1.0";&#13;
	uint256 public constant decimals = 18;&#13;
	uint256 public totalSupply;&#13;
&#13;
	uint256 public constant MAX_SUPPLY=410000000000*10**decimals;&#13;
&#13;
	&#13;
    mapping(address =&gt; uint256) balances;&#13;
	mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
	event GetETH(address indexed _from, uint256 _value);&#13;
&#13;
	function BACA(){&#13;
		totalSupply=MAX_SUPPLY;&#13;
		balances[msg.sender] = MAX_SUPPLY;&#13;
		Transfer(0x0, msg.sender, MAX_SUPPLY);&#13;
	}&#13;
&#13;
	function () payable external&#13;
	{&#13;
		GetETH(msg.sender,msg.value);&#13;
	}&#13;
&#13;
	function etherProceeds() external&#13;
		onlyOwner&#13;
	{&#13;
		if(!msg.sender.send(this.balance)) revert();&#13;
	}&#13;
&#13;
  	function transfer(address _to, uint256 _value) public  returns (bool)&#13;
 	{&#13;
		require(_to != address(0));&#13;
		// SafeMath.sub will throw if there is not enough balance.&#13;
		balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
		balances[_to] = balances[_to].add(_value);&#13;
		Transfer(msg.sender, _to, _value);&#13;
		return true;&#13;
  	}&#13;
&#13;
  	function balanceOf(address _owner) public constant returns (uint256 balance) &#13;
  	{&#13;
		return balances[_owner];&#13;
  	}&#13;
&#13;
  	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) &#13;
  	{&#13;
		require(_to != address(0));&#13;
		uint256 _allowance = allowed[_from][msg.sender];&#13;
&#13;
		balances[_from] = balances[_from].sub(_value);&#13;
		balances[_to] = balances[_to].add(_value);&#13;
		allowed[_from][msg.sender] = _allowance.sub(_value);&#13;
		Transfer(_from, _to, _value);&#13;
		return true;&#13;
  	}&#13;
&#13;
  	function approve(address _spender, uint256 _value) public returns (bool) &#13;
  	{&#13;
		allowed[msg.sender][_spender] = _value;&#13;
		Approval(msg.sender, _spender, _value);&#13;
		return true;&#13;
  	}&#13;
&#13;
  	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) &#13;
  	{&#13;
		return allowed[_owner][_spender];&#13;
  	}&#13;
&#13;
	  &#13;
}