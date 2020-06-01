pragma solidity ^0.4.23;

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

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="e99b8c848a86a9db">[email protected]</span>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private reentrancyLock = false;&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * @notice If you mark a function `nonReentrant`, you should also&#13;
   * mark it `external`. Calling one nonReentrant function from&#13;
   * another is not supported. Instead, you can implement a&#13;
   * `private` function doing the actual work, and a `external`&#13;
   * wrapper marked as `nonReentrant`.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    require(!reentrancyLock);&#13;
    reentrancyLock = true;&#13;
    _;&#13;
    reentrancyLock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  function totalSupply() public view returns (uint256);&#13;
  function balanceOf(address who) public view returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender)&#13;
    public view returns (uint256);&#13;
&#13;
  function transferFrom(address from, address to, uint256 value)&#13;
    public returns (bool);&#13;
&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(&#13;
    address indexed owner,&#13;
    address indexed spender,&#13;
    uint256 value&#13;
  );&#13;
}&#13;
&#13;
contract BablosTokenInterface is ERC20 {&#13;
  bool public frozen;&#13;
  function burn(uint256 _value) public;&#13;
  function setSale(address _sale) public;&#13;
  function thaw() external;&#13;
}&#13;
&#13;
contract PriceUpdaterInterface {&#13;
  enum Currency { ETH, BTC, WME, WMZ, WMR, WMX }&#13;
&#13;
  uint public decimalPrecision = 3;&#13;
&#13;
  mapping(uint =&gt; uint) public price;&#13;
}&#13;
&#13;
contract BablosCrowdsaleWalletInterface {&#13;
  enum State {&#13;
    // gathering funds&#13;
    GATHERING,&#13;
    // returning funds to investors&#13;
    REFUNDING,&#13;
    // funds can be pulled by owners&#13;
    SUCCEEDED&#13;
  }&#13;
&#13;
  event StateChanged(State state);&#13;
  event Invested(address indexed investor, PriceUpdaterInterface.Currency currency, uint amount, uint tokensReceived);&#13;
  event EtherWithdrawan(address indexed to, uint value);&#13;
  event RefundSent(address indexed to, uint value);&#13;
  event ControllerRetired(address was);&#13;
&#13;
  /// @dev price updater interface&#13;
  PriceUpdaterInterface public priceUpdater;&#13;
&#13;
  /// @notice total amount of investments in currencies&#13;
  mapping(uint =&gt; uint) public totalInvested;&#13;
&#13;
  /// @notice state of the registry&#13;
  State public state = State.GATHERING;&#13;
&#13;
  /// @dev balances of investors in wei&#13;
  mapping(address =&gt; uint) public weiBalances;&#13;
&#13;
  /// @dev balances of tokens sold to investors&#13;
  mapping(address =&gt; uint) public tokenBalances;&#13;
&#13;
  /// @dev list of unique investors&#13;
  address[] public investors;&#13;
&#13;
  /// @dev token accepted for refunds&#13;
  BablosTokenInterface public token;&#13;
&#13;
  /// @dev operations will be controlled by this address&#13;
  address public controller;&#13;
&#13;
  /// @dev the team's tokens percent&#13;
  uint public teamPercent;&#13;
&#13;
  /// @dev tokens sent to initial PR - they will be substracted, when tokens will be burn&#13;
  uint public prTokens;&#13;
  &#13;
  /// @dev performs only allowed state transitions&#13;
  function changeState(State _newState) external;&#13;
&#13;
  /// @dev records an investment&#13;
  /// @param _investor who invested&#13;
  /// @param _tokenAmount the amount of token bought, calculation is handled by ICO&#13;
  /// @param _currency the currency in which investor invested&#13;
  /// @param _amount the invested amount&#13;
  function invested(address _investor, uint _tokenAmount, PriceUpdaterInterface.Currency _currency, uint _amount) external payable;&#13;
&#13;
  /// @dev get total invested in ETH&#13;
  function getTotalInvestedEther() external view returns (uint);&#13;
&#13;
  /// @dev get total invested in EUR&#13;
  function getTotalInvestedEur() external view returns (uint);&#13;
&#13;
  /// @notice withdraw `_value` of ether to his address, can be called if crowdsale succeeded&#13;
  /// @param _value amount of wei to withdraw&#13;
  function withdrawEther(uint _value) external;&#13;
&#13;
  /// @notice owner: send `_value` of tokens to his address, can be called if&#13;
  /// crowdsale failed and some of the investors refunded the ether&#13;
  /// @param _value amount of token-wei to send&#13;
  function withdrawTokens(uint _value) external;&#13;
&#13;
  /// @notice withdraw accumulated balance, called by payee in case crowdsale failed&#13;
  /// @dev caller should approve tokens bought during ICO to this contract&#13;
  function withdrawPayments() external;&#13;
&#13;
  /// @dev returns investors count&#13;
  function getInvestorsCount() external view returns (uint);&#13;
&#13;
  /// @dev ability for controller to step down&#13;
  function detachController() external;&#13;
&#13;
  /// @dev unhold holded team's tokens&#13;
  function unholdTeamTokens() external;&#13;
}&#13;
&#13;
contract BablosCrowdsale is ReentrancyGuard, Ownable {&#13;
  using SafeMath for uint;&#13;
&#13;
  enum SaleState { INIT, ACTIVE, PAUSED, SOFT_CAP_REACHED, FAILED, SUCCEEDED }&#13;
&#13;
  SaleState public state = SaleState.INIT;&#13;
&#13;
  // The token being sold&#13;
  BablosTokenInterface public token;&#13;
&#13;
  // Address where funds are collected&#13;
  BablosCrowdsaleWalletInterface public wallet;&#13;
&#13;
  // How many tokens per 1 ether&#13;
  uint public rate;&#13;
&#13;
  uint public openingTime;&#13;
  uint public closingTime;&#13;
&#13;
  uint public tokensSold;&#13;
  uint public tokensSoldExternal;&#13;
&#13;
  uint public softCap;&#13;
  uint public hardCap;&#13;
  uint public minimumAmount;&#13;
&#13;
  address public controller;&#13;
  PriceUpdaterInterface public priceUpdater;&#13;
&#13;
  /**&#13;
   * Event for token purchase logging&#13;
   * @param purchaser who paid for the tokens&#13;
   * @param beneficiary who got the tokens&#13;
   * @param currency of paid value&#13;
   * @param value paid for purchase&#13;
   * @param amount amount of tokens purchased&#13;
   */&#13;
  event TokenPurchase(&#13;
    address indexed purchaser,&#13;
    address indexed beneficiary,&#13;
    uint currency,&#13;
    uint value,&#13;
    uint amount&#13;
  );&#13;
&#13;
  event StateChanged(SaleState _state);&#13;
  event FundTransfer(address _backer, uint _amount);&#13;
&#13;
  // MODIFIERS&#13;
&#13;
  modifier requiresState(SaleState _state) {&#13;
    require(state == _state);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier onlyController() {&#13;
    require(msg.sender == controller);&#13;
    _;&#13;
  }&#13;
&#13;
  /// @dev triggers some state changes based on current time&#13;
  /// @param _client optional refund parameter&#13;
  /// @param _payment optional refund parameter&#13;
  /// @param _currency currency&#13;
  /// note: function body could be skipped!&#13;
  modifier timedStateChange(address _client, uint _payment, PriceUpdaterInterface.Currency _currency) {&#13;
    if (SaleState.INIT == state &amp;&amp; getTime() &gt;= openingTime) {&#13;
      changeState(SaleState.ACTIVE);&#13;
    }&#13;
&#13;
    if ((state == SaleState.ACTIVE || state == SaleState.SOFT_CAP_REACHED) &amp;&amp; getTime() &gt;= closingTime) {&#13;
      finishSale();&#13;
&#13;
      if (_currency == PriceUpdaterInterface.Currency.ETH &amp;&amp; _payment &gt; 0) {&#13;
        _client.transfer(_payment);&#13;
      }&#13;
    } else {&#13;
      _;&#13;
    }&#13;
  }&#13;
&#13;
  constructor(&#13;
    uint _rate, &#13;
    BablosTokenInterface _token,&#13;
    uint _openingTime, &#13;
    uint _closingTime, &#13;
    uint _softCap,&#13;
    uint _hardCap,&#13;
    uint _minimumAmount) &#13;
    public&#13;
  {&#13;
    require(_rate &gt; 0);&#13;
    require(_token != address(0));&#13;
    require(_openingTime &gt;= getTime());&#13;
    require(_closingTime &gt; _openingTime);&#13;
    require(_softCap &gt; 0);&#13;
    require(_hardCap &gt; 0);&#13;
&#13;
    rate = _rate;&#13;
    token = _token;&#13;
    openingTime = _openingTime;&#13;
    closingTime = _closingTime;&#13;
    softCap = _softCap;&#13;
    hardCap = _hardCap;&#13;
    minimumAmount = _minimumAmount;&#13;
  }&#13;
&#13;
  function setWallet(BablosCrowdsaleWalletInterface _wallet) external onlyOwner {&#13;
    require(_wallet != address(0));&#13;
    wallet = _wallet;&#13;
  }&#13;
&#13;
  function setController(address _controller) external onlyOwner {&#13;
    require(_controller != address(0));&#13;
    controller = _controller;&#13;
  }&#13;
&#13;
  function setPriceUpdater(PriceUpdaterInterface _priceUpdater) external onlyOwner {&#13;
    require(_priceUpdater != address(0));&#13;
    priceUpdater = _priceUpdater;&#13;
  }&#13;
&#13;
  function isActive() public view returns (bool active) {&#13;
    return state == SaleState.ACTIVE || state == SaleState.SOFT_CAP_REACHED;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev fallback function&#13;
   */&#13;
  function () external payable {&#13;
    require(msg.data.length == 0);&#13;
    buyTokens(msg.sender);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev token purchase&#13;
   * @param _beneficiary Address performing the token purchase&#13;
   */&#13;
  function buyTokens(address _beneficiary) public payable {&#13;
    uint weiAmount = msg.value;&#13;
&#13;
    require(_beneficiary != address(0));&#13;
    require(weiAmount != 0);&#13;
&#13;
    // calculate token amount to be created&#13;
    uint tokens = _getTokenAmount(weiAmount);&#13;
&#13;
    require(tokens &gt;= minimumAmount &amp;&amp; token.balanceOf(address(this)) &gt;= tokens);&#13;
&#13;
    _internalBuy(_beneficiary, PriceUpdaterInterface.Currency.ETH, weiAmount, tokens);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev external token purchase (BTC and WebMoney). Only allowed for merchant controller&#13;
   * @param _beneficiary Address performing the token purchase&#13;
   * @param _tokens Quantity of purchased tokens&#13;
   */&#13;
  function externalBuyToken(&#13;
    address _beneficiary, &#13;
    PriceUpdaterInterface.Currency _currency, &#13;
    uint _amount, &#13;
    uint _tokens)&#13;
      external&#13;
      onlyController&#13;
  {&#13;
    require(_beneficiary != address(0));&#13;
    require(_tokens &gt;= minimumAmount &amp;&amp; token.balanceOf(address(this)) &gt;= _tokens);&#13;
    require(_amount != 0);&#13;
&#13;
    _internalBuy(_beneficiary, _currency, _amount, _tokens);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Override to extend the way in which ether is converted to tokens.&#13;
   * @param _weiAmount Value in wei to be converted into tokens&#13;
   * @return Number of tokens that can be purchased with the specified _weiAmount&#13;
   */&#13;
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {&#13;
    return _weiAmount.mul(rate).div(1 ether);&#13;
  }&#13;
&#13;
  function _internalBuy(&#13;
    address _beneficiary, &#13;
    PriceUpdaterInterface.Currency _currency, &#13;
    uint _amount, &#13;
    uint _tokens)&#13;
      internal&#13;
      nonReentrant&#13;
      timedStateChange(_beneficiary, _amount, _currency)&#13;
  {&#13;
    require(isActive());&#13;
    if (_currency == PriceUpdaterInterface.Currency.ETH) {&#13;
      tokensSold = tokensSold.add(_tokens);&#13;
    } else {&#13;
      tokensSoldExternal = tokensSoldExternal.add(_tokens);&#13;
    }&#13;
    token.transfer(_beneficiary, _tokens);&#13;
&#13;
    emit TokenPurchase(&#13;
      msg.sender,&#13;
      _beneficiary,&#13;
      uint(_currency),&#13;
      _amount,&#13;
      _tokens&#13;
    );&#13;
&#13;
    if (_currency == PriceUpdaterInterface.Currency.ETH) {&#13;
      wallet.invested.value(_amount)(_beneficiary, _tokens, _currency, _amount);&#13;
      emit FundTransfer(_beneficiary, _amount);&#13;
    } else {&#13;
      wallet.invested(_beneficiary, _tokens, _currency, _amount);&#13;
    }&#13;
    &#13;
    // check if soft cap reached&#13;
    if (state == SaleState.ACTIVE &amp;&amp; wallet.getTotalInvestedEther() &gt;= softCap) {&#13;
      changeState(SaleState.SOFT_CAP_REACHED);&#13;
    }&#13;
&#13;
    // check if all tokens are sold&#13;
    if (token.balanceOf(address(this)) &lt; minimumAmount) {&#13;
      finishSale();&#13;
    }&#13;
&#13;
    // check if hard cap reached&#13;
    if (state == SaleState.SOFT_CAP_REACHED &amp;&amp; wallet.getTotalInvestedEur() &gt;= hardCap) {&#13;
      finishSale();&#13;
    }&#13;
  }&#13;
&#13;
  function finishSale() private {&#13;
    if (wallet.getTotalInvestedEther() &lt; softCap) {&#13;
      changeState(SaleState.FAILED);&#13;
    } else {&#13;
      changeState(SaleState.SUCCEEDED);&#13;
    }&#13;
  }&#13;
&#13;
  /// @dev performs only allowed state transitions&#13;
  function changeState(SaleState _newState) private {&#13;
    require(state != _newState);&#13;
&#13;
    if (SaleState.INIT == state) {&#13;
      assert(SaleState.ACTIVE == _newState);&#13;
    } else if (SaleState.ACTIVE == state) {&#13;
      assert(&#13;
        SaleState.PAUSED == _newState ||&#13;
        SaleState.SOFT_CAP_REACHED == _newState ||&#13;
        SaleState.FAILED == _newState ||&#13;
        SaleState.SUCCEEDED == _newState&#13;
      );&#13;
    } else if (SaleState.SOFT_CAP_REACHED == state) {&#13;
      assert(&#13;
        SaleState.PAUSED == _newState ||&#13;
        SaleState.SUCCEEDED == _newState&#13;
      );&#13;
    } else if (SaleState.PAUSED == state) {&#13;
      assert(SaleState.ACTIVE == _newState || SaleState.FAILED == _newState);&#13;
    } else {&#13;
      assert(false);&#13;
    }&#13;
&#13;
    state = _newState;&#13;
    emit StateChanged(state);&#13;
&#13;
    if (SaleState.SOFT_CAP_REACHED == state) {&#13;
      onSoftCapReached();&#13;
    } else if (SaleState.SUCCEEDED == state) {&#13;
      onSuccess();&#13;
    } else if (SaleState.FAILED == state) {&#13;
      onFailure();&#13;
    }&#13;
  }&#13;
&#13;
  function onSoftCapReached() private {&#13;
    wallet.changeState(BablosCrowdsaleWalletInterface.State.SUCCEEDED);&#13;
  }&#13;
&#13;
  function onSuccess() private {&#13;
    // burn all remaining tokens&#13;
    token.burn(token.balanceOf(address(this)));&#13;
    token.thaw();&#13;
    wallet.unholdTeamTokens();&#13;
    wallet.detachController();&#13;
  }&#13;
&#13;
  function onFailure() private {&#13;
    // allow clients to get their ether back&#13;
    wallet.changeState(BablosCrowdsaleWalletInterface.State.REFUNDING);&#13;
    wallet.unholdTeamTokens();&#13;
    wallet.detachController();&#13;
  }&#13;
&#13;
  /// @dev to be overridden in tests&#13;
  function getTime() internal view returns (uint) {&#13;
    // solium-disable-next-line security/no-block-members&#13;
    return now;&#13;
  }&#13;
&#13;
}