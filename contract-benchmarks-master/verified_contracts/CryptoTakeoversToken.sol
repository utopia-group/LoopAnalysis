pragma solidity 0.4.24;

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
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
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
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

contract Operatable is Ownable {

    address public operator;

    event LogOperatorChanged(address indexed from, address indexed to);

    modifier isValidOperator(address _operator) {
        require(_operator != address(0));
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operator);
        _;
    }

    constructor(address _owner, address _operator) public isValidOperator(_operator) {
        require(_owner != address(0));
        
        owner = _owner;
        operator = _operator;
    }

    function setOperator(address _operator) public onlyOwner isValidOperator(_operator) {
        emit LogOperatorChanged(operator, _operator);
        operator = _operator;
    }
}

/// @title CryptoTakeovers In-Game Token.
/// @dev The token used in the game to participate in NFT airdrop raffles.
/// @author Ido Amram <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7a131e153a1908030a0e150e1b111f150c1f080954191517">[email protected]</a>&gt;, Elad Mallel &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="20454c41446043525950544f54414b454f564552530e434f4d">[email protected]</a>&gt;&#13;
contract CryptoTakeoversToken is MintableToken, Operatable {&#13;
&#13;
    /*&#13;
     * Events&#13;
     */&#13;
&#13;
    event LogGameOperatorChanged(address indexed from, address indexed to);&#13;
    event LogShouldBlockPublicTradeSet(bool value, address indexed owner);&#13;
&#13;
    /*&#13;
     * Storage&#13;
     */&#13;
&#13;
    bool public shouldBlockPublicTrade;&#13;
    address public gameOperator;&#13;
&#13;
    /*&#13;
     * Modifiers&#13;
     */&#13;
&#13;
    modifier hasMintPermission() {&#13;
        require(msg.sender == operator || (gameOperator != address(0) &amp;&amp; msg.sender == gameOperator));&#13;
        _;&#13;
    }&#13;
&#13;
    modifier hasTradePermission(address _from) {&#13;
        require(_from == operator || !shouldBlockPublicTrade);&#13;
        _;&#13;
    }&#13;
&#13;
    /*&#13;
     * Public (unauthorized) functions&#13;
     */&#13;
&#13;
    /// @dev CryptoTakeoversToken constructor.&#13;
    /// @param _owner the address of the owner to set for this contract&#13;
    /// @param _operator the address ofh the operator to set for this contract&#13;
    constructor (address _owner, address _operator) Operatable(_owner, _operator) public {&#13;
        shouldBlockPublicTrade = true;&#13;
    }&#13;
&#13;
    /*&#13;
     * Operator (authorized) functions&#13;
     */&#13;
&#13;
    /// @dev Allows an authorized set of accounts to transfer tokens.&#13;
    /// @param _to the account to transfer tokens to&#13;
    /// @param _value the amount of tokens to transfer&#13;
    /// @return true if the transfer succeeded, and false otherwise&#13;
    function transfer(address _to, uint256 _value) public hasTradePermission(msg.sender) returns (bool) {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    /// @dev Allows an authorized set of accounts to transfer tokens.&#13;
    /// @param _from the account from which to transfer tokens&#13;
    /// @param _to the account to transfer tokens to&#13;
    /// @param _value the amount of tokens to transfer&#13;
    /// @return true if the transfer succeeded, and false otherwise&#13;
    function transferFrom(address _from, address _to, uint256 _value) public hasTradePermission(_from) returns (bool) {&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    /// @dev Allows the operator to set the address of the game operator, which should be the pre-sale contract or the game contract.&#13;
    /// @param _gameOperator the address of the game operator&#13;
    function setGameOperator(address _gameOperator) public onlyOperator {&#13;
        require(_gameOperator != address(0));&#13;
&#13;
        emit LogGameOperatorChanged(gameOperator, _gameOperator);&#13;
&#13;
        gameOperator = _gameOperator;&#13;
    }&#13;
&#13;
    /*&#13;
     * Owner (authorized) functions&#13;
     */&#13;
&#13;
    /// @dev Allows the owner to enable or restrict open trade of tokens.&#13;
    /// @param _shouldBlockPublicTrade true if trade should be restricted, and false to open trade&#13;
    function setShouldBlockPublicTrade(bool _shouldBlockPublicTrade) public onlyOwner {&#13;
        shouldBlockPublicTrade = _shouldBlockPublicTrade;&#13;
&#13;
        emit LogShouldBlockPublicTradeSet(_shouldBlockPublicTrade, owner);&#13;
    }&#13;
}