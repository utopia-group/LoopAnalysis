pragma solidity ^0.4.24;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

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




/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

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


/// @title Desing by contract (Hoare logic)
/// @author Melonport AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d2a6b7b3bf92bfb7bebdbca2bda0a6fcb1bdbf">[email protected]</a>&gt;&#13;
/// @notice Gives deriving contracts design by contract modifiers&#13;
contract DBC {&#13;
&#13;
    // MODIFIERS&#13;
&#13;
    modifier pre_cond(bool condition) {&#13;
        require(condition);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier post_cond(bool condition) {&#13;
        _;&#13;
        assert(condition);&#13;
    }&#13;
&#13;
    modifier invariant(bool condition) {&#13;
        require(condition);&#13;
        _;&#13;
        assert(condition);&#13;
    }&#13;
}&#13;
&#13;
&#13;
contract Owned is DBC {&#13;
&#13;
    // FIELDS&#13;
&#13;
    address public owner;&#13;
&#13;
    // NON-CONSTANT METHODS&#13;
&#13;
    function Owned() { owner = msg.sender; }&#13;
&#13;
    function changeOwner(address ofNewOwner) pre_cond(isOwner()) { owner = ofNewOwner; }&#13;
&#13;
    // PRE, POST, INVARIANT CONDITIONS&#13;
&#13;
    function isOwner() internal returns (bool) { return msg.sender == owner; }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 *&#13;
 * @dev Implementation of the basic standard token.&#13;
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md&#13;
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
 */&#13;
contract StandardToken is ERC20, Owned {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping (address =&gt; uint256) private balances;&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) private allowed;&#13;
&#13;
  uint256 private totalSupply_;&#13;
&#13;
  /**&#13;
  * @dev Total number of tokens in existence&#13;
  */&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return totalSupply_;&#13;
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
  * @dev Transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    require(_value &lt;= balances[msg.sender]);&#13;
    require(_to != address(0));&#13;
&#13;
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    emit Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
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
    require(_value &lt;= balances[_from]);&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
    require(_to != address(0));&#13;
&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    emit Transfer(_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
   * approve should be called when allowed[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _addedValue The amount of tokens to increase the allowance by.&#13;
   */&#13;
  function increaseApproval(&#13;
    address _spender,&#13;
    uint256 _addedValue&#13;
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
   * approve should be called when allowed[_spender] == 0. To decrement&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _subtractedValue The amount of tokens to decrease the allowance by.&#13;
   */&#13;
  function decreaseApproval(&#13;
    address _spender,&#13;
    uint256 _subtractedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    uint256 oldValue = allowed[msg.sender][_spender];&#13;
    if (_subtractedValue &gt;= oldValue) {&#13;
      allowed[msg.sender][_spender] = 0;&#13;
    } else {&#13;
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
    }&#13;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Internal function that mints an amount of the token and assigns it to&#13;
   * an account. This encapsulates the modification of balances such that the&#13;
   * proper events are emitted.&#13;
   * @param _account The account that will receive the created tokens.&#13;
   * @param _amount The amount that will be created.&#13;
   */&#13;
  function _mint(address _account, uint256 _amount) internal {&#13;
    require(_account != 0);&#13;
    totalSupply_ = totalSupply_.add(_amount);&#13;
    balances[_account] = balances[_account].add(_amount);&#13;
    emit Transfer(address(0), _account, _amount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Internal function that burns an amount of the token of a given&#13;
   * account.&#13;
   * @param _account The account whose tokens will be burnt.&#13;
   * @param _amount The amount that will be burnt.&#13;
   */&#13;
  function _burn(address _account, uint256 _amount) internal {&#13;
    require(_account != 0);&#13;
    require(_amount &lt;= balances[_account]);&#13;
&#13;
    totalSupply_ = totalSupply_.sub(_amount);&#13;
    balances[_account] = balances[_account].sub(_amount);&#13;
    emit Transfer(_account, address(0), _amount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Internal function that burns an amount of the token of a given&#13;
   * account, deducting from the sender's allowance for said account. Uses the&#13;
   * internal _burn function.&#13;
   * @param _account The account whose tokens will be burnt.&#13;
   * @param _amount The amount that will be burnt.&#13;
   */&#13;
  function _burnFrom(address _account, uint256 _amount) internal {&#13;
    require(_amount &lt;= allowed[_account][msg.sender]);&#13;
&#13;
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,&#13;
    // this function needs to emit an event with the updated approval.&#13;
    allowed[_account][msg.sender] = allowed[_account][msg.sender].sub(_amount);&#13;
    _burn(_account, _amount);&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title SimpleToken&#13;
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.&#13;
 * Note they can later distribute these tokens as they wish using `transfer` and other&#13;
 * `StandardToken` functions.&#13;
 */&#13;
contract GammonCoin is StandardToken {&#13;
&#13;
  string public constant name = "GammonCoin";&#13;
  string public constant symbol = "GC";&#13;
  uint8 public constant decimals = 18;&#13;
&#13;
  uint256 public constant INITIAL_SUPPLY = 172750000 * (10 ** uint256(decimals));&#13;
&#13;
  /**&#13;
   * @dev Constructor that gives msg.sender all of existing tokens.&#13;
   */&#13;
  constructor() public {&#13;
    _mint(msg.sender, INITIAL_SUPPLY);&#13;
  }&#13;
&#13;
}