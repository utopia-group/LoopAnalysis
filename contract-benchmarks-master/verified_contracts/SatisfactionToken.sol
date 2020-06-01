pragma solidity ^0.4.23;

library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

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

contract HasNoContracts is Ownable {

  /**
   * @dev Reclaim ownership of Ownable contracts
   * @param contractAddr The address of the Ownable to be reclaimed.
   */
  function reclaimContract(address contractAddr) external onlyOwner {
    Ownable contractInst = Ownable(contractAddr);
    contractInst.transferOwnership(owner);
  }
}

contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  function HasNoEther() public payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by settings a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    // solium-disable-next-line security/no-send
    assert(owner.send(address(this).balance));
  }
}

contract HasNoTokens is CanReclaimToken {

 /**
  * @dev Reject all ERC223 compatible tokens
  * @param from_ address The address that is transferring the tokens
  * @param value_ uint256 the amount of the specified token
  * @param data_ Bytes The data passed from the caller.
  */
  function tokenFallback(address from_, uint256 value_, bytes data_) external {
    from_;
    value_;
    data_;
    revert();
  }

}

contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

contract CheckpointStorage {

  /**
   * @dev `Checkpoint` is the structure that attaches a block number to a
   * @dev given value, the block number attached is the one that last changed the
   * @dev value
   */
  struct Checkpoint {
    // `fromBlock` is the block number that the value was generated from
    uint128 fromBlock;

    // `value` is the amount of tokens at a specific block number
    uint128 value;
  }

  // Tracks the history of the `totalSupply` of the token
  Checkpoint[] public totalSupplyHistory;

  /**
   * @dev `getValueAt` retrieves the number of tokens at a given block number
   *
   * @param checkpoints The history of values being queried
   * @param _block The block number to retrieve the value at
   * @return The number of tokens being queried
   */
  function getValueAt(Checkpoint[] storage checkpoints, uint _block) internal view returns (uint) {
    if (checkpoints.length == 0)
      return 0;

    // Shortcut for the actual value
    if (_block >= checkpoints[checkpoints.length - 1].fromBlock)
      return checkpoints[checkpoints.length - 1].value;
    if (_block < checkpoints[0].fromBlock)
      return 0;

    // Binary search of the value in the array
    uint min = 0;
    uint max = checkpoints.length - 1;
    while (max > min) {
      uint mid = (max + min + 1) / 2;
      if (checkpoints[mid].fromBlock <= _block) {
        min = mid;
      } else {
        max = mid - 1;
      }
    }
    return checkpoints[min].value;
  }

  /**
   * @dev `updateValueAtNow` used to update the `balances` map and the
   * @dev `totalSupplyHistory`
   *
   * @param checkpoints The history of data being updated
   * @param _value The new number of tokens
   */
  function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value) internal {
    if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
      Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
      newCheckPoint.fromBlock = uint128(block.number);
      newCheckPoint.value = uint128(_value);
    } else {
      Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length - 1];
      oldCheckPoint.value = uint128(_value);
    }
  }
}

contract SatisfactionToken is ERC20, CheckpointStorage, NoOwner {

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event Burn(address indexed burner, uint256 value);

  using SafeMath for uint256;

  string public name = "Satisfaction Token";
  uint8 public decimals = 18;
  string public symbol = "SAT";
  string public version;

  /**
   * `parentToken` is the Token address that was cloned to produce this token;
   *  it will be 0x0 for a token that was not cloned
   */
  SatisfactionToken public parentToken;

  /**
   * `parentSnapShotBlock` is the block number from the Parent Token that was
   *  used to determine the initial distribution of the Clone Token
   */
  uint256 public parentSnapShotBlock;

  // `creationBlock` is the block number that the Clone Token was created
  uint256 public creationBlock;

  /**
   * `balances` is the map that tracks the balance of each address, in this
   *  contract when the balance changes the block number that the change
   *  occurred is also included in the map
   */
  mapping(address => Checkpoint[]) internal balances;

  // `allowed` tracks any extra transfer rights as in all ERC20 tokens
  mapping(address => mapping(address => uint256)) internal allowed;

  // Flag that determines if the token is transferable or not.
  bool public transfersEnabled;

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  constructor(
    address _parentToken,
    uint256 _parentSnapShotBlock,
    string _tokenVersion,
    bool _transfersEnabled) public
  {
    version = _tokenVersion;
    parentToken = SatisfactionToken(_parentToken);
    parentSnapShotBlock = _parentSnapShotBlock;
    transfersEnabled = _transfersEnabled;
    creationBlock = block.number;
  }

  /**
   * @dev Transfer token for a specified address
   *
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(transfersEnabled);
    require(parentSnapShotBlock < block.number);
    require(_to != address(0));

    uint256 lastBalance = balanceOfAt(msg.sender, block.number);
    require(_value <= lastBalance);

    return doTransfer(msg.sender, _to, _value, lastBalance);
  }

  /**
   * @dev Addition to ERC20 token methods. Transfer tokens to a specified
   * @dev address and execute a call with the sent data on the same transaction
   *
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   * @param _data ABI-encoded contract call to call `_to` address.
   *
   * @return true if the call function was executed successfully
   */
  function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
    require(_to != address(this));

    transfer(_to, _value);

    // solium-disable-next-line security/no-call-value
    require(_to.call.value(msg.value)(_data));
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   *
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(transfersEnabled);
    require(parentSnapShotBlock < block.number);
    require(_to != address(0));
    require(_value <= allowed[_from][msg.sender]);

    uint256 lastBalance = balanceOfAt(_from, block.number);
    require(_value <= lastBalance);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    return doTransfer(_from, _to, _value, lastBalance);
  }

  /**
   * @dev Addition to ERC20 token methods. Transfer tokens from one address to
   * @dev another and make a contract call on the same transaction
   *
   * @param _from The address which you want to send tokens from
   * @param _to The address which you want to transfer to
   * @param _value The amout of tokens to be transferred
   * @param _data ABI-encoded contract call to call `_to` address.
   *
   * @return true if the call function was executed successfully
   */
  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    public payable returns (bool)
  {
    require(_to != address(this));

    transferFrom(_from, _to, _value);

    // solium-disable-next-line security/no-call-value
    require(_to.call.value(msg.value)(_data));
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
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
   *
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
   * @dev approve should be called when allowed[_spender] == 0. To increment
   * @dev allowed value is better to use this function to avoid 2 calls (and wait until
   * <span class="__cf_email__" data-cfemail="ed99ad89889b">[email protected]</span> he first transaction is mined)&#13;
   * @dev From MonolithDAO Token.sol&#13;
   *&#13;
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
   * @dev Addition to StandardToken methods. Increase the amount of tokens that&#13;
   * @dev an owner allowed to a spender and execute a call with the sent data.&#13;
   *&#13;
   * @dev approve should be called when allowed[_spender] == 0. To increment&#13;
   * @dev allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * @dev the first transaction is mined)&#13;
   * @dev From MonolithDAO Token.sol&#13;
   *&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _addedValue The amount of tokens to increase the allowance by.&#13;
   * @param _data ABI-encoded contract call to call `_spender` address.&#13;
   */&#13;
  function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public payable returns (bool) {&#13;
    require(_spender != address(this));&#13;
&#13;
    increaseApproval(_spender, _addedValue);&#13;
&#13;
    // solium-disable-next-line security/no-call-value&#13;
    require(_spender.call.value(msg.value)(_data));&#13;
&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
   *&#13;
   * @dev approve should be called when allowed[_spender] == 0. To decrement&#13;
   * @dev allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * @dev the first transaction is mined)&#13;
   * @dev From MonolithDAO Token.sol&#13;
   *&#13;
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
  /**&#13;
   * @dev Addition to StandardToken methods. Decrease the amount of tokens that&#13;
   * @dev an owner allowed to a spender and execute a call with the sent data.&#13;
   *&#13;
   * @dev approve should be called when allowed[_spender] == 0. To decrement&#13;
   * @dev allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * @dev the first transaction is mined)&#13;
   * @dev From MonolithDAO Token.sol&#13;
   *&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _subtractedValue The amount of tokens to decrease the allowance by.&#13;
   * @param _data ABI-encoded contract call to call `_spender` address.&#13;
   */&#13;
  function decreaseApprovalAndCall(address _spender, uint _subtractedValue, bytes _data) public payable returns (bool) {&#13;
    require(_spender != address(this));&#13;
&#13;
    decreaseApproval(_spender, _subtractedValue);&#13;
&#13;
    // solium-disable-next-line security/no-call-value&#13;
    require(_spender.call.value(msg.value)(_data));&#13;
&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @param _owner The address that's balance is being requested&#13;
   * @return The balance of `_owner` at the current block&#13;
   */&#13;
  function balanceOf(address _owner) public view returns (uint256) {&#13;
    return balanceOfAt(_owner, block.number);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Queries the balance of `_owner` at a specific `_blockNumber`&#13;
   *&#13;
   * @param _owner The address from which the balance will be retrieved&#13;
   * @param _blockNumber The block number when the balance is queried&#13;
   * @return The balance at `_blockNumber`&#13;
   */&#13;
  function balanceOfAt(address _owner, uint256 _blockNumber) public view returns (uint256) {&#13;
    // These next few lines are used when the balance of the token is&#13;
    //  requested before a check point was ever created for this token, it&#13;
    //  requires that the `parentToken.balanceOfAt` be queried at the&#13;
    //  genesis block for that token as this contains initial balance of&#13;
    //  this token&#13;
    if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock &gt; _blockNumber)) {&#13;
      if (address(parentToken) != address(0)) {&#13;
        return parentToken.balanceOfAt(_owner, Math.min256(_blockNumber, parentSnapShotBlock));&#13;
      } else {&#13;
        // Has no parent&#13;
        return 0;&#13;
      }&#13;
    // This will return the expected balance during normal situations&#13;
    } else {&#13;
      return getValueAt(balances[_owner], _blockNumber);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev This function makes it easy to get the total number of tokens&#13;
   *&#13;
   * @return The total number of tokens&#13;
   */&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return totalSupplyAt(block.number);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Total amount of tokens at a specific `_blockNumber`.&#13;
   *&#13;
   * @param _blockNumber The block number when the totalSupply is queried&#13;
   * @return The total amount of tokens at `_blockNumber`&#13;
   */&#13;
  function totalSupplyAt(uint256 _blockNumber) public view returns(uint256) {&#13;
&#13;
    // These next few lines are used when the totalSupply of the token is&#13;
    //  requested before a check point was ever created for this token, it&#13;
    //  requires that the `parentToken.totalSupplyAt` be queried at the&#13;
    //  genesis block for this token as that contains totalSupply of this&#13;
    //  token at this block number.&#13;
    if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock &gt; _blockNumber)) {&#13;
      if (address(parentToken) != 0) {&#13;
        return parentToken.totalSupplyAt(Math.min256(_blockNumber, parentSnapShotBlock));&#13;
      } else {&#13;
        return 0;&#13;
      }&#13;
    // This will return the expected totalSupply during normal situations&#13;
    } else {&#13;
      return getValueAt(totalSupplyHistory, _blockNumber);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to mint tokens&#13;
   *&#13;
   * @param _to The address that will receive the minted tokens.&#13;
   * @param _amount The amount of tokens to mint.&#13;
   * @return A boolean that indicates if the operation was successful.&#13;
   */&#13;
  function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {&#13;
    uint256 curTotalSupply = totalSupply();&#13;
    uint256 lastBalance = balanceOf(_to);&#13;
&#13;
    updateValueAtNow(totalSupplyHistory, curTotalSupply.add(_amount));&#13;
    updateValueAtNow(balances[_to], lastBalance.add(_amount));&#13;
&#13;
    emit Mint(_to, _amount);&#13;
    emit Transfer(address(0), _to, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to stop minting new tokens.&#13;
   *&#13;
   * @return True if the operation was successful.&#13;
   */&#13;
  function finishMinting() public onlyOwner canMint returns (bool) {&#13;
    mintingFinished = true;&#13;
    emit MintFinished();&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Burns a specific amount of tokens.&#13;
   *&#13;
   * @param _value uint256 The amount of token to be burned.&#13;
   */&#13;
  function burn(uint256 _value) public {&#13;
    uint256 lastBalance = balanceOf(msg.sender);&#13;
    require(_value &lt;= lastBalance);&#13;
&#13;
    address burner = msg.sender;&#13;
    uint256 curTotalSupply = totalSupply();&#13;
&#13;
    updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_value));&#13;
    updateValueAtNow(balances[burner], lastBalance.sub(_value));&#13;
&#13;
    emit Burn(burner, _value);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Burns a specific amount of tokens from an address&#13;
   *&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _value uint256 The amount of token to be burned.&#13;
   */&#13;
  function burnFrom(address _from, uint256 _value) public {&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
    uint256 lastBalance = balanceOfAt(_from, block.number);&#13;
    require(_value &lt;= lastBalance);&#13;
&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
&#13;
    address burner = _from;&#13;
    uint256 curTotalSupply = totalSupply();&#13;
&#13;
    updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_value));&#13;
    updateValueAtNow(balances[burner], lastBalance.sub(_value));&#13;
&#13;
    emit Burn(burner, _value);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Enables token holders to transfer their tokens freely if true&#13;
   *&#13;
   * @param _transfersEnabled True if transfers are allowed in the clone&#13;
   */&#13;
  function enableTransfers(bool _transfersEnabled) public onlyOwner canMint {&#13;
    transfersEnabled = _transfersEnabled;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev This is the actual transfer function in the token contract, it can&#13;
   * @dev only be called by other functions in this contract.&#13;
   *&#13;
   * @param _from The address holding the tokens being transferred&#13;
   * @param _to The address of the recipient&#13;
   * @param _value The amount of tokens to be transferred&#13;
   * @param _lastBalance The last balance of from&#13;
   * @return True if the transfer was successful&#13;
   */&#13;
  function doTransfer(address _from, address _to, uint256 _value, uint256 _lastBalance) internal returns (bool) {&#13;
    if (_value == 0) {&#13;
      return true;&#13;
    }&#13;
&#13;
    updateValueAtNow(balances[_from], _lastBalance.sub(_value));&#13;
&#13;
    uint256 previousBalance = balanceOfAt(_to, block.number);&#13;
    updateValueAtNow(balances[_to], previousBalance.add(_value));&#13;
&#13;
    emit Transfer(_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
}