pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}

// File: openzeppelin-solidity/contracts/ownership/HasNoTokens.sol

/**
 * @title Contracts that should not own Tokens
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0b796e6668644b39">[email protected]</a>π.com&gt;&#13;
 * @dev This blocks incoming ERC223 tokens to prevent accidental loss of tokens.&#13;
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the&#13;
 * owner to reclaim the tokens.&#13;
 */&#13;
contract HasNoTokens is CanReclaimToken {&#13;
&#13;
 /**&#13;
  * @dev Reject all ERC223 compatible tokens&#13;
  * @param from_ address The address that is transferring the tokens&#13;
  * @param value_ uint256 the amount of the specified token&#13;
  * @param data_ Bytes The data passed from the caller.&#13;
  */&#13;
  function tokenFallback(address from_, uint256 value_, bytes data_) external {&#13;
    from_;&#13;
    value_;&#13;
    data_;&#13;
    revert();&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol&#13;
&#13;
/**&#13;
 * @title Pausable&#13;
 * @dev Base contract which allows children to implement an emergency stop mechanism.&#13;
 */&#13;
contract Pausable is Ownable {&#13;
  event Pause();&#13;
  event Unpause();&#13;
&#13;
  bool public paused = false;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is not paused.&#13;
   */&#13;
  modifier whenNotPaused() {&#13;
    require(!paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is paused.&#13;
   */&#13;
  modifier whenPaused() {&#13;
    require(paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to pause, triggers stopped state&#13;
   */&#13;
  function pause() onlyOwner whenNotPaused public {&#13;
    paused = true;&#13;
    emit Pause();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to unpause, returns to normal state&#13;
   */&#13;
  function unpause() onlyOwner whenPaused public {&#13;
    paused = false;&#13;
    emit Unpause();&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/math/SafeMath.sol&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, throws on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the&#13;
    // benefit is lost if 'b' is also tested.&#13;
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    // uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return a / b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol&#13;
&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances.&#13;
 */&#13;
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping(address =&gt; uint256) balances;&#13;
&#13;
  uint256 totalSupply_;&#13;
&#13;
  /**&#13;
  * @dev total number of tokens in existence&#13;
  */&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return totalSupply_;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[msg.sender]);&#13;
&#13;
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    emit Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param _owner The address to query the the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) public view returns (uint256) {&#13;
    return balances[_owner];&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 *&#13;
 * @dev Implementation of the basic standard token.&#13;
 * @dev https://github.com/ethereum/EIPs/issues/20&#13;
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
 */&#13;
contract StandardToken is ERC20, BasicToken {&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Transfer tokens from one address to another&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _to address The address which you want to transfer to&#13;
   * @param _value uint256 the amount of tokens to be transferred&#13;
   */&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[_from]);&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    emit Transfer(_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
   *&#13;
   * Beware that changing an allowance with this method brings the risk that someone may use both the old&#13;
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this&#13;
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:&#13;
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _value The amount of tokens to be spent.&#13;
   */&#13;
  function approve(address _spender, uint256 _value) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = _value;&#13;
    emit Approval(msg.sender, _spender, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
   * @param _owner address The address which owns the funds.&#13;
   * @param _spender address The address which will spend the funds.&#13;
   * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
   */&#13;
  function allowance(&#13;
    address _owner,&#13;
    address _spender&#13;
   )&#13;
    public&#13;
    view&#13;
    returns (uint256)&#13;
  {&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
   *&#13;
   * approve should be called when allowed[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _addedValue The amount of tokens to increase the allowance by.&#13;
   */&#13;
  function increaseApproval(&#13;
    address _spender,&#13;
    uint _addedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    allowed[msg.sender][_spender] = (&#13;
      allowed[msg.sender][_spender].add(_addedValue));&#13;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
   *&#13;
   * approve should be called when allowed[_spender] == 0. To decrement&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _subtractedValue The amount of tokens to decrease the allowance by.&#13;
   */&#13;
  function decreaseApproval(&#13;
    address _spender,&#13;
    uint _subtractedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    uint oldValue = allowed[msg.sender][_spender];&#13;
    if (_subtractedValue &gt; oldValue) {&#13;
      allowed[msg.sender][_spender] = 0;&#13;
    } else {&#13;
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
    }&#13;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol&#13;
&#13;
/**&#13;
 * @title Pausable token&#13;
 * @dev StandardToken modified with pausable transfers.&#13;
 **/&#13;
contract PausableToken is StandardToken, Pausable {&#13;
&#13;
  function transfer(&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool)&#13;
  {&#13;
    return super.transfer(_to, _value);&#13;
  }&#13;
&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool)&#13;
  {&#13;
    return super.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  function approve(&#13;
    address _spender,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool)&#13;
  {&#13;
    return super.approve(_spender, _value);&#13;
  }&#13;
&#13;
  function increaseApproval(&#13;
    address _spender,&#13;
    uint _addedValue&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool success)&#13;
  {&#13;
    return super.increaseApproval(_spender, _addedValue);&#13;
  }&#13;
&#13;
  function decreaseApproval(&#13;
    address _spender,&#13;
    uint _subtractedValue&#13;
  )&#13;
    public&#13;
    whenNotPaused&#13;
    returns (bool success)&#13;
  {&#13;
    return super.decreaseApproval(_spender, _subtractedValue);&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/Cubik.sol&#13;
&#13;
/**&#13;
 * @title Cubik&#13;
 * @dev ERC20 CUBIK Token&#13;
 *&#13;
 * CUBIK Tokens are divisible by 1e18 (1,000,000,000,000,000,000) base&#13;
 * units referred to as 'Wei'.&#13;
 *&#13;
 * CUBIK are displayed using 18 decimal places of precision.&#13;
 *&#13;
 * 5 Billion CUBIK Token total supply (5 Octillion Wei):&#13;
 * 5,000,000,000 * 1e18 == 5e9 * 1e18 == 5e27&#13;
 *&#13;
 * All initial CUBIK Grains are assigned to the creator of&#13;
 * this contract.&#13;
 */&#13;
&#13;
contract Cubik is PausableToken, HasNoTokens {&#13;
&#13;
  string public constant name = 'Cubik';                              // Set the token name for display&#13;
  string public constant symbol = 'CUBIK';                                  // Set the token symbol for display&#13;
  uint8 public constant decimals = 18;                                     // Set the number of decimals for display&#13;
  uint256 public constant INITIAL_SUPPLY = 5e9 * 10**uint256(decimals); // supply specified in Wei&#13;
&#13;
  /**&#13;
   * @dev Cubik Constructor&#13;
   * Runs only on initial contract creation.&#13;
   */&#13;
  constructor() public {&#13;
    totalSupply_ = INITIAL_SUPPLY;                               // Set the total supply&#13;
    balances[msg.sender] = INITIAL_SUPPLY;                      // Creator address is assigned all&#13;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);&#13;
  }&#13;
&#13;
}