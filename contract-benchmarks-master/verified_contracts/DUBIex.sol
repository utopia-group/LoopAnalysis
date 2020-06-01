pragma solidity 0.4.18;


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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
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
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="3042555d535f7002">[email protected]</span>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private reentrancy_lock = false;&#13;
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
    require(!reentrancy_lock);&#13;
    reentrancy_lock = true;&#13;
    _;&#13;
    reentrancy_lock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
library Utils {&#13;
  function isEther(address addr) internal pure returns (bool) {&#13;
    return addr == address(0x0);&#13;
  }&#13;
}&#13;
&#13;
&#13;
contract DUBIex is ReentrancyGuard {&#13;
  using SafeMath for uint256;&#13;
  using SafeERC20 for ERC20;&#13;
  &#13;
  // order&#13;
  struct Order {&#13;
    uint256 id;&#13;
    address maker;&#13;
    uint256 amount;&#13;
    address pairA;&#13;
    address pairB;&#13;
    uint256 priceA;&#13;
    uint256 priceB;&#13;
  }&#13;
&#13;
  // order id -&gt; order&#13;
  mapping(uint256 =&gt; Order) public orders;&#13;
&#13;
  // weiSend of current tx&#13;
  uint256 private weiSend = 0;&#13;
&#13;
  // makes sure weiSend of current tx is reset&#13;
  modifier weiSendGuard() {&#13;
    weiSend = msg.value;&#13;
    _;&#13;
    weiSend = 0;&#13;
  }&#13;
&#13;
  // logs&#13;
  event LogMakeOrder(uint256 id, address indexed maker, uint256 amount, address indexed pairA, address indexed pairB, uint256 priceA, uint256 priceB);&#13;
  event LogTakeOrder(uint256 indexed id, address indexed taker, uint256 amount);&#13;
  event LogCancelOrder(uint256 indexed id);&#13;
&#13;
  // internal&#13;
  function _makeOrder(uint256 id, uint256 amount, address pairA, address pairB, uint256 priceA, uint256 priceB, address maker) internal returns (bool) {&#13;
    // validate input&#13;
    if (&#13;
      id &lt;= 0 ||&#13;
      amount &lt;= 0 ||&#13;
      pairA == pairB ||&#13;
      priceA &lt;= 0 ||&#13;
      priceB &lt;= 0 ||&#13;
      orders[id].id == id&#13;
    ) return false;&#13;
&#13;
    bool pairAisEther = Utils.isEther(pairA);&#13;
    ERC20 tokenA = ERC20(pairA);&#13;
&#13;
    // validate maker's deposit&#13;
    if (pairAisEther &amp;&amp; (weiSend &lt;= 0 || weiSend &lt; amount)) return false;&#13;
    else if (!pairAisEther &amp;&amp; (tokenA.allowance(maker, this) &lt; amount || tokenA.balanceOf(maker) &lt; amount)) return false;&#13;
&#13;
    // update state&#13;
    orders[id] = Order(id, maker, amount, pairA, pairB, priceA, priceB);&#13;
&#13;
    // retrieve makers amount&#13;
    if (pairAisEther) {&#13;
      // eth already received, subtract used wei&#13;
      weiSend = weiSend.sub(amount);&#13;
    } else {&#13;
      // pull tokens&#13;
      tokenA.safeTransferFrom(maker, this, amount);&#13;
    }&#13;
&#13;
    LogMakeOrder(id, maker, amount, pairA, pairB, priceA, priceB);&#13;
&#13;
    return true;&#13;
  }&#13;
&#13;
  function _takeOrder(uint256 id, uint256 amount, address taker) internal returns (bool) {&#13;
    // validate inputs&#13;
    if (&#13;
      id &lt;= 0 ||&#13;
      amount &lt;= 0&#13;
    ) return false;&#13;
    &#13;
    // get order&#13;
    Order storage order = orders[id];&#13;
    // validate order&#13;
    if (order.id != id) return false;&#13;
    &#13;
    bool pairAisEther = Utils.isEther(order.pairA);&#13;
    bool pairBisEther = Utils.isEther(order.pairB);&#13;
    // amount of pairA usable&#13;
    uint256 usableAmount = amount &gt; order.amount ? order.amount : amount;&#13;
    // amount of pairB maker will receive&#13;
    uint256 totalB = usableAmount.mul(order.priceB).div(order.priceA);&#13;
&#13;
    // token interfaces&#13;
    ERC20 tokenA = ERC20(order.pairA);&#13;
    ERC20 tokenB = ERC20(order.pairB);&#13;
&#13;
    // validate taker's deposit&#13;
    if (pairBisEther &amp;&amp; (weiSend &lt;= 0 || weiSend &lt; totalB)) return false;&#13;
    else if (!pairBisEther &amp;&amp; (tokenB.allowance(taker, this) &lt; totalB || tokenB.balanceOf(taker) &lt; amount)) return false;&#13;
&#13;
    // update state&#13;
    order.amount = order.amount.sub(usableAmount);&#13;
&#13;
    // pay maker&#13;
    if (pairBisEther) {&#13;
      weiSend = weiSend.sub(totalB);&#13;
      order.maker.transfer(totalB);&#13;
    } else {&#13;
      tokenB.safeTransferFrom(taker, order.maker, totalB);&#13;
    }&#13;
&#13;
    // pay taker&#13;
    if (pairAisEther) {&#13;
      taker.transfer(usableAmount);&#13;
    } else {&#13;
      tokenA.safeTransfer(taker, usableAmount);&#13;
    }&#13;
&#13;
    LogTakeOrder(id, taker, usableAmount);&#13;
&#13;
    return true;&#13;
  }&#13;
&#13;
  function _cancelOrder(uint256 id, address maker) internal returns (bool) {&#13;
    // validate inputs&#13;
    if (id &lt;= 0) return false;&#13;
&#13;
    // get order&#13;
    Order storage order = orders[id];&#13;
    if (&#13;
      order.id != id ||&#13;
      order.maker != maker&#13;
    ) return false;&#13;
&#13;
    uint256 amount = order.amount;&#13;
    bool pairAisEther = Utils.isEther(order.pairA);&#13;
&#13;
    // update state&#13;
    order.amount = 0;&#13;
&#13;
    // actions&#13;
    if (pairAisEther) {&#13;
      order.maker.transfer(amount);&#13;
    } else {&#13;
      ERC20(order.pairA).safeTransfer(order.maker, amount);&#13;
    }&#13;
&#13;
    LogCancelOrder(id);&#13;
&#13;
    return true;&#13;
  }&#13;
&#13;
  // single&#13;
  function makeOrder(uint256 id, uint256 amount, address pairA, address pairB, uint256 priceA, uint256 priceB) external payable weiSendGuard nonReentrant returns (bool) {&#13;
    bool success = _makeOrder(id, amount, pairA, pairB, priceA, priceB, msg.sender);&#13;
&#13;
    if (weiSend &gt; 0) msg.sender.transfer(weiSend);&#13;
&#13;
    return success;&#13;
  }&#13;
&#13;
  function takeOrder(uint256 id, uint256 amount) external payable weiSendGuard nonReentrant returns (bool) {&#13;
    bool success = _takeOrder(id, amount, msg.sender);&#13;
&#13;
    if (weiSend &gt; 0) msg.sender.transfer(weiSend);&#13;
&#13;
    return success;&#13;
  }&#13;
&#13;
  function cancelOrder(uint256 id) external nonReentrant returns (bool) {&#13;
    return _cancelOrder(id, msg.sender);&#13;
  }&#13;
&#13;
  // multi&#13;
  function makeOrders(uint256[] ids, uint256[] amounts, address[] pairAs, address[] pairBs, uint256[] priceAs, uint256[] priceBs) external payable weiSendGuard nonReentrant returns (bool) {&#13;
    require(&#13;
      amounts.length == ids.length &amp;&amp;&#13;
      pairAs.length == ids.length &amp;&amp;&#13;
      pairBs.length == ids.length &amp;&amp;&#13;
      priceAs.length == ids.length &amp;&amp;&#13;
      priceBs.length == ids.length&#13;
    );&#13;
&#13;
    bool allSuccess = true;&#13;
&#13;
    for (uint256 i = 0; i &lt; ids.length; i++) {&#13;
      // update if any of the orders failed&#13;
      // the function is like this because "stack too deep" error&#13;
      if (allSuccess &amp;&amp; !_makeOrder(ids[i], amounts[i], pairAs[i], pairBs[i], priceAs[i], priceBs[i], msg.sender)) allSuccess = false;&#13;
    }&#13;
&#13;
    if (weiSend &gt; 0) msg.sender.transfer(weiSend);&#13;
&#13;
    return allSuccess;&#13;
  }&#13;
&#13;
  function takeOrders(uint256[] ids, uint256[] amounts) external payable weiSendGuard nonReentrant returns (bool) {&#13;
    require(ids.length == amounts.length);&#13;
&#13;
    bool allSuccess = true;&#13;
&#13;
    for (uint256 i = 0; i &lt; ids.length; i++) {&#13;
      bool success = _takeOrder(ids[i], amounts[i], msg.sender);&#13;
&#13;
      // update if any of the orders failed&#13;
      if (allSuccess &amp;&amp; !success) allSuccess = success;&#13;
    }&#13;
&#13;
    if (weiSend &gt; 0) msg.sender.transfer(weiSend);&#13;
&#13;
    return allSuccess;&#13;
  }&#13;
&#13;
  function cancelOrders(uint256[] ids) external nonReentrant returns (bool) {&#13;
    bool allSuccess = true;&#13;
&#13;
    for (uint256 i = 0; i &lt; ids.length; i++) {&#13;
      bool success = _cancelOrder(ids[i], msg.sender);&#13;
&#13;
      // update if any of the orders failed&#13;
      if (allSuccess &amp;&amp; !success) allSuccess = success;&#13;
    }&#13;
&#13;
    return allSuccess;&#13;
  }&#13;
}