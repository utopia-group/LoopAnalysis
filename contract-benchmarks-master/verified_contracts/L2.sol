pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/CappedToken.sol

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */
contract CappedToken is MintableToken {

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
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
    returns (bool)
  {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

// File: contracts/SmartToken.sol

interface IERC223Receiver {
  function tokenFallback(address _from, uint256 _value, bytes _data) external;
}


/// @title Smart token implementation compatible with ERC20, ERC223, Mintable, Burnable and Pausable tokens
/// @author Aler Denisov <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a1c0cdc4d38fdbc0ccd1c8cdcdcee1c6ccc0c8cd8fc2cecc">[email protected]</a>&gt;&#13;
contract SmartToken is BurnableToken, CappedToken, PausableToken {&#13;
  constructor(uint256 _cap) public CappedToken(_cap) {}&#13;
&#13;
  event Transfer(address indexed from, address indexed to, uint256 value, bytes data);&#13;
&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  ) public returns (bool) &#13;
  {&#13;
    bytes memory empty;&#13;
    return transferFrom(&#13;
      _from, &#13;
      _to, &#13;
      _value, &#13;
      empty&#13;
    );&#13;
  }&#13;
&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value,&#13;
    bytes _data&#13;
  ) public returns (bool)&#13;
  {&#13;
    require(_value &lt;= allowed[_from][msg.sender], "Used didn't allow sender to interact with balance");&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    if (isContract(_to)) {&#13;
      return transferToContract(&#13;
        _from, &#13;
        _to, &#13;
        _value, &#13;
        _data&#13;
      ); &#13;
    } else {&#13;
      return transferToAddress(&#13;
        _from, &#13;
        _to, &#13;
        _value, &#13;
        _data&#13;
      );&#13;
    }&#13;
  }&#13;
&#13;
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool success) {&#13;
    if (isContract(_to)) {&#13;
      return transferToContract(&#13;
        msg.sender,&#13;
        _to,&#13;
        _value,&#13;
        _data&#13;
      );&#13;
    } else {&#13;
      return transferToAddress(&#13;
        msg.sender,&#13;
        _to,&#13;
        _value,&#13;
        _data&#13;
      );&#13;
    }&#13;
  }&#13;
&#13;
  function transfer(address _to, uint256 _value) public returns (bool success) {&#13;
    bytes memory empty;&#13;
    return transfer(_to, _value, empty);&#13;
  }&#13;
&#13;
  function isContract(address _addr) internal view returns (bool) {&#13;
    uint256 length;&#13;
    // solium-disable-next-line security/no-inline-assembly&#13;
    assembly {&#13;
      //retrieve the size of the code on target address, this needs assembly&#13;
      length := extcodesize(_addr)&#13;
    } &#13;
    return (length&gt;0);&#13;
  }&#13;
&#13;
  function moveTokens(address _from, address _to, uint256 _value) internal returns (bool success) {&#13;
    require(balanceOf(_from) &gt;= _value, "Balance isn't enough");&#13;
    balances[_from] = balanceOf(_from).sub(_value);&#13;
    balances[_to] = balanceOf(_to).add(_value);&#13;
&#13;
    return true;&#13;
  }&#13;
&#13;
  function transferToAddress(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value,&#13;
    bytes _data&#13;
  ) internal returns (bool success) &#13;
  {&#13;
    require(moveTokens(_from, _to, _value), "Tokens movement was failed");&#13;
    emit Transfer(_from, _to, _value);&#13;
    emit Transfer(&#13;
      _from,&#13;
      _to,&#13;
      _value,&#13;
      _data&#13;
    );&#13;
    return true;&#13;
  }&#13;
  &#13;
  //function that is called when transaction target is a contract&#13;
  function transferToContract(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value,&#13;
    bytes _data&#13;
  ) internal returns (bool success) &#13;
  {&#13;
    require(moveTokens(_from, _to, _value), "Tokens movement was failed");&#13;
    IERC223Receiver(_to).tokenFallback(_from, _value, _data);&#13;
    emit Transfer(_from, _to, _value);&#13;
    emit Transfer(&#13;
      _from,&#13;
      _to,&#13;
      _value,&#13;
      _data&#13;
    );&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/SmartMultichainToken.sol&#13;
&#13;
contract SmartMultichainToken is SmartToken {&#13;
  event BlockchainExchange(&#13;
    address indexed from, &#13;
    uint256 value, &#13;
    uint256 indexed newNetwork, &#13;
    bytes32 adr&#13;
  );&#13;
&#13;
  constructor(uint256 _cap) public SmartToken(_cap) {}&#13;
  /// @dev Function to burn tokens and rise event for burn tokens in another network&#13;
  /// @param _amount The amount of tokens that will burn&#13;
  /// @param _network The index of target network.&#13;
  /// @param _adr The address in new network&#13;
  function blockchainExchange(&#13;
    uint256 _amount, &#13;
    uint256 _network, &#13;
    bytes32 _adr&#13;
  ) public &#13;
  {&#13;
    burn(_amount);&#13;
    cap.sub(_amount);&#13;
    emit BlockchainExchange(&#13;
      msg.sender, &#13;
      _amount, &#13;
      _network, &#13;
      _adr&#13;
    );&#13;
  }&#13;
&#13;
  /// @dev Function to burn allowed tokens from special address and rise event for burn tokens in another network&#13;
  /// @param _from The address of holder&#13;
  /// @param _amount The amount of tokens that will burn&#13;
  /// @param _network The index of target network.&#13;
  /// @param _adr The address in new network&#13;
  function blockchainExchangeFrom(&#13;
    address _from,&#13;
    uint256 _amount, &#13;
    uint256 _network, &#13;
    bytes32 _adr&#13;
  ) public &#13;
  {&#13;
    require(_amount &lt;= allowed[_from][msg.sender], "Used didn't allow sender to interact with balance");&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);&#13;
    _burn(_from, _amount);&#13;
    emit BlockchainExchange(&#13;
      msg.sender, &#13;
      _amount, &#13;
      _network,&#13;
      _adr&#13;
    );&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/Blacklist.sol&#13;
&#13;
contract Blacklist is BurnableToken, Ownable {&#13;
  mapping (address =&gt; bool) public blacklist;&#13;
&#13;
  event DestroyedBlackFunds(address _blackListedUser, uint _balance);&#13;
  event AddedBlackList(address _user);&#13;
  event RemovedBlackList(address _user);&#13;
&#13;
  function isBlacklisted(address _maker) public view returns (bool) {&#13;
    return blacklist[_maker];&#13;
  }&#13;
&#13;
  function addBlackList(address _evilUser) public onlyOwner {&#13;
    blacklist[_evilUser] = true;&#13;
    emit AddedBlackList(_evilUser);&#13;
  }&#13;
&#13;
  function removeBlackList(address _clearedUser) public onlyOwner {&#13;
    blacklist[_clearedUser] = false;&#13;
    emit RemovedBlackList(_clearedUser);&#13;
  }&#13;
&#13;
  function destroyBlackFunds(address _blackListedUser) public onlyOwner {&#13;
    require(blacklist[_blackListedUser], "User isn't blacklisted");&#13;
    uint dirtyFunds = balanceOf(_blackListedUser);&#13;
    _burn(_blackListedUser, dirtyFunds);&#13;
    emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/TransferTokenPolicy.sol&#13;
&#13;
contract TransferTokenPolicy is SmartToken {&#13;
  modifier isTransferAllowed(address _from, address _to, uint256 _value) {&#13;
    require(_allowTransfer(_from, _to, _value), "Transfer isn't allowed");&#13;
    _;&#13;
  }&#13;
&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  ) public isTransferAllowed(_from, _to, _value) returns (bool)&#13;
  {&#13;
    return super.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value,&#13;
    bytes _data&#13;
  ) public isTransferAllowed(_from, _to, _value) returns (bool)&#13;
  {&#13;
    return super.transferFrom(&#13;
      _from,&#13;
      _to,&#13;
      _value,&#13;
      _data&#13;
    );&#13;
  }&#13;
&#13;
  function transfer(address _to, uint256 _value, bytes _data) public isTransferAllowed(msg.sender, _to, _value) returns (bool success) {&#13;
    return super.transfer(_to, _value, _data);&#13;
  }&#13;
&#13;
  function transfer(address _to, uint256 _value) public isTransferAllowed(msg.sender, _to, _value) returns (bool success) {&#13;
    return super.transfer(_to, _value);&#13;
  }&#13;
&#13;
  function burn(uint256 _amount) public isTransferAllowed(msg.sender, address(0x0), _amount) {&#13;
    super.burn(_amount);&#13;
  }&#13;
&#13;
  function _allowTransfer(address, address, uint256) internal returns(bool);&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol&#13;
&#13;
/**&#13;
 * @title DetailedERC20 token&#13;
 * @dev The decimals are only for visualization purposes.&#13;
 * All the operations are done using the smallest and indivisible token unit,&#13;
 * just as on Ethereum all the operations are done in wei.&#13;
 */&#13;
contract DetailedERC20 is ERC20 {&#13;
  string public name;&#13;
  string public symbol;&#13;
  uint8 public decimals;&#13;
&#13;
  constructor(string _name, string _symbol, uint8 _decimals) public {&#13;
    name = _name;&#13;
    symbol = _symbol;&#13;
    decimals = _decimals;&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/L2.sol&#13;
&#13;
contract L2 is TransferTokenPolicy, SmartMultichainToken, Blacklist, DetailedERC20 {&#13;
  uint256 private precision = 4; &#13;
  constructor() public&#13;
    DetailedERC20(&#13;
      "L2",&#13;
      "L2",&#13;
      uint8(precision)&#13;
    )&#13;
    SmartMultichainToken(&#13;
      40 * 10 ** (7 + precision) // 40 millions with decimals&#13;
    ) {&#13;
  }&#13;
&#13;
  function _allowTransfer(address _from, address _to, uint256) internal returns(bool) {&#13;
    return !isBlacklisted(_from) &amp;&amp; !isBlacklisted(_to);&#13;
  }&#13;
}