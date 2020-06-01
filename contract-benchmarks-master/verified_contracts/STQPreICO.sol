pragma solidity 0.4.15;



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



/*
 * @title This is proxy for analytics. Target contract can be found at field m_analytics (see "read contract").
 * @author Eenae

 * FIXME after fix of truffle issue #560: refactor to a separate contract file which uses InvestmentAnalytics interface
 */
contract AnalyticProxy {

    function AnalyticProxy() {
        m_analytics = InvestmentAnalytics(msg.sender);
    }

    /// @notice forward payment to analytics-capable contract
    function() payable {
        m_analytics.iaInvestedBy.value(msg.value)(msg.sender);
    }

    InvestmentAnalytics public m_analytics;
}


/*
 * @title Mixin contract which supports different payment channels and provides analytical per-channel data.
 * @author Eenae
 */
contract InvestmentAnalytics {
    using SafeMath for uint256;

    function InvestmentAnalytics(){
    }

    /// @dev creates more payment channels, up to the limit but not exceeding gas stipend
    function createMorePaymentChannelsInternal(uint limit) internal returns (uint) {
        uint paymentChannelsCreated;
        for (uint i = 0; i < limit; i++) {
            uint startingGas = msg.gas;
            /*
             * ~170k of gas per paymentChannel,
             * using gas price = 4Gwei 2k paymentChannels will cost ~1.4 ETH.
             */

            address paymentChannel = new AnalyticProxy();
            m_validPaymentChannels[paymentChannel] = true;
            m_paymentChannels.push(paymentChannel);
            paymentChannelsCreated++;

            // cost of creating one channel
            uint gasPerChannel = startingGas.sub(msg.gas);
            if (gasPerChannel.add(50000) > msg.gas)
                break;  // enough proxies for this call
        }
        return paymentChannelsCreated;
    }


    /// @dev process payments - record analytics and pass control to iaOnInvested callback
    function iaInvestedBy(address investor) external payable {
        address paymentChannel = msg.sender;
        if (m_validPaymentChannels[paymentChannel]) {
            // payment received by one of our channels
            uint value = msg.value;
            m_investmentsByPaymentChannel[paymentChannel] = m_investmentsByPaymentChannel[paymentChannel].add(value);
            // We know for sure that investment came from specified investor (see AnalyticProxy).
            iaOnInvested(investor, value, true);
        } else {
            // Looks like some user has paid to this method, this payment is not included in the analytics,
            // but, of course, processed.
            iaOnInvested(msg.sender, msg.value, false);
        }
    }

    /// @dev callback
    function iaOnInvested(address investor, uint payment, bool usingPaymentChannel) internal {
    }


    function paymentChannelsCount() external constant returns (uint) {
        return m_paymentChannels.length;
    }

    function readAnalyticsMap() external constant returns (address[], uint[]) {
        address[] memory keys = new address[](m_paymentChannels.length);
        uint[] memory values = new uint[](m_paymentChannels.length);

        for (uint i = 0; i < m_paymentChannels.length; i++) {
            address key = m_paymentChannels[i];
            keys[i] = key;
            values[i] = m_investmentsByPaymentChannel[key];
        }

        return (keys, values);
    }

    function readPaymentChannels() external constant returns (address[]) {
        return m_paymentChannels;
    }


    mapping(address => uint256) public m_investmentsByPaymentChannel;
    mapping(address => bool) m_validPaymentChannels;

    address[] public m_paymentChannels;
}

/**
 * @title Helps contracts guard agains rentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="087a6d656b67483a">[email protected]</a>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private rentrancy_lock = false;&#13;
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
    require(!rentrancy_lock);&#13;
    rentrancy_lock = true;&#13;
    _;&#13;
    rentrancy_lock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  function Ownable() {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) onlyOwner {&#13;
    if (newOwner != address(0)) {&#13;
      owner = newOwner;&#13;
    }&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
contract STQToken {&#13;
    function mint(address _to, uint256 _amount) external;&#13;
}&#13;
&#13;
/// @title Storiqa pre-ICO contract&#13;
contract STQPreICO is Ownable, ReentrancyGuard, InvestmentAnalytics {&#13;
    using SafeMath for uint256;&#13;
&#13;
    event FundTransfer(address backer, uint amount, bool isContribution);&#13;
&#13;
    function STQPreICO(address token, address funds) {&#13;
        require(address(0) != address(token) &amp;&amp; address(0) != address(funds));&#13;
&#13;
        m_token = STQToken(token);&#13;
        m_funds = funds;&#13;
    }&#13;
&#13;
&#13;
    // PUBLIC interface: payments&#13;
&#13;
    // fallback function as a shortcut&#13;
    function() payable {&#13;
        require(0 == msg.data.length);&#13;
        buy();  // only internal call here!&#13;
    }&#13;
&#13;
    /// @notice ICO participation&#13;
    function buy() public payable {     // dont mark as external!&#13;
        iaOnInvested(msg.sender, msg.value, false);&#13;
    }&#13;
&#13;
&#13;
    // PUBLIC interface: maintenance&#13;
&#13;
    function createMorePaymentChannels(uint limit) external onlyOwner returns (uint) {&#13;
        return createMorePaymentChannelsInternal(limit);&#13;
    }&#13;
&#13;
    /// @notice Tests ownership of the current caller.&#13;
    /// @return true if it's an owner&#13;
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to&#13;
    // addOwner/changeOwner and to isOwner.&#13;
    function amIOwner() external constant onlyOwner returns (bool) {&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    // INTERNAL&#13;
&#13;
    /// @dev payment callback&#13;
    function iaOnInvested(address investor, uint payment, bool usingPaymentChannel)&#13;
        internal&#13;
        nonReentrant&#13;
    {&#13;
        require(payment &gt;= c_MinInvestment);&#13;
        require(getCurrentTime() &gt;= c_startTime &amp;&amp; getCurrentTime() &lt; c_endTime || msg.sender == owner);&#13;
&#13;
        uint startingInvariant = this.balance.add(m_funds.balance);&#13;
&#13;
        // return or update payment if needed&#13;
        uint paymentAllowed = getMaximumFunds().sub(m_totalInvested);&#13;
        if (0 == paymentAllowed) {&#13;
            investor.transfer(payment);&#13;
            return;&#13;
        }&#13;
        uint change;&#13;
        if (paymentAllowed &lt; payment) {&#13;
            change = payment.sub(paymentAllowed);&#13;
            payment = paymentAllowed;&#13;
        }&#13;
&#13;
        // calculate rate&#13;
        uint bonusPercent = c_preICOBonusPercent;&#13;
        bonusPercent += getLargePaymentBonus(payment);&#13;
        if (usingPaymentChannel)&#13;
            bonusPercent += c_paymentChannelBonusPercent;&#13;
&#13;
        uint rate = c_STQperETH.mul(100 + bonusPercent).div(100);&#13;
&#13;
        // issue tokens&#13;
        uint stq = payment.mul(rate);&#13;
        m_token.mint(investor, stq);&#13;
&#13;
        // record payment&#13;
        m_funds.transfer(payment);&#13;
        m_totalInvested = m_totalInvested.add(payment);&#13;
        assert(m_totalInvested &lt;= getMaximumFunds());&#13;
        FundTransfer(investor, payment, true);&#13;
&#13;
        if (change &gt; 0)&#13;
            investor.transfer(change);&#13;
&#13;
        assert(startingInvariant == this.balance.add(m_funds.balance).add(change));&#13;
    }&#13;
&#13;
    function getLargePaymentBonus(uint payment) private constant returns (uint) {&#13;
        if (payment &gt; 1000 ether) return 10;&#13;
        if (payment &gt; 800 ether) return 8;&#13;
        if (payment &gt; 500 ether) return 5;&#13;
        if (payment &gt; 200 ether) return 2;&#13;
        return 0;&#13;
    }&#13;
&#13;
    /// @dev to be overridden in tests&#13;
    function getCurrentTime() internal constant returns (uint) {&#13;
        return now;&#13;
    }&#13;
&#13;
    /// @dev to be overridden in tests&#13;
    function getMaximumFunds() internal constant returns (uint) {&#13;
        return c_MaximumFunds;&#13;
    }&#13;
&#13;
&#13;
    // FIELDS&#13;
&#13;
    /// @notice start time of the pre-ICO&#13;
    uint public constant c_startTime = 1507766400;&#13;
&#13;
    /// @notice end time of the pre-ICO&#13;
    uint public constant c_endTime = c_startTime + (1 days);&#13;
&#13;
    /// @notice minimum investment&#13;
    uint public constant c_MinInvestment = 10 finney;&#13;
&#13;
    /// @notice maximum investments to be accepted during pre-ICO&#13;
    uint public constant c_MaximumFunds = 8000 ether;&#13;
&#13;
&#13;
    /// @notice starting exchange rate of STQ&#13;
    uint public constant c_STQperETH = 100000;&#13;
&#13;
    /// @notice pre-ICO bonus&#13;
    uint public constant c_preICOBonusPercent = 40;&#13;
&#13;
    /// @notice authorised payment bonus&#13;
    uint public constant c_paymentChannelBonusPercent = 2;&#13;
&#13;
&#13;
    /// @dev total investments amount&#13;
    uint public m_totalInvested;&#13;
&#13;
    /// @dev contract responsible for token accounting&#13;
    STQToken public m_token;&#13;
&#13;
    /// @dev address responsible for investments accounting&#13;
    address public m_funds;&#13;
}