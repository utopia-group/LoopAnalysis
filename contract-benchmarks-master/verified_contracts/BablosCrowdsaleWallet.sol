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
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3d4f58505e527d0f">[email protected]</a>π.com&gt;&#13;
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
contract BablosCrowdsaleWallet is BablosCrowdsaleWalletInterface, Ownable, ReentrancyGuard {&#13;
  using SafeMath for uint;&#13;
&#13;
  modifier requiresState(State _state) {&#13;
    require(state == _state);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier onlyController() {&#13;
    require(msg.sender == controller);&#13;
    _;&#13;
  }&#13;
  &#13;
  constructor(&#13;
    BablosTokenInterface _token, &#13;
    address _controller, &#13;
    PriceUpdaterInterface _priceUpdater, &#13;
    uint _teamPercent, &#13;
    uint _prTokens) &#13;
      public &#13;
  {&#13;
    token = _token;&#13;
    controller = _controller;&#13;
    priceUpdater = _priceUpdater;&#13;
    teamPercent = _teamPercent;&#13;
    prTokens = _prTokens;&#13;
  }&#13;
&#13;
  function getTotalInvestedEther() external view returns (uint) {&#13;
    uint etherPrice = priceUpdater.price(uint(PriceUpdaterInterface.Currency.ETH));&#13;
    uint totalInvestedEth = totalInvested[uint(PriceUpdaterInterface.Currency.ETH)];&#13;
    uint totalAmount = _totalInvestedNonEther();&#13;
    return totalAmount.mul(1 ether).div(etherPrice).add(totalInvestedEth);&#13;
  }&#13;
&#13;
  function getTotalInvestedEur() external view returns (uint) {&#13;
    uint totalAmount = _totalInvestedNonEther();&#13;
    uint etherAmount = totalInvested[uint(PriceUpdaterInterface.Currency.ETH)]&#13;
      .mul(priceUpdater.price(uint(PriceUpdaterInterface.Currency.ETH)))&#13;
      .div(1 ether);&#13;
    return totalAmount.add(etherAmount);&#13;
  }&#13;
&#13;
  /// @dev total invested in EUR within ETH amount&#13;
  function _totalInvestedNonEther() internal view returns (uint) {&#13;
    uint totalAmount;&#13;
    uint precision = priceUpdater.decimalPrecision();&#13;
    // BTC&#13;
    uint btcAmount = totalInvested[uint(PriceUpdaterInterface.Currency.BTC)]&#13;
      .mul(10 ** precision)&#13;
      .div(priceUpdater.price(uint(PriceUpdaterInterface.Currency.BTC)));&#13;
    totalAmount = totalAmount.add(btcAmount);&#13;
    // WME&#13;
    uint wmeAmount = totalInvested[uint(PriceUpdaterInterface.Currency.WME)]&#13;
      .mul(10 ** precision)&#13;
      .div(priceUpdater.price(uint(PriceUpdaterInterface.Currency.WME)));&#13;
    totalAmount = totalAmount.add(wmeAmount);&#13;
    // WMZ&#13;
    uint wmzAmount = totalInvested[uint(PriceUpdaterInterface.Currency.WMZ)]&#13;
      .mul(10 ** precision)&#13;
      .div(priceUpdater.price(uint(PriceUpdaterInterface.Currency.WMZ)));&#13;
    totalAmount = totalAmount.add(wmzAmount);&#13;
    // WMR&#13;
    uint wmrAmount = totalInvested[uint(PriceUpdaterInterface.Currency.WMR)]&#13;
      .mul(10 ** precision)&#13;
      .div(priceUpdater.price(uint(PriceUpdaterInterface.Currency.WMR)));&#13;
    totalAmount = totalAmount.add(wmrAmount);&#13;
    // WMX&#13;
    uint wmxAmount = totalInvested[uint(PriceUpdaterInterface.Currency.WMX)]&#13;
      .mul(10 ** precision)&#13;
      .div(priceUpdater.price(uint(PriceUpdaterInterface.Currency.WMX)));&#13;
    totalAmount = totalAmount.add(wmxAmount);&#13;
    return totalAmount;&#13;
  }&#13;
&#13;
  function changeState(State _newState) external onlyController {&#13;
    assert(state != _newState);&#13;
&#13;
    if (State.GATHERING == state) {&#13;
      assert(_newState == State.REFUNDING || _newState == State.SUCCEEDED);&#13;
    } else {&#13;
      assert(false);&#13;
    }&#13;
&#13;
    state = _newState;&#13;
    emit StateChanged(state);&#13;
  }&#13;
&#13;
  function invested(&#13;
    address _investor,&#13;
    uint _tokenAmount,&#13;
    PriceUpdaterInterface.Currency _currency,&#13;
    uint _amount) &#13;
      external &#13;
      payable&#13;
      onlyController&#13;
  {&#13;
    require(state == State.GATHERING || state == State.SUCCEEDED);&#13;
    uint amount;&#13;
    if (_currency == PriceUpdaterInterface.Currency.ETH) {&#13;
      amount = msg.value;&#13;
      weiBalances[_investor] = weiBalances[_investor].add(amount);&#13;
    } else {&#13;
      amount = _amount;&#13;
    }&#13;
    require(amount != 0);&#13;
    require(_tokenAmount != 0);&#13;
    assert(_investor != controller);&#13;
&#13;
    // register investor&#13;
    if (tokenBalances[_investor] == 0) {&#13;
      investors.push(_investor);&#13;
    }&#13;
&#13;
    // register payment&#13;
    totalInvested[uint(_currency)] = totalInvested[uint(_currency)].add(amount);&#13;
    tokenBalances[_investor] = tokenBalances[_investor].add(_tokenAmount);&#13;
&#13;
    emit Invested(_investor, _currency, amount, _tokenAmount);&#13;
  }&#13;
&#13;
  function withdrawEther(uint _value)&#13;
    external&#13;
    onlyOwner&#13;
    requiresState(State.SUCCEEDED) &#13;
  {&#13;
    require(_value &gt; 0 &amp;&amp; address(this).balance &gt;= _value);&#13;
    owner.transfer(_value);&#13;
    emit EtherWithdrawan(owner, _value);&#13;
  }&#13;
&#13;
  function withdrawTokens(uint _value)&#13;
    external&#13;
    onlyOwner&#13;
    requiresState(State.REFUNDING)&#13;
  {&#13;
    require(_value &gt; 0 &amp;&amp; token.balanceOf(address(this)) &gt;= _value);&#13;
    token.transfer(owner, _value);&#13;
  }&#13;
&#13;
  function withdrawPayments()&#13;
    external&#13;
    nonReentrant&#13;
    requiresState(State.REFUNDING)&#13;
  {&#13;
    address payee = msg.sender;&#13;
    uint payment = weiBalances[payee];&#13;
    uint tokens = tokenBalances[payee];&#13;
&#13;
    // check that there is some ether to withdraw&#13;
    require(payment != 0);&#13;
    // check that the contract holds enough ether&#13;
    require(address(this).balance &gt;= payment);&#13;
    // check that the investor (payee) gives back all tokens bought during ICO&#13;
    require(token.allowance(payee, address(this)) &gt;= tokenBalances[payee]);&#13;
&#13;
    totalInvested[uint(PriceUpdaterInterface.Currency.ETH)] = totalInvested[uint(PriceUpdaterInterface.Currency.ETH)].sub(payment);&#13;
    weiBalances[payee] = 0;&#13;
    tokenBalances[payee] = 0;&#13;
&#13;
    token.transferFrom(payee, address(this), tokens);&#13;
&#13;
    payee.transfer(payment);&#13;
    emit RefundSent(payee, payment);&#13;
  }&#13;
&#13;
  function getInvestorsCount() external view returns (uint) { return investors.length; }&#13;
&#13;
  function detachController() external onlyController {&#13;
    address was = controller;&#13;
    controller = address(0);&#13;
    emit ControllerRetired(was);&#13;
  }&#13;
&#13;
  function unholdTeamTokens() external onlyController {&#13;
    uint tokens = token.balanceOf(address(this));&#13;
    if (state == State.SUCCEEDED) {&#13;
      uint soldTokens = token.totalSupply().sub(token.balanceOf(address(this))).sub(prTokens);&#13;
      uint soldPecent = 100 - teamPercent;&#13;
      uint teamShares = soldTokens.mul(teamPercent).div(soldPecent).sub(prTokens);&#13;
      token.transfer(owner, teamShares);&#13;
      token.burn(token.balanceOf(address(this)));&#13;
    } else {&#13;
      token.approve(owner, tokens);&#13;
    }&#13;
  }&#13;
}