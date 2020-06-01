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
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2e5c4b434d416e1c">[email protected]</a>π.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this ether.&#13;
 * @notice Ether can still be sent to this contract by:&#13;
 * calling functions labeled `payable`&#13;
 * `selfdestruct(contract_address)`&#13;
 * mining directly to the contract address&#13;
 */&#13;
contract HasNoEther is Ownable {&#13;
&#13;
  /**&#13;
  * @dev Constructor that rejects incoming Ether&#13;
  * The `payable` flag is added so we can access `msg.value` without compiler warning. If we&#13;
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable&#13;
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively&#13;
  * we could use assembly to access msg.value.&#13;
  */&#13;
  constructor() public payable {&#13;
    require(msg.value == 0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Disallows direct send by settings a default function without the `payable` flag.&#13;
   */&#13;
  function() external {&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfer all Ether held by the contract to the owner.&#13;
   */&#13;
  function reclaimEther() external onlyOwner {&#13;
    owner.transfer(address(this).balance);&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title SafeERC20&#13;
 * @dev Wrappers around ERC20 operations that throw on failure.&#13;
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,&#13;
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.&#13;
 */&#13;
library SafeERC20 {&#13;
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {&#13;
    require(token.transfer(to, value));&#13;
  }&#13;
&#13;
  function safeTransferFrom(&#13;
    ERC20 token,&#13;
    address from,&#13;
    address to,&#13;
    uint256 value&#13;
  )&#13;
    internal&#13;
  {&#13;
    require(token.transferFrom(from, to, value));&#13;
  }&#13;
&#13;
  function safeApprove(ERC20 token, address spender, uint256 value) internal {&#13;
    require(token.approve(spender, value));&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Contracts that should be able to recover tokens&#13;
 * @author SylTi&#13;
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.&#13;
 * This will prevent any accidental loss of tokens.&#13;
 */&#13;
contract CanReclaimToken is Ownable {&#13;
  using SafeERC20 for ERC20Basic;&#13;
&#13;
  /**&#13;
   * @dev Reclaim all ERC20Basic compatible tokens&#13;
   * @param token ERC20Basic The address of the token contract&#13;
   */&#13;
  function reclaimToken(ERC20Basic token) external onlyOwner {&#13;
    uint256 balance = token.balanceOf(this);&#13;
    token.safeTransfer(owner, balance);&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5321363e303c1361">[email protected]</a>π.com&gt;&#13;
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
&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Contracts that should not own Contracts&#13;
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e89a8d858b87a8da">[email protected]</a>π.com&gt;&#13;
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
    contractInst.transferOwnership(owner);&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Base contract for contracts that should not own things.&#13;
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7b091e1618143b49">[email protected]</a>π.com&gt;&#13;
 * @dev Solves a class of errors where a contract accidentally becomes owner of Ether, Tokens or&#13;
 * Owned contracts. See respective base contracts for details.&#13;
 */&#13;
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Burnable Token&#13;
 * @dev Token that can be irreversibly burned (destroyed).&#13;
 */&#13;
contract BurnableToken is BasicToken {&#13;
&#13;
  event Burn(address indexed burner, uint256 value);&#13;
&#13;
  /**&#13;
   * @dev Burns a specific amount of tokens.&#13;
   * @param _value The amount of token to be burned.&#13;
   */&#13;
  function burn(uint256 _value) public {&#13;
    _burn(msg.sender, _value);&#13;
  }&#13;
&#13;
  function _burn(address _who, uint256 _value) internal {&#13;
    require(_value &lt;= balances[_who]);&#13;
    // no need to require value &lt;= totalSupply, since that would imply the&#13;
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure&#13;
&#13;
    balances[_who] = balances[_who].sub(_value);&#13;
    totalSupply_ = totalSupply_.sub(_value);&#13;
    emit Burn(_who, _value);&#13;
    emit Transfer(_who, address(0), _value);&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
/*&#13;
Copyright 2018 Vibeo&#13;
&#13;
Licensed under the Apache License, Version 2.0 (the "License");&#13;
you may not use this file except in compliance with the License.&#13;
You may obtain a copy of the License at&#13;
&#13;
    http://www.apache.org/licenses/LICENSE-2.0&#13;
&#13;
Unless required by applicable law or agreed to in writing, software&#13;
distributed under the License is distributed on an "AS IS" BASIS,&#13;
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.&#13;
See the License for the specific language governing permissions and&#13;
limitations under the License.&#13;
 */&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract CustomWhitelist is Ownable {&#13;
  mapping(address =&gt; bool) public whitelist;&#13;
  uint256 public numberOfWhitelists;&#13;
&#13;
  event WhitelistedAddressAdded(address _addr);&#13;
  event WhitelistedAddressRemoved(address _addr);&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account that's not whitelisted.&#13;
   */&#13;
  modifier onlyWhitelisted() {&#13;
    require(whitelist[msg.sender] || msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  constructor() public {&#13;
    whitelist[msg.sender] = true;&#13;
    numberOfWhitelists = 1;&#13;
    emit WhitelistedAddressAdded(msg.sender);&#13;
  }&#13;
  /**&#13;
   * @dev add an address to the whitelist&#13;
   * @param _addr address&#13;
   */&#13;
  function addAddressToWhitelist(address _addr) onlyWhitelisted  public {&#13;
    require(_addr != address(0));&#13;
    require(!whitelist[_addr]);&#13;
&#13;
    whitelist[_addr] = true;&#13;
    numberOfWhitelists++;&#13;
&#13;
    emit WhitelistedAddressAdded(_addr);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove an address from the whitelist&#13;
   * @param _addr address&#13;
   */&#13;
  function removeAddressFromWhitelist(address _addr) onlyWhitelisted  public {&#13;
    require(_addr != address(0));&#13;
    require(whitelist[_addr]);&#13;
    //the owner can not be unwhitelisted&#13;
    require(_addr != owner);&#13;
&#13;
    whitelist[_addr] = false;&#13;
    numberOfWhitelists--;&#13;
&#13;
    emit WhitelistedAddressRemoved(_addr);&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Pausable&#13;
 * @dev Base contract which allows children to implement an emergency stop mechanism.&#13;
 */&#13;
contract CustomPausable is CustomWhitelist {&#13;
  event Pause();&#13;
  event Unpause();&#13;
&#13;
  bool public paused = false;&#13;
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
  function pause() onlyWhitelisted whenNotPaused public {&#13;
    paused = true;&#13;
    emit Pause();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to unpause, returns to normal state&#13;
   */&#13;
  function unpause() onlyWhitelisted whenPaused public {&#13;
    paused = false;&#13;
    emit Unpause();&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Vibeo: A new era of Instant Messaging/Social app allowing access to a blockchain community.&#13;
 */&#13;
contract VibeoToken is StandardToken, BurnableToken, NoOwner, CustomPausable {&#13;
  string public constant name = "Vibeo";&#13;
  string public constant symbol = "VBEO";&#13;
  uint8 public constant decimals = 18;&#13;
&#13;
  uint256 public constant MAX_SUPPLY = 950000000 * (10 ** uint256(decimals)); //950 M&#13;
&#13;
  ///@notice When transfers are disabled, no one except the transfer agents can use the transfer function.&#13;
  bool public transfersEnabled;&#13;
&#13;
  ///@notice This signifies that the ICO was successful.&#13;
  bool public softCapReached;&#13;
&#13;
  mapping(bytes32 =&gt; bool) private mintingList;&#13;
&#13;
  ///@notice Transfer agents are allowed to perform transfers regardless of the transfer state.&#13;
  mapping(address =&gt; bool) private transferAgents;&#13;
&#13;
  ///@notice The end date of the crowdsale. &#13;
  uint256 public icoEndDate;&#13;
  uint256 private year = 365 * 1 days;&#13;
&#13;
  event TransferAgentSet(address agent, bool state);&#13;
  event BulkTransferPerformed(address[] _destinations, uint256[] _amounts);&#13;
&#13;
  constructor() public {&#13;
    mintTokens(msg.sender, 453000000);&#13;
    setTransferAgent(msg.sender, true);&#13;
  }&#13;
&#13;
  ///@notice Checks if the supplied address is able to perform transfers.&#13;
  ///@param _from The address to check against if the transfer is allowed.&#13;
  modifier canTransfer(address _from) {&#13;
    if (!transfersEnabled &amp;&amp; !transferAgents[_from]) {&#13;
      revert();&#13;
    }&#13;
    _;&#13;
  }&#13;
&#13;
  ///@notice Computes keccak256 hash of the supplied value.&#13;
  ///@param _key The string value to compute hash from.&#13;
  function computeHash(string _key) private pure returns(bytes32){&#13;
    return keccak256(abi.encodePacked(_key));&#13;
  }&#13;
&#13;
  ///@notice Check if the minting for the supplied key was already performed.&#13;
  ///@param _key The key or category name of minting.&#13;
  modifier whenNotMinted(string _key) {&#13;
    if(mintingList[computeHash(_key)]) {&#13;
      revert();&#13;
    }&#13;
    &#13;
    _;&#13;
  }&#13;
&#13;
  ///@notice This function enables the whitelisted application (internal application) to set the ICO end date and can only be used once.&#13;
  ///@param _date The date to set as the ICO end date.&#13;
  function setICOEndDate(uint256 _date) public whenNotPaused onlyWhitelisted {&#13;
    require(icoEndDate == 0);&#13;
    icoEndDate = _date;&#13;
  }&#13;
&#13;
  ///@notice This function enables the whitelisted application (internal application) to set whether or not the softcap was reached.&#13;
  //This function can only be used once.&#13;
  function setSoftCapReached() public onlyWhitelisted {&#13;
    require(!softCapReached);&#13;
    softCapReached = true;&#13;
  }&#13;
&#13;
  ///@notice This function enables token transfers for everyone. Can only be enabled after the end of the ICO.&#13;
  function enableTransfers() public onlyWhitelisted {&#13;
    require(icoEndDate &gt; 0);&#13;
    require(now &gt;= icoEndDate);&#13;
    require(!transfersEnabled);&#13;
    transfersEnabled = true;&#13;
  }&#13;
&#13;
  ///@notice This function disables token transfers for everyone.&#13;
  function disableTransfers() public onlyWhitelisted {&#13;
    require(transfersEnabled);&#13;
    transfersEnabled = false;&#13;
  }&#13;
&#13;
  ///@notice Mints the tokens only once against the supplied key (category).&#13;
  ///@param _key The key or the category of the allocation to mint the tokens for.&#13;
  ///@param _amount The amount of tokens to mint.&#13;
  function mintOnce(string _key, address _to, uint256 _amount) private whenNotPaused whenNotMinted(_key) {&#13;
    mintTokens(_to, _amount);&#13;
    mintingList[computeHash(_key)] = true;&#13;
  }&#13;
&#13;
  ///@notice Mints the below-mentioned amount of tokens allocated to the Vibeo team. &#13;
  //The tokens are only available to the team after 1 year of the ICO end.&#13;
  function mintTeamTokens() public onlyWhitelisted {&#13;
    require(icoEndDate &gt; 0);&#13;
    require(softCapReached);&#13;
    &#13;
    if(now &lt; icoEndDate + year) {&#13;
      revert("Access is denied. The team tokens are locked for 1 year from the ICO end date.");&#13;
    }&#13;
&#13;
    mintOnce("team", msg.sender, 50000000);&#13;
  }&#13;
&#13;
  ///@notice Mints the below-mentioned amount of tokens allocated to the Vibeo treasury wallet. &#13;
  //The tokens are available only when the softcap is reached and the ICO end date is specified.&#13;
  function mintTreasuryTokens() public onlyWhitelisted {&#13;
    require(icoEndDate &gt; 0);&#13;
    require(softCapReached);&#13;
&#13;
    mintOnce("treasury", msg.sender, 90000000);&#13;
  }&#13;
&#13;
  ///@notice Mints the below-mentioned amount of tokens allocated to the Vibeo board advisors. &#13;
  //The tokens are only available to the team after 1 year of the ICO end.&#13;
  function mintAdvisorTokens() public onlyWhitelisted {&#13;
    require(icoEndDate &gt; 0);&#13;
&#13;
    if(now &lt; icoEndDate + year) {&#13;
      revert("Access is denied. The advisor tokens are locked for 1 year from the ICO end date.");&#13;
    }&#13;
&#13;
    mintOnce("advisorsTokens", msg.sender, 80000000);&#13;
  }&#13;
&#13;
  ///@notice Mints the below-mentioned amount of tokens allocated to the Vibeo partners. &#13;
  //The tokens are immediately available once the softcap is reached.&#13;
  function mintPartnershipTokens() public onlyWhitelisted {&#13;
    require(softCapReached);&#13;
    mintOnce("partnerships", msg.sender, 60000000);&#13;
  }&#13;
&#13;
  ///@notice Mints the below-mentioned amount of tokens allocated to reward the Vibeo community. &#13;
  //The tokens are immediately available once the softcap is reached.&#13;
  function mintCommunityRewards() public onlyWhitelisted {&#13;
    require(softCapReached);&#13;
    mintOnce("communityRewards", msg.sender, 90000000);&#13;
  }&#13;
&#13;
  ///@notice Mints the below-mentioned amount of tokens allocated to Vibeo user adoption. &#13;
  //The tokens are immediately available once the softcap is reached and ICO end date is specified.&#13;
  function mintUserAdoptionTokens() public onlyWhitelisted {&#13;
    require(icoEndDate &gt; 0);&#13;
    require(softCapReached);&#13;
&#13;
    mintOnce("useradoption", msg.sender, 95000000);&#13;
  }&#13;
&#13;
  ///@notice Mints the below-mentioned amount of tokens allocated to the Vibeo marketing channel. &#13;
  //The tokens are immediately available once the softcap is reached.&#13;
  function mintMarketingTokens() public onlyWhitelisted {&#13;
    require(softCapReached);&#13;
    mintOnce("marketing", msg.sender, 32000000);&#13;
  }&#13;
&#13;
  ///@notice Enables or disables the specified address to become a transfer agent.&#13;
  //Transfer agents are such wallet addresses which can perform transfers even when transfer state is disabled.&#13;
  ///@param _agent The wallet address of the transfer agent to assign or update.&#13;
  ///@param _state Sets the status of the supplied wallet address to be a transfer agent. &#13;
  ///When this is set to false, the address will no longer be considered as a transfer agent.&#13;
  function setTransferAgent(address _agent, bool _state) public whenNotPaused onlyWhitelisted {&#13;
    transferAgents[_agent] = _state;&#13;
    emit TransferAgentSet(_agent, _state);&#13;
  }&#13;
&#13;
  ///@notice Checks if the specified address is a transfer agent.&#13;
  ///@param _address The wallet address of the transfer agent to assign or update.&#13;
  ///When this is set to false, the address will no longer be considered as a transfer agent.&#13;
  function isTransferAgent(address _address) public constant onlyWhitelisted returns(bool) {&#13;
    return transferAgents[_address];&#13;
  }&#13;
&#13;
  ///@notice Transfers the specified value of tokens to the destination address. &#13;
  //Transfers can only happen when the tranfer state is enabled. &#13;
  //Transfer state can only be enabled after the end of the crowdsale.&#13;
  ///@param _to The destination wallet address to transfer funds to.&#13;
  ///@param _value The amount of tokens to send to the destination address.&#13;
  function transfer(address _to, uint256 _value) public whenNotPaused canTransfer(msg.sender) returns (bool) {&#13;
    require(_to != address(0));&#13;
    return super.transfer(_to, _value);&#13;
  }&#13;
&#13;
  ///@notice Mints the supplied value of the tokens to the destination address.&#13;
  //Minting cannot be performed any further once the maximum supply is reached.&#13;
  //This function is private and cannot be used by anyone except for this contract.&#13;
  ///@param _to The address which will receive the minted tokens.&#13;
  ///@param _value The amount of tokens to mint.&#13;
  function mintTokens(address _to, uint256 _value) private {&#13;
    require(_to != address(0));&#13;
    _value = _value.mul(10 ** uint256(decimals));&#13;
    require(totalSupply_.add(_value) &lt;= MAX_SUPPLY);&#13;
&#13;
    totalSupply_ = totalSupply_.add(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
  }&#13;
&#13;
  ///@notice Transfers tokens from a specified wallet address.&#13;
  ///@dev This function is overriden to leverage transfer state feature.&#13;
  ///@param _from The address to transfer funds from.&#13;
  ///@param _to The address to transfer funds to.&#13;
  ///@param _value The amount of tokens to transfer.&#13;
  function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    return super.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  ///@notice Approves a wallet address to spend on behalf of the sender.&#13;
  ///@dev This function is overriden to leverage transfer state feature.&#13;
  ///@param _spender The address which is approved to spend on behalf of the sender.&#13;
  ///@param _value The amount of tokens approve to spend. &#13;
  function approve(address _spender, uint256 _value) public canTransfer(msg.sender) returns (bool) {&#13;
    require(_spender != address(0));&#13;
    return super.approve(_spender, _value);&#13;
  }&#13;
&#13;
&#13;
  ///@notice Increases the approval of the spender.&#13;
  ///@dev This function is overriden to leverage transfer state feature.&#13;
  ///@param _spender The address which is approved to spend on behalf of the sender.&#13;
  ///@param _addedValue The added amount of tokens approved to spend.&#13;
  function increaseApproval(address _spender, uint256 _addedValue) public canTransfer(msg.sender) returns(bool) {&#13;
    require(_spender != address(0));&#13;
    return super.increaseApproval(_spender, _addedValue);&#13;
  }&#13;
&#13;
  ///@notice Decreases the approval of the spender.&#13;
  ///@dev This function is overriden to leverage transfer state feature.&#13;
  ///@param _spender The address of the spender to decrease the allocation from.&#13;
  ///@param _subtractedValue The amount of tokens to subtract from the approved allocation.&#13;
  function decreaseApproval(address _spender, uint256 _subtractedValue) public canTransfer(msg.sender) whenNotPaused returns (bool) {&#13;
    require(_spender != address(0));&#13;
    return super.decreaseApproval(_spender, _subtractedValue);&#13;
  }&#13;
&#13;
  ///@notice Returns the sum of supplied values.&#13;
  ///@param _values The collection of values to create the sum from.  &#13;
  function sumOf(uint256[] _values) private pure returns(uint256) {&#13;
    uint256 total = 0;&#13;
&#13;
    for (uint256 i = 0; i &lt; _values.length; i++) {&#13;
      total = total.add(_values[i]);&#13;
    }&#13;
&#13;
    return total;&#13;
  }&#13;
&#13;
  ///@notice Allows only the admins and/or whitelisted applications to perform bulk transfer operation.&#13;
  ///@param _destinations The destination wallet addresses to send funds to.&#13;
  ///@param _amounts The respective amount of fund to send to the specified addresses. &#13;
  function bulkTransfer(address[] _destinations, uint256[] _amounts) public onlyWhitelisted {&#13;
    require(_destinations.length == _amounts.length);&#13;
&#13;
    //Saving gas by determining if the sender has enough balance&#13;
    //to post this transaction.&#13;
    uint256 requiredBalance = sumOf(_amounts);&#13;
    require(balances[msg.sender] &gt;= requiredBalance);&#13;
    &#13;
    for (uint256 i = 0; i &lt; _destinations.length; i++) {&#13;
     transfer(_destinations[i], _amounts[i]);&#13;
    }&#13;
&#13;
    emit BulkTransferPerformed(_destinations, _amounts);&#13;
  }&#13;
&#13;
  ///@notice Burns the coins held by the sender.&#13;
  ///@param _value The amount of coins to burn.&#13;
  ///@dev This function is overriden to leverage Pausable feature.&#13;
  function burn(uint256 _value) public whenNotPaused {&#13;
    super.burn(_value);&#13;
  }&#13;
}