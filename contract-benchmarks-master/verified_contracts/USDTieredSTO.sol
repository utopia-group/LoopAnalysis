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
        require(!paused, "Contract is paused");
        _;
    }

    /**
    * @notice Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

   /**
    * @notice Called by the owner to pause, triggers stopped state
    */
    function _pause() internal whenNotPaused {
        paused = true;
        /*solium-disable-next-line security/no-block-members*/
        emit Pause(now);
    }

    /**
    * @notice Called by the owner to unpause, returns to normal state
    */
    function _unpause() internal whenPaused {
        paused = false;
        /*solium-disable-next-line security/no-block-members*/
        emit Unpause(now);
    }

}

/**
 * @title Interface that every module contract should implement
 */
interface IModule {

    /**
     * @notice This function returns the signature of configure function
     */
    function getInitFunction() external pure returns (bytes4);

    /**
     * @notice Return the permission flags that are associated with a module
     */
    function getPermissions() external view returns(bytes32[]);

    /**
     * @notice Used to withdraw the fee by the factory owner
     */
    function takeFee(uint256 _amount) external returns(bool);

}

/**
 * @title Interface for all security tokens
 */
interface ISecurityToken {

    // Standard ERC20 interface
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);
    function increaseApproval(address _spender, uint _addedValue) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //transfer, transferFrom must respect the result of verifyTransfer
    function verifyTransfer(address _from, address _to, uint256 _value) external returns (bool success);

    /**
     * @notice Mints new tokens and assigns them to the target _investor.
     * Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)
     * @param _investor Address the tokens will be minted to
     * @param _value is the amount of tokens that will be minted to the investor
     */
    function mint(address _investor, uint256 _value) external returns (bool success);

    /**
     * @notice Mints new tokens and assigns them to the target _investor.
     * Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)
     * @param _investor Address the tokens will be minted to
     * @param _value is The amount of tokens that will be minted to the investor
     * @param _data Data to indicate validation
     */
    function mintWithData(address _investor, uint256 _value, bytes _data) external returns (bool success);

    /**
     * @notice Used to burn the securityToken on behalf of someone else
     * @param _from Address for whom to burn tokens
     * @param _value No. of tokens to be burned
     * @param _data Data to indicate validation
     */
    function burnFromWithData(address _from, uint256 _value, bytes _data) external;

    /**
     * @notice Used to burn the securityToken
     * @param _value No. of tokens to be burned
     * @param _data Data to indicate validation
     */
    function burnWithData(uint256 _value, bytes _data) external;

    event Minted(address indexed _to, uint256 _value);
    event Burnt(address indexed _burner, uint256 _value);

    // Permissions this to a Permission module, which has a key of 1
    // If no Permission return false - note that IModule withPerm will allow ST owner all permissions anyway
    // this allows individual modules to override this logic if needed (to not allow ST owner all permissions)
    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns (bool);

    /**
     * @notice Returns module list for a module type
     * @param _module Address of the module
     * @return bytes32 Name
     * @return address Module address
     * @return address Module factory address
     * @return bool Module archived
     * @return uint8 Module type
     * @return uint256 Module index
     * @return uint256 Name index

     */
    function getModule(address _module) external view returns(bytes32, address, address, bool, uint8, uint256, uint256);

    /**
     * @notice Returns module list for a module name
     * @param _name Name of the module
     * @return address[] List of modules with this name
     */
    function getModulesByName(bytes32 _name) external view returns (address[]);

    /**
     * @notice Returns module list for a module type
     * @param _type Type of the module
     * @return address[] List of modules with this type
     */
    function getModulesByType(uint8 _type) external view returns (address[]);

    /**
     * @notice Queries totalSupply at a specified checkpoint
     * @param _checkpointId Checkpoint ID to query as of
     */
    function totalSupplyAt(uint256 _checkpointId) external view returns (uint256);

    /**
     * @notice Queries balance at a specified checkpoint
     * @param _investor Investor to query balance for
     * @param _checkpointId Checkpoint ID to query as of
     */
    function balanceOfAt(address _investor, uint256 _checkpointId) external view returns (uint256);

    /**
     * @notice Creates a checkpoint that can be used to query historical balances / totalSuppy
     */
    function createCheckpoint() external returns (uint256);

    /**
     * @notice Gets length of investors array
     * NB - this length may differ from investorCount if the list has not been pruned of zero-balance investors
     * @return Length
     */
    function getInvestors() external view returns (address[]);

    /**
     * @notice returns an array of investors at a given checkpoint
     * NB - this length may differ from investorCount as it contains all investors that ever held tokens
     * @param _checkpointId Checkpoint id at which investor list is to be populated
     * @return list of investors
     */
    function getInvestorsAt(uint256 _checkpointId) external view returns(address[]);

    /**
     * @notice generates subset of investors
     * NB - can be used in batches if investor list is large
     * @param _start Position of investor to start iteration from
     * @param _end Position of investor to stop iteration at
     * @return list of investors
     */
    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[]);
    
    /**
     * @notice Gets current checkpoint ID
     * @return Id
     */
    function currentCheckpointId() external view returns (uint256);

    /**
    * @notice Gets an investor at a particular index
    * @param _index Index to return address from
    * @return Investor address
    */
    function investors(uint256 _index) external view returns (address);

   /**
    * @notice Allows the owner to withdraw unspent POLY stored by them on the ST or any ERC20 token.
    * @dev Owner can transfer POLY to the ST which will be used to pay for modules that require a POLY fee.
    * @param _tokenContract Address of the ERC20Basic compliance token
    * @param _value Amount of POLY to withdraw
    */
    function withdrawERC20(address _tokenContract, uint256 _value) external;

    /**
    * @notice Allows owner to approve more POLY to one of the modules
    * @param _module Module address
    * @param _budget New budget
    */
    function changeModuleBudget(address _module, uint256 _budget) external;

    /**
     * @notice Changes the tokenDetails
     * @param _newTokenDetails New token details
     */
    function updateTokenDetails(string _newTokenDetails) external;

    /**
    * @notice Allows the owner to change token granularity
    * @param _granularity Granularity level of the token
    */
    function changeGranularity(uint256 _granularity) external;

    /**
    * @notice Removes addresses with zero balances from the investors list
    * @param _start Index in investors list at which to start removing zero balances
    * @param _iters Max number of iterations of the for loop
    * NB - pruning this list will mean you may not be able to iterate over investors on-chain as of a historical checkpoint
    */
    function pruneInvestors(uint256 _start, uint256 _iters) external;

    /**
     * @notice Freezes all the transfers
     */
    function freezeTransfers() external;

    /**
     * @notice Un-freezes all the transfers
     */
    function unfreezeTransfers() external;

    /**
     * @notice Ends token minting period permanently
     */
    function freezeMinting() external;

    /**
     * @notice Mints new tokens and assigns them to the target investors.
     * Can only be called by the STO attached to the token or by the Issuer (Security Token contract owner)
     * @param _investors A list of addresses to whom the minted tokens will be delivered
     * @param _values A list of the amount of tokens to mint to corresponding addresses from _investor[] list
     * @return Success
     */
    function mintMulti(address[] _investors, uint256[] _values) external returns (bool success);

    /**
     * @notice Function used to attach a module to the security token
     * @dev  E.G.: On deployment (through the STR) ST gets a TransferManager module attached to it
     * @dev to control restrictions on transfers.
     * @dev You are allowed to add a new moduleType if:
     * @dev - there is no existing module of that type yet added
     * @dev - the last member of the module list is replacable
     * @param _moduleFactory is the address of the module factory to be added
     * @param _data is data packed into bytes used to further configure the module (See STO usage)
     * @param _maxCost max amount of POLY willing to pay to module. (WIP)
     */
    function addModule(
        address _moduleFactory,
        bytes _data,
        uint256 _maxCost,
        uint256 _budget
    ) external;

    /**
    * @notice Archives a module attached to the SecurityToken
    * @param _module address of module to archive
    */
    function archiveModule(address _module) external;

    /**
    * @notice Unarchives a module attached to the SecurityToken
    * @param _module address of module to unarchive
    */
    function unarchiveModule(address _module) external;

    /**
    * @notice Removes a module attached to the SecurityToken
    * @param _module address of module to archive
    */
    function removeModule(address _module) external;

    /**
     * @notice Used by the issuer to set the controller addresses
     * @param _controller address of the controller
     */
    function setController(address _controller) external;

    /**
     * @notice Used by a controller to execute a forced transfer
     * @param _from address from which to take tokens
     * @param _to address where to send tokens
     * @param _value amount of tokens to transfer
     * @param _data data to indicate validation
     * @param _log data attached to the transfer by controller to emit in event
     */
    function forceTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _log) external;

    /**
     * @notice Used by a controller to execute a foced burn
     * @param _from address from which to take tokens
     * @param _value amount of tokens to transfer
     * @param _data data to indicate validation
     * @param _log data attached to the transfer by controller to emit in event
     */
    function forceBurn(address _from, uint256 _value, bytes _data, bytes _log) external;

    /**
     * @notice Used by the issuer to permanently disable controller functionality
     * @dev enabled via feature switch "disableControllerAllowed"
     */
     function disableController() external;

     /**
     * @notice Used to get the version of the securityToken
     */
     function getVersion() external view returns(uint8[]);

     /**
     * @notice Gets the investor count
     */
     function getInvestorCount() external view returns(uint256);

     /**
      * @notice Overloaded version of the transfer function
      * @param _to receiver of transfer
      * @param _value value of transfer
      * @param _data data to indicate validation
      * @return bool success
      */
     function transferWithData(address _to, uint256 _value, bytes _data) external returns (bool success);

     /**
      * @notice Overloaded version of the transferFrom function
      * @param _from sender of transfer
      * @param _to receiver of transfer
      * @param _value value of transfer
      * @param _data data to indicate validation
      * @return bool success
      */
     function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) external returns(bool);

     /**
      * @notice Provides the granularity of the token
      * @return uint256
      */
     function granularity() external view returns(uint256);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);
    function increaseApproval(address _spender, uint _addedValue) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
 * @title Interface that any module contract should implement
 * @notice Contract is abstract
 */
contract Module is IModule {

    address public factory;

    address public securityToken;

    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";

    IERC20 public polyToken;

    /**
     * @notice Constructor
     * @param _securityToken Address of the security token
     * @param _polyAddress Address of the polytoken
     */
    constructor (address _securityToken, address _polyAddress) public {
        securityToken = _securityToken;
        factory = msg.sender;
        polyToken = IERC20(_polyAddress);
    }

    //Allows owner, factory or permissioned delegate
    modifier withPerm(bytes32 _perm) {
        bool isOwner = msg.sender == Ownable(securityToken).owner();
        bool isFactory = msg.sender == factory;
        require(isOwner||isFactory||ISecurityToken(securityToken).checkPermission(msg.sender, address(this), _perm), "Permission check failed");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == Ownable(securityToken).owner(), "Sender is not owner");
        _;
    }

    modifier onlyFactory {
        require(msg.sender == factory, "Sender is not factory");
        _;
    }

    modifier onlyFactoryOwner {
        require(msg.sender == Ownable(factory).owner(), "Sender is not factory owner");
        _;
    }

    modifier onlyFactoryOrOwner {
        require((msg.sender == Ownable(securityToken).owner()) || (msg.sender == factory), "Sender is not factory or owner");
        _;
    }

    /**
     * @notice used to withdraw the fee by the factory owner
     */
    function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {
        require(polyToken.transferFrom(securityToken, Ownable(factory).owner(), _amount), "Unable to take fee");
        return true;
    }
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
 * @title Interface to be implemented by all STO modules
 */
contract ISTO is Module, Pausable  {
    using SafeMath for uint256;

    enum FundRaiseType { ETH, POLY, DAI }
    mapping (uint8 => bool) public fundRaiseTypes;
    mapping (uint8 => uint256) public fundsRaised;

    // Start time of the STO
    uint256 public startTime;
    // End time of the STO
    uint256 public endTime;
    // Time STO was paused
    uint256 public pausedTime;
    // Number of individual investors
    uint256 public investorCount;
    // Address where ETH & POLY funds are delivered
    address public wallet;
     // Final amount of tokens sold
    uint256 public totalTokensSold;

    // Event
    event SetFundRaiseTypes(FundRaiseType[] _fundRaiseTypes);

    /**
    * @notice Reclaims ERC20Basic compatible tokens
    * @dev We duplicate here due to the overriden owner & onlyOwner
    * @param _tokenContract The address of the token contract
    */
    function reclaimERC20(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, balance), "Transfer failed");
    }

    /**
     * @notice Returns funds raised by the STO
     */
    function getRaised(FundRaiseType _fundRaiseType) public view returns (uint256) {
        return fundsRaised[uint8(_fundRaiseType)];
    }

    /**
     * @notice Returns the total no. of tokens sold
     */
    function getTokensSold() public view returns (uint256);

    /**
     * @notice Pause (overridden function)
     */
    function pause() public onlyOwner {
        /*solium-disable-next-line security/no-block-members*/
        require(now < endTime, "STO has been finalized");
        super._pause();
    }

    /**
     * @notice Unpause (overridden function)
     */
    function unpause() public onlyOwner {
        super._unpause();
    }

    function _setFundRaiseType(FundRaiseType[] _fundRaiseTypes) internal {
        // FundRaiseType[] parameter type ensures only valid values for _fundRaiseTypes
        require(_fundRaiseTypes.length > 0, "Raise type is not specified");
        fundRaiseTypes[uint8(FundRaiseType.ETH)] = false;
        fundRaiseTypes[uint8(FundRaiseType.POLY)] = false;
        fundRaiseTypes[uint8(FundRaiseType.DAI)] = false;
        for (uint8 j = 0; j < _fundRaiseTypes.length; j++) {
            fundRaiseTypes[uint8(_fundRaiseTypes[j])] = true;
        }
        emit SetFundRaiseTypes(_fundRaiseTypes);
    }

}

interface IOracle {

    /**
    * @notice Returns address of oracle currency (0x0 for ETH)
    */
    function getCurrencyAddress() external view returns(address);

    /**
    * @notice Returns symbol of oracle currency (0x0 for ETH)
    */
    function getCurrencySymbol() external view returns(bytes32);

    /**
    * @notice Returns denomination of price
    */
    function getCurrencyDenominated() external view returns(bytes32);

    /**
    * @notice Returns price - should throw if not valid
    */
    function getPrice() external view returns(uint256);

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
        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner, balance), "Transfer failed");
    }
}

/**
 * @title Core functionality for registry upgradability
 */
contract PolymathRegistry is ReclaimTokens {

    mapping (bytes32 => address) public storedAddresses;

    event ChangeAddress(string _nameKey, address indexed _oldAddress, address indexed _newAddress);

    /**
     * @notice Gets the contract address
     * @param _nameKey is the key for the contract address mapping
     * @return address
     */
    function getAddress(string _nameKey) external view returns(address) {
        bytes32 key = keccak256(bytes(_nameKey));
        require(storedAddresses[key] != address(0), "Invalid address key");
        return storedAddresses[key];
    }

    /**
     * @notice Changes the contract address
     * @param _nameKey is the key for the contract address mapping
     * @param _newAddress is the new contract address
     */
    function changeAddress(string _nameKey, address _newAddress) external onlyOwner {
        bytes32 key = keccak256(bytes(_nameKey));
        emit ChangeAddress(_nameKey, storedAddresses[key], _newAddress);
        storedAddresses[key] = _newAddress;
    }


}

contract RegistryUpdater is Ownable {

    address public polymathRegistry;
    address public moduleRegistry;
    address public securityTokenRegistry;
    address public featureRegistry;
    address public polyToken;

    constructor (address _polymathRegistry) public {
        require(_polymathRegistry != address(0), "Invalid address");
        polymathRegistry = _polymathRegistry;
    }

    function updateFromRegistry() public onlyOwner {
        moduleRegistry = PolymathRegistry(polymathRegistry).getAddress("ModuleRegistry");
        securityTokenRegistry = PolymathRegistry(polymathRegistry).getAddress("SecurityTokenRegistry");
        featureRegistry = PolymathRegistry(polymathRegistry).getAddress("FeatureRegistry");
        polyToken = PolymathRegistry(polymathRegistry).getAddress("PolyToken");
    }

}

library DecimalMath {

    using SafeMath for uint256;

     /**
     * @notice This function multiplies two decimals represented as (decimal * 10**DECIMALS)
     * @return uint256 Result of multiplication represented as (decimal * 10**DECIMALS)
     */
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, y), (10 ** 18) / 2) / (10 ** 18);
    }

    /**
     * @notice This function divides two decimals represented as (decimal * 10**DECIMALS)
     * @return uint256 Result of division represented as (decimal * 10**DECIMALS)
     */
    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, (10 ** 18)), y / 2) / y;
    }

}

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a7d5c2cac4c8e795">[email protected]</a>π.com&gt;&#13;
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
contract USDTieredSTO is ISTO, ReentrancyGuard {&#13;
    using SafeMath for uint256;&#13;
&#13;
    /////////////&#13;
    // Storage //&#13;
    /////////////&#13;
&#13;
    string public POLY_ORACLE = "PolyUsdOracle";&#13;
    string public ETH_ORACLE = "EthUsdOracle";&#13;
    mapping (bytes32 =&gt; mapping (bytes32 =&gt; string)) oracleKeys;&#13;
&#13;
    IERC20 public usdToken;&#13;
&#13;
    // Determine whether users can invest on behalf of a beneficiary&#13;
    bool public allowBeneficialInvestments = false;&#13;
&#13;
    // Address where ETH, POLY &amp; DAI funds are delivered&#13;
    address public wallet;&#13;
&#13;
    // Address of issuer reserve wallet for unsold tokens&#13;
    address public reserveWallet;&#13;
&#13;
    // How many token units a buyer gets per USD per tier (multiplied by 10**18)&#13;
    uint256[] public ratePerTier;&#13;
&#13;
    // How many token units a buyer gets per USD per tier (multiplied by 10**18) when investing in POLY up to tokensPerTierDiscountPoly&#13;
    uint256[] public ratePerTierDiscountPoly;&#13;
&#13;
    // How many tokens are available in each tier (relative to totalSupply)&#13;
    uint256[] public tokensPerTierTotal;&#13;
&#13;
    // How many token units are available in each tier (relative to totalSupply) at the ratePerTierDiscountPoly rate&#13;
    uint256[] public tokensPerTierDiscountPoly;&#13;
&#13;
    // How many tokens have been minted in each tier (relative to totalSupply)&#13;
    uint256[] public mintedPerTierTotal;&#13;
&#13;
    // How many tokens have been minted in each tier (relative to totalSupply) for each fund raise type&#13;
    mapping (uint8 =&gt; uint256[]) public mintedPerTier;&#13;
&#13;
    // How many tokens have been minted in each tier (relative to totalSupply) at discounted POLY rate&#13;
    uint256[] public mintedPerTierDiscountPoly;&#13;
&#13;
    // Current tier&#13;
    uint8 public currentTier;&#13;
&#13;
    // Amount of USD funds raised&#13;
    uint256 public fundsRaisedUSD;&#13;
&#13;
    // Amount in USD invested by each address&#13;
    mapping (address =&gt; uint256) public investorInvestedUSD;&#13;
&#13;
    // Amount in fund raise type invested by each investor&#13;
    mapping (address =&gt; mapping (uint8 =&gt; uint256)) public investorInvested;&#13;
&#13;
    // List of accredited investors&#13;
    mapping (address =&gt; bool) public accredited;&#13;
&#13;
    // Default limit in USD for non-accredited investors multiplied by 10**18&#13;
    uint256 public nonAccreditedLimitUSD;&#13;
&#13;
    // Overrides for default limit in USD for non-accredited investors multiplied by 10**18&#13;
    mapping (address =&gt; uint256) public nonAccreditedLimitUSDOverride;&#13;
&#13;
    // Minimum investable amount in USD&#13;
    uint256 public minimumInvestmentUSD;&#13;
&#13;
    // Whether or not the STO has been finalized&#13;
    bool public isFinalized;&#13;
&#13;
    // Final amount of tokens returned to issuer&#13;
    uint256 public finalAmountReturned;&#13;
&#13;
    ////////////&#13;
    // Events //&#13;
    ////////////&#13;
&#13;
    event SetAllowBeneficialInvestments(bool _allowed);&#13;
    event SetNonAccreditedLimit(address _investor, uint256 _limit);&#13;
    event SetAccredited(address _investor, bool _accredited);&#13;
    event TokenPurchase(&#13;
        address indexed _purchaser,&#13;
        address indexed _beneficiary,&#13;
        uint256 _tokens,&#13;
        uint256 _usdAmount,&#13;
        uint256 _tierPrice,&#13;
        uint8 _tier&#13;
    );&#13;
    event FundsReceived(&#13;
        address indexed _purchaser,&#13;
        address indexed _beneficiary,&#13;
        uint256 _usdAmount,&#13;
        FundRaiseType _fundRaiseType,&#13;
        uint256 _receivedValue,&#13;
        uint256 _spentValue,&#13;
        uint256 _rate&#13;
    );&#13;
    event FundsReceivedPOLY(&#13;
        address indexed _purchaser,&#13;
        address indexed _beneficiary,&#13;
        uint256 _usdAmount,&#13;
        uint256 _receivedValue,&#13;
        uint256 _spentValue,&#13;
        uint256 _rate&#13;
    );&#13;
    event ReserveTokenMint(address indexed _owner, address indexed _wallet, uint256 _tokens, uint8 _latestTier);&#13;
&#13;
    event SetAddresses(&#13;
        address indexed _wallet,&#13;
        address indexed _reserveWallet,&#13;
        address indexed _usdToken&#13;
    );&#13;
    event SetLimits(&#13;
        uint256 _nonAccreditedLimitUSD,&#13;
        uint256 _minimumInvestmentUSD&#13;
    );&#13;
    event SetTimes(&#13;
        uint256 _startTime,&#13;
        uint256 _endTime&#13;
    );&#13;
    event SetTiers(&#13;
        uint256[] _ratePerTier,&#13;
        uint256[] _ratePerTierDiscountPoly,&#13;
        uint256[] _tokensPerTierTotal,&#13;
        uint256[] _tokensPerTierDiscountPoly&#13;
    );&#13;
&#13;
    ///////////////&#13;
    // Modifiers //&#13;
    ///////////////&#13;
&#13;
    modifier validETH {&#13;
        require(_getOracle(bytes32("ETH"), bytes32("USD")) != address(0), "Invalid ETHUSD Oracle");&#13;
        require(fundRaiseTypes[uint8(FundRaiseType.ETH)], "Fund raise in ETH should be allowed");&#13;
        _;&#13;
    }&#13;
&#13;
    modifier validPOLY {&#13;
        require(_getOracle(bytes32("POLY"), bytes32("USD")) != address(0), "Invalid POLYUSD Oracle");&#13;
        require(fundRaiseTypes[uint8(FundRaiseType.POLY)], "Fund raise in POLY should be allowed");&#13;
        _;&#13;
    }&#13;
&#13;
    modifier validDAI {&#13;
        require(fundRaiseTypes[uint8(FundRaiseType.DAI)], "Fund raise in DAI should be allowed");&#13;
        _;&#13;
    }&#13;
&#13;
    ///////////////////////&#13;
    // STO Configuration //&#13;
    ///////////////////////&#13;
&#13;
    constructor (address _securityToken, address _polyAddress, address _factory) public Module(_securityToken, _polyAddress) {&#13;
        oracleKeys[bytes32("ETH")][bytes32("USD")] = ETH_ORACLE;&#13;
        oracleKeys[bytes32("POLY")][bytes32("USD")] = POLY_ORACLE;&#13;
        require(_factory != address(0), "In-valid address");&#13;
        factory = _factory;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Function used to intialize the contract variables&#13;
     * @param _startTime Unix timestamp at which offering get started&#13;
     * @param _endTime Unix timestamp at which offering get ended&#13;
     * @param _ratePerTier Rate (in USD) per tier (* 10**18)&#13;
     * @param _tokensPerTierTotal Tokens available in each tier&#13;
     * @param _nonAccreditedLimitUSD Limit in USD (* 10**18) for non-accredited investors&#13;
     * @param _minimumInvestmentUSD Minimun investment in USD (* 10**18)&#13;
     * @param _fundRaiseTypes Types of currency used to collect the funds&#13;
     * @param _wallet Ethereum account address to hold the funds&#13;
     * @param _reserveWallet Ethereum account address to receive unsold tokens&#13;
     * @param _usdToken Contract address of the stable coin&#13;
     */&#13;
    function configure(&#13;
        uint256 _startTime,&#13;
        uint256 _endTime,&#13;
        uint256[] _ratePerTier,&#13;
        uint256[] _ratePerTierDiscountPoly,&#13;
        uint256[] _tokensPerTierTotal,&#13;
        uint256[] _tokensPerTierDiscountPoly,&#13;
        uint256 _nonAccreditedLimitUSD,&#13;
        uint256 _minimumInvestmentUSD,&#13;
        FundRaiseType[] _fundRaiseTypes,&#13;
        address _wallet,&#13;
        address _reserveWallet,&#13;
        address _usdToken&#13;
    ) public onlyFactory {&#13;
        modifyTimes(_startTime, _endTime);&#13;
        // NB - modifyTiers must come before modifyFunding&#13;
        modifyTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);&#13;
        // NB - modifyFunding must come before modifyAddresses&#13;
        modifyFunding(_fundRaiseTypes);&#13;
        modifyAddresses(_wallet, _reserveWallet, _usdToken);&#13;
        modifyLimits(_nonAccreditedLimitUSD, _minimumInvestmentUSD);&#13;
    }&#13;
&#13;
    function modifyFunding(FundRaiseType[] _fundRaiseTypes) public onlyFactoryOrOwner {&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        require(now &lt; startTime, "STO shouldn't be started");&#13;
        _setFundRaiseType(_fundRaiseTypes);&#13;
        uint256 length = getNumberOfTiers();&#13;
        mintedPerTierTotal = new uint256[](length);&#13;
        mintedPerTierDiscountPoly = new uint256[](length);&#13;
        for (uint8 i = 0; i &lt; _fundRaiseTypes.length; i++) {&#13;
            mintedPerTier[uint8(_fundRaiseTypes[i])] = new uint256[](length);&#13;
        }&#13;
    }&#13;
&#13;
    function modifyLimits(&#13;
        uint256 _nonAccreditedLimitUSD,&#13;
        uint256 _minimumInvestmentUSD&#13;
    ) public onlyFactoryOrOwner {&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        require(now &lt; startTime, "STO shouldn't be started");&#13;
        minimumInvestmentUSD = _minimumInvestmentUSD;&#13;
        nonAccreditedLimitUSD = _nonAccreditedLimitUSD;&#13;
        emit SetLimits(minimumInvestmentUSD, nonAccreditedLimitUSD);&#13;
    }&#13;
&#13;
    function modifyTiers(&#13;
        uint256[] _ratePerTier,&#13;
        uint256[] _ratePerTierDiscountPoly,&#13;
        uint256[] _tokensPerTierTotal,&#13;
        uint256[] _tokensPerTierDiscountPoly&#13;
    ) public onlyFactoryOrOwner {&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        require(now &lt; startTime, "STO shouldn't be started");&#13;
        require(_tokensPerTierTotal.length &gt; 0, "Length should be &gt; 0");&#13;
        require(_ratePerTier.length == _tokensPerTierTotal.length, "Mismatch b/w rates &amp; tokens / tier");&#13;
        require(_ratePerTierDiscountPoly.length == _tokensPerTierTotal.length, "Mismatch b/w discount rates &amp; tokens / tier");&#13;
        require(_tokensPerTierDiscountPoly.length == _tokensPerTierTotal.length, "Mismatch b/w discount tokens / tier &amp; tokens / tier");&#13;
        for (uint8 i = 0; i &lt; _ratePerTier.length; i++) {&#13;
            require(_ratePerTier[i] &gt; 0, "Rate &gt; 0");&#13;
            require(_tokensPerTierTotal[i] &gt; 0, "Tokens per tier &gt; 0");&#13;
            require(_tokensPerTierDiscountPoly[i] &lt;= _tokensPerTierTotal[i], "Discounted tokens / tier &lt;= tokens / tier");&#13;
            require(_ratePerTierDiscountPoly[i] &lt;= _ratePerTier[i], "Discounted rate / tier &lt;= rate / tier");&#13;
        }&#13;
        ratePerTier = _ratePerTier;&#13;
        ratePerTierDiscountPoly = _ratePerTierDiscountPoly;&#13;
        tokensPerTierTotal = _tokensPerTierTotal;&#13;
        tokensPerTierDiscountPoly = _tokensPerTierDiscountPoly;&#13;
        emit SetTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);&#13;
    }&#13;
&#13;
    function modifyTimes(&#13;
        uint256 _startTime,&#13;
        uint256 _endTime&#13;
    ) public onlyFactoryOrOwner {&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        require((startTime == 0) || (now &lt; startTime), "Invalid startTime");&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        require((_endTime &gt; _startTime) &amp;&amp; (_startTime &gt; now), "Invalid times");&#13;
        startTime = _startTime;&#13;
        endTime = _endTime;&#13;
        emit SetTimes(_startTime, _endTime);&#13;
    }&#13;
&#13;
    function modifyAddresses(&#13;
        address _wallet,&#13;
        address _reserveWallet,&#13;
        address _usdToken&#13;
    ) public onlyFactoryOrOwner {&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        require(now &lt; startTime, "STO shouldn't be started");&#13;
        require(_wallet != address(0) &amp;&amp; _reserveWallet != address(0), "Invalid address");&#13;
        if (fundRaiseTypes[uint8(FundRaiseType.DAI)]) {&#13;
            require(_usdToken != address(0), "Invalid address");&#13;
        }&#13;
        wallet = _wallet;&#13;
        reserveWallet = _reserveWallet;&#13;
        usdToken = IERC20(_usdToken);&#13;
        emit SetAddresses(_wallet, _reserveWallet, _usdToken);&#13;
    }&#13;
&#13;
    ////////////////////&#13;
    // STO Management //&#13;
    ////////////////////&#13;
&#13;
    /**&#13;
     * @notice Finalizes the STO and mint remaining tokens to reserve address&#13;
     * @notice Reserve address must be whitelisted to successfully finalize&#13;
     */&#13;
    function finalize() public onlyOwner {&#13;
        require(!isFinalized, "STO is already finalized");&#13;
        isFinalized = true;&#13;
        uint256 tempReturned;&#13;
        uint256 tempSold;&#13;
        uint256 remainingTokens;&#13;
        for (uint8 i = 0; i &lt; tokensPerTierTotal.length; i++) {&#13;
            remainingTokens = tokensPerTierTotal[i].sub(mintedPerTierTotal[i]);&#13;
            tempReturned = tempReturned.add(remainingTokens);&#13;
            tempSold = tempSold.add(mintedPerTierTotal[i]);&#13;
            if (remainingTokens &gt; 0) {&#13;
                mintedPerTierTotal[i] = tokensPerTierTotal[i];&#13;
            }&#13;
        }&#13;
        require(ISecurityToken(securityToken).mint(reserveWallet, tempReturned), "Error in minting");&#13;
        emit ReserveTokenMint(msg.sender, reserveWallet, tempReturned, currentTier);&#13;
        finalAmountReturned = tempReturned;&#13;
        totalTokensSold = tempSold;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Modifies the list of accredited addresses&#13;
     * @param _investors Array of investor addresses to modify&#13;
     * @param _accredited Array of bools specifying accreditation status&#13;
     */&#13;
    function changeAccredited(address[] _investors, bool[] _accredited) public onlyOwner {&#13;
        require(_investors.length == _accredited.length, "Array length mismatch");&#13;
        for (uint256 i = 0; i &lt; _investors.length; i++) {&#13;
            accredited[_investors[i]] = _accredited[i];&#13;
            emit SetAccredited(_investors[i], _accredited[i]);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Modifies the list of overrides for non-accredited limits in USD&#13;
     * @param _investors Array of investor addresses to modify&#13;
     * @param _nonAccreditedLimit Array of uints specifying non-accredited limits&#13;
     */&#13;
    function changeNonAccreditedLimit(address[] _investors, uint256[] _nonAccreditedLimit) public onlyOwner {&#13;
        //nonAccreditedLimitUSDOverride&#13;
        require(_investors.length == _nonAccreditedLimit.length, "Array length mismatch");&#13;
        for (uint256 i = 0; i &lt; _investors.length; i++) {&#13;
            require(_nonAccreditedLimit[i] &gt; 0, "Limit can not be 0");&#13;
            nonAccreditedLimitUSDOverride[_investors[i]] = _nonAccreditedLimit[i];&#13;
            emit SetNonAccreditedLimit(_investors[i], _nonAccreditedLimit[i]);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Function to set allowBeneficialInvestments (allow beneficiary to be different to funder)&#13;
     * @param _allowBeneficialInvestments Boolean to allow or disallow beneficial investments&#13;
     */&#13;
    function changeAllowBeneficialInvestments(bool _allowBeneficialInvestments) public onlyOwner {&#13;
        require(_allowBeneficialInvestments != allowBeneficialInvestments, "Value unchanged");&#13;
        allowBeneficialInvestments = _allowBeneficialInvestments;&#13;
        emit SetAllowBeneficialInvestments(allowBeneficialInvestments);&#13;
    }&#13;
&#13;
    //////////////////////////&#13;
    // Investment Functions //&#13;
    //////////////////////////&#13;
&#13;
    /**&#13;
    * @notice fallback function - assumes ETH being invested&#13;
    */&#13;
    function () external payable {&#13;
        buyWithETH(msg.sender);&#13;
    }&#13;
&#13;
    /**&#13;
      * @notice Purchase tokens using ETH&#13;
      * @param _beneficiary Address where security tokens will be sent&#13;
      */&#13;
    function buyWithETH(address _beneficiary) public payable validETH {&#13;
        uint256 rate = getRate(FundRaiseType.ETH);&#13;
        (uint256 spentUSD, uint256 spentValue) = _buyTokens(_beneficiary, msg.value, rate, FundRaiseType.ETH);&#13;
        // Modify storage&#13;
        investorInvested[_beneficiary][uint8(FundRaiseType.ETH)] = investorInvested[_beneficiary][uint8(FundRaiseType.ETH)].add(spentValue);&#13;
        fundsRaised[uint8(FundRaiseType.ETH)] = fundsRaised[uint8(FundRaiseType.ETH)].add(spentValue);&#13;
        // Forward ETH to issuer wallet&#13;
        wallet.transfer(spentValue);&#13;
        // Refund excess ETH to investor wallet&#13;
        msg.sender.transfer(msg.value.sub(spentValue));&#13;
        emit FundsReceived(msg.sender, _beneficiary, spentUSD, FundRaiseType.ETH, msg.value, spentValue, rate);&#13;
    }&#13;
&#13;
    /**&#13;
      * @notice Purchase tokens using POLY&#13;
      * @param _beneficiary Address where security tokens will be sent&#13;
      * @param _investedPOLY Amount of POLY invested&#13;
      */&#13;
    function buyWithPOLY(address _beneficiary, uint256 _investedPOLY) public validPOLY {&#13;
        _buyWithTokens(_beneficiary, _investedPOLY, FundRaiseType.POLY);&#13;
    }&#13;
&#13;
    /**&#13;
      * @notice Purchase tokens using POLY&#13;
      * @param _beneficiary Address where security tokens will be sent&#13;
      * @param _investedDAI Amount of POLY invested&#13;
      */&#13;
    function buyWithUSD(address _beneficiary, uint256 _investedDAI) public validDAI {&#13;
        _buyWithTokens(_beneficiary, _investedDAI, FundRaiseType.DAI);&#13;
    }&#13;
&#13;
    function _buyWithTokens(address _beneficiary, uint256 _tokenAmount, FundRaiseType _fundRaiseType) internal {&#13;
        require(_fundRaiseType == FundRaiseType.POLY || _fundRaiseType == FundRaiseType.DAI, "POLY &amp; DAI supported");&#13;
        uint256 rate = getRate(_fundRaiseType);&#13;
        (uint256 spentUSD, uint256 spentValue) = _buyTokens(_beneficiary, _tokenAmount, rate, _fundRaiseType);&#13;
        // Modify storage&#13;
        investorInvested[_beneficiary][uint8(_fundRaiseType)] = investorInvested[_beneficiary][uint8(_fundRaiseType)].add(spentValue);&#13;
        fundsRaised[uint8(_fundRaiseType)] = fundsRaised[uint8(_fundRaiseType)].add(spentValue);&#13;
        // Forward DAI to issuer wallet&#13;
        IERC20 token = _fundRaiseType == FundRaiseType.POLY ? polyToken : usdToken;&#13;
        require(token.transferFrom(msg.sender, wallet, spentValue), "Transfer failed");&#13;
        emit FundsReceived(msg.sender, _beneficiary, spentUSD, _fundRaiseType, _tokenAmount, spentValue, rate);&#13;
    }&#13;
&#13;
    /**&#13;
      * @notice Low level token purchase&#13;
      * @param _beneficiary Address where security tokens will be sent&#13;
      * @param _investmentValue Amount of POLY, ETH or DAI invested&#13;
      * @param _fundRaiseType Fund raise type (POLY, ETH, DAI)&#13;
      */&#13;
    function _buyTokens(&#13;
        address _beneficiary,&#13;
        uint256 _investmentValue,&#13;
        uint256 _rate,&#13;
        FundRaiseType _fundRaiseType&#13;
    )&#13;
        internal&#13;
        nonReentrant&#13;
        whenNotPaused&#13;
        returns(uint256, uint256)&#13;
    {&#13;
        if (!allowBeneficialInvestments) {&#13;
            require(_beneficiary == msg.sender, "Beneficiary does not match funder");&#13;
        }&#13;
&#13;
        require(isOpen(), "STO is not open");&#13;
        require(_investmentValue &gt; 0, "No funds were sent");&#13;
&#13;
        uint256 investedUSD = DecimalMath.mul(_rate, _investmentValue);&#13;
        uint256 originalUSD = investedUSD;&#13;
&#13;
        // Check for minimum investment&#13;
        require(investedUSD.add(investorInvestedUSD[_beneficiary]) &gt;= minimumInvestmentUSD, "Total investment &lt; minimumInvestmentUSD");&#13;
&#13;
        // Check for non-accredited cap&#13;
        if (!accredited[_beneficiary]) {&#13;
            uint256 investorLimitUSD = (nonAccreditedLimitUSDOverride[_beneficiary] == 0) ? nonAccreditedLimitUSD : nonAccreditedLimitUSDOverride[_beneficiary];&#13;
            require(investorInvestedUSD[_beneficiary] &lt; investorLimitUSD, "Non-accredited investor has reached limit");&#13;
            if (investedUSD.add(investorInvestedUSD[_beneficiary]) &gt; investorLimitUSD)&#13;
                investedUSD = investorLimitUSD.sub(investorInvestedUSD[_beneficiary]);&#13;
        }&#13;
        uint256 spentUSD;&#13;
        // Iterate over each tier and process payment&#13;
        for (uint8 i = currentTier; i &lt; ratePerTier.length; i++) {&#13;
            // Update current tier if needed&#13;
            if (currentTier != i)&#13;
                currentTier = i;&#13;
            // If there are tokens remaining, process investment&#13;
            if (mintedPerTierTotal[i] &lt; tokensPerTierTotal[i])&#13;
                spentUSD = spentUSD.add(_calculateTier(_beneficiary, i, investedUSD.sub(spentUSD), _fundRaiseType));&#13;
            // If all funds have been spent, exit the loop&#13;
            if (investedUSD == spentUSD)&#13;
                break;&#13;
        }&#13;
&#13;
        // Modify storage&#13;
        if (spentUSD &gt; 0) {&#13;
            if (investorInvestedUSD[_beneficiary] == 0)&#13;
                investorCount = investorCount + 1;&#13;
            investorInvestedUSD[_beneficiary] = investorInvestedUSD[_beneficiary].add(spentUSD);&#13;
            fundsRaisedUSD = fundsRaisedUSD.add(spentUSD);&#13;
        }&#13;
&#13;
        // Calculate spent in base currency (ETH, DAI or POLY)&#13;
        uint256 spentValue;&#13;
        if (spentUSD == 0) {&#13;
            spentValue = 0;&#13;
        } else {&#13;
            spentValue = DecimalMath.mul(DecimalMath.div(spentUSD, originalUSD), _investmentValue);&#13;
        }&#13;
&#13;
        // Return calculated amounts&#13;
        return (spentUSD, spentValue);&#13;
    }&#13;
&#13;
    function _calculateTier(&#13;
        address _beneficiary,&#13;
        uint8 _tier,&#13;
        uint256 _investedUSD,&#13;
        FundRaiseType _fundRaiseType&#13;
    ) &#13;
        internal&#13;
        returns(uint256)&#13;
     {&#13;
        // First purchase any discounted tokens if POLY investment&#13;
        uint256 spentUSD;&#13;
        uint256 tierSpentUSD;&#13;
        uint256 tierPurchasedTokens;&#13;
        uint256 investedUSD = _investedUSD;&#13;
        // Check whether there are any remaining discounted tokens&#13;
        if ((_fundRaiseType == FundRaiseType.POLY) &amp;&amp; (tokensPerTierDiscountPoly[_tier] &gt; mintedPerTierDiscountPoly[_tier])) {&#13;
            uint256 discountRemaining = tokensPerTierDiscountPoly[_tier].sub(mintedPerTierDiscountPoly[_tier]);&#13;
            uint256 totalRemaining = tokensPerTierTotal[_tier].sub(mintedPerTierTotal[_tier]);&#13;
            if (totalRemaining &lt; discountRemaining)&#13;
                (spentUSD, tierPurchasedTokens) = _purchaseTier(_beneficiary, ratePerTierDiscountPoly[_tier], totalRemaining, investedUSD, _tier);&#13;
            else&#13;
                (spentUSD, tierPurchasedTokens) = _purchaseTier(_beneficiary, ratePerTierDiscountPoly[_tier], discountRemaining, investedUSD, _tier);&#13;
            investedUSD = investedUSD.sub(spentUSD);&#13;
            mintedPerTierDiscountPoly[_tier] = mintedPerTierDiscountPoly[_tier].add(tierPurchasedTokens);&#13;
            mintedPerTier[uint8(FundRaiseType.POLY)][_tier] = mintedPerTier[uint8(FundRaiseType.POLY)][_tier].add(tierPurchasedTokens);&#13;
            mintedPerTierTotal[_tier] = mintedPerTierTotal[_tier].add(tierPurchasedTokens);&#13;
        }&#13;
        // Now, if there is any remaining USD to be invested, purchase at non-discounted rate&#13;
        if ((investedUSD &gt; 0) &amp;&amp; (tokensPerTierTotal[_tier].sub(mintedPerTierTotal[_tier]) &gt; 0)) {&#13;
            (tierSpentUSD, tierPurchasedTokens) = _purchaseTier(_beneficiary, ratePerTier[_tier], tokensPerTierTotal[_tier].sub(mintedPerTierTotal[_tier]), investedUSD, _tier);&#13;
            spentUSD = spentUSD.add(tierSpentUSD);&#13;
            mintedPerTier[uint8(_fundRaiseType)][_tier] = mintedPerTier[uint8(_fundRaiseType)][_tier].add(tierPurchasedTokens);&#13;
            mintedPerTierTotal[_tier] = mintedPerTierTotal[_tier].add(tierPurchasedTokens);&#13;
        }&#13;
        return spentUSD;&#13;
    }&#13;
&#13;
    function _purchaseTier(&#13;
        address _beneficiary,&#13;
        uint256 _tierPrice,&#13;
        uint256 _tierRemaining,&#13;
        uint256 _investedUSD,&#13;
        uint8 _tier&#13;
    )&#13;
        internal&#13;
        returns(uint256, uint256)&#13;
    {&#13;
        uint256 maximumTokens = DecimalMath.div(_investedUSD, _tierPrice);&#13;
        uint256 spentUSD;&#13;
        uint256 purchasedTokens;&#13;
        if (maximumTokens &gt; _tierRemaining) {&#13;
            spentUSD = DecimalMath.mul(_tierRemaining, _tierPrice);&#13;
            // In case of rounding issues, ensure that spentUSD is never more than investedUSD&#13;
            if (spentUSD &gt; _investedUSD) {&#13;
                spentUSD = _investedUSD;&#13;
            }&#13;
            purchasedTokens = _tierRemaining;&#13;
        } else {&#13;
            spentUSD = _investedUSD;&#13;
            purchasedTokens = maximumTokens;&#13;
        }&#13;
        require(ISecurityToken(securityToken).mint(_beneficiary, purchasedTokens), "Error in minting");&#13;
        emit TokenPurchase(msg.sender, _beneficiary, purchasedTokens, spentUSD, _tierPrice, _tier);&#13;
        return (spentUSD, purchasedTokens);&#13;
    }&#13;
&#13;
    /////////////&#13;
    // Getters //&#13;
    /////////////&#13;
&#13;
    /**&#13;
     * @notice This function returns whether or not the STO is in fundraising mode (open)&#13;
     * @return bool Whether the STO is accepting investments&#13;
     */&#13;
    function isOpen() public view returns(bool) {&#13;
        if (isFinalized)&#13;
            return false;&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        if (now &lt; startTime)&#13;
            return false;&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        if (now &gt;= endTime)&#13;
            return false;&#13;
        if (capReached())&#13;
            return false;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Checks whether the cap has been reached.&#13;
     * @return bool Whether the cap was reached&#13;
     */&#13;
    function capReached() public view returns (bool) {&#13;
        if (isFinalized) {&#13;
            return (finalAmountReturned == 0);&#13;
        }&#13;
        return (mintedPerTierTotal[mintedPerTierTotal.length - 1] == tokensPerTierTotal[tokensPerTierTotal.length - 1]);&#13;
    }&#13;
&#13;
    function getRate(FundRaiseType _fundRaiseType) public view returns (uint256) {&#13;
        if (_fundRaiseType == FundRaiseType.ETH) {&#13;
            return IOracle(_getOracle(bytes32("ETH"), bytes32("USD"))).getPrice();&#13;
        } else if (_fundRaiseType == FundRaiseType.POLY) {&#13;
            return IOracle(_getOracle(bytes32("POLY"), bytes32("USD"))).getPrice();&#13;
        } else if (_fundRaiseType == FundRaiseType.DAI) {&#13;
            return 1 * 10**18;&#13;
        } else {&#13;
            revert("Incorrect funding");&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice This function converts from ETH or POLY to USD&#13;
     * @param _fundRaiseType Currency key&#13;
     * @param _amount Value to convert to USD&#13;
     * @return uint256 Value in USD&#13;
     */&#13;
    function convertToUSD(FundRaiseType _fundRaiseType, uint256 _amount) public view returns(uint256) {&#13;
        uint256 rate = getRate(_fundRaiseType);&#13;
        return DecimalMath.mul(_amount, rate);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice This function converts from USD to ETH or POLY&#13;
     * @param _fundRaiseType Currency key&#13;
     * @param _amount Value to convert from USD&#13;
     * @return uint256 Value in ETH or POLY&#13;
     */&#13;
    function convertFromUSD(FundRaiseType _fundRaiseType, uint256 _amount) public view returns(uint256) {&#13;
        uint256 rate = getRate(_fundRaiseType);&#13;
        return DecimalMath.div(_amount, rate);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Return the total no. of tokens sold&#13;
     * @return uint256 Total number of tokens sold&#13;
     */&#13;
    function getTokensSold() public view returns (uint256) {&#13;
        if (isFinalized)&#13;
            return totalTokensSold;&#13;
        else&#13;
            return getTokensMinted();&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Return the total no. of tokens minted&#13;
     * @return uint256 Total number of tokens minted&#13;
     */&#13;
    function getTokensMinted() public view returns (uint256) {&#13;
        uint256 tokensMinted;&#13;
        for (uint8 i = 0; i &lt; mintedPerTierTotal.length; i++) {&#13;
            tokensMinted = tokensMinted.add(mintedPerTierTotal[i]);&#13;
        }&#13;
        return tokensMinted;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Return the total no. of tokens sold for ETH&#13;
     * @return uint256 Total number of tokens sold for ETH&#13;
     */&#13;
    function getTokensSoldFor(FundRaiseType _fundRaiseType) public view returns (uint256) {&#13;
        uint256 tokensSold;&#13;
        for (uint8 i = 0; i &lt; mintedPerTier[uint8(_fundRaiseType)].length; i++) {&#13;
            tokensSold = tokensSold.add(mintedPerTier[uint8(_fundRaiseType)][i]);&#13;
        }&#13;
        return tokensSold;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Return the total no. of tiers&#13;
     * @return uint256 Total number of tiers&#13;
     */&#13;
    function getNumberOfTiers() public view returns (uint256) {&#13;
        return tokensPerTierTotal.length;&#13;
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
     * @notice This function returns the signature of configure function&#13;
     * @return bytes4 Configure function signature&#13;
     */&#13;
    function getInitFunction() public pure returns (bytes4) {&#13;
        return 0xb0ff041e;&#13;
    }&#13;
&#13;
    function _getOracle(bytes32 _currency, bytes32 _denominatedCurrency) internal view returns (address) {&#13;
        return PolymathRegistry(RegistryUpdater(securityToken).polymathRegistry()).getAddress(oracleKeys[_currency][_denominatedCurrency]);&#13;
    }&#13;
&#13;
}