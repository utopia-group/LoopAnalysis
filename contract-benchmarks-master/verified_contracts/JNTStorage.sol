/* Author: Victor Mezrin  <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b1c7d8d2c5dec3f1dcd4cbc3d8df9fd2dedc">[email protected]</a> */&#13;
&#13;
&#13;
pragma solidity ^0.4.18;&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title SafeMathInterface&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
contract SafeMathInterface {&#13;
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256);&#13;
  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256);&#13;
  function safeSub(uint256 a, uint256 b) internal pure returns (uint256);&#13;
  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256);&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
contract SafeMath is SafeMathInterface {&#13;
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a * b;&#13;
    assert(a == 0 || c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CommonModifiersInterface&#13;
 * @dev Base contract which contains common checks.&#13;
 */&#13;
contract CommonModifiersInterface {&#13;
&#13;
  /**&#13;
   * @dev Assemble the given address bytecode. If bytecode exists then the _addr is a contract.&#13;
   */&#13;
  function isContract(address _targetAddress) internal constant returns (bool);&#13;
&#13;
  /**&#13;
   * @dev modifier to allow actions only when the _targetAddress is a contract.&#13;
   */&#13;
  modifier onlyContractAddress(address _targetAddress) {&#13;
    require(isContract(_targetAddress) == true);&#13;
    _;&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CommonModifiers&#13;
 * @dev Base contract which contains common checks.&#13;
 */&#13;
contract CommonModifiers is CommonModifiersInterface {&#13;
&#13;
  /**&#13;
   * @dev Assemble the given address bytecode. If bytecode exists then the _addr is a contract.&#13;
   */&#13;
  function isContract(address _targetAddress) internal constant returns (bool) {&#13;
    require (_targetAddress != address(0x0));&#13;
&#13;
    uint256 length;&#13;
    assembly {&#13;
      //retrieve the size of the code on target address, this needs assembly&#13;
      length := extcodesize(_targetAddress)&#13;
    }&#13;
    return (length &gt; 0);&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title AssetIDInterface&#13;
 * @dev Interface of a contract that assigned to an asset (JNT, jUSD etc.)&#13;
 * @dev Contracts for the same asset (like JNT, jUSD etc.) will have the same AssetID.&#13;
 * @dev This will help to avoid misconfiguration of contracts&#13;
 */&#13;
contract AssetIDInterface {&#13;
  function getAssetID() public constant returns (string);&#13;
  function getAssetIDHash() public constant returns (bytes32);&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title AssetID&#13;
 * @dev Base contract implementing AssetIDInterface&#13;
 */&#13;
contract AssetID is AssetIDInterface {&#13;
&#13;
  /* Storage */&#13;
&#13;
  string assetID;&#13;
&#13;
&#13;
  /* Constructor */&#13;
&#13;
  function AssetID(string _assetID) public {&#13;
    require(bytes(_assetID).length &gt; 0);&#13;
&#13;
    assetID = _assetID;&#13;
  }&#13;
&#13;
&#13;
  /* Getters */&#13;
&#13;
  function getAssetID() public constant returns (string) {&#13;
    return assetID;&#13;
  }&#13;
&#13;
  function getAssetIDHash() public constant returns (bytes32) {&#13;
    return keccak256(assetID);&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title OwnableInterface&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract OwnableInterface {&#13;
&#13;
  /**&#13;
   * @dev The getter for "owner" contract variable&#13;
   */&#13;
  function getOwner() public constant returns (address);&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the current owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require (msg.sender == getOwner());&#13;
    _;&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Ownable is OwnableInterface {&#13;
&#13;
  /* Storage */&#13;
&#13;
  address owner = address(0x0);&#13;
  address proposedOwner = address(0x0);&#13;
&#13;
&#13;
  /* Events */&#13;
&#13;
  event OwnerAssignedEvent(address indexed newowner);&#13;
  event OwnershipOfferCreatedEvent(address indexed currentowner, address indexed proposedowner);&#13;
  event OwnershipOfferAcceptedEvent(address indexed currentowner, address indexed proposedowner);&#13;
  event OwnershipOfferCancelledEvent(address indexed currentowner, address indexed proposedowner);&#13;
&#13;
&#13;
  /**&#13;
   * @dev The constructor sets the initial `owner` to the passed account.&#13;
   */&#13;
  function Ownable() public {&#13;
    owner = msg.sender;&#13;
&#13;
    OwnerAssignedEvent(owner);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Old owner requests transfer ownership to the new owner.&#13;
   * @param _proposedOwner The address to transfer ownership to.&#13;
   */&#13;
  function createOwnershipOffer(address _proposedOwner) external onlyOwner {&#13;
    require (proposedOwner == address(0x0));&#13;
    require (_proposedOwner != address(0x0));&#13;
    require (_proposedOwner != address(this));&#13;
&#13;
    proposedOwner = _proposedOwner;&#13;
&#13;
    OwnershipOfferCreatedEvent(owner, _proposedOwner);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Allows the new owner to accept an ownership offer to contract control.&#13;
   */&#13;
  //noinspection UnprotectedFunction&#13;
  function acceptOwnershipOffer() external {&#13;
    require (proposedOwner != address(0x0));&#13;
    require (msg.sender == proposedOwner);&#13;
&#13;
    address _oldOwner = owner;&#13;
    owner = proposedOwner;&#13;
    proposedOwner = address(0x0);&#13;
&#13;
    OwnerAssignedEvent(owner);&#13;
    OwnershipOfferAcceptedEvent(_oldOwner, owner);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Old owner cancels transfer ownership to the new owner.&#13;
   */&#13;
  function cancelOwnershipOffer() external {&#13;
    require (proposedOwner != address(0x0));&#13;
    require (msg.sender == owner || msg.sender == proposedOwner);&#13;
&#13;
    address _oldProposedOwner = proposedOwner;&#13;
    proposedOwner = address(0x0);&#13;
&#13;
    OwnershipOfferCancelledEvent(owner, _oldProposedOwner);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev The getter for "owner" contract variable&#13;
   */&#13;
  function getOwner() public constant returns (address) {&#13;
    return owner;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev The getter for "proposedOwner" contract variable&#13;
   */&#13;
  function getProposedOwner() public constant returns (address) {&#13;
    return proposedOwner;&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title ManageableInterface&#13;
 * @dev Contract that allows to grant permissions to any address&#13;
 * @dev In real life we are no able to perform all actions with just one Ethereum address&#13;
 * @dev because risks are too high.&#13;
 * @dev Instead owner delegates rights to manage an contract to the different addresses and&#13;
 * @dev stay able to revoke permissions at any time.&#13;
 */&#13;
contract ManageableInterface {&#13;
&#13;
  /**&#13;
   * @dev Function to check if the manager can perform the action or not&#13;
   * @param _manager        address Manager`s address&#13;
   * @param _permissionName string  Permission name&#13;
   * @return True if manager is enabled and has been granted needed permission&#13;
   */&#13;
  function isManagerAllowed(address _manager, string _permissionName) public constant returns (bool);&#13;
&#13;
  /**&#13;
   * @dev Modifier to use in derived contracts&#13;
   */&#13;
  modifier onlyAllowedManager(string _permissionName) {&#13;
    require(isManagerAllowed(msg.sender, _permissionName) == true);&#13;
    _;&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
contract Manageable is OwnableInterface,&#13;
                       ManageableInterface {&#13;
&#13;
  /* Storage */&#13;
&#13;
  mapping (address =&gt; bool) managerEnabled;  // hard switch for a manager - on/off&#13;
  mapping (address =&gt; mapping (string =&gt; bool)) managerPermissions;  // detailed info about manager`s permissions&#13;
&#13;
&#13;
  /* Events */&#13;
&#13;
  event ManagerEnabledEvent(address indexed manager);&#13;
  event ManagerDisabledEvent(address indexed manager);&#13;
  event ManagerPermissionGrantedEvent(address indexed manager, string permission);&#13;
  event ManagerPermissionRevokedEvent(address indexed manager, string permission);&#13;
&#13;
&#13;
  /* Configure contract */&#13;
&#13;
  /**&#13;
   * @dev Function to add new manager&#13;
   * @param _manager address New manager&#13;
   */&#13;
  function enableManager(address _manager) external onlyOwner onlyValidManagerAddress(_manager) {&#13;
    require(managerEnabled[_manager] == false);&#13;
&#13;
    managerEnabled[_manager] = true;&#13;
    ManagerEnabledEvent(_manager);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to remove existing manager&#13;
   * @param _manager address Existing manager&#13;
   */&#13;
  function disableManager(address _manager) external onlyOwner onlyValidManagerAddress(_manager) {&#13;
    require(managerEnabled[_manager] == true);&#13;
&#13;
    managerEnabled[_manager] = false;&#13;
    ManagerDisabledEvent(_manager);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to grant new permission to the manager&#13;
   * @param _manager        address Existing manager&#13;
   * @param _permissionName string  Granted permission name&#13;
   */&#13;
  function grantManagerPermission(&#13;
    address _manager, string _permissionName&#13;
  )&#13;
    external&#13;
    onlyOwner&#13;
    onlyValidManagerAddress(_manager)&#13;
    onlyValidPermissionName(_permissionName)&#13;
  {&#13;
    require(managerPermissions[_manager][_permissionName] == false);&#13;
&#13;
    managerPermissions[_manager][_permissionName] = true;&#13;
    ManagerPermissionGrantedEvent(_manager, _permissionName);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to revoke permission of the manager&#13;
   * @param _manager        address Existing manager&#13;
   * @param _permissionName string  Revoked permission name&#13;
   */&#13;
  function revokeManagerPermission(&#13;
    address _manager, string _permissionName&#13;
  )&#13;
    external&#13;
    onlyOwner&#13;
    onlyValidManagerAddress(_manager)&#13;
    onlyValidPermissionName(_permissionName)&#13;
  {&#13;
    require(managerPermissions[_manager][_permissionName] == true);&#13;
&#13;
    managerPermissions[_manager][_permissionName] = false;&#13;
    ManagerPermissionRevokedEvent(_manager, _permissionName);&#13;
  }&#13;
&#13;
&#13;
  /* Getters */&#13;
&#13;
  /**&#13;
   * @dev Function to check manager status&#13;
   * @param _manager address Manager`s address&#13;
   * @return True if manager is enabled&#13;
   */&#13;
  function isManagerEnabled(&#13;
    address _manager&#13;
  )&#13;
    public&#13;
    constant&#13;
    onlyValidManagerAddress(_manager)&#13;
    returns (bool)&#13;
  {&#13;
    return managerEnabled[_manager];&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check permissions of a manager&#13;
   * @param _manager        address Manager`s address&#13;
   * @param _permissionName string  Permission name&#13;
   * @return True if manager has been granted needed permission&#13;
   */&#13;
  function isPermissionGranted(&#13;
    address _manager, string _permissionName&#13;
  )&#13;
    public&#13;
    constant&#13;
    onlyValidManagerAddress(_manager)&#13;
    onlyValidPermissionName(_permissionName)&#13;
    returns (bool)&#13;
  {&#13;
    return managerPermissions[_manager][_permissionName];&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check if the manager can perform the action or not&#13;
   * @param _manager        address Manager`s address&#13;
   * @param _permissionName string  Permission name&#13;
   * @return True if manager is enabled and has been granted needed permission&#13;
   */&#13;
  function isManagerAllowed(&#13;
    address _manager, string _permissionName&#13;
  )&#13;
    public&#13;
    constant&#13;
    onlyValidManagerAddress(_manager)&#13;
    onlyValidPermissionName(_permissionName)&#13;
    returns (bool)&#13;
  {&#13;
    return (managerEnabled[_manager] &amp;&amp; managerPermissions[_manager][_permissionName]);&#13;
  }&#13;
&#13;
&#13;
  /* Helpers */&#13;
&#13;
  /**&#13;
   * @dev Modifier to check manager address&#13;
   */&#13;
  modifier onlyValidManagerAddress(address _manager) {&#13;
    require(_manager != address(0x0));&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Modifier to check name of manager permission&#13;
   */&#13;
  modifier onlyValidPermissionName(string _permissionName) {&#13;
    require(bytes(_permissionName).length != 0);&#13;
    _;&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title PausableInterface&#13;
 * @dev Base contract which allows children to implement an emergency stop mechanism.&#13;
 * @dev Based on zeppelin's Pausable, but integrated with Manageable&#13;
 * @dev Contract is in paused state by default and should be explicitly unlocked&#13;
 */&#13;
contract PausableInterface {&#13;
&#13;
  /**&#13;
   * Events&#13;
   */&#13;
&#13;
  event PauseEvent();&#13;
  event UnpauseEvent();&#13;
&#13;
&#13;
  /**&#13;
   * @dev called by the manager to pause, triggers stopped state&#13;
   */&#13;
  function pauseContract() public;&#13;
&#13;
  /**&#13;
   * @dev called by the manager to unpause, returns to normal state&#13;
   */&#13;
  function unpauseContract() public;&#13;
&#13;
  /**&#13;
   * @dev The getter for "paused" contract variable&#13;
   */&#13;
  function getPaused() public constant returns (bool);&#13;
&#13;
&#13;
  /**&#13;
   * @dev modifier to allow actions only when the contract IS paused&#13;
   */&#13;
  modifier whenContractNotPaused() {&#13;
    require(getPaused() == false);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev modifier to allow actions only when the contract IS NOT paused&#13;
   */&#13;
  modifier whenContractPaused {&#13;
    require(getPaused() == true);&#13;
    _;&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Pausable&#13;
 * @dev Base contract which allows children to implement an emergency stop mechanism.&#13;
 * @dev Based on zeppelin's Pausable, but integrated with Manageable&#13;
 * @dev Contract is in paused state by default and should be explicitly unlocked&#13;
 */&#13;
contract Pausable is ManageableInterface,&#13;
                     PausableInterface {&#13;
&#13;
  /**&#13;
   * Storage&#13;
   */&#13;
&#13;
  bool paused = true;&#13;
&#13;
&#13;
  /**&#13;
   * @dev called by the manager to pause, triggers stopped state&#13;
   */&#13;
  function pauseContract() public onlyAllowedManager('pause_contract') whenContractNotPaused {&#13;
    paused = true;&#13;
    PauseEvent();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the manager to unpause, returns to normal state&#13;
   */&#13;
  function unpauseContract() public onlyAllowedManager('unpause_contract') whenContractPaused {&#13;
    paused = false;&#13;
    UnpauseEvent();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev The getter for "paused" contract variable&#13;
   */&#13;
  function getPaused() public constant returns (bool) {&#13;
    return paused;&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title BytecodeExecutorInterface interface&#13;
 * @dev Implementation of a contract that execute any bytecode on behalf of the contract&#13;
 * @dev Last resort for the immutable and not-replaceable contract :)&#13;
 */&#13;
contract BytecodeExecutorInterface {&#13;
&#13;
  /* Events */&#13;
&#13;
  event CallExecutedEvent(address indexed target,&#13;
                          uint256 suppliedGas,&#13;
                          uint256 ethValue,&#13;
                          bytes32 transactionBytecodeHash);&#13;
  event DelegatecallExecutedEvent(address indexed target,&#13;
                                  uint256 suppliedGas,&#13;
                                  bytes32 transactionBytecodeHash);&#13;
&#13;
&#13;
  /* Functions */&#13;
&#13;
  function executeCall(address _target, uint256 _suppliedGas, uint256 _ethValue, bytes _transactionBytecode) external;&#13;
  function executeDelegatecall(address _target, uint256 _suppliedGas, bytes _transactionBytecode) external;&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title BytecodeExecutor&#13;
 * @dev Implementation of a contract that execute any bytecode on behalf of the contract&#13;
 * @dev Last resort for the immutable and not-replaceable contract :)&#13;
 */&#13;
contract BytecodeExecutor is ManageableInterface,&#13;
                             BytecodeExecutorInterface {&#13;
&#13;
  /* Storage */&#13;
&#13;
  bool underExecution = false;&#13;
&#13;
&#13;
  /* BytecodeExecutorInterface */&#13;
&#13;
  function executeCall(&#13;
    address _target,&#13;
    uint256 _suppliedGas,&#13;
    uint256 _ethValue,&#13;
    bytes _transactionBytecode&#13;
  )&#13;
    external&#13;
    onlyAllowedManager('execute_call')&#13;
  {&#13;
    require(underExecution == false);&#13;
&#13;
    underExecution = true; // Avoid recursive calling&#13;
    _target.call.gas(_suppliedGas).value(_ethValue)(_transactionBytecode);&#13;
    underExecution = false;&#13;
&#13;
    CallExecutedEvent(_target, _suppliedGas, _ethValue, keccak256(_transactionBytecode));&#13;
  }&#13;
&#13;
  function executeDelegatecall(&#13;
    address _target,&#13;
    uint256 _suppliedGas,&#13;
    bytes _transactionBytecode&#13;
  )&#13;
    external&#13;
    onlyAllowedManager('execute_delegatecall')&#13;
  {&#13;
    require(underExecution == false);&#13;
&#13;
    underExecution = true; // Avoid recursive calling&#13;
    _target.delegatecall.gas(_suppliedGas)(_transactionBytecode);&#13;
    underExecution = false;&#13;
&#13;
    DelegatecallExecutedEvent(_target, _suppliedGas, keccak256(_transactionBytecode));&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CrydrStorageBaseInterface interface&#13;
 * @dev Interface of a contract that manages balance of an CryDR&#13;
 */&#13;
contract CrydrStorageBaseInterface {&#13;
&#13;
  /* Events */&#13;
&#13;
  event CrydrControllerChangedEvent(address indexed crydrcontroller);&#13;
&#13;
&#13;
  /* Configuration */&#13;
&#13;
  function setCrydrController(address _newController) public;&#13;
  function getCrydrController() public constant returns (address);&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CrydrStorageBase&#13;
 */&#13;
contract CrydrStorageBase is CommonModifiersInterface,&#13;
                             AssetIDInterface,&#13;
                             ManageableInterface,&#13;
                             PausableInterface,&#13;
                             CrydrStorageBaseInterface {&#13;
&#13;
  /* Storage */&#13;
&#13;
  address crydrController = address(0x0);&#13;
&#13;
&#13;
  /* CrydrStorageBaseInterface */&#13;
&#13;
  /* Configuration */&#13;
&#13;
  function setCrydrController(&#13;
    address _crydrController&#13;
  )&#13;
    public&#13;
    whenContractPaused&#13;
    onlyContractAddress(_crydrController)&#13;
    onlyAllowedManager('set_crydr_controller')&#13;
  {&#13;
    require(_crydrController != address(crydrController));&#13;
    require(_crydrController != address(this));&#13;
&#13;
    crydrController = _crydrController;&#13;
    CrydrControllerChangedEvent(_crydrController);&#13;
  }&#13;
&#13;
  function getCrydrController() public constant returns (address) {&#13;
    return address(crydrController);&#13;
  }&#13;
&#13;
&#13;
  /* PausableInterface */&#13;
&#13;
  /**&#13;
   * @dev Override method to ensure that contract properly configured before it is unpaused&#13;
   */&#13;
  function unpauseContract() public {&#13;
    require(isContract(crydrController) == true);&#13;
    require(getAssetIDHash() == AssetIDInterface(crydrController).getAssetIDHash());&#13;
&#13;
    super.unpauseContract();&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CrydrStorageBlocksInterface interface&#13;
 * @dev Interface of a contract that manages balance of an CryDR&#13;
 */&#13;
contract CrydrStorageBlocksInterface {&#13;
&#13;
  /* Events */&#13;
&#13;
  event AccountBlockedEvent(address indexed account);&#13;
  event AccountUnblockedEvent(address indexed account);&#13;
  event AccountFundsBlockedEvent(address indexed account, uint256 value);&#13;
  event AccountFundsUnblockedEvent(address indexed account, uint256 value);&#13;
&#13;
&#13;
  /* Low-level change of blocks and getters */&#13;
&#13;
  function blockAccount(address _account) public;&#13;
  function unblockAccount(address _account) public;&#13;
  function getAccountBlocks(address _account) public constant returns (uint256);&#13;
&#13;
  function blockAccountFunds(address _account, uint256 _value) public;&#13;
  function unblockAccountFunds(address _account, uint256 _value) public;&#13;
  function getAccountBlockedFunds(address _account) public constant returns (uint256);&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CrydrStorageBlocks&#13;
 */&#13;
contract CrydrStorageBlocks is SafeMathInterface,&#13;
                               PausableInterface,&#13;
                               CrydrStorageBaseInterface,&#13;
                               CrydrStorageBlocksInterface {&#13;
&#13;
  /* Storage */&#13;
&#13;
  mapping (address =&gt; uint256) accountBlocks;&#13;
  mapping (address =&gt; uint256) accountBlockedFunds;&#13;
&#13;
&#13;
  /* Constructor */&#13;
&#13;
  function CrydrStorageBlocks() public {&#13;
    accountBlocks[0x0] = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;&#13;
  }&#13;
&#13;
&#13;
  /* Low-level change of blocks and getters */&#13;
&#13;
  function blockAccount(&#13;
    address _account&#13;
  )&#13;
    public&#13;
  {&#13;
    require(msg.sender == getCrydrController());&#13;
&#13;
    require(_account != address(0x0));&#13;
&#13;
    accountBlocks[_account] = safeAdd(accountBlocks[_account], 1);&#13;
    AccountBlockedEvent(_account);&#13;
  }&#13;
&#13;
  function unblockAccount(&#13;
    address _account&#13;
  )&#13;
    public&#13;
  {&#13;
    require(msg.sender == getCrydrController());&#13;
&#13;
    require(_account != address(0x0));&#13;
&#13;
    accountBlocks[_account] = safeSub(accountBlocks[_account], 1);&#13;
    AccountUnblockedEvent(_account);&#13;
  }&#13;
&#13;
  function getAccountBlocks(&#13;
    address _account&#13;
  )&#13;
    public&#13;
    constant&#13;
    returns (uint256)&#13;
  {&#13;
    require(_account != address(0x0));&#13;
&#13;
    return accountBlocks[_account];&#13;
  }&#13;
&#13;
  function blockAccountFunds(&#13;
    address _account,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
  {&#13;
    require(msg.sender == getCrydrController());&#13;
&#13;
    require(_account != address(0x0));&#13;
    require(_value &gt; 0);&#13;
&#13;
    accountBlockedFunds[_account] = safeAdd(accountBlockedFunds[_account], _value);&#13;
    AccountFundsBlockedEvent(_account, _value);&#13;
  }&#13;
&#13;
  function unblockAccountFunds(&#13;
    address _account,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
  {&#13;
    require(msg.sender == getCrydrController());&#13;
&#13;
    require(_account != address(0x0));&#13;
    require(_value &gt; 0);&#13;
&#13;
    accountBlockedFunds[_account] = safeSub(accountBlockedFunds[_account], _value);&#13;
    AccountFundsUnblockedEvent(_account, _value);&#13;
  }&#13;
&#13;
  function getAccountBlockedFunds(&#13;
    address _account&#13;
  )&#13;
    public&#13;
    constant&#13;
    returns (uint256)&#13;
  {&#13;
    require(_account != address(0x0));&#13;
&#13;
    return accountBlockedFunds[_account];&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CrydrStorageBalanceInterface interface&#13;
 * @dev Interface of a contract that manages balance of an CryDR&#13;
 */&#13;
contract CrydrStorageBalanceInterface {&#13;
&#13;
  /* Events */&#13;
&#13;
  event AccountBalanceIncreasedEvent(address indexed account, uint256 value);&#13;
  event AccountBalanceDecreasedEvent(address indexed account, uint256 value);&#13;
&#13;
&#13;
  /* Low-level change of balance. Implied that totalSupply kept in sync. */&#13;
&#13;
  function increaseBalance(address _account, uint256 _value) public;&#13;
  function decreaseBalance(address _account, uint256 _value) public;&#13;
  function getBalance(address _account) public constant returns (uint256);&#13;
  function getTotalSupply() public constant returns (uint256);&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CrydrStorageBalance&#13;
 */&#13;
contract CrydrStorageBalance is SafeMathInterface,&#13;
                                PausableInterface,&#13;
                                CrydrStorageBaseInterface,&#13;
                                CrydrStorageBalanceInterface {&#13;
&#13;
  /* Storage */&#13;
&#13;
  mapping (address =&gt; uint256) balances;&#13;
  uint256 totalSupply = 0;&#13;
&#13;
&#13;
  /* Low-level change of balance and getters. Implied that totalSupply kept in sync. */&#13;
&#13;
  function increaseBalance(&#13;
    address _account,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenContractNotPaused&#13;
  {&#13;
    require(msg.sender == getCrydrController());&#13;
&#13;
    require(_account != address(0x0));&#13;
    require(_value &gt; 0);&#13;
&#13;
    balances[_account] = safeAdd(balances[_account], _value);&#13;
    totalSupply = safeAdd(totalSupply, _value);&#13;
    AccountBalanceIncreasedEvent(_account, _value);&#13;
  }&#13;
&#13;
  function decreaseBalance(&#13;
    address _account,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenContractNotPaused&#13;
  {&#13;
    require(msg.sender == getCrydrController());&#13;
&#13;
    require(_account != address(0x0));&#13;
    require(_value &gt; 0);&#13;
&#13;
    balances[_account] = safeSub(balances[_account], _value);&#13;
    totalSupply = safeSub(totalSupply, _value);&#13;
    AccountBalanceDecreasedEvent(_account, _value);&#13;
  }&#13;
&#13;
  function getBalance(address _account) public constant returns (uint256) {&#13;
    require(_account != address(0x0));&#13;
&#13;
    return balances[_account];&#13;
  }&#13;
&#13;
  function getTotalSupply() public constant returns (uint256) {&#13;
    return totalSupply;&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CrydrStorageAllowanceInterface interface&#13;
 * @dev Interface of a contract that manages balance of an CryDR&#13;
 */&#13;
contract CrydrStorageAllowanceInterface {&#13;
&#13;
  /* Events */&#13;
&#13;
  event AccountAllowanceIncreasedEvent(address indexed owner, address indexed spender, uint256 value);&#13;
  event AccountAllowanceDecreasedEvent(address indexed owner, address indexed spender, uint256 value);&#13;
&#13;
&#13;
  /* Low-level change of allowance */&#13;
&#13;
  function increaseAllowance(address _owner, address _spender, uint256 _value) public;&#13;
  function decreaseAllowance(address _owner, address _spender, uint256 _value) public;&#13;
  function getAllowance(address _owner, address _spender) public constant returns (uint256);&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CrydrStorageAllowance&#13;
 */&#13;
contract CrydrStorageAllowance is SafeMathInterface,&#13;
                                  PausableInterface,&#13;
                                  CrydrStorageBaseInterface,&#13;
                                  CrydrStorageAllowanceInterface {&#13;
&#13;
  /* Storage */&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
&#13;
&#13;
  /* Low-level change of allowance and getters */&#13;
&#13;
  function increaseAllowance(&#13;
    address _owner,&#13;
    address _spender,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenContractNotPaused&#13;
  {&#13;
    require(msg.sender == getCrydrController());&#13;
&#13;
    require(_owner != address(0x0));&#13;
    require(_spender != address(0x0));&#13;
    require(_owner != _spender);&#13;
    require(_value &gt; 0);&#13;
&#13;
    allowed[_owner][_spender] = safeAdd(allowed[_owner][_spender], _value);&#13;
    AccountAllowanceIncreasedEvent(_owner, _spender, _value);&#13;
  }&#13;
&#13;
  function decreaseAllowance(&#13;
    address _owner,&#13;
    address _spender,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenContractNotPaused&#13;
  {&#13;
    require(msg.sender == getCrydrController());&#13;
&#13;
    require(_owner != address(0x0));&#13;
    require(_spender != address(0x0));&#13;
    require(_owner != _spender);&#13;
    require(_value &gt; 0);&#13;
&#13;
    allowed[_owner][_spender] = safeSub(allowed[_owner][_spender], _value);&#13;
    AccountAllowanceDecreasedEvent(_owner, _spender, _value);&#13;
  }&#13;
&#13;
  function getAllowance(&#13;
    address _owner,&#13;
    address _spender&#13;
  )&#13;
    public&#13;
    constant&#13;
    returns (uint256)&#13;
  {&#13;
    require(_owner != address(0x0));&#13;
    require(_spender != address(0x0));&#13;
    require(_owner != _spender);&#13;
&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CrydrStorageERC20Interface interface&#13;
 * @dev Interface of a contract that manages balance of an CryDR and have optimization for ERC20 controllers&#13;
 */&#13;
contract CrydrStorageERC20Interface {&#13;
&#13;
  /* Events */&#13;
&#13;
  event CrydrTransferredEvent(address indexed from, address indexed to, uint256 value);&#13;
  event CrydrTransferredFromEvent(address indexed spender, address indexed from, address indexed to, uint256 value);&#13;
  event CrydrSpendingApprovedEvent(address indexed owner, address indexed spender, uint256 value);&#13;
&#13;
&#13;
  /* ERC20 optimization. _msgsender - account that invoked CrydrView */&#13;
&#13;
  function transfer(address _msgsender, address _to, uint256 _value) public;&#13;
  function transferFrom(address _msgsender, address _from, address _to, uint256 _value) public;&#13;
  function approve(address _msgsender, address _spender, uint256 _value) public;&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title CrydrStorageERC20&#13;
 */&#13;
contract CrydrStorageERC20 is SafeMathInterface,&#13;
                              PausableInterface,&#13;
                              CrydrStorageBaseInterface,&#13;
                              CrydrStorageBalanceInterface,&#13;
                              CrydrStorageAllowanceInterface,&#13;
                              CrydrStorageBlocksInterface,&#13;
                              CrydrStorageERC20Interface {&#13;
&#13;
  function transfer(&#13;
    address _msgsender,&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenContractNotPaused&#13;
  {&#13;
    require(msg.sender == getCrydrController());&#13;
&#13;
    require(_msgsender != _to);&#13;
    require(getAccountBlocks(_msgsender) == 0);&#13;
    require(safeSub(getBalance(_msgsender), _value) &gt;= getAccountBlockedFunds(_msgsender));&#13;
&#13;
    decreaseBalance(_msgsender, _value);&#13;
    increaseBalance(_to, _value);&#13;
    CrydrTransferredEvent(_msgsender, _to, _value);&#13;
  }&#13;
&#13;
  function transferFrom(&#13;
    address _msgsender,&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenContractNotPaused&#13;
  {&#13;
    require(msg.sender == getCrydrController());&#13;
&#13;
    require(getAccountBlocks(_msgsender) == 0);&#13;
    require(getAccountBlocks(_from) == 0);&#13;
    require(safeSub(getBalance(_from), _value) &gt;= getAccountBlockedFunds(_from));&#13;
    require(_from != _to);&#13;
&#13;
    decreaseAllowance(_from, _msgsender, _value);&#13;
    decreaseBalance(_from, _value);&#13;
    increaseBalance(_to, _value);&#13;
    CrydrTransferredFromEvent(_msgsender, _from, _to, _value);&#13;
  }&#13;
&#13;
  function approve(&#13;
    address _msgsender,&#13;
    address _spender,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    whenContractNotPaused&#13;
  {&#13;
    require(msg.sender == getCrydrController());&#13;
&#13;
    require(getAccountBlocks(_msgsender) == 0);&#13;
    require(getAccountBlocks(_spender) == 0);&#13;
&#13;
    uint256 currentAllowance = getAllowance(_msgsender, _spender);&#13;
    require(currentAllowance != _value);&#13;
    if (currentAllowance &gt; _value) {&#13;
      decreaseAllowance(_msgsender, _spender, safeSub(currentAllowance, _value));&#13;
    } else {&#13;
      increaseAllowance(_msgsender, _spender, safeSub(_value, currentAllowance));&#13;
    }&#13;
&#13;
    CrydrSpendingApprovedEvent(_msgsender, _spender, _value);&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title JCashCrydrStorage&#13;
 * @dev Implementation of a contract that manages data of an CryDR&#13;
 */&#13;
contract JCashCrydrStorage is SafeMath,&#13;
                              CommonModifiers,&#13;
                              AssetID,&#13;
                              Ownable,&#13;
                              Manageable,&#13;
                              Pausable,&#13;
                              BytecodeExecutor,&#13;
                              CrydrStorageBase,&#13;
                              CrydrStorageBalance,&#13;
                              CrydrStorageAllowance,&#13;
                              CrydrStorageBlocks,&#13;
                              CrydrStorageERC20 {&#13;
&#13;
  /* Constructor */&#13;
&#13;
  function JCashCrydrStorage(string _assetID) AssetID(_assetID) public { }&#13;
}&#13;
&#13;
&#13;
&#13;
contract JNTStorage is JCashCrydrStorage {&#13;
  function JNTStorage() JCashCrydrStorage('JNT') public {}&#13;
}