pragma solidity ^0.4.24;

// File: node_modules\zeppelin-solidity\contracts\math\SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}

// File: node_modules\zeppelin-solidity\contracts\crowdsale\Crowdsale.sol

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
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
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

// File: node_modules\zeppelin-solidity\contracts\ownership\Ownable.sol

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

// File: node_modules\zeppelin-solidity\contracts\crowdsale\validation\TimedCrowdsale.sol

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

// File: node_modules\zeppelin-solidity\contracts\crowdsale\distribution\FinalizableCrowdsale.sol

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

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

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
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\StandardToken.sol

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
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

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
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\MintableToken.sol

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
    hasMintPermission
    canMint
    public
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
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

// File: node_modules\zeppelin-solidity\contracts\crowdsale\emission\MintedCrowdsale.sol

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
    require(MintableToken(token).mint(_beneficiary, _tokenAmount));
  }
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\CappedToken.sol

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */
contract CappedToken is MintableToken {

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
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
    returns (bool)
  {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

// File: node_modules\zeppelin-solidity\contracts\math\Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

// File: node_modules\zeppelin-solidity\contracts\payment\Escrow.sol

/**
 * @title Escrow
 * @dev Base escrow contract, holds funds destinated to a payee until they
 * withdraw them. The contract that uses the escrow as its payment method
 * should be its owner, and provide public methods redirecting to the escrow's
 * deposit and withdraw.
 */
contract Escrow is Ownable {
  using SafeMath for uint256;

  event Deposited(address indexed payee, uint256 weiAmount);
  event Withdrawn(address indexed payee, uint256 weiAmount);

  mapping(address => uint256) private deposits;

  function depositsOf(address _payee) public view returns (uint256) {
    return deposits[_payee];
  }

  /**
  * @dev Stores the sent amount as credit to be withdrawn.
  * @param _payee The destination address of the funds.
  */
  function deposit(address _payee) public onlyOwner payable {
    uint256 amount = msg.value;
    deposits[_payee] = deposits[_payee].add(amount);

    emit Deposited(_payee, amount);
  }

  /**
  * @dev Withdraw accumulated balance for a payee.
  * @param _payee The address whose funds will be withdrawn and transferred to.
  */
  function withdraw(address _payee) public onlyOwner {
    uint256 payment = deposits[_payee];
    assert(address(this).balance >= payment);

    deposits[_payee] = 0;

    _payee.transfer(payment);

    emit Withdrawn(_payee, payment);
  }
}

// File: node_modules\zeppelin-solidity\contracts\payment\ConditionalEscrow.sol

/**
 * @title ConditionalEscrow
 * @dev Base abstract escrow to only allow withdrawal if a condition is met.
 */
contract ConditionalEscrow is Escrow {
  /**
  * @dev Returns whether an address is allowed to withdraw their funds. To be
  * implemented by derived contracts.
  * @param _payee The destination address of the funds.
  */
  function withdrawalAllowed(address _payee) public view returns (bool);

  function withdraw(address _payee) public {
    require(withdrawalAllowed(_payee));
    super.withdraw(_payee);
  }
}

// File: node_modules\zeppelin-solidity\contracts\payment\RefundEscrow.sol

/**
 * @title RefundEscrow
 * @dev Escrow that holds funds for a beneficiary, deposited from multiple parties.
 * The contract owner may close the deposit period, and allow for either withdrawal
 * by the beneficiary, or refunds to the depositors.
 */
contract RefundEscrow is Ownable, ConditionalEscrow {
  enum State { Active, Refunding, Closed }

  event Closed();
  event RefundsEnabled();

  State public state;
  address public beneficiary;

  /**
   * @dev Constructor.
   * @param _beneficiary The beneficiary of the deposits.
   */
  constructor(address _beneficiary) public {
    require(_beneficiary != address(0));
    beneficiary = _beneficiary;
    state = State.Active;
  }

  /**
   * @dev Stores funds that may later be refunded.
   * @param _refundee The address funds will be sent to if a refund occurs.
   */
  function deposit(address _refundee) public payable {
    require(state == State.Active);
    super.deposit(_refundee);
  }

  /**
   * @dev Allows for the beneficiary to withdraw their funds, rejecting
   * further deposits.
   */
  function close() public onlyOwner {
    require(state == State.Active);
    state = State.Closed;
    emit Closed();
  }

  /**
   * @dev Allows for refunds to take place, rejecting further deposits.
   */
  function enableRefunds() public onlyOwner {
    require(state == State.Active);
    state = State.Refunding;
    emit RefundsEnabled();
  }

  /**
   * @dev Withdraws the beneficiary's funds.
   */
  function beneficiaryWithdraw() public {
    require(state == State.Closed);
    beneficiary.transfer(address(this).balance);
  }

  /**
   * @dev Returns whether refundees can withdraw their deposits (be refunded).
   */
  function withdrawalAllowed(address _payee) public view returns (bool) {
    return state == State.Refunding;
  }
}

// File: contracts\ClinicAllRefundEscrow.sol

/**
 * @title ClinicAllRefundEscrow
 * @dev Escrow that holds funds for a beneficiary, deposited from multiple parties.
 * The contract owner may close the deposit period, and allow for either withdrawal
 * by the beneficiary, or refunds to the depositors.
 */
contract ClinicAllRefundEscrow is RefundEscrow {
  using Math for uint256;

  struct RefundeeRecord {
    bool isRefunded;
    uint256 index;
  }

  mapping(address => RefundeeRecord) public refundees;
  address[] internal refundeesList;

  /**
   * @dev Constructor.
   * @param _beneficiary The beneficiary of the deposits.
   */
  constructor(address _beneficiary)
  RefundEscrow(_beneficiary)
  public {
  }

  /**
   * @dev Stores funds that may later be refunded.
   * @param _refundee The address funds will be sent to if a refund occurs.
   */
  function deposit(address _refundee) public payable {
    require(state == State.Active, "Funds deposition is possible only in the Active state.");
    super.deposit(_refundee);

    RefundeeRecord storage _data = refundees[_refundee];
    _data.isRefunded = false;

    if (_data.index == uint256(0)) {
      refundeesList.push(_refundee);
      _data.index = refundeesList.length.sub(1);
    }
  }

  /**
  * @dev Allows for the beneficiary to withdraw their funds, rejecting
  * further deposits.
  */
  function close() public onlyOwner {
    super.close();
    super.beneficiaryWithdraw();
  }

  function withdraw(address _payee) public onlyOwner {
    require(state == State.Refunding, "Funds withdrawal is possible only in the Refunding state.");
    require(depositsOf(_payee) > 0, "An investor should have non-negative deposit for withdrawal.");

    RefundeeRecord storage _data = refundees[_payee];
    require(_data.isRefunded == false, "An investor should not be refunded.");
    super.withdraw(_payee);
    _data.isRefunded = true;

    removeRefundeeByIndex(_data.index);
  }

  /**
  * @dev Remove refundee referenced index from the internal list
  * @param _indexToDelete An index in an array for deletion
  */
  function removeRefundeeByIndex(uint256 _indexToDelete) private {
    if ((refundeesList.length > 0) && (_indexToDelete < refundeesList.length)) {
      uint256 _lastIndex = refundeesList.length.sub(1);
      refundeesList[_indexToDelete] = refundeesList[_lastIndex];
      refundeesList.length--;
    }
  }
  /**
  * @dev Get refundee list length
  */
  function refundeesListLength() public onlyOwner view returns (uint256) {
    return refundeesList.length;
  }

  /**
  * @dev Auto refund
  * @param _txFee The cost of executing refund code
  */
  function withdrawChunk(uint256 _txFee, uint256 _chunkLength) public onlyOwner returns (uint256, address[]) {
    require(state == State.Refunding, "Funds withdrawal is possible only in the Refunding state.");

    uint256 _refundeesCount = refundeesList.length;
    require(_chunkLength >= _refundeesCount);
    require(_txFee > 0, "Transaction fee should be above zero.");
    require(_refundeesCount > 0, "List of investors should not be empty.");
    uint256 _weiRefunded = 0;
    require(address(this).balance > (_chunkLength.mul(_txFee)), "Account's ballance should allow to pay all tx fees.");
    address[] memory _refundeesListCopy = new address[](_chunkLength);

    uint256 i;
    for (i = 0; i < _chunkLength; i++) {
      address _refundee = refundeesList[i];
      RefundeeRecord storage _data = refundees[_refundee];
      if (_data.isRefunded == false) {
        if (depositsOf(_refundee) > _txFee) {
          uint256 _deposit = depositsOf(_refundee);
          if (_deposit > _txFee) {
            _weiRefunded = _weiRefunded.add(_deposit);
            uint256 _paymentWithoutTxFee = _deposit.sub(_txFee);
            _refundee.transfer(_paymentWithoutTxFee);
            emit Withdrawn(_refundee, _paymentWithoutTxFee);
            _data.isRefunded = true;
            _refundeesListCopy[i] = _refundee;
          }
        }
      }
    }

    for (i = 0; i < _chunkLength; i++) {
      if (address(0) != _refundeesListCopy[i]) {
        RefundeeRecord storage _dataCleanup = refundees[_refundeesListCopy[i]];
        require(_dataCleanup.isRefunded == true, "Investors in this list should be refunded.");
        removeRefundeeByIndex(_dataCleanup.index);
      }
    }

    return (_weiRefunded, _refundeesListCopy);
  }

  /**
  * @dev Auto refund
  * @param _txFee The cost of executing refund code
  */
  function withdrawEverything(uint256 _txFee) public onlyOwner returns (uint256, address[]) {
    require(state == State.Refunding, "Funds withdrawal is possible only in the Refunding state.");
    return withdrawChunk(_txFee, refundeesList.length);
  }
}

// File: node_modules\zeppelin-solidity\contracts\lifecycle\TokenDestructible.sol

/**
 * @title TokenDestructible:
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="cdbfa8a0aea28dff">[email protected]</a>π.com&gt;&#13;
 * @dev Base contract that can be destroyed by owner. All funds in contract including&#13;
 * listed tokens will be sent to the owner.&#13;
 */&#13;
contract TokenDestructible is Ownable {&#13;
&#13;
  constructor() public payable { }&#13;
&#13;
  /**&#13;
   * @notice Terminate contract and refund to owner&#13;
   * @param tokens List of addresses of ERC20 or ERC20Basic token contracts to&#13;
   refund.&#13;
   * @notice The called token contracts could try to re-enter this contract. Only&#13;
   supply token contracts you trust.&#13;
   */&#13;
  function destroy(address[] tokens) onlyOwner public {&#13;
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
// File: node_modules\zeppelin-solidity\contracts\token\ERC20\BurnableToken.sol&#13;
&#13;
/**&#13;
 * @title Burnable Token&#13;
 * @dev Token that can be irreversibly burned (destroyed).&#13;
 */&#13;
contract BurnableToken is BasicToken {&#13;
&#13;
  event Burn(address indexed burner, uint256 value);&#13;
&#13;
  /**&#13;
   * @dev Burns a specific amount of tokens.&#13;
   * @param _value The amount of token to be burned.&#13;
   */&#13;
  function burn(uint256 _value) public {&#13;
    _burn(msg.sender, _value);&#13;
  }&#13;
&#13;
  function _burn(address _who, uint256 _value) internal {&#13;
    require(_value &lt;= balances[_who]);&#13;
    // no need to require value &lt;= totalSupply, since that would imply the&#13;
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure&#13;
&#13;
    balances[_who] = balances[_who].sub(_value);&#13;
    totalSupply_ = totalSupply_.sub(_value);&#13;
    emit Burn(_who, _value);&#13;
    emit Transfer(_who, address(0), _value);&#13;
  }&#13;
}&#13;
&#13;
// File: node_modules\zeppelin-solidity\contracts\token\ERC20\DetailedERC20.sol&#13;
&#13;
/**&#13;
 * @title DetailedERC20 token&#13;
 * @dev The decimals are only for visualization purposes.&#13;
 * All the operations are done using the smallest and indivisible token unit,&#13;
 * just as on Ethereum all the operations are done in wei.&#13;
 */&#13;
contract DetailedERC20 is ERC20 {&#13;
  string public name;&#13;
  string public symbol;&#13;
  uint8 public decimals;&#13;
&#13;
  constructor(string _name, string _symbol, uint8 _decimals) public {&#13;
    name = _name;&#13;
    symbol = _symbol;&#13;
    decimals = _decimals;&#13;
  }&#13;
}&#13;
&#13;
// File: node_modules\zeppelin-solidity\contracts\lifecycle\Pausable.sol&#13;
&#13;
/**&#13;
 * @title Pausable&#13;
 * @dev Base contract which allows children to implement an emergency stop mechanism.&#13;
 */&#13;
contract Pausable is Ownable {&#13;
  event Pause();&#13;
  event Unpause();&#13;
&#13;
  bool public paused = false;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is not paused.&#13;
   */&#13;
  modifier whenNotPaused() {&#13;
    require(!paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is paused.&#13;
   */&#13;
  modifier whenPaused() {&#13;
    require(paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to pause, triggers stopped state&#13;
   */&#13;
  function pause() onlyOwner whenNotPaused public {&#13;
    paused = true;&#13;
    emit Pause();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to unpause, returns to normal state&#13;
   */&#13;
  function unpause() onlyOwner whenPaused public {&#13;
    paused = false;&#13;
    emit Unpause();&#13;
  }&#13;
}&#13;
&#13;
// File: node_modules\zeppelin-solidity\contracts\token\ERC20\PausableToken.sol&#13;
&#13;
/**&#13;
 * @title Pausable token&#13;
 * @dev StandardToken modified with pausable transfers.&#13;
 **/&#13;
contract PausableToken is StandardToken, Pausable {&#13;
&#13;
  function transfer(&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool)&#13;
  {&#13;
    return super.transfer(_to, _value);&#13;
  }&#13;
&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool)&#13;
  {&#13;
    return super.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  function approve(&#13;
    address _spender,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool)&#13;
  {&#13;
    return super.approve(_spender, _value);&#13;
  }&#13;
&#13;
  function increaseApproval(&#13;
    address _spender,&#13;
    uint _addedValue&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool success)&#13;
  {&#13;
    return super.increaseApproval(_spender, _addedValue);&#13;
  }&#13;
&#13;
  function decreaseApproval(&#13;
    address _spender,&#13;
    uint _subtractedValue&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool success)&#13;
  {&#13;
    return super.decreaseApproval(_spender, _subtractedValue);&#13;
  }&#13;
}&#13;
&#13;
// File: contracts\ClinicAllToken.sol&#13;
&#13;
contract ClinicAllToken is MintableToken, DetailedERC20, CappedToken, PausableToken, BurnableToken, TokenDestructible {&#13;
  constructor&#13;
  (&#13;
    string _name,&#13;
    string _symbol,&#13;
    uint8 _decimals,&#13;
    uint256 _cap&#13;
  )&#13;
  DetailedERC20(_name, _symbol, _decimals)&#13;
  CappedToken(_cap)&#13;
  public&#13;
  {&#13;
&#13;
  }&#13;
&#13;
  /*/&#13;
  *  Refund event when ICO didn't pass soft cap and we refund ETH to investors + burn ERC-20 tokens from investors balances&#13;
  /*/&#13;
  function burnAfterRefund(address _who) public onlyOwner {&#13;
    uint256 _value = balances[_who];&#13;
    _burn(_who, _value);&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: node_modules\zeppelin-solidity\contracts\ownership\rbac\Roles.sol&#13;
&#13;
/**&#13;
 * @title Roles&#13;
 * @author Francisco Giordano (@frangio)&#13;
 * @dev Library for managing addresses assigned to a Role.&#13;
 * See RBAC.sol for example usage.&#13;
 */&#13;
library Roles {&#13;
  struct Role {&#13;
    mapping (address =&gt; bool) bearer;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev give an address access to this role&#13;
   */&#13;
  function add(Role storage role, address addr)&#13;
    internal&#13;
  {&#13;
    role.bearer[addr] = true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove an address' access to this role&#13;
   */&#13;
  function remove(Role storage role, address addr)&#13;
    internal&#13;
  {&#13;
    role.bearer[addr] = false;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev check if an address has this role&#13;
   * // reverts&#13;
   */&#13;
  function check(Role storage role, address addr)&#13;
    view&#13;
    internal&#13;
  {&#13;
    require(has(role, addr));&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev check if an address has this role&#13;
   * @return bool&#13;
   */&#13;
  function has(Role storage role, address addr)&#13;
    view&#13;
    internal&#13;
    returns (bool)&#13;
  {&#13;
    return role.bearer[addr];&#13;
  }&#13;
}&#13;
&#13;
// File: node_modules\zeppelin-solidity\contracts\ownership\rbac\RBAC.sol&#13;
&#13;
/**&#13;
 * @title RBAC (Role-Based Access Control)&#13;
 * @author Matt Condon (@Shrugs)&#13;
 * @dev Stores and provides setters and getters for roles and addresses.&#13;
 * Supports unlimited numbers of roles and addresses.&#13;
 * See //contracts/mocks/RBACMock.sol for an example of usage.&#13;
 * This RBAC method uses strings to key roles. It may be beneficial&#13;
 * for you to write your own implementation of this interface using Enums or similar.&#13;
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,&#13;
 * to avoid typos.&#13;
 */&#13;
contract RBAC {&#13;
  using Roles for Roles.Role;&#13;
&#13;
  mapping (string =&gt; Roles.Role) private roles;&#13;
&#13;
  event RoleAdded(address indexed operator, string role);&#13;
  event RoleRemoved(address indexed operator, string role);&#13;
&#13;
  /**&#13;
   * @dev reverts if addr does not have role&#13;
   * @param _operator address&#13;
   * @param _role the name of the role&#13;
   * // reverts&#13;
   */&#13;
  function checkRole(address _operator, string _role)&#13;
    view&#13;
    public&#13;
  {&#13;
    roles[_role].check(_operator);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev determine if addr has role&#13;
   * @param _operator address&#13;
   * @param _role the name of the role&#13;
   * @return bool&#13;
   */&#13;
  function hasRole(address _operator, string _role)&#13;
    view&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    return roles[_role].has(_operator);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev add a role to an address&#13;
   * @param _operator address&#13;
   * @param _role the name of the role&#13;
   */&#13;
  function addRole(address _operator, string _role)&#13;
    internal&#13;
  {&#13;
    roles[_role].add(_operator);&#13;
    emit RoleAdded(_operator, _role);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove a role from an address&#13;
   * @param _operator address&#13;
   * @param _role the name of the role&#13;
   */&#13;
  function removeRole(address _operator, string _role)&#13;
    internal&#13;
  {&#13;
    roles[_role].remove(_operator);&#13;
    emit RoleRemoved(_operator, _role);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev modifier to scope access to a single role (uses msg.sender as addr)&#13;
   * @param _role the name of the role&#13;
   * // reverts&#13;
   */&#13;
  modifier onlyRole(string _role)&#13;
  {&#13;
    checkRole(msg.sender, _role);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)&#13;
   * @param _roles the names of the roles to scope access to&#13;
   * // reverts&#13;
   *&#13;
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this&#13;
   *  see: https://github.com/ethereum/solidity/issues/2467&#13;
   */&#13;
  // modifier onlyRoles(string[] _roles) {&#13;
  //     bool hasAnyRole = false;&#13;
  //     for (uint8 i = 0; i &lt; _roles.length; i++) {&#13;
  //         if (hasRole(msg.sender, _roles[i])) {&#13;
  //             hasAnyRole = true;&#13;
  //             break;&#13;
  //         }&#13;
  //     }&#13;
&#13;
  //     require(hasAnyRole);&#13;
&#13;
  //     _;&#13;
  // }&#13;
}&#13;
&#13;
// File: contracts\Managed.sol&#13;
&#13;
/**&#13;
 * @title Managed&#13;
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.&#13;
 * This simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Managed is Ownable, RBAC {&#13;
  string public constant ROLE_MANAGER = "manager";&#13;
&#13;
  /**&#13;
  * @dev Throws if operator is not whitelisted.&#13;
  */&#13;
  modifier onlyManager() {&#13;
    checkRole(msg.sender, ROLE_MANAGER);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev set an address as a manager&#13;
  * @param _operator address&#13;
  * @return true if the address was added to the whitelist, false if the address was already in the whitelist&#13;
  */&#13;
  function setManager(address _operator) public onlyOwner {&#13;
    addRole(_operator, ROLE_MANAGER);&#13;
  }&#13;
}&#13;
&#13;
// File: contracts\Limited.sol&#13;
&#13;
/**&#13;
 * @title LimitedCrowdsale&#13;
 * @dev Crowdsale in which only limited number of tokens can be bought.&#13;
 */&#13;
contract Limited is Managed {&#13;
  using SafeMath for uint256;&#13;
  mapping(address =&gt; uint256) public limitsList;&#13;
&#13;
  /**&#13;
  * @dev Reverts if beneficiary has no limit. Can be used when extending this contract.&#13;
  */&#13;
  modifier isLimited(address _payee) {&#13;
    require(limitsList[_payee] &gt; 0, "An investor is limited if it has a limit.");&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
  * @dev Reverts if beneficiary want to buy more tickets than limit allows. Can be used when extending this contract.&#13;
  */&#13;
  modifier doesNotExceedLimit(address _payee, uint256 _tokenAmount, uint256 _tokenBalance) {&#13;
    require(_tokenBalance.add(_tokenAmount) &lt;= getLimit(_payee), "An investor should not exceed its limit on buying.");&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Returns limits for _payee.&#13;
  * @param _payee Address to get token limits&#13;
  */&#13;
  function getLimit(address _payee)&#13;
  public view returns (uint256)&#13;
  {&#13;
    return limitsList[_payee];&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds limits to addresses.&#13;
  * @param _payees Addresses to set limit&#13;
  * @param _limits Limit values to set to addresses&#13;
  */&#13;
  function addAddressesLimits(address[] _payees, uint256[] _limits) public&#13;
  onlyManager&#13;
  {&#13;
    require(_payees.length == _limits.length, "Array sizes should be equal.");&#13;
    for (uint256 i = 0; i &lt; _payees.length; i++) {&#13;
      addLimit(_payees[i], _limits[i]);&#13;
    }&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
  * @dev Adds limit to address.&#13;
  * @param _payee Address to set limit&#13;
  * @param _limit Limit value to set to address&#13;
  */&#13;
  function addLimit(address _payee, uint256 _limit) public&#13;
  onlyManager&#13;
  {&#13;
    limitsList[_payee] = _limit;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
  * @dev Removes single address-limit record.&#13;
  * @param _payee Address to be removed&#13;
  */&#13;
  function removeLimit(address _payee) external&#13;
  onlyManager&#13;
  {&#13;
    limitsList[_payee] = 0;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: node_modules\zeppelin-solidity\contracts\access\Whitelist.sol&#13;
&#13;
/**&#13;
 * @title Whitelist&#13;
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.&#13;
 * This simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Whitelist is Ownable, RBAC {&#13;
  string public constant ROLE_WHITELISTED = "whitelist";&#13;
&#13;
  /**&#13;
   * @dev Throws if operator is not whitelisted.&#13;
   * @param _operator address&#13;
   */&#13;
  modifier onlyIfWhitelisted(address _operator) {&#13;
    checkRole(_operator, ROLE_WHITELISTED);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev add an address to the whitelist&#13;
   * @param _operator address&#13;
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist&#13;
   */&#13;
  function addAddressToWhitelist(address _operator)&#13;
    onlyOwner&#13;
    public&#13;
  {&#13;
    addRole(_operator, ROLE_WHITELISTED);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev getter to determine if address is in whitelist&#13;
   */&#13;
  function whitelist(address _operator)&#13;
    public&#13;
    view&#13;
    returns (bool)&#13;
  {&#13;
    return hasRole(_operator, ROLE_WHITELISTED);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev add addresses to the whitelist&#13;
   * @param _operators addresses&#13;
   * @return true if at least one address was added to the whitelist,&#13;
   * false if all addresses were already in the whitelist&#13;
   */&#13;
  function addAddressesToWhitelist(address[] _operators)&#13;
    onlyOwner&#13;
    public&#13;
  {&#13;
    for (uint256 i = 0; i &lt; _operators.length; i++) {&#13;
      addAddressToWhitelist(_operators[i]);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove an address from the whitelist&#13;
   * @param _operator address&#13;
   * @return true if the address was removed from the whitelist,&#13;
   * false if the address wasn't in the whitelist in the first place&#13;
   */&#13;
  function removeAddressFromWhitelist(address _operator)&#13;
    onlyOwner&#13;
    public&#13;
  {&#13;
    removeRole(_operator, ROLE_WHITELISTED);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove addresses from the whitelist&#13;
   * @param _operators addresses&#13;
   * @return true if at least one address was removed from the whitelist,&#13;
   * false if all addresses weren't in the whitelist in the first place&#13;
   */&#13;
  function removeAddressesFromWhitelist(address[] _operators)&#13;
    onlyOwner&#13;
    public&#13;
  {&#13;
    for (uint256 i = 0; i &lt; _operators.length; i++) {&#13;
      removeAddressFromWhitelist(_operators[i]);&#13;
    }&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts\ManagedWhitelist.sol&#13;
&#13;
/**&#13;
 * @title ManagedWhitelist&#13;
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.&#13;
 * This simplifies the implementation of "user permissions".&#13;
 */&#13;
contract ManagedWhitelist is Managed, Whitelist {&#13;
  /**&#13;
  * @dev add an address to the whitelist&#13;
  * @param _operator address&#13;
  * @return true if the address was added to the whitelist, false if the address was already in the whitelist&#13;
  */&#13;
  function addAddressToWhitelist(address _operator) public onlyManager {&#13;
    addRole(_operator, ROLE_WHITELISTED);&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev add addresses to the whitelist&#13;
  * @param _operators addresses&#13;
  * @return true if at least one address was added to the whitelist,&#13;
  * false if all addresses were already in the whitelist&#13;
  */&#13;
  function addAddressesToWhitelist(address[] _operators) public onlyManager {&#13;
    for (uint256 i = 0; i &lt; _operators.length; i++) {&#13;
      addAddressToWhitelist(_operators[i]);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev remove an address from the whitelist&#13;
  * @param _operator address&#13;
  * @return true if the address was removed from the whitelist,&#13;
  * false if the address wasn't in the whitelist in the first place&#13;
  */&#13;
  function removeAddressFromWhitelist(address _operator) public onlyManager {&#13;
    removeRole(_operator, ROLE_WHITELISTED);&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev remove addresses from the whitelist&#13;
  * @param _operators addresses&#13;
  * @return true if at least one address was removed from the whitelist,&#13;
  * false if all addresses weren't in the whitelist in the first place&#13;
  */&#13;
  function removeAddressesFromWhitelist(address[] _operators) public onlyManager {&#13;
    for (uint256 i = 0; i &lt; _operators.length; i++) {&#13;
      removeAddressFromWhitelist(_operators[i]);&#13;
    }&#13;
  }&#13;
}&#13;
&#13;
// File: contracts\ClinicAllCrowdsale.sol&#13;
&#13;
/// @title ClinicAll crowdsale contract&#13;
/// @dev  ClinicAll crowdsale contract&#13;
contract ClinicAllCrowdsale is Crowdsale, FinalizableCrowdsale, MintedCrowdsale, ManagedWhitelist, Limited {&#13;
  constructor&#13;
  (&#13;
    uint256 _tokenLimitSupply,&#13;
    uint256 _rate,&#13;
    address _wallet,&#13;
    ERC20 _token,&#13;
    uint256 _openingTime,&#13;
    uint256 _closingTime,&#13;
    uint256 _discountTokenAmount,&#13;
    uint256 _discountTokenPercent,&#13;
    uint256 _privateSaleClosingTime,&#13;
    uint256 _softCapLimit,&#13;
    ClinicAllRefundEscrow _vault,&#13;
    uint256 _buyLimitSupplyMin,&#13;
    uint256 _buyLimitSupplyMax&#13;
  )&#13;
  Crowdsale(_rate, _wallet, _token)&#13;
  TimedCrowdsale(_openingTime, _closingTime)&#13;
  public&#13;
  {&#13;
    tokenSupplyLimit = _tokenLimitSupply;&#13;
    discountTokenAmount = _discountTokenAmount;&#13;
    discountTokenPercent = _discountTokenPercent;&#13;
    privateSaleClosingTime = _privateSaleClosingTime;&#13;
    softCapLimit = _softCapLimit;&#13;
    vault = _vault;&#13;
    buyLimitSupplyMin = _buyLimitSupplyMin;&#13;
    buyLimitSupplyMax = _buyLimitSupplyMax;&#13;
  }&#13;
&#13;
  using SafeMath for uint256;&#13;
&#13;
  // refund vault used to hold funds while crowdsale is running&#13;
  ClinicAllRefundEscrow public vault;&#13;
&#13;
  /*/&#13;
  *  Properties, constants&#13;
  /*/&#13;
  // Limit of tokens for supply during ICO public sale&#13;
  uint256 public tokenSupplyLimit;&#13;
  // Limit of tokens with discount on current contract&#13;
  uint256 public discountTokenAmount;&#13;
  // Percent value for discount tokens&#13;
  uint256 public discountTokenPercent;&#13;
  // Time when we finish private sale&#13;
  uint256 public privateSaleClosingTime;&#13;
  // Minimum amount of funds to be raised in weis&#13;
  uint256 public softCapLimit;&#13;
  // Min buy limit for each investor&#13;
  uint256 public buyLimitSupplyMin;&#13;
  // Max buy limit for each investor&#13;
  uint256 public buyLimitSupplyMax;&#13;
&#13;
  // Public functions&#13;
&#13;
  /*/&#13;
  *  @dev CrowdSale manager is able to change rate value during ICO&#13;
  *  @param _rate wei to CHT tokens exchange rate&#13;
  */&#13;
  function updateRate(uint256 _rate) public&#13;
  onlyManager&#13;
  {&#13;
    require(_rate != 0, "Exchange rate should not be 0.");&#13;
    rate = _rate;&#13;
  }&#13;
&#13;
  /*/&#13;
  *  @dev CrowdSale manager is able to change min and max buy limit for investors during ICO&#13;
  *  @param _min Minimal amount of tokens that could be bought&#13;
  *  @param _max Maximum amount of tokens that could be bought&#13;
  */&#13;
  function updateBuyLimitRange(uint256 _min, uint256 _max) public&#13;
  onlyOwner&#13;
  {&#13;
    require(_min != 0, "Minimal buy limit should not be 0.");&#13;
    require(_max != 0, "Maximal buy limit should not be 0.");&#13;
    require(_max &gt; _min, "Maximal buy limit should be greater than minimal buy limit.");&#13;
    buyLimitSupplyMin = _min;&#13;
    buyLimitSupplyMax = _max;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Investors can claim refunds here if crowdsale is unsuccessful&#13;
  */&#13;
  function claimRefund() public {&#13;
    require(isFinalized, "Claim refunds is only possible if the ICO is finalized.");&#13;
    require(!goalReached(), "Claim refunds is only possible if the soft cap goal has not been reached.");&#13;
    uint256 deposit = vault.depositsOf(msg.sender);&#13;
    vault.withdraw(msg.sender);&#13;
    weiRaised = weiRaised.sub(deposit);&#13;
    ClinicAllToken(token).burnAfterRefund(msg.sender);&#13;
  }&#13;
&#13;
  /**&#13;
  @dev Owner can claim full refund if a crowdsale is unsuccessful&#13;
  @param _txFee Transaction fee that will be deducted from an invested sum&#13;
  */&#13;
  function claimRefundChunk(uint256 _txFee, uint256 _chunkLength) public onlyOwner {&#13;
    require(isFinalized, "Claim refunds is only possible if the ICO is finalized.");&#13;
    require(!goalReached(), "Claim refunds is only possible if the soft cap goal has not been reached.");&#13;
    uint256 _weiRefunded;&#13;
    address[] memory _refundeesList;&#13;
    (_weiRefunded, _refundeesList) = vault.withdrawChunk(_txFee, _chunkLength);&#13;
    weiRaised = weiRaised.sub(_weiRefunded);&#13;
    for (uint256 i = 0; i &lt; _refundeesList.length; i++) {&#13;
      ClinicAllToken(token).burnAfterRefund(_refundeesList[i]);&#13;
    }&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
  * @dev Get refundee list length&#13;
  */&#13;
  function refundeesListLength() public onlyOwner view returns (uint256) {&#13;
    return vault.refundeesListLength();&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Checks whether the period in which the crowdsale is open has already elapsed.&#13;
  * @return Whether crowdsale period has elapsed&#13;
  */&#13;
  function hasClosed() public view returns (bool) {&#13;
    return ((block.timestamp &gt; closingTime) || tokenSupplyLimit &lt;= token.totalSupply());&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Checks whether funding goal was reached.&#13;
  * @return Whether funding goal was reached&#13;
  */&#13;
  function goalReached() public view returns (bool) {&#13;
    return token.totalSupply() &gt;= softCapLimit;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Checks rest of tokens supply.&#13;
  */&#13;
  function supplyRest() public view returns (uint256) {&#13;
    return (tokenSupplyLimit.sub(token.totalSupply()));&#13;
  }&#13;
&#13;
  //Private functions&#13;
&#13;
  function _processPurchase(&#13;
    address _beneficiary,&#13;
    uint256 _tokenAmount&#13;
  )&#13;
  internal&#13;
  doesNotExceedLimit(_beneficiary, _tokenAmount, token.balanceOf(_beneficiary))&#13;
  {&#13;
    super._processPurchase(_beneficiary, _tokenAmount);&#13;
  }&#13;
&#13;
  function _preValidatePurchase(&#13;
    address _beneficiary,&#13;
    uint256 _weiAmount&#13;
  )&#13;
  internal&#13;
  onlyIfWhitelisted(_beneficiary)&#13;
  isLimited(_beneficiary)&#13;
  {&#13;
    super._preValidatePurchase(_beneficiary, _weiAmount);&#13;
    uint256 tokens = _getTokenAmount(_weiAmount);&#13;
    require(tokens.add(token.totalSupply()) &lt;= tokenSupplyLimit, "Total amount fo sold tokens should not exceed the total supply limit.");&#13;
    require(tokens &gt;= buyLimitSupplyMin, "An investor can buy an amount of tokens only above the minimal limit.");&#13;
    require(tokens.add(token.balanceOf(_beneficiary)) &lt;= buyLimitSupplyMax, "An investor cannot buy tokens above the maximal limit.");&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Te way in which ether is converted to tokens.&#13;
   * @param _weiAmount Value in wei to be converted into tokens&#13;
   * @return Number of tokens that can be purchased with the specified _weiAmount with discount or not&#13;
   */&#13;
  function _getTokenAmount(uint256 _weiAmount)&#13;
  internal view returns (uint256)&#13;
  {&#13;
    if (isDiscount()) {&#13;
      return _getTokensWithDiscount(_weiAmount);&#13;
    }&#13;
    return _weiAmount.mul(rate);&#13;
  }&#13;
  /**&#13;
   * @dev Public method where ether is converted to tokens.&#13;
   * @param _weiAmount Value in wei to be converted into tokens&#13;
   */&#13;
  function getTokenAmount(uint256 _weiAmount)&#13;
  public view returns (uint256)&#13;
  {&#13;
    return _getTokenAmount(_weiAmount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev iternal method returns total tokens amount including discount&#13;
   */&#13;
  function _getTokensWithDiscount(uint256 _weiAmount)&#13;
  internal view returns (uint256)&#13;
  {&#13;
    uint256 tokens = 0;&#13;
    uint256 restOfDiscountTokens = discountTokenAmount.sub(token.totalSupply());&#13;
    uint256 discountTokensMax = _getDiscountTokenAmount(_weiAmount);&#13;
    if (restOfDiscountTokens &lt; discountTokensMax) {&#13;
      uint256 discountTokens = restOfDiscountTokens;&#13;
      //get rest of WEI&#13;
      uint256 _rate = _getDiscountRate();&#13;
      uint256 _discointWeiAmount = discountTokens.div(_rate);&#13;
      uint256 _restOfWeiAmount = _weiAmount.sub(_discointWeiAmount);&#13;
      uint256 normalTokens = _restOfWeiAmount.mul(rate);&#13;
      tokens = discountTokens.add(normalTokens);&#13;
    } else {&#13;
      tokens = discountTokensMax;&#13;
    }&#13;
&#13;
    return tokens;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev iternal method returns discount tokens amount&#13;
   * @param _weiAmount An amount of ETH that should be converted to an amount of CHT tokens&#13;
   */&#13;
  function _getDiscountTokenAmount(uint256 _weiAmount)&#13;
  internal view returns (uint256)&#13;
  {&#13;
    require(_weiAmount != 0, "It should be possible to buy tokens only by providing non zero ETH.");&#13;
    uint256 _rate = _getDiscountRate();&#13;
    return _weiAmount.mul(_rate);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Returns the discount rate value&#13;
   */&#13;
  function _getDiscountRate()&#13;
  internal view returns (uint256)&#13;
  {&#13;
    require(isDiscount(), "Getting discount rate should be possible only below the discount tokens limit.");&#13;
    return rate.add(rate.mul(discountTokenPercent).div(100));&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Returns the exchange rate value&#13;
   */&#13;
  function getRate()&#13;
  public view returns (uint256)&#13;
  {&#13;
    if (isDiscount()) {&#13;
      return _getDiscountRate();&#13;
    }&#13;
&#13;
    return rate;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Returns the status if the ICO's private sale has closed or not&#13;
   */&#13;
  function isDiscount()&#13;
  public view returns (bool)&#13;
  {&#13;
    return (privateSaleClosingTime &gt;= block.timestamp &amp;&amp; token.totalSupply() &lt; discountTokenAmount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Internal method where owner transfers part of tokens to reserve&#13;
   */&#13;
&#13;
  function transferTokensToReserve(address _beneficiary) private&#13;
  {&#13;
    require(tokenSupplyLimit &lt; CappedToken(token).cap(), "Token's supply limit should be less that token' cap limit.");&#13;
    // calculate token amount to be created&#13;
    uint256 _tokenCap = CappedToken(token).cap();&#13;
    uint256 tokens = _tokenCap.sub(tokenSupplyLimit);&#13;
&#13;
    _deliverTokens(_beneficiary, tokens);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Internal method where owner transfers part of tokens to reserve and finish minting&#13;
   */&#13;
  function finalization() internal {&#13;
    if (goalReached()) {&#13;
      transferTokensToReserve(wallet);&#13;
      vault.close();&#13;
    } else {&#13;
      vault.enableRefunds();&#13;
    }&#13;
    MintableToken(token).finishMinting();&#13;
    super.finalization();&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Overrides Crowdsale fund forwarding, sending funds to vault.&#13;
  */&#13;
  function _forwardFunds() internal {&#13;
    vault.deposit.value(msg.value)(msg.sender);&#13;
  }&#13;
}