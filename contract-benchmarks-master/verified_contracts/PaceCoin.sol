// Copyright (c) 2017-18 pacecoin.io

// Developed by pacecoin core development team
// Contact for information at <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="066f686069467667656365696f68286f69">[email protected]</a>&#13;
&#13;
// Distributed under the MIT/X11 software license, see https://opensource.org/licenses/MIT&#13;
&#13;
pragma solidity 0.4.19;&#13;
&#13;
contract ERC20Basic {&#13;
  uint256 public totalSupply;&#13;
  function balanceOf(address who) constant returns (uint256);&#13;
  function transfer(address to, uint256 value) returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender) constant returns (uint256);&#13;
  function transferFrom(address from, address to, uint256 value) returns (bool);&#13;
  function approve(address spender, uint256 value) returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping(address =&gt; uint256) balances;&#13;
&#13;
  function transfer(address _to, uint256 _value) returns (bool) {&#13;
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  function balanceOf(address _owner) constant returns (uint256 balance) {&#13;
    return balances[_owner];&#13;
  }&#13;
&#13;
}&#13;
&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
  function Ownable() {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  function transferOwnership(address newOwner) onlyOwner {&#13;
    if (newOwner != address(0)) {&#13;
      owner = newOwner;&#13;
    }&#13;
  }&#13;
&#13;
}&#13;
&#13;
library SafeMath {&#13;
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    uint256 c = a * b;&#13;
    assert(a == 0 || c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  function div(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
                                                                                // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
                                                                                // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  function add(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
contract StandardToken is ERC20, BasicToken {&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {&#13;
    var _allowance = allowed[_from][msg.sender];&#13;
                                                                                // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met&#13;
                                                                                // require (_value &lt;= _allowance);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    allowed[_from][msg.sender] = _allowance.sub(_value);&#13;
    Transfer(_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  function approve(address _spender, uint256 _value) returns (bool) {&#13;
                                                                                &#13;
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));&#13;
&#13;
    allowed[msg.sender][_spender] = _value;&#13;
    Approval(msg.sender, _spender, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
&#13;
}&#13;
&#13;
contract PACECOIN is StandardToken, Ownable&#13;
{&#13;
    string public name = "PACECOIN";&#13;
    string public symbol = "PCN";&#13;
&#13;
    uint public decimals = 8;&#13;
&#13;
    uint private INITIAL_SUPPLY = 165 * 10**14;    //  165 000 000 or 165 Million&#13;
&#13;
    function PACECOIN()&#13;
    {&#13;
        owner = msg.sender;&#13;
        totalSupply = INITIAL_SUPPLY;&#13;
        balances[owner] = INITIAL_SUPPLY;&#13;
    }&#13;
}