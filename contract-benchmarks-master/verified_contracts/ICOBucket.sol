pragma solidity ^0.4.25;

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

/// @title Role based access control mixin for Rasmart Platform
/// @author Abha Mai <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="214c404840434940191361464c40484d0f424e4c">[email protected]</a>&gt;&#13;
/// @dev Ignore DRY approach to achieve readability&#13;
contract RBACMixin {&#13;
  /// @notice Constant string message to throw on lack of access&#13;
  string constant FORBIDDEN = "Haven't enough right to access";&#13;
  /// @notice Public map of owners&#13;
  mapping (address =&gt; bool) public owners;&#13;
  /// @notice Public map of minters&#13;
  mapping (address =&gt; bool) public minters;&#13;
&#13;
  /// @notice The event indicates the addition of a new owner&#13;
  /// @param who is address of added owner&#13;
  event AddOwner(address indexed who);&#13;
  /// @notice The event indicates the deletion of an owner&#13;
  /// @param who is address of deleted owner&#13;
  event DeleteOwner(address indexed who);&#13;
&#13;
  /// @notice The event indicates the addition of a new minter&#13;
  /// @param who is address of added minter&#13;
  event AddMinter(address indexed who);&#13;
  /// @notice The event indicates the deletion of a minter&#13;
  /// @param who is address of deleted minter&#13;
  event DeleteMinter(address indexed who);&#13;
&#13;
  constructor () public {&#13;
    _setOwner(msg.sender, true);&#13;
  }&#13;
&#13;
  /// @notice The functional modifier rejects the interaction of senders who are not owners&#13;
  modifier onlyOwner() {&#13;
    require(isOwner(msg.sender), FORBIDDEN);&#13;
    _;&#13;
  }&#13;
&#13;
  /// @notice Functional modifier for rejecting the interaction of senders that are not minters&#13;
  modifier onlyMinter() {&#13;
    require(isMinter(msg.sender), FORBIDDEN);&#13;
    _;&#13;
  }&#13;
&#13;
  /// @notice Look up for the owner role on providen address&#13;
  /// @param _who is address to look up&#13;
  /// @return A boolean of owner role&#13;
  function isOwner(address _who) public view returns (bool) {&#13;
    return owners[_who];&#13;
  }&#13;
&#13;
  /// @notice Look up for the minter role on providen address&#13;
  /// @param _who is address to look up&#13;
  /// @return A boolean of minter role&#13;
  function isMinter(address _who) public view returns (bool) {&#13;
    return minters[_who];&#13;
  }&#13;
&#13;
  /// @notice Adds the owner role to provided address&#13;
  /// @dev Requires owner role to interact&#13;
  /// @param _who is address to add role&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function addOwner(address _who) public onlyOwner returns (bool) {&#13;
    _setOwner(_who, true);&#13;
  }&#13;
&#13;
  /// @notice Deletes the owner role to provided address&#13;
  /// @dev Requires owner role to interact&#13;
  /// @param _who is address to delete role&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function deleteOwner(address _who) public onlyOwner returns (bool) {&#13;
    _setOwner(_who, false);&#13;
  }&#13;
&#13;
  /// @notice Adds the minter role to provided address&#13;
  /// @dev Requires owner role to interact&#13;
  /// @param _who is address to add role&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function addMinter(address _who) public onlyOwner returns (bool) {&#13;
    _setMinter(_who, true);&#13;
  }&#13;
&#13;
  /// @notice Deletes the minter role to provided address&#13;
  /// @dev Requires owner role to interact&#13;
  /// @param _who is address to delete role&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function deleteMinter(address _who) public onlyOwner returns (bool) {&#13;
    _setMinter(_who, false);&#13;
  }&#13;
&#13;
  /// @notice Changes the owner role to provided address&#13;
  /// @param _who is address to change role&#13;
  /// @param _flag is next role status after success&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function _setOwner(address _who, bool _flag) private returns (bool) {&#13;
    require(owners[_who] != _flag);&#13;
    owners[_who] = _flag;&#13;
    if (_flag) {&#13;
      emit AddOwner(_who);&#13;
    } else {&#13;
      emit DeleteOwner(_who);&#13;
    }&#13;
    return true;&#13;
  }&#13;
&#13;
  /// @notice Changes the minter role to provided address&#13;
  /// @param _who is address to change role&#13;
  /// @param _flag is next role status after success&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function _setMinter(address _who, bool _flag) private returns (bool) {&#13;
    require(minters[_who] != _flag);&#13;
    minters[_who] = _flag;&#13;
    if (_flag) {&#13;
      emit AddMinter(_who);&#13;
    } else {&#13;
      emit DeleteMinter(_who);&#13;
    }&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
interface IMintableToken {&#13;
  function mint(address _to, uint256 _amount) external returns (bool);&#13;
}&#13;
&#13;
&#13;
/// @title Very simplified implementation of Token Bucket Algorithm to secure token minting&#13;
/// @author Abha Mai &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e588848c84878d84ddd7a58288848c89cb868a88">[email protected]</a>&gt;&#13;
/// @notice Works with tokens implemented Mintable interface&#13;
/// @dev Transfer ownership/minting role to contract and execute mint over ICOBucket proxy to secure&#13;
contract ICOBucket is RBACMixin {&#13;
  using SafeMath for uint;&#13;
&#13;
  /// @notice Limit maximum amount of available for minting tokens when bucket is full&#13;
  /// @dev Should be enough to mint tokens with proper speed but less enough to prevent overminting in case of losing pkey&#13;
  uint256 public size;&#13;
  /// @notice Bucket refill rate&#13;
  /// @dev Tokens per second (based on block.timestamp). Amount without decimals (in smallest part of token)&#13;
  uint256 public rate;&#13;
  /// @notice Stored time of latest minting&#13;
  /// @dev Each successful call of minting function will update field with call timestamp&#13;
  uint256 public lastMintTime;&#13;
  /// @notice Left tokens in bucket on time of latest minting&#13;
  uint256 public leftOnLastMint;&#13;
&#13;
  /// @notice Reference of Mintable token&#13;
  /// @dev Setup in contructor phase and never change in future&#13;
  IMintableToken public token;&#13;
&#13;
  /// @notice Token Bucket leak event fires on each minting&#13;
  /// @param to is address of target tokens holder&#13;
  /// @param left is amount of tokens available in bucket after leak&#13;
  event Leak(address indexed to, uint256 left);&#13;
&#13;
  /// ICO SECTION&#13;
  /// @notice A token price&#13;
  uint256 public tokenCost;&#13;
&#13;
  /// @notice Allow only whitelisted wallets to purchase&#13;
  mapping(address =&gt; bool) public whiteList;&#13;
&#13;
  /// @notice Main wallet all funds are transferred to&#13;
  address public wallet;&#13;
&#13;
  /// @notice Main wallet all funds are transferred to&#13;
  uint256 public bonus;&#13;
&#13;
  /// @notice Minimum amount of tokens can be purchased&#13;
  uint256 public minimumTokensForPurchase;&#13;
&#13;
  /// @notice A helper&#13;
  modifier onlyWhiteList {&#13;
      require(whiteList[msg.sender]);&#13;
      _;&#13;
  }&#13;
  /// END ICO SECTION&#13;
&#13;
  /// @param _token is address of Mintable token&#13;
  /// @param _size initial size of token bucket&#13;
  /// @param _rate initial refill rate (tokens/sec)&#13;
  constructor (address _token, uint256 _size, uint256 _rate, uint256 _cost, address _wallet, uint256 _bonus, uint256 _minimum) public {&#13;
    token = IMintableToken(_token);&#13;
    size = _size;&#13;
    rate = _rate;&#13;
    leftOnLastMint = _size;&#13;
    tokenCost = _cost;&#13;
    wallet = _wallet;&#13;
    bonus = _bonus;&#13;
    minimumTokensForPurchase = _minimum;&#13;
  }&#13;
&#13;
  /// @notice Change size of bucket&#13;
  /// @dev Require owner role to call&#13;
  /// @param _size is new size of bucket&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function setSize(uint256 _size) public onlyOwner returns (bool) {&#13;
    size = _size;&#13;
    return true;&#13;
  }&#13;
&#13;
  /// @notice Change refill rate of bucket&#13;
  /// @dev Require owner role to call&#13;
  /// @param _rate is new refill rate of bucket&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function setRate(uint256 _rate) public onlyOwner returns (bool) {&#13;
    rate = _rate;&#13;
    return true;&#13;
  }&#13;
&#13;
  /// @notice Change size and refill rate of bucket&#13;
  /// @dev Require owner role to call&#13;
  /// @param _size is new size of bucket&#13;
  /// @param _rate is new refill rate of bucket&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function setSizeAndRate(uint256 _size, uint256 _rate) public onlyOwner returns (bool) {&#13;
    return setSize(_size) &amp;&amp; setRate(_rate);&#13;
  }&#13;
&#13;
  /// @notice Function to calculate and get available in bucket tokens&#13;
  /// @return An amount of available tokens in bucket&#13;
  function availableTokens() public view returns (uint) {&#13;
     // solium-disable-next-line security/no-block-members&#13;
    uint256 timeAfterMint = now.sub(lastMintTime);&#13;
    uint256 refillAmount = rate.mul(timeAfterMint).add(leftOnLastMint);&#13;
    return size &lt; refillAmount ? size : refillAmount;&#13;
  }&#13;
&#13;
  /// ICO METHODS&#13;
  function addToWhiteList(address _address) public onlyMinter {&#13;
    whiteList[_address] = true;&#13;
  }&#13;
&#13;
  function removeFromWhiteList(address _address) public onlyMinter {&#13;
    whiteList[_address] = false;&#13;
  }&#13;
&#13;
  function setWallet(address _wallet) public onlyOwner {&#13;
    wallet = _wallet;&#13;
  }&#13;
&#13;
  function setBonus(uint256 _bonus) public onlyOwner {&#13;
    bonus = _bonus;&#13;
  }&#13;
&#13;
  function setMinimumTokensForPurchase(uint256 _minimum) public onlyOwner {&#13;
    minimumTokensForPurchase = _minimum;&#13;
  }&#13;
&#13;
  /// @notice Purchase function mints tokens&#13;
  /// @return A boolean that indicates if the operation was successful.&#13;
  function () public payable onlyWhiteList {&#13;
    uint256 tokensAmount = tokensAmountForPurchase();&#13;
    uint256 available = availableTokens();&#13;
    uint256 minimum = minimumTokensForPurchase;&#13;
    require(tokensAmount &lt;= available);&#13;
    require(tokensAmount &gt;= minimum);&#13;
    // transfer all funcds to external multisig wallet&#13;
    wallet.transfer(msg.value);&#13;
    leftOnLastMint = available.sub(tokensAmount);&#13;
    lastMintTime = now; // solium-disable-line security/no-block-members&#13;
    require(token.mint(msg.sender, tokensAmount));&#13;
  }&#13;
&#13;
  function tokensAmountForPurchase() private constant returns(uint256) {&#13;
    return msg.value.mul(10 ** 18)&#13;
                    .div(tokenCost)&#13;
                    .mul(100 + bonus)&#13;
                    .div(100);&#13;
  }&#13;
}