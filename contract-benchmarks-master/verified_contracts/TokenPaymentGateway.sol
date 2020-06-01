contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  function HasNoEther() payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by settings a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    assert(owner.send(this.balance));
  }
}


library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}

/**
 * @title Contracts that should not own Tokens
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c0b2a5ada3af80f2">[email protected]</a>π.com&gt;&#13;
 * @dev This blocks incoming ERC23 tokens to prevent accidental loss of tokens.&#13;
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the&#13;
 * owner to reclaim the tokens.&#13;
 */&#13;
contract HasNoTokens is CanReclaimToken {&#13;
&#13;
 /**&#13;
  * @dev Reject all ERC23 compatible tokens&#13;
  * @param from_ address The address that is transferring the tokens&#13;
  * @param value_ uint256 the amount of the specified token&#13;
  * @param data_ Bytes The data passed from the caller.&#13;
  */&#13;
  function tokenFallback(address from_, uint256 value_, bytes data_) external {&#13;
    revert();&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private rentrancy_lock = false;&#13;
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
    require(!rentrancy_lock);&#13;
    rentrancy_lock = true;&#13;
    _;&#13;
    rentrancy_lock = false;&#13;
  }&#13;
&#13;
}&#13;
contract Claimable is Ownable {&#13;
  address public pendingOwner;&#13;
&#13;
  /**&#13;
   * @dev Modifier throws if called by any account other than the pendingOwner.&#13;
   */&#13;
  modifier onlyPendingOwner() {&#13;
    require(msg.sender == pendingOwner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to set the pendingOwner address.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) onlyOwner public {&#13;
    pendingOwner = newOwner;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the pendingOwner address to finalize the transfer.&#13;
   */&#13;
  function claimOwnership() onlyPendingOwner public {&#13;
    OwnershipTransferred(owner, pendingOwner);&#13;
    owner = pendingOwner;&#13;
    pendingOwner = 0x0;&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Pausable&#13;
 * @dev Base contract which allows children to implement an emergency stop mechanism.&#13;
 */&#13;
contract Pausable is Ownable {&#13;
  event Pause();&#13;
  event Unpause();&#13;
&#13;
  bool public paused = false;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is not paused.&#13;
   */&#13;
  modifier whenNotPaused() {&#13;
    require(!paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is paused.&#13;
   */&#13;
  modifier whenPaused() {&#13;
    require(paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to pause, triggers stopped state&#13;
   */&#13;
  function pause() onlyOwner whenNotPaused public {&#13;
    paused = true;&#13;
    Pause();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to unpause, returns to normal state&#13;
   */&#13;
  function unpause() onlyOwner whenPaused public {&#13;
    paused = false;&#13;
    Unpause();&#13;
  }&#13;
}&#13;
contract StandardContract {&#13;
    // allows usage of "require" as a modifier&#13;
    modifier requires(bool b) {&#13;
        require(b);&#13;
        _;&#13;
    }&#13;
&#13;
    // require at least one of the two conditions to be true&#13;
    modifier requiresOne(bool b1, bool b2) {&#13;
        require(b1 || b2);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notNull(address a) {&#13;
        require(a != 0);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notZero(uint256 a) {&#13;
        require(a != 0);&#13;
        _;&#13;
    }&#13;
}&#13;
&#13;
contract TokenPaymentGateway is Claimable, HasNoEther, HasNoTokens, ReentrancyGuard, Pausable, StandardContract {&#13;
  &#13;
  ERC20 public token;&#13;
  address public tokenCollector;&#13;
&#13;
  event LogPayment(address from, uint256 amount, bytes extraData);&#13;
  event LogSettingsUpdate(address tokenAddress, address tokenCollector);&#13;
  &#13;
  function TokenPaymentGateway() {}&#13;
&#13;
  function receiveApproval(address _from, uint256 _amount, address _ignoreToken, bytes _extraData)&#13;
    requires(msg.sender == address(token))&#13;
    requires(_extraData.length &gt; 0)&#13;
    whenNotPaused&#13;
    nonReentrant&#13;
    external&#13;
  {&#13;
    require(token.transferFrom(_from, tokenCollector, _amount));&#13;
    emit LogPayment(_from, _amount, _extraData);&#13;
  }&#13;
&#13;
  function adminUpdateSettings(address _tokenAddress, address _tokenCollector)&#13;
    onlyOwner&#13;
    external&#13;
  {&#13;
    token = ERC20(_tokenAddress);&#13;
    tokenCollector = _tokenCollector;&#13;
    emit LogSettingsUpdate(_tokenAddress, _tokenCollector);&#13;
  }&#13;
}