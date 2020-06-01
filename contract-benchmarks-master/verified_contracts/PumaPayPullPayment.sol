pragma solidity 0.4.25;

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

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

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

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

// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol

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

// File: contracts/PumaPayToken.sol

/// PumaPayToken inherits from MintableToken, which in turn inherits from StandardToken.
/// Super is used to bypass the original function signature and include the whenNotMinting modifier.
contract PumaPayToken is MintableToken {

    string public name = "PumaPay"; 
    string public symbol = "PMA";
    uint8 public decimals = 18;

    constructor() public {
    }

    /// This modifier will be used to disable all ERC20 functionalities during the minting process.
    modifier whenNotMinting() {
        require(mintingFinished);
        _;
    }

    /// @dev transfer token for a specified address
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    /// @return success bool Calling super.transfer and returns true if successful.
    function transfer(address _to, uint256 _value) public whenNotMinting returns (bool) {
        return super.transfer(_to, _value);
    }

    /// @dev Transfer tokens from one address to another.
    /// @param _from address The address which you want to send tokens from.
    /// @param _to address The address which you want to transfer to.
    /// @param _value uint256 the amount of tokens to be transferred.
    /// @return success bool Calling super.transferFrom and returns true if successful.
    function transferFrom(address _from, address _to, uint256 _value) public whenNotMinting returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
}

// File: contracts/PumaPayPullPayment.sol

/// @title PumaPay Pull Payment - Contract that facilitates our pull payment protocol
/// @author PumaPay Dev Team - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5b3f3e2d3e37342b3e29281b2b2e363a2b3a22753234">[email protected]</a>&gt;&#13;
contract PumaPayPullPayment is Ownable {&#13;
&#13;
    using SafeMath for uint256;&#13;
&#13;
    /// ===============================================================================================================&#13;
    ///                                      Events&#13;
    /// ===============================================================================================================&#13;
&#13;
    event LogExecutorAdded(address executor);&#13;
    event LogExecutorRemoved(address executor);&#13;
    event LogPaymentRegistered(address clientAddress, address beneficiaryAddress, string paymentID);&#13;
    event LogPaymentCancelled(address clientAddress, address beneficiaryAddress, string paymentID);&#13;
    event LogPullPaymentExecuted(address clientAddress, address beneficiaryAddress, string paymentID);&#13;
    event LogSetExchangeRate(string currency, uint256 exchangeRate);&#13;
&#13;
    /// ===============================================================================================================&#13;
    ///                                      Constants&#13;
    /// ===============================================================================================================&#13;
&#13;
    uint256 constant private DECIMAL_FIXER = 10 ** 10;    /// 1e^10 - This transforms the Rate from decimals to uint256&#13;
    uint256 constant private FIAT_TO_CENT_FIXER = 100;    /// Fiat currencies have 100 cents in 1 basic monetary unit.&#13;
    uint256 constant private ONE_ETHER = 1 ether;         /// PumaPay token has 18 decimals - same as one ETHER&#13;
    uint256 constant private MINIMUM_AMOUNT_OF_ETH_FOR_OPARATORS = 0.01 ether; /// minimum amount of ETHER the owner/executor should have&#13;
    uint256 constant private OVERFLOW_LIMITER_NUMBER = 10 ** 20; /// 1e^20 - This number is used to prevent numeric overflows&#13;
&#13;
    /// ===============================================================================================================&#13;
    ///                                      Members&#13;
    /// ===============================================================================================================&#13;
&#13;
    PumaPayToken public token;&#13;
&#13;
    mapping(string =&gt; uint256) private exchangeRates;&#13;
    mapping(address =&gt; bool) public executors;&#13;
    mapping(address =&gt; mapping(address =&gt; PullPayment)) public pullPayments;&#13;
&#13;
    struct PullPayment {&#13;
        string merchantID;                      /// ID of the merchant&#13;
        string paymentID;                       /// ID of the payment&#13;
        string currency;                        /// 3-letter abbr i.e. 'EUR' / 'USD' etc.&#13;
        uint256 initialPaymentAmountInCents;    /// initial payment amount in fiat in cents&#13;
        uint256 fiatAmountInCents;              /// payment amount in fiat in cents&#13;
        uint256 frequency;                      /// how often merchant can pull - in seconds&#13;
        uint256 numberOfPayments;               /// amount of pull payments merchant can make&#13;
        uint256 startTimestamp;                 /// when subscription starts - in seconds&#13;
        uint256 nextPaymentTimestamp;           /// timestamp of next payment&#13;
        uint256 lastPaymentTimestamp;           /// timestamp of last payment&#13;
        uint256 cancelTimestamp;                /// timestamp the payment was cancelled&#13;
    }&#13;
&#13;
    /// ===============================================================================================================&#13;
    ///                                      Modifiers&#13;
    /// ===============================================================================================================&#13;
    modifier isExecutor() {&#13;
        require(executors[msg.sender]);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier executorExists(address _executor) {&#13;
        require(executors[_executor]);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier executorDoesNotExists(address _executor) {&#13;
        require(!executors[_executor]);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier paymentExists(address _client, address _beneficiary) {&#13;
        require(doesPaymentExist(_client, _beneficiary));&#13;
        _;&#13;
    }&#13;
&#13;
    modifier paymentNotCancelled(address _client, address _beneficiary) {&#13;
        require(pullPayments[_client][_beneficiary].cancelTimestamp == 0);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isValidPullPaymentRequest(address _client, address _beneficiary, string _paymentID) {&#13;
        require(&#13;
            (pullPayments[_client][_beneficiary].initialPaymentAmountInCents &gt; 0 ||&#13;
            (now &gt;= pullPayments[_client][_beneficiary].startTimestamp &amp;&amp;&#13;
            now &gt;= pullPayments[_client][_beneficiary].nextPaymentTimestamp)&#13;
            )&#13;
            &amp;&amp;&#13;
            pullPayments[_client][_beneficiary].numberOfPayments &gt; 0 &amp;&amp;&#13;
        (pullPayments[_client][_beneficiary].cancelTimestamp == 0 ||&#13;
        pullPayments[_client][_beneficiary].cancelTimestamp &gt; pullPayments[_client][_beneficiary].nextPaymentTimestamp) &amp;&amp;&#13;
        keccak256(&#13;
            abi.encodePacked(pullPayments[_client][_beneficiary].paymentID)&#13;
        ) == keccak256(abi.encodePacked(_paymentID))&#13;
        );&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isValidDeletionRequest(string paymentID, address client, address beneficiary) {&#13;
        require(&#13;
            beneficiary != address(0) &amp;&amp;&#13;
            client != address(0) &amp;&amp;&#13;
            bytes(paymentID).length != 0&#13;
        );&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isValidAddress(address _address) {&#13;
        require(_address != address(0));&#13;
        _;&#13;
    }&#13;
&#13;
    /// ===============================================================================================================&#13;
    ///                                      Constructor&#13;
    /// ===============================================================================================================&#13;
&#13;
    /// @dev Contract constructor - sets the token address that the contract facilitates.&#13;
    /// @param _token Token Address.&#13;
    constructor (PumaPayToken _token)&#13;
    public&#13;
    {&#13;
        require(_token != address(0));&#13;
        token = _token;&#13;
    }&#13;
&#13;
    // @notice Will receive any eth sent to the contract&#13;
    function() external payable {&#13;
    }&#13;
&#13;
    /// ===============================================================================================================&#13;
    ///                                      Public Functions - Owner Only&#13;
    /// ===============================================================================================================&#13;
&#13;
    /// @dev Adds a new executor. - can be executed only by the onwer. &#13;
    /// When adding a new executor 1 ETH is tranferred to allow the executor to pay for gas.&#13;
    /// The balance of the owner is also checked and if funding is needed 1 ETH is transferred.&#13;
    /// @param _executor - address of the executor which cannot be zero address.&#13;
    function addExecutor(address _executor)&#13;
    public&#13;
    onlyOwner&#13;
    isValidAddress(_executor)&#13;
    executorDoesNotExists(_executor)&#13;
    {&#13;
        _executor.transfer(0.25 ether);&#13;
        executors[_executor] = true;&#13;
&#13;
        if (isFundingNeeded(owner)) {&#13;
            owner.transfer(0.5 ether);&#13;
        }&#13;
&#13;
        emit LogExecutorAdded(_executor);&#13;
    }&#13;
&#13;
    /// @dev Removes a new executor. - can be executed only by the onwer.&#13;
    /// The balance of the owner is checked and if funding is needed 1 ETH is transferred.&#13;
    /// @param _executor - address of the executor which cannot be zero address.&#13;
    function removeExecutor(address _executor)&#13;
    public&#13;
    onlyOwner&#13;
    isValidAddress(_executor)&#13;
    executorExists(_executor)&#13;
    {&#13;
        executors[_executor] = false;&#13;
        if (isFundingNeeded(owner)) {&#13;
            owner.transfer(0.5 ether);&#13;
        }&#13;
        emit LogExecutorRemoved(_executor);&#13;
    }&#13;
&#13;
    /// @dev Sets the exchange rate for a currency. - can be executed only by the onwer.&#13;
    /// Emits 'LogSetExchangeRate' with the currency and the updated rate.&#13;
    /// The balance of the owner is checked and if funding is needed 1 ETH is transferred.&#13;
    /// @param _currency - address of the executor which cannot be zero address&#13;
    /// @param _rate - address of the executor which cannot be zero address&#13;
    function setRate(string _currency, uint256 _rate)&#13;
    public&#13;
    onlyOwner&#13;
    returns (bool) {&#13;
        exchangeRates[_currency] = _rate;&#13;
        emit LogSetExchangeRate(_currency, _rate);&#13;
&#13;
        if (isFundingNeeded(owner)) {&#13;
            owner.transfer(0.5 ether);&#13;
        }&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /// ===============================================================================================================&#13;
    ///                                      Public Functions - Executors Only&#13;
    /// ===============================================================================================================&#13;
&#13;
    /// @dev Registers a new pull payment to the PumaPay Pull Payment Contract - The registration can be executed only by one of the executors of the PumaPay Pull Payment Contract&#13;
    /// and the PumaPay Pull Payment Contract checks that the pull payment has been singed by the client of the account.&#13;
    /// The balance of the executor (msg.sender) is checked and if funding is needed 1 ETH is transferred.&#13;
    /// Emits 'LogPaymentRegistered' with client address, beneficiary address and paymentID.&#13;
    /// @param v - recovery ID of the ETH signature. - https://github.com/ethereum/EIPs/issues/155&#13;
    /// @param r - R output of ECDSA signature.&#13;
    /// @param s - S output of ECDSA signature.&#13;
    /// @param _merchantID - ID of the merchant.&#13;
    /// @param _paymentID - ID of the payment.&#13;
    /// @param _client - client address that is linked to this pull payment.&#13;
    /// @param _beneficiary - address that is allowed to execute this pull payment.&#13;
    /// @param _currency - currency of the payment / 3-letter abbr i.e. 'EUR'.&#13;
    /// @param _fiatAmountInCents - payment amount in fiat in cents.&#13;
    /// @param _frequency - how often merchant can pull - in seconds.&#13;
    /// @param _numberOfPayments - amount of pull payments merchant can make&#13;
    /// @param _startTimestamp - when subscription starts - in seconds.&#13;
    function registerPullPayment(&#13;
        uint8 v,&#13;
        bytes32 r,&#13;
        bytes32 s,&#13;
        string _merchantID,&#13;
        string _paymentID,&#13;
        address _client,&#13;
        address _beneficiary,&#13;
        string _currency,&#13;
        uint256 _initialPaymentAmountInCents,&#13;
        uint256 _fiatAmountInCents,&#13;
        uint256 _frequency,&#13;
        uint256 _numberOfPayments,&#13;
        uint256 _startTimestamp&#13;
    )&#13;
    public&#13;
    isExecutor()&#13;
    {&#13;
        require(&#13;
            bytes(_paymentID).length &gt; 0 &amp;&amp;&#13;
            bytes(_currency).length &gt; 0 &amp;&amp;&#13;
            _client != address(0) &amp;&amp;&#13;
            _beneficiary != address(0) &amp;&amp;&#13;
            _fiatAmountInCents &gt; 0 &amp;&amp;&#13;
            _frequency &gt; 0 &amp;&amp;&#13;
            _frequency &lt; OVERFLOW_LIMITER_NUMBER &amp;&amp;&#13;
            _numberOfPayments &gt; 0 &amp;&amp;&#13;
            _startTimestamp &gt; 0 &amp;&amp;&#13;
            _startTimestamp &lt; OVERFLOW_LIMITER_NUMBER&#13;
        );&#13;
&#13;
        pullPayments[_client][_beneficiary].currency = _currency;&#13;
        pullPayments[_client][_beneficiary].initialPaymentAmountInCents = _initialPaymentAmountInCents;&#13;
        pullPayments[_client][_beneficiary].fiatAmountInCents = _fiatAmountInCents;&#13;
        pullPayments[_client][_beneficiary].frequency = _frequency;&#13;
        pullPayments[_client][_beneficiary].startTimestamp = _startTimestamp;&#13;
        pullPayments[_client][_beneficiary].numberOfPayments = _numberOfPayments;&#13;
&#13;
        require(isValidRegistration(v, r, s, _client, _beneficiary, pullPayments[_client][_beneficiary]));&#13;
&#13;
        pullPayments[_client][_beneficiary].merchantID = _merchantID;&#13;
        pullPayments[_client][_beneficiary].paymentID = _paymentID;&#13;
        pullPayments[_client][_beneficiary].nextPaymentTimestamp = _startTimestamp;&#13;
        pullPayments[_client][_beneficiary].lastPaymentTimestamp = 0;&#13;
        pullPayments[_client][_beneficiary].cancelTimestamp = 0;&#13;
&#13;
        if (isFundingNeeded(msg.sender)) {&#13;
            msg.sender.transfer(0.5 ether);&#13;
        }&#13;
&#13;
        emit LogPaymentRegistered(_client, _beneficiary, _paymentID);&#13;
    }&#13;
&#13;
    /// @dev Deletes a pull payment for a beneficiary - The deletion needs can be executed only by one of the executors of the PumaPay Pull Payment Contract&#13;
    /// and the PumaPay Pull Payment Contract checks that the beneficiary and the paymentID have been singed by the client of the account.&#13;
    /// This method sets the cancellation of the pull payment in the pull payments array for this beneficiary specified.&#13;
    /// The balance of the executor (msg.sender) is checked and if funding is needed 1 ETH is transferred.&#13;
    /// Emits 'LogPaymentCancelled' with beneficiary address and paymentID.&#13;
    /// @param v - recovery ID of the ETH signature. - https://github.com/ethereum/EIPs/issues/155&#13;
    /// @param r - R output of ECDSA signature.&#13;
    /// @param s - S output of ECDSA signature.&#13;
    /// @param _paymentID - ID of the payment.&#13;
    /// @param _client - client address that is linked to this pull payment.&#13;
    /// @param _beneficiary - address that is allowed to execute this pull payment.&#13;
    function deletePullPayment(&#13;
        uint8 v,&#13;
        bytes32 r,&#13;
        bytes32 s,&#13;
        string _paymentID,&#13;
        address _client,&#13;
        address _beneficiary&#13;
    )&#13;
    public&#13;
    isExecutor()&#13;
    paymentExists(_client, _beneficiary)&#13;
    paymentNotCancelled(_client, _beneficiary)&#13;
    isValidDeletionRequest(_paymentID, _client, _beneficiary)&#13;
    {&#13;
        require(isValidDeletion(v, r, s, _paymentID, _client, _beneficiary));&#13;
&#13;
        pullPayments[_client][_beneficiary].cancelTimestamp = now;&#13;
&#13;
        if (isFundingNeeded(msg.sender)) {&#13;
            msg.sender.transfer(0.5 ether);&#13;
        }&#13;
&#13;
        emit LogPaymentCancelled(_client, _beneficiary, _paymentID);&#13;
    }&#13;
&#13;
    /// ===============================================================================================================&#13;
    ///                                      Public Functions&#13;
    /// ===============================================================================================================&#13;
&#13;
    /// @dev Executes a pull payment for the msg.sender - The pull payment should exist and the payment request&#13;
    /// should be valid in terms of when it can be executed.&#13;
    /// Emits 'LogPullPaymentExecuted' with client address, msg.sender as the beneficiary address and the paymentID.&#13;
    /// Use Case 1: Single/Recurring Fixed Pull Payment (initialPaymentAmountInCents == 0 )&#13;
    /// ------------------------------------------------&#13;
    /// We calculate the amount in PMA using the rate for the currency specified in the pull payment&#13;
    /// and the 'fiatAmountInCents' and we transfer from the client account the amount in PMA.&#13;
    /// After execution we set the last payment timestamp to NOW, the next payment timestamp is incremented by&#13;
    /// the frequency and the number of payments is decresed by 1.&#13;
    /// Use Case 2: Recurring Fixed Pull Payment with initial fee (initialPaymentAmountInCents &gt; 0)&#13;
    /// ------------------------------------------------------------------------------------------------&#13;
    /// We calculate the amount in PMA using the rate for the currency specified in the pull payment&#13;
    /// and the 'initialPaymentAmountInCents' and we transfer from the client account the amount in PMA.&#13;
    /// After execution we set the last payment timestamp to NOW and the 'initialPaymentAmountInCents to ZERO.&#13;
    /// @param _client - address of the client from which the msg.sender requires to pull funds.&#13;
    function executePullPayment(address _client, string _paymentID)&#13;
    public&#13;
    paymentExists(_client, msg.sender)&#13;
    isValidPullPaymentRequest(_client, msg.sender, _paymentID)&#13;
    {&#13;
        uint256 amountInPMA;&#13;
        if (pullPayments[_client][msg.sender].initialPaymentAmountInCents &gt; 0) {&#13;
            amountInPMA = calculatePMAFromFiat(pullPayments[_client][msg.sender].initialPaymentAmountInCents, pullPayments[_client][msg.sender].currency);&#13;
            pullPayments[_client][msg.sender].initialPaymentAmountInCents = 0;&#13;
        } else {&#13;
            amountInPMA = calculatePMAFromFiat(pullPayments[_client][msg.sender].fiatAmountInCents, pullPayments[_client][msg.sender].currency);&#13;
&#13;
            pullPayments[_client][msg.sender].nextPaymentTimestamp = pullPayments[_client][msg.sender].nextPaymentTimestamp + pullPayments[_client][msg.sender].frequency;&#13;
            pullPayments[_client][msg.sender].numberOfPayments = pullPayments[_client][msg.sender].numberOfPayments - 1;&#13;
        }&#13;
        pullPayments[_client][msg.sender].lastPaymentTimestamp = now;&#13;
        token.transferFrom(_client, msg.sender, amountInPMA);&#13;
&#13;
        emit LogPullPaymentExecuted(_client, msg.sender, pullPayments[_client][msg.sender].paymentID);&#13;
    }&#13;
&#13;
    function getRate(string _currency) public view returns (uint256) {&#13;
        return exchangeRates[_currency];&#13;
    }&#13;
&#13;
    /// ===============================================================================================================&#13;
    ///                                      Internal Functions&#13;
    /// ===============================================================================================================&#13;
&#13;
    /// @dev Calculates the PMA Rate for the fiat currency specified - The rate is set every 10 minutes by our PMA server&#13;
    /// for the currencies specified in the smart contract. &#13;
    /// @param _fiatAmountInCents - payment amount in fiat CENTS so that is always integer&#13;
    /// @param _currency - currency in which the payment needs to take place&#13;
    /// RATE CALCULATION EXAMPLE&#13;
    /// ------------------------&#13;
    /// RATE ==&gt; 1 PMA = 0.01 USD$&#13;
    /// 1 USD$ = 1/0.01 PMA = 100 PMA&#13;
    /// Start the calculation from one ether - PMA Token has 18 decimals&#13;
    /// Multiply by the DECIMAL_FIXER (1e+10) to fix the multiplication of the rate&#13;
    /// Multiply with the fiat amount in cents&#13;
    /// Divide by the Rate of PMA to Fiat in cents&#13;
    /// Divide by the FIAT_TO_CENT_FIXER to fix the _fiatAmountInCents&#13;
    function calculatePMAFromFiat(uint256 _fiatAmountInCents, string _currency)&#13;
    internal&#13;
    view&#13;
    returns (uint256) {&#13;
        return ONE_ETHER.mul(DECIMAL_FIXER).mul(_fiatAmountInCents).div(exchangeRates[_currency]).div(FIAT_TO_CENT_FIXER);&#13;
    }&#13;
&#13;
    /// @dev Checks if a registration request is valid by comparing the v, r, s params&#13;
    /// and the hashed params with the client address.&#13;
    /// @param v - recovery ID of the ETH signature. - https://github.com/ethereum/EIPs/issues/155&#13;
    /// @param r - R output of ECDSA signature.&#13;
    /// @param s - S output of ECDSA signature.&#13;
    /// @param _client - client address that is linked to this pull payment.&#13;
    /// @param _beneficiary - address that is allowed to execute this pull payment.&#13;
    /// @param _pullPayment - pull payment to be validated.&#13;
    /// @return bool - if the v, r, s params with the hashed params match the client address&#13;
    function isValidRegistration(&#13;
        uint8 v,&#13;
        bytes32 r,&#13;
        bytes32 s,&#13;
        address _client,&#13;
        address _beneficiary,&#13;
        PullPayment _pullPayment&#13;
    )&#13;
    internal&#13;
    pure&#13;
    returns (bool)&#13;
    {&#13;
        return ecrecover(&#13;
            keccak256(&#13;
                abi.encodePacked(&#13;
                    _beneficiary,&#13;
                    _pullPayment.currency,&#13;
                    _pullPayment.initialPaymentAmountInCents,&#13;
                    _pullPayment.fiatAmountInCents,&#13;
                    _pullPayment.frequency,&#13;
                    _pullPayment.numberOfPayments,&#13;
                    _pullPayment.startTimestamp&#13;
                )&#13;
            ),&#13;
            v, r, s) == _client;&#13;
    }&#13;
&#13;
    /// @dev Checks if a deletion request is valid by comparing the v, r, s params&#13;
    /// and the hashed params with the client address.&#13;
    /// @param v - recovery ID of the ETH signature. - https://github.com/ethereum/EIPs/issues/155&#13;
    /// @param r - R output of ECDSA signature.&#13;
    /// @param s - S output of ECDSA signature.&#13;
    /// @param _paymentID - ID of the payment.&#13;
    /// @param _client - client address that is linked to this pull payment.&#13;
    /// @param _beneficiary - address that is allowed to execute this pull payment.&#13;
    /// @return bool - if the v, r, s params with the hashed params match the client address&#13;
    function isValidDeletion(&#13;
        uint8 v,&#13;
        bytes32 r,&#13;
        bytes32 s,&#13;
        string _paymentID,&#13;
        address _client,&#13;
        address _beneficiary&#13;
    )&#13;
    internal&#13;
    view&#13;
    returns (bool)&#13;
    {&#13;
        return ecrecover(&#13;
            keccak256(&#13;
                abi.encodePacked(&#13;
                    _paymentID,&#13;
                    _beneficiary&#13;
                )&#13;
            ), v, r, s) == _client&#13;
        &amp;&amp; keccak256(&#13;
            abi.encodePacked(pullPayments[_client][_beneficiary].paymentID)&#13;
        ) == keccak256(abi.encodePacked(_paymentID));&#13;
    }&#13;
&#13;
    /// @dev Checks if a payment for a beneficiary of a client exists.&#13;
    /// @param _client - client address that is linked to this pull payment.&#13;
    /// @param _beneficiary - address to execute a pull payment.&#13;
    /// @return bool - whether the beneficiary for this client has a pull payment to execute.&#13;
    function doesPaymentExist(address _client, address _beneficiary)&#13;
    internal&#13;
    view&#13;
    returns (bool) {&#13;
        return (&#13;
        bytes(pullPayments[_client][_beneficiary].currency).length &gt; 0 &amp;&amp;&#13;
        pullPayments[_client][_beneficiary].fiatAmountInCents &gt; 0 &amp;&amp;&#13;
        pullPayments[_client][_beneficiary].frequency &gt; 0 &amp;&amp;&#13;
        pullPayments[_client][_beneficiary].startTimestamp &gt; 0 &amp;&amp;&#13;
        pullPayments[_client][_beneficiary].numberOfPayments &gt; 0 &amp;&amp;&#13;
        pullPayments[_client][_beneficiary].nextPaymentTimestamp &gt; 0&#13;
        );&#13;
    }&#13;
&#13;
    /// @dev Checks if the address of an owner/executor needs to be funded. &#13;
    /// The minimum amount the owner/executors should always have is 0.001 ETH &#13;
    /// @param _address - address of owner/executors that the balance is checked against. &#13;
    /// @return bool - whether the address needs more ETH.&#13;
    function isFundingNeeded(address _address)&#13;
    private&#13;
    view&#13;
    returns (bool) {&#13;
        return address(_address).balance &lt;= MINIMUM_AMOUNT_OF_ETH_FOR_OPARATORS;&#13;
    }&#13;
}