pragma solidity ^0.4.11;
/* Inlined from ./contracts/PortMayor.sol */


/* Inlined from node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol */



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

/* Inlined from node_modules/zeppelin-solidity/contracts/ownership/HasNoEther.sol */




/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="96e4f3fbf5f9d6a4">[email protected]</a>π.com&gt;&#13;
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
/* Inlined from node_modules/zeppelin-solidity/contracts/ownership/CanReclaimToken.sol */&#13;
&#13;
&#13;
&#13;
/* Inlined from node_modules/zeppelin-solidity/contracts/token/ERC20Basic.sol */&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  uint256 public totalSupply;&#13;
  function balanceOf(address who) public view returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
/* Inlined from node_modules/zeppelin-solidity/contracts/token/SafeERC20.sol */&#13;
&#13;
&#13;
&#13;
/* Inlined from node_modules/zeppelin-solidity/contracts/token/ERC20.sol */&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender) public view returns (uint256);&#13;
  function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title SafeERC20&#13;
 * @dev Wrappers around ERC20 operations that throw on failure.&#13;
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,&#13;
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.&#13;
 */&#13;
library SafeERC20 {&#13;
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {&#13;
    assert(token.transfer(to, value));&#13;
  }&#13;
&#13;
  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {&#13;
    assert(token.transferFrom(from, to, value));&#13;
  }&#13;
&#13;
  function safeApprove(ERC20 token, address spender, uint256 value) internal {&#13;
    assert(token.approve(spender, value));&#13;
  }&#13;
}&#13;
&#13;
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
   * @param token ERC20Basic The address of the token contract&#13;
   */&#13;
  function reclaimToken(ERC20Basic token) external onlyOwner {&#13;
    uint256 balance = token.balanceOf(this);&#13;
    token.safeTransfer(owner, balance);&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
/* Inlined from contracts/PortCoin.sol */&#13;
&#13;
&#13;
&#13;
&#13;
contract PortCoin is ERC20 {&#13;
&#13;
  address mayor;&#13;
&#13;
  string public name = "Portland Maine Token";&#13;
  string public symbol = "PORT";&#13;
  uint public decimals = 0;&#13;
&#13;
  mapping(address =&gt; uint256) balances;&#13;
  mapping(address =&gt; mapping(address =&gt; uint256)) approvals;&#13;
&#13;
  event NewMayor(address indexed oldMayor, address indexed newMayor);&#13;
&#13;
  function PortCoin() public {&#13;
    mayor = msg.sender;&#13;
  }&#13;
&#13;
  modifier onlyMayor() {&#13;
    require(msg.sender == mayor);&#13;
    _;&#13;
  }&#13;
&#13;
  function electNewMayor(address newMayor) onlyMayor public {&#13;
    address oldMayor = mayor;&#13;
    mayor = newMayor;&#13;
    NewMayor(oldMayor, newMayor);&#13;
  }&#13;
&#13;
  function issue(address to, uint256 amount) onlyMayor public returns (bool){&#13;
    totalSupply += amount;&#13;
    balances[to] += amount;&#13;
    Transfer(0x0, to, amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  function balanceOf(address who) public constant returns (uint256) {&#13;
    return balances[who];&#13;
  }&#13;
&#13;
  function transfer(address to, uint256 value) public returns (bool) {&#13;
    require(balances[msg.sender] &gt;= value);&#13;
    balances[to] += value;&#13;
    balances[msg.sender] -= value;&#13;
    Transfer(msg.sender, to, value);&#13;
    return true;&#13;
  }&#13;
&#13;
  function approve(address spender, uint256 value) public returns (bool) {&#13;
    approvals[msg.sender][spender] = value;&#13;
    Approval(msg.sender, spender, value);&#13;
    return true;&#13;
  }&#13;
&#13;
  function allowance(address owner, address spender) public constant returns (uint256) {&#13;
    return approvals[owner][spender];&#13;
  }&#13;
&#13;
  function transferFrom(address from, address to, uint256 value) public returns (bool) {&#13;
    require(approvals[from][msg.sender] &gt;= value);&#13;
    require(balances[from] &gt;= value);&#13;
&#13;
    balances[to] += value;&#13;
    balances[from] -= value;&#13;
    approvals[from][msg.sender] -= value;&#13;
    Transfer(from, to, value);&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
&#13;
contract PortMayor is Ownable, HasNoEther, CanReclaimToken {&#13;
&#13;
  PortCoin coin;&#13;
  mapping(address =&gt; uint256) tickets;&#13;
&#13;
  event Attend(address indexed attendee, uint256 ticket, address indexed eventAddress);&#13;
  event EventCreated(address eventAddress);&#13;
&#13;
  function PortMayor(address portCoinAddress) public {&#13;
    coin = PortCoin(portCoinAddress);&#13;
  }&#13;
&#13;
  function electNewMayor(address newMayor) onlyOwner public {&#13;
    coin.electNewMayor(newMayor);&#13;
  }&#13;
&#13;
  function isEvent(address eventAddress) view public returns (bool) {&#13;
    return tickets[eventAddress] &gt; 0;&#13;
  }&#13;
&#13;
  function isValidTicket(address eventAddress, uint8 ticket) view public returns (bool){&#13;
    return (tickets[eventAddress] &amp; (uint256(2) ** ticket)) &gt; 0;&#13;
  }&#13;
&#13;
  function createEvent(address eventAddress) onlyOwner public {&#13;
    tickets[eventAddress] = uint256(0) - 1; // fill with 1s&#13;
    EventCreated(eventAddress);&#13;
  }&#13;
&#13;
  function stringify(uint8 v) public pure returns (string ret) {&#13;
    bytes memory data = new bytes(3);&#13;
    data[0] = bytes1(48 + (v / 100) % 10);&#13;
    data[1] = bytes1(48 + (v / 10) % 10);&#13;
    data[2] = bytes1(48 + v % 10);&#13;
    return string(data);&#13;
  }&#13;
&#13;
  function attend(uint8 ticket, bytes32 r, bytes32 s, uint8 v) public {&#13;
    address eventAddress = ecrecover(keccak256("\x19Ethereum Signed Message:\n3",stringify(ticket)),v,r,s);&#13;
    require(isValidTicket(eventAddress, ticket));&#13;
    tickets[eventAddress] = tickets[eventAddress] ^ (uint256(2) ** ticket);&#13;
    coin.issue(msg.sender, 1);&#13;
    Attend(msg.sender, ticket, eventAddress);&#13;
  }&#13;
&#13;
  function issue(address to, uint quantity) public onlyOwner {&#13;
    coin.issue(to, quantity);&#13;
  }&#13;
}