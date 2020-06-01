pragma solidity ^0.4.16;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

/** 
 * @title TokenDestructible:
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="fd8f98909e92bdcf">[email protected]</a>π.com&gt;&#13;
 * @dev Base contract that can be destroyed by owner. All funds in contract including&#13;
 * listed tokens will be sent to the owner.&#13;
 */&#13;
contract TokenDestructible is Ownable {&#13;
&#13;
  function TokenDestructible() payable { } &#13;
&#13;
  /** &#13;
   * @notice Terminate contract and refund to owner&#13;
   * @param tokens List of addresses of ERC20 or ERC20Basic token contracts to&#13;
   refund.&#13;
   * @notice The called token contracts could try to re-enter this contract. Only&#13;
   supply token contracts you trust.&#13;
   */&#13;
  function destroy(address[] tokens) onlyOwner {&#13;
&#13;
    // Transfer tokens to owner&#13;
    for (uint256 i = 0; i &lt; tokens.length; i++) {&#13;
      ERC20Basic token = ERC20Basic(tokens[i]);&#13;
      uint256 balance = token.balanceOf(this);&#13;
      token.transfer(owner, balance);&#13;
    }&#13;
&#13;
    // Transfer Eth to owner and terminate contract&#13;
    selfdestruct(owner);&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title StopIcoCoin token&#13;
 * @dev Simple ERC20 Token example, with mintable token creation&#13;
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120&#13;
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol&#13;
 */&#13;
&#13;
contract StopIcoCoin is StandardToken, Ownable, TokenDestructible {&#13;
&#13;
  string public name = "StopIco";&#13;
  uint8 public decimals = 18;&#13;
  string public symbol = "Stop";&#13;
  string public version = "0.1";&#13;
&#13;
  event Mint(address indexed to, uint256 amount);&#13;
  event MintFinished();&#13;
&#13;
  bool public mintingFinished = false;&#13;
&#13;
  modifier canMint() {&#13;
    require(!mintingFinished);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to mint tokens&#13;
   * @param _to The address that will recieve the minted tokens.&#13;
   * @param _amount The amount of tokens to mint.&#13;
   * @return A boolean that indicates if the operation was successful.&#13;
   */&#13;
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {&#13;
    totalSupply = totalSupply.add(_amount);&#13;
    balances[_to] = balances[_to].add(_amount);&#13;
    Mint(_to, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to stop minting new tokens.&#13;
   * @return True if the operation was successful.&#13;
   */&#13;
  function finishMinting() onlyOwner returns (bool) {&#13;
    mintingFinished = true;&#13;
    MintFinished();&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Crowdsale &#13;
 * @dev Crowdsale is a base contract for managing a token crowdsale.&#13;
 * Crowdsales have a start and end block, where investors can make&#13;
 * token purchases and the crowdsale will assign them tokens based&#13;
 * on a token per ETH rate. Funds collected are forwarded to a wallet &#13;
 * as they arrive.&#13;
 */&#13;
contract StopIcoDonation is Ownable, Pausable, TokenDestructible {&#13;
  using SafeMath for uint256;&#13;
&#13;
  // The token being sold&#13;
  StopIcoCoin public token;&#13;
&#13;
  // start and end dates where donation are allowed (both inclusive)&#13;
    uint256 constant public START = 151340000000; //Start Date(2017, 11, 16) &#13;
  uint256 constant public END = 1517500000; // end date (2017, 12, 21)&#13;
&#13;
  // address where funds are collected&#13;
  address public wallet = 0x5fa4Fc122aB7d6d20A3E07d6Df507C9288f293dC;&#13;
  &#13;
&#13;
  // amount of raised money in wei&#13;
  uint256 public weiRaised;&#13;
&#13;
&#13;
&#13;
  /**&#13;
   * event for token purchase logging&#13;
   * @param purchaser who paid for the tokens&#13;
   * @param beneficiary who got the tokens&#13;
   * @param value weis paid for purchase&#13;
   * @param amount amount of tokens purchased&#13;
   */ &#13;
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);&#13;
  event BountyDistributed(address indexed bountyAddress, uint256 amount);&#13;
&#13;
  function StopIcoDonation() payable {&#13;
    token = new StopIcoCoin();&#13;
  }&#13;
&#13;
  // function to get the price of the token&#13;
  // returns how many token units a buyer gets per wei, needs to be divided by 10&#13;
  function getRate() constant returns (uint8) {&#13;
    if      (now &lt; START)            return 166;&#13;
    else if (now &lt;= START +  6 days) return 162; // day 1 to 6, 35% bonus&#13;
    else if (now &lt;= START + 13 days) return 156; // day 7 to 13, 30% bonus&#13;
    else if (now &lt;= START + 20 days) return 150; // day 14 to 20, 25% bonus&#13;
    else if (now &lt;= START + 27 days) return 144; // day 21 to 27, 20% bonus&#13;
    else if (now &lt;= START + 35 days) return 138; // day 28 to 35, 15% bonus&#13;
    &#13;
   &#13;
    return 120; // no bonus&#13;
  }&#13;
&#13;
  // fallback function can be used to buy tokens&#13;
  function () payable {&#13;
    buyTokens(msg.sender);&#13;
  }&#13;
&#13;
  // low level token purchase function&#13;
  function buyTokens(address beneficiary) whenNotPaused() payable {&#13;
    require(beneficiary != 0x0);&#13;
    require(msg.value != 0);&#13;
    require(now &lt;= END);&#13;
&#13;
    uint256 weiAmount = msg.value;&#13;
&#13;
    // calculate token amount to be minted&#13;
    uint256 tokens = weiAmount.mul(getRate()).div(10);&#13;
    &#13;
    // update state&#13;
    weiRaised = weiRaised.add(weiAmount);&#13;
&#13;
    token.mint(beneficiary, tokens);&#13;
&#13;
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);&#13;
&#13;
    wallet.transfer(msg.value);&#13;
  }&#13;
&#13;
&#13;
  }