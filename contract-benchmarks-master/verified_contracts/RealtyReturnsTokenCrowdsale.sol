pragma solidity 0.4.24;

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

// File: zeppelin-solidity/contracts/crowdsale/Crowdsale.sol

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
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
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {
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
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method:
   *   super._preValidatePurchase(_beneficiary, _weiAmount);
   *   require(weiRaised.add(_weiAmount) <= cap);
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

// File: zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol

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
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  constructor(uint256 _openingTime, uint256 _closingTime) public {
    // solium-disable-next-line security/no-block-members
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

// File: zeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Ownable, TimedCrowdsale {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() public onlyOwner {
    require(!isFinalized);
    require(hasClosed());

    finalization();
    emit Finalized();

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

// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: zeppelin-solidity/contracts/token/ERC20/MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
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

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

// File: zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol

/**
 * @title MintedCrowdsale
 * @dev Extension of Crowdsale contract whose tokens are minted in each purchase.
 * Token ownership should be transferred to MintedCrowdsale for minting.
 */
contract MintedCrowdsale is Crowdsale {

  /**
   * @dev Overrides delivery by minting tokens upon purchase.
   * @param _beneficiary Token purchaser
   * @param _tokenAmount Number of tokens to be minted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    // Potentially dangerous assumption about the type of the token.
    require(MintableToken(address(token)).mint(_beneficiary, _tokenAmount));
  }
}

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

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
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

// File: contracts/RealtyReturnsTokenInterface.sol

contract RealtyReturnsTokenInterface {
    function paused() public;
    function unpause() public;
    function finishMinting() public returns (bool);
}

// File: zeppelin-solidity/contracts/token/ERC20/PausableToken.sol

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

// File: contracts/RealtyReturnsToken.sol

/**
 * @title Realty Coins contract - ERC20 compatible token contract.
 * @author Gustavo Guimaraes - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="95f2e0e6e1f4e3faf2e0fcf8f4e7f4f0e6d5f2f8f4fcf9bbf6faf8">[email protected]</a>&gt;&#13;
 */&#13;
contract RealtyReturnsToken is PausableToken, MintableToken {&#13;
    string public constant name = "Realty Returns Token";&#13;
    string public constant symbol = "RRT";&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    constructor() public {&#13;
        pause();&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/LockTokenAllocation.sol&#13;
&#13;
/**&#13;
 * @title LockTokenAllocation contract&#13;
 */&#13;
contract LockTokenAllocation is Ownable {&#13;
    using SafeMath for uint;&#13;
    uint256 public unlockedAt;&#13;
    uint256 public canSelfDestruct;&#13;
    uint256 public tokensCreated;&#13;
    uint256 public allocatedTokens;&#13;
    uint256 public totalLockTokenAllocation;&#13;
&#13;
    mapping (address =&gt; uint256) public lockedAllocations;&#13;
&#13;
    ERC20 public RR;&#13;
&#13;
    /**&#13;
     * @dev constructor function that sets token, totalLockTokenAllocation, unlock time, and selfdestruct timestamp&#13;
     * for the LockTokenAllocation contract&#13;
     */&#13;
    constructor&#13;
        (&#13;
            ERC20 _token,&#13;
            uint256 _unlockedAt,&#13;
            uint256 _canSelfDestruct,&#13;
            uint256 _totalLockTokenAllocation&#13;
        )&#13;
        public&#13;
    {&#13;
        require(_token != address(0));&#13;
&#13;
        RR = ERC20(_token);&#13;
        unlockedAt = _unlockedAt;&#13;
        canSelfDestruct = _canSelfDestruct;&#13;
        totalLockTokenAllocation = _totalLockTokenAllocation;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Adds founders' token allocation&#13;
     * @param beneficiary Ethereum address of a person&#13;
     * @param allocationValue Number of tokens allocated to person&#13;
     * @return true if address is correctly added&#13;
     */&#13;
    function addLockTokenAllocation(address beneficiary, uint256 allocationValue)&#13;
        external&#13;
        onlyOwner&#13;
        returns(bool)&#13;
    {&#13;
        require(lockedAllocations[beneficiary] == 0 &amp;&amp; beneficiary != address(0)); // can only add once.&#13;
&#13;
        allocatedTokens = allocatedTokens.add(allocationValue);&#13;
        require(allocatedTokens &lt;= totalLockTokenAllocation);&#13;
&#13;
        lockedAllocations[beneficiary] = allocationValue;&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
     * @dev Allow unlocking of allocated tokens by transferring them to whitelisted addresses.&#13;
     * Need to be called by each address&#13;
     */&#13;
    function unlock() external {&#13;
        require(RR != address(0));&#13;
        assert(now &gt;= unlockedAt);&#13;
&#13;
        // During first unlock attempt fetch total number of locked tokens.&#13;
        if (tokensCreated == 0) {&#13;
            tokensCreated = RR.balanceOf(this);&#13;
        }&#13;
&#13;
        uint256 transferAllocation = lockedAllocations[msg.sender];&#13;
        lockedAllocations[msg.sender] = 0;&#13;
&#13;
        // Will fail if allocation (and therefore toTransfer) is 0.&#13;
        require(RR.transfer(msg.sender, transferAllocation));&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev allow for selfdestruct possibility and sending funds to owner&#13;
     */&#13;
    function kill() public onlyOwner {&#13;
        require(now &gt;= canSelfDestruct);&#13;
        uint256 balance = RR.balanceOf(this);&#13;
&#13;
        if (balance &gt; 0) {&#13;
            RR.transfer(msg.sender, balance);&#13;
        }&#13;
&#13;
        selfdestruct(owner);&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/RealtyReturnsTokenCrowdsale.sol&#13;
&#13;
/**&#13;
 * @title Realty Returns Token Crowdsale Contract - crowdsale contract for Realty Returns (RR) tokens.&#13;
 * @author Gustavo Guimaraes - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="573022242336213830223e3a362536322417303a363e3b7934383a">[email protected]</a>&gt;&#13;
 */&#13;
&#13;
contract RealtyReturnsTokenCrowdsale is FinalizableCrowdsale, MintedCrowdsale, Pausable {&#13;
    uint256 constant public TRESURY_SHARE =              240000000e18;   // 240 M&#13;
    uint256 constant public TEAM_SHARE =                 120000000e18;   // 120 M&#13;
    uint256 constant public FOUNDERS_SHARE =             120000000e18;   // 120 M&#13;
    uint256 constant public NETWORK_SHARE =              530000000e18;   // 530 M&#13;
&#13;
    uint256 constant public TOTAL_TOKENS_FOR_CROWDSALE = 190000000e18;  // 190 M&#13;
    uint256 public crowdsaleSoftCap =  1321580e18; // approximately 1.3 M&#13;
&#13;
    address public treasuryWallet;&#13;
    address public teamShare;&#13;
    address public foundersShare;&#13;
    address public networkGrowth;&#13;
&#13;
    // remainderPurchaser and remainderTokens info saved in the contract&#13;
    // used for reference for contract owner to send refund if any to last purchaser after end of crowdsale&#13;
    address public remainderPurchaser;&#13;
    uint256 public remainderAmount;&#13;
&#13;
    address public onePercentAddress;&#13;
&#13;
    event MintedTokensFor(address indexed investor, uint256 tokensPurchased);&#13;
    event TokenRateChanged(uint256 previousRate, uint256 newRate);&#13;
&#13;
    /**&#13;
     * @dev Contract constructor function&#13;
     * @param _openingTime The timestamp of the beginning of the crowdsale&#13;
     * @param _closingTime Timestamp when the crowdsale will finish&#13;
     * @param _token REB token address&#13;
     * @param _rate The token rate per ETH&#13;
     * @param _wallet Multisig wallet that will hold the crowdsale funds.&#13;
     * @param _treasuryWallet Ethereum address where bounty tokens will be minted to&#13;
     * @param _onePercentAddress onePercent Ethereum address&#13;
     */&#13;
    constructor&#13;
        (&#13;
            uint256 _openingTime,&#13;
            uint256 _closingTime,&#13;
            RealtyReturnsToken _token,&#13;
            uint256 _rate,&#13;
            address _wallet,&#13;
            address _treasuryWallet,&#13;
            address _onePercentAddress&#13;
        )&#13;
        public&#13;
        FinalizableCrowdsale()&#13;
        Crowdsale(_rate, _wallet, _token)&#13;
        TimedCrowdsale(_openingTime, _closingTime)&#13;
    {&#13;
        require(_treasuryWallet != address(0));&#13;
        treasuryWallet = _treasuryWallet;&#13;
        onePercentAddress = _onePercentAddress;&#13;
&#13;
        // NOTE: Ensure token ownership is transferred to crowdsale so it is able to mint tokens&#13;
        require(RealtyReturnsToken(token).paused());&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev change crowdsale rate&#13;
     * @param newRate Figure that corresponds to the new rate per token&#13;
     */&#13;
    function setRate(uint256 newRate) external onlyOwner {&#13;
        require(newRate != 0);&#13;
&#13;
        emit TokenRateChanged(rate, newRate);&#13;
        rate = newRate;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev flexible soft cap&#13;
     * @param newCap Figure that corresponds to the new crowdsale soft cap&#13;
     */&#13;
    function setSoftCap(uint256 newCap) external onlyOwner {&#13;
        require(newCap != 0);&#13;
&#13;
        crowdsaleSoftCap = newCap;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Mint tokens investors that send fiat for token purchases.&#13;
     * The send of fiat will be off chain and custom minting happens in this function and it performed by the owner&#13;
     * @param beneficiaryAddress Address of beneficiary&#13;
     * @param amountOfTokens Number of tokens to be created&#13;
     */&#13;
    function mintTokensFor(address beneficiaryAddress, uint256 amountOfTokens)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        require(beneficiaryAddress != address(0));&#13;
        require(token.totalSupply().add(amountOfTokens) &lt;= TOTAL_TOKENS_FOR_CROWDSALE);&#13;
&#13;
        _deliverTokens(beneficiaryAddress, amountOfTokens);&#13;
        emit MintedTokensFor(beneficiaryAddress, amountOfTokens);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Set the address which should receive the vested team and founders tokens plus networkGrowth shares on finalization&#13;
     * @param _teamShare address of team and advisor allocation contract&#13;
     * @param _foundersShare address of team and advisor allocation contract&#13;
     * @param _networkGrowth address of networkGrowth contract&#13;
     */&#13;
    function setTokenDistributionAddresses&#13;
        (&#13;
            address _teamShare,&#13;
            address _foundersShare,&#13;
            address _networkGrowth&#13;
        )&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        // only able to be set once&#13;
        require(teamShare == address(0x0) &amp;&amp; foundersShare == address(0x0) &amp;&amp; networkGrowth == address(0x0));&#13;
        // ensure that the addresses as params to the func are not empty&#13;
        require(_teamShare != address(0x0) &amp;&amp; _foundersShare != address(0x0) &amp;&amp; _networkGrowth != address(0x0));&#13;
&#13;
        teamShare = _teamShare;&#13;
        foundersShare = _foundersShare;&#13;
        networkGrowth = _networkGrowth;&#13;
    }&#13;
&#13;
    // overriding TimeCrowdsale#hasClosed to add cap logic&#13;
    // @return true if crowdsale event has ended&#13;
    function hasClosed() public view returns (bool) {&#13;
        if (token.totalSupply() &gt; crowdsaleSoftCap) {&#13;
            return true;&#13;
        }&#13;
&#13;
        return super.hasClosed();&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Override validation of an incoming purchase.&#13;
     * Use require statemens to revert state when conditions are not met. Use super to concatenate validations.&#13;
     * @param _beneficiary Address performing the token purchase&#13;
     * @param _weiAmount Value in wei involved in the purchase&#13;
     */&#13;
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)&#13;
        internal&#13;
        whenNotPaused&#13;
    {&#13;
        require(_beneficiary != address(0));&#13;
        require(_weiAmount &gt;= 1 ether);&#13;
        require(token.totalSupply() &lt; TOTAL_TOKENS_FOR_CROWDSALE);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Override to extend the way in which ether is converted to tokens.&#13;
     * @param _weiAmount Value in wei to be converted into tokens&#13;
     * @return Number of tokens that can be purchased with the specified _weiAmount&#13;
     */&#13;
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {&#13;
        uint256 tokensAmount = _weiAmount.mul(rate);&#13;
&#13;
        // remainder logic&#13;
        if (token.totalSupply().add(tokensAmount) &gt; TOTAL_TOKENS_FOR_CROWDSALE) {&#13;
            tokensAmount = TOTAL_TOKENS_FOR_CROWDSALE.sub(token.totalSupply());&#13;
            uint256 _weiAmountLocalScope = tokensAmount.div(rate);&#13;
&#13;
            // save info so as to refund purchaser after crowdsale's end&#13;
            remainderPurchaser = msg.sender;&#13;
            remainderAmount = _weiAmount.sub(_weiAmountLocalScope);&#13;
&#13;
            // update state here so when it is updated again in buyTokens the weiAmount reflects the remainder logic&#13;
            if (weiRaised &gt; _weiAmount.add(_weiAmountLocalScope))&#13;
                weiRaised = weiRaised.sub(_weiAmount.add(_weiAmountLocalScope));&#13;
        }&#13;
&#13;
        return tokensAmount;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Determines how ETH is stored/forwarded on purchases.&#13;
    */&#13;
    function _forwardFunds() internal {&#13;
        // 1% of the purchase to save in different wallet&#13;
        uint256 onePercentValue = msg.value.div(100);&#13;
        uint256 valueToTransfer = msg.value.sub(onePercentValue);&#13;
&#13;
        onePercentAddress.transfer(onePercentValue);&#13;
        wallet.transfer(valueToTransfer);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev finalizes crowdsale&#13;
     */&#13;
    function finalization() internal {&#13;
        // This must have been set manually prior to finalize().&#13;
        require(teamShare != address(0) &amp;&amp; foundersShare != address(0) &amp;&amp; networkGrowth != address(0));&#13;
&#13;
        if (TOTAL_TOKENS_FOR_CROWDSALE &gt; token.totalSupply()) {&#13;
            uint256 remainingTokens = TOTAL_TOKENS_FOR_CROWDSALE.sub(token.totalSupply());&#13;
            _deliverTokens(wallet, remainingTokens);&#13;
        }&#13;
&#13;
        // final minting&#13;
        _deliverTokens(treasuryWallet, TRESURY_SHARE);&#13;
        _deliverTokens(teamShare, TEAM_SHARE);&#13;
        _deliverTokens(foundersShare, FOUNDERS_SHARE);&#13;
        _deliverTokens(networkGrowth, NETWORK_SHARE);&#13;
&#13;
        RealtyReturnsToken(token).finishMinting();&#13;
        RealtyReturnsToken(token).unpause();&#13;
        super.finalization();&#13;
    }&#13;
}