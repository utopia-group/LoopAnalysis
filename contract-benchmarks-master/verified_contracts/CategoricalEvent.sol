pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

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

// File: @gnosis.pm/util-contracts/contracts/Proxy.sol

/// @title Proxied - indicates that a contract will be proxied. Also defines storage requirements for Proxy.
/// @author Alan Lu - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ea8b868b84aa8d8485998399c49a87">[email protected]</a>&gt;&#13;
contract Proxied {&#13;
    address public masterCopy;&#13;
}&#13;
&#13;
/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5c2f28393a3d321c3b32332f352f722c31">[email protected]</a>&gt;&#13;
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
// File: contracts/Tokens/OutcomeToken.sol&#13;
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
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="9eedeafbf8fff0def9f0f1edf7edb0eef3">[email protected]</a>&gt;&#13;
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
// File: contracts/Oracles/Oracle.sol&#13;
&#13;
/// @title Abstract oracle contract - Functions to be implemented by oracles&#13;
contract Oracle {&#13;
&#13;
    function isOutcomeSet() public view returns (bool);&#13;
    function getOutcome() public view returns (int);&#13;
}&#13;
&#13;
// File: contracts/Events/Event.sol&#13;
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
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c7b4b3a2a1a6a987a0a9a8b4aeb4e9b7aa">[email protected]</a>&gt;&#13;
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
// File: contracts/Events/CategoricalEvent.sol&#13;
&#13;
contract CategoricalEventProxy is Proxy, EventData {&#13;
&#13;
    /// @dev Contract constructor validates and sets basic event properties&#13;
    /// @param _collateralToken Tokens used as collateral in exchange for outcome tokens&#13;
    /// @param _oracle Oracle contract used to resolve the event&#13;
    /// @param outcomeCount Number of event outcomes&#13;
    constructor(address proxied, address outcomeTokenMasterCopy, ERC20 _collateralToken, Oracle _oracle, uint8 outcomeCount)&#13;
        Proxy(proxied)&#13;
        public&#13;
    {&#13;
        // Validate input&#13;
        require(address(_collateralToken) != 0 &amp;&amp; address(_oracle) != 0 &amp;&amp; outcomeCount &gt;= 2);&#13;
        collateralToken = _collateralToken;&#13;
        oracle = _oracle;&#13;
        // Create an outcome token for each outcome&#13;
        for (uint8 i = 0; i &lt; outcomeCount; i++) {&#13;
            OutcomeToken outcomeToken = OutcomeToken(new OutcomeTokenProxy(outcomeTokenMasterCopy));&#13;
            outcomeTokens.push(outcomeToken);&#13;
            emit OutcomeTokenCreation(outcomeToken, i);&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
/// @title Categorical event contract - Categorical events resolve to an outcome from a set of outcomes&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d8abacbdbeb9b698bfb6b7abb1abf6a8b5">[email protected]</a>&gt;&#13;
contract CategoricalEvent is Proxied, Event {&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Exchanges sender's winning outcome tokens for collateral tokens&#13;
    /// @return Sender's winnings&#13;
    function redeemWinnings()&#13;
        public&#13;
        returns (uint winnings)&#13;
    {&#13;
        // Winning outcome has to be set&#13;
        require(isOutcomeSet);&#13;
        // Calculate winnings&#13;
        winnings = outcomeTokens[uint(outcome)].balanceOf(msg.sender);&#13;
        // Revoke tokens from winning outcome&#13;
        outcomeTokens[uint(outcome)].revoke(msg.sender, winnings);&#13;
        // Payout winnings&#13;
        require(collateralToken.transfer(msg.sender, winnings));&#13;
        emit WinningsRedemption(msg.sender, winnings);&#13;
    }&#13;
&#13;
    /// @dev Calculates and returns event hash&#13;
    /// @return Event hash&#13;
    function getEventHash()&#13;
        public&#13;
        view&#13;
        returns (bytes32)&#13;
    {&#13;
        return keccak256(abi.encodePacked(collateralToken, oracle, outcomeTokens.length));&#13;
    }&#13;
}