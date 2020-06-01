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

// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3143545c525e7103">[email protected]</a>π.com&gt;&#13;
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
// File: contracts/TweedentityRegistry.sol&#13;
&#13;
contract Pausable {&#13;
&#13;
  bool public paused;&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title TweedentityRegistry&#13;
 * @author Francesco Sullo &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ee889c8f808d8b9d8d81ae9d9b828281c08d81">[email protected]</a>&gt;&#13;
 * @dev It store the tweedentities contracts addresses to allows dapp to be updated&#13;
 */&#13;
&#13;
&#13;
contract TweedentityRegistry&#13;
is HasNoEther&#13;
{&#13;
&#13;
  string public version = "1.3.0";&#13;
&#13;
  uint public totalStores;&#13;
  mapping (bytes32 =&gt; address) public stores;&#13;
&#13;
  address public manager;&#13;
  address public claimer;&#13;
&#13;
  bytes32 public managerKey = keccak256("manager");&#13;
  bytes32 public claimerKey = keccak256("claimer");&#13;
  bytes32 public storeKey = keccak256("store");&#13;
&#13;
  event ContractRegistered(&#13;
    bytes32 indexed key,&#13;
    string spec,&#13;
    address addr&#13;
  );&#13;
&#13;
&#13;
  function setManager(&#13;
    address _manager&#13;
  )&#13;
  external&#13;
  onlyOwner&#13;
  {&#13;
    require(_manager != address(0));&#13;
    manager = _manager;&#13;
    ContractRegistered(managerKey, "", _manager);&#13;
  }&#13;
&#13;
&#13;
  function setClaimer(&#13;
    address _claimer&#13;
  )&#13;
  external&#13;
  onlyOwner&#13;
  {&#13;
    require(_claimer != address(0));&#13;
    claimer = _claimer;&#13;
    ContractRegistered(claimerKey, "", _claimer);&#13;
  }&#13;
&#13;
&#13;
  function setManagerAndClaimer(&#13;
    address _manager,&#13;
    address _claimer&#13;
  )&#13;
  external&#13;
  onlyOwner&#13;
  {&#13;
    require(_manager != address(0));&#13;
    require(_claimer != address(0));&#13;
    manager = _manager;&#13;
    claimer = _claimer;&#13;
    ContractRegistered(managerKey, "", _manager);&#13;
    ContractRegistered(claimerKey, "", _claimer);&#13;
  }&#13;
&#13;
&#13;
  function setAStore(&#13;
    string _appNickname,&#13;
    address _store&#13;
  )&#13;
  external&#13;
  onlyOwner&#13;
  {&#13;
    require(_store != address(0));&#13;
    if (getStore(_appNickname) == address(0)) {&#13;
      totalStores++;&#13;
    }&#13;
    stores[keccak256(_appNickname)] = _store;&#13;
    ContractRegistered(storeKey, _appNickname, _store);&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Gets the store managing the specified app&#13;
   * @param _appNickname The nickname of the app&#13;
   */&#13;
  function getStore(&#13;
    string _appNickname&#13;
  )&#13;
  public&#13;
  constant returns(address)&#13;
  {&#13;
    return stores[keccak256(_appNickname)];&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Returns true if the registry looks ready&#13;
   */&#13;
  function isReady()&#13;
  external&#13;
  constant returns(bool)&#13;
  {&#13;
    Pausable pausable = Pausable(manager);&#13;
    return totalStores &gt; 0 &amp;&amp; manager != address(0) &amp;&amp; claimer != address(0) &amp;&amp; pausable.paused() == false;&#13;
  }&#13;
&#13;
}