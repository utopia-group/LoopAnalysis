pragma solidity ^0.4.25;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

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

// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="9be9fef6f8f4dba9">[email protected]</a>π.com&gt;, Eenae &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2d4c41485548546d4044554f5459485e034442">[email protected]</a>&gt;&#13;
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
// File: openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol&#13;
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
// File: openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol&#13;
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
// File: openzeppelin-solidity/contracts/crowdsale/emission/AllowanceCrowdsale.sol&#13;
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
// File: openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol&#13;
&#13;
/**&#13;
 * @title CappedCrowdsale&#13;
 * @dev Crowdsale with a limit for total contributions.&#13;
 */&#13;
contract CappedCrowdsale is Crowdsale {&#13;
  using SafeMath for uint256;&#13;
&#13;
  uint256 private _cap;&#13;
&#13;
  /**&#13;
   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.&#13;
   * @param cap Max amount of wei to be contributed&#13;
   */&#13;
  constructor(uint256 cap) internal {&#13;
    require(cap &gt; 0);&#13;
    _cap = cap;&#13;
  }&#13;
&#13;
  /**&#13;
   * @return the cap of the crowdsale.&#13;
   */&#13;
  function cap() public view returns(uint256) {&#13;
    return _cap;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Checks whether the cap has been reached.&#13;
   * @return Whether the cap was reached&#13;
   */&#13;
  function capReached() public view returns (bool) {&#13;
    return weiRaised() &gt;= _cap;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Extend parent behavior requiring purchase to respect the funding cap.&#13;
   * @param beneficiary Token purchaser&#13;
   * @param weiAmount Amount of wei contributed&#13;
   */&#13;
  function _preValidatePurchase(&#13;
    address beneficiary,&#13;
    uint256 weiAmount&#13;
  )&#13;
    internal&#13;
    view&#13;
  {&#13;
    super._preValidatePurchase(beneficiary, weiAmount);&#13;
    require(weiRaised().add(weiAmount) &lt;= _cap);&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts/BitherCrowdsale.sol&#13;
&#13;
/**&#13;
 * @title BitherCrowdsale&#13;
 * @dev BitherCrowdsale contract uses multiple openzeppelin base contracts and adds some custom behaviour.&#13;
 *      The openzeppelin base contracts have been audited and are widely used by the community. They can&#13;
 *      be trusted to have almost zero security vulnerabilities and therefore do not need to be tested.&#13;
 *      The BitherCrowdale enables the purchasing of 2 tokens, the BitherToken (BTR) and BitherStockToken&#13;
 *      (BSK) at rates determined by the current block time. It specifies a cap of Ether that can be contributed&#13;
 *      and a length of time the crowdsale lasts. It requires the crowdsale contract address be given&#13;
 *      an allowance of 33000000 BTR and 21000000 BSK enabling it to distribute the purchased tokens. These&#13;
 *      values are determined by the cap of 300000 ETH and the phased distribution rates.&#13;
 */&#13;
contract BitherCrowdsale is AllowanceCrowdsale, TimedCrowdsale, CappedCrowdsale {&#13;
&#13;
    uint256 constant private CAP_IN_WEI = 300000 ether;&#13;
&#13;
    uint256 constant private BTR_PRIVATE_SALE_RATE = 110;&#13;
    uint256 constant private BTR_PRESALE_RATE_DAY_1 = 110;&#13;
    uint256 constant private BTR_PRESALE_RATE_DAY_2_TO_5 = 109;&#13;
    uint256 constant private BTR_PRESALE_RATE_DAY_6_TO_9 = 108;&#13;
    uint256 constant private BTR_PRESALE_RATE_DAY_10_TO_13 = 107;&#13;
&#13;
    uint256 constant private BTR_CROWDSALE_RATE_DAY_1_FIRST_2_HOURS = 110;&#13;
    uint256 constant private BTR_CROWDSALE_RATE_DAY_1_TO_7 = 106;&#13;
    uint256 constant private BTR_CROWDSALE_RATE_DAY_8_TO_14 = 104;&#13;
    uint256 constant private BTR_CROWDSALE_RATE_DAY_15_TO_21 = 102;&#13;
    uint256 constant private BTR_CROWDSALE_RATE_DAY_22_TO_28 = 100;&#13;
&#13;
    uint256 constant private BSK_PRIVATE_SALE_RATE = 70;&#13;
    uint256 constant private BSK_PRESALE_RATE_FIRST_2_HOURS = 70;&#13;
    uint256 constant private BSK_PRESALE_RATE_DAY_1 = 68;&#13;
    uint256 constant private BSK_PRESALE_RATE_DAY_2_TO_5 = 66;&#13;
    uint256 constant private BSK_PRESALE_RATE_DAY_6_TO_9 = 64;&#13;
    uint256 constant private BSK_PRESALE_RATE_DAY_10_TO_13 = 62;&#13;
&#13;
    uint256 constant private BSK_CROWDSALE_RATE_DAY_1_TO_7 = 60;&#13;
    uint256 constant private BSK_CROWDSALE_RATE_DAY_8_TO_14 = 57;&#13;
    uint256 constant private BSK_CROWDSALE_RATE_DAY_15_TO_21 = 54;&#13;
    uint256 constant private BSK_CROWDSALE_RATE_DAY_22_TO_28 = 50;&#13;
&#13;
    IERC20 private _bitherStockToken;&#13;
    uint256 private _privateSaleClosingTime; // Thursday, 24 January 2019 14:00:00 (1548338400)&#13;
    uint256 private _presaleOpeningTime; // Saturday, 26 January 2019 14:00:00 (1548511200)&#13;
    uint256 private _crowdsaleOpeningTime; // Saturday, 16 February 2019 14:00:00 (1550325600)&#13;
    uint256 private _crowdsaleClosingTime; // Saturday, 16 March 2019 14:00:00 (1552744800)&#13;
&#13;
    /**&#13;
     * Event for BSK token purchase logging&#13;
     * @param purchaser Who paid for the tokens&#13;
     * @param beneficiary Who got the tokens&#13;
     * @param value Wei paid for purchase&#13;
     * @param amount Amount of tokens purchased&#13;
     */&#13;
    event BitherStockTokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);&#13;
&#13;
    /**&#13;
     * @dev Constructor, calls the inherited classes constructors, stores bitherStockToken and determines crowdsale times&#13;
     * @param bitherToken The BitherToken address, must be an ERC20 contract&#13;
     * @param bitherStockToken The BitherStockToken, must be an ERC20 contract&#13;
     * @param bitherTokensOwner Address holding the tokens, which has approved allowance to the crowdsale&#13;
     * @param etherBenefactor Address that will receive the deposited Ether&#13;
     * @param preSaleOpeningTime The presale opening time, in seconds, all other times are determined using this to reduce risk of error&#13;
     */&#13;
    constructor(IERC20 bitherToken, IERC20 bitherStockToken, address bitherTokensOwner, address etherBenefactor, uint256 preSaleOpeningTime)&#13;
        Crowdsale(BTR_PRIVATE_SALE_RATE, etherBenefactor, bitherToken)&#13;
        AllowanceCrowdsale(bitherTokensOwner)&#13;
        TimedCrowdsale(now, preSaleOpeningTime + 7 weeks)&#13;
        CappedCrowdsale(CAP_IN_WEI)&#13;
        public&#13;
    {&#13;
        _bitherStockToken = bitherStockToken;&#13;
&#13;
        _privateSaleClosingTime = preSaleOpeningTime - 2 days;&#13;
        _presaleOpeningTime = preSaleOpeningTime;&#13;
        _crowdsaleOpeningTime = preSaleOpeningTime + 3 weeks;&#13;
        _crowdsaleClosingTime = _crowdsaleOpeningTime + 4 weeks;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Overrides function in the Crowdsale contract to revert contributions less then&#13;
     *      69 Eth during the first period and less than 0.1 Eth during the rest of the crowdsale&#13;
     * @param beneficiary Address performing the token purchase&#13;
     * @param weiAmount Value in wei involved in the purchase&#13;
     */&#13;
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {&#13;
        super._preValidatePurchase(beneficiary, weiAmount);&#13;
&#13;
        if (now &lt; _privateSaleClosingTime) {&#13;
            require(weiAmount &gt;= 69 ether, "Not enough Eth. Contributions must be 69 Eth minimum during the private sale");&#13;
        } else {&#13;
            require(weiAmount &gt;= 100 finney, "Not enough Eth. Contributions must be 0.1 Eth minimum during the presale and crowdsale");&#13;
        }&#13;
&#13;
        if (now &gt; _privateSaleClosingTime &amp;&amp; now &lt; _presaleOpeningTime) {&#13;
            revert("Private sale has ended and the presale is yet to begin");&#13;
        } else if (now &gt; _presaleOpeningTime + 13 days &amp;&amp; now &lt; _crowdsaleOpeningTime) {&#13;
            revert("Presale has ended and the crowdsale is yet to begin");&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Overrides function in the Crowdsale contract to enable a custom phased distribution&#13;
     * @param weiAmount Value in wei to be converted into tokens&#13;
     * @return Number of tokens that can be purchased with the specified weiAmount&#13;
     */&#13;
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {&#13;
&#13;
        if (now &lt; _privateSaleClosingTime) {&#13;
            return weiAmount.mul(BTR_PRIVATE_SALE_RATE);&#13;
&#13;
        } else if (now &lt; _presaleOpeningTime + 1 days) {&#13;
            return weiAmount.mul(BTR_PRESALE_RATE_DAY_1);&#13;
        } else if (now &lt; _presaleOpeningTime + 5 days) {&#13;
            return weiAmount.mul(BTR_PRESALE_RATE_DAY_2_TO_5);&#13;
        } else if (now &lt; _presaleOpeningTime + 9 days) {&#13;
            return weiAmount.mul(BTR_PRESALE_RATE_DAY_6_TO_9);&#13;
        } else if (now &lt; _presaleOpeningTime + 13 days) {&#13;
            return weiAmount.mul(BTR_PRESALE_RATE_DAY_10_TO_13);&#13;
&#13;
        } else if (now &lt; _crowdsaleOpeningTime + 2 hours) {&#13;
            return weiAmount.mul(BTR_CROWDSALE_RATE_DAY_1_FIRST_2_HOURS);&#13;
        } else if (now &lt; _crowdsaleOpeningTime + 1 weeks) {&#13;
            return weiAmount.mul(BTR_CROWDSALE_RATE_DAY_1_TO_7);&#13;
        } else if (now &lt; _crowdsaleOpeningTime + 2 weeks) {&#13;
            return weiAmount.mul(BTR_CROWDSALE_RATE_DAY_8_TO_14);&#13;
        } else if (now &lt; _crowdsaleOpeningTime + 3 weeks) {&#13;
            return weiAmount.mul(BTR_CROWDSALE_RATE_DAY_15_TO_21);&#13;
        } else if (now &lt;= closingTime()) {&#13;
            return weiAmount.mul(BTR_CROWDSALE_RATE_DAY_22_TO_28);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Overrides function in AllowanceCrowdsale contract (therefore also overrides function&#13;
     *      in Crowdsale contract) to add functionality for distribution of a second token, BSK.&#13;
     * @param beneficiary Token purchaser&#13;
     * @param tokenAmount Amount of tokens purchased&#13;
     */&#13;
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {&#13;
        super._deliverTokens(beneficiary, tokenAmount);&#13;
&#13;
        uint256 weiAmount = msg.value;&#13;
        uint256 bskTokenAmount = getBskTokenAmount(weiAmount);&#13;
&#13;
        _bitherStockToken.safeTransferFrom(tokenWallet(), beneficiary, bskTokenAmount);&#13;
&#13;
        emit BitherStockTokensPurchased(msg.sender, beneficiary, weiAmount, bskTokenAmount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Determines distribution of BSK depending on the time of the transaction&#13;
     * @param weiAmount Value in wei to be converted into tokens&#13;
     * @return Number of tokens that can be purchased with the specified weiAmount&#13;
     */&#13;
    function getBskTokenAmount(uint256 weiAmount) private view returns (uint256) {&#13;
&#13;
        if (now &lt; _privateSaleClosingTime) {&#13;
            return weiAmount.mul(BSK_PRIVATE_SALE_RATE);&#13;
&#13;
        } else if (now &lt; _presaleOpeningTime + 2 hours) {&#13;
            return weiAmount.mul(BSK_PRESALE_RATE_FIRST_2_HOURS);&#13;
        } else if (now &lt; _presaleOpeningTime + 1 days) {&#13;
            return weiAmount.mul(BSK_PRESALE_RATE_DAY_1);&#13;
        } else if (now &lt; _presaleOpeningTime + 5 days) {&#13;
            return weiAmount.mul(BSK_PRESALE_RATE_DAY_2_TO_5);&#13;
        } else if (now &lt; _presaleOpeningTime + 9 days) {&#13;
            return weiAmount.mul(BSK_PRESALE_RATE_DAY_6_TO_9);&#13;
        } else if (now &lt; _presaleOpeningTime + 13 days) {&#13;
            return weiAmount.mul(BSK_PRESALE_RATE_DAY_10_TO_13);&#13;
&#13;
        } else if (now &lt; _crowdsaleOpeningTime + 1 weeks) {&#13;
            return weiAmount.mul(BSK_CROWDSALE_RATE_DAY_1_TO_7);&#13;
        } else if (now &lt; _crowdsaleOpeningTime + 2 weeks) {&#13;
            return weiAmount.mul(BSK_CROWDSALE_RATE_DAY_8_TO_14);&#13;
        } else if (now &lt; _crowdsaleOpeningTime + 3 weeks) {&#13;
            return weiAmount.mul(BSK_CROWDSALE_RATE_DAY_15_TO_21);&#13;
        } else if (now &lt;= closingTime()) {&#13;
            return weiAmount.mul(BSK_CROWDSALE_RATE_DAY_22_TO_28);&#13;
        }&#13;
    }&#13;
}