pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="90e2f5fdf3ffd0a2">[email protected]</a>π.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this Ether.&#13;
 * @notice Ether can still be sent to this contract by:&#13;
 * calling functions labeled `payable`&#13;
 * `selfdestruct(contract_address)`&#13;
 * mining directly to the contract address&#13;
 */&#13;
contract HasNoEther is Ownable {&#13;
&#13;
  /**&#13;
  * @dev Constructor that rejects incoming Ether&#13;
  * The `payable` flag is added so we can access `msg.value` without compiler warning. If we&#13;
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable&#13;
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively&#13;
  * we could use assembly to access msg.value.&#13;
  */&#13;
  constructor() public payable {&#13;
    require(msg.value == 0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Disallows direct send by setting a default function without the `payable` flag.&#13;
   */&#13;
  function() external {&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfer all Ether held by the contract to the owner.&#13;
   */&#13;
  function reclaimEther() external onlyOwner {&#13;
    owner.transfer(address(this).balance);&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * See https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  function totalSupply() public view returns (uint256);&#13;
  function balanceOf(address _who) public view returns (uint256);&#13;
  function transfer(address _to, uint256 _value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address _owner, address _spender)&#13;
    public view returns (uint256);&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _value)&#13;
    public returns (bool);&#13;
&#13;
  function approve(address _spender, uint256 _value) public returns (bool);&#13;
  event Approval(&#13;
    address indexed owner,&#13;
    address indexed spender,&#13;
    uint256 value&#13;
  );&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol&#13;
&#13;
/**&#13;
 * @title SafeERC20&#13;
 * @dev Wrappers around ERC20 operations that throw on failure.&#13;
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,&#13;
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.&#13;
 */&#13;
library SafeERC20 {&#13;
  function safeTransfer(&#13;
    ERC20Basic _token,&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    internal&#13;
  {&#13;
    require(_token.transfer(_to, _value));&#13;
  }&#13;
&#13;
  function safeTransferFrom(&#13;
    ERC20 _token,&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    internal&#13;
  {&#13;
    require(_token.transferFrom(_from, _to, _value));&#13;
  }&#13;
&#13;
  function safeApprove(&#13;
    ERC20 _token,&#13;
    address _spender,&#13;
    uint256 _value&#13;
  )&#13;
    internal&#13;
  {&#13;
    require(_token.approve(_spender, _value));&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol&#13;
&#13;
/**&#13;
 * @title Contracts that should be able to recover tokens&#13;
 * @author SylTi&#13;
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.&#13;
 * This will prevent any accidental loss of tokens.&#13;
 */&#13;
contract CanReclaimToken is Ownable {&#13;
  using SafeERC20 for ERC20Basic;&#13;
&#13;
  /**&#13;
   * @dev Reclaim all ERC20Basic compatible tokens&#13;
   * @param _token ERC20Basic The address of the token contract&#13;
   */&#13;
  function reclaimToken(ERC20Basic _token) external onlyOwner {&#13;
    uint256 balance = _token.balanceOf(this);&#13;
    _token.safeTransfer(owner, balance);&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/ownership/HasNoTokens.sol&#13;
&#13;
/**&#13;
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="394b5c545a56790b">[email protected]</a>π.com&gt;&#13;
 * @dev This blocks incoming ERC223 tokens to prevent accidental loss of tokens.&#13;
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the&#13;
 * owner to reclaim the tokens.&#13;
 */&#13;
contract HasNoTokens is CanReclaimToken {&#13;
&#13;
 /**&#13;
  * @dev Reject all ERC223 compatible tokens&#13;
  * @param _from address The address that is transferring the tokens&#13;
  * @param _value uint256 the amount of the specified token&#13;
  * @param _data Bytes The data passed from the caller.&#13;
  */&#13;
  function tokenFallback(&#13;
    address _from,&#13;
    uint256 _value,&#13;
    bytes _data&#13;
  )&#13;
    external&#13;
    pure&#13;
  {&#13;
    _from;&#13;
    _value;&#13;
    _data;&#13;
    revert();&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts/IPassportLogicRegistry.sol&#13;
&#13;
interface IPassportLogicRegistry {&#13;
    /**&#13;
     * @dev This event will be emitted every time a new passport logic implementation is registered&#13;
     * @param version representing the version name of the registered passport logic implementation&#13;
     * @param implementation representing the address of the registered passport logic implementation&#13;
     */&#13;
    event PassportLogicAdded(string version, address implementation);&#13;
&#13;
    /**&#13;
     * @dev This event will be emitted every time a new passport logic implementation is set as current one&#13;
     * @param version representing the version name of the current passport logic implementation&#13;
     * @param implementation representing the address of the current passport logic implementation&#13;
     */&#13;
    event CurrentPassportLogicSet(string version, address implementation);&#13;
&#13;
    /**&#13;
     * @dev Tells the address of the passport logic implementation for a given version&#13;
     * @param _version to query the implementation of&#13;
     * @return address of the passport logic implementation registered for the given version&#13;
     */&#13;
    function getPassportLogic(string _version) external view returns (address);&#13;
&#13;
    /**&#13;
     * @dev Tells the version of the current passport logic implementation&#13;
     * @return version of the current passport logic implementation&#13;
     */&#13;
    function getCurrentPassportLogicVersion() external view returns (string);&#13;
&#13;
    /**&#13;
     * @dev Tells the address of the current passport logic implementation&#13;
     * @return address of the current passport logic implementation&#13;
     */&#13;
    function getCurrentPassportLogic() external view returns (address);&#13;
}&#13;
&#13;
// File: contracts/PassportLogicRegistry.sol&#13;
&#13;
/**&#13;
 * @title PassportImplRegistry&#13;
 * @dev This contract works as a registry of passport implementations, it holds the implementations for the registered versions.&#13;
 */&#13;
contract PassportLogicRegistry is IPassportLogicRegistry, Ownable, HasNoEther, HasNoTokens {&#13;
    // current passport version/implementation&#13;
    string internal currentPassportLogicVersion;&#13;
    address internal currentPassportLogic;&#13;
&#13;
    // Mapping of versions to passport implementations&#13;
    mapping(string =&gt; address) internal passportLogicImplementations;&#13;
&#13;
    /**&#13;
     * @dev The PassportImplRegistry constructor sets the current passport version and implementation.&#13;
     */&#13;
    constructor (string _version, address _implementation) public {&#13;
        _addPassportLogic(_version, _implementation);&#13;
        _setCurrentPassportLogic(_version);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Registers a new passport version with its logic implementation address&#13;
     * @param _version representing the version name of the new passport logic implementation to be registered&#13;
     * @param _implementation representing the address of the new passport logic implementation to be registered&#13;
     */&#13;
    function addPassportLogic(string _version, address _implementation) public onlyOwner {&#13;
        _addPassportLogic(_version, _implementation);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Tells the address of the passport logic implementation for a given version&#13;
     * @param _version to query the implementation of&#13;
     * @return address of the passport logic implementation registered for the given version&#13;
     */&#13;
    function getPassportLogic(string _version) external view returns (address) {&#13;
        return passportLogicImplementations[_version];&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Sets a new passport logic implementation as current one&#13;
     * @param _version representing the version name of the passport logic implementation to be set as current one&#13;
     */&#13;
    function setCurrentPassportLogic(string _version) public onlyOwner {&#13;
        _setCurrentPassportLogic(_version);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Tells the version of the current passport logic implementation&#13;
     * @return version of the current passport logic implementation&#13;
     */&#13;
    function getCurrentPassportLogicVersion() external view returns (string) {&#13;
        return currentPassportLogicVersion;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Tells the address of the current passport logic implementation&#13;
     * @return address of the current passport logic implementation&#13;
     */&#13;
    function getCurrentPassportLogic() external view returns (address) {&#13;
        return currentPassportLogic;&#13;
    }&#13;
&#13;
    function _addPassportLogic(string _version, address _implementation) internal {&#13;
        require(_implementation != 0x0, "Cannot set implementation to a zero address");&#13;
        require(passportLogicImplementations[_version] == 0x0, "Cannot replace existing version implementation");&#13;
&#13;
        passportLogicImplementations[_version] = _implementation;&#13;
        emit PassportLogicAdded(_version, _implementation);&#13;
    }&#13;
&#13;
    function _setCurrentPassportLogic(string _version) internal {&#13;
        require(passportLogicImplementations[_version] != 0x0, "Cannot set non-existing passport logic as current implementation");&#13;
&#13;
        currentPassportLogicVersion = _version;&#13;
        currentPassportLogic = passportLogicImplementations[_version];&#13;
        emit CurrentPassportLogicSet(currentPassportLogicVersion, currentPassportLogic);&#13;
    }&#13;
}