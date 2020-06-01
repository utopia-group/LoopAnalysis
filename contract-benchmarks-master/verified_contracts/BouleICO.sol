pragma solidity ^0.4.11;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

pragma solidity ^0.4.11;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
contract Ownable {
  address public owner;


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
    if (msg.sender != owner) {
      throw;
    }
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to. 
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

pragma solidity ^0.4.11;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

pragma solidity ^0.4.11;




/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value);
  function approve(address spender, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.4.11;




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
  function transfer(address _to, uint256 _value) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

pragma solidity ^0.4.11;




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
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

pragma solidity ^0.4.11;





/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    if(mintingFinished) throw;
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

pragma solidity ^0.4.11;


/*
    Copyright 2017, Giovanni Zorzato (Boulé Foundation)
*/

contract BouleToken is MintableToken {
    // BouleToken is an OpenZeppelin Mintable Token
    string public name = "Boule Token";
    string public symbol = "BOU";
    uint public decimals = 18;

    // do no allow to send ether to this token
    function () public payable {
        throw;
    }

}



pragma solidity ^0.4.4;


/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <<span class="__cf_email__" data-cfemail="394a4d5c5f5857175e5c564b5e5c795a56574a5c574a404a17575c4d">[email protected]</span>&gt;&#13;
contract MultiSigWallet {&#13;
&#13;
    uint constant public MAX_OWNER_COUNT = 50;&#13;
&#13;
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
    modifier onlyWallet() {&#13;
        if (msg.sender != address(this))&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerDoesNotExist(address owner) {&#13;
        if (isOwner[owner])&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerExists(address owner) {&#13;
        if (!isOwner[owner])&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier transactionExists(uint transactionId) {&#13;
        if (transactions[transactionId].destination == 0)&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier confirmed(uint transactionId, address owner) {&#13;
        if (!confirmations[transactionId][owner])&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notConfirmed(uint transactionId, address owner) {&#13;
        if (confirmations[transactionId][owner])&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notExecuted(uint transactionId) {&#13;
        if (transactions[transactionId].executed)&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notNull(address _address) {&#13;
        if (_address == 0)&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier validRequirement(uint ownerCount, uint _required) {&#13;
        if (   ownerCount &gt; MAX_OWNER_COUNT&#13;
            || _required &gt; ownerCount&#13;
            || _required == 0&#13;
            || ownerCount == 0)&#13;
            throw;&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev Fallback function allows to deposit ether.&#13;
    function()&#13;
        payable&#13;
    {&#13;
        if (msg.value &gt; 0)&#13;
            Deposit(msg.sender, msg.value);&#13;
    }&#13;
&#13;
    /*&#13;
     * Public functions&#13;
     */&#13;
    /// @dev Contract constructor sets initial owners and required number of confirmations.&#13;
    /// @param _owners List of initial owners.&#13;
    /// @param _required Number of required confirmations.&#13;
    function MultiSigWallet(address[] _owners, uint _required)&#13;
        public&#13;
        validRequirement(_owners.length, _required)&#13;
    {&#13;
        for (uint i=0; i&lt;_owners.length; i++) {&#13;
            if (isOwner[_owners[i]] || _owners[i] == 0)&#13;
                throw;&#13;
            isOwner[_owners[i]] = true;&#13;
        }&#13;
        owners = _owners;&#13;
        required = _required;&#13;
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
        OwnerAddition(owner);&#13;
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
        OwnerRemoval(owner);&#13;
    }&#13;
&#13;
    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.&#13;
    /// @param owner Address of owner to be replaced.&#13;
    /// @param owner Address of new owner.&#13;
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
        OwnerRemoval(owner);&#13;
        OwnerAddition(newOwner);&#13;
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
        RequirementChange(_required);&#13;
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
        Confirmation(msg.sender, transactionId);&#13;
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
        Revocation(msg.sender, transactionId);&#13;
    }&#13;
&#13;
    /// @dev Allows anyone to execute a confirmed transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    function executeTransaction(uint transactionId)&#13;
        public&#13;
        notExecuted(transactionId)&#13;
    {&#13;
        if (isConfirmed(transactionId)) {&#13;
            Transaction tx = transactions[transactionId];&#13;
            tx.executed = true;&#13;
            if (tx.destination.call.value(tx.value)(tx.data))&#13;
                Execution(transactionId);&#13;
            else {&#13;
                ExecutionFailure(transactionId);&#13;
                tx.executed = false;&#13;
            }&#13;
        }&#13;
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
        Submission(transactionId);&#13;
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
        for (uint i=0; i&lt;owners.length; i++)&#13;
            if (confirmations[transactionId][owners[i]])&#13;
                count += 1;&#13;
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
        for (uint i=0; i&lt;transactionCount; i++)&#13;
            if (   pending &amp;&amp; !transactions[i].executed&#13;
                || executed &amp;&amp; transactions[i].executed)&#13;
                count += 1;&#13;
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
pragma solidity ^0.4.11;&#13;
&#13;
&#13;
/*&#13;
    Copyright 2017, Giovanni Zorzato (Boulé Foundation)&#13;
 */&#13;
&#13;
&#13;
contract BouleICO is Ownable{&#13;
&#13;
    uint public startTime;             // unix ts in which the sale starts.&#13;
    uint public secondPriceTime;       // unix ts in which the second price triggers.&#13;
    uint public thirdPriceTime;        // unix ts in which the third price starts.&#13;
    uint public fourthPriceTime;       // unix ts in which the fourth price starts.&#13;
    uint public endTime;               // unix ts in which the sale end.&#13;
&#13;
    address public bouleDevMultisig;   // The address to hold the funds donated&#13;
&#13;
    uint public totalCollected = 0;    // In wei&#13;
    bool public saleStopped = false;   // Has Boulé stopped the sale?&#13;
    bool public saleFinalized = false; // Has Boulé finalized the sale?&#13;
&#13;
    BouleToken public token;           // The token&#13;
&#13;
    MultiSigWallet wallet;             // Multisig&#13;
&#13;
    uint constant public minInvestment = 0.1 ether;    // Minimum investment  0.1 ETH&#13;
&#13;
    /** Addresses that are allowed to invest even before ICO opens. For testing, for ICO partners, etc. */&#13;
    mapping (address =&gt; bool) public whitelist;&#13;
&#13;
    event NewBuyer(address indexed holder, uint256 bouAmount, uint256 amount);&#13;
    event Whitelisted(address addr, bool status);&#13;
&#13;
    function BouleICO (&#13;
    address _token,&#13;
    address _bouleDevMultisig,&#13;
    uint _startTime,&#13;
    uint _secondPriceTime,&#13;
    uint _thirdPriceTime,&#13;
    uint _fourthPriceTime,&#13;
    uint _endTime&#13;
    )&#13;
    {&#13;
        if (_startTime &gt;= _endTime) throw;&#13;
&#13;
        // Save constructor arguments as global variables&#13;
        token = BouleToken(_token);&#13;
        bouleDevMultisig = _bouleDevMultisig;&#13;
        // create wallet object&#13;
        wallet = MultiSigWallet(bouleDevMultisig);&#13;
&#13;
        startTime = _startTime;&#13;
        secondPriceTime = _secondPriceTime;&#13;
        thirdPriceTime = _thirdPriceTime;&#13;
        fourthPriceTime = _fourthPriceTime;&#13;
        endTime = _endTime;&#13;
    }&#13;
&#13;
    // change whitelist status for a specific address&#13;
    function setWhitelistStatus(address addr, bool status)&#13;
    onlyOwner {&#13;
        whitelist[addr] = status;&#13;
        Whitelisted(addr, status);&#13;
    }&#13;
&#13;
    // @notice Get the price for a BOU token at current time (how many tokens for 1 ETH)&#13;
    // @return price of BOU&#13;
    function getPrice() constant public returns (uint256) {&#13;
        var time = getNow();&#13;
        if(time &lt; startTime){&#13;
            // whitelist&#13;
            return 1400;&#13;
        }&#13;
        if(time &lt; secondPriceTime){&#13;
            return 1200; //20%&#13;
        }&#13;
        if(time &lt; thirdPriceTime){&#13;
            return 1150; //15%&#13;
        }&#13;
        if(time &lt; fourthPriceTime){&#13;
            return 1100; //10%&#13;
        }&#13;
        return 1050; //5%&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
        * Get the amount of unsold tokens allocated to this contract;&#13;
    */&#13;
    function getTokensLeft() public constant returns (uint) {&#13;
        return token.balanceOf(this);&#13;
    }&#13;
&#13;
&#13;
    /// The fallback function is called when ether is sent to the contract, it&#13;
    /// simply calls `doPayment()` with the address that sent the ether as the&#13;
    /// `_owner`. Payable is a required solidity modifier for functions to receive&#13;
    /// ether, without this modifier functions will throw if ether is sent to them&#13;
&#13;
    function () public payable {&#13;
        doPayment(msg.sender);&#13;
    }&#13;
&#13;
&#13;
&#13;
    /// @dev `doPayment()` is an internal function that sends the ether that this&#13;
    ///  contract receives to the bouleDevMultisig and creates tokens in the address of the&#13;
    /// @param _owner The address that will hold the newly created tokens&#13;
&#13;
    function doPayment(address _owner)&#13;
    only_during_sale_period_or_whitelisted(_owner)&#13;
    only_sale_not_stopped&#13;
    non_zero_address(_owner)&#13;
    minimum_value(minInvestment)&#13;
    internal {&#13;
        // Calculate how many tokens at current price&#13;
        uint256 tokenAmount = SafeMath.mul(msg.value, getPrice());&#13;
        // do not allow selling more than what we have&#13;
        if(tokenAmount &gt; getTokensLeft()) {&#13;
            throw;&#13;
        }&#13;
        // transfer token (it will throw error if transaction is not valid)&#13;
        token.transfer(_owner, tokenAmount);&#13;
&#13;
        // record total selling&#13;
        totalCollected = SafeMath.add(totalCollected, msg.value);&#13;
&#13;
        NewBuyer(_owner, tokenAmount, msg.value);&#13;
    }&#13;
&#13;
    // @notice Function to stop sale for an emergency.&#13;
    // @dev Only Boulé Dev can do it after it has been activated.&#13;
    function emergencyStopSale()&#13;
    only_sale_not_stopped&#13;
    onlyOwner&#13;
    public {&#13;
        saleStopped = true;&#13;
    }&#13;
&#13;
    // @notice Function to restart stopped sale.&#13;
    // @dev Only Boulé can do it after it has been disabled and sale is ongoing.&#13;
    function restartSale()&#13;
    only_during_sale_period&#13;
    only_sale_stopped&#13;
    onlyOwner&#13;
    public {&#13;
        saleStopped = false;&#13;
    }&#13;
&#13;
&#13;
    // @notice Moves funds in sale contract to Boulé MultiSigWallet.&#13;
    // @dev  Moves funds in sale contract to Boulé MultiSigWallet.&#13;
    function moveFunds()&#13;
    onlyOwner&#13;
    public {&#13;
        // move funds&#13;
        if (!wallet.send(this.balance)) throw;&#13;
    }&#13;
&#13;
&#13;
    function finalizeSale()&#13;
    only_after_sale&#13;
    onlyOwner&#13;
    public {&#13;
        doFinalizeSale();&#13;
    }&#13;
&#13;
    function doFinalizeSale()&#13;
    internal {&#13;
        // move all remaining eth in the sale contract into multisig wallet&#13;
        if (!wallet.send(this.balance)) throw;&#13;
        // transfer remaining tokens&#13;
        token.transfer(bouleDevMultisig, getTokensLeft());&#13;
&#13;
        saleFinalized = true;&#13;
        saleStopped = true;&#13;
    }&#13;
&#13;
    function getNow() internal constant returns (uint) {&#13;
        return now;&#13;
    }&#13;
&#13;
    modifier only(address x) {&#13;
        if (msg.sender != x) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier only_during_sale_period {&#13;
        if (getNow() &lt; startTime) throw;&#13;
        if (getNow() &gt;= endTime) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    // valid only during sale or before sale if the sender is whitelisted&#13;
    modifier only_during_sale_period_or_whitelisted(address x) {&#13;
        if (getNow() &lt; startTime &amp;&amp; !whitelist[x]) throw;&#13;
        if (getNow() &gt;= endTime) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier only_after_sale {&#13;
        if (getNow() &lt; endTime) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier only_sale_stopped {&#13;
        if (!saleStopped) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier only_sale_not_stopped {&#13;
        if (saleStopped) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier non_zero_address(address x) {&#13;
        if (x == 0) throw;&#13;
        _;&#13;
    }&#13;
&#13;
    modifier minimum_value(uint256 x) {&#13;
        if (msg.value &lt; x) throw;&#13;
        _;&#13;
    }&#13;
}