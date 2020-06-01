pragma solidity 0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol

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

// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="87f5e2eae4e8c7b5">[email protected]</span>π.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this ether.&#13;
 * @notice Ether can still be sent to this contract by:&#13;
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
    // solium-disable-next-line security/no-send&#13;
    assert(owner.send(address(this).balance));&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/math/SafeMath.sol&#13;
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
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
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
// File: contracts/RTELockingVault.sol&#13;
&#13;
/**&#13;
 * @title RTELockingVault&#13;
 * @dev For RTE token holders to lock up their tokens for incentives&#13;
 */&#13;
contract RTELockingVault is HasNoEther, CanReclaimToken {&#13;
  using SafeERC20 for ERC20;&#13;
  using SafeMath for uint256;&#13;
&#13;
  ERC20 public token;&#13;
&#13;
  bool public vaultUnlocked;&#13;
&#13;
  uint256 public cap;&#13;
&#13;
  uint256 public minimumDeposit;&#13;
&#13;
  uint256 public tokensDeposited;&#13;
&#13;
  uint256 public interestRate;&#13;
&#13;
  uint256 public vaultDepositDeadlineTime;&#13;
&#13;
  uint256 public vaultUnlockTime;&#13;
&#13;
  uint256 public vaultLockDays;&#13;
&#13;
  address public rewardWallet;&#13;
&#13;
  mapping(address =&gt; uint256) public lockedBalances;&#13;
&#13;
  /**&#13;
   * @dev Locked tokens event&#13;
   * @param _investor Investor address&#13;
   * @param _value Tokens locked&#13;
   */&#13;
  event TokenLocked(address _investor, uint256 _value);&#13;
&#13;
  /**&#13;
   * @dev Withdrawal event&#13;
   * @param _investor Investor address&#13;
   * @param _value Tokens withdrawn&#13;
   */&#13;
  event TokenWithdrawal(address _investor, uint256 _value);&#13;
&#13;
  constructor (&#13;
    ERC20 _token,&#13;
    uint256 _cap,&#13;
    uint256 _minimumDeposit,&#13;
    uint256 _interestRate,&#13;
    uint256 _vaultDepositDeadlineTime,&#13;
    uint256 _vaultUnlockTime,&#13;
    uint256 _vaultLockDays,&#13;
    address _rewardWallet&#13;
  )&#13;
    public&#13;
  {&#13;
    require(_vaultDepositDeadlineTime &gt; now);&#13;
    // require(_vaultDepositDeadlineTime &lt; _vaultUnlockTime);&#13;
&#13;
    vaultUnlocked = false;&#13;
&#13;
    token = _token;&#13;
    cap = _cap;&#13;
    minimumDeposit = _minimumDeposit;&#13;
    interestRate = _interestRate;&#13;
    vaultDepositDeadlineTime = _vaultDepositDeadlineTime;&#13;
    vaultUnlockTime = _vaultUnlockTime;&#13;
    vaultLockDays = _vaultLockDays;&#13;
    rewardWallet = _rewardWallet;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Deposit and lock tokens&#13;
   * @param _amount Amount of tokens to transfer and lock&#13;
   */&#13;
  function lockToken(uint256 _amount) public {&#13;
    require(_amount &gt;= minimumDeposit);&#13;
    require(now &lt; vaultDepositDeadlineTime);&#13;
    require(tokensDeposited.add(_amount) &lt;= cap);&#13;
&#13;
    token.safeTransferFrom(msg.sender, address(this), _amount);&#13;
&#13;
    lockedBalances[msg.sender] = lockedBalances[msg.sender].add(_amount);&#13;
&#13;
    tokensDeposited = tokensDeposited.add(_amount);&#13;
&#13;
    emit TokenLocked(msg.sender, _amount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Withdraw locked tokens&#13;
   */&#13;
  function withdrawToken() public {&#13;
    // require(vaultUnlocked);&#13;
&#13;
    uint256 interestAmount = (interestRate.mul(lockedBalances[msg.sender]).div(36500)).mul(vaultLockDays);&#13;
&#13;
    uint256 withdrawAmount = (lockedBalances[msg.sender]).add(interestAmount);&#13;
    require(withdrawAmount &gt; 0);&#13;
&#13;
    lockedBalances[msg.sender] = 0;&#13;
&#13;
    token.safeTransfer(msg.sender, withdrawAmount);&#13;
&#13;
    emit TokenWithdrawal(msg.sender, withdrawAmount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Force Withdraw locked tokens&#13;
   */&#13;
  function forceWithdrawToken(address _forceAddress) public onlyOwner {&#13;
    require(vaultUnlocked);&#13;
&#13;
    uint256 interestAmount = (interestRate.mul(lockedBalances[_forceAddress]).div(36500)).mul(vaultLockDays);&#13;
&#13;
    uint256 withdrawAmount = (lockedBalances[_forceAddress]).add(interestAmount);&#13;
    require(withdrawAmount &gt; 0);&#13;
&#13;
    lockedBalances[_forceAddress] = 0;&#13;
&#13;
    token.safeTransfer(_forceAddress, withdrawAmount);&#13;
&#13;
    emit TokenWithdrawal(_forceAddress, withdrawAmount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Irreversibly finalizes and unlocks the vault - only owner of contract can call this&#13;
   */&#13;
  function finalizeVault() public onlyOwner {&#13;
    // require(!vaultUnlocked);&#13;
    require(now &gt;= vaultUnlockTime);&#13;
&#13;
    vaultUnlocked = true;&#13;
&#13;
    uint256 bonusTokens = ((tokensDeposited.mul(interestRate)).div(36500)).mul(vaultLockDays);&#13;
&#13;
    token.safeTransferFrom(rewardWallet, address(this), bonusTokens);&#13;
  }&#13;
}