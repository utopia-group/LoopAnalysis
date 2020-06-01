pragma solidity ^0.4.24;

/**
 * @title Utility contract to allow pausing and unpausing of certain functions
 */
contract Pausable {

    event Pause(uint256 _timestammp);
    event Unpause(uint256 _timestamp);

    bool public paused = false;

    /**
    * @notice Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @notice Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

   /**
    * @notice called by the owner to pause, triggers stopped state
    */
    function _pause() internal {
        require(!paused);
        paused = true;
        emit Pause(now);
    }

    /**
    * @notice called by the owner to unpause, returns to normal state
    */
    function _unpause() internal {
        require(paused);
        paused = false;
        emit Unpause(now);
    }

}

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
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
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
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
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

/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

/**
 * @title Interface for the ST20 token standard
 */
contract IST20 is StandardToken, DetailedERC20 {

    // off-chain hash
    string public tokenDetails;

    //transfer, transferFrom must respect use respect the result of verifyTransfer
    function verifyTransfer(address _from, address _to, uint256 _amount) public returns (bool success);

    /**
     * @notice mints new tokens and assigns them to the target _investor.
     * Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)
     */
    function mint(address _investor, uint256 _amount) public returns (bool success);

    /**
     * @notice Burn function used to burn the securityToken
     * @param _value No. of token that get burned
     */
    function burn(uint256 _value) public;

    event Minted(address indexed to, uint256 amount);
    event Burnt(address indexed _burner, uint256 _value);

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
 * @title Interface for all security tokens
 */
contract ISecurityToken is IST20, Ownable {

    uint8 public constant PERMISSIONMANAGER_KEY = 1;
    uint8 public constant TRANSFERMANAGER_KEY = 2;
    uint8 public constant STO_KEY = 3;
    uint8 public constant CHECKPOINT_KEY = 4;
    uint256 public granularity;

    // Value of current checkpoint
    uint256 public currentCheckpointId;

    // Total number of non-zero token holders
    uint256 public investorCount;

    // List of token holders
    address[] public investors;

    // Permissions this to a Permission module, which has a key of 1
    // If no Permission return false - note that IModule withPerm will allow ST owner all permissions anyway
    // this allows individual modules to override this logic if needed (to not allow ST owner all permissions)
    function checkPermission(address _delegate, address _module, bytes32 _perm) public view returns(bool);

    /**
     * @notice returns module list for a module type
     * @param _moduleType is which type of module we are trying to remove
     * @param _moduleIndex is the index of the module within the chosen type
     */
    function getModule(uint8 _moduleType, uint _moduleIndex) public view returns (bytes32, address);

    /**
     * @notice returns module list for a module name - will return first match
     * @param _moduleType is which type of module we are trying to remove
     * @param _name is the name of the module within the chosen type
     */
    function getModuleByName(uint8 _moduleType, bytes32 _name) public view returns (bytes32, address);

    /**
     * @notice Queries totalSupply as of a defined checkpoint
     * @param _checkpointId Checkpoint ID to query as of
     */
    function totalSupplyAt(uint256 _checkpointId) public view returns(uint256);

    /**
     * @notice Queries balances as of a defined checkpoint
     * @param _investor Investor to query balance for
     * @param _checkpointId Checkpoint ID to query as of
     */
    function balanceOfAt(address _investor, uint256 _checkpointId) public view returns(uint256);

    /**
     * @notice Creates a checkpoint that can be used to query historical balances / totalSuppy
     */
    function createCheckpoint() public returns(uint256);

    /**
     * @notice gets length of investors array
     * NB - this length may differ from investorCount if list has not been pruned of zero balance investors
     * @return length
     */
    function getInvestorsLength() public view returns(uint256);

}

/**
 * @title Interface that any module factory contract should implement
 */
contract IModuleFactory is Ownable {

    ERC20 public polyToken;
    uint256 public setupCost;
    uint256 public usageCost;
    uint256 public monthlySubscriptionCost;

    event LogChangeFactorySetupFee(uint256 _oldSetupcost, uint256 _newSetupCost, address _moduleFactory);
    event LogChangeFactoryUsageFee(uint256 _oldUsageCost, uint256 _newUsageCost, address _moduleFactory);
    event LogChangeFactorySubscriptionFee(uint256 _oldSubscriptionCost, uint256 _newMonthlySubscriptionCost, address _moduleFactory);
    event LogGenerateModuleFromFactory(address _module, bytes32 indexed _moduleName, address indexed _moduleFactory, address _creator, uint256 _timestamp);

    /**
     * @notice Constructor
     * @param _polyAddress Address of the polytoken
     */
    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public {
      polyToken = ERC20(_polyAddress);
      setupCost = _setupCost;
      usageCost = _usageCost;
      monthlySubscriptionCost = _subscriptionCost;
    }

    //Should create an instance of the Module, or throw
    function deploy(bytes _data) external returns(address);

    /**
     * @notice Type of the Module factory
     */
    function getType() public view returns(uint8);

    /**
     * @notice Get the name of the Module
     */
    function getName() public view returns(bytes32);

    /**
     * @notice Get the description of the Module
     */
    function getDescription() public view returns(string);

    /**
     * @notice Get the title of the Module
     */
    function getTitle() public view returns(string);

    /**
     * @notice Get the Instructions that helped to used the module
     */
    function getInstructions() public view returns (string);

    /**
     * @notice Get the tags related to the module factory
     */
    function getTags() public view returns (bytes32[]);

    //Pull function sig from _data
    function getSig(bytes _data) internal pure returns (bytes4 sig) {
        uint len = _data.length < 4 ? _data.length : 4;
        for (uint i = 0; i < len; i++) {
            sig = bytes4(uint(sig) + uint(_data[i]) * (2 ** (8 * (len - 1 - i))));
        }
    }

    /**
     * @notice used to change the fee of the setup cost
     * @param _newSetupCost new setup cost
     */
    function changeFactorySetupFee(uint256 _newSetupCost) public onlyOwner {
        emit LogChangeFactorySetupFee(setupCost, _newSetupCost, address(this));
        setupCost = _newSetupCost;
    }

    /**
     * @notice used to change the fee of the usage cost
     * @param _newUsageCost new usage cost
     */
    function changeFactoryUsageFee(uint256 _newUsageCost) public onlyOwner {
        emit LogChangeFactoryUsageFee(usageCost, _newUsageCost, address(this));
        usageCost = _newUsageCost;
    }

    /**
     * @notice used to change the fee of the subscription cost
     * @param _newSubscriptionCost new subscription cost
     */
    function changeFactorySubscriptionFee(uint256 _newSubscriptionCost) public onlyOwner {
        emit LogChangeFactorySubscriptionFee(monthlySubscriptionCost, _newSubscriptionCost, address(this));
        monthlySubscriptionCost = _newSubscriptionCost;
        
    }

}

/**
 * @title Interface that any module contract should implement
 */
contract IModule {

    address public factory;

    address public securityToken;

    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";

    ERC20 public polyToken;

    /**
     * @notice Constructor
     * @param _securityToken Address of the security token
     * @param _polyAddress Address of the polytoken
     */
    constructor (address _securityToken, address _polyAddress) public {
        securityToken = _securityToken;
        factory = msg.sender;
        polyToken = ERC20(_polyAddress);
    }

    /**
     * @notice This function returns the signature of configure function
     */
    function getInitFunction() public pure returns (bytes4);

    //Allows owner, factory or permissioned delegate
    modifier withPerm(bytes32 _perm) {
        bool isOwner = msg.sender == ISecurityToken(securityToken).owner();
        bool isFactory = msg.sender == factory;
        require(isOwner||isFactory||ISecurityToken(securityToken).checkPermission(msg.sender, address(this), _perm), "Permission check failed");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == ISecurityToken(securityToken).owner(), "Sender is not owner");
        _;
    }

    modifier onlyFactory {
        require(msg.sender == factory, "Sender is not factory");
        _;
    }

    modifier onlyFactoryOwner {
        require(msg.sender == IModuleFactory(factory).owner(), "Sender is not factory owner");
        _;
    }

    /**
     * @notice Return the permissions flag that are associated with Module
     */
    function getPermissions() public view returns(bytes32[]);

    /**
     * @notice used to withdraw the fee by the factory owner
     */
    function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {
        require(polyToken.transferFrom(address(this), IModuleFactory(factory).owner(), _amount), "Unable to take fee");
        return true;
    }
}

/**
 * @title Interface to be implemented by all STO modules
 */
contract ISTO is IModule, Pausable {

    using SafeMath for uint256;

    enum FundraiseType { ETH, POLY }
    FundraiseType public fundraiseType;

    // Start time of the STO
    uint256 public startTime;
    // End time of the STO
    uint256 public endTime;

    /**
     * @notice use to verify the investment, whether the investor provide the allowance to the STO or not.
     * @param _beneficiary Ethereum address of the beneficiary, who wants to buy the st-20
     * @param _fundsAmount Amount invested by the beneficiary
     */
    function verifyInvestment(address _beneficiary, uint256 _fundsAmount) public view returns(bool) {
        return polyToken.allowance(_beneficiary, address(this)) >= _fundsAmount;
    }

    /**
     * @notice Return ETH raised by the STO
     */
    function getRaisedEther() public view returns (uint256);

    /**
     * @notice Return POLY raised by the STO
     */
    function getRaisedPOLY() public view returns (uint256);

    /**
     * @notice Return the total no. of investors
     */
    function getNumberInvestors() public view returns (uint256);

    /**
     * @notice pause (overridden function)
     */
    function pause() public onlyOwner {
        require(now < endTime);
        super._pause();
    }

    /**
     * @notice unpause (overridden function)
     */
    function unpause(uint256 _newEndDate) public onlyOwner {
        require(_newEndDate >= endTime);
        super._unpause();
        endTime = _newEndDate;
    }

    /**
    * @notice Reclaim ERC20Basic compatible tokens
    * @param _tokenContract The address of the token contract
    */
    function reclaimERC20(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0));
        ERC20Basic token = ERC20Basic(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, balance));
    }

}

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7b091e1618143b49">[email protected]</a>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private reentrancyLock = false;&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * @notice If you mark a function `nonReentrant`, you should also&#13;
   * mark it `external`. Calling one nonReentrant function from&#13;
   * another is not supported. Instead, you can implement a&#13;
   * `private` function doing the actual work, and a `external`&#13;
   * wrapper marked as `nonReentrant`.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    require(!reentrancyLock);&#13;
    reentrancyLock = true;&#13;
    _;&#13;
    reentrancyLock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title STO module for standard capped crowdsale&#13;
 */&#13;
contract CappedSTO is ISTO, ReentrancyGuard {&#13;
    using SafeMath for uint256;&#13;
&#13;
    // Address where funds are collected and tokens are issued to&#13;
    address public wallet;&#13;
&#13;
    // How many token units a buyer gets per wei / base unit of POLY&#13;
    uint256 public rate;&#13;
&#13;
    // Amount of funds raised&#13;
    uint256 public fundsRaised;&#13;
&#13;
    uint256 public investorCount;&#13;
&#13;
    // Amount of tokens sold&#13;
    uint256 public tokensSold;&#13;
&#13;
    //How many tokens this STO will be allowed to sell to investors&#13;
    uint256 public cap;&#13;
&#13;
    mapping (address =&gt; uint256) public investors;&#13;
&#13;
    /**&#13;
    * Event for token purchase logging&#13;
    * @param purchaser who paid for the tokens&#13;
    * @param beneficiary who got the tokens&#13;
    * @param value weis paid for purchase&#13;
    * @param amount amount of tokens purchased&#13;
    */&#13;
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);&#13;
&#13;
    constructor (address _securityToken, address _polyAddress) public&#13;
    IModule(_securityToken, _polyAddress)&#13;
    {&#13;
    }&#13;
&#13;
    //////////////////////////////////&#13;
    /**&#13;
    * @notice fallback function ***DO NOT OVERRIDE***&#13;
    */&#13;
    function () external payable {&#13;
        buyTokens(msg.sender);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Function used to intialize the contract variables&#13;
     * @param _startTime Unix timestamp at which offering get started&#13;
     * @param _endTime Unix timestamp at which offering get ended&#13;
     * @param _cap Maximum No. of tokens for sale&#13;
     * @param _rate Token units a buyer gets per wei / base unit of POLY&#13;
     * @param _fundRaiseType Type of currency used to collect the funds&#13;
     * @param _fundsReceiver Ethereum account address to hold the funds&#13;
     */&#13;
    function configure(&#13;
        uint256 _startTime,&#13;
        uint256 _endTime,&#13;
        uint256 _cap,&#13;
        uint256 _rate,&#13;
        uint8 _fundRaiseType,&#13;
        address _fundsReceiver&#13;
    )&#13;
    public&#13;
    onlyFactory&#13;
    {&#13;
        require(_rate &gt; 0, "Rate of token should be greater than 0");&#13;
        require(_fundsReceiver != address(0), "Zero address is not permitted");&#13;
        require(_startTime &gt;= now &amp;&amp; _endTime &gt; _startTime, "Date parameters are not valid");&#13;
        require(_cap &gt; 0, "Cap should be greater than 0");&#13;
        startTime = _startTime;&#13;
        endTime = _endTime;&#13;
        cap = _cap;&#13;
        rate = _rate;&#13;
        wallet = _fundsReceiver;&#13;
        _check(_fundRaiseType);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice This function returns the signature of configure function&#13;
     */&#13;
    function getInitFunction() public pure returns (bytes4) {&#13;
        return bytes4(keccak256("configure(uint256,uint256,uint256,uint256,uint8,address)"));&#13;
    }&#13;
&#13;
    /**&#13;
      * @notice low level token purchase ***DO NOT OVERRIDE***&#13;
      * @param _beneficiary Address performing the token purchase&#13;
      */&#13;
    function buyTokens(address _beneficiary) public payable nonReentrant {&#13;
        require(!paused);&#13;
        require(fundraiseType == FundraiseType.ETH, "ETH should be the mode of investment");&#13;
&#13;
        uint256 weiAmount = msg.value;&#13;
        _processTx(_beneficiary, weiAmount);&#13;
&#13;
        _forwardFunds();&#13;
        _postValidatePurchase(_beneficiary, weiAmount);&#13;
    }&#13;
&#13;
    /**&#13;
      * @notice low level token purchase&#13;
      * @param _investedPOLY Amount of POLY invested&#13;
      */&#13;
    function buyTokensWithPoly(uint256 _investedPOLY) public nonReentrant{&#13;
        require(!paused);&#13;
        require(fundraiseType == FundraiseType.POLY, "POLY should be the mode of investment");&#13;
        require(verifyInvestment(msg.sender, _investedPOLY), "Not valid Investment");&#13;
        _processTx(msg.sender, _investedPOLY);&#13;
        _forwardPoly(msg.sender, wallet, _investedPOLY);&#13;
        _postValidatePurchase(msg.sender, _investedPOLY);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Checks whether the cap has been reached.&#13;
    * @return bool Whether the cap was reached&#13;
    */&#13;
    function capReached() public view returns (bool) {&#13;
        return tokensSold &gt;= cap;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Return ETH raised by the STO&#13;
     */&#13;
    function getRaisedEther() public view returns (uint256) {&#13;
        if (fundraiseType == FundraiseType.ETH)&#13;
            return fundsRaised;&#13;
        else&#13;
            return 0;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Return POLY raised by the STO&#13;
     */&#13;
    function getRaisedPOLY() public view returns (uint256) {&#13;
        if (fundraiseType == FundraiseType.POLY)&#13;
            return fundsRaised;&#13;
        else&#13;
            return 0;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Return the total no. of investors&#13;
     */&#13;
    function getNumberInvestors() public view returns (uint256) {&#13;
        return investorCount;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Return the permissions flag that are associated with STO&#13;
     */&#13;
    function getPermissions() public view returns(bytes32[]) {&#13;
        bytes32[] memory allPermissions = new bytes32[](0);&#13;
        return allPermissions;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Return the STO details&#13;
     */&#13;
    function getSTODetails() public view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool) {&#13;
        return (&#13;
            startTime,&#13;
            endTime,&#13;
            cap,&#13;
            rate,&#13;
            fundsRaised,&#13;
            investorCount,&#13;
            tokensSold,&#13;
            (fundraiseType == FundraiseType.POLY)&#13;
        );&#13;
    }&#13;
&#13;
    // -----------------------------------------&#13;
    // Internal interface (extensible)&#13;
    // -----------------------------------------&#13;
    /**&#13;
      * Processing the purchase as well as verify the required validations&#13;
      * @param _beneficiary Address performing the token purchase&#13;
      * @param _investedAmount Value in wei involved in the purchase&#13;
    */&#13;
    function _processTx(address _beneficiary, uint256 _investedAmount) internal {&#13;
&#13;
        _preValidatePurchase(_beneficiary, _investedAmount);&#13;
        // calculate token amount to be created&#13;
        uint256 tokens = _getTokenAmount(_investedAmount);&#13;
&#13;
        // update state&#13;
        fundsRaised = fundsRaised.add(_investedAmount);&#13;
        tokensSold = tokensSold.add(tokens);&#13;
&#13;
        _processPurchase(_beneficiary, tokens);&#13;
        emit TokenPurchase(msg.sender, _beneficiary, _investedAmount, tokens);&#13;
&#13;
        _updatePurchasingState(_beneficiary, _investedAmount);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Validation of an incoming purchase.&#13;
      Use require statements to revert state when conditions are not met. Use super to concatenate validations.&#13;
    * @param _beneficiary Address performing the token purchase&#13;
    * @param _investedAmount Value in wei involved in the purchase&#13;
    */&#13;
    function _preValidatePurchase(address _beneficiary, uint256 _investedAmount) internal view {&#13;
        require(_beneficiary != address(0), "Beneficiary address should not be 0x");&#13;
        require(_investedAmount != 0, "Amount invested should not be equal to 0");&#13;
        require(tokensSold.add(_getTokenAmount(_investedAmount)) &lt;= cap, "Investment more than cap is not allowed");&#13;
        require(now &gt;= startTime &amp;&amp; now &lt;= endTime, "Offering is closed/Not yet started");&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Validation of an executed purchase.&#13;
      Observe state and use revert statements to undo rollback when valid conditions are not met.&#13;
    */&#13;
    function _postValidatePurchase(address /*_beneficiary*/, uint256 /*_investedAmount*/) internal pure {&#13;
      // optional override&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Source of tokens.&#13;
      Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.&#13;
    * @param _beneficiary Address performing the token purchase&#13;
    * @param _tokenAmount Number of tokens to be emitted&#13;
    */&#13;
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {&#13;
        require(IST20(securityToken).mint(_beneficiary, _tokenAmount), "Error in minting the tokens");&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.&#13;
    * @param _beneficiary Address receiving the tokens&#13;
    * @param _tokenAmount Number of tokens to be purchased&#13;
    */&#13;
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {&#13;
        if (investors[_beneficiary] == 0) {&#13;
            investorCount = investorCount + 1;&#13;
        }&#13;
        investors[_beneficiary] = investors[_beneficiary].add(_tokenAmount);&#13;
&#13;
        _deliverTokens(_beneficiary, _tokenAmount);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Override for extensions that require an internal state to check for validity&#13;
      (current user contributions, etc.)&#13;
    */&#13;
    function _updatePurchasingState(address /*_beneficiary*/, uint256 /*_investedAmount*/) internal pure {&#13;
      // optional override&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Override to extend the way in which ether is converted to tokens.&#13;
    * @param _investedAmount Value in wei to be converted into tokens&#13;
    * @return Number of tokens that can be purchased with the specified _investedAmount&#13;
    */&#13;
    function _getTokenAmount(uint256 _investedAmount) internal view returns (uint256) {&#13;
        return _investedAmount.mul(rate);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Determines how ETH is stored/forwarded on purchases.&#13;
    */&#13;
    function _forwardFunds() internal {&#13;
        wallet.transfer(msg.value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Internal function used to check the type of fund raise currency&#13;
     * @param _fundraiseType Type of currency used to collect the funds&#13;
     */&#13;
    function _check(uint8 _fundraiseType) internal {&#13;
        require(_fundraiseType == 0 || _fundraiseType == 1, "Not a valid fundraise type");&#13;
        if (_fundraiseType == 0) {&#13;
            fundraiseType = FundraiseType.ETH;&#13;
        }&#13;
        if (_fundraiseType == 1) {&#13;
            require(address(polyToken) != address(0), "Address of the polyToken should not be 0x");&#13;
            fundraiseType = FundraiseType.POLY;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Internal function used to forward the POLY raised to beneficiary address&#13;
     * @param _beneficiary Address of the funds reciever&#13;
     * @param _to Address who wants to ST-20 tokens&#13;
     * @param _fundsAmount Amount invested by _to&#13;
     */&#13;
    function _forwardPoly(address _beneficiary, address _to, uint256 _fundsAmount) internal {&#13;
        polyToken.transferFrom(_beneficiary, _to, _fundsAmount);&#13;
    }&#13;
&#13;
}