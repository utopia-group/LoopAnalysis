pragma solidity ^0.4.18;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="25574048464a6517">[email protected]</a>π.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this ether.&#13;
 * @notice Ether can still be send to this contract by:&#13;
 * calling functions labeled `payable`&#13;
 * `selfdestruct(contract_address)`&#13;
 * mining directly to the contract address&#13;
*/&#13;
contract HasNoEther is Ownable {&#13;
&#13;
  /**&#13;
  * @dev Constructor that rejects incoming Ether&#13;
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we&#13;
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable&#13;
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively&#13;
  * we could use assembly to access msg.value.&#13;
  */&#13;
  function HasNoEther() public payable {&#13;
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
    assert(owner.send(this.balance));&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/StoreManager.sol&#13;
&#13;
interface StoreInterface {&#13;
&#13;
  function getAppNickname()&#13;
  external&#13;
  constant returns (bytes32);&#13;
&#13;
&#13;
  function getAppId()&#13;
  external&#13;
  constant returns (uint);&#13;
&#13;
&#13;
  function getAddressLastUpdate(&#13;
    address _address&#13;
  )&#13;
  external&#13;
  constant returns (uint);&#13;
&#13;
&#13;
  function isUpgradable(&#13;
    address _address,&#13;
    string _uid&#13;
  )&#13;
  public&#13;
  constant returns (bool);&#13;
&#13;
&#13;
  function isUid(&#13;
    string _uid&#13;
  )&#13;
  public&#13;
  view&#13;
  returns (bool);&#13;
&#13;
&#13;
  function setIdentity(&#13;
    address _address,&#13;
    string _uid&#13;
  )&#13;
  external;&#13;
&#13;
&#13;
  function unsetIdentity(&#13;
    address _address&#13;
  )&#13;
  external;&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title StoreManager&#13;
 * @author Francesco Sullo &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="177165767974726474785764627b7b78397478">[email protected]</a>&gt;&#13;
 * @dev Sets and removes tweedentities in the store,&#13;
 * adding more logic to the simple logic of the store&#13;
 */&#13;
&#13;
&#13;
contract StoreManager&#13;
is Pausable, HasNoEther&#13;
{&#13;
&#13;
  string public fromVersion = "1.0.0";&#13;
&#13;
  struct Store {&#13;
    StoreInterface store;&#13;
    address addr;&#13;
    bool active;&#13;
  }&#13;
&#13;
  mapping(uint =&gt; Store) private __stores;&#13;
  uint public totalStores;&#13;
&#13;
  mapping(uint =&gt; bytes32) public appNicknames32;&#13;
  mapping(uint =&gt; string) public appNicknames;&#13;
  mapping(string =&gt; uint) private __appIds;&#13;
&#13;
  address public claimer;&#13;
  address public newClaimer;&#13;
  mapping(address =&gt; bool) public customerService;&#13;
  address[] private __customerServiceAddress;&#13;
&#13;
  uint public upgradable = 0;&#13;
  uint public notUpgradableInStore = 1;&#13;
  uint public addressNotUpgradable = 2;&#13;
&#13;
  uint public minimumTimeBeforeUpdate = 1 hours;&#13;
&#13;
&#13;
&#13;
  // events&#13;
&#13;
&#13;
  event StoreSet(&#13;
    string appNickname,&#13;
    address indexed addr&#13;
  );&#13;
&#13;
&#13;
  event ClaimerSet(&#13;
    address indexed claimer,&#13;
    bool isNew&#13;
  );&#13;
&#13;
&#13;
  event StoreActive(&#13;
    string appNickname,&#13;
    address indexed store,&#13;
    bool active&#13;
  );&#13;
&#13;
&#13;
  event ClaimerSwitch(&#13;
    address indexed oldClaimer,&#13;
    address indexed newClaimer&#13;
  );&#13;
&#13;
&#13;
  event CustomerServiceSet(&#13;
    address indexed addr&#13;
  );&#13;
&#13;
&#13;
  event IdentityNotUpgradable(&#13;
    string appNickname,&#13;
    address indexed addr,&#13;
    string uid&#13;
  );&#13;
&#13;
&#13;
  event MinimumTimeBeforeUpdateChanged(&#13;
    uint _newMinimumTime&#13;
  );&#13;
&#13;
  // config&#13;
&#13;
&#13;
  /**&#13;
   * @dev Sets a store to be used by the manager&#13;
   * @param _appNickname The nickname of the app for which the store's been configured&#13;
   * @param _address The address of the store&#13;
   */&#13;
  function setAStore(&#13;
    string _appNickname,&#13;
    address _address&#13;
  )&#13;
  public&#13;
  onlyOwner&#13;
  {&#13;
    require(bytes(_appNickname).length &gt; 0);&#13;
    bytes32 _appNickname32 = keccak256(_appNickname);&#13;
    require(_address != address(0));&#13;
    StoreInterface _store = StoreInterface(_address);&#13;
    require(_store.getAppNickname() == _appNickname32);&#13;
    uint _appId = _store.getAppId();&#13;
    require(appNicknames32[_appId] == 0x0);&#13;
    appNicknames32[_appId] = _appNickname32;&#13;
    appNicknames[_appId] = _appNickname;&#13;
    __appIds[_appNickname] = _appId;&#13;
&#13;
    __stores[_appId] = Store(&#13;
      _store,&#13;
      _address,&#13;
      true&#13;
    );&#13;
    totalStores++;&#13;
    StoreSet(_appNickname, _address);&#13;
    StoreActive(_appNickname, _address, true);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Sets the claimer which will verify the ownership and call to set a tweedentity&#13;
   * @param _address Address of the claimer&#13;
   */&#13;
  function setClaimer(&#13;
    address _address&#13;
  )&#13;
  public&#13;
  onlyOwner&#13;
  {&#13;
    require(_address != address(0));&#13;
    claimer = _address;&#13;
    ClaimerSet(_address, false);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Sets a new claimer during updates&#13;
   * @param _address Address of the new claimer&#13;
   */&#13;
  function setNewClaimer(&#13;
    address _address&#13;
  )&#13;
  public&#13;
  onlyOwner&#13;
  {&#13;
    require(_address != address(0) &amp;&amp; claimer != address(0));&#13;
    newClaimer = _address;&#13;
    ClaimerSet(_address, true);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
  * @dev Sets new manager&#13;
  */&#13;
  function switchClaimerAndRemoveOldOne()&#13;
  external&#13;
  onlyOwner&#13;
  {&#13;
    require(newClaimer != address(0));&#13;
    ClaimerSwitch(claimer, newClaimer);&#13;
    claimer = newClaimer;&#13;
    newClaimer = address(0);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Sets a wallet as customer service to perform emergency removal of wrong, abused, squatted tweedentities (due, for example, to hacking of the Twitter account)&#13;
   * @param _address The customer service wallet&#13;
   * @param _status The status (true is set, false is unset)&#13;
   */&#13;
  function setCustomerService(&#13;
    address _address,&#13;
    bool _status&#13;
  )&#13;
  public&#13;
  onlyOwner&#13;
  {&#13;
    require(_address != address(0));&#13;
    customerService[_address] = _status;&#13;
    bool found;&#13;
    for (uint i = 0; i &lt; __customerServiceAddress.length; i++) {&#13;
      if (__customerServiceAddress[i] == _address) {&#13;
        found = true;&#13;
        break;&#13;
      }&#13;
    }&#13;
    if (!found) {&#13;
      __customerServiceAddress.push(_address);&#13;
    }&#13;
    CustomerServiceSet(_address);&#13;
  }&#13;
&#13;
&#13;
&#13;
  /**&#13;
   * @dev Unable/disable a store&#13;
   * @param _appNickname The store to be enabled/disabled&#13;
   * @param _active A bool to unable (true) or disable (false)&#13;
   */&#13;
  function activateStore(&#13;
    string _appNickname,&#13;
    bool _active&#13;
  )&#13;
  public&#13;
  onlyOwner&#13;
  {&#13;
    uint _appId = __appIds[_appNickname];&#13;
    require(__stores[_appId].active != _active);&#13;
    __stores[_appId] = Store(&#13;
      __stores[_appId].store,&#13;
      __stores[_appId].addr,&#13;
      _active&#13;
    );&#13;
    StoreActive(_appNickname, __stores[_appId].addr, _active);&#13;
  }&#13;
&#13;
&#13;
&#13;
  //modifiers&#13;
&#13;
&#13;
  modifier onlyClaimer() {&#13;
    require(msg.sender == claimer || (newClaimer != address(0) &amp;&amp; msg.sender == newClaimer));&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
  modifier onlyCustomerService() {&#13;
    require(msg.sender == owner || customerService[msg.sender] == true);&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
  modifier whenStoreSet(&#13;
    uint _appId&#13;
  ) {&#13;
    require(appNicknames32[_appId] != 0x0);&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
&#13;
  // internal getters&#13;
&#13;
&#13;
  function __getStore(&#13;
    uint _appId&#13;
  )&#13;
  internal&#13;
  constant returns (StoreInterface)&#13;
  {&#13;
    return __stores[_appId].store;&#13;
  }&#13;
&#13;
&#13;
&#13;
  // helpers&#13;
&#13;
&#13;
  function isAddressUpgradable(&#13;
    StoreInterface _store,&#13;
    address _address&#13;
  )&#13;
  internal&#13;
  constant returns (bool)&#13;
  {&#13;
    uint lastUpdate = _store.getAddressLastUpdate(_address);&#13;
    return lastUpdate == 0 || now &gt;= lastUpdate + minimumTimeBeforeUpdate;&#13;
  }&#13;
&#13;
&#13;
  function isUpgradable(&#13;
    StoreInterface _store,&#13;
    address _address,&#13;
    string _uid&#13;
  )&#13;
  internal&#13;
  constant returns (bool)&#13;
  {&#13;
    if (!_store.isUpgradable(_address, _uid) || !isAddressUpgradable(_store, _address)) {&#13;
      return false;&#13;
    }&#13;
    return true;&#13;
  }&#13;
&#13;
&#13;
&#13;
  // getters&#13;
&#13;
&#13;
  /**&#13;
   * @dev Gets the app-id associated to a nickname&#13;
   * @param _appNickname The nickname of a configured app&#13;
   */&#13;
  function getAppId(&#13;
    string _appNickname&#13;
  )&#13;
  external&#13;
  constant returns (uint) {&#13;
    return __appIds[_appNickname];&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Allows other contracts to check if a store is set&#13;
   * @param _appNickname The nickname of a configured app&#13;
   */&#13;
  function isStoreSet(&#13;
    string _appNickname&#13;
  )&#13;
  public&#13;
  constant returns (bool){&#13;
    return __appIds[_appNickname] != 0;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Allows other contracts to check if a store is active&#13;
   * @param _appId The id of a configured app&#13;
   */&#13;
  function isStoreActive(&#13;
    uint _appId&#13;
  )&#13;
  public&#13;
  constant returns (bool){&#13;
    return __stores[_appId].active;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Return a numeric code about the upgradability of a couple wallet-uid in a certain app&#13;
   * @param _appId The id of the app&#13;
   * @param _address The address of the wallet&#13;
   * @param _uid The user-id&#13;
   */&#13;
  function getUpgradability(&#13;
    uint _appId,&#13;
    address _address,&#13;
    string _uid&#13;
  )&#13;
  external&#13;
  constant returns (uint)&#13;
  {&#13;
    StoreInterface _store = __getStore(_appId);&#13;
    if (!_store.isUpgradable(_address, _uid)) {&#13;
      return notUpgradableInStore;&#13;
    } else if (!isAddressUpgradable(_store, _address)) {&#13;
      return addressNotUpgradable;&#13;
    } else {&#13;
      return upgradable;&#13;
    }&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Returns the address of a store&#13;
   * @param _appNickname The app nickname&#13;
   */&#13;
  function getStoreAddress(&#13;
    string _appNickname&#13;
  )&#13;
  external&#13;
  constant returns (address) {&#13;
    return __stores[__appIds[_appNickname]].addr;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Returns the address of a store&#13;
   * @param _appId The app id&#13;
   */&#13;
  function getStoreAddressById(&#13;
    uint _appId&#13;
  )&#13;
  external&#13;
  constant returns (address) {&#13;
    return __stores[_appId].addr;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Returns the address of any customerService account&#13;
   */&#13;
  function getCustomerServiceAddress()&#13;
  external&#13;
  constant returns (address[]) {&#13;
    return __customerServiceAddress;&#13;
  }&#13;
&#13;
&#13;
&#13;
  // primary methods&#13;
&#13;
&#13;
  /**&#13;
   * @dev Sets a new identity&#13;
   * @param _appId The id of the app&#13;
   * @param _address The address of the wallet&#13;
   * @param _uid The user-id&#13;
   */&#13;
  function setIdentity(&#13;
    uint _appId,&#13;
    address _address,&#13;
    string _uid&#13;
  )&#13;
  external&#13;
  onlyClaimer&#13;
  whenStoreSet(_appId)&#13;
  whenNotPaused&#13;
  {&#13;
    require(_address != address(0));&#13;
&#13;
    StoreInterface _store = __getStore(_appId);&#13;
    require(_store.isUid(_uid));&#13;
&#13;
    if (isUpgradable(_store, _address, _uid)) {&#13;
      _store.setIdentity(_address, _uid);&#13;
    } else {&#13;
      IdentityNotUpgradable(appNicknames[_appId], _address, _uid);&#13;
    }&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Unsets an existent identity&#13;
   * @param _appId The id of the app&#13;
   * @param _address The address of the wallet&#13;
   */&#13;
  function unsetIdentity(&#13;
    uint _appId,&#13;
    address _address&#13;
  )&#13;
  external&#13;
  onlyCustomerService&#13;
  whenStoreSet(_appId)&#13;
  whenNotPaused&#13;
  {&#13;
    StoreInterface _store = __getStore(_appId);&#13;
    _store.unsetIdentity(_address);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Allow the sender to unset its existent identity&#13;
   * @param _appId The id of the app&#13;
   */&#13;
  function unsetMyIdentity(&#13;
    uint _appId&#13;
  )&#13;
  external&#13;
  whenStoreSet(_appId)&#13;
  whenNotPaused&#13;
  {&#13;
    StoreInterface _store = __getStore(_appId);&#13;
    _store.unsetIdentity(msg.sender);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Update the minimum time before allowing a wallet to update its data&#13;
   * @param _newMinimumTime The new minimum time in seconds&#13;
   */&#13;
  function changeMinimumTimeBeforeUpdate(&#13;
    uint _newMinimumTime&#13;
  )&#13;
  external&#13;
  onlyOwner&#13;
  {&#13;
    minimumTimeBeforeUpdate = _newMinimumTime;&#13;
    MinimumTimeBeforeUpdateChanged(_newMinimumTime);&#13;
  }&#13;
&#13;
}