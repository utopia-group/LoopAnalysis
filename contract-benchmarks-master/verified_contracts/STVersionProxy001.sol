pragma solidity ^0.4.24;

/**
 * @title Math
 * @dev Assorted math operations
 */
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

contract IERC20 is ERC20 {

    function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool);

    function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool);
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
 * @title Interface for the polymath module registry contract
 */
contract IModuleRegistry {

    /**
     * @notice Called by a security token to notify the registry it is using a module
     * @param _moduleFactory is the address of the relevant module factory
     */
    function useModule(address _moduleFactory) external;

    /**
     * @notice Called by moduleFactory owner to register new modules for SecurityToken to use
     * @param _moduleFactory is the address of the module factory to be registered
     */
    function registerModule(address _moduleFactory) external returns(bool);

    /**
     * @notice Use to get all the tags releated to the functionality of the Module Factory.
     * @param _moduleType Type of module
     */
    function getTagByModuleType(uint8 _moduleType) public view returns(bytes32[]);

}

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
 * @title Interface to be implemented by all Transfer Manager modules
 */
contract ITransferManager is IModule, Pausable {

    //If verifyTransfer returns:
    //  FORCE_VALID, the transaction will always be valid, regardless of other TM results
    //  INVALID, then the transfer should not be allowed regardless of other TM results
    //  VALID, then the transfer is valid for this TM
    //  NA, then the result from this TM is ignored
    enum Result {INVALID, NA, VALID, FORCE_VALID}

    function verifyTransfer(address _from, address _to, uint256 _amount, bool _isTransfer) public returns(Result);

    function unpause() onlyOwner public {
        super._unpause();
    }

    function pause() onlyOwner public {
        super._pause();
    }
}

/**
 * @title Interface to be implemented by all permission manager modules
 */
contract IPermissionManager is IModule {

    function checkPermission(address _delegate, address _module, bytes32 _perm) public view returns(bool);

    function changePermission(address _delegate, address _module, bytes32 _perm, bool _valid) public returns(bool);

    function getDelegateDetails(address _delegate) public view returns(bytes32);

}

/**
 * @title Interface for the token burner contract
 */
interface ITokenBurner {

    function burn(address _burner, uint256  _value ) external returns(bool);

}

/**
 * @title Utility contract to allow owner to retreive any ERC20 sent to the contract
 */
contract ReclaimTokens is Ownable {

    /**
    * @notice Reclaim all ERC20Basic compatible tokens
    * @param _tokenContract The address of the token contract
    */
    function reclaimERC20(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0));
        ERC20Basic token = ERC20Basic(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner, balance));
    }
}

/**
 * @title Core functionality for registry upgradability
 */
contract PolymathRegistry is ReclaimTokens {

    mapping (bytes32 => address) public storedAddresses;

    event LogChangeAddress(string _nameKey, address indexed _oldAddress, address indexed _newAddress);

    /**
     * @notice Get the contract address
     * @param _nameKey is the key for the contract address mapping
     * @return address
     */
    function getAddress(string _nameKey) view public returns(address) {
        bytes32 key = keccak256(bytes(_nameKey));
        require(storedAddresses[key] != address(0), "Invalid address key");
        return storedAddresses[key];
    }

    /**
     * @notice change the contract address
     * @param _nameKey is the key for the contract address mapping
     * @param _newAddress is the new contract address
     */
    function changeAddress(string _nameKey, address _newAddress) public onlyOwner {
        bytes32 key = keccak256(bytes(_nameKey));
        emit LogChangeAddress(_nameKey, storedAddresses[key], _newAddress);
        storedAddresses[key] = _newAddress;
    }


}

contract RegistryUpdater is Ownable {

    address public polymathRegistry;
    address public moduleRegistry;
    address public securityTokenRegistry;
    address public tickerRegistry;
    address public polyToken;

    constructor (address _polymathRegistry) public {
        require(_polymathRegistry != address(0));
        polymathRegistry = _polymathRegistry;
    }

    function updateFromRegistry() onlyOwner public {
        moduleRegistry = PolymathRegistry(polymathRegistry).getAddress("ModuleRegistry");
        securityTokenRegistry = PolymathRegistry(polymathRegistry).getAddress("SecurityTokenRegistry");
        tickerRegistry = PolymathRegistry(polymathRegistry).getAddress("TickerRegistry");
        polyToken = PolymathRegistry(polymathRegistry).getAddress("PolyToken");
    }

}

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="82f0e7efe1edc2b0">[email protected]</a>π.com&gt;&#13;
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
* @title Security Token contract&#13;
* @notice SecurityToken is an ERC20 token with added capabilities:&#13;
* @notice - Implements the ST-20 Interface&#13;
* @notice - Transfers are restricted&#13;
* @notice - Modules can be attached to it to control its behaviour&#13;
* @notice - ST should not be deployed directly, but rather the SecurityTokenRegistry should be used&#13;
*/&#13;
contract SecurityToken is ISecurityToken, ReentrancyGuard, RegistryUpdater {&#13;
    using SafeMath for uint256;&#13;
&#13;
    bytes32 public constant securityTokenVersion = "0.0.1";&#13;
&#13;
    // Reference to token burner contract&#13;
    ITokenBurner public tokenBurner;&#13;
&#13;
    // Use to halt all the transactions&#13;
    bool public freeze = false;&#13;
&#13;
    struct ModuleData {&#13;
        bytes32 name;&#13;
        address moduleAddress;&#13;
    }&#13;
&#13;
    // Structures to maintain checkpoints of balances for governance / dividends&#13;
    struct Checkpoint {&#13;
        uint256 checkpointId;&#13;
        uint256 value;&#13;
    }&#13;
&#13;
    mapping (address =&gt; Checkpoint[]) public checkpointBalances;&#13;
    Checkpoint[] public checkpointTotalSupply;&#13;
&#13;
    bool public finishedIssuerMinting = false;&#13;
    bool public finishedSTOMinting = false;&#13;
&#13;
    mapping (bytes4 =&gt; bool) transferFunctions;&#13;
&#13;
    // Module list should be order agnostic!&#13;
    mapping (uint8 =&gt; ModuleData[]) public modules;&#13;
&#13;
    uint8 public constant MAX_MODULES = 20;&#13;
&#13;
    mapping (address =&gt; bool) public investorListed;&#13;
&#13;
    // Emit at the time when module get added&#13;
    event LogModuleAdded(&#13;
        uint8 indexed _type,&#13;
        bytes32 _name,&#13;
        address _moduleFactory,&#13;
        address _module,&#13;
        uint256 _moduleCost,&#13;
        uint256 _budget,&#13;
        uint256 _timestamp&#13;
    );&#13;
&#13;
    // Emit when the token details get updated&#13;
    event LogUpdateTokenDetails(string _oldDetails, string _newDetails);&#13;
    // Emit when the granularity get changed&#13;
    event LogGranularityChanged(uint256 _oldGranularity, uint256 _newGranularity);&#13;
    // Emit when Module get removed from the securityToken&#13;
    event LogModuleRemoved(uint8 indexed _type, address _module, uint256 _timestamp);&#13;
    // Emit when the budget allocated to a module is changed&#13;
    event LogModuleBudgetChanged(uint8 indexed _moduleType, address _module, uint256 _budget);&#13;
    // Emit when all the transfers get freeze&#13;
    event LogFreezeTransfers(bool _freeze, uint256 _timestamp);&#13;
    // Emit when new checkpoint created&#13;
    event LogCheckpointCreated(uint256 indexed _checkpointId, uint256 _timestamp);&#13;
    // Emit when the minting get finished for the Issuer&#13;
    event LogFinishMintingIssuer(uint256 _timestamp);&#13;
    // Emit when the minting get finished for the STOs&#13;
    event LogFinishMintingSTO(uint256 _timestamp);&#13;
    // Change the STR address in the event of a upgrade&#13;
    event LogChangeSTRAddress(address indexed _oldAddress, address indexed _newAddress);&#13;
&#13;
    // If _fallback is true, then for STO module type we only allow the module if it is set, if it is not set we only allow the owner&#13;
    // for other _moduleType we allow both issuer and module.&#13;
    modifier onlyModule(uint8 _moduleType, bool _fallback) {&#13;
      //Loop over all modules of type _moduleType&#13;
        bool isModuleType = false;&#13;
        for (uint8 i = 0; i &lt; modules[_moduleType].length; i++) {&#13;
            isModuleType = isModuleType || (modules[_moduleType][i].moduleAddress == msg.sender);&#13;
        }&#13;
        if (_fallback &amp;&amp; !isModuleType) {&#13;
            if (_moduleType == STO_KEY)&#13;
                require(modules[_moduleType].length == 0 &amp;&amp; msg.sender == owner, "Sender is not owner or STO module is attached");&#13;
            else&#13;
                require(msg.sender == owner, "Sender is not owner");&#13;
        } else {&#13;
            require(isModuleType, "Sender is not correct module type");&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    modifier checkGranularity(uint256 _amount) {&#13;
        require(_amount % granularity == 0, "Unable to modify token balances at this granularity");&#13;
        _;&#13;
    }&#13;
&#13;
    // Checks whether the minting is allowed or not, check for the owner if owner is no the msg.sender then check&#13;
    // for the finishedSTOMinting flag because only STOs and owner are allowed for minting&#13;
    modifier isMintingAllowed() {&#13;
        if (msg.sender == owner) {&#13;
            require(!finishedIssuerMinting, "Minting is finished for Issuer");&#13;
        } else {&#13;
            require(!finishedSTOMinting, "Minting is finished for STOs");&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Constructor&#13;
     * @param _name Name of the SecurityToken&#13;
     * @param _symbol Symbol of the Token&#13;
     * @param _decimals Decimals for the securityToken&#13;
     * @param _granularity granular level of the token&#13;
     * @param _tokenDetails Details of the token that are stored off-chain (IPFS hash)&#13;
     * @param _polymathRegistry Contract address of the polymath registry&#13;
     */&#13;
    constructor (&#13;
        string _name,&#13;
        string _symbol,&#13;
        uint8 _decimals,&#13;
        uint256 _granularity,&#13;
        string _tokenDetails,&#13;
        address _polymathRegistry&#13;
    )&#13;
    public&#13;
    DetailedERC20(_name, _symbol, _decimals)&#13;
    RegistryUpdater(_polymathRegistry)&#13;
    {&#13;
        //When it is created, the owner is the STR&#13;
        updateFromRegistry();&#13;
        tokenDetails = _tokenDetails;&#13;
        granularity = _granularity;&#13;
        transferFunctions[bytes4(keccak256("transfer(address,uint256)"))] = true;&#13;
        transferFunctions[bytes4(keccak256("transferFrom(address,address,uint256)"))] = true;&#13;
        transferFunctions[bytes4(keccak256("mint(address,uint256)"))] = true;&#13;
        transferFunctions[bytes4(keccak256("burn(uint256)"))] = true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Function used to attach the module in security token&#13;
     * @param _moduleFactory Contract address of the module factory that needs to be attached&#13;
     * @param _data Data used for the intialization of the module factory variables&#13;
     * @param _maxCost Maximum cost of the Module factory&#13;
     * @param _budget Budget of the Module factory&#13;
     */&#13;
    function addModule(&#13;
        address _moduleFactory,&#13;
        bytes _data,&#13;
        uint256 _maxCost,&#13;
        uint256 _budget&#13;
    ) external onlyOwner nonReentrant {&#13;
        _addModule(_moduleFactory, _data, _maxCost, _budget);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice _addModule handles the attachment (or replacement) of modules for the ST&#13;
    * @dev  E.G.: On deployment (through the STR) ST gets a TransferManager module attached to it&#13;
    * @dev to control restrictions on transfers.&#13;
    * @dev You are allowed to add a new moduleType if:&#13;
    * @dev - there is no existing module of that type yet added&#13;
    * @dev - the last member of the module list is replacable&#13;
    * @param _moduleFactory is the address of the module factory to be added&#13;
    * @param _data is data packed into bytes used to further configure the module (See STO usage)&#13;
    * @param _maxCost max amount of POLY willing to pay to module. (WIP)&#13;
    */&#13;
    function _addModule(address _moduleFactory, bytes _data, uint256 _maxCost, uint256 _budget) internal {&#13;
        //Check that module exists in registry - will throw otherwise&#13;
        IModuleRegistry(moduleRegistry).useModule(_moduleFactory);&#13;
        IModuleFactory moduleFactory = IModuleFactory(_moduleFactory);&#13;
        uint8 moduleType = moduleFactory.getType();&#13;
        require(modules[moduleType].length &lt; MAX_MODULES, "Limit of MAX MODULES is reached");&#13;
        uint256 moduleCost = moduleFactory.setupCost();&#13;
        require(moduleCost &lt;= _maxCost, "Max Cost is always be greater than module cost");&#13;
        //Approve fee for module&#13;
        require(ERC20(polyToken).approve(_moduleFactory, moduleCost), "Not able to approve the module cost");&#13;
        //Creates instance of module from factory&#13;
        address module = moduleFactory.deploy(_data);&#13;
        //Approve ongoing budget&#13;
        require(ERC20(polyToken).approve(module, _budget), "Not able to approve the budget");&#13;
        //Add to SecurityToken module map&#13;
        bytes32 moduleName = moduleFactory.getName();&#13;
        modules[moduleType].push(ModuleData(moduleName, module));&#13;
        //Emit log event&#13;
        emit LogModuleAdded(moduleType, moduleName, _moduleFactory, module, moduleCost, _budget, now);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Removes a module attached to the SecurityToken&#13;
    * @param _moduleType is which type of module we are trying to remove&#13;
    * @param _moduleIndex is the index of the module within the chosen type&#13;
    */&#13;
    function removeModule(uint8 _moduleType, uint8 _moduleIndex) external onlyOwner {&#13;
        require(_moduleIndex &lt; modules[_moduleType].length,&#13;
        "Module index doesn't exist as per the choosen module type");&#13;
        require(modules[_moduleType][_moduleIndex].moduleAddress != address(0),&#13;
        "Module contract address should not be 0x");&#13;
        //Take the last member of the list, and replace _moduleIndex with this, then shorten the list by one&#13;
        emit LogModuleRemoved(_moduleType, modules[_moduleType][_moduleIndex].moduleAddress, now);&#13;
        modules[_moduleType][_moduleIndex] = modules[_moduleType][modules[_moduleType].length - 1];&#13;
        modules[_moduleType].length = modules[_moduleType].length - 1;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Returns module list for a module type&#13;
     * @param _moduleType is which type of module we are trying to get&#13;
     * @param _moduleIndex is the index of the module within the chosen type&#13;
     * @return bytes32&#13;
     * @return address&#13;
     */&#13;
    function getModule(uint8 _moduleType, uint _moduleIndex) public view returns (bytes32, address) {&#13;
        if (modules[_moduleType].length &gt; 0) {&#13;
            return (&#13;
                modules[_moduleType][_moduleIndex].name,&#13;
                modules[_moduleType][_moduleIndex].moduleAddress&#13;
            );&#13;
        } else {&#13;
            return ("", address(0));&#13;
        }&#13;
&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice returns module list for a module name - will return first match&#13;
     * @param _moduleType is which type of module we are trying to get&#13;
     * @param _name is the name of the module within the chosen type&#13;
     * @return bytes32&#13;
     * @return address&#13;
     */&#13;
    function getModuleByName(uint8 _moduleType, bytes32 _name) public view returns (bytes32, address) {&#13;
        if (modules[_moduleType].length &gt; 0) {&#13;
            for (uint256 i = 0; i &lt; modules[_moduleType].length; i++) {&#13;
                if (modules[_moduleType][i].name == _name) {&#13;
                  return (&#13;
                      modules[_moduleType][i].name,&#13;
                      modules[_moduleType][i].moduleAddress&#13;
                  );&#13;
                }&#13;
            }&#13;
            return ("", address(0));&#13;
        } else {&#13;
            return ("", address(0));&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice allows the owner to withdraw unspent POLY stored by them on the ST.&#13;
    * @dev Owner can transfer POLY to the ST which will be used to pay for modules that require a POLY fee.&#13;
    * @param _amount amount of POLY to withdraw&#13;
    */&#13;
    function withdrawPoly(uint256 _amount) public onlyOwner {&#13;
        require(ERC20(polyToken).transfer(owner, _amount), "In-sufficient balance");&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice allows owner to approve more POLY to one of the modules&#13;
    * @param _moduleType module type&#13;
    * @param _moduleIndex module index&#13;
    * @param _budget new budget&#13;
    */&#13;
    function changeModuleBudget(uint8 _moduleType, uint8 _moduleIndex, uint256 _budget) public onlyOwner {&#13;
        require(_moduleType != 0, "Module type cannot be zero");&#13;
        require(_moduleIndex &lt; modules[_moduleType].length, "Incorrrect module index");&#13;
        uint256 _currentAllowance = IERC20(polyToken).allowance(address(this), modules[_moduleType][_moduleIndex].moduleAddress);&#13;
        if (_budget &lt; _currentAllowance) {&#13;
            require(IERC20(polyToken).decreaseApproval(modules[_moduleType][_moduleIndex].moduleAddress, _currentAllowance.sub(_budget)), "Insufficient balance to decreaseApproval");&#13;
        } else {&#13;
            require(IERC20(polyToken).increaseApproval(modules[_moduleType][_moduleIndex].moduleAddress, _budget.sub(_currentAllowance)), "Insufficient balance to increaseApproval");&#13;
        }&#13;
        emit LogModuleBudgetChanged(_moduleType, modules[_moduleType][_moduleIndex].moduleAddress, _budget);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice change the tokenDetails&#13;
     * @param _newTokenDetails New token details&#13;
     */&#13;
    function updateTokenDetails(string _newTokenDetails) public onlyOwner {&#13;
        emit LogUpdateTokenDetails(tokenDetails, _newTokenDetails);&#13;
        tokenDetails = _newTokenDetails;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice allows owner to change token granularity&#13;
    * @param _granularity granularity level of the token&#13;
    */&#13;
    function changeGranularity(uint256 _granularity) public onlyOwner {&#13;
        require(_granularity != 0, "Granularity can not be 0");&#13;
        emit LogGranularityChanged(granularity, _granularity);&#13;
        granularity = _granularity;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice keeps track of the number of non-zero token holders&#13;
    * @param _from sender of transfer&#13;
    * @param _to receiver of transfer&#13;
    * @param _value value of transfer&#13;
    */&#13;
    function adjustInvestorCount(address _from, address _to, uint256 _value) internal {&#13;
        if ((_value == 0) || (_from == _to)) {&#13;
            return;&#13;
        }&#13;
        // Check whether receiver is a new token holder&#13;
        if ((balanceOf(_to) == 0) &amp;&amp; (_to != address(0))) {&#13;
            investorCount = investorCount.add(1);&#13;
        }&#13;
        // Check whether sender is moving all of their tokens&#13;
        if (_value == balanceOf(_from)) {&#13;
            investorCount = investorCount.sub(1);&#13;
        }&#13;
        //Also adjust investor list&#13;
        if (!investorListed[_to] &amp;&amp; (_to != address(0))) {&#13;
            investors.push(_to);&#13;
            investorListed[_to] = true;&#13;
        }&#13;
&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice removes addresses with zero balances from the investors list&#13;
    * @param _start Index in investor list at which to start removing zero balances&#13;
    * @param _iters Max number of iterations of the for loop&#13;
    * NB - pruning this list will mean you may not be able to iterate over investors on-chain as of a historical checkpoint&#13;
    */&#13;
    function pruneInvestors(uint256 _start, uint256 _iters) public onlyOwner {&#13;
        for (uint256 i = _start; i &lt; Math.min256(_start.add(_iters), investors.length); i++) {&#13;
            if ((i &lt; investors.length) &amp;&amp; (balanceOf(investors[i]) == 0)) {&#13;
                investorListed[investors[i]] = false;&#13;
                investors[i] = investors[investors.length - 1];&#13;
                investors.length--;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice gets length of investors array&#13;
     * NB - this length may differ from investorCount if list has not been pruned of zero balance investors&#13;
     * @return length&#13;
     */&#13;
    function getInvestorsLength() public view returns(uint256) {&#13;
        return investors.length;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice freeze all the transfers&#13;
     */&#13;
    function freezeTransfers() public onlyOwner {&#13;
        require(!freeze);&#13;
        freeze = true;&#13;
        emit LogFreezeTransfers(freeze, now);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice un-freeze all the transfers&#13;
     */&#13;
    function unfreezeTransfers() public onlyOwner {&#13;
        require(freeze);&#13;
        freeze = false;&#13;
        emit LogFreezeTransfers(freeze, now);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice adjust totalsupply at checkpoint after minting or burning tokens&#13;
     */&#13;
    function adjustTotalSupplyCheckpoints() internal {&#13;
        adjustCheckpoints(checkpointTotalSupply, totalSupply());&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice adjust token holder balance at checkpoint after a token transfer&#13;
     * @param _investor address of the token holder affected&#13;
     */&#13;
    function adjustBalanceCheckpoints(address _investor) internal {&#13;
        adjustCheckpoints(checkpointBalances[_investor], balanceOf(_investor));&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice store the changes to the checkpoint objects&#13;
     * @param _checkpoints the affected checkpoint object array&#13;
     * @param _newValue the new value that needs to be stored&#13;
     */&#13;
    function adjustCheckpoints(Checkpoint[] storage _checkpoints, uint256 _newValue) internal {&#13;
        //No checkpoints set yet&#13;
        if (currentCheckpointId == 0) {&#13;
            return;&#13;
        }&#13;
        //No previous checkpoint data - add current balance against checkpoint&#13;
        if (_checkpoints.length == 0) {&#13;
            _checkpoints.push(&#13;
                Checkpoint({&#13;
                    checkpointId: currentCheckpointId,&#13;
                    value: _newValue&#13;
                })&#13;
            );&#13;
            return;&#13;
        }&#13;
        //No new checkpoints since last update&#13;
        if (_checkpoints[_checkpoints.length - 1].checkpointId == currentCheckpointId) {&#13;
            return;&#13;
        }&#13;
        //New checkpoint, so record balance&#13;
        _checkpoints.push(&#13;
            Checkpoint({&#13;
                checkpointId: currentCheckpointId,&#13;
                value: _newValue&#13;
            })&#13;
        );&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Overloaded version of the transfer function&#13;
     * @param _to receiver of transfer&#13;
     * @param _value value of transfer&#13;
     * @return bool success&#13;
     */&#13;
    function transfer(address _to, uint256 _value) public returns (bool success) {&#13;
        adjustInvestorCount(msg.sender, _to, _value);&#13;
        require(verifyTransfer(msg.sender, _to, _value), "Transfer is not valid");&#13;
        adjustBalanceCheckpoints(msg.sender);&#13;
        adjustBalanceCheckpoints(_to);&#13;
        require(super.transfer(_to, _value));&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Overloaded version of the transferFrom function&#13;
     * @param _from sender of transfer&#13;
     * @param _to receiver of transfer&#13;
     * @param _value value of transfer&#13;
     * @return bool success&#13;
     */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {&#13;
        adjustInvestorCount(_from, _to, _value);&#13;
        require(verifyTransfer(_from, _to, _value), "Transfer is not valid");&#13;
        adjustBalanceCheckpoints(_from);&#13;
        adjustBalanceCheckpoints(_to);&#13;
        require(super.transferFrom(_from, _to, _value));&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice validate transfer with TransferManager module if it exists&#13;
     * @dev TransferManager module has a key of 2&#13;
     * @param _from sender of transfer&#13;
     * @param _to receiver of transfer&#13;
     * @param _amount value of transfer&#13;
     * @return bool&#13;
     */&#13;
    function verifyTransfer(address _from, address _to, uint256 _amount) public checkGranularity(_amount) returns (bool) {&#13;
        if (!freeze) {&#13;
            bool isTransfer = false;&#13;
            if (transferFunctions[getSig(msg.data)]) {&#13;
              isTransfer = true;&#13;
            }&#13;
            if (modules[TRANSFERMANAGER_KEY].length == 0) {&#13;
                return true;&#13;
            }&#13;
            bool isInvalid = false;&#13;
            bool isValid = false;&#13;
            bool isForceValid = false;&#13;
            for (uint8 i = 0; i &lt; modules[TRANSFERMANAGER_KEY].length; i++) {&#13;
                ITransferManager.Result valid = ITransferManager(modules[TRANSFERMANAGER_KEY][i].moduleAddress).verifyTransfer(_from, _to, _amount, isTransfer);&#13;
                if (valid == ITransferManager.Result.INVALID) {&#13;
                    isInvalid = true;&#13;
                }&#13;
                if (valid == ITransferManager.Result.VALID) {&#13;
                    isValid = true;&#13;
                }&#13;
                if (valid == ITransferManager.Result.FORCE_VALID) {&#13;
                    isForceValid = true;&#13;
                }&#13;
            }&#13;
            return isForceValid ? true : (isInvalid ? false : isValid);&#13;
      }&#13;
      return false;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice End token minting period permanently for Issuer&#13;
     */&#13;
    function finishMintingIssuer() public onlyOwner {&#13;
        finishedIssuerMinting = true;&#13;
        emit LogFinishMintingIssuer(now);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice End token minting period permanently for STOs&#13;
     */&#13;
    function finishMintingSTO() public onlyOwner {&#13;
        finishedSTOMinting = true;&#13;
        emit LogFinishMintingSTO(now);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice mints new tokens and assigns them to the target _investor.&#13;
     * @dev Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)&#13;
     * @param _investor Address to whom the minted tokens will be dilivered&#13;
     * @param _amount Number of tokens get minted&#13;
     * @return success&#13;
     */&#13;
    function mint(address _investor, uint256 _amount) public onlyModule(STO_KEY, true) checkGranularity(_amount) isMintingAllowed() returns (bool success) {&#13;
        require(_investor != address(0), "Investor address should not be 0x");&#13;
        adjustInvestorCount(address(0), _investor, _amount);&#13;
        require(verifyTransfer(address(0), _investor, _amount), "Transfer is not valid");&#13;
        adjustBalanceCheckpoints(_investor);&#13;
        adjustTotalSupplyCheckpoints();&#13;
        totalSupply_ = totalSupply_.add(_amount);&#13;
        balances[_investor] = balances[_investor].add(_amount);&#13;
        emit Minted(_investor, _amount);&#13;
        emit Transfer(address(0), _investor, _amount);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice mints new tokens and assigns them to the target _investor.&#13;
     * Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)&#13;
     * @param _investors A list of addresses to whom the minted tokens will be dilivered&#13;
     * @param _amounts A list of number of tokens get minted and transfer to corresponding address of the investor from _investor[] list&#13;
     * @return success&#13;
     */&#13;
    function mintMulti(address[] _investors, uint256[] _amounts) public onlyModule(STO_KEY, true) returns (bool success) {&#13;
        require(_investors.length == _amounts.length, "Mis-match in the length of the arrays");&#13;
        for (uint256 i = 0; i &lt; _investors.length; i++) {&#13;
            mint(_investors[i], _amounts[i]);&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Validate permissions with PermissionManager if it exists, If no Permission return false&#13;
     * @dev Note that IModule withPerm will allow ST owner all permissions anyway&#13;
     * @dev this allows individual modules to override this logic if needed (to not allow ST owner all permissions)&#13;
     * @param _delegate address of delegate&#13;
     * @param _module address of PermissionManager module&#13;
     * @param _perm the permissions&#13;
     * @return success&#13;
     */&#13;
    function checkPermission(address _delegate, address _module, bytes32 _perm) public view returns(bool) {&#13;
        if (modules[PERMISSIONMANAGER_KEY].length == 0) {&#13;
            return false;&#13;
        }&#13;
&#13;
        for (uint8 i = 0; i &lt; modules[PERMISSIONMANAGER_KEY].length; i++) {&#13;
            if (IPermissionManager(modules[PERMISSIONMANAGER_KEY][i].moduleAddress).checkPermission(_delegate, _module, _perm)) {&#13;
                return true;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice used to set the token Burner address. It only be called by the owner&#13;
     * @param _tokenBurner Address of the token burner contract&#13;
     */&#13;
    function setTokenBurner(address _tokenBurner) public onlyOwner {&#13;
        tokenBurner = ITokenBurner(_tokenBurner);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Burn function used to burn the securityToken&#13;
     * @param _value No. of token that get burned&#13;
     */&#13;
    function burn(uint256 _value) checkGranularity(_value) public {&#13;
        adjustInvestorCount(msg.sender, address(0), _value);&#13;
        require(tokenBurner != address(0), "Token Burner contract address is not set yet");&#13;
        require(verifyTransfer(msg.sender, address(0), _value), "Transfer is not valid");&#13;
        require(_value &lt;= balances[msg.sender], "Value should no be greater than the balance of msg.sender");&#13;
        adjustBalanceCheckpoints(msg.sender);&#13;
        adjustTotalSupplyCheckpoints();&#13;
        // no need to require value &lt;= totalSupply, since that would imply the&#13;
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure&#13;
&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
        require(tokenBurner.burn(msg.sender, _value), "Token burner process is not validated");&#13;
        totalSupply_ = totalSupply_.sub(_value);&#13;
        emit Burnt(msg.sender, _value);&#13;
        emit Transfer(msg.sender, address(0), _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Get function signature from _data&#13;
     * @param _data passed data&#13;
     * @return bytes4 sig&#13;
     */&#13;
    function getSig(bytes _data) internal pure returns (bytes4 sig) {&#13;
        uint len = _data.length &lt; 4 ? _data.length : 4;&#13;
        for (uint i = 0; i &lt; len; i++) {&#13;
            sig = bytes4(uint(sig) + uint(_data[i]) * (2 ** (8 * (len - 1 - i))));&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Creates a checkpoint that can be used to query historical balances / totalSuppy&#13;
     * @return uint256&#13;
     */&#13;
    function createCheckpoint() public onlyModule(CHECKPOINT_KEY, true) returns(uint256) {&#13;
        require(currentCheckpointId &lt; 2**256 - 1);&#13;
        currentCheckpointId = currentCheckpointId + 1;&#13;
        emit LogCheckpointCreated(currentCheckpointId, now);&#13;
        return currentCheckpointId;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Queries totalSupply as of a defined checkpoint&#13;
     * @param _checkpointId Checkpoint ID to query&#13;
     * @return uint256&#13;
     */&#13;
    function totalSupplyAt(uint256 _checkpointId) public view returns(uint256) {&#13;
        return getValueAt(checkpointTotalSupply, _checkpointId, totalSupply());&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Queries value at a defined checkpoint&#13;
     * @param checkpoints is array of Checkpoint objects&#13;
     * @param _checkpointId Checkpoint ID to query&#13;
     * @param _currentValue Current value of checkpoint&#13;
     * @return uint256&#13;
     */&#13;
    function getValueAt(Checkpoint[] storage checkpoints, uint256 _checkpointId, uint256 _currentValue) internal view returns(uint256) {&#13;
        require(_checkpointId &lt;= currentCheckpointId);&#13;
        //Checkpoint id 0 is when the token is first created - everyone has a zero balance&#13;
        if (_checkpointId == 0) {&#13;
          return 0;&#13;
        }&#13;
        if (checkpoints.length == 0) {&#13;
            return _currentValue;&#13;
        }&#13;
        if (checkpoints[0].checkpointId &gt;= _checkpointId) {&#13;
            return checkpoints[0].value;&#13;
        }&#13;
        if (checkpoints[checkpoints.length - 1].checkpointId &lt; _checkpointId) {&#13;
            return _currentValue;&#13;
        }&#13;
        if (checkpoints[checkpoints.length - 1].checkpointId == _checkpointId) {&#13;
            return checkpoints[checkpoints.length - 1].value;&#13;
        }&#13;
        uint256 min = 0;&#13;
        uint256 max = checkpoints.length - 1;&#13;
        while (max &gt; min) {&#13;
            uint256 mid = (max + min) / 2;&#13;
            if (checkpoints[mid].checkpointId == _checkpointId) {&#13;
                max = mid;&#13;
                break;&#13;
            }&#13;
            if (checkpoints[mid].checkpointId &lt; _checkpointId) {&#13;
                min = mid + 1;&#13;
            } else {&#13;
                max = mid;&#13;
            }&#13;
        }&#13;
        return checkpoints[max].value;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Queries balances as of a defined checkpoint&#13;
     * @param _investor Investor to query balance for&#13;
     * @param _checkpointId Checkpoint ID to query as of&#13;
     */&#13;
    function balanceOfAt(address _investor, uint256 _checkpointId) public view returns(uint256) {&#13;
        return getValueAt(checkpointBalances[_investor], _checkpointId, balanceOf(_investor));&#13;
    }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Interface for the polymath ticker registry contract&#13;
 */&#13;
contract ITickerRegistry {&#13;
    /**&#13;
    * @notice Check the validity of the symbol&#13;
    * @param _symbol token symbol&#13;
    * @param _owner address of the owner&#13;
    * @param _tokenName Name of the token&#13;
    * @return bool&#13;
    */&#13;
    function checkValidity(string _symbol, address _owner, string _tokenName) public returns(bool);&#13;
&#13;
    /**&#13;
    * @notice Returns the owner and timestamp for a given symbol&#13;
    * @param _symbol symbol&#13;
    */&#13;
    function getDetails(string _symbol) public view returns (address, uint256, string, bytes32, bool);&#13;
&#13;
    /**&#13;
     * @notice Check the symbol is reserved or not&#13;
     * @param _symbol Symbol of the token&#13;
     * @return bool&#13;
     */&#13;
     function isReserved(string _symbol, address _owner, string _tokenName, bytes32 _swarmHash) public returns(bool);&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Interface for security token proxy deployment&#13;
 */&#13;
contract ISTProxy {&#13;
&#13;
    /**&#13;
     * @notice deploys the token and adds default modules like permission manager and transfer manager.&#13;
     * Future versions of the proxy can attach different modules or pass some other paramters.&#13;
     */&#13;
    function deployToken(string _name, string _symbol, uint8 _decimals, string _tokenDetails, address _issuer, bool _divisible, address _polymathRegistry)&#13;
        public returns (address);&#13;
}&#13;
&#13;
/**&#13;
 * @title Interface for the polymath security token registry contract&#13;
 */&#13;
contract ISecurityTokenRegistry {&#13;
&#13;
    bytes32 public protocolVersion = "0.0.1";&#13;
    mapping (bytes32 =&gt; address) public protocolVersionST;&#13;
&#13;
    struct SecurityTokenData {&#13;
        string symbol;&#13;
        string tokenDetails;&#13;
    }&#13;
&#13;
    mapping(address =&gt; SecurityTokenData) securityTokens;&#13;
    mapping(string =&gt; address) symbols;&#13;
&#13;
    /**&#13;
     * @notice Creates a new Security Token and saves it to the registry&#13;
     * @param _name Name of the token&#13;
     * @param _symbol Ticker symbol of the security token&#13;
     * @param _tokenDetails off-chain details of the token&#13;
     */&#13;
    function generateSecurityToken(string _name, string _symbol, string _tokenDetails, bool _divisible) public;&#13;
&#13;
    function setProtocolVersion(address _stVersionProxyAddress, bytes32 _version) public;&#13;
&#13;
    /**&#13;
     * @notice Get security token address by ticker name&#13;
     * @param _symbol Symbol of the Scurity token&#13;
     * @return address _symbol&#13;
     */&#13;
    function getSecurityTokenAddress(string _symbol) public view returns (address);&#13;
&#13;
     /**&#13;
     * @notice Get security token data by its address&#13;
     * @param _securityToken Address of the Scurity token&#13;
     * @return string, address, bytes32&#13;
     */&#13;
    function getSecurityTokenData(address _securityToken) public view returns (string, address, string);&#13;
&#13;
    /**&#13;
    * @notice Check that Security Token is registered&#13;
    * @param _securityToken Address of the Scurity token&#13;
    * @return bool&#13;
    */&#13;
    function isSecurityToken(address _securityToken) public view returns (bool);&#13;
}&#13;
&#13;
/**&#13;
 * @title Utility contract for reusable code&#13;
 */&#13;
contract Util {&#13;
&#13;
   /**&#13;
    * @notice changes a string to upper case&#13;
    * @param _base string to change&#13;
    */&#13;
    function upper(string _base) internal pure returns (string) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        for (uint i = 0; i &lt; _baseBytes.length; i++) {&#13;
            bytes1 b1 = _baseBytes[i];&#13;
            if (b1 &gt;= 0x61 &amp;&amp; b1 &lt;= 0x7A) {&#13;
                b1 = bytes1(uint8(b1)-32);&#13;
            }&#13;
            _baseBytes[i] = b1;&#13;
        }&#13;
        return string(_baseBytes);&#13;
    }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Registry contract for issuers to register their security tokens&#13;
 */&#13;
contract SecurityTokenRegistry is ISecurityTokenRegistry, Util, Pausable, RegistryUpdater, ReclaimTokens {&#13;
&#13;
    // Registration fee in POLY base 18 decimals&#13;
    uint256 public registrationFee;&#13;
    // Emit when changePolyRegisterationFee is called&#13;
    event LogChangePolyRegisterationFee(uint256 _oldFee, uint256 _newFee);&#13;
&#13;
    // Emit at the time of launching of new security token&#13;
    event LogNewSecurityToken(string _ticker, address indexed _securityTokenAddress, address indexed _owner);&#13;
    event LogAddCustomSecurityToken(string _name, string _symbol, address _securityToken, uint256 _addedAt);&#13;
&#13;
    constructor (&#13;
        address _polymathRegistry,&#13;
        address _stVersionProxy,&#13;
        uint256 _registrationFee&#13;
    )&#13;
    public&#13;
    RegistryUpdater(_polymathRegistry)&#13;
    {&#13;
        registrationFee = _registrationFee;&#13;
        // By default, the STR version is set to 0.0.1&#13;
        setProtocolVersion(_stVersionProxy, "0.0.1");&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Creates a new Security Token and saves it to the registry&#13;
     * @param _name Name of the token&#13;
     * @param _symbol Ticker symbol of the security token&#13;
     * @param _tokenDetails off-chain details of the token&#13;
     * @param _divisible Set to true if token is divisible&#13;
     */&#13;
    function generateSecurityToken(string _name, string _symbol, string _tokenDetails, bool _divisible) public whenNotPaused {&#13;
        require(bytes(_name).length &gt; 0 &amp;&amp; bytes(_symbol).length &gt; 0, "Name and Symbol string length should be greater than 0");&#13;
        require(ITickerRegistry(tickerRegistry).checkValidity(_symbol, msg.sender, _name), "Trying to use non-valid symbol");&#13;
        if(registrationFee &gt; 0)&#13;
            require(ERC20(polyToken).transferFrom(msg.sender, this, registrationFee), "Failed transferFrom because of sufficent Allowance is not provided");&#13;
        string memory symbol = upper(_symbol);&#13;
        address newSecurityTokenAddress = ISTProxy(protocolVersionST[protocolVersion]).deployToken(&#13;
            _name,&#13;
            symbol,&#13;
            18,&#13;
            _tokenDetails,&#13;
            msg.sender,&#13;
            _divisible,&#13;
            polymathRegistry&#13;
        );&#13;
&#13;
        securityTokens[newSecurityTokenAddress] = SecurityTokenData(symbol, _tokenDetails);&#13;
        symbols[symbol] = newSecurityTokenAddress;&#13;
        emit LogNewSecurityToken(symbol, newSecurityTokenAddress, msg.sender);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Add a new custom (Token should follow the ISecurityToken interface) Security Token and saves it to the registry&#13;
     * @param _name Name of the token&#13;
     * @param _symbol Ticker symbol of the security token&#13;
     * @param _owner Owner of the token&#13;
     * @param _securityToken Address of the securityToken&#13;
     * @param _tokenDetails off-chain details of the token&#13;
     * @param _swarmHash off-chain details about the issuer company&#13;
     */&#13;
    function addCustomSecurityToken(string _name, string _symbol, address _owner, address _securityToken, string _tokenDetails, bytes32 _swarmHash) public onlyOwner whenNotPaused {&#13;
        require(bytes(_name).length &gt; 0 &amp;&amp; bytes(_symbol).length &gt; 0, "Name and Symbol string length should be greater than 0");&#13;
        string memory symbol = upper(_symbol);&#13;
        require(_securityToken != address(0) &amp;&amp; symbols[symbol] == address(0), "Symbol is already at the polymath network or entered security token address is 0x");&#13;
        require(_owner != address(0));&#13;
        require(!(ITickerRegistry(tickerRegistry).isReserved(symbol, _owner, _name, _swarmHash)), "Trying to use non-valid symbol");&#13;
        symbols[symbol] = _securityToken;&#13;
        securityTokens[_securityToken] = SecurityTokenData(symbol, _tokenDetails);&#13;
        emit LogAddCustomSecurityToken(_name, symbol, _securityToken, now);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Changes the protocol version and the SecurityToken contract&#13;
    * @notice Used only by Polymath to upgrade the SecurityToken contract and add more functionalities to future versions&#13;
    * @notice Changing versions does not affect existing tokens.&#13;
    */&#13;
    function setProtocolVersion(address _stVersionProxyAddress, bytes32 _version) public onlyOwner {&#13;
        protocolVersion = _version;&#13;
        protocolVersionST[_version] = _stVersionProxyAddress;&#13;
    }&#13;
&#13;
    //////////////////////////////&#13;
    ///////// Get Functions&#13;
    //////////////////////////////&#13;
    /**&#13;
     * @notice Get security token address by ticker name&#13;
     * @param _symbol Symbol of the Scurity token&#13;
     * @return address&#13;
     */&#13;
    function getSecurityTokenAddress(string _symbol) public view returns (address) {&#13;
        string memory __symbol = upper(_symbol);&#13;
        return symbols[__symbol];&#13;
    }&#13;
&#13;
     /**&#13;
     * @notice Get security token data by its address&#13;
     * @param _securityToken Address of the Scurity token&#13;
     * @return string&#13;
     * @return address&#13;
     * @return string&#13;
     */&#13;
    function getSecurityTokenData(address _securityToken) public view returns (string, address, string) {&#13;
        return (&#13;
            securityTokens[_securityToken].symbol,&#13;
            ISecurityToken(_securityToken).owner(),&#13;
            securityTokens[_securityToken].tokenDetails&#13;
        );&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Check that Security Token is registered&#13;
    * @param _securityToken Address of the Scurity token&#13;
    * @return bool&#13;
    */&#13;
    function isSecurityToken(address _securityToken) public view returns (bool) {&#13;
        return (keccak256(bytes(securityTokens[_securityToken].symbol)) != keccak256(""));&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice set the ticker registration fee in POLY tokens&#13;
     * @param _registrationFee registration fee in POLY tokens (base 18 decimals)&#13;
     */&#13;
    function changePolyRegisterationFee(uint256 _registrationFee) public onlyOwner {&#13;
        require(registrationFee != _registrationFee);&#13;
        emit LogChangePolyRegisterationFee(registrationFee, _registrationFee);&#13;
        registrationFee = _registrationFee;&#13;
    }&#13;
&#13;
     /**&#13;
     * @notice pause registration function&#13;
     */&#13;
    function unpause() public onlyOwner  {&#13;
        _unpause();&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice unpause registration function&#13;
     */&#13;
    function pause() public onlyOwner {&#13;
        _pause();&#13;
    }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Proxy for deploying Security Token v1&#13;
 */&#13;
contract STVersionProxy001 is ISTProxy {&#13;
&#13;
    address public transferManagerFactory;&#13;
&#13;
    // Should be set to false when we have more TransferManager options&#13;
    bool addTransferManager = true;&#13;
&#13;
    constructor (address _transferManagerFactory) public {&#13;
        transferManagerFactory = _transferManagerFactory;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice deploys the token and adds default modules like permission manager and transfer manager.&#13;
     * Future versions of the proxy can attach different modules or pass some other paramters.&#13;
     */&#13;
    function deployToken(string _name, string _symbol, uint8 _decimals, string _tokenDetails, address _issuer, bool _divisible, address _polymathRegistry)&#13;
    public returns (address) {&#13;
        address newSecurityTokenAddress = new SecurityToken(&#13;
        _name,&#13;
        _symbol,&#13;
        _decimals,&#13;
        _divisible ? 1 : uint256(10)**_decimals,&#13;
        _tokenDetails,&#13;
        _polymathRegistry&#13;
        );&#13;
&#13;
        if (addTransferManager) {&#13;
            SecurityToken(newSecurityTokenAddress).addModule(transferManagerFactory, "", 0, 0);&#13;
        }&#13;
&#13;
        SecurityToken(newSecurityTokenAddress).transferOwnership(_issuer);&#13;
&#13;
        return newSecurityTokenAddress;&#13;
    }&#13;
}