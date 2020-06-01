pragma solidity ^0.4.17;

/**
 * @title ERC20
 * @dev ERC20 interface
 */
contract ERC20 {
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/// @dev Crowdsale interface for Etheal Normal Sale, functions needed from outside.
contract iEthealSale {
    bool public paused;
    uint256 public minContribution;
    uint256 public whitelistThreshold;
    mapping (address => uint256) public stakes;
    function setPromoBonus(address _investor, uint256 _value) public;
    function buyTokens(address _beneficiary) public payable;
    function depositEth(address _beneficiary, uint256 _time, bytes _whitelistSign) public payable;
    function depositOffchain(address _beneficiary, uint256 _amount, uint256 _time) public;
    function hasEnded() public constant returns (bool);
}






/**
 * @title claim accidentally sent tokens
 */
contract HasNoTokens is Ownable {
    event ExtractedTokens(address indexed _token, address indexed _claimer, uint _amount);

    /// @notice This method can be used to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    /// @param _claimer Address that tokens will be send to
    function extractTokens(address _token, address _claimer) onlyOwner public {
        if (_token == 0x0) {
            _claimer.transfer(this.balance);
            return;
        }

        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(this);
        token.transfer(_claimer, balance);
        ExtractedTokens(_token, _claimer, balance);
    }
}





/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

/*
 * ERC-20 Standard Token Smart Contract Interface.
 * Copyright © 2016–2017 by ABDK Consulting.
 * Author: Mikhail Vladimirov <<span class="__cf_email__" data-cfemail="caa7a3a1a2aba3a6e4bca6abaea3a7a3b8a5bc8aada7aba3a6e4a9a5a7">[email protected]</span>&gt;&#13;
 */&#13;
&#13;
/**&#13;
 * ERC-20 standard token interface, as defined&#13;
 * &lt;a href="http://github.com/ethereum/EIPs/issues/20"&gt;here&lt;/a&gt;.&#13;
 */&#13;
contract Token {&#13;
    /**&#13;
     * Get total number of tokens in circulation.&#13;
     *&#13;
     * @return total number of tokens in circulation&#13;
     */&#13;
    function totalSupply () view returns (uint256 supply);&#13;
&#13;
    /**&#13;
     * Get number of tokens currently belonging to given owner.&#13;
     *&#13;
     * @param _owner address to get number of tokens currently belonging to the&#13;
     *        owner of&#13;
     * @return number of tokens currently belonging to the owner of given address&#13;
     */&#13;
    function balanceOf (address _owner) view returns (uint256 balance);&#13;
&#13;
    /**&#13;
     * Transfer given number of tokens from message sender to given recipient.&#13;
     *&#13;
     * @param _to address to transfer tokens to the owner of&#13;
     * @param _value number of tokens to transfer to the owner of given address&#13;
     * @return true if tokens were transferred successfully, false otherwise&#13;
     */&#13;
    function transfer (address _to, uint256 _value) returns (bool success);&#13;
&#13;
    /**&#13;
     * Transfer given number of tokens from given owner to given recipient.&#13;
     *&#13;
     * @param _from address to transfer tokens from the owner of&#13;
     * @param _to address to transfer tokens to the owner of&#13;
     * @param _value number of tokens to transfer from given owner to given&#13;
     *        recipient&#13;
     * @return true if tokens were transferred successfully, false otherwise&#13;
     */&#13;
    function transferFrom (address _from, address _to, uint256 _value) returns (bool success);&#13;
&#13;
    /**&#13;
     * Allow given spender to transfer given number of tokens from message sender.&#13;
     *&#13;
     * @param _spender address to allow the owner of to transfer tokens from&#13;
     *        message sender&#13;
     * @param _value number of tokens to allow to transfer&#13;
     * @return true if token transfer was successfully approved, false otherwise&#13;
     */&#13;
    function approve (address _spender, uint256 _value) returns (bool success);&#13;
&#13;
    /**&#13;
     * Tell how many tokens given spender is currently allowed to transfer from&#13;
     * given owner.&#13;
     *&#13;
     * @param _owner address to get number of tokens allowed to be transferred&#13;
     *        from the owner of&#13;
     * @param _spender address to get number of tokens allowed to be transferred&#13;
     *        by the owner of&#13;
     * @return number of tokens given spender is currently allowed to transfer&#13;
     *         from given owner&#13;
     */&#13;
    function allowance (address _owner, address _spender) view returns (uint256 remaining);&#13;
&#13;
    /**&#13;
     * Logged when tokens were transferred from one owner to another.&#13;
     *&#13;
     * @param _from address of the owner, tokens were transferred from&#13;
     * @param _to address of the owner, tokens were transferred to&#13;
     * @param _value number of tokens transferred&#13;
     */&#13;
    event Transfer (address indexed _from, address indexed _to, uint256 _value);&#13;
&#13;
    /**&#13;
     * Logged when owner approved his tokens to be transferred by some spender.&#13;
     *&#13;
     * @param _owner owner who approved his tokens to be transferred&#13;
     * @param _spender spender who were allowed to transfer the tokens belonging&#13;
     *        to the owner&#13;
     * @param _value number of tokens belonging to the owner, approved to be&#13;
     *        transferred by the spender&#13;
     */&#13;
    event Approval (address indexed _owner, address indexed _spender, uint256 _value);&#13;
}&#13;
&#13;
/*&#13;
 * Abstract Token Smart Contract.  Copyright © 2017 by ABDK Consulting.&#13;
 * Author: Mikhail Vladimirov &lt;<span class="__cf_email__" data-cfemail="64090d0f0c050d084a120805000d090d160b12240309050d084a070b09">[email protected]</span>&gt;&#13;
 * Modified to use SafeMath library by thesved&#13;
 */&#13;
/**&#13;
 * Abstract Token Smart Contract that could be used as a base contract for&#13;
 * ERC-20 token contracts.&#13;
 */&#13;
contract AbstractToken is Token {&#13;
    using SafeMath for uint;&#13;
&#13;
    /**&#13;
     * Create new Abstract Token contract.&#13;
     */&#13;
    function AbstractToken () {&#13;
        // Do nothing&#13;
    }&#13;
&#13;
    /**&#13;
     * Get number of tokens currently belonging to given owner.&#13;
     *&#13;
     * @param _owner address to get number of tokens currently belonging to the owner&#13;
     * @return number of tokens currently belonging to the owner of given address&#13;
     */&#13;
    function balanceOf (address _owner) view returns (uint256 balance) {&#13;
        return accounts[_owner];&#13;
    }&#13;
&#13;
    /**&#13;
     * Transfer given number of tokens from message sender to given recipient.&#13;
     *&#13;
     * @param _to address to transfer tokens to the owner of&#13;
     * @param _value number of tokens to transfer to the owner of given address&#13;
     * @return true if tokens were transferred successfully, false otherwise&#13;
     */&#13;
    function transfer (address _to, uint256 _value) returns (bool success) {&#13;
        uint256 fromBalance = accounts[msg.sender];&#13;
        if (fromBalance &lt; _value) return false;&#13;
        if (_value &gt; 0 &amp;&amp; msg.sender != _to) {&#13;
            accounts[msg.sender] = fromBalance.sub(_value);&#13;
            accounts[_to] = accounts[_to].add(_value);&#13;
            Transfer(msg.sender, _to, _value);&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Transfer given number of tokens from given owner to given recipient.&#13;
     *&#13;
     * @param _from address to transfer tokens from the owner of&#13;
     * @param _to address to transfer tokens to the owner of&#13;
     * @param _value number of tokens to transfer from given owner to given recipient&#13;
     * @return true if tokens were transferred successfully, false otherwise&#13;
     */&#13;
    function transferFrom (address _from, address _to, uint256 _value) returns (bool success) {&#13;
        uint256 spenderAllowance = allowances[_from][msg.sender];&#13;
        if (spenderAllowance &lt; _value) return false;&#13;
        uint256 fromBalance = accounts[_from];&#13;
        if (fromBalance &lt; _value) return false;&#13;
&#13;
        allowances[_from][msg.sender] = spenderAllowance.sub(_value);&#13;
&#13;
        if (_value &gt; 0 &amp;&amp; _from != _to) {&#13;
            accounts[_from] = fromBalance.sub(_value);&#13;
            accounts[_to] = accounts[_to].add(_value);&#13;
            Transfer(_from, _to, _value);&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Allow given spender to transfer given number of tokens from message sender.&#13;
     *&#13;
     * @param _spender address to allow the owner of to transfer tokens from&#13;
     *        message sender&#13;
     * @param _value number of tokens to allow to transfer&#13;
     * @return true if token transfer was successfully approved, false otherwise&#13;
     */&#13;
    function approve (address _spender, uint256 _value) returns (bool success) {&#13;
        allowances[msg.sender][_spender] = _value;&#13;
        Approval(msg.sender, _spender, _value);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Tell how many tokens given spender is currently allowed to transfer from&#13;
     * given owner.&#13;
     *&#13;
     * @param _owner address to get number of tokens allowed to be transferred from the owner&#13;
     * @param _spender address to get number of tokens allowed to be transferred by the owner&#13;
     * @return number of tokens given spender is currently allowed to transfer from given owner&#13;
     */&#13;
    function allowance (address _owner, address _spender) view returns (uint256 remaining) {&#13;
        return allowances[_owner][_spender];&#13;
    }&#13;
&#13;
    /**&#13;
     * Mapping from addresses of token holders to the numbers of tokens belonging&#13;
     * to these token holders.&#13;
     */&#13;
    mapping (address =&gt; uint256) accounts;&#13;
&#13;
    /**&#13;
     * Mapping from addresses of token holders to the mapping of addresses of&#13;
     * spenders to the allowances set by these token holders to these spenders.&#13;
     */&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) private allowances;&#13;
}&#13;
&#13;
&#13;
/*&#13;
 * Abstract Virtual Token Smart Contract.  Copyright © 2017 by ABDK Consulting.&#13;
 * Author: Mikhail Vladimirov &lt;<span class="__cf_email__" data-cfemail="274a4e4c4f464e4b09514b46434e4a4e55485167404a464e4b0944484a">[email protected]</span>&gt;&#13;
 * Modified to use SafeMath library by thesved&#13;
 */&#13;
&#13;
/**&#13;
 * Abstract Token Smart Contract that could be used as a base contract for&#13;
 * ERC-20 token contracts supporting virtual balance.&#13;
 */&#13;
contract AbstractVirtualToken is AbstractToken {&#13;
    using SafeMath for uint;&#13;
&#13;
    /**&#13;
     * Maximum number of real (i.e. non-virtual) tokens in circulation (2^255-1).&#13;
     */&#13;
    uint256 constant MAXIMUM_TOKENS_COUNT = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;&#13;
&#13;
    /**&#13;
     * Mask used to extract real balance of an account (2^255-1).&#13;
     */&#13;
    uint256 constant BALANCE_MASK = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;&#13;
&#13;
    /**&#13;
     * Mask used to extract "materialized" flag of an account (2^255).&#13;
     */&#13;
    uint256 constant MATERIALIZED_FLAG_MASK = 0x8000000000000000000000000000000000000000000000000000000000000000;&#13;
&#13;
    /**&#13;
     * Create new Abstract Virtual Token contract.&#13;
     */&#13;
    function AbstractVirtualToken () {&#13;
        // Do nothing&#13;
    }&#13;
&#13;
    /**&#13;
     * Get total number of tokens in circulation.&#13;
     *&#13;
     * @return total number of tokens in circulation&#13;
     */&#13;
    function totalSupply () view returns (uint256 supply) {&#13;
        return tokensCount;&#13;
    }&#13;
&#13;
    /**&#13;
     * Get number of tokens currently belonging to given owner.&#13;
     *&#13;
     * @param _owner address to get number of tokens currently belonging to the owner&#13;
     * @return number of tokens currently belonging to the owner of given address&#13;
    */&#13;
    function balanceOf (address _owner) constant returns (uint256 balance) { &#13;
        return (accounts[_owner] &amp; BALANCE_MASK).add(getVirtualBalance(_owner));&#13;
    }&#13;
&#13;
    /**&#13;
     * Transfer given number of tokens from message sender to given recipient.&#13;
     *&#13;
     * @param _to address to transfer tokens to the owner of&#13;
     * @param _value number of tokens to transfer to the owner of given address&#13;
     * @return true if tokens were transferred successfully, false otherwise&#13;
     */&#13;
    function transfer (address _to, uint256 _value) returns (bool success) {&#13;
        if (_value &gt; balanceOf(msg.sender)) return false;&#13;
        else {&#13;
            materializeBalanceIfNeeded(msg.sender, _value);&#13;
            return AbstractToken.transfer(_to, _value);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Transfer given number of tokens from given owner to given recipient.&#13;
     *&#13;
     * @param _from address to transfer tokens from the owner of&#13;
     * @param _to address to transfer tokens to the owner of&#13;
     * @param _value number of tokens to transfer from given owner to given&#13;
     *        recipient&#13;
     * @return true if tokens were transferred successfully, false otherwise&#13;
     */&#13;
    function transferFrom (address _from, address _to, uint256 _value) returns (bool success) {&#13;
        if (_value &gt; allowance(_from, msg.sender)) return false;&#13;
        if (_value &gt; balanceOf(_from)) return false;&#13;
        else {&#13;
            materializeBalanceIfNeeded(_from, _value);&#13;
            return AbstractToken.transferFrom(_from, _to, _value);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Get virtual balance of the owner of given address.&#13;
     *&#13;
     * @param _owner address to get virtual balance for the owner of&#13;
     * @return virtual balance of the owner of given address&#13;
     */&#13;
    function virtualBalanceOf (address _owner) internal view returns (uint256 _virtualBalance);&#13;
&#13;
    /**&#13;
     * Calculate virtual balance of the owner of given address taking into account&#13;
     * materialized flag and total number of real tokens already in circulation.&#13;
     */&#13;
    function getVirtualBalance (address _owner) private view returns (uint256 _virtualBalance) {&#13;
        if (accounts [_owner] &amp; MATERIALIZED_FLAG_MASK != 0) return 0;&#13;
        else {&#13;
            _virtualBalance = virtualBalanceOf(_owner);&#13;
            uint256 maxVirtualBalance = MAXIMUM_TOKENS_COUNT.sub(tokensCount);&#13;
            if (_virtualBalance &gt; maxVirtualBalance)&#13;
                _virtualBalance = maxVirtualBalance;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Materialize virtual balance of the owner of given address if this will help&#13;
     * to transfer given number of tokens from it.&#13;
     *&#13;
     * @param _owner address to materialize virtual balance of&#13;
     * @param _value number of tokens to be transferred&#13;
     */&#13;
    function materializeBalanceIfNeeded (address _owner, uint256 _value) private {&#13;
        uint256 storedBalance = accounts[_owner];&#13;
        if (storedBalance &amp; MATERIALIZED_FLAG_MASK == 0) {&#13;
            // Virtual balance is not materialized yet&#13;
            if (_value &gt; storedBalance) {&#13;
                // Real balance is not enough&#13;
                uint256 virtualBalance = getVirtualBalance(_owner);&#13;
                require (_value.sub(storedBalance) &lt;= virtualBalance);&#13;
                accounts[_owner] = MATERIALIZED_FLAG_MASK | storedBalance.add(virtualBalance);&#13;
                tokensCount = tokensCount.add(virtualBalance);&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * Number of real (i.e. non-virtual) tokens in circulation.&#13;
    */&#13;
    uint256 tokensCount;&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * Etheal Promo ERC-20 contract&#13;
 * Author: thesved&#13;
 */&#13;
contract EthealPromoToken is HasNoTokens, AbstractVirtualToken {&#13;
    // Balance threshold to assign virtual tokens to the owner of higher balances then this threshold.&#13;
    uint256 private constant VIRTUAL_THRESHOLD = 0.1 ether;&#13;
&#13;
    // Number of virtual tokens to assign to the owners of balances higher than virtual threshold.&#13;
    uint256 private constant VIRTUAL_COUNT = 911;&#13;
&#13;
    // crowdsale to set bonus when sending token&#13;
    iEthealSale public crowdsale;&#13;
&#13;
&#13;
    ////////////////&#13;
    // Basic functions&#13;
    ////////////////&#13;
&#13;
    /// @dev Constructor, crowdsale address can be 0x0&#13;
    function EthealPromoToken(address _crowdsale) {&#13;
        crowdsale = iEthealSale(_crowdsale);&#13;
    }&#13;
&#13;
    /// @dev Setting crowdsale, crowdsale address can be 0x0&#13;
    function setCrowdsale(address _crowdsale) public onlyOwner {&#13;
        crowdsale = iEthealSale(_crowdsale);&#13;
    }&#13;
&#13;
    /// @notice Get virtual balance of the owner of given address.&#13;
    /// @param _owner address to get virtual balance for the owner&#13;
    /// @return virtual balance of the owner of given address&#13;
    function virtualBalanceOf(address _owner) internal view returns (uint256) {&#13;
        return _owner.balance &gt;= VIRTUAL_THRESHOLD ? VIRTUAL_COUNT : 0;&#13;
    }&#13;
&#13;
    /// @notice Get name of this token.&#13;
    function name() public pure returns (string result) {&#13;
        return "An Etheal Promo";&#13;
    }&#13;
&#13;
    /// @notice Get symbol of this token.&#13;
    function symbol() public pure returns (string result) {&#13;
        return "HEALP";&#13;
    }&#13;
&#13;
    /// @notice Get number of decimals for this token.&#13;
    function decimals() public pure returns (uint8 result) {&#13;
        return 0;&#13;
    }&#13;
&#13;
&#13;
    ////////////////&#13;
    // Set sale bonus&#13;
    ////////////////&#13;
&#13;
    /// @dev Internal function for setting sale bonus&#13;
    function setSaleBonus(address _from, address _to, uint256 _value) internal {&#13;
        if (address(crowdsale) == address(0)) return;&#13;
        if (_value == 0) return;&#13;
&#13;
        if (_to == address(1) || _to == address(this) || _to == address(crowdsale)) {&#13;
            crowdsale.setPromoBonus(_from, _value);&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Override transfer function to set sale bonus&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        bool success = super.transfer(_to, _value); &#13;
&#13;
        if (success) {&#13;
            setSaleBonus(msg.sender, _to, _value);&#13;
        }&#13;
&#13;
        return success;&#13;
    }&#13;
&#13;
    /// @dev Override transfer function to set sale bonus&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        bool success = super.transferFrom(_from, _to, _value);&#13;
&#13;
        if (success) {&#13;
            setSaleBonus(_from, _to, _value);&#13;
        }&#13;
&#13;
        return success;&#13;
    }&#13;
&#13;
&#13;
    ////////////////&#13;
    // Extra&#13;
    ////////////////&#13;
&#13;
    /// @notice Notify owners about their virtual balances.&#13;
    function massNotify(address[] _owners) public onlyOwner {&#13;
        for (uint256 i = 0; i &lt; _owners.length; i++) {&#13;
            Transfer(address(0), _owners[i], VIRTUAL_COUNT);&#13;
        }&#13;
    }&#13;
&#13;
    /// @notice Kill this smart contract.&#13;
    function kill() public onlyOwner {&#13;
        selfdestruct(owner);&#13;
    }&#13;
&#13;
    &#13;
}