pragma solidity ^0.4.15;


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


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}




/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}



/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}





/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}





/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
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
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

// Quantstamp Technologies Inc. (<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="056c6b636a457470646b7176716468752b666a68">[email protected]</a>)&#13;
&#13;
&#13;
&#13;
/**&#13;
 * The Quantstamp token (QSP) has a fixed supply and restricts the ability&#13;
 * to transfer tokens until the owner has called the enableTransfer()&#13;
 * function.&#13;
 *&#13;
 * The owner can associate the token with a token sale contract. In that&#13;
 * case, the token balance is moved to the token sale contract, which&#13;
 * in turn can transfer its tokens to contributors to the sale.&#13;
 */&#13;
contract QuantstampToken is StandardToken, BurnableToken, Ownable {&#13;
&#13;
    // Constants&#13;
    string  public constant name = "Quantstamp Token";&#13;
    string  public constant symbol = "QSP";&#13;
    uint8   public constant decimals = 18;&#13;
    uint256 public constant INITIAL_SUPPLY      = 1000000000 * (10 ** uint256(decimals));&#13;
    uint256 public constant CROWDSALE_ALLOWANCE =  650000000 * (10 ** uint256(decimals));&#13;
    uint256 public constant ADMIN_ALLOWANCE     =  350000000 * (10 ** uint256(decimals));&#13;
&#13;
    // Properties&#13;
    uint256 public crowdSaleAllowance;      // the number of tokens available for crowdsales&#13;
    uint256 public adminAllowance;          // the number of tokens available for the administrator&#13;
    address public crowdSaleAddr;           // the address of a crowdsale currently selling this token&#13;
    address public adminAddr;               // the address of the token admin account&#13;
    bool    public transferEnabled = false; // indicates if transferring tokens is enabled or not&#13;
&#13;
    // Modifiers&#13;
    modifier onlyWhenTransferEnabled() {&#13;
        if (!transferEnabled) {&#13;
            require(msg.sender == adminAddr || msg.sender == crowdSaleAddr);&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * The listed addresses are not valid recipients of tokens.&#13;
     *&#13;
     * 0x0           - the zero address is not valid&#13;
     * this          - the contract itself should not receive tokens&#13;
     * owner         - the owner has all the initial tokens, but cannot receive any back&#13;
     * adminAddr     - the admin has an allowance of tokens to transfer, but does not receive any&#13;
     * crowdSaleAddr - the crowdsale has an allowance of tokens to transfer, but does not receive any&#13;
     */&#13;
    modifier validDestination(address _to) {&#13;
        require(_to != address(0x0));&#13;
        require(_to != address(this));&#13;
        require(_to != owner);&#13;
        require(_to != address(adminAddr));&#13;
        require(_to != address(crowdSaleAddr));&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * Constructor - instantiates token supply and allocates balanace of&#13;
     * to the owner (msg.sender).&#13;
     */&#13;
    function QuantstampToken(address _admin) {&#13;
        // the owner is a custodian of tokens that can&#13;
        // give an allowance of tokens for crowdsales&#13;
        // or to the admin, but cannot itself transfer&#13;
        // tokens; hence, this requirement&#13;
        require(msg.sender != _admin);&#13;
&#13;
        totalSupply = INITIAL_SUPPLY;&#13;
        crowdSaleAllowance = CROWDSALE_ALLOWANCE;&#13;
        adminAllowance = ADMIN_ALLOWANCE;&#13;
&#13;
        // mint all tokens&#13;
        balances[msg.sender] = totalSupply;&#13;
        Transfer(address(0x0), msg.sender, totalSupply);&#13;
&#13;
        adminAddr = _admin;&#13;
        approve(adminAddr, adminAllowance);&#13;
    }&#13;
&#13;
    /**&#13;
     * Associates this token with a current crowdsale, giving the crowdsale&#13;
     * an allowance of tokens from the crowdsale supply. This gives the&#13;
     * crowdsale the ability to call transferFrom to transfer tokens to&#13;
     * whomever has purchased them.&#13;
     *&#13;
     * Note that if _amountForSale is 0, then it is assumed that the full&#13;
     * remaining crowdsale supply is made available to the crowdsale.&#13;
     *&#13;
     * @param _crowdSaleAddr The address of a crowdsale contract that will sell this token&#13;
     * @param _amountForSale The supply of tokens provided to the crowdsale&#13;
     */&#13;
    function setCrowdsale(address _crowdSaleAddr, uint256 _amountForSale) external onlyOwner {&#13;
        require(!transferEnabled);&#13;
        require(_amountForSale &lt;= crowdSaleAllowance);&#13;
&#13;
        // if 0, then full available crowdsale supply is assumed&#13;
        uint amount = (_amountForSale == 0) ? crowdSaleAllowance : _amountForSale;&#13;
&#13;
        // Clear allowance of old, and set allowance of new&#13;
        approve(crowdSaleAddr, 0);&#13;
        approve(_crowdSaleAddr, amount);&#13;
&#13;
        crowdSaleAddr = _crowdSaleAddr;&#13;
    }&#13;
&#13;
    /**&#13;
     * Enables the ability of anyone to transfer their tokens. This can&#13;
     * only be called by the token owner. Once enabled, it is not&#13;
     * possible to disable transfers.&#13;
     */&#13;
    function enableTransfer() external onlyOwner {&#13;
        transferEnabled = true;&#13;
        approve(crowdSaleAddr, 0);&#13;
        approve(adminAddr, 0);&#13;
        crowdSaleAllowance = 0;&#13;
        adminAllowance = 0;&#13;
    }&#13;
&#13;
    /**&#13;
     * Overrides ERC20 transfer function with modifier that prevents the&#13;
     * ability to transfer tokens until after transfers have been enabled.&#13;
     */&#13;
    function transfer(address _to, uint256 _value) public onlyWhenTransferEnabled validDestination(_to) returns (bool) {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * Overrides ERC20 transferFrom function with modifier that prevents the&#13;
     * ability to transfer tokens until after transfers have been enabled.&#13;
     */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public onlyWhenTransferEnabled validDestination(_to) returns (bool) {&#13;
        bool result = super.transferFrom(_from, _to, _value);&#13;
        if (result) {&#13;
            if (msg.sender == crowdSaleAddr)&#13;
                crowdSaleAllowance = crowdSaleAllowance.sub(_value);&#13;
            if (msg.sender == adminAddr)&#13;
                adminAllowance = adminAllowance.sub(_value);&#13;
        }&#13;
        return result;&#13;
    }&#13;
&#13;
    /**&#13;
     * Overrides the burn function so that it cannot be called until after&#13;
     * transfers have been enabled.&#13;
     *&#13;
     * @param _value    The amount of tokens to burn in mini-QSP&#13;
     */&#13;
    function burn(uint256 _value) public {&#13;
        require(transferEnabled || msg.sender == owner);&#13;
        require(balances[msg.sender] &gt;= _value);&#13;
        super.burn(_value);&#13;
        Transfer(msg.sender, address(0x0), _value);&#13;
    }&#13;
}