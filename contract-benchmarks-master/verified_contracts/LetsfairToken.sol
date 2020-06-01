// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
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
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title SchedulableToken
 * @dev The SchedulableToken provide a method to create tokens progressively, in a gradual
 * and programed way, until a specified date and amount. To effectively create tokens, it
 * is necessary for someone to periodically run the release() function in the contract.
 * For example: You want to create a total of 1000 tokens (maxSupply) spread over 2 years (duration).
 * In this way, when calling the release() function, the number of tokens that are entitled at
 * that moment will be added to the beneficiary's wallet. In this scenario, by running the
 * release() function every day at the same time over 2 years, the beneficiary will receive
 * 1.37 tokens (1000 / 364.25 * 2) everyday.
 * @author Anselmo Zago (<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="fd9c938e98919092bd9198898e9b9c948fd3928f9a">[email protected]</a>), based in TokenVesting by Zeppelin Solidity library.&#13;
 */&#13;
contract SchedulableToken is StandardToken, BurnableToken {&#13;
  using SafeMath for uint256;&#13;
&#13;
  event Released(uint256 amount);&#13;
&#13;
  address public beneficiary;&#13;
  uint256 public maxSupply;&#13;
  uint256 public start;&#13;
  uint256 public duration;&#13;
&#13;
  /**&#13;
   * @dev Constructor of the SchedulableToken contract that releases the tokens gradually and&#13;
   * programmatically. The balance will be assigned to _beneficiary in the maximum amount of&#13;
   * _maxSupply, divided proportionally during the _duration period.&#13;
   * @param _beneficiary address of the beneficiary to whom schedulable tokens will be added&#13;
   * @param _maxSupply schedulable token max supply&#13;
   * @param _duration duration in seconds of the period in which the tokens will released&#13;
   */&#13;
  function SchedulableToken(address _beneficiary, uint256 _maxSupply, uint256 _duration) public {&#13;
    require(_beneficiary != address(0));&#13;
    require(_maxSupply &gt; 0);&#13;
    require(_duration &gt; 0);&#13;
&#13;
    beneficiary = _beneficiary;&#13;
    maxSupply = _maxSupply;&#13;
    duration = _duration;&#13;
    start = now;&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Transfers schedulable tokens to beneficiary.&#13;
   */&#13;
  function release() public {&#13;
    uint256 amount = calculateAmountToRelease();&#13;
    require(amount &gt; 0);&#13;
&#13;
    balances[beneficiary] = balances[beneficiary].add(amount);&#13;
    totalSupply = totalSupply.add(amount);&#13;
&#13;
    Released(amount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Calculates the amount of tokens by right, until that moment.&#13;
   */&#13;
  function calculateAmountToRelease() public view returns (uint256) {&#13;
    if (now &lt; start.add(duration)) {&#13;
      return maxSupply.mul(now.sub(start)).div(duration).sub(totalSupply);&#13;
    } else {&#13;
      return schedulableAmount();&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Returns the total amount that still to be released by the end of the duration.&#13;
   */&#13;
  function schedulableAmount() public view returns (uint256) {&#13;
    return maxSupply.sub(totalSupply);&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Overridden the BurnableToken burn() function to also correct maxSupply.&#13;
  * @param _value The amount of token to be burned.&#13;
  */&#13;
  function burn(uint256 _value) public {&#13;
    super.burn(_value);&#13;
    maxSupply = maxSupply.sub(_value);&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Letsfair Token (LTF)&#13;
 * @dev LetsfairToken contract implements the ERC20 with the StandardToken functions.&#13;
 * The token's creation is realize in a gradual and programmatic way, distributed&#13;
 * proportionally over a predefined period, specified by SchedulableToken.&#13;
 * @author Anselmo Zago (<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2849465b4d44454768444d5c5b4e49415a06475a4f">[email protected]</a>)&#13;
 */&#13;
 contract LetsfairToken is SchedulableToken {&#13;
&#13;
  string public constant name = "Letsfair";&#13;
  string public constant symbol = "LTF";&#13;
  uint8 public constant decimals = 18;&#13;
&#13;
  address _beneficiary = 0xe0F158B382F30A1eccecb5B67B1cf7EB92B5f1E4;&#13;
  uint256 _maxSupply = 10 ** 27; // 1 billion with decimals&#13;
  uint256 _duration = 157788000; // ~5 years in seconds&#13;
&#13;
  function LetsfairToken() SchedulableToken(_beneficiary, _maxSupply, _duration) public {}&#13;
}