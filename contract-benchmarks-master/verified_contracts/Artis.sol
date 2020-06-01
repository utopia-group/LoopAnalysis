pragma solidity ^0.4.18;
//this is just a basic ERC20 token implementation for testing
//this contract could be deployed as is but for now just serves as a mock for scratch token
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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

/////////////////////////////////////////////////////////////////////////////////////////////



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
  function Ownable() public {
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
  function transferContractOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
/////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
   emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////
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

/////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @title Contactable token
 * @dev Basic version of a contactable contract, allowing the owner to provide a string with their
 * contact information.
 */
contract Contactable is Ownable {

  string public contactInformation;

  /**
    * @dev Allows the owner to set a string with their contact information.
    * @param info The contact information to attach to the contract.
    */
  function setContactInformation(string info) onlyOwner public {
    contactInformation = info;
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////
/**
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e795828a8488a7d5">[email protected]</a>π.com&gt;&#13;
 * @dev Should contracts (anything Ownable) end up being owned by this contract, it allows the owner&#13;
 * of this contract to reclaim ownership of the contracts.&#13;
 */&#13;
contract HasNoContracts is Ownable {&#13;
&#13;
  /**&#13;
   * @dev Reclaim ownership of Ownable contracts&#13;
   * @param contractAddr The address of the Ownable to be reclaimed.&#13;
   */&#13;
  function reclaimContract(address contractAddr) external onlyOwner {&#13;
    Ownable contractInst = Ownable(contractAddr);&#13;
    contractInst.transferContractOwnership(owner);&#13;
  }&#13;
}&#13;
/////////////////////////////////////////////////////////////////////////////////////////////&#13;
&#13;
/////////////////////////////////////////////////////////////////////////////////////////////&#13;
/**&#13;
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8bf9eee6e8e4cbb9">[email protected]</a>π.com&gt;&#13;
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
  function tokenFallback(address from_, uint256 value_, bytes data_) pure external {&#13;
    from_;&#13;
    value_;&#13;
    data_;&#13;
    revert();&#13;
  }&#13;
&#13;
}&#13;
/////////////////////////////////////////////////////////////////////////////////////////////&#13;
/**&#13;
 * @title Destructible&#13;
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.&#13;
 */&#13;
contract Destructible is Ownable {&#13;
&#13;
  function Destructible() public payable { }&#13;
&#13;
  /**&#13;
   * @dev Transfers the current balance to the owner and terminates the contract.&#13;
   */&#13;
  function destroy() onlyOwner public {&#13;
    selfdestruct(owner);&#13;
  }&#13;
&#13;
  function destroyAndSend(address _recipient) onlyOwner public {&#13;
    selfdestruct(_recipient);&#13;
  }&#13;
}&#13;
/////////////////////////////////////////////////////////////////////////////////////////////&#13;
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
/////////////////////////////////////////////////////////////////////////////////////////////&#13;
contract ERC20Basic {&#13;
  string internal _symbol;&#13;
  string internal _name;&#13;
  uint8 internal _decimals;&#13;
  uint internal _totalSupply;&#13;
  mapping (address =&gt; uint) internal _balanceOf;&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint)) internal _allowances;&#13;
&#13;
  function ERC20Basic(string symbol, string name, uint8 decimals, uint totalSupply) public {&#13;
      _symbol = symbol;&#13;
      _name = name;&#13;
      _decimals = decimals;&#13;
      _totalSupply = totalSupply;&#13;
  }&#13;
&#13;
  function name() public constant returns (string) {&#13;
      return _name;&#13;
  }&#13;
&#13;
  function symbol() public constant returns (string) {&#13;
      return _symbol;&#13;
  }&#13;
&#13;
  function decimals() public constant returns (uint8) {&#13;
      return _decimals;&#13;
  }&#13;
&#13;
  function totalSupply() public constant returns (uint) {&#13;
      return _totalSupply;&#13;
  }&#13;
  function balanceOf(address _addr) public constant returns (uint);&#13;
  function transfer(address _to, uint _value) public returns (bool);&#13;
  event Transfer(address indexed _from, address indexed _to, uint _value);&#13;
}&#13;
/////////////////////////////////////////////////////////////////////////////////////////////&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender) public view returns (uint256);&#13;
  function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
/////////////////////////////////////////////////////////////////////////////////////////////&#13;
/**&#13;
 * @title SafeERC20&#13;
 * @dev Wrappers around ERC20 operations that throw on failure.&#13;
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,&#13;
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.&#13;
 */&#13;
library SafeERC20 {&#13;
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {&#13;
    assert(token.transfer(to, value));&#13;
  }&#13;
&#13;
  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {&#13;
    assert(token.transferFrom(from, to, value));&#13;
  }&#13;
&#13;
  function safeApprove(ERC20 token, address spender, uint256 value) internal {&#13;
    assert(token.approve(spender, value));&#13;
  }&#13;
}&#13;
/////////////////////////////////////////////////////////////////////////////////////////////&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances.&#13;
 */&#13;
contract BasicToken is ERC20Basic, Ownable {&#13;
  using SafeMath for uint256;&#13;
&#13;
 mapping (address =&gt; bool) public frozenAccount;&#13;
 event FrozenFunds(address target, bool frozen);&#13;
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
   function freezeAccount(address target, bool freeze) onlyOwner external {&#13;
         frozenAccount[target] = freeze;&#13;
         emit FrozenFunds(target, freeze);&#13;
         }&#13;
&#13;
  /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
      require(!frozenAccount[msg.sender]);&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= _balanceOf[msg.sender]);&#13;
&#13;
    // SafeMath.sub will throw if there is not enough balance.&#13;
    _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);&#13;
    _balanceOf[_to] = _balanceOf[_to].add(_value);&#13;
    emit Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param _owner The address to query the the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
    return _balanceOf[_owner];&#13;
  }&#13;
&#13;
}&#13;
/////////////////////////////////////////////////////////////////////////////////////////////&#13;
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
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
    require(!frozenAccount[_from] &amp;&amp; !frozenAccount[_to] &amp;&amp; !frozenAccount[msg.sender]);&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= _balanceOf[_from]);&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
    _balanceOf[_from] = _balanceOf[_from].sub(_value);&#13;
    _balanceOf[_to] = _balanceOf[_to].add(_value);&#13;
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
  function allowance(address _owner, address _spender) public view returns (uint256) {&#13;
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
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
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
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {&#13;
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
/////////////////////////////////////////////////////////////////////////////////////////////&#13;
contract PausableToken is StandardToken, Pausable {&#13;
&#13;
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.transfer(_to, _value);&#13;
  }&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.approve(_spender, _value);&#13;
  }&#13;
&#13;
  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {&#13;
    return super.increaseApproval(_spender, _addedValue);&#13;
  }&#13;
&#13;
  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {&#13;
    return super.decreaseApproval(_spender, _subtractedValue);&#13;
  }&#13;
}&#13;
/////////////////////////////////////////////////////////////////////////////////////////////&#13;
&#13;
contract Artis is ERC20Basic("ATS", "Artis", 18, 1000000000000000000000000000),  PausableToken, Destructible, Contactable, HasNoTokens, HasNoContracts {&#13;
&#13;
    using SafeMath for uint;&#13;
&#13;
    event Burn(address _from, uint256 _value);&#13;
    event Mint(address _to, uint _value);&#13;
&#13;
    constructor() public {&#13;
      _balanceOf[msg.sender] = _totalSupply;&#13;
    }&#13;
&#13;
       function totalSupply() public view returns (uint) {&#13;
           return _totalSupply;&#13;
       }&#13;
&#13;
       function balanceOf(address _addr) public view returns (uint) {&#13;
           return _balanceOf[_addr];&#13;
       }&#13;
&#13;
       function burn(address _from, uint256 _value) onlyOwner external {&#13;
        require(_balanceOf[_from] &gt;= 0);&#13;
        _balanceOf[_from] =  _balanceOf[_from].sub(_value);&#13;
        _totalSupply = _totalSupply.sub(_value);&#13;
        emit Burn(_from, _value);&#13;
      }&#13;
&#13;
&#13;
        function mintToken(address _to, uint256 _value) onlyOwner external  {&#13;
          require(!frozenAccount[msg.sender] &amp;&amp; !frozenAccount[_to]);&#13;
         _balanceOf[_to] = _balanceOf[_to].add(_value);&#13;
         _totalSupply = _totalSupply.add(_value);&#13;
         emit Mint(_to,_value);&#13;
       }&#13;
&#13;
&#13;
}