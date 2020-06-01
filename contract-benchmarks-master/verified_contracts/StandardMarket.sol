pragma solidity ^0.4.24;


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



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  int256 constant INT256_MIN = int256((uint256(1) << 255));

  /**
  * @dev Multiplies two unsigned integers, throws on overflow.
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
  * @dev Multiplies two signed integers, throws on overflow.
  */
  function mul(int256 a, int256 b) internal pure returns (int256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert((a != -1 || b != INT256_MIN) && c / a == b);
  }

  /**
  * @dev Integer division of two unsigned integers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Integer division of two signed integers, truncating the quotient.
  */
  function div(int256 a, int256 b) internal pure returns (int256) {
    // assert(b != 0); // Solidity automatically throws when dividing by 0
    // Overflow only happens when the smallest negative int is multiplied by -1.
    assert(a != INT256_MIN || b != -1);
    return a / b;
  }

  /**
  * @dev Subtracts two unsigned integers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Subtracts two signed integers, throws on overflow.
  */
  function sub(int256 a, int256 b) internal pure returns (int256 c) {
    c = a - b;
    assert((b >= 0 && c <= a) || (b < 0 && c > a));
  }

  /**
  * @dev Adds two unsigned integers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }

  /**
  * @dev Adds two signed integers, throws on overflow.
  */
  function add(int256 a, int256 b) internal pure returns (int256 c) {
    c = a + b;
    assert((b >= 0 && c >= a) || (b < 0 && c < a));
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

/// @title Proxied - indicates that a contract will be proxied. Also defines storage requirements for Proxy.
/// @author Alan Lu - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5d3c313c331d3a33322e342e732d30">[email protected]</a>&gt;&#13;
contract Proxied {&#13;
    address public masterCopy;&#13;
}&#13;
&#13;
/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6516110003040b25020b0a160c164b1508">[email protected]</a>&gt;&#13;
contract Proxy is Proxied {&#13;
    /// @dev Constructor function sets address of master copy contract.&#13;
    /// @param _masterCopy Master copy address.&#13;
    constructor(address _masterCopy)&#13;
        public&#13;
    {&#13;
        require(_masterCopy != 0);&#13;
        masterCopy = _masterCopy;&#13;
    }&#13;
&#13;
    /// @dev Fallback function forwards all transactions and returns all received return data.&#13;
    function ()&#13;
        external&#13;
        payable&#13;
    {&#13;
        address _masterCopy = masterCopy;&#13;
        assembly {&#13;
            calldatacopy(0, 0, calldatasize())&#13;
            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)&#13;
            returndatacopy(0, 0, returndatasize())&#13;
            switch success&#13;
            case 0 { revert(0, returndatasize()) }&#13;
            default { return(0, returndatasize()) }&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
&#13;
contract OutcomeTokenProxy is Proxy {&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
&#13;
    // HACK: Lining up storage with StandardToken and OutcomeToken&#13;
    mapping(address =&gt; uint256) balances;&#13;
    uint256 totalSupply_;&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;&#13;
&#13;
    address internal eventContract;&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Constructor sets events contract address&#13;
    constructor(address proxied)&#13;
        public&#13;
        Proxy(proxied)&#13;
    {&#13;
        eventContract = msg.sender;&#13;
    }&#13;
}&#13;
&#13;
/// @title Outcome token contract - Issuing and revoking outcome tokens&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c8bbbcadaea9a688afa6a7bba1bbe6b8a5">[email protected]</a>&gt;&#13;
contract OutcomeToken is Proxied, StandardToken {&#13;
    using SafeMath for *;&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event Issuance(address indexed owner, uint amount);&#13;
    event Revocation(address indexed owner, uint amount);&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    address public eventContract;&#13;
&#13;
    /*&#13;
     *  Modifiers&#13;
     */&#13;
    modifier isEventContract () {&#13;
        // Only event contract is allowed to proceed&#13;
        require(msg.sender == eventContract);&#13;
        _;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Events contract issues new tokens for address. Returns success&#13;
    /// @param _for Address of receiver&#13;
    /// @param outcomeTokenCount Number of tokens to issue&#13;
    function issue(address _for, uint outcomeTokenCount)&#13;
        public&#13;
        isEventContract&#13;
    {&#13;
        balances[_for] = balances[_for].add(outcomeTokenCount);&#13;
        totalSupply_ = totalSupply_.add(outcomeTokenCount);&#13;
        emit Issuance(_for, outcomeTokenCount);&#13;
    }&#13;
&#13;
    /// @dev Events contract revokes tokens for address. Returns success&#13;
    /// @param _for Address of token holder&#13;
    /// @param outcomeTokenCount Number of tokens to revoke&#13;
    function revoke(address _for, uint outcomeTokenCount)&#13;
        public&#13;
        isEventContract&#13;
    {&#13;
        balances[_for] = balances[_for].sub(outcomeTokenCount);&#13;
        totalSupply_ = totalSupply_.sub(outcomeTokenCount);&#13;
        emit Revocation(_for, outcomeTokenCount);&#13;
    }&#13;
}&#13;
&#13;
/// @title Abstract oracle contract - Functions to be implemented by oracles&#13;
contract Oracle {&#13;
&#13;
    function isOutcomeSet() public view returns (bool);&#13;
    function getOutcome() public view returns (int);&#13;
}&#13;
&#13;
&#13;
contract EventData {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event OutcomeTokenCreation(OutcomeToken outcomeToken, uint8 index);&#13;
    event OutcomeTokenSetIssuance(address indexed buyer, uint collateralTokenCount);&#13;
    event OutcomeTokenSetRevocation(address indexed seller, uint outcomeTokenCount);&#13;
    event OutcomeAssignment(int outcome);&#13;
    event WinningsRedemption(address indexed receiver, uint winnings);&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    ERC20 public collateralToken;&#13;
    Oracle public oracle;&#13;
    bool public isOutcomeSet;&#13;
    int public outcome;&#13;
    OutcomeToken[] public outcomeTokens;&#13;
}&#13;
&#13;
/// @title Event contract - Provide basic functionality required by different event types&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a4d7d0c1c2c5cae4c3cacbd7cdd78ad4c9">[email protected]</a>&gt;&#13;
contract Event is EventData {&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Buys equal number of tokens of all outcomes, exchanging collateral tokens and sets of outcome tokens 1:1&#13;
    /// @param collateralTokenCount Number of collateral tokens&#13;
    function buyAllOutcomes(uint collateralTokenCount)&#13;
        public&#13;
    {&#13;
        // Transfer collateral tokens to events contract&#13;
        require(collateralToken.transferFrom(msg.sender, this, collateralTokenCount));&#13;
        // Issue new outcome tokens to sender&#13;
        for (uint8 i = 0; i &lt; outcomeTokens.length; i++)&#13;
            outcomeTokens[i].issue(msg.sender, collateralTokenCount);&#13;
        emit OutcomeTokenSetIssuance(msg.sender, collateralTokenCount);&#13;
    }&#13;
&#13;
    /// @dev Sells equal number of tokens of all outcomes, exchanging collateral tokens and sets of outcome tokens 1:1&#13;
    /// @param outcomeTokenCount Number of outcome tokens&#13;
    function sellAllOutcomes(uint outcomeTokenCount)&#13;
        public&#13;
    {&#13;
        // Revoke sender's outcome tokens of all outcomes&#13;
        for (uint8 i = 0; i &lt; outcomeTokens.length; i++)&#13;
            outcomeTokens[i].revoke(msg.sender, outcomeTokenCount);&#13;
        // Transfer collateral tokens to sender&#13;
        require(collateralToken.transfer(msg.sender, outcomeTokenCount));&#13;
        emit OutcomeTokenSetRevocation(msg.sender, outcomeTokenCount);&#13;
    }&#13;
&#13;
    /// @dev Sets winning event outcome&#13;
    function setOutcome()&#13;
        public&#13;
    {&#13;
        // Winning outcome is not set yet in event contract but in oracle contract&#13;
        require(!isOutcomeSet &amp;&amp; oracle.isOutcomeSet());&#13;
        // Set winning outcome&#13;
        outcome = oracle.getOutcome();&#13;
        isOutcomeSet = true;&#13;
        emit OutcomeAssignment(outcome);&#13;
    }&#13;
&#13;
    /// @dev Returns outcome count&#13;
    /// @return Outcome count&#13;
    function getOutcomeCount()&#13;
        public&#13;
        view&#13;
        returns (uint8)&#13;
    {&#13;
        return uint8(outcomeTokens.length);&#13;
    }&#13;
&#13;
    /// @dev Returns outcome tokens array&#13;
    /// @return Outcome tokens&#13;
    function getOutcomeTokens()&#13;
        public&#13;
        view&#13;
        returns (OutcomeToken[])&#13;
    {&#13;
        return outcomeTokens;&#13;
    }&#13;
&#13;
    /// @dev Returns the amount of outcome tokens held by owner&#13;
    /// @return Outcome token distribution&#13;
    function getOutcomeTokenDistribution(address owner)&#13;
        public&#13;
        view&#13;
        returns (uint[] outcomeTokenDistribution)&#13;
    {&#13;
        outcomeTokenDistribution = new uint[](outcomeTokens.length);&#13;
        for (uint8 i = 0; i &lt; outcomeTokenDistribution.length; i++)&#13;
            outcomeTokenDistribution[i] = outcomeTokens[i].balanceOf(owner);&#13;
    }&#13;
&#13;
    /// @dev Calculates and returns event hash&#13;
    /// @return Event hash&#13;
    function getEventHash() public view returns (bytes32);&#13;
&#13;
    /// @dev Exchanges sender's winning outcome tokens for collateral tokens&#13;
    /// @return Sender's winnings&#13;
    function redeemWinnings() public returns (uint);&#13;
}&#13;
&#13;
&#13;
/// @title Abstract market maker contract - Functions to be implemented by market maker contracts&#13;
contract MarketMaker {&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    function calcCost(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public view returns (uint);&#13;
    function calcProfit(Market market, uint8 outcomeTokenIndex, uint outcomeTokenCount) public view returns (uint);&#13;
    function calcNetCost(Market market, int[] outcomeTokenAmounts) public view returns (int);&#13;
    function calcMarginalPrice(Market market, uint8 outcomeTokenIndex) public view returns (uint);&#13;
}&#13;
&#13;
&#13;
contract MarketData {&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event MarketFunding(uint funding);&#13;
    event MarketClosing();&#13;
    event FeeWithdrawal(uint fees);&#13;
    event OutcomeTokenPurchase(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenCost, uint marketFees);&#13;
    event OutcomeTokenSale(address indexed seller, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint outcomeTokenProfit, uint marketFees);&#13;
    event OutcomeTokenShortSale(address indexed buyer, uint8 outcomeTokenIndex, uint outcomeTokenCount, uint cost);&#13;
    event OutcomeTokenTrade(address indexed transactor, int[] outcomeTokenAmounts, int outcomeTokenNetCost, uint marketFees);&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    address public creator;&#13;
    uint public createdAtBlock;&#13;
    Event public eventContract;&#13;
    MarketMaker public marketMaker;&#13;
    uint24 public fee;&#13;
    uint public funding;&#13;
    int[] public netOutcomeTokensSold;&#13;
    Stages public stage;&#13;
&#13;
    enum Stages {&#13;
        MarketCreated,&#13;
        MarketFunded,&#13;
        MarketClosed&#13;
    }&#13;
}&#13;
&#13;
/// @title Abstract market contract - Functions to be implemented by market contracts&#13;
contract Market is MarketData {&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    function fund(uint _funding) public;&#13;
    function close() public;&#13;
    function withdrawFees() public returns (uint);&#13;
    function buy(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint maxCost) public returns (uint);&#13;
    function sell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);&#13;
    function shortSell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit) public returns (uint);&#13;
    function trade(int[] outcomeTokenAmounts, int costLimit) public returns (int);&#13;
    function calcMarketFee(uint outcomeTokenCost) public view returns (uint);&#13;
}&#13;
&#13;
&#13;
contract StandardMarketData {&#13;
    /*&#13;
     *  Constants&#13;
     */&#13;
    uint24 public constant FEE_RANGE = 1000000; // 100%&#13;
}&#13;
&#13;
contract StandardMarketProxy is Proxy, MarketData, StandardMarketData {&#13;
    constructor(address proxy, address _creator, Event _eventContract, MarketMaker _marketMaker, uint24 _fee)&#13;
        Proxy(proxy)&#13;
        public&#13;
    {&#13;
        // Validate inputs&#13;
        require(address(_eventContract) != 0 &amp;&amp; address(_marketMaker) != 0 &amp;&amp; _fee &lt; FEE_RANGE);&#13;
        creator = _creator;&#13;
        createdAtBlock = block.number;&#13;
        eventContract = _eventContract;&#13;
        netOutcomeTokensSold = new int[](eventContract.getOutcomeCount());&#13;
        fee = _fee;&#13;
        marketMaker = _marketMaker;&#13;
        stage = Stages.MarketCreated;&#13;
    }&#13;
}&#13;
&#13;
/// @title Standard market contract - Backed implementation of standard markets&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1764637271767957707978647e6439677a">[email protected]</a>&gt;&#13;
contract StandardMarket is Proxied, Market, StandardMarketData {&#13;
    using SafeMath for *;&#13;
&#13;
    /*&#13;
     *  Modifiers&#13;
     */&#13;
    modifier isCreator() {&#13;
        // Only creator is allowed to proceed&#13;
        require(msg.sender == creator);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier atStage(Stages _stage) {&#13;
        // Contract has to be in given stage&#13;
        require(stage == _stage);&#13;
        _;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Allows to fund the market with collateral tokens converting them into outcome tokens&#13;
    /// @param _funding Funding amount&#13;
    function fund(uint _funding)&#13;
        public&#13;
        isCreator&#13;
        atStage(Stages.MarketCreated)&#13;
    {&#13;
        // Request collateral tokens and allow event contract to transfer them to buy all outcomes&#13;
        require(   eventContract.collateralToken().transferFrom(msg.sender, this, _funding)&#13;
                &amp;&amp; eventContract.collateralToken().approve(eventContract, _funding));&#13;
        eventContract.buyAllOutcomes(_funding);&#13;
        funding = _funding;&#13;
        stage = Stages.MarketFunded;&#13;
        emit MarketFunding(funding);&#13;
    }&#13;
&#13;
    /// @dev Allows market creator to close the markets by transferring all remaining outcome tokens to the creator&#13;
    function close()&#13;
        public&#13;
        isCreator&#13;
        atStage(Stages.MarketFunded)&#13;
    {&#13;
        uint8 outcomeCount = eventContract.getOutcomeCount();&#13;
        for (uint8 i = 0; i &lt; outcomeCount; i++)&#13;
            require(eventContract.outcomeTokens(i).transfer(creator, eventContract.outcomeTokens(i).balanceOf(this)));&#13;
        stage = Stages.MarketClosed;&#13;
        emit MarketClosing();&#13;
    }&#13;
&#13;
    /// @dev Allows market creator to withdraw fees generated by trades&#13;
    /// @return Fee amount&#13;
    function withdrawFees()&#13;
        public&#13;
        isCreator&#13;
        returns (uint fees)&#13;
    {&#13;
        fees = eventContract.collateralToken().balanceOf(this);&#13;
        // Transfer fees&#13;
        require(eventContract.collateralToken().transfer(creator, fees));&#13;
        emit FeeWithdrawal(fees);&#13;
    }&#13;
&#13;
    /// @dev Allows to buy outcome tokens from market maker&#13;
    /// @param outcomeTokenIndex Index of the outcome token to buy&#13;
    /// @param outcomeTokenCount Amount of outcome tokens to buy&#13;
    /// @param maxCost The maximum cost in collateral tokens to pay for outcome tokens&#13;
    /// @return Cost in collateral tokens&#13;
    function buy(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint maxCost)&#13;
        public&#13;
        atStage(Stages.MarketFunded)&#13;
        returns (uint cost)&#13;
    {&#13;
        require(int(outcomeTokenCount) &gt;= 0 &amp;&amp; int(maxCost) &gt; 0);&#13;
        uint8 outcomeCount = eventContract.getOutcomeCount();&#13;
        require(outcomeTokenIndex &gt;= 0 &amp;&amp; outcomeTokenIndex &lt; outcomeCount);&#13;
        int[] memory outcomeTokenAmounts = new int[](outcomeCount);&#13;
        outcomeTokenAmounts[outcomeTokenIndex] = int(outcomeTokenCount);&#13;
        (int netCost, int outcomeTokenNetCost, uint fees) = tradeImpl(outcomeCount, outcomeTokenAmounts, int(maxCost));&#13;
        require(netCost &gt;= 0 &amp;&amp; outcomeTokenNetCost &gt;= 0);&#13;
        cost = uint(netCost);&#13;
        emit OutcomeTokenPurchase(msg.sender, outcomeTokenIndex, outcomeTokenCount, uint(outcomeTokenNetCost), fees);&#13;
    }&#13;
&#13;
    /// @dev Allows to sell outcome tokens to market maker&#13;
    /// @param outcomeTokenIndex Index of the outcome token to sell&#13;
    /// @param outcomeTokenCount Amount of outcome tokens to sell&#13;
    /// @param minProfit The minimum profit in collateral tokens to earn for outcome tokens&#13;
    /// @return Profit in collateral tokens&#13;
    function sell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit)&#13;
        public&#13;
        atStage(Stages.MarketFunded)&#13;
        returns (uint profit)&#13;
    {&#13;
        require(-int(outcomeTokenCount) &lt;= 0 &amp;&amp; -int(minProfit) &lt; 0);&#13;
        uint8 outcomeCount = eventContract.getOutcomeCount();&#13;
        require(outcomeTokenIndex &gt;= 0 &amp;&amp; outcomeTokenIndex &lt; outcomeCount);&#13;
        int[] memory outcomeTokenAmounts = new int[](outcomeCount);&#13;
        outcomeTokenAmounts[outcomeTokenIndex] = -int(outcomeTokenCount);&#13;
        (int netCost, int outcomeTokenNetCost, uint fees) = tradeImpl(outcomeCount, outcomeTokenAmounts, -int(minProfit));&#13;
        require(netCost &lt;= 0 &amp;&amp; outcomeTokenNetCost &lt;= 0);&#13;
        profit = uint(-netCost);&#13;
        emit OutcomeTokenSale(msg.sender, outcomeTokenIndex, outcomeTokenCount, uint(-outcomeTokenNetCost), fees);&#13;
    }&#13;
&#13;
    /// @dev Buys all outcomes, then sells all shares of selected outcome which were bought, keeping&#13;
    ///      shares of all other outcome tokens.&#13;
    /// @param outcomeTokenIndex Index of the outcome token to short sell&#13;
    /// @param outcomeTokenCount Amount of outcome tokens to short sell&#13;
    /// @param minProfit The minimum profit in collateral tokens to earn for short sold outcome tokens&#13;
    /// @return Cost to short sell outcome in collateral tokens&#13;
    function shortSell(uint8 outcomeTokenIndex, uint outcomeTokenCount, uint minProfit)&#13;
        public&#13;
        returns (uint cost)&#13;
    {&#13;
        // Buy all outcomes&#13;
        require(   eventContract.collateralToken().transferFrom(msg.sender, this, outcomeTokenCount)&#13;
                &amp;&amp; eventContract.collateralToken().approve(eventContract, outcomeTokenCount));&#13;
        eventContract.buyAllOutcomes(outcomeTokenCount);&#13;
        // Short sell selected outcome&#13;
        eventContract.outcomeTokens(outcomeTokenIndex).approve(this, outcomeTokenCount);&#13;
        uint profit = this.sell(outcomeTokenIndex, outcomeTokenCount, minProfit);&#13;
        cost = outcomeTokenCount - profit;&#13;
        // Transfer outcome tokens to buyer&#13;
        uint8 outcomeCount = eventContract.getOutcomeCount();&#13;
        for (uint8 i = 0; i &lt; outcomeCount; i++)&#13;
            if (i != outcomeTokenIndex)&#13;
                require(eventContract.outcomeTokens(i).transfer(msg.sender, outcomeTokenCount));&#13;
        // Send change back to buyer&#13;
        require(eventContract.collateralToken().transfer(msg.sender, profit));&#13;
        emit OutcomeTokenShortSale(msg.sender, outcomeTokenIndex, outcomeTokenCount, cost);&#13;
    }&#13;
&#13;
    /// @dev Allows to trade outcome tokens and collateral with the market maker&#13;
    /// @param outcomeTokenAmounts Amounts of each outcome token to buy or sell. If positive, will buy this amount of outcome token from the market. If negative, will sell this amount back to the market instead.&#13;
    /// @param collateralLimit If positive, this is the limit for the amount of collateral tokens which will be sent to the market to conduct the trade. If negative, this is the minimum amount of collateral tokens which will be received from the market for the trade. If zero, there is no limit.&#13;
    /// @return If positive, the amount of collateral sent to the market. If negative, the amount of collateral received from the market. If zero, no collateral was sent or received.&#13;
    function trade(int[] outcomeTokenAmounts, int collateralLimit)&#13;
        public&#13;
        atStage(Stages.MarketFunded)&#13;
        returns (int netCost)&#13;
    {&#13;
        uint8 outcomeCount = eventContract.getOutcomeCount();&#13;
        require(outcomeTokenAmounts.length == outcomeCount);&#13;
&#13;
        int outcomeTokenNetCost;&#13;
        uint fees;&#13;
        (netCost, outcomeTokenNetCost, fees) = tradeImpl(outcomeCount, outcomeTokenAmounts, collateralLimit);&#13;
&#13;
        emit OutcomeTokenTrade(msg.sender, outcomeTokenAmounts, outcomeTokenNetCost, fees);&#13;
    }&#13;
&#13;
    function tradeImpl(uint8 outcomeCount, int[] outcomeTokenAmounts, int collateralLimit)&#13;
        private&#13;
        returns (int netCost, int outcomeTokenNetCost, uint fees)&#13;
    {&#13;
        // Calculate net cost for executing trade&#13;
        outcomeTokenNetCost = marketMaker.calcNetCost(this, outcomeTokenAmounts);&#13;
        if(outcomeTokenNetCost &lt; 0)&#13;
            fees = calcMarketFee(uint(-outcomeTokenNetCost));&#13;
        else&#13;
            fees = calcMarketFee(uint(outcomeTokenNetCost));&#13;
&#13;
        require(int(fees) &gt;= 0);&#13;
        netCost = outcomeTokenNetCost.add(int(fees));&#13;
&#13;
        require(&#13;
            (collateralLimit != 0 &amp;&amp; netCost &lt;= collateralLimit) ||&#13;
            collateralLimit == 0&#13;
        );&#13;
&#13;
        if(outcomeTokenNetCost &gt; 0) {&#13;
            require(&#13;
                eventContract.collateralToken().transferFrom(msg.sender, this, uint(netCost)) &amp;&amp;&#13;
                eventContract.collateralToken().approve(eventContract, uint(outcomeTokenNetCost))&#13;
            );&#13;
&#13;
            eventContract.buyAllOutcomes(uint(outcomeTokenNetCost));&#13;
        }&#13;
&#13;
        for (uint8 i = 0; i &lt; outcomeCount; i++) {&#13;
            if(outcomeTokenAmounts[i] != 0) {&#13;
                if(outcomeTokenAmounts[i] &lt; 0) {&#13;
                    require(eventContract.outcomeTokens(i).transferFrom(msg.sender, this, uint(-outcomeTokenAmounts[i])));&#13;
                } else {&#13;
                    require(eventContract.outcomeTokens(i).transfer(msg.sender, uint(outcomeTokenAmounts[i])));&#13;
                }&#13;
&#13;
                netOutcomeTokensSold[i] = netOutcomeTokensSold[i].add(outcomeTokenAmounts[i]);&#13;
            }&#13;
        }&#13;
&#13;
        if(outcomeTokenNetCost &lt; 0) {&#13;
            // This is safe since&#13;
            // 0x8000000000000000000000000000000000000000000000000000000000000000 ==&#13;
            // uint(-int(-0x8000000000000000000000000000000000000000000000000000000000000000))&#13;
            eventContract.sellAllOutcomes(uint(-outcomeTokenNetCost));&#13;
            if(netCost &lt; 0) {&#13;
                require(eventContract.collateralToken().transfer(msg.sender, uint(-netCost)));&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Calculates fee to be paid to market maker&#13;
    /// @param outcomeTokenCost Cost for buying outcome tokens&#13;
    /// @return Fee for trade&#13;
    function calcMarketFee(uint outcomeTokenCost)&#13;
        public&#13;
        view&#13;
        returns (uint)&#13;
    {&#13;
        return outcomeTokenCost * fee / FEE_RANGE;&#13;
    }&#13;
}