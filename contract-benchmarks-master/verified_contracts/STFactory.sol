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
 * @title Interface that every module factory contract should implement
 */
interface IModuleFactory {

    event ChangeFactorySetupFee(uint256 _oldSetupCost, uint256 _newSetupCost, address _moduleFactory);
    event ChangeFactoryUsageFee(uint256 _oldUsageCost, uint256 _newUsageCost, address _moduleFactory);
    event ChangeFactorySubscriptionFee(uint256 _oldSubscriptionCost, uint256 _newMonthlySubscriptionCost, address _moduleFactory);
    event GenerateModuleFromFactory(
        address _module,
        bytes32 indexed _moduleName,
        address indexed _moduleFactory,
        address _creator,
        uint256 _setupCost,
        uint256 _timestamp
    );
    event ChangeSTVersionBound(string _boundType, uint8 _major, uint8 _minor, uint8 _patch);

    //Should create an instance of the Module, or throw
    function deploy(bytes _data) external returns(address);

    /**
     * @notice Type of the Module factory
     */
    function getTypes() external view returns(uint8[]);

    /**
     * @notice Get the name of the Module
     */
    function getName() external view returns(bytes32);

    /**
     * @notice Returns the instructions associated with the module
     */
    function getInstructions() external view returns (string);

    /**
     * @notice Get the tags related to the module factory
     */
    function getTags() external view returns (bytes32[]);

    /**
     * @notice Used to change the setup fee
     * @param _newSetupCost New setup fee
     */
    function changeFactorySetupFee(uint256 _newSetupCost) external;

    /**
     * @notice Used to change the usage fee
     * @param _newUsageCost New usage fee
     */
    function changeFactoryUsageFee(uint256 _newUsageCost) external;

    /**
     * @notice Used to change the subscription fee
     * @param _newSubscriptionCost New subscription fee
     */
    function changeFactorySubscriptionFee(uint256 _newSubscriptionCost) external;

    /**
     * @notice Function use to change the lower and upper bound of the compatible version st
     * @param _boundType Type of bound
     * @param _newVersion New version array
     */
    function changeSTVersionBounds(string _boundType, uint8[] _newVersion) external;

   /**
     * @notice Get the setup cost of the module
     */
    function getSetupCost() external view returns (uint256);

    /**
     * @notice Used to get the lower bound
     * @return Lower bound
     */
    function getLowerSTVersionBounds() external view returns(uint8[]);

     /**
     * @notice Used to get the upper bound
     * @return Upper bound
     */
    function getUpperSTVersionBounds() external view returns(uint8[]);

}

/**
 * @title Interface for the Polymath Module Registry contract
 */
interface IModuleRegistry {

    /**
     * @notice Called by a security token to notify the registry it is using a module
     * @param _moduleFactory is the address of the relevant module factory
     */
    function useModule(address _moduleFactory) external;

    /**
     * @notice Called by the ModuleFactory owner to register new modules for SecurityToken to use
     * @param _moduleFactory is the address of the module factory to be registered
     */
    function registerModule(address _moduleFactory) external;

    /**
     * @notice Called by the ModuleFactory owner or registry curator to delete a ModuleFactory
     * @param _moduleFactory is the address of the module factory to be deleted
     */
    function removeModule(address _moduleFactory) external;

    /**
    * @notice Called by Polymath to verify modules for SecurityToken to use.
    * @notice A module can not be used by an ST unless first approved/verified by Polymath
    * @notice (The only exception to this is that the author of the module is the owner of the ST - Only if enabled by the FeatureRegistry)
    * @param _moduleFactory is the address of the module factory to be registered
    */
    function verifyModule(address _moduleFactory, bool _verified) external;

    /**
     * @notice Used to get the reputation of a Module Factory
     * @param _factoryAddress address of the Module Factory
     * @return address array which has the list of securityToken's uses that module factory
     */
    function getReputationByFactory(address _factoryAddress) external view returns(address[]);

    /**
     * @notice Returns all the tags related to the a module type which are valid for the given token
     * @param _moduleType is the module type
     * @param _securityToken is the token
     * @return list of tags
     * @return corresponding list of module factories
     */
    function getTagsByTypeAndToken(uint8 _moduleType, address _securityToken) external view returns(bytes32[], address[]);

    /**
     * @notice Returns all the tags related to the a module type which are valid for the given token
     * @param _moduleType is the module type
     * @return list of tags
     * @return corresponding list of module factories
     */
    function getTagsByType(uint8 _moduleType) external view returns(bytes32[], address[]);

    /**
     * @notice Returns the list of addresses of Module Factory of a particular type
     * @param _moduleType Type of Module
     * @return address array that contains the list of addresses of module factory contracts.
     */
    function getModulesByType(uint8 _moduleType) external view returns(address[]);

    /**
     * @notice Returns the list of available Module factory addresses of a particular type for a given token.
     * @param _moduleType is the module type to look for
     * @param _securityToken is the address of SecurityToken
     * @return address array that contains the list of available addresses of module factory contracts.
     */
    function getModulesByTypeAndToken(uint8 _moduleType, address _securityToken) external view returns (address[]);

    /**
     * @notice Use to get the latest contract address of the regstries
     */
    function updateFromRegistry() external;

    /**
     * @notice Get the owner of the contract
     * @return address owner
     */
    function owner() external view returns(address);

    /**
     * @notice Check whether the contract operations is paused or not
     * @return bool 
     */
    function isPaused() external view returns(bool);

}

/**
 * @title Interface for managing polymath feature switches
 */
interface IFeatureRegistry {

    /**
     * @notice Get the status of a feature
     * @param _nameKey is the key for the feature status mapping
     * @return bool
     */
    function getFeatureStatus(string _nameKey) external view returns(bool);

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
 * @title Interface to be implemented by all Transfer Manager modules
 * @dev abstract contract
 */
contract ITransferManager is Module, Pausable {

    //If verifyTransfer returns:
    //  FORCE_VALID, the transaction will always be valid, regardless of other TM results
    //  INVALID, then the transfer should not be allowed regardless of other TM results
    //  VALID, then the transfer is valid for this TM
    //  NA, then the result from this TM is ignored
    enum Result {INVALID, NA, VALID, FORCE_VALID}

    function verifyTransfer(address _from, address _to, uint256 _amount, bytes _data, bool _isTransfer) public returns(Result);

    function unpause() public onlyOwner {
        super._unpause();
    }

    function pause() public onlyOwner {
        super._pause();
    }
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

/**
 * @title Utility contract for reusable code
 */
library Util {

   /**
    * @notice Changes a string to upper case
    * @param _base String to change
    */
    function upper(string _base) internal pure returns (string) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            bytes1 b1 = _baseBytes[i];
            if (b1 >= 0x61 && b1 <= 0x7A) {
                b1 = bytes1(uint8(b1)-32);
            }
            _baseBytes[i] = b1;
        }
        return string(_baseBytes);
    }

    /**
     * @notice Changes the string into bytes32
     * @param _source String that need to convert into bytes32
     */
    /// Notice - Maximum Length for _source will be 32 chars otherwise returned bytes32 value will have lossy value.
    function stringToBytes32(string memory _source) internal pure returns (bytes32) {
        return bytesToBytes32(bytes(_source), 0);
    }

    /**
     * @notice Changes bytes into bytes32
     * @param _b Bytes that need to convert into bytes32
     * @param _offset Offset from which to begin conversion
     */
    /// Notice - Maximum length for _source will be 32 chars otherwise returned bytes32 value will have lossy value.
    function bytesToBytes32(bytes _b, uint _offset) internal pure returns (bytes32) {
        bytes32 result;

        for (uint i = 0; i < _b.length; i++) {
            result |= bytes32(_b[_offset + i] & 0xFF) >> (i * 8);
        }
        return result;
    }

    /**
     * @notice Changes the bytes32 into string
     * @param _source that need to convert into string
     */
    function bytes32ToString(bytes32 _source) internal pure returns (string result) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(_source) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    /**
     * @notice Gets function signature from _data
     * @param _data Passed data
     * @return bytes4 sig
     */
    function getSig(bytes _data) internal pure returns (bytes4 sig) {
        uint len = _data.length < 4 ? _data.length : 4;
        for (uint i = 0; i < len; i++) {
            sig = bytes4(uint(sig) + uint(_data[i]) * (2 ** (8 * (len - 1 - i))));
        }
    }


}

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5725323a34381765">[email protected]</a>π.com&gt;&#13;
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
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  function totalSupply() public view returns (uint256);&#13;
  function balanceOf(address who) public view returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, throws on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the&#13;
    // benefit is lost if 'b' is also tested.&#13;
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    // uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return a / b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances.&#13;
 */&#13;
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping(address =&gt; uint256) balances;&#13;
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
  /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[msg.sender]);&#13;
&#13;
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    emit Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param _owner The address to query the the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) public view returns (uint256) {&#13;
    return balances[_owner];&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender)&#13;
    public view returns (uint256);&#13;
&#13;
  function transferFrom(address from, address to, uint256 value)&#13;
    public returns (bool);&#13;
&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(&#13;
    address indexed owner,&#13;
    address indexed spender,&#13;
    uint256 value&#13;
  );&#13;
}&#13;
&#13;
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
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[_from]);&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
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
  function allowance(&#13;
    address _owner,&#13;
    address _spender&#13;
   )&#13;
    public&#13;
    view&#13;
    returns (uint256)&#13;
  {&#13;
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
  function increaseApproval(&#13;
    address _spender,&#13;
    uint _addedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    allowed[msg.sender][_spender] = (&#13;
      allowed[msg.sender][_spender].add(_addedValue));&#13;
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
  function decreaseApproval(&#13;
    address _spender,&#13;
    uint _subtractedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
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
/**&#13;
 * @title Interface to be implemented by all permission manager modules&#13;
 */&#13;
interface IPermissionManager {&#13;
&#13;
    /**&#13;
    * @notice Used to check the permission on delegate corresponds to module contract address&#13;
    * @param _delegate Ethereum address of the delegate&#13;
    * @param _module Ethereum contract address of the module&#13;
    * @param _perm Permission flag&#13;
    * @return bool&#13;
    */&#13;
    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns(bool);&#13;
&#13;
    /**&#13;
    * @notice Used to add a delegate&#13;
    * @param _delegate Ethereum address of the delegate&#13;
    * @param _details Details about the delegate i.e `Belongs to financial firm`&#13;
    */&#13;
    function addDelegate(address _delegate, bytes32 _details) external;&#13;
&#13;
    /**&#13;
    * @notice Used to delete a delegate&#13;
    * @param _delegate Ethereum address of the delegate&#13;
    */&#13;
    function deleteDelegate(address _delegate) external;&#13;
&#13;
    /**&#13;
    * @notice Used to check if an address is a delegate or not&#13;
    * @param _potentialDelegate the address of potential delegate&#13;
    * @return bool&#13;
    */&#13;
    function checkDelegate(address _potentialDelegate) external view returns(bool);&#13;
&#13;
    /**&#13;
    * @notice Used to provide/change the permission to the delegate corresponds to the module contract&#13;
    * @param _delegate Ethereum address of the delegate&#13;
    * @param _module Ethereum contract address of the module&#13;
    * @param _perm Permission flag&#13;
    * @param _valid Bool flag use to switch on/off the permission&#13;
    * @return bool&#13;
    */&#13;
    function changePermission(&#13;
        address _delegate,&#13;
        address _module,&#13;
        bytes32 _perm,&#13;
        bool _valid&#13;
    )&#13;
    external;&#13;
&#13;
    /**&#13;
    * @notice Used to change one or more permissions for a single delegate at once&#13;
    * @param _delegate Ethereum address of the delegate&#13;
    * @param _modules Multiple module matching the multiperms, needs to be same length&#13;
    * @param _perms Multiple permission flag needs to be changed&#13;
    * @param _valids Bool array consist the flag to switch on/off the permission&#13;
    * @return nothing&#13;
    */&#13;
    function changePermissionMulti(&#13;
        address _delegate,&#13;
        address[] _modules,&#13;
        bytes32[] _perms,&#13;
        bool[] _valids&#13;
    )&#13;
    external;&#13;
&#13;
    /**&#13;
    * @notice Used to return all delegates with a given permission and module&#13;
    * @param _module Ethereum contract address of the module&#13;
    * @param _perm Permission flag&#13;
    * @return address[]&#13;
    */&#13;
    function getAllDelegatesWithPerm(address _module, bytes32 _perm) external view returns(address[]);&#13;
&#13;
     /**&#13;
    * @notice Used to return all permission of a single or multiple module&#13;
    * @dev possible that function get out of gas is there are lot of modules and perm related to them&#13;
    * @param _delegate Ethereum address of the delegate&#13;
    * @param _types uint8[] of types&#13;
    * @return address[] the address array of Modules this delegate has permission&#13;
    * @return bytes32[] the permission array of the corresponding Modules&#13;
    */&#13;
    function getAllModulesAndPermsFromTypes(address _delegate, uint8[] _types) external view returns(address[], bytes32[]);&#13;
&#13;
    /**&#13;
    * @notice Used to get the Permission flag related the `this` contract&#13;
    * @return Array of permission flags&#13;
    */&#13;
    function getPermissions() external view returns(bytes32[]);&#13;
&#13;
    /**&#13;
    * @notice Used to get all delegates&#13;
    * @return address[]&#13;
    */&#13;
    function getAllDelegates() external view returns(address[]);&#13;
&#13;
}&#13;
&#13;
library TokenLib {&#13;
&#13;
    using SafeMath for uint256;&#13;
&#13;
    // Struct for module data&#13;
    struct ModuleData {&#13;
        bytes32 name;&#13;
        address module;&#13;
        address moduleFactory;&#13;
        bool isArchived;&#13;
        uint8[] moduleTypes;&#13;
        uint256[] moduleIndexes;&#13;
        uint256 nameIndex;&#13;
    }&#13;
&#13;
    // Structures to maintain checkpoints of balances for governance / dividends&#13;
    struct Checkpoint {&#13;
        uint256 checkpointId;&#13;
        uint256 value;&#13;
    }&#13;
&#13;
    struct InvestorDataStorage {&#13;
        // List of investors who have ever held a non-zero token balance&#13;
        mapping (address =&gt; bool) investorListed;&#13;
        // List of token holders&#13;
        address[] investors;&#13;
        // Total number of non-zero token holders&#13;
        uint256 investorCount;&#13;
    }&#13;
&#13;
    // Emit when Module is archived from the SecurityToken&#13;
    event ModuleArchived(uint8[] _types, address _module, uint256 _timestamp);&#13;
    // Emit when Module is unarchived from the SecurityToken&#13;
    event ModuleUnarchived(uint8[] _types, address _module, uint256 _timestamp);&#13;
&#13;
    /**&#13;
    * @notice Archives a module attached to the SecurityToken&#13;
    * @param _moduleData Storage data&#13;
    * @param _module Address of module to archive&#13;
    */&#13;
    function archiveModule(ModuleData storage _moduleData, address _module) public {&#13;
        require(!_moduleData.isArchived, "Module archived");&#13;
        require(_moduleData.module != address(0), "Module missing");&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        emit ModuleArchived(_moduleData.moduleTypes, _module, now);&#13;
        _moduleData.isArchived = true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Unarchives a module attached to the SecurityToken&#13;
    * @param _moduleData Storage data&#13;
    * @param _module Address of module to unarchive&#13;
    */&#13;
    function unarchiveModule(ModuleData storage _moduleData, address _module) public {&#13;
        require(_moduleData.isArchived, "Module unarchived");&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        emit ModuleUnarchived(_moduleData.moduleTypes, _module, now);&#13;
        _moduleData.isArchived = false;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Validates permissions with PermissionManager if it exists. If there's no permission return false&#13;
     * @dev Note that IModule withPerm will allow ST owner all permissions by default&#13;
     * @dev this allows individual modules to override this logic if needed (to not allow ST owner all permissions)&#13;
     * @param _modules is the modules to check permissions on&#13;
     * @param _delegate is the address of the delegate&#13;
     * @param _module is the address of the PermissionManager module&#13;
     * @param _perm is the permissions data&#13;
     * @return success&#13;
     */&#13;
    function checkPermission(address[] storage _modules, address _delegate, address _module, bytes32 _perm) public view returns(bool) {&#13;
        if (_modules.length == 0) {&#13;
            return false;&#13;
        }&#13;
&#13;
        for (uint8 i = 0; i &lt; _modules.length; i++) {&#13;
            if (IPermissionManager(_modules[i]).checkPermission(_delegate, _module, _perm)) {&#13;
                return true;&#13;
            }&#13;
        }&#13;
&#13;
        return false;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Queries a value at a defined checkpoint&#13;
     * @param _checkpoints is array of Checkpoint objects&#13;
     * @param _checkpointId is the Checkpoint ID to query&#13;
     * @param _currentValue is the Current value of checkpoint&#13;
     * @return uint256&#13;
     */&#13;
    function getValueAt(Checkpoint[] storage _checkpoints, uint256 _checkpointId, uint256 _currentValue) public view returns(uint256) {&#13;
        //Checkpoint id 0 is when the token is first created - everyone has a zero balance&#13;
        if (_checkpointId == 0) {&#13;
            return 0;&#13;
        }&#13;
        if (_checkpoints.length == 0) {&#13;
            return _currentValue;&#13;
        }&#13;
        if (_checkpoints[0].checkpointId &gt;= _checkpointId) {&#13;
            return _checkpoints[0].value;&#13;
        }&#13;
        if (_checkpoints[_checkpoints.length - 1].checkpointId &lt; _checkpointId) {&#13;
            return _currentValue;&#13;
        }&#13;
        if (_checkpoints[_checkpoints.length - 1].checkpointId == _checkpointId) {&#13;
            return _checkpoints[_checkpoints.length - 1].value;&#13;
        }&#13;
        uint256 min = 0;&#13;
        uint256 max = _checkpoints.length - 1;&#13;
        while (max &gt; min) {&#13;
            uint256 mid = (max + min) / 2;&#13;
            if (_checkpoints[mid].checkpointId == _checkpointId) {&#13;
                max = mid;&#13;
                break;&#13;
            }&#13;
            if (_checkpoints[mid].checkpointId &lt; _checkpointId) {&#13;
                min = mid + 1;&#13;
            } else {&#13;
                max = mid;&#13;
            }&#13;
        }&#13;
        return _checkpoints[max].value;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Stores the changes to the checkpoint objects&#13;
     * @param _checkpoints is the affected checkpoint object array&#13;
     * @param _newValue is the new value that needs to be stored&#13;
     */&#13;
    function adjustCheckpoints(TokenLib.Checkpoint[] storage _checkpoints, uint256 _newValue, uint256 _currentCheckpointId) public {&#13;
        //No checkpoints set yet&#13;
        if (_currentCheckpointId == 0) {&#13;
            return;&#13;
        }&#13;
        //No new checkpoints since last update&#13;
        if ((_checkpoints.length &gt; 0) &amp;&amp; (_checkpoints[_checkpoints.length - 1].checkpointId == _currentCheckpointId)) {&#13;
            return;&#13;
        }&#13;
        //New checkpoint, so record balance&#13;
        _checkpoints.push(&#13;
            TokenLib.Checkpoint({&#13;
                checkpointId: _currentCheckpointId,&#13;
                value: _newValue&#13;
            })&#13;
        );&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Keeps track of the number of non-zero token holders&#13;
    * @param _investorData Date releated to investor metrics&#13;
    * @param _from Sender of transfer&#13;
    * @param _to Receiver of transfer&#13;
    * @param _value Value of transfer&#13;
    * @param _balanceTo Balance of the _to address&#13;
    * @param _balanceFrom Balance of the _from address&#13;
    */&#13;
    function adjustInvestorCount(&#13;
        InvestorDataStorage storage _investorData,&#13;
        address _from,&#13;
        address _to,&#13;
        uint256 _value,&#13;
        uint256 _balanceTo,&#13;
        uint256 _balanceFrom&#13;
        ) public  {&#13;
        if ((_value == 0) || (_from == _to)) {&#13;
            return;&#13;
        }&#13;
        // Check whether receiver is a new token holder&#13;
        if ((_balanceTo == 0) &amp;&amp; (_to != address(0))) {&#13;
            _investorData.investorCount = (_investorData.investorCount).add(1);&#13;
        }&#13;
        // Check whether sender is moving all of their tokens&#13;
        if (_value == _balanceFrom) {&#13;
            _investorData.investorCount = (_investorData.investorCount).sub(1);&#13;
        }&#13;
        //Also adjust investor list&#13;
        if (!_investorData.investorListed[_to] &amp;&amp; (_to != address(0))) {&#13;
            _investorData.investors.push(_to);&#13;
            _investorData.investorListed[_to] = true;&#13;
        }&#13;
&#13;
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
* @notice - ST does not inherit from ISecurityToken due to:&#13;
* @notice - https://github.com/ethereum/solidity/issues/4847&#13;
*/&#13;
contract SecurityToken is StandardToken, DetailedERC20, ReentrancyGuard, RegistryUpdater {&#13;
    using SafeMath for uint256;&#13;
&#13;
    TokenLib.InvestorDataStorage investorData;&#13;
&#13;
    // Used to hold the semantic version data&#13;
    struct SemanticVersion {&#13;
        uint8 major;&#13;
        uint8 minor;&#13;
        uint8 patch;&#13;
    }&#13;
&#13;
    SemanticVersion securityTokenVersion;&#13;
&#13;
    // off-chain data&#13;
    string public tokenDetails;&#13;
&#13;
    uint8 constant PERMISSION_KEY = 1;&#13;
    uint8 constant TRANSFER_KEY = 2;&#13;
    uint8 constant MINT_KEY = 3;&#13;
    uint8 constant CHECKPOINT_KEY = 4;&#13;
    uint8 constant BURN_KEY = 5;&#13;
&#13;
    uint256 public granularity;&#13;
&#13;
    // Value of current checkpoint&#13;
    uint256 public currentCheckpointId;&#13;
&#13;
    // Used to temporarily halt all transactions&#13;
    bool public transfersFrozen;&#13;
&#13;
    // Used to permanently halt all minting&#13;
    bool public mintingFrozen;&#13;
&#13;
    // Used to permanently halt controller actions&#13;
    bool public controllerDisabled;&#13;
&#13;
    // Address whitelisted by issuer as controller&#13;
    address public controller;&#13;
&#13;
    // Records added modules - module list should be order agnostic!&#13;
    mapping (uint8 =&gt; address[]) modules;&#13;
&#13;
    // Records information about the module&#13;
    mapping (address =&gt; TokenLib.ModuleData) modulesToData;&#13;
&#13;
    // Records added module names - module list should be order agnostic!&#13;
    mapping (bytes32 =&gt; address[]) names;&#13;
&#13;
    // Map each investor to a series of checkpoints&#13;
    mapping (address =&gt; TokenLib.Checkpoint[]) checkpointBalances;&#13;
&#13;
    // List of checkpoints that relate to total supply&#13;
    TokenLib.Checkpoint[] checkpointTotalSupply;&#13;
&#13;
    // Times at which each checkpoint was created&#13;
    uint256[] checkpointTimes;&#13;
&#13;
    // Emit at the time when module get added&#13;
    event ModuleAdded(&#13;
        uint8[] _types,&#13;
        bytes32 _name,&#13;
        address _moduleFactory,&#13;
        address _module,&#13;
        uint256 _moduleCost,&#13;
        uint256 _budget,&#13;
        uint256 _timestamp&#13;
    );&#13;
&#13;
    // Emit when the token details get updated&#13;
    event UpdateTokenDetails(string _oldDetails, string _newDetails);&#13;
    // Emit when the granularity get changed&#13;
    event GranularityChanged(uint256 _oldGranularity, uint256 _newGranularity);&#13;
    // Emit when Module get archived from the securityToken&#13;
    event ModuleArchived(uint8[] _types, address _module, uint256 _timestamp);&#13;
    // Emit when Module get unarchived from the securityToken&#13;
    event ModuleUnarchived(uint8[] _types, address _module, uint256 _timestamp);&#13;
    // Emit when Module get removed from the securityToken&#13;
    event ModuleRemoved(uint8[] _types, address _module, uint256 _timestamp);&#13;
    // Emit when the budget allocated to a module is changed&#13;
    event ModuleBudgetChanged(uint8[] _moduleTypes, address _module, uint256 _oldBudget, uint256 _budget);&#13;
    // Emit when transfers are frozen or unfrozen&#13;
    event FreezeTransfers(bool _status, uint256 _timestamp);&#13;
    // Emit when new checkpoint created&#13;
    event CheckpointCreated(uint256 indexed _checkpointId, uint256 _timestamp);&#13;
    // Emit when is permanently frozen by the issuer&#13;
    event FreezeMinting(uint256 _timestamp);&#13;
    // Events to log minting and burning&#13;
    event Minted(address indexed _to, uint256 _value);&#13;
    event Burnt(address indexed _from, uint256 _value);&#13;
&#13;
    // Events to log controller actions&#13;
    event SetController(address indexed _oldController, address indexed _newController);&#13;
    event ForceTransfer(&#13;
        address indexed _controller,&#13;
        address indexed _from,&#13;
        address indexed _to,&#13;
        uint256 _value,&#13;
        bool _verifyTransfer,&#13;
        bytes _data&#13;
    );&#13;
    event ForceBurn(&#13;
        address indexed _controller,&#13;
        address indexed _from,&#13;
        uint256 _value,&#13;
        bool _verifyTransfer,&#13;
        bytes _data&#13;
    );&#13;
    event DisableController(uint256 _timestamp);&#13;
&#13;
    function _isModule(address _module, uint8 _type) internal view returns (bool) {&#13;
        require(modulesToData[_module].module == _module, "Wrong address");&#13;
        require(!modulesToData[_module].isArchived, "Module archived");&#13;
        for (uint256 i = 0; i &lt; modulesToData[_module].moduleTypes.length; i++) {&#13;
            if (modulesToData[_module].moduleTypes[i] == _type) {&#13;
                return true;&#13;
            }&#13;
        }&#13;
        return false;&#13;
    }&#13;
&#13;
    // Require msg.sender to be the specified module type&#13;
    modifier onlyModule(uint8 _type) {&#13;
        require(_isModule(msg.sender, _type));&#13;
        _;&#13;
    }&#13;
&#13;
    // Require msg.sender to be the specified module type or the owner of the token&#13;
    modifier onlyModuleOrOwner(uint8 _type) {&#13;
        if (msg.sender == owner) {&#13;
            _;&#13;
        } else {&#13;
            require(_isModule(msg.sender, _type));&#13;
            _;&#13;
        }&#13;
    }&#13;
&#13;
    modifier checkGranularity(uint256 _value) {&#13;
        require(_value % granularity == 0, "Invalid granularity");&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isMintingAllowed() {&#13;
        require(!mintingFrozen, "Minting frozen");&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isEnabled(string _nameKey) {&#13;
        require(IFeatureRegistry(featureRegistry).getFeatureStatus(_nameKey));&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Revert if called by an account which is not a controller&#13;
     */&#13;
    modifier onlyController() {&#13;
        require(msg.sender == controller, "Not controller");&#13;
        require(!controllerDisabled, "Controller disabled");&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Constructor&#13;
     * @param _name Name of the SecurityToken&#13;
     * @param _symbol Symbol of the Token&#13;
     * @param _decimals Decimals for the securityToken&#13;
     * @param _granularity granular level of the token&#13;
     * @param _tokenDetails Details of the token that are stored off-chain&#13;
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
        securityTokenVersion = SemanticVersion(2,0,0);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Attachs a module to the SecurityToken&#13;
     * @dev  E.G.: On deployment (through the STR) ST gets a TransferManager module attached to it&#13;
     * @dev to control restrictions on transfers.&#13;
     * @param _moduleFactory is the address of the module factory to be added&#13;
     * @param _data is data packed into bytes used to further configure the module (See STO usage)&#13;
     * @param _maxCost max amount of POLY willing to pay to the module.&#13;
     * @param _budget max amount of ongoing POLY willing to assign to the module.&#13;
     */&#13;
    function addModule(&#13;
        address _moduleFactory,&#13;
        bytes _data,&#13;
        uint256 _maxCost,&#13;
        uint256 _budget&#13;
    ) external onlyOwner nonReentrant {&#13;
        //Check that the module factory exists in the ModuleRegistry - will throw otherwise&#13;
        IModuleRegistry(moduleRegistry).useModule(_moduleFactory);&#13;
        IModuleFactory moduleFactory = IModuleFactory(_moduleFactory);&#13;
        uint8[] memory moduleTypes = moduleFactory.getTypes();&#13;
        uint256 moduleCost = moduleFactory.getSetupCost();&#13;
        require(moduleCost &lt;= _maxCost, "Invalid cost");&#13;
        //Approve fee for module&#13;
        ERC20(polyToken).approve(_moduleFactory, moduleCost);&#13;
        //Creates instance of module from factory&#13;
        address module = moduleFactory.deploy(_data);&#13;
        require(modulesToData[module].module == address(0), "Module exists");&#13;
        //Approve ongoing budget&#13;
        ERC20(polyToken).approve(module, _budget);&#13;
        //Add to SecurityToken module map&#13;
        bytes32 moduleName = moduleFactory.getName();&#13;
        uint256[] memory moduleIndexes = new uint256[](moduleTypes.length);&#13;
        uint256 i;&#13;
        for (i = 0; i &lt; moduleTypes.length; i++) {&#13;
            moduleIndexes[i] = modules[moduleTypes[i]].length;&#13;
            modules[moduleTypes[i]].push(module);&#13;
        }&#13;
        modulesToData[module] = TokenLib.ModuleData(&#13;
            moduleName, module, _moduleFactory, false, moduleTypes, moduleIndexes, names[moduleName].length&#13;
        );&#13;
        names[moduleName].push(module);&#13;
        //Emit log event&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        emit ModuleAdded(moduleTypes, moduleName, _moduleFactory, module, moduleCost, _budget, now);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Archives a module attached to the SecurityToken&#13;
    * @param _module address of module to archive&#13;
    */&#13;
    function archiveModule(address _module) external onlyOwner {&#13;
        TokenLib.archiveModule(modulesToData[_module], _module);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Unarchives a module attached to the SecurityToken&#13;
    * @param _module address of module to unarchive&#13;
    */&#13;
    function unarchiveModule(address _module) external onlyOwner {&#13;
        TokenLib.unarchiveModule(modulesToData[_module], _module);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Removes a module attached to the SecurityToken&#13;
    * @param _module address of module to unarchive&#13;
    */&#13;
    function removeModule(address _module) external onlyOwner {&#13;
        require(modulesToData[_module].isArchived, "Not archived");&#13;
        require(modulesToData[_module].module != address(0), "Module missing");&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        emit ModuleRemoved(modulesToData[_module].moduleTypes, _module, now);&#13;
        // Remove from module type list&#13;
        uint8[] memory moduleTypes = modulesToData[_module].moduleTypes;&#13;
        for (uint256 i = 0; i &lt; moduleTypes.length; i++) {&#13;
            _removeModuleWithIndex(moduleTypes[i], modulesToData[_module].moduleIndexes[i]);&#13;
            /* modulesToData[_module].moduleType[moduleTypes[i]] = false; */&#13;
        }&#13;
        // Remove from module names list&#13;
        uint256 index = modulesToData[_module].nameIndex;&#13;
        bytes32 name = modulesToData[_module].name;&#13;
        uint256 length = names[name].length;&#13;
        names[name][index] = names[name][length - 1];&#13;
        names[name].length = length - 1;&#13;
        if ((length - 1) != index) {&#13;
            modulesToData[names[name][index]].nameIndex = index;&#13;
        }&#13;
        // Remove from modulesToData&#13;
        delete modulesToData[_module];&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Internal - Removes a module attached to the SecurityToken by index&#13;
    */&#13;
    function _removeModuleWithIndex(uint8 _type, uint256 _index) internal {&#13;
        uint256 length = modules[_type].length;&#13;
        modules[_type][_index] = modules[_type][length - 1];&#13;
        modules[_type].length = length - 1;&#13;
&#13;
        if ((length - 1) != _index) {&#13;
            //Need to find index of _type in moduleTypes of module we are moving&#13;
            uint8[] memory newTypes = modulesToData[modules[_type][_index]].moduleTypes;&#13;
            for (uint256 i = 0; i &lt; newTypes.length; i++) {&#13;
                if (newTypes[i] == _type) {&#13;
                    modulesToData[modules[_type][_index]].moduleIndexes[i] = _index;&#13;
                }&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Returns the data associated to a module&#13;
     * @param _module address of the module&#13;
     * @return bytes32 name&#13;
     * @return address module address&#13;
     * @return address module factory address&#13;
     * @return bool module archived&#13;
     * @return uint8 module type&#13;
     */&#13;
    function getModule(address _module) external view returns (bytes32, address, address, bool, uint8[]) {&#13;
        return (modulesToData[_module].name,&#13;
        modulesToData[_module].module,&#13;
        modulesToData[_module].moduleFactory,&#13;
        modulesToData[_module].isArchived,&#13;
        modulesToData[_module].moduleTypes);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Returns a list of modules that match the provided name&#13;
     * @param _name name of the module&#13;
     * @return address[] list of modules with this name&#13;
     */&#13;
    function getModulesByName(bytes32 _name) external view returns (address[]) {&#13;
        return names[_name];&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Returns a list of modules that match the provided module type&#13;
     * @param _type type of the module&#13;
     * @return address[] list of modules with this type&#13;
     */&#13;
    function getModulesByType(uint8 _type) external view returns (address[]) {&#13;
        return modules[_type];&#13;
    }&#13;
&#13;
   /**&#13;
    * @notice Allows the owner to withdraw unspent POLY stored by them on the ST or any ERC20 token.&#13;
    * @dev Owner can transfer POLY to the ST which will be used to pay for modules that require a POLY fee.&#13;
    * @param _tokenContract Address of the ERC20Basic compliance token&#13;
    * @param _value amount of POLY to withdraw&#13;
    */&#13;
    function withdrawERC20(address _tokenContract, uint256 _value) external onlyOwner {&#13;
        require(_tokenContract != address(0));&#13;
        IERC20 token = IERC20(_tokenContract);&#13;
        require(token.transfer(owner, _value));&#13;
    }&#13;
&#13;
    /**&#13;
&#13;
    * @notice allows owner to increase/decrease POLY approval of one of the modules&#13;
    * @param _module module address&#13;
    * @param _change change in allowance&#13;
    * @param _increase true if budget has to be increased, false if decrease&#13;
    */&#13;
    function changeModuleBudget(address _module, uint256 _change, bool _increase) external onlyOwner {&#13;
        require(modulesToData[_module].module != address(0), "Module missing");&#13;
        uint256 currentAllowance = IERC20(polyToken).allowance(address(this), _module);&#13;
        uint256 newAllowance;&#13;
        if (_increase) {&#13;
            require(IERC20(polyToken).increaseApproval(_module, _change), "IncreaseApproval fail");&#13;
            newAllowance = currentAllowance.add(_change);&#13;
        } else {&#13;
            require(IERC20(polyToken).decreaseApproval(_module, _change), "Insufficient allowance");&#13;
            newAllowance = currentAllowance.sub(_change);&#13;
        }&#13;
        emit ModuleBudgetChanged(modulesToData[_module].moduleTypes, _module, currentAllowance, newAllowance);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice updates the tokenDetails associated with the token&#13;
     * @param _newTokenDetails New token details&#13;
     */&#13;
    function updateTokenDetails(string _newTokenDetails) external onlyOwner {&#13;
        emit UpdateTokenDetails(tokenDetails, _newTokenDetails);&#13;
        tokenDetails = _newTokenDetails;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Allows owner to change token granularity&#13;
    * @param _granularity granularity level of the token&#13;
    */&#13;
    function changeGranularity(uint256 _granularity) external onlyOwner {&#13;
        require(_granularity != 0, "Invalid granularity");&#13;
        emit GranularityChanged(granularity, _granularity);&#13;
        granularity = _granularity;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Keeps track of the number of non-zero token holders&#13;
    * @param _from sender of transfer&#13;
    * @param _to receiver of transfer&#13;
    * @param _value value of transfer&#13;
    */&#13;
    function _adjustInvestorCount(address _from, address _to, uint256 _value) internal {&#13;
        TokenLib.adjustInvestorCount(investorData, _from, _to, _value, balanceOf(_to), balanceOf(_from));&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice returns an array of investors&#13;
     * NB - this length may differ from investorCount as it contains all investors that ever held tokens&#13;
     * @return list of addresses&#13;
     */&#13;
    function getInvestors() external view returns(address[]) {&#13;
        return investorData.investors;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice returns an array of investors at a given checkpoint&#13;
     * NB - this length may differ from investorCount as it contains all investors that ever held tokens&#13;
     * @param _checkpointId Checkpoint id at which investor list is to be populated&#13;
     * @return list of investors&#13;
     */&#13;
    function getInvestorsAt(uint256 _checkpointId) external view returns(address[]) {&#13;
        uint256 count = 0;&#13;
        uint256 i;&#13;
        for (i = 0; i &lt; investorData.investors.length; i++) {&#13;
            if (balanceOfAt(investorData.investors[i], _checkpointId) &gt; 0) {&#13;
                count++;&#13;
            }&#13;
        }&#13;
        address[] memory investors = new address[](count);&#13;
        count = 0;&#13;
        for (i = 0; i &lt; investorData.investors.length; i++) {&#13;
            if (balanceOfAt(investorData.investors[i], _checkpointId) &gt; 0) {&#13;
                investors[count] = investorData.investors[i];&#13;
                count++;&#13;
            }&#13;
        }&#13;
        return investors;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice generates subset of investors&#13;
     * NB - can be used in batches if investor list is large&#13;
     * @param _start Position of investor to start iteration from&#13;
     * @param _end Position of investor to stop iteration at&#13;
     * @return list of investors&#13;
     */&#13;
    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[]) {&#13;
        require(_end &lt;= investorData.investors.length, "Invalid end");&#13;
        address[] memory investors = new address[](_end.sub(_start));&#13;
        uint256 index = 0;&#13;
        for (uint256 i = _start; i &lt; _end; i++) {&#13;
            investors[index] = investorData.investors[i];&#13;
            index++;&#13;
        }&#13;
        return investors;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Returns the investor count&#13;
     * @return Investor count&#13;
     */&#13;
    function getInvestorCount() external view returns(uint256) {&#13;
        return investorData.investorCount;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice freezes transfers&#13;
     */&#13;
    function freezeTransfers() external onlyOwner {&#13;
        require(!transfersFrozen, "Already frozen");&#13;
        transfersFrozen = true;&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        emit FreezeTransfers(true, now);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Unfreeze transfers&#13;
     */&#13;
    function unfreezeTransfers() external onlyOwner {&#13;
        require(transfersFrozen, "Not frozen");&#13;
        transfersFrozen = false;&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        emit FreezeTransfers(false, now);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Internal - adjusts totalSupply at checkpoint after minting or burning tokens&#13;
     */&#13;
    function _adjustTotalSupplyCheckpoints() internal {&#13;
        TokenLib.adjustCheckpoints(checkpointTotalSupply, totalSupply(), currentCheckpointId);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Internal - adjusts token holder balance at checkpoint after a token transfer&#13;
     * @param _investor address of the token holder affected&#13;
     */&#13;
    function _adjustBalanceCheckpoints(address _investor) internal {&#13;
        TokenLib.adjustCheckpoints(checkpointBalances[_investor], balanceOf(_investor), currentCheckpointId);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Overloaded version of the transfer function&#13;
     * @param _to receiver of transfer&#13;
     * @param _value value of transfer&#13;
     * @return bool success&#13;
     */&#13;
    function transfer(address _to, uint256 _value) public returns (bool success) {&#13;
        return transferWithData(_to, _value, "");&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Overloaded version of the transfer function&#13;
     * @param _to receiver of transfer&#13;
     * @param _value value of transfer&#13;
     * @param _data data to indicate validation&#13;
     * @return bool success&#13;
     */&#13;
    function transferWithData(address _to, uint256 _value, bytes _data) public returns (bool success) {&#13;
        require(_updateTransfer(msg.sender, _to, _value, _data), "Transfer invalid");&#13;
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
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {&#13;
        return transferFromWithData(_from, _to, _value, "");&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Overloaded version of the transferFrom function&#13;
     * @param _from sender of transfer&#13;
     * @param _to receiver of transfer&#13;
     * @param _value value of transfer&#13;
     * @param _data data to indicate validation&#13;
     * @return bool success&#13;
     */&#13;
    function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) public returns(bool) {&#13;
        require(_updateTransfer(_from, _to, _value, _data), "Transfer invalid");&#13;
        require(super.transferFrom(_from, _to, _value));&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Updates internal variables when performing a transfer&#13;
     * @param _from sender of transfer&#13;
     * @param _to receiver of transfer&#13;
     * @param _value value of transfer&#13;
     * @param _data data to indicate validation&#13;
     * @return bool success&#13;
     */&#13;
    function _updateTransfer(address _from, address _to, uint256 _value, bytes _data) internal nonReentrant returns(bool) {&#13;
        // NB - the ordering in this function implies the following:&#13;
        //  - investor counts are updated before transfer managers are called - i.e. transfer managers will see&#13;
        //investor counts including the current transfer.&#13;
        //  - checkpoints are updated after the transfer managers are called. This allows TMs to create&#13;
        //checkpoints as though they have been created before the current transactions,&#13;
        //  - to avoid the situation where a transfer manager transfers tokens, and this function is called recursively,&#13;
        //the function is marked as nonReentrant. This means that no TM can transfer (or mint / burn) tokens.&#13;
        _adjustInvestorCount(_from, _to, _value);&#13;
        bool verified = _verifyTransfer(_from, _to, _value, _data, true);&#13;
        _adjustBalanceCheckpoints(_from);&#13;
        _adjustBalanceCheckpoints(_to);&#13;
        return verified;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Validate transfer with TransferManager module if it exists&#13;
     * @dev TransferManager module has a key of 2&#13;
     * @dev _isTransfer boolean flag is the deciding factor for whether the&#13;
     * state variables gets modified or not within the different modules. i.e isTransfer = true&#13;
     * leads to change in the modules environment otherwise _verifyTransfer() works as a read-only&#13;
     * function (no change in the state).&#13;
     * @param _from sender of transfer&#13;
     * @param _to receiver of transfer&#13;
     * @param _value value of transfer&#13;
     * @param _data data to indicate validation&#13;
     * @param _isTransfer whether transfer is being executed&#13;
     * @return bool&#13;
     */&#13;
    function _verifyTransfer(&#13;
        address _from,&#13;
        address _to,&#13;
        uint256 _value,&#13;
        bytes _data,&#13;
        bool _isTransfer&#13;
    ) internal checkGranularity(_value) returns (bool) {&#13;
        if (!transfersFrozen) {&#13;
            bool isInvalid = false;&#13;
            bool isValid = false;&#13;
            bool isForceValid = false;&#13;
            bool unarchived = false;&#13;
            address module;&#13;
            for (uint256 i = 0; i &lt; modules[TRANSFER_KEY].length; i++) {&#13;
                module = modules[TRANSFER_KEY][i];&#13;
                if (!modulesToData[module].isArchived) {&#13;
                    unarchived = true;&#13;
                    ITransferManager.Result valid = ITransferManager(module).verifyTransfer(_from, _to, _value, _data, _isTransfer);&#13;
                    if (valid == ITransferManager.Result.INVALID) {&#13;
                        isInvalid = true;&#13;
                    } else if (valid == ITransferManager.Result.VALID) {&#13;
                        isValid = true;&#13;
                    } else if (valid == ITransferManager.Result.FORCE_VALID) {&#13;
                        isForceValid = true;&#13;
                    }&#13;
                }&#13;
            }&#13;
            // If no unarchived modules, return true by default&#13;
            return unarchived ? (isForceValid ? true : (isInvalid ? false : isValid)) : true;&#13;
        }&#13;
        return false;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Validates a transfer with a TransferManager module if it exists&#13;
     * @dev TransferManager module has a key of 2&#13;
     * @param _from sender of transfer&#13;
     * @param _to receiver of transfer&#13;
     * @param _value value of transfer&#13;
     * @param _data data to indicate validation&#13;
     * @return bool&#13;
     */&#13;
    function verifyTransfer(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {&#13;
        return _verifyTransfer(_from, _to, _value, _data, false);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Permanently freeze minting of this security token.&#13;
     * @dev It MUST NOT be possible to increase `totalSuppy` after this function is called.&#13;
     */&#13;
    function freezeMinting() external isMintingAllowed() isEnabled("freezeMintingAllowed") onlyOwner {&#13;
        mintingFrozen = true;&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        emit FreezeMinting(now);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Mints new tokens and assigns them to the target _investor.&#13;
     * @dev Can only be called by the issuer or STO attached to the token&#13;
     * @param _investor Address where the minted tokens will be delivered&#13;
     * @param _value Number of tokens be minted&#13;
     * @return success&#13;
     */&#13;
    function mint(address _investor, uint256 _value) public returns (bool success) {&#13;
        return mintWithData(_investor, _value, "");&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice mints new tokens and assigns them to the target _investor.&#13;
     * @dev Can only be called by the issuer or STO attached to the token&#13;
     * @param _investor Address where the minted tokens will be delivered&#13;
     * @param _value Number of tokens be minted&#13;
     * @param _data data to indicate validation&#13;
     * @return success&#13;
     */&#13;
    function mintWithData(&#13;
        address _investor,&#13;
        uint256 _value,&#13;
        bytes _data&#13;
        ) public onlyModuleOrOwner(MINT_KEY) isMintingAllowed() returns (bool success) {&#13;
        require(_investor != address(0), "Investor is 0");&#13;
        require(_updateTransfer(address(0), _investor, _value, _data), "Transfer invalid");&#13;
        _adjustTotalSupplyCheckpoints();&#13;
        totalSupply_ = totalSupply_.add(_value);&#13;
        balances[_investor] = balances[_investor].add(_value);&#13;
        emit Minted(_investor, _value);&#13;
        emit Transfer(address(0), _investor, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Mints new tokens and assigns them to the target _investor.&#13;
     * @dev Can only be called by the issuer or STO attached to the token.&#13;
     * @param _investors A list of addresses to whom the minted tokens will be dilivered&#13;
     * @param _values A list of number of tokens get minted and transfer to corresponding address of the investor from _investor[] list&#13;
     * @return success&#13;
     */&#13;
    function mintMulti(address[] _investors, uint256[] _values) external returns (bool success) {&#13;
        require(_investors.length == _values.length, "Incorrect inputs");&#13;
        for (uint256 i = 0; i &lt; _investors.length; i++) {&#13;
            mint(_investors[i], _values[i]);&#13;
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
        for (uint256 i = 0; i &lt; modules[PERMISSION_KEY].length; i++) {&#13;
            if (!modulesToData[modules[PERMISSION_KEY][i]].isArchived)&#13;
                return TokenLib.checkPermission(modules[PERMISSION_KEY], _delegate, _module, _perm);&#13;
        }&#13;
        return false;&#13;
    }&#13;
&#13;
    function _burn(address _from, uint256 _value, bytes _data) internal returns(bool) {&#13;
        require(_value &lt;= balances[_from], "Value too high");&#13;
        bool verified = _updateTransfer(_from, address(0), _value, _data);&#13;
        _adjustTotalSupplyCheckpoints();&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        totalSupply_ = totalSupply_.sub(_value);&#13;
        emit Burnt(_from, _value);&#13;
        emit Transfer(_from, address(0), _value);&#13;
        return verified;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Burn function used to burn the securityToken&#13;
     * @param _value No. of tokens that get burned&#13;
     * @param _data data to indicate validation&#13;
     */&#13;
    function burnWithData(uint256 _value, bytes _data) public onlyModule(BURN_KEY) {&#13;
        require(_burn(msg.sender, _value, _data), "Burn invalid");&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Burn function used to burn the securityToken on behalf of someone else&#13;
     * @param _from Address for whom to burn tokens&#13;
     * @param _value No. of tokens that get burned&#13;
     * @param _data data to indicate validation&#13;
     */&#13;
    function burnFromWithData(address _from, uint256 _value, bytes _data) public onlyModule(BURN_KEY) {&#13;
        require(_value &lt;= allowed[_from][msg.sender], "Value too high");&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
        require(_burn(_from, _value, _data), "Burn invalid");&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Creates a checkpoint that can be used to query historical balances / totalSuppy&#13;
     * @return uint256&#13;
     */&#13;
    function createCheckpoint() external onlyModuleOrOwner(CHECKPOINT_KEY) returns(uint256) {&#13;
        require(currentCheckpointId &lt; 2**256 - 1);&#13;
        currentCheckpointId = currentCheckpointId + 1;&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        checkpointTimes.push(now);&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        emit CheckpointCreated(currentCheckpointId, now);&#13;
        return currentCheckpointId;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Gets list of times that checkpoints were created&#13;
     * @return List of checkpoint times&#13;
     */&#13;
    function getCheckpointTimes() external view returns(uint256[]) {&#13;
        return checkpointTimes;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Queries totalSupply as of a defined checkpoint&#13;
     * @param _checkpointId Checkpoint ID to query&#13;
     * @return uint256&#13;
     */&#13;
    function totalSupplyAt(uint256 _checkpointId) external view returns(uint256) {&#13;
        require(_checkpointId &lt;= currentCheckpointId);&#13;
        return TokenLib.getValueAt(checkpointTotalSupply, _checkpointId, totalSupply());&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Queries balances as of a defined checkpoint&#13;
     * @param _investor Investor to query balance for&#13;
     * @param _checkpointId Checkpoint ID to query as of&#13;
     */&#13;
    function balanceOfAt(address _investor, uint256 _checkpointId) public view returns(uint256) {&#13;
        require(_checkpointId &lt;= currentCheckpointId);&#13;
        return TokenLib.getValueAt(checkpointBalances[_investor], _checkpointId, balanceOf(_investor));&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Used by the issuer to set the controller addresses&#13;
     * @param _controller address of the controller&#13;
     */&#13;
    function setController(address _controller) public onlyOwner {&#13;
        require(!controllerDisabled);&#13;
        emit SetController(controller, _controller);&#13;
        controller = _controller;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Used by the issuer to permanently disable controller functionality&#13;
     * @dev enabled via feature switch "disableControllerAllowed"&#13;
     */&#13;
    function disableController() external isEnabled("disableControllerAllowed") onlyOwner {&#13;
        require(!controllerDisabled);&#13;
        controllerDisabled = true;&#13;
        delete controller;&#13;
        /*solium-disable-next-line security/no-block-members*/&#13;
        emit DisableController(now);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Used by a controller to execute a forced transfer&#13;
     * @param _from address from which to take tokens&#13;
     * @param _to address where to send tokens&#13;
     * @param _value amount of tokens to transfer&#13;
     * @param _data data to indicate validation&#13;
     * @param _log data attached to the transfer by controller to emit in event&#13;
     */&#13;
    function forceTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _log) public onlyController {&#13;
        require(_to != address(0));&#13;
        require(_value &lt;= balances[_from]);&#13;
        bool verified = _updateTransfer(_from, _to, _value, _data);&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        emit ForceTransfer(msg.sender, _from, _to, _value, verified, _log);&#13;
        emit Transfer(_from, _to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Used by a controller to execute a forced burn&#13;
     * @param _from address from which to take tokens&#13;
     * @param _value amount of tokens to transfer&#13;
     * @param _data data to indicate validation&#13;
     * @param _log data attached to the transfer by controller to emit in event&#13;
     */&#13;
    function forceBurn(address _from, uint256 _value, bytes _data, bytes _log) public onlyController {&#13;
        bool verified = _burn(_from, _value, _data);&#13;
        emit ForceBurn(msg.sender, _from, _value, verified, _log);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Returns the version of the SecurityToken&#13;
     */&#13;
    function getVersion() external view returns(uint8[]) {&#13;
        uint8[] memory _version = new uint8[](3);&#13;
        _version[0] = securityTokenVersion.major;&#13;
        _version[1] = securityTokenVersion.minor;&#13;
        _version[2] = securityTokenVersion.patch;&#13;
        return _version;&#13;
    }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Interface for security token proxy deployment&#13;
 */&#13;
interface ISTFactory {&#13;
&#13;
    /**&#13;
     * @notice Deploys the token and adds default modules like permission manager and transfer manager.&#13;
     * Future versions of the proxy can attach different modules or pass some other paramters.&#13;
     * @param _name is the name of the Security token&#13;
     * @param _symbol is the symbol of the Security Token&#13;
     * @param _decimals is the number of decimals of the Security Token&#13;
     * @param _tokenDetails is the off-chain data associated with the Security Token&#13;
     * @param _issuer is the owner of the Security Token&#13;
     * @param _divisible whether the token is divisible or not&#13;
     * @param _polymathRegistry is the address of the Polymath Registry contract&#13;
     */&#13;
    function deployToken(&#13;
        string _name,&#13;
        string _symbol,&#13;
        uint8 _decimals,&#13;
        string _tokenDetails,&#13;
        address _issuer,&#13;
        bool _divisible,&#13;
        address _polymathRegistry&#13;
    )&#13;
        external&#13;
        returns (address);&#13;
}&#13;
&#13;
/**&#13;
 * @title Proxy for deploying SecurityToken instances&#13;
 */&#13;
contract STFactory is ISTFactory {&#13;
&#13;
    address public transferManagerFactory;&#13;
&#13;
    constructor (address _transferManagerFactory) public {&#13;
        transferManagerFactory = _transferManagerFactory;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice deploys the token and adds default modules like the GeneralTransferManager.&#13;
     * Future versions of the proxy can attach different modules or pass different parameters.&#13;
     */&#13;
    function deployToken(&#13;
        string _name,&#13;
        string _symbol,&#13;
        uint8 _decimals,&#13;
        string _tokenDetails,&#13;
        address _issuer,&#13;
        bool _divisible,&#13;
        address _polymathRegistry&#13;
        ) external returns (address) {&#13;
        address newSecurityTokenAddress = new SecurityToken(&#13;
            _name,&#13;
            _symbol,&#13;
            _decimals,&#13;
            _divisible ? 1 : uint256(10)**_decimals,&#13;
            _tokenDetails,&#13;
            _polymathRegistry&#13;
        );&#13;
        SecurityToken(newSecurityTokenAddress).addModule(transferManagerFactory, "", 0, 0);&#13;
        SecurityToken(newSecurityTokenAddress).transferOwnership(_issuer);&#13;
        return newSecurityTokenAddress;&#13;
    }&#13;
}