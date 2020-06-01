pragma solidity ^0.4.18;

// ----------------------------------------------------------------------
// Based on code by OpenZeppelin
// ----------------------------------------------------------------------
// Copyright (c) 2016 Smart Contract Solutions, Inc.
// Released under the MIT license
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/LICENSE
// ----------------------------------------------------------------------


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

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
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
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override 
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */

contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  function Crowdsale(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statemens to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.transfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  /**
   * @dev Reverts if not in crowdsale time range. 
   */
  modifier onlyWhileOpen {
    require(now >= openingTime && now <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  function TimedCrowdsale(uint256 _openingTime, uint256 _closingTime) public {
    require(_openingTime >= now);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    return now > closingTime;
  }
  
  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhileOpen {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}


/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is TimedCrowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasClosed());

    finalization();
    Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value);
  }
}

contract TkoToken is MintableToken, BurnableToken, PausableToken {

    string public constant name = 'TkoToken';

    string public constant symbol = 'TKO';

    uint public constant decimals = 18;

}



/// @title Whitelist for TKO token sale.
/// @author Takeoff Technology OU - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6b02050d042b1f0a000e040d0d451c18">[email protected]</a>&gt;&#13;
/// @dev Based on code by OpenZeppelin's WhitelistedCrowdsale.sol&#13;
contract TkoWhitelist is Ownable{&#13;
&#13;
    using SafeMath for uint256;&#13;
&#13;
    // Manage whitelist account address.&#13;
    address public admin;&#13;
&#13;
    mapping(address =&gt; uint256) internal totalIndividualWeiAmount;&#13;
    mapping(address =&gt; bool) internal whitelist;&#13;
&#13;
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);&#13;
&#13;
&#13;
    /**&#13;
     * TkoWhitelist&#13;
     * @dev TkoWhitelist is the storage for whitelist and total amount by contributor's address.&#13;
     * @param _admin Address of managing whitelist.&#13;
     */&#13;
    function TkoWhitelist (address _admin) public {&#13;
        require(_admin != address(0));&#13;
        admin = _admin;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Throws if called by any account other than the owner or the admin.&#13;
     */&#13;
    modifier onlyOwnerOrAdmin() {&#13;
        require(msg.sender == owner || msg.sender == admin);&#13;
        _;&#13;
    }&#13;
&#13;
 /**&#13;
  * @dev Throws if called by any account other than the admin.&#13;
  */&#13;
 modifier onlyAdmin() {&#13;
   require(msg.sender == admin);&#13;
   _;&#13;
  }&#13;
&#13;
    /**&#13;
     * @dev Allows the current owner to change administrator account of the contract to a newAdmin.&#13;
     * @param newAdmin The address to transfer ownership to.&#13;
     */&#13;
    function changeAdmin(address newAdmin) public onlyOwner {&#13;
        AdminChanged(admin, newAdmin);&#13;
        admin = newAdmin;&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
      * @dev Returen whether the beneficiary is whitelisted.&#13;
      */&#13;
    function isWhitelisted(address _beneficiary) external view onlyOwnerOrAdmin returns (bool) {&#13;
        return whitelist[_beneficiary];&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Adds single address to whitelist.&#13;
     * @param _beneficiary Address to be added to the whitelist&#13;
     */&#13;
    function addToWhitelist(address _beneficiary) external onlyOwnerOrAdmin {&#13;
        whitelist[_beneficiary] = true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Adds list of addresses to whitelist.&#13;
     * @param _beneficiaries Addresses to be added to the whitelist&#13;
     */&#13;
    function addManyToWhitelist(address[] _beneficiaries) external onlyOwnerOrAdmin {&#13;
        for (uint256 i = 0; i &lt; _beneficiaries.length; i++) {&#13;
            whitelist[_beneficiaries[i]] = true;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Removes single address from whitelist.&#13;
     * @param _beneficiary Address to be removed to the whitelist&#13;
     */&#13;
    function removeFromWhitelist(address _beneficiary) external onlyOwnerOrAdmin {&#13;
        whitelist[_beneficiary] = false;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Return total individual wei amount.&#13;
     * @param _beneficiary Addresses to get total wei amount .&#13;
     * @return Total wei amount for the address.&#13;
     */&#13;
    function getTotalIndividualWeiAmount(address _beneficiary) external view onlyOwnerOrAdmin returns (uint256) {&#13;
        return totalIndividualWeiAmount[_beneficiary];&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Set total individual wei amount.&#13;
     * @param _beneficiary Addresses to set total wei amount.&#13;
     * @param _totalWeiAmount Total wei amount for the address.&#13;
     */&#13;
    function setTotalIndividualWeiAmount(address _beneficiary,uint256 _totalWeiAmount) external onlyOwner {&#13;
        totalIndividualWeiAmount[_beneficiary] = _totalWeiAmount;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Add total individual wei amount.&#13;
     * @param _beneficiary Addresses to add total wei amount.&#13;
     * @param _weiAmount Total wei amount to be added for the address.&#13;
     */&#13;
    function addTotalIndividualWeiAmount(address _beneficiary,uint256 _weiAmount) external onlyOwner {&#13;
        totalIndividualWeiAmount[_beneficiary] = totalIndividualWeiAmount[_beneficiary].add(_weiAmount);&#13;
    }&#13;
&#13;
}&#13;
&#13;
/// @title TKO Token presale contract.&#13;
/// @author Takeoff Technology OU - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6801060e07281c09030d070e0e461f1b">[email protected]</a>&gt;&#13;
contract TkoTokenPreSale is FinalizableCrowdsale, Pausable {&#13;
&#13;
    using SafeMath for uint256;&#13;
&#13;
    uint256 public initialRate;&#13;
    uint256 public finalRate;&#13;
&#13;
    uint256 public limitEther;&#13;
    uint256 public largeContribThreshold;&#13;
    uint256 public largeContribPercentage;&#13;
&#13;
    TkoWhitelist internal whitelist;&#13;
&#13;
    /**&#13;
     * TkoTokenPreSale&#13;
     * @dev TkoTokenPresale sells tokens at a set rate for the specified period.&#13;
     * Tokens that can be purchased per 1 Ether will decrease linearly over the period.&#13;
     * Bonus tokens are issued for large contributor at the rate specified.&#13;
     * If you wish to purchase above the specified amount, you need to be registered in the whitelist.&#13;
     * @param _openingTime Opening unix timestamp for TKO token pre-sale.&#13;
     * @param _closingTime Closing unix timestamp for TKO token pre-sale.&#13;
     * @param _initialRate Number of tokens issued at start (minimum unit) per 1wei.&#13;
     * @param _finalRate   Number of tokens issued at end (minimum unit) per 1wei.&#13;
     * @param _limitEther  Threshold value of purchase amount not required to register in whitelist (unit Ether).&#13;
     * @param _largeContribThreshold Threshold value of purchase amount in which bonus occurs (unit Ether)&#13;
     * @param _largeContribPercentage Percentage of added bonus&#13;
     * @param _wallet Wallet address to store Ether.&#13;
     * @param _token The address of the token to be sold in the pre-sale. TkoTokenPreSale must have ownership for mint.&#13;
     * @param _whitelist The address of the whitelist.&#13;
     */&#13;
    function TkoTokenPreSale (&#13;
        uint256 _openingTime,&#13;
        uint256 _closingTime,&#13;
        uint256 _initialRate,&#13;
        uint256 _finalRate,&#13;
        uint256 _limitEther,&#13;
        uint256 _largeContribThreshold,&#13;
        uint256 _largeContribPercentage,&#13;
        address _wallet,&#13;
        TkoToken _token,&#13;
        TkoWhitelist _whitelist&#13;
    )&#13;
    public&#13;
    Crowdsale(_initialRate, _wallet, _token)&#13;
    TimedCrowdsale(_openingTime, _closingTime)&#13;
    {&#13;
        initialRate = _initialRate;&#13;
        finalRate   = _finalRate;&#13;
&#13;
        limitEther = _limitEther;&#13;
        largeContribThreshold  = _largeContribThreshold;&#13;
        largeContribPercentage = _largeContribPercentage;&#13;
&#13;
        whitelist = _whitelist;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Extend parent behavior to confirm purchase amount and whitelist.&#13;
     * @param _beneficiary Token purchaser&#13;
     * @param _weiAmount Amount of wei contributed&#13;
     */&#13;
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhileOpen whenNotPaused {&#13;
&#13;
        uint256 limitWeiAmount = limitEther.mul(1 ether);&#13;
        require( whitelist.isWhitelisted(_beneficiary) ||&#13;
                    whitelist.getTotalIndividualWeiAmount(_beneficiary).add(_weiAmount) &lt; limitWeiAmount);&#13;
        super._preValidatePurchase(_beneficiary, _weiAmount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Returns the rate of tokens per wei at the present time.&#13;
     * Note that, as price _increases_ with time, the rate _decreases_.&#13;
     * @return The number of tokens a buyer gets per wei at a given time&#13;
     */&#13;
    function getCurrentRate() public view returns (uint256) {&#13;
        uint256 elapsedTime = now.sub(openingTime);&#13;
        uint256 timeRange = closingTime.sub(openingTime);&#13;
        uint256 rateRange = initialRate.sub(finalRate);&#13;
        return initialRate.sub(elapsedTime.mul(rateRange).div(timeRange));&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
     * @dev Overrides parent method taking into account variable rate and add bonus for large contributor.&#13;
     * @param _weiAmount The value in wei to be converted into tokens&#13;
     * @return The number of tokens _weiAmount wei will buy at present time&#13;
     */&#13;
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {&#13;
&#13;
        uint256 currentRate = getCurrentRate();&#13;
        uint256 tokenAmount = currentRate.mul(_weiAmount);&#13;
&#13;
        uint256 largeContribThresholdWeiAmount = largeContribThreshold.mul(1 ether);&#13;
        if ( _weiAmount &gt;= largeContribThresholdWeiAmount ) {&#13;
            tokenAmount = tokenAmount.mul(largeContribPercentage).div(100);&#13;
        }&#13;
&#13;
        return tokenAmount;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Add wei amount to the address's amount on the whitelist contract.&#13;
     * @param _beneficiary Address receiving the tokens&#13;
     * @param _weiAmount Value in wei involved in the purchase&#13;
     */&#13;
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {&#13;
        whitelist.addTotalIndividualWeiAmount(_beneficiary, _weiAmount);&#13;
        super._updatePurchasingState(_beneficiary, _weiAmount);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Overrides delivery by minting tokens upon purchase.&#13;
    * @param _beneficiary Token purchaser&#13;
    * @param _tokenAmount Number of tokens to be minted&#13;
    */&#13;
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal onlyWhileOpen whenNotPaused {&#13;
        // Don't call super._deliverTokens() to transfer token.&#13;
        // Following call will mint FOR _beneficiary, So need not to call transfer token .&#13;
        require(TkoToken(token).mint(_beneficiary, _tokenAmount));&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev called by the owner to pause, triggers stopped state&#13;
     */&#13;
    function pauseCrowdsale() public onlyOwner whenNotPaused {&#13;
        TkoToken(token).pause();&#13;
        super.pause();&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev called by the owner to unpause, returns to normal state&#13;
    */&#13;
    function unpauseCrowdsale() public onlyOwner whenPaused {&#13;
        TkoToken(token).unpause();&#13;
        super.unpause();&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev called by the owner to change owner of token and whitelist.&#13;
    */&#13;
    function evacuate() public onlyOwner {&#13;
        TkoToken(token).transferOwnership(wallet);&#13;
        whitelist.transferOwnership(wallet);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Can be overridden to add finalization logic. The overriding function&#13;
     * should call super.finalization() to ensure the chain of finalization is&#13;
     * executed entirely.&#13;
     */&#13;
    function finalization() internal {&#13;
        TkoToken(token).transferOwnership(wallet);&#13;
        whitelist.transferOwnership(wallet);&#13;
        super.finalization();&#13;
    }&#13;
&#13;
}