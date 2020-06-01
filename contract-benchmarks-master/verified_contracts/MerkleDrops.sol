pragma solidity 0.4.24;

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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
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

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="7200171f111d3240">[email protected]</span>π.com&gt;&#13;
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
   * @dev Disallows direct send by settings a default function without the `payable` flag.&#13;
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
/**&#13;
 * @title SafeERC20&#13;
 * @dev Wrappers around ERC20 operations that throw on failure.&#13;
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,&#13;
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.&#13;
 */&#13;
library SafeERC20 {&#13;
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {&#13;
    require(token.transfer(to, value));&#13;
  }&#13;
&#13;
  function safeTransferFrom(&#13;
    ERC20 token,&#13;
    address from,&#13;
    address to,&#13;
    uint256 value&#13;
  )&#13;
    internal&#13;
  {&#13;
    require(token.transferFrom(from, to, value));&#13;
  }&#13;
&#13;
  function safeApprove(ERC20 token, address spender, uint256 value) internal {&#13;
    require(token.approve(spender, value));&#13;
  }&#13;
}&#13;
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
/**&#13;
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="394b5c545a56790b">[email protected]</span>π.com&gt;&#13;
 * @dev This blocks incoming ERC223 tokens to prevent accidental loss of tokens.&#13;
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the&#13;
 * owner to reclaim the tokens.&#13;
 */&#13;
contract HasNoTokens is CanReclaimToken {&#13;
&#13;
 /**&#13;
  * @dev Reject all ERC223 compatible tokens&#13;
  * @param from_ address The address that is transferring the tokens&#13;
  * @param value_ uint256 the amount of the specified token&#13;
  * @param data_ Bytes The data passed from the caller.&#13;
  */&#13;
  function tokenFallback(address from_, uint256 value_, bytes data_) external {&#13;
    from_;&#13;
    value_;&#13;
    data_;&#13;
    revert();&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Contracts that should not own Contracts&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="87f5e2eae4e8c7b5">[email protected]</span>π.com&gt;&#13;
 * @dev Should contracts (anything Ownable) end up being owned by this contract, it allows the owner&#13;
 * of this contract to reclaim ownership of the contracts.&#13;
 */&#13;
contract HasNoContracts is Ownable {&#13;
&#13;
  /**&#13;
   * @dev Reclaim ownership of Ownable contracts&#13;
   * @param contractAddr The address of the Ownable to be reclaimed.&#13;
   */&#13;
  function reclaimContract(address contractAddr) external onlyOwner {&#13;
    Ownable contractInst = Ownable(contractAddr);&#13;
    contractInst.transferOwnership(owner);&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Base contract for contracts that should not own things.&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="74061119171b3446">[email protected]</span>π.com&gt;&#13;
 * @dev Solves a class of errors where a contract accidentally becomes owner of Ether, Tokens or&#13;
 * Owned contracts. See respective base contracts for details.&#13;
 */&#13;
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {&#13;
}&#13;
&#13;
/*&#13;
 * @title MerkleProof&#13;
 * @dev Merkle proof verification based on&#13;
 * https://github.com/ameensol/merkle-tree-solidity/blob/master/src/MerkleProof.sol&#13;
 */&#13;
library MerkleProof {&#13;
  /*&#13;
   * @dev Verifies a Merkle proof proving the existence of a leaf in a Merkle tree. Assumes that each pair of leaves&#13;
   * and each pair of pre-images is sorted.&#13;
   * @param _proof Merkle proof containing sibling hashes on the branch from the leaf to the root of the Merkle tree&#13;
   * @param _root Merkle root&#13;
   * @param _leaf Leaf of Merkle tree&#13;
   */&#13;
  function verifyProof(&#13;
    bytes32[] _proof,&#13;
    bytes32 _root,&#13;
    bytes32 _leaf&#13;
  )&#13;
    internal&#13;
    pure&#13;
    returns (bool)&#13;
  {&#13;
    bytes32 computedHash = _leaf;&#13;
&#13;
    for (uint256 i = 0; i &lt; _proof.length; i++) {&#13;
      bytes32 proofElement = _proof[i];&#13;
&#13;
      if (computedHash &lt; proofElement) {&#13;
        // Hash(current computed hash + current element of the proof)&#13;
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));&#13;
      } else {&#13;
        // Hash(current element of the proof + current computed hash)&#13;
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));&#13;
      }&#13;
    }&#13;
&#13;
    // Check if the computed hash (root) is equal to the provided root&#13;
    return computedHash == _root;&#13;
  }&#13;
}&#13;
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
    emit Pause();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to unpause, returns to normal state&#13;
   */&#13;
  function unpause() onlyOwner whenPaused public {&#13;
    paused = false;&#13;
    emit Unpause();&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Roles&#13;
 * @author Francisco Giordano (@frangio)&#13;
 * @dev Library for managing addresses assigned to a Role.&#13;
 * See RBAC.sol for example usage.&#13;
 */&#13;
library Roles {&#13;
  struct Role {&#13;
    mapping (address =&gt; bool) bearer;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev give an address access to this role&#13;
   */&#13;
  function add(Role storage role, address addr)&#13;
    internal&#13;
  {&#13;
    role.bearer[addr] = true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove an address' access to this role&#13;
   */&#13;
  function remove(Role storage role, address addr)&#13;
    internal&#13;
  {&#13;
    role.bearer[addr] = false;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev check if an address has this role&#13;
   * // reverts&#13;
   */&#13;
  function check(Role storage role, address addr)&#13;
    view&#13;
    internal&#13;
  {&#13;
    require(has(role, addr));&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev check if an address has this role&#13;
   * @return bool&#13;
   */&#13;
  function has(Role storage role, address addr)&#13;
    view&#13;
    internal&#13;
    returns (bool)&#13;
  {&#13;
    return role.bearer[addr];&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title RBAC (Role-Based Access Control)&#13;
 * @author Matt Condon (@Shrugs)&#13;
 * @dev Stores and provides setters and getters for roles and addresses.&#13;
 * Supports unlimited numbers of roles and addresses.&#13;
 * See //contracts/mocks/RBACMock.sol for an example of usage.&#13;
 * This RBAC method uses strings to key roles. It may be beneficial&#13;
 * for you to write your own implementation of this interface using Enums or similar.&#13;
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,&#13;
 * to avoid typos.&#13;
 */&#13;
contract RBAC {&#13;
  using Roles for Roles.Role;&#13;
&#13;
  mapping (string =&gt; Roles.Role) private roles;&#13;
&#13;
  event RoleAdded(address indexed operator, string role);&#13;
  event RoleRemoved(address indexed operator, string role);&#13;
&#13;
  /**&#13;
   * @dev reverts if addr does not have role&#13;
   * @param _operator address&#13;
   * @param _role the name of the role&#13;
   * // reverts&#13;
   */&#13;
  function checkRole(address _operator, string _role)&#13;
    view&#13;
    public&#13;
  {&#13;
    roles[_role].check(_operator);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev determine if addr has role&#13;
   * @param _operator address&#13;
   * @param _role the name of the role&#13;
   * @return bool&#13;
   */&#13;
  function hasRole(address _operator, string _role)&#13;
    view&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    return roles[_role].has(_operator);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev add a role to an address&#13;
   * @param _operator address&#13;
   * @param _role the name of the role&#13;
   */&#13;
  function addRole(address _operator, string _role)&#13;
    internal&#13;
  {&#13;
    roles[_role].add(_operator);&#13;
    emit RoleAdded(_operator, _role);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove a role from an address&#13;
   * @param _operator address&#13;
   * @param _role the name of the role&#13;
   */&#13;
  function removeRole(address _operator, string _role)&#13;
    internal&#13;
  {&#13;
    roles[_role].remove(_operator);&#13;
    emit RoleRemoved(_operator, _role);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev modifier to scope access to a single role (uses msg.sender as addr)&#13;
   * @param _role the name of the role&#13;
   * // reverts&#13;
   */&#13;
  modifier onlyRole(string _role)&#13;
  {&#13;
    checkRole(msg.sender, _role);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)&#13;
   * @param _roles the names of the roles to scope access to&#13;
   * // reverts&#13;
   *&#13;
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this&#13;
   *  see: https://github.com/ethereum/solidity/issues/2467&#13;
   */&#13;
  // modifier onlyRoles(string[] _roles) {&#13;
  //     bool hasAnyRole = false;&#13;
  //     for (uint8 i = 0; i &lt; _roles.length; i++) {&#13;
  //         if (hasRole(msg.sender, _roles[i])) {&#13;
  //             hasAnyRole = true;&#13;
  //             break;&#13;
  //         }&#13;
  //     }&#13;
&#13;
  //     require(hasAnyRole);&#13;
&#13;
  //     _;&#13;
  // }&#13;
}&#13;
&#13;
/**&#13;
 * @title Whitelist&#13;
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.&#13;
 * This simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Whitelist is Ownable, RBAC {&#13;
  string public constant ROLE_WHITELISTED = "whitelist";&#13;
&#13;
  /**&#13;
   * @dev Throws if operator is not whitelisted.&#13;
   * @param _operator address&#13;
   */&#13;
  modifier onlyIfWhitelisted(address _operator) {&#13;
    checkRole(_operator, ROLE_WHITELISTED);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev add an address to the whitelist&#13;
   * @param _operator address&#13;
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist&#13;
   */&#13;
  function addAddressToWhitelist(address _operator)&#13;
    onlyOwner&#13;
    public&#13;
  {&#13;
    addRole(_operator, ROLE_WHITELISTED);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev getter to determine if address is in whitelist&#13;
   */&#13;
  function whitelist(address _operator)&#13;
    public&#13;
    view&#13;
    returns (bool)&#13;
  {&#13;
    return hasRole(_operator, ROLE_WHITELISTED);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev add addresses to the whitelist&#13;
   * @param _operators addresses&#13;
   * @return true if at least one address was added to the whitelist,&#13;
   * false if all addresses were already in the whitelist&#13;
   */&#13;
  function addAddressesToWhitelist(address[] _operators)&#13;
    onlyOwner&#13;
    public&#13;
  {&#13;
    for (uint256 i = 0; i &lt; _operators.length; i++) {&#13;
      addAddressToWhitelist(_operators[i]);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove an address from the whitelist&#13;
   * @param _operator address&#13;
   * @return true if the address was removed from the whitelist,&#13;
   * false if the address wasn't in the whitelist in the first place&#13;
   */&#13;
  function removeAddressFromWhitelist(address _operator)&#13;
    onlyOwner&#13;
    public&#13;
  {&#13;
    removeRole(_operator, ROLE_WHITELISTED);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove addresses from the whitelist&#13;
   * @param _operators addresses&#13;
   * @return true if at least one address was removed from the whitelist,&#13;
   * false if all addresses weren't in the whitelist in the first place&#13;
   */&#13;
  function removeAddressesFromWhitelist(address[] _operators)&#13;
    onlyOwner&#13;
    public&#13;
  {&#13;
    for (uint256 i = 0; i &lt; _operators.length; i++) {&#13;
      removeAddressFromWhitelist(_operators[i]);&#13;
    }&#13;
  }&#13;
&#13;
}&#13;
&#13;
contract MerkleDrops is Pausable, Whitelist {&#13;
&#13;
  bytes32 public rootHash;&#13;
  ERC20 public token;&#13;
  mapping(bytes32 =&gt; bool) public redeemed;&#13;
&#13;
  constructor(bytes32 _rootHash, address _tokenAddress) {&#13;
    rootHash = _rootHash;&#13;
    token = ERC20(_tokenAddress);&#13;
    super.addAddressToWhitelist(msg.sender);&#13;
  }&#13;
&#13;
  function constructLeaf(uint256 index, address recipient, uint256 amount) constant returns(bytes32) {&#13;
    bytes32 node = keccak256(abi.encodePacked(index, recipient, amount));&#13;
    return node;&#13;
  }&#13;
&#13;
  function isProofValid(bytes32[] _proof, bytes32 _node) public constant returns(bool){&#13;
    bool isValid = MerkleProof.verifyProof(_proof, rootHash, _node);&#13;
    return isValid;&#13;
  }&#13;
&#13;
  function redeemTokens(uint256 index , uint256 amount, bytes32[] _proof) whenNotPaused public returns(bool) {&#13;
    bytes32 node = constructLeaf(index, msg.sender, amount);&#13;
    require(!redeemed[node]);&#13;
    require(isProofValid(_proof, node));&#13;
    redeemed[node] = true;&#13;
    token.transfer(msg.sender, amount);&#13;
  }&#13;
&#13;
  function withdrawTokens(ERC20 _token) public onlyIfWhitelisted(msg.sender) {&#13;
    token.transfer(msg.sender, _token.balanceOf(this));&#13;
  }&#13;
&#13;
  function changeRoot(bytes32 _rootHash) public onlyIfWhitelisted(msg.sender) {&#13;
    rootHash = _rootHash;&#13;
  }&#13;
}