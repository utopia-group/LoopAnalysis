pragma solidity ^0.4.23;

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

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
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
    emit Transfer(_from, _to, _value);
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
    emit Approval(msg.sender, _spender, _value);
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
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor (string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f88b8c9d9e9996d69f9d978a9f9db89b97968b9d968b818bd6969d8c">[email protected]</a>&gt;&#13;
contract MultiSigWallet {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event Confirmation(address indexed sender, uint indexed transactionId);&#13;
    event Revocation(address indexed sender, uint indexed transactionId);&#13;
    event Submission(uint indexed transactionId);&#13;
    event Execution(uint indexed transactionId);&#13;
    event ExecutionFailure(uint indexed transactionId);&#13;
    event Deposit(address indexed sender, uint value);&#13;
    event OwnerAddition(address indexed owner);&#13;
    event OwnerRemoval(address indexed owner);&#13;
    event RequirementChange(uint required);&#13;
&#13;
    /*&#13;
     *  Constants&#13;
     */&#13;
    uint constant public MAX_OWNER_COUNT = 50;&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    mapping (uint =&gt; Transaction) public transactions;&#13;
    mapping (uint =&gt; mapping (address =&gt; bool)) public confirmations;&#13;
    mapping (address =&gt; bool) public isOwner;&#13;
    address[] public owners;&#13;
    uint public required;&#13;
    uint public transactionCount;&#13;
&#13;
    struct Transaction {&#13;
        address destination;&#13;
        uint value;&#13;
        bytes data;&#13;
        bool executed;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Modifiers&#13;
     */&#13;
    modifier onlyWallet() {&#13;
        require(msg.sender == address(this));&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerDoesNotExist(address owner) {&#13;
        require(!isOwner[owner]);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerExists(address owner) {&#13;
        require(isOwner[owner]);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier transactionExists(uint transactionId) {&#13;
        require(transactions[transactionId].destination != 0);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier confirmed(uint transactionId, address owner) {&#13;
        require(confirmations[transactionId][owner]);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notConfirmed(uint transactionId, address owner) {&#13;
        require(!confirmations[transactionId][owner]);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notExecuted(uint transactionId) {&#13;
        require(!transactions[transactionId].executed);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notNull(address _address) {&#13;
        require(_address != 0);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier validRequirement(uint ownerCount, uint _required) {&#13;
        require(ownerCount &lt;= MAX_OWNER_COUNT &amp;&amp; _required &lt;= ownerCount &amp;&amp; _required != 0 &amp;&amp; ownerCount != 0);&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev Fallback function allows to deposit ether.&#13;
    function() public payable&#13;
    {&#13;
        if (msg.value &gt; 0) emit Deposit(msg.sender, msg.value);&#13;
    }&#13;
&#13;
    /*&#13;
     * Public functions&#13;
     */&#13;
    constructor () public&#13;
    {&#13;
        isOwner[msg.sender] = true;&#13;
        owners.push(msg.sender);&#13;
        emit OwnerAddition(msg.sender);&#13;
        required = 1;&#13;
    }&#13;
&#13;
    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.&#13;
    /// @param owner Address of new owner.&#13;
    function addOwner(address owner)&#13;
        public&#13;
        onlyWallet&#13;
        ownerDoesNotExist(owner)&#13;
        notNull(owner)&#13;
        validRequirement(owners.length + 1, required)&#13;
    {&#13;
        isOwner[owner] = true;&#13;
        owners.push(owner);&#13;
        emit OwnerAddition(owner);&#13;
    }&#13;
&#13;
    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.&#13;
    /// @param owner Address of owner.&#13;
    function removeOwner(address owner)&#13;
        public&#13;
        onlyWallet&#13;
        ownerExists(owner)&#13;
    {&#13;
        isOwner[owner] = false;&#13;
        for (uint i=0; i&lt;owners.length - 1; i++)&#13;
            if (owners[i] == owner) {&#13;
                owners[i] = owners[owners.length - 1];&#13;
                break;&#13;
            }&#13;
        owners.length -= 1;&#13;
        if (required &gt; owners.length)&#13;
            changeRequirement(owners.length);&#13;
        emit OwnerRemoval(owner);&#13;
    }&#13;
&#13;
    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.&#13;
    /// @param owner Address of owner to be replaced.&#13;
    /// @param newOwner Address of new owner.&#13;
    function replaceOwner(address owner, address newOwner)&#13;
        public&#13;
        onlyWallet&#13;
        ownerExists(owner)&#13;
        ownerDoesNotExist(newOwner)&#13;
    {&#13;
        for (uint i=0; i&lt;owners.length; i++)&#13;
            if (owners[i] == owner) {&#13;
                owners[i] = newOwner;&#13;
                break;&#13;
            }&#13;
        isOwner[owner] = false;&#13;
        isOwner[newOwner] = true;&#13;
        emit OwnerRemoval(owner);&#13;
        emit OwnerAddition(newOwner);&#13;
    }&#13;
&#13;
    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.&#13;
    /// @param _required Number of required confirmations.&#13;
    function changeRequirement(uint _required)&#13;
        public&#13;
        onlyWallet&#13;
        validRequirement(owners.length, _required)&#13;
    {&#13;
        required = _required;&#13;
        emit RequirementChange(_required);&#13;
    }&#13;
&#13;
    /// @dev Allows an owner to submit and confirm a transaction.&#13;
    /// @param destination Transaction target address.&#13;
    /// @param value Transaction ether value.&#13;
    /// @param data Transaction data payload.&#13;
    /// @return Returns transaction ID.&#13;
    function submitTransaction(address destination, uint value, bytes data)&#13;
        public&#13;
        returns (uint transactionId)&#13;
    {&#13;
        transactionId = addTransaction(destination, value, data);&#13;
        confirmTransaction(transactionId);&#13;
    }&#13;
&#13;
    /// @dev Allows an owner to confirm a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    function confirmTransaction(uint transactionId)&#13;
        public&#13;
        ownerExists(msg.sender)&#13;
        transactionExists(transactionId)&#13;
        notConfirmed(transactionId, msg.sender)&#13;
    {&#13;
        confirmations[transactionId][msg.sender] = true;&#13;
        emit Confirmation(msg.sender, transactionId);&#13;
        executeTransaction(transactionId);&#13;
    }&#13;
&#13;
    /// @dev Allows an owner to revoke a confirmation for a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    function revokeConfirmation(uint transactionId)&#13;
        public&#13;
        ownerExists(msg.sender)&#13;
        confirmed(transactionId, msg.sender)&#13;
        notExecuted(transactionId)&#13;
    {&#13;
        confirmations[transactionId][msg.sender] = false;&#13;
        emit Revocation(msg.sender, transactionId);&#13;
    }&#13;
&#13;
    /// @dev Allows anyone to execute a confirmed transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    function executeTransaction(uint transactionId)&#13;
        public&#13;
        ownerExists(msg.sender)&#13;
        confirmed(transactionId, msg.sender)&#13;
        notExecuted(transactionId)&#13;
    {&#13;
        if (isConfirmed(transactionId)) {&#13;
            Transaction storage txn = transactions[transactionId];&#13;
            txn.executed = true;&#13;
            if (external_call(txn.destination, txn.value, txn.data.length, txn.data))&#13;
                emit Execution(transactionId);&#13;
            else {&#13;
                emit ExecutionFailure(transactionId);&#13;
                txn.executed = false;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    // call has been separated into its own function in order to take advantage&#13;
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.&#13;
    function external_call(address destination, uint value, uint dataLength, bytes data) private returns (bool) {&#13;
        bool result;&#13;
        assembly {&#13;
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)&#13;
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that&#13;
            result := call(&#13;
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting&#13;
                                   // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +&#13;
                                   // callNewAccountGas (25000, in case the destination address does not exist and needs creating)&#13;
                destination,&#13;
                value,&#13;
                d,&#13;
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem&#13;
                x,&#13;
                0                  // Output is ignored, therefore the output size is zero&#13;
            )&#13;
        }&#13;
        return result;&#13;
    }&#13;
&#13;
    /// @dev Returns the confirmation status of a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    /// @return Confirmation status.&#13;
    function isConfirmed(uint transactionId)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        uint count = 0;&#13;
        for (uint i=0; i&lt;owners.length; i++) {&#13;
            if (confirmations[transactionId][owners[i]])&#13;
                count += 1;&#13;
            if (count == required)&#13;
                return true;&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * Internal functions&#13;
     */&#13;
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.&#13;
    /// @param destination Transaction target address.&#13;
    /// @param value Transaction ether value.&#13;
    /// @param data Transaction data payload.&#13;
    /// @return Returns transaction ID.&#13;
    function addTransaction(address destination, uint value, bytes data)&#13;
        internal&#13;
        notNull(destination)&#13;
        returns (uint transactionId)&#13;
    {&#13;
        transactionId = transactionCount;&#13;
        transactions[transactionId] = Transaction({&#13;
            destination: destination,&#13;
            value: value,&#13;
            data: data,&#13;
            executed: false&#13;
        });&#13;
        transactionCount += 1;&#13;
        emit Submission(transactionId);&#13;
    }&#13;
&#13;
    /*&#13;
     * Web3 call functions&#13;
     */&#13;
    /// @dev Returns number of confirmations of a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    /// @return Number of confirmations.&#13;
    function getConfirmationCount(uint transactionId)&#13;
        public&#13;
        constant&#13;
        returns (uint count)&#13;
    {&#13;
        for (uint i=0; i&lt;owners.length; i++) {&#13;
            if (confirmations[transactionId][owners[i]]) count += 1;&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Returns total number of transactions after filers are applied.&#13;
    /// @param pending Include pending transactions.&#13;
    /// @param executed Include executed transactions.&#13;
    /// @return Total number of transactions after filters are applied.&#13;
    function getTransactionCount(bool pending, bool executed)&#13;
        public&#13;
        constant&#13;
        returns (uint count)&#13;
    {&#13;
      for ( uint i=0; i&lt;transactionCount; i++ ) {&#13;
        if ( pending &amp;&amp; !transactions[i].executed || executed &amp;&amp; transactions[i].executed )&#13;
           count += 1;&#13;
      }&#13;
    }&#13;
&#13;
    /// @dev Returns list of owners.&#13;
    /// @return List of owner addresses.&#13;
    function getOwners()&#13;
        public&#13;
        constant&#13;
        returns (address[])&#13;
    {&#13;
        return owners;&#13;
    }&#13;
&#13;
    /// @dev Returns array with owner addresses, which confirmed transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    /// @return Returns array of owner addresses.&#13;
    function getConfirmations(uint transactionId)&#13;
        public&#13;
        constant&#13;
        returns (address[] _confirmations)&#13;
    {&#13;
        address[] memory confirmationsTemp = new address[](owners.length);&#13;
        uint count = 0;&#13;
        uint i;&#13;
        for (i=0; i&lt;owners.length; i++)&#13;
            if (confirmations[transactionId][owners[i]]) {&#13;
                confirmationsTemp[count] = owners[i];&#13;
                count += 1;&#13;
            }&#13;
        _confirmations = new address[](count);&#13;
        for (i=0; i&lt;count; i++)&#13;
            _confirmations[i] = confirmationsTemp[i];&#13;
    }&#13;
&#13;
    /// @dev Returns list of transaction IDs in defined range.&#13;
    /// @param from Index start position of transaction array.&#13;
    /// @param to Index end position of transaction array.&#13;
    /// @param pending Include pending transactions.&#13;
    /// @param executed Include executed transactions.&#13;
    /// @return Returns array of transaction IDs.&#13;
    function getTransactionIds(uint from, uint to, bool pending, bool executed)&#13;
        public&#13;
        constant&#13;
        returns (uint[] _transactionIds)&#13;
    {&#13;
        uint[] memory transactionIdsTemp = new uint[](transactionCount);&#13;
        uint count = 0;&#13;
        uint i;&#13;
        for (i=0; i&lt;transactionCount; i++)&#13;
            if (   pending &amp;&amp; !transactions[i].executed&#13;
                || executed &amp;&amp; transactions[i].executed)&#13;
            {&#13;
                transactionIdsTemp[count] = i;&#13;
                count += 1;&#13;
            }&#13;
        _transactionIds = new uint[](to - from);&#13;
        for (i=from; i&lt;to; i++)&#13;
            _transactionIds[i - from] = transactionIdsTemp[i];&#13;
    }&#13;
}&#13;
&#13;
contract NomadPreICO is&#13;
    StandardToken, &#13;
    Ownable, &#13;
    DetailedERC20("preNSP", "NOMAD SPACE NETWORK preICO TOKEN", 18)&#13;
    , MultiSigWallet&#13;
{&#13;
    using SafeMath for uint256;&#13;
&#13;
    //TODO проверить, что не смогу записывать в данные переменные&#13;
    uint256 public StartDate     = 1527811200;       // 01 June 2018 00:00:00 UTC&#13;
    uint256 public EndDate       = 1538351999;       // 30 September 2018 г., 23:59:59&#13;
    uint256 public ExchangeRate  = 762000000000000000000; // 762*10*10^18&#13;
    uint256 public hardCap       = 5000000*ExchangeRate; // $5M&#13;
    uint256 public softCap       = 1000000*ExchangeRate; // $1M&#13;
&#13;
    //TODO Check test comment&#13;
    //uint256 public onlyTestTimestamp = 0;&#13;
    //function onlyTestSetTimestamp(uint256 newTimestamp) public {&#13;
      //  onlyTestTimestamp = newTimestamp;&#13;
    //}&#13;
&#13;
    //TODO Check test comment&#13;
    function getTimestamp() public view returns (uint256) {&#13;
        return block.timestamp;&#13;
    //    if (onlyTestTimestamp!=0) {return onlyTestTimestamp; } else {return block.timestamp;}&#13;
    }&#13;
&#13;
    function setExchangeRate(uint256 newExchangeRate) &#13;
        onlyOwner &#13;
        public&#13;
    {&#13;
        require(getTimestamp() &lt; StartDate);&#13;
        ExchangeRate = newExchangeRate;&#13;
        hardCap      = 5000000*ExchangeRate;&#13;
        softCap      = 1000000*ExchangeRate;&#13;
    }&#13;
&#13;
    address[] senders;&#13;
    mapping(address =&gt; uint256) sendersCalcTokens;&#13;
    mapping(address =&gt; uint256) sendersEth;&#13;
&#13;
    function getSenders          (               ) public view returns (address[]) {return senders                   ;}&#13;
    function getSendersCalcTokens(address _sender) public view returns (uint256 )  {return sendersCalcTokens[_sender];}&#13;
    function getSendersEth       (address _sender) public view returns (uint256)   {return sendersEth       [_sender];}&#13;
&#13;
    function () payable public {&#13;
        require(msg.value &gt; 0); &#13;
        require(getTimestamp() &gt;= StartDate);&#13;
        require(getTimestamp() &lt;= EndDate);&#13;
        require(Eth2USD(address(this).balance) &lt;= hardCap);&#13;
        &#13;
        sendersEth[msg.sender] = sendersEth[msg.sender].add(msg.value);&#13;
        sendersCalcTokens[msg.sender] = sendersCalcTokens[msg.sender].add( Eth2preNSP(msg.value) );&#13;
&#13;
        for (uint i=0; i&lt;senders.length; i++) &#13;
            if (senders[i] == msg.sender) return;&#13;
        senders.push(msg.sender);        &#13;
    }&#13;
&#13;
    bool public mvpExists = false;&#13;
    bool public softCapOk = false;&#13;
&#13;
    function setMvpExists(bool _mvpExists) &#13;
        public &#13;
        onlyWallet &#13;
    { mvpExists = _mvpExists; }&#13;
    &#13;
    function checkSoftCapOk() public { &#13;
        require(!softCapOk);&#13;
        if( softCap &lt;= Eth2USD(address(this).balance) ) softCapOk = true;&#13;
    }&#13;
&#13;
    address withdrawalAddress;&#13;
    function setWithdrawalAddress (address _withdrawalAddress) public onlyWallet { &#13;
        withdrawalAddress = _withdrawalAddress;&#13;
    }&#13;
    &#13;
    function release() public onlyWallet {&#13;
        releaseETH();&#13;
        releaseTokens();&#13;
    }&#13;
&#13;
    function releaseETH() public onlyWallet {&#13;
        if(address(this).balance &gt; 0 &amp;&amp; softCapOk &amp;&amp; mvpExists)&#13;
            address(withdrawalAddress).transfer(address(this).balance);&#13;
    }&#13;
&#13;
    function releaseTokens() public onlyWallet {&#13;
        if(softCapOk &amp;&amp; mvpExists)&#13;
            for (uint i=0; i&lt;senders.length; i++)&#13;
                releaseTokens4Sender(i);&#13;
    }&#13;
&#13;
    function releaseTokens4Sender(uint senderNum) public onlyWallet {&#13;
        address sender = senders[senderNum];&#13;
        uint256 tokens = sendersCalcTokens[sender];&#13;
        if (tokens&gt;0) {&#13;
            sendersCalcTokens[sender] = 0;&#13;
            mint(sender, tokens);&#13;
        }&#13;
    }&#13;
&#13;
    function mint(address _to, uint256 _amount) internal {&#13;
        totalSupply_ = totalSupply_.add(_amount);&#13;
        balances[_to] = balances[_to].add(_amount);&#13;
        emit Transfer(address(0), _to, _amount);&#13;
    }&#13;
&#13;
    function returnEth() public onlyWallet {&#13;
        require(getTimestamp() &gt; EndDate);&#13;
        require(!softCapOk || !mvpExists);&#13;
        &#13;
        for (uint i=0; i&lt;senders.length; i++)&#13;
            returnEth4Sender(i);&#13;
    }&#13;
&#13;
    function returnEth4Sender(uint senderNum) public onlyWallet {&#13;
        require(getTimestamp() &gt; EndDate);&#13;
        require(!softCapOk || !mvpExists);&#13;
        &#13;
        address sender = senders[senderNum];&#13;
        sendersEth[sender] = 0;&#13;
        address(sender).transfer(sendersEth[sender]);&#13;
    }&#13;
&#13;
    function GetTokenPriceCents() public view returns (uint256) {&#13;
        require(getTimestamp() &gt;= StartDate);&#13;
        require(getTimestamp() &lt;= EndDate);&#13;
        if( (getTimestamp() &gt;= 1527811200)&amp;&amp;(getTimestamp() &lt; 1530403200) ) return 4; // June &#13;
        else                   &#13;
        if( (getTimestamp() &gt;= 1530403200)&amp;&amp;(getTimestamp() &lt; 1533081600) ) return 5; // July&#13;
        else&#13;
        if( (getTimestamp() &gt;= 1533081600)&amp;&amp;(getTimestamp() &lt; 1535760000) ) return 6; // August &#13;
        else&#13;
        if( (getTimestamp() &gt;= 1535760000)&amp;&amp;(getTimestamp() &lt; 1538352000) ) return 8; // September&#13;
        else revert();&#13;
    }&#13;
&#13;
    function Eth2USD(uint256 _wei) public view returns (uint256) {&#13;
        return _wei*ExchangeRate;&#13;
    }&#13;
&#13;
    function Eth2preNSP(uint256 _wei) public view returns (uint256) {&#13;
        return Eth2USD(_wei)*100/GetTokenPriceCents();&#13;
    }&#13;
}