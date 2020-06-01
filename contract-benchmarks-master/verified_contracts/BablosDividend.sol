pragma solidity ^0.4.23;

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
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="96e4f3fbf5f9d6a4">[email protected]</a>π.com&gt;&#13;
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
contract DividendInterface {&#13;
  function putProfit() public payable;&#13;
  function dividendBalanceOf(address _account) public view returns (uint256);&#13;
  function hasDividends() public view returns (bool);&#13;
  function claimDividends() public returns (uint256);&#13;
  function claimedDividendsOf(address _account) public view returns (uint256);&#13;
  function saveUnclaimedDividends(address _account) public;&#13;
}&#13;
&#13;
contract BasicDividend is DividendInterface, ReentrancyGuard, Ownable {&#13;
  using SafeMath for uint256;&#13;
&#13;
  event Dividends(uint256 amount);&#13;
  event DividendsClaimed(address claimer, uint256 amount);&#13;
&#13;
  uint256 public totalDividends;&#13;
  mapping (address =&gt; uint256) public lastDividends;&#13;
  mapping (address =&gt; uint256) public unclaimedDividends;&#13;
  mapping (address =&gt; uint256) public claimedDividends;&#13;
  ERC20 public token;&#13;
&#13;
  modifier onlyToken() {&#13;
    require(msg.sender == address(token));&#13;
    _;&#13;
  }&#13;
&#13;
  constructor(ERC20 _token) public {&#13;
    token = _token;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev fallback payment function&#13;
   */&#13;
  function () external payable {&#13;
    putProfit();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev on every ether transaction totalDividends is incremented by amount&#13;
   */&#13;
  function putProfit() public nonReentrant onlyOwner payable {&#13;
    totalDividends = totalDividends.add(msg.value);&#13;
    emit Dividends(msg.value);&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the unclaimed dividends balance of the specified address.&#13;
  * @param _account The address to query the the dividends balance of.&#13;
  * @return An uint256 representing the amount of dividends owned by the passed address.&#13;
  */&#13;
  function dividendBalanceOf(address _account) public view returns (uint256) {&#13;
    uint256 accountBalance = token.balanceOf(_account);&#13;
    uint256 totalSupply = token.totalSupply();&#13;
    uint256 newDividends = totalDividends.sub(lastDividends[_account]);&#13;
    uint256 product = accountBalance.mul(newDividends);&#13;
    return product.div(totalSupply) + unclaimedDividends[_account];&#13;
  }&#13;
&#13;
  function claimedDividendsOf(address _account) public view returns (uint256) {&#13;
    return claimedDividends[_account];&#13;
  }&#13;
&#13;
  function hasDividends() public view returns (bool) {&#13;
    return totalDividends &gt; 0 &amp;&amp; address(this).balance &gt; 0;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev claim dividends&#13;
  */&#13;
  function claimDividends() public nonReentrant returns (uint256) {&#13;
    require(address(this).balance &gt; 0);&#13;
    uint256 dividends = dividendBalanceOf(msg.sender);&#13;
    require(dividends &gt; 0);&#13;
    lastDividends[msg.sender] = totalDividends;&#13;
    unclaimedDividends[msg.sender] = 0;&#13;
    claimedDividends[msg.sender] = claimedDividends[msg.sender].add(dividends);&#13;
    msg.sender.transfer(dividends);&#13;
    emit DividendsClaimed(msg.sender, dividends);&#13;
    return dividends;&#13;
  }&#13;
&#13;
  function saveUnclaimedDividends(address _account) public onlyToken {&#13;
    if (totalDividends &gt; lastDividends[_account]) {&#13;
      unclaimedDividends[_account] = dividendBalanceOf(_account);&#13;
      lastDividends[_account] = totalDividends;&#13;
    }&#13;
  }&#13;
}&#13;
&#13;
contract BablosDividend is BasicDividend {&#13;
&#13;
  constructor(ERC20 _token) public BasicDividend(_token) {&#13;
&#13;
  }&#13;
&#13;
}