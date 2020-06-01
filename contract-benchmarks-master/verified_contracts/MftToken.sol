//File: node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol
pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

//File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol
pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

//File: node_modules/openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol
pragma solidity ^0.4.24;






/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

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
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

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

//File: node_modules/openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol
pragma solidity ^0.4.24;




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
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

//File: node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol
pragma solidity ^0.4.24;




/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

//File: node_modules/openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol
pragma solidity ^0.4.24;





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
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

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
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

//File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol
pragma solidity ^0.4.24;


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

//File: node_modules/openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol
pragma solidity ^0.4.24;





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
    public
    hasMintPermission
    canMint
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
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

//File: node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol
pragma solidity ^0.4.24;





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
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

//File: node_modules/openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol
pragma solidity ^0.4.24;





/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

//File: contracts/ico/MftToken.sol
/**
 * @title MFT token
 *
 * @version 1.0
 * @author Validity Labs AG <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7a13141c153a0c1b16131e130e03161b18095415081d">[email protected]</a>&gt;&#13;
 */&#13;
pragma solidity 0.4.24;&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract MftToken is BurnableToken, MintableToken, PausableToken {&#13;
    /* solhint-disable */&#13;
    string public constant name = "MindFire Token";&#13;
    string public constant symbol = "MFT";&#13;
    uint8 public constant decimals = 18;&#13;
    /* solhint-enable */&#13;
&#13;
    /** &#13;
    * @dev `Checkpoint` is the structure that attaches a block number to a&#13;
    * given value, the block number attached is the one that last changed the value&#13;
    */&#13;
    struct Checkpoint {&#13;
        // `fromBlock` is the block number that the value was generatedsuper.mint(_to, _value); from&#13;
        uint128 fromBlock;&#13;
        // `value` is the amount of tokens at a specific block number&#13;
        uint128 value;&#13;
    }&#13;
&#13;
    // Tracks the history of the `totalSupply` of the token&#13;
    Checkpoint[] public totalSupplyHistory;&#13;
&#13;
    /** &#13;
    * `balances` is the map that tracks the balance of each address, in this&#13;
    * contract when the balance changes the block number that the change&#13;
    * occurred is also included in the map&#13;
    */&#13;
    mapping (address =&gt; Checkpoint[]) public balances;&#13;
&#13;
    /**&#13;
     * @dev Constructor of MftToken that instantiates a new Mintable Pauseable Token&#13;
     */&#13;
    constructor() public {&#13;
        paused = true;  // token should not be transferrable until after all tokens have been issued&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev allows batch minting through the mint function call&#13;
    * @param _to address[]&#13;
    * @param _value uint256[]&#13;
    */&#13;
    function batchMint(address[] _to, uint256[] _value) external {&#13;
        require(_to.length == _value.length, "[] len !=");&#13;
&#13;
        for (uint256 i; i &lt; _to.length; i = i.add(1)) {&#13;
            mint(_to[i], _value[i]);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Send `_value` tokens to `_to` from `msg.sender`&#13;
    * @param _to The address of the recipient&#13;
    * @param _value The amount of tokens to be transferred&#13;
    * @return Whether the transfer was successful or not&#13;
    */&#13;
    function transfer(address _to, uint256 _value) public returns (bool success) {&#13;
        require(!paused, "token is paused");&#13;
&#13;
        doTransfer(msg.sender, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Send `_value` tokens to `_to` from `_from` on the condition it is approved by `_from`&#13;
    * @param _from The address holding the tokens being transferred&#13;
    * @param _to The address of the recipient&#13;
    * @param _value The amount of tokens to be transferred&#13;
    * @return True if the transfer was successful&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {&#13;
        require(!paused, "token is paused");&#13;
&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
        doTransfer(_from, _to, _value);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @param _owner The address that's balance is being requested&#13;
    * @return The balance of `_owner` at the current block&#13;
    */&#13;
    function balanceOf(address _owner) public constant returns (uint256 balance) {&#13;
        return balanceOfAt(_owner, block.number);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev `msg.sender` approves `_spender` to spend `_value` tokens on&#13;
    *  its behalf. This is a modified version of the ERC20 approve function&#13;
    *  to be a little bit safer&#13;
    * @param _spender The address of the account able to transfer the tokens&#13;
    * @param _value The amount of tokens to be approved for transfer&#13;
    * @return True if the approval was successful&#13;
    */&#13;
    function approve(address _spender, uint256 _value) public returns (bool success) {&#13;
        require(!paused, "token is paused");&#13;
&#13;
        // To change the approve amount you first have to reduce the addresses`&#13;
        //  allowance to zero by calling `approve(_spender,0)` if it is not&#13;
        //  already 0 to mitigate the race condition described here:&#13;
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
        require((_value == 0) || (allowed[msg.sender][_spender] == 0), "allowed not 0");&#13;
&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev This function makes it easy to read the `allowed[]` map&#13;
    * @param _owner The address of the account that owns the token&#13;
    * @param _spender The address of the account able to transfer the tokens&#13;
    * @return Amount of remaining tokens of _owner that _spender is allowed&#13;
    *  to spend&#13;
    */&#13;
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    /**&#13;
    *  @dev This function makes it easy to get the total number of tokens&#13;
    * @return The total number of tokens&#13;
    */&#13;
    function totalSupply() public constant returns (uint256) {&#13;
        return totalSupplyAt(block.number);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Queries the balance of `_owner` at a specific `_blockNumber`&#13;
    * @param _owner The address from which the balance will be retrieved&#13;
    * @param _blockNumber The block number when the balance is queried&#13;
    * @return The balance at `_blockNumber`&#13;
    */&#13;
    function balanceOfAt(address _owner, uint256 _blockNumber) public constant returns (uint256) {&#13;
&#13;
        // These next few lines are used when the balance of the token is&#13;
        //  requested before a check point was ever created for this token, it&#13;
        //  requires that the `parentToken.balanceOfAt` be queried at the&#13;
        //  genesis block for that token as this contains initial balance of&#13;
        //  this token&#13;
        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock &gt; _blockNumber)) {&#13;
            return 0;&#13;
        } else {    // This will return the expected balance during normal situations&#13;
            return getValueAt(balances[_owner], _blockNumber);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Total amount of tokens at a specific `_blockNumber`.&#13;
    * @param _blockNumber The block number when the totalSupply is queried&#13;
    * @return The total amount of tokens at `_blockNumber`&#13;
    */&#13;
    function totalSupplyAt(uint256 _blockNumber) public constant returns(uint256) {&#13;
&#13;
        // These next few lines are used when the totalSupply of the token is&#13;
        //  requested before a check point was ever created for this token, it&#13;
        //  requires that the `parentToken.totalSupplyAt` be queried at the&#13;
        //  genesis block for this token as that contains totalSupply of this&#13;
        //  token at this block number.&#13;
        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock &gt; _blockNumber)) {&#13;
            return 0;&#13;
        // This will return the expected totalSupply during normal situations&#13;
        } else {&#13;
            return getValueAt(totalSupplyHistory, _blockNumber);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Generates `_value` tokens that are assigned to `_owner`&#13;
    * @param _to The address that will be assigned the new tokens&#13;
    * @param _value The quantity of tokens generated&#13;
    * @return True if the tokens are generated correctly&#13;
    */&#13;
    function mint(address _to, uint256 _value) public hasMintPermission canMint returns (bool) {&#13;
        uint256 curTotalSupply = totalSupply();&#13;
        uint256 previousBalanceTo = balanceOf(_to);&#13;
&#13;
        updateValueAtNow(totalSupplyHistory, curTotalSupply.add(_value));&#13;
        updateValueAtNow(balances[_to], previousBalanceTo.add(_value));&#13;
&#13;
        emit Mint(_to, _value);&#13;
        emit Transfer(0, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev called to burn _value of tokens by the msg.sender&#13;
    * @param _value uint256 the amount of tokens to burn&#13;
    */&#13;
    function burn(uint256 _value) public {&#13;
        uint256 curTotalSupply = totalSupply();&#13;
        uint256 previousBalanceFrom = balanceOf(msg.sender);&#13;
&#13;
        updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_value));&#13;
        updateValueAtNow(balances[msg.sender], previousBalanceFrom.sub(_value));&#13;
&#13;
        emit Burn(msg.sender, _value);&#13;
        emit Transfer(msg.sender, 0, _value);&#13;
    }&#13;
&#13;
    /*** INTERNAL FUNCTIONS ***/&#13;
    /**&#13;
    * @dev This is the actual transfer function&#13;
    * @param _from The address holding the tokens being transferred&#13;
    * @param _to The address of the recipient&#13;
    * @param _value The amount of tokens to be transferred&#13;
    * @return True if the transfer was successful&#13;
    */&#13;
    function doTransfer(address _from, address _to, uint256 _value) internal {&#13;
        if (_value == 0) {&#13;
            emit Transfer(_from, _to, _value);    // Follow the spec to louch the event when transfer 0&#13;
            return;&#13;
        }&#13;
&#13;
        // Do not allow transfer to 0x0 or the token contract itself&#13;
        require((_to != address(0)) &amp;&amp; (_to != address(this)), "cannot transfer to 0x0 or token contract");&#13;
&#13;
        &#13;
        uint256 previousBalanceFrom = balanceOfAt(_from, block.number);&#13;
        // First update the balance array with the new value for the address&#13;
        //  sending the tokens&#13;
        updateValueAtNow(balances[_from], previousBalanceFrom.sub(_value));&#13;
&#13;
        // Then update the balance array with the new value for the address&#13;
        //  receiving the tokens&#13;
        uint256 previousBalanceTo = balanceOfAt(_to, block.number);&#13;
        updateValueAtNow(balances[_to], previousBalanceTo.add(_value));&#13;
&#13;
        // An event to make the transfer easy to find on the blockchain&#13;
        emit Transfer(_from, _to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev `getValueAt` retrieves the number of tokens at a given block number&#13;
    * @param checkpoints The history of values being queried&#13;
    * @param _block The block number to retrieve the value at&#13;
    * @return The number of tokens being queried&#13;
    */&#13;
    function getValueAt(Checkpoint[] storage checkpoints, uint _block) internal view returns (uint) {&#13;
        if (checkpoints.length == 0) return 0;&#13;
&#13;
        // Shortcut for the actual value&#13;
        if (_block &gt;= checkpoints[checkpoints.length.sub(1)].fromBlock) {&#13;
            return checkpoints[checkpoints.length.sub(1)].value;&#13;
        }&#13;
&#13;
        if (_block &lt; checkpoints[0].fromBlock) {&#13;
            return 0;&#13;
        } &#13;
&#13;
        // Binary search of the value in the array&#13;
        uint min = 0;&#13;
        uint max = checkpoints.length.sub(1);&#13;
&#13;
        while (max &gt; min) {&#13;
            uint mid = (max.add(min).add(1)).div(2);&#13;
            if (checkpoints[mid].fromBlock &lt;= _block) {&#13;
                min = mid;&#13;
            } else {&#13;
                max = mid.sub(1);&#13;
            }&#13;
        }&#13;
&#13;
        return checkpoints[min].value;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev `updateValueAtNow` used to update the `_CheckpointBalances` map and the `_CheckpointTotalSupply`&#13;
    * @param checkpoints The history of data being updated&#13;
    * @param _value The new number of tokens&#13;
    */&#13;
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value) internal {&#13;
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length.sub(1)].fromBlock &lt; block.number)) {&#13;
            checkpoints.push(Checkpoint(uint128(block.number), uint128(_value)));&#13;
        } else {&#13;
            checkpoints[checkpoints.length.sub(1)].value = uint128(_value);&#13;
        }&#13;
    }&#13;
}