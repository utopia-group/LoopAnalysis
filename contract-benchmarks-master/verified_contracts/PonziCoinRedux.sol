pragma solidity ^0.4.2;

/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
/// @title Abstract token contract - Functions to be implemented by token contracts.

contract AbstractToken {
    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Issuance(address indexed to, uint256 value);
}

contract StandardToken is AbstractToken {

    /*
     *  Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    /*
     *  Read and write storage functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read storage functions
     */
    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


/// @title Token contract - Implements Standard Token Interface but adds Pyramid Scheme Support :)
/// @author Rishab Hegde - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e3808c8d97828097a3918a908b82818b86848786cd808c8e">[email protected]</a>&gt;&#13;
/// Missed the boat on the first PonziCoin?&#13;
/// Re-deployed by !author because that was fun, so let's do it again.&#13;
/// Get in while the gettin's good, and get out while you still can!&#13;
contract PonziCoinRedux is StandardToken, SafeMath {&#13;
&#13;
    /*&#13;
     * Token meta data&#13;
     */&#13;
    string constant public name = "PonziCoin";&#13;
    string constant public symbol = "SEC";&#13;
    uint8 constant public decimals = 3;&#13;
&#13;
    uint public buyPrice = 10 szabo;&#13;
    uint public sellPrice = 2500000000000 wei;&#13;
    uint public tierBudget = 100000;&#13;
&#13;
    // Address of the founder of PonziCoin.&#13;
    address public founder = 0x4688e5C3410B423DC749265Dfd4d513473445FE3;&#13;
&#13;
    /*&#13;
     * Contract functions&#13;
     */&#13;
    /// @dev Allows user to create tokens if token creation is still going&#13;
    /// and cap was not reached. Returns token count.&#13;
    function fund()&#13;
      public&#13;
      payable &#13;
      returns (bool)&#13;
    {&#13;
      uint tokenCount = msg.value / buyPrice;&#13;
      if (tokenCount &gt; tierBudget) {&#13;
        tokenCount = tierBudget;&#13;
      }&#13;
      &#13;
      uint investment = tokenCount * buyPrice;&#13;
&#13;
      balances[msg.sender] += tokenCount;&#13;
      Issuance(msg.sender, tokenCount);&#13;
      totalSupply += tokenCount;&#13;
      tierBudget -= tokenCount;&#13;
&#13;
      if (tierBudget &lt;= 0) {&#13;
        tierBudget = 100000;&#13;
        buyPrice *= 2;&#13;
        sellPrice *= 2;&#13;
      }&#13;
      if (msg.value &gt; investment) {&#13;
        msg.sender.transfer(msg.value - investment);&#13;
      }&#13;
      return true;&#13;
    }&#13;
&#13;
    function withdraw(uint tokenCount)&#13;
      public&#13;
      returns (bool)&#13;
    {&#13;
      if (balances[msg.sender] &gt;= tokenCount) {&#13;
        uint withdrawal = tokenCount * sellPrice;&#13;
        balances[msg.sender] -= tokenCount;&#13;
        totalSupply -= tokenCount;&#13;
        msg.sender.transfer(withdrawal);&#13;
        return true;&#13;
      } else {&#13;
        return false;&#13;
      }&#13;
    }&#13;
&#13;
    /// @dev Contract constructor function sets initial token balances.&#13;
    function PonziCoinRedux()&#13;
    {   &#13;
        // It's not a good scam unless it's pre-mined. No I'm not going to dump on you, don't worry. This isn't a scam (at least not entirely). If I feel like maintaining the website is too much I'll give the keys to someone else.&#13;
        balances[founder] = 200000;&#13;
        totalSupply += 200000;&#13;
    }&#13;
}