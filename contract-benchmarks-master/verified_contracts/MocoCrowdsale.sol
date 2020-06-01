/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract Whitelisted is Ownable {

    mapping (address => uint8) public whitelist;
    mapping (address => bool) public provider;

    // Only whitelisted
    modifier onlyWhitelisted {
      require(isWhitelisted(msg.sender));
      _;
    }

      modifier onlyProvider {
        require(isProvider(msg.sender));
        _;
      }

      // Check if address is KYC provider
      function isProvider(address _provider) public view returns (bool){
        if (owner() == _provider){
          return true;
        }
        return provider[_provider] == true ? true : false;
      }
      // Set new provider
      function setProvider(address _provider) public onlyOwner {
         provider[_provider] = true;
      }
      // Deactive current provider
      function deactivateProvider(address _provider) public onlyOwner {
         require(provider[_provider] == true);
         provider[_provider] = false;
      }
      // Set purchaser to whitelist with zone code
      function setWhitelisted(address _purchaser, uint8 _zone) public onlyProvider {
         whitelist[_purchaser] = _zone;
      }
      // Delete purchaser from whitelist
      function deleteFromWhitelist(address _purchaser) public onlyProvider {
         whitelist[_purchaser] = 0;
      }
      // Get purchaser zone code
      function getWhitelistedZone(address _purchaser) public view returns(uint8) {
        return whitelist[_purchaser] > 0 ? whitelist[_purchaser] : 0;
      }
      // Check if purchaser is whitelisted : return true or false
      function isWhitelisted(address _purchaser) public view returns (bool){
        return whitelist[_purchaser] > 0;
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
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater thanminuend).
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
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4c3e29212f230c7e">[email protected]</a>π.com&gt;, Eenae &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3958555c415c40795450415b404d5c4a175056">[email protected]</a>&gt;&#13;
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
&#13;
/**&#13;
 * @title Crowdsale&#13;
 * @dev Crowdsale is a base contract for managing a token crowdsale,&#13;
 * allowing investors to purchase tokens with ether. This contract implements&#13;
 * such functionality in its most fundamental form and can be extended to provide additional&#13;
 * functionality and/or custom behavior.&#13;
 * The external interface represents the basic interface for purchasing tokens, and conform&#13;
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.&#13;
 * The internal interface conforms the extensible and modifiable surface of crowdsales.Override&#13;
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
  // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals calledTOK&#13;
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
&#13;
/**&#13;
 * @title TimedCrowdsale&#13;
 * @dev Crowdsale accepting contributions only within a time frame.&#13;
 */&#13;
contract TimedCrowdsale is Crowdsale {&#13;
  using SafeMath for uint256;&#13;
&#13;
  uint256 private _openingTime;&#13;
  uint256 private _closingTime;&#13;
&#13;
  /**&#13;
   * @dev Reverts if not in crowdsale time range.&#13;
   */&#13;
  modifier onlyWhileOpen {&#13;
    require(isOpen());&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Constructor, takes crowdsale opening and closing times.&#13;
   * @param openingTime Crowdsale opening time&#13;
   * @param closingTime Crowdsale closing time&#13;
   */&#13;
  constructor(uint256 openingTime, uint256 closingTime) internal {&#13;
    // solium-disable-next-line security/no-block-members&#13;
    require(openingTime &gt;= block.timestamp);&#13;
    require(closingTime &gt; openingTime);&#13;
&#13;
    _openingTime = openingTime;&#13;
    _closingTime = closingTime;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the crowdsale opening time.&#13;
   */&#13;
  function openingTime() public view returns(uint256) {&#13;
    return _openingTime;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the crowdsale closing time.&#13;
   */&#13;
  function closingTime() public view returns(uint256) {&#13;
    return _closingTime;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return true if the crowdsale is open, false otherwise.&#13;
   */&#13;
  function isOpen() public view returns (bool) {&#13;
    // solium-disable-next-line security/no-block-members&#13;
    return block.timestamp &gt;= _openingTime &amp;&amp; block.timestamp &lt;= _closingTime;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.&#13;
   * @return Whether crowdsale period has elapsed&#13;
   */&#13;
  function hasClosed() public view returns (bool) {&#13;
    // solium-disable-next-line security/no-block-members&#13;
    return block.timestamp &gt; _closingTime;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Extend parent behavior requiring to be within contributing period&#13;
   * @param beneficiary Token purchaser&#13;
   * @param weiAmount Amount of wei contributed&#13;
   */&#13;
  function _preValidatePurchase(&#13;
    address beneficiary,&#13;
    uint256 weiAmount&#13;
  )&#13;
    internal&#13;
    onlyWhileOpen&#13;
    view&#13;
  {&#13;
    super._preValidatePurchase(beneficiary, weiAmount);&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title PostDeliveryCrowdsale&#13;
 * @dev Crowdsale that locks tokens from withdrawal until it ends.&#13;
 */&#13;
contract PostDeliveryCrowdsale is TimedCrowdsale {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping(address =&gt; uint256) private _balances;&#13;
&#13;
  constructor() internal {}&#13;
&#13;
  /**&#13;
   * @dev Withdraw tokens only after crowdsale ends.&#13;
   * @param beneficiary Whose tokens will be withdrawn.&#13;
   */&#13;
  function withdrawTokens(address beneficiary) public {&#13;
    require(hasClosed());&#13;
    uint256 amount = _balances[beneficiary];&#13;
    require(amount &gt; 0);&#13;
    _balances[beneficiary] = 0;&#13;
    _deliverTokens(beneficiary, amount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the balance of an account.&#13;
   */&#13;
  function balanceOf(address account) public view returns(uint256) {&#13;
    return _balances[account];&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Overrides parent by storing balances instead of issuing tokens right away.&#13;
   * @param beneficiary Token purchaser&#13;
   * @param tokenAmount Amount of tokens purchased&#13;
   */&#13;
  function _processPurchase(&#13;
    address beneficiary,&#13;
    uint256 tokenAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    _balances[beneficiary] = _balances[beneficiary].add(tokenAmount);&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/math/Math.sol&#13;
&#13;
/**&#13;
 * @title Math&#13;
 * @dev Assorted math operations&#13;
 */&#13;
library Math {&#13;
  /**&#13;
  * @dev Returns the largest of two numbers.&#13;
  */&#13;
  function max(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    return a &gt;= b ? a : b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Returns the smallest of two numbers.&#13;
  */&#13;
  function min(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    return a &lt; b ? a : b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Calculates the average of two numbers. Since these are integers,&#13;
  * averages of an even and odd number cannot be represented, and will be&#13;
  * rounded down.&#13;
  */&#13;
  function average(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // (a + b) / 2 can overflow, so we distribute&#13;
    return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);&#13;
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
   * @param tokenWallet Address holding the tokens, which has approved allowance to thecrowdsale&#13;
   */&#13;
  constructor(address tokenWallet) internal {&#13;
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
    return Math.min(&#13;
      token().balanceOf(_tokenWallet),&#13;
      token().allowance(_tokenWallet, this)&#13;
    );&#13;
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
contract MocoCrowdsale is TimedCrowdsale, AllowanceCrowdsale, Whitelisted {&#13;
  // Amount of wei raised&#13;
&#13;
  uint256 public bonusPeriod;&#13;
&#13;
  uint256 public bonusAmount;&#13;
  // Unlock period 1 - 6 month&#13;
  uint256 private _unlock1;&#13;
&#13;
  // Unlock period 2 - 12 month&#13;
  uint256 private _unlock2;&#13;
&#13;
  // Specify locked zone for 2nd period&#13;
  uint8 private _lockedZone;&#13;
&#13;
  // Total tokens distributed&#13;
  uint256 private _totalTokensDistributed;&#13;
&#13;
&#13;
  // Total tokens locked&#13;
  uint256 private _totalTokensLocked;&#13;
&#13;
&#13;
  event TokensPurchased(&#13;
    address indexed purchaser,&#13;
    address indexed beneficiary,&#13;
    address asset,&#13;
    uint256 value,&#13;
    uint256 amount&#13;
  );&#13;
&#13;
  struct Asset {&#13;
    uint256 weiRaised;&#13;
    uint256 minAmount;&#13;
    uint256 rate;&#13;
    bool active;&#13;
  }&#13;
&#13;
  mapping (address =&gt; Asset) private asset;&#13;
  mapping(address =&gt; uint256) private _balances;&#13;
&#13;
&#13;
  constructor(&#13;
    uint256 _openingTime,&#13;
    uint256 _closingTime,&#13;
    uint256 _unlockPeriod1,&#13;
    uint256 _unlockPeriod2,&#13;
    uint256 _bonusPeriodEnd,&#13;
    uint256 _bonusAmount,&#13;
    uint256 _rate,&#13;
    address _wallet,&#13;
    IERC20 _token,&#13;
    address _tokenWallet&#13;
  ) public&#13;
  TimedCrowdsale(_openingTime, _closingTime)&#13;
  Crowdsale(_rate, _wallet, _token)&#13;
  AllowanceCrowdsale(_tokenWallet){&#13;
       _unlock1 = _unlockPeriod1;&#13;
       _unlock2 = _unlockPeriod2;&#13;
       bonusPeriod = _bonusPeriodEnd;&#13;
      bonusAmount  = _bonusAmount;&#13;
      asset[0x0].rate  = _rate;&#13;
  }&#13;
  function getAssetRaised(address _assetAddress) public view returns(uint256) {&#13;
      return asset[_assetAddress].weiRaised;&#13;
  }&#13;
  function getAssetMinAmount(address _assetAddress) public view returns(uint256) {&#13;
      return asset[_assetAddress].minAmount;&#13;
  }&#13;
  function getAssetRate(address _assetAddress) public view returns(uint256) {&#13;
      return asset[_assetAddress].rate;&#13;
  }&#13;
  function isAssetActive(address _assetAddress) public view returns(bool) {&#13;
      return asset[_assetAddress].active == true ? true : false;&#13;
  }&#13;
  // Add asset&#13;
  function setAsset(address _assetAddress, uint256 _weiRaised, uint256 _minAmount, uint256 _rate) public onlyOwner {&#13;
      asset[_assetAddress].weiRaised = _weiRaised;&#13;
      asset[_assetAddress].minAmount = _minAmount;&#13;
      asset[_assetAddress].rate = _rate;&#13;
      asset[_assetAddress].active = true;&#13;
  }&#13;
&#13;
  //&#13;
&#13;
  function weiRaised(address _asset) public view returns (uint256) {&#13;
    return asset[_asset].weiRaised;&#13;
  }&#13;
  function _getTokenAmount(uint256 weiAmount, address asst)&#13;
    internal view returns (uint256)&#13;
  {&#13;
    return weiAmount.mul(asset[asst].rate);&#13;
  }&#13;
&#13;
  function minAmount(address _asset) public view returns (uint256) {&#13;
    return asset[_asset].minAmount;&#13;
  }&#13;
&#13;
  // Buy Tokens&#13;
  function buyTokens(address beneficiary) public onlyWhitelisted payable {&#13;
    uint256 weiAmount = msg.value;&#13;
    _preValidatePurchase(beneficiary, weiAmount, 0x0);&#13;
&#13;
    // calculate token amount to be created&#13;
    uint256 tokens = _getTokenAmount(weiAmount, 0x0);&#13;
&#13;
    // update state&#13;
    asset[0x0].weiRaised = asset[0x0].weiRaised.add(weiAmount);&#13;
&#13;
    _processPurchase(beneficiary, tokens);&#13;
&#13;
    emit TokensPurchased(&#13;
      msg.sender,&#13;
      beneficiary,&#13;
      0x0,&#13;
      weiAmount,&#13;
      tokens&#13;
    );&#13;
&#13;
    // super._updatePurchasingState(beneficiary, weiAmount);&#13;
&#13;
    super._forwardFunds();&#13;
    // super._postValidatePurchase(beneficiary, weiAmount);&#13;
  }&#13;
  // Buy tokens for assets&#13;
  function buyTokensAsset(address beneficiary, address asst, uint256 amount) public onlyWhitelisted {&#13;
     require(isAssetActive(asst));&#13;
    _preValidatePurchase(beneficiary, amount, asst);&#13;
&#13;
    // calculate token amount to be created&#13;
    uint256 tokens = _getTokenAmount(amount, asst);&#13;
&#13;
    // update state&#13;
    asset[asst].weiRaised = asset[asst].weiRaised.add(amount);&#13;
&#13;
    _processPurchase(beneficiary, tokens);&#13;
&#13;
    emit TokensPurchased(&#13;
      msg.sender,&#13;
      beneficiary,&#13;
      asst,&#13;
      amount,&#13;
      tokens&#13;
    );&#13;
&#13;
     address _wallet  = wallet();&#13;
     IERC20(asst).safeTransferFrom(beneficiary, _wallet, amount);&#13;
&#13;
    // super._postValidatePurchase(beneficiary, weiAmount);&#13;
  }&#13;
&#13;
  // Check if locked is end&#13;
  function lockedHasEnd() public view returns (bool) {&#13;
    return block.timestamp &gt; _unlock1 ? true : false;&#13;
  }&#13;
  // Check if locked is end&#13;
  function lockedTwoHasEnd() public view returns (bool) {&#13;
    return block.timestamp &gt; _unlock2 ? true : false;&#13;
  }&#13;
// Withdraw tokens after locked period is finished&#13;
  function withdrawTokens(address beneficiary) public {&#13;
    require(lockedHasEnd());&#13;
    uint256 amount = _balances[beneficiary];&#13;
    require(amount &gt; 0);&#13;
    uint256 zone = super.getWhitelistedZone(beneficiary);&#13;
    if (zone == 840){&#13;
      // require(lockedTwoHasEnd());&#13;
      if(lockedTwoHasEnd()){&#13;
        _balances[beneficiary] = 0;&#13;
        _deliverTokens(beneficiary, amount);&#13;
      }&#13;
    } else {&#13;
    _balances[beneficiary] = 0;&#13;
    _deliverTokens(beneficiary, amount);&#13;
    }&#13;
  }&#13;
&#13;
  // Locked tokens balance&#13;
  function balanceOf(address account) public view returns(uint256) {&#13;
    return _balances[account];&#13;
  }&#13;
  // Pre validation token buy&#13;
  function _preValidatePurchase(&#13;
    address beneficiary,&#13;
    uint256 weiAmount,&#13;
    address asst&#13;
  )&#13;
    internal&#13;
    view&#13;
  {&#13;
    require(beneficiary != address(0));&#13;
    require(weiAmount != 0);&#13;
    require(weiAmount &gt;= minAmount(asst));&#13;
}&#13;
  function getBonusAmount(uint256 _tokenAmount) public view returns(uint256) {&#13;
    return block.timestamp &lt; bonusPeriod ? _tokenAmount.div(bonusAmount) : 0;&#13;
  }&#13;
&#13;
  function calculateTokens(uint256 _weiAmount) public view returns(uint256) {&#13;
    uint256 tokens  = _getTokenAmount(_weiAmount);&#13;
    return  tokens + getBonusAmount(tokens);&#13;
  }&#13;
&#13;
  function _processPurchase(&#13;
    address beneficiary,&#13;
    uint256 tokenAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    uint256 zone = super.getWhitelistedZone(beneficiary);&#13;
   uint256 bonusTokens = getBonusAmount(tokenAmount);&#13;
    if (zone == 840){&#13;
      uint256 totalTokens = bonusTokens.add(tokenAmount);&#13;
      _balances[beneficiary] = _balances[beneficiary].add(totalTokens);&#13;
    }&#13;
    else {&#13;
      super._deliverTokens(beneficiary, tokenAmount);&#13;
      _balances[beneficiary] = _balances[beneficiary].add(bonusTokens);&#13;
    }&#13;
&#13;
  }&#13;
&#13;
}