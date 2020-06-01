pragma solidity ^0.4.24;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {

  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    // safeApprove should only be called when setting an initial allowance, 
    // or when resetting it to zero. To increase and decrease it, use 
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }
}

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8af8efe7e9e5cab8">[email protected]</a>π.com&gt;, Eenae &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1978757c617c60597470617b606d7c6a377076">[email protected]</a>&gt;&#13;
 * @dev If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /// @dev counter to allow mutex lock with only one SSTORE operation&#13;
  uint256 private _guardCounter;&#13;
&#13;
  constructor() internal {&#13;
    // The counter starts at one to prevent changing it from zero to a non-zero&#13;
    // value, which is a more expensive operation.&#13;
    _guardCounter = 1;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * Calling a `nonReentrant` function from another `nonReentrant`&#13;
   * function is not supported. It is possible to prevent this from happening&#13;
   * by making the `nonReentrant` function external, and make it call a&#13;
   * `private` function that does the actual work.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    _guardCounter += 1;&#13;
    uint256 localCounter = _guardCounter;&#13;
    _;&#13;
    require(localCounter == _guardCounter);&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 * modifed to set specific owner&#13;
 */&#13;
contract Ownable {&#13;
  address internal _owner;&#13;
&#13;
  event OwnershipTransferred(&#13;
    address indexed previousOwner,&#13;
    address indexed newOwner&#13;
  );&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  constructor() internal {&#13;
    _owner = msg.sender;&#13;
    emit OwnershipTransferred(address(0), _owner);&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the address of the owner.&#13;
   */&#13;
  function owner() public view returns(address) {&#13;
    return _owner;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(isOwner());&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return true if `msg.sender` is the owner of the contract.&#13;
   */&#13;
  function isOwner() public view returns(bool) {&#13;
    return msg.sender == _owner;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) public onlyOwner {&#13;
    _transferOwnership(newOwner);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfers control of the contract to a newOwner.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function _transferOwnership(address newOwner) internal {&#13;
    require(newOwner != address(0));&#13;
    emit OwnershipTransferred(_owner, newOwner);&#13;
    _owner = newOwner;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Crowdsale&#13;
 * @dev Crowdsale is a base contract for managing a token crowdsale,&#13;
 * allowing investors to purchase tokens with ether. This contract implements&#13;
 * such functionality in its most fundamental form and can be extended to provide additional&#13;
 * functionality and/or custom behavior.&#13;
 * The external interface represents the basic interface for purchasing tokens, and conform&#13;
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.&#13;
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override&#13;
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate&#13;
 * behavior.&#13;
 */&#13;
contract Crowdsale is ReentrancyGuard {&#13;
  using SafeMath for uint256;&#13;
  using SafeERC20 for IERC20;&#13;
&#13;
  // The token being sold&#13;
  IERC20 private _token;&#13;
&#13;
  // Address where funds are collected&#13;
  address private _wallet;&#13;
&#13;
  // How many token units a buyer gets per wei.&#13;
  // The rate is the conversion between wei and the smallest and indivisible token unit.&#13;
  // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK&#13;
  // 1 wei will give you 1 unit, or 0.001 TOK.&#13;
  uint256 private _rate;&#13;
&#13;
  // Amount of wei raised&#13;
  uint256 private _weiRaised;&#13;
&#13;
  /**&#13;
   * Event for token purchase logging&#13;
   * @param purchaser who paid for the tokens&#13;
   * @param beneficiary who got the tokens&#13;
   * @param value weis paid for purchase&#13;
   * @param amount amount of tokens purchased&#13;
   */&#13;
  event TokensPurchased(&#13;
    address indexed purchaser,&#13;
    address indexed beneficiary,&#13;
    uint256 value,&#13;
    uint256 amount&#13;
  );&#13;
&#13;
  /**&#13;
   * @param rate Number of token units a buyer gets per wei&#13;
   * @dev The rate is the conversion between wei and the smallest and indivisible&#13;
   * token unit. So, if you are using a rate of 1 with a ERC20Detailed token&#13;
   * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.&#13;
   * @param wallet Address where collected funds will be forwarded to&#13;
   * @param token Address of the token being sold&#13;
   */&#13;
  constructor(uint256 rate, address wallet, IERC20 token) internal {&#13;
    require(rate &gt; 0);&#13;
    require(wallet != address(0));&#13;
    require(token != address(0));&#13;
&#13;
    _rate = rate;&#13;
    _wallet = wallet;&#13;
    _token = token;&#13;
  }&#13;
&#13;
  // -----------------------------------------&#13;
  // Crowdsale external interface&#13;
  // -----------------------------------------&#13;
&#13;
  /**&#13;
   * @dev fallback function ***DO NOT OVERRIDE***&#13;
   * Note that other contracts will transfer fund with a base gas stipend&#13;
   * of 2300, which is not enough to call buyTokens. Consider calling&#13;
   * buyTokens directly when purchasing tokens from a contract.&#13;
   */&#13;
  function () external payable {&#13;
    buyTokens(msg.sender);&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the token being sold.&#13;
   */&#13;
  function token() public view returns(IERC20) {&#13;
    return _token;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the address where funds are collected.&#13;
   */&#13;
  function wallet() public view returns(address) {&#13;
    return _wallet;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the number of token units a buyer gets per wei.&#13;
   */&#13;
  function rate() public view returns(uint256) {&#13;
    return _rate;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the amount of wei raised.&#13;
   */&#13;
  function weiRaised() public view returns (uint256) {&#13;
    return _weiRaised;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev low level token purchase ***DO NOT OVERRIDE***&#13;
   * This function has a non-reentrancy guard, so it shouldn't be called by&#13;
   * another `nonReentrant` function.&#13;
   * @param beneficiary Recipient of the token purchase&#13;
   */&#13;
  function buyTokens(address beneficiary) public nonReentrant payable {&#13;
&#13;
    uint256 weiAmount = msg.value;&#13;
    _preValidatePurchase(beneficiary, weiAmount);&#13;
&#13;
    // calculate token amount to be created&#13;
    uint256 tokens = _getTokenAmount(weiAmount);&#13;
&#13;
    // update state&#13;
    _weiRaised = _weiRaised.add(weiAmount);&#13;
&#13;
    _processPurchase(beneficiary, tokens);&#13;
    emit TokensPurchased(&#13;
      msg.sender,&#13;
      beneficiary,&#13;
      weiAmount,&#13;
      tokens&#13;
    );&#13;
&#13;
    _updatePurchasingState(beneficiary, weiAmount);&#13;
&#13;
    _forwardFunds();&#13;
    _postValidatePurchase(beneficiary, weiAmount);&#13;
  }&#13;
&#13;
  // -----------------------------------------&#13;
  // Internal interface (extensible)&#13;
  // -----------------------------------------&#13;
&#13;
  /**&#13;
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.&#13;
   * Example from CappedCrowdsale.sol's _preValidatePurchase method:&#13;
   *   super._preValidatePurchase(beneficiary, weiAmount);&#13;
   *   require(weiRaised().add(weiAmount) &lt;= cap);&#13;
   * @param beneficiary Address performing the token purchase&#13;
   * @param weiAmount Value in wei involved in the purchase&#13;
   */&#13;
  function _preValidatePurchase(&#13;
    address beneficiary,&#13;
    uint256 weiAmount&#13;
  )&#13;
    internal&#13;
    view&#13;
  {&#13;
    require(beneficiary != address(0));&#13;
    require(weiAmount != 0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.&#13;
   * @param beneficiary Address performing the token purchase&#13;
   * @param weiAmount Value in wei involved in the purchase&#13;
   */&#13;
  function _postValidatePurchase(&#13;
    address beneficiary,&#13;
    uint256 weiAmount&#13;
  )&#13;
    internal&#13;
    view&#13;
  {&#13;
    // optional override&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.&#13;
   * @param beneficiary Address performing the token purchase&#13;
   * @param tokenAmount Number of tokens to be emitted&#13;
   */&#13;
  function _deliverTokens(&#13;
    address beneficiary,&#13;
    uint256 tokenAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    _token.safeTransfer(beneficiary, tokenAmount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send tokens.&#13;
   * @param beneficiary Address receiving the tokens&#13;
   * @param tokenAmount Number of tokens to be purchased&#13;
   */&#13;
  function _processPurchase(&#13;
    address beneficiary,&#13;
    uint256 tokenAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    _deliverTokens(beneficiary, tokenAmount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)&#13;
   * @param beneficiary Address receiving the tokens&#13;
   * @param weiAmount Value in wei involved in the purchase&#13;
   */&#13;
  function _updatePurchasingState(&#13;
    address beneficiary,&#13;
    uint256 weiAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    // optional override&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Override to extend the way in which ether is converted to tokens.&#13;
   * @param weiAmount Value in wei to be converted into tokens&#13;
   * @return Number of tokens that can be purchased with the specified _weiAmount&#13;
   */&#13;
  function _getTokenAmount(uint256 weiAmount)&#13;
    internal view returns (uint256)&#13;
  {&#13;
    return weiAmount.mul(_rate);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Determines how ETH is stored/forwarded on purchases.&#13;
   */&#13;
  function _forwardFunds() internal {&#13;
    _wallet.transfer(msg.value);&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title AllowanceCrowdsale&#13;
 * @dev Extension of Crowdsale where tokens are held by a wallet, which approves an allowance to the crowdsale.&#13;
 */&#13;
contract AllowanceCrowdsale is Crowdsale {&#13;
  using SafeMath for uint256;&#13;
  using SafeERC20 for IERC20;&#13;
&#13;
  address private _tokenWallet;&#13;
&#13;
  /**&#13;
   * @dev Constructor, takes token wallet address.&#13;
   * @param tokenWallet Address holding the tokens, which has approved allowance to the crowdsale&#13;
   */&#13;
  constructor(address tokenWallet) public {&#13;
    require(tokenWallet != address(0));&#13;
    _tokenWallet = tokenWallet;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the address of the wallet that will hold the tokens.&#13;
   */&#13;
  function tokenWallet() public view returns(address) {&#13;
    return _tokenWallet;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Checks the amount of tokens left in the allowance.&#13;
   * @return Amount of tokens left in the allowance&#13;
   */&#13;
  function remainingTokens() public view returns (uint256) {&#13;
    return token().allowance(_tokenWallet, this);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Overrides parent behavior by transferring tokens from wallet.&#13;
   * @param beneficiary Token purchaser&#13;
   * @param tokenAmount Amount of tokens purchased&#13;
   */&#13;
  function _deliverTokens(&#13;
    address beneficiary,&#13;
    uint256 tokenAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    token().safeTransferFrom(_tokenWallet, beneficiary, tokenAmount);&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 *@title LILEPriceContract&#13;
 * @dev Contract inherits the standard Crowdsale and update the token calculation &#13;
 * mechanism to deliver bonuses&#13;
 */&#13;
contract LILEPriceContract is Crowdsale, Ownable {&#13;
  &#13;
  uint256 public minimumAllowed = 100000000000000000; // 0.1 ETH&#13;
  uint256 public maximumAllowed = 101000000000000000000; // 101 ETH;&#13;
  uint256 private _rate;&#13;
  &#13;
  /**&#13;
   * LILE token price updated&#13;
   */&#13;
  event LILEPriceUpdated(uint256 oldPrice, uint256 newPrice);&#13;
  &#13;
  constructor (uint256 rate) public {&#13;
      _rate = rate;&#13;
  }&#13;
  &#13;
  function updateLILEPrice(uint256 _weiAmount) onlyOwner external {&#13;
    require(_weiAmount &gt; 0);&#13;
    assert((1 ether) % _weiAmount == 0);&#13;
    emit LILEPriceUpdated(_rate, _weiAmount);&#13;
    _rate = _weiAmount;&#13;
  }&#13;
    &#13;
  /**&#13;
   * @dev Extend to validate ETH contribution limit&#13;
   * @param beneficiary Address performing the token purchase&#13;
   * @param weiAmount Value in wei involved in the purchase&#13;
  */&#13;
  function _preValidatePurchase(&#13;
    address beneficiary,&#13;
    uint256 weiAmount&#13;
  )&#13;
    internal&#13;
    view&#13;
  {&#13;
    require(weiAmount &gt;= minimumAllowed &amp;&amp; weiAmount &lt;= maximumAllowed);&#13;
    super._preValidatePurchase(beneficiary, weiAmount);&#13;
  }&#13;
  &#13;
  function rate() public view returns(uint256) {&#13;
    return _rate;&#13;
  }&#13;
  &#13;
  /**&#13;
   * @dev Override to extend the way in which ether is converted to tokens.&#13;
   * @param weiAmount Value in wei to be converted into tokens&#13;
   * @return Number of tokens that can be purchased with the specified _weiAmount&#13;
  */&#13;
  function _getTokenAmount(uint256 weiAmount)&#13;
    internal view returns (uint256)&#13;
  {&#13;
    uint256 amount = 0;&#13;
    &#13;
    //0.10 - 0.49 ETH&#13;
    if(weiAmount &gt;= 100000000000000000 &amp;&amp; weiAmount &lt; 500000000000000000){&#13;
      amount = weiAmount.mul( _rate.add(_rate.mul(9).div(100)) );&#13;
    }&#13;
    //0.50 - 0.99&#13;
        else if(weiAmount &gt;= 500000000000000000 &amp;&amp; weiAmount &lt; 1000000000000000000) {&#13;
      amount = weiAmount.mul( _rate.add(_rate.mul(18).div(100)) );&#13;
    } &#13;
    //1.00 - 2.99&#13;
    else if(weiAmount &gt;= 1000000000000000000 &amp;&amp; weiAmount &lt; 3000000000000000000) {&#13;
      amount = weiAmount.mul( _rate.add(_rate.mul(39).div(100)) );&#13;
    } &#13;
    //3.00 - 4.99&#13;
    else if(weiAmount &gt;= 3000000000000000000 &amp;&amp; weiAmount &lt; 500000000000000000) {&#13;
      amount = weiAmount.mul( _rate.add(_rate.mul(61).div(100)) );&#13;
    } &#13;
    //5.00 - 101&#13;
    else if (weiAmount &gt;= 500000000000000000 &amp;&amp; weiAmount &lt; 101000000000000000000) &#13;
      amount = weiAmount.mul( _rate.add(_rate.mul(81).div(100)) );&#13;
    // no bonus&#13;
    else &#13;
      amount = weiAmount.mul( _rate);&#13;
    &#13;
    // update amount for 8 decimals (etherdecimals - tokendecimals, 18-8 = 10)  &#13;
    amount = amount.div(10 ** 10);&#13;
    return amount;&#13;
  }&#13;
  &#13;
  /**&#13;
   * @dev return tokens amount against given weiAmount&#13;
  */&#13;
  function getTokenAmount(uint256 weiAmount)&#13;
    public view returns (uint256)&#13;
  {&#13;
    return _getTokenAmount(weiAmount);&#13;
  }&#13;
  &#13;
}&#13;
&#13;
/**&#13;
 * @title LILECrowdsale&#13;
 * @dev LILECrowdsale an AllowanceCrowdsale with bonuses&#13;
 * _wallet: funds collection address&#13;
 * _token: ERC20 token contract address&#13;
 * _tokenWallet: address holding the funds&#13;
 */ &#13;
contract LILECrowdsale is AllowanceCrowdsale, LILEPriceContract    {&#13;
  &#13;
  uint256 private constant _rate = 38; //@USD: 250.00&#13;
  &#13;
  //amount of tokens to be sold in this Crowdsale&#13;
  uint256 public forsale = 145623058000000;&#13;
  &#13;
  // funds will be transferred to this address&#13;
  address private _wallet = address(0x546705A13550a039de877C0404A19BF4EAd65536);&#13;
  &#13;
  // token contract address&#13;
  ERC20 private _token = ERC20(0x5B2988f2D77c38B46a753EA09a4f6Bf726E07e34);&#13;
  &#13;
  // address holding the tokens&#13;
  address private _tokenWallet = address(0x51aceC3F6710469d3F4c59594ffef05de10b1728);&#13;
&#13;
  constructor()&#13;
    public&#13;
    Crowdsale(_rate, _wallet, _token)&#13;
    AllowanceCrowdsale(_tokenWallet)&#13;
    LILEPriceContract(_rate)&#13;
    {&#13;
    }&#13;
}