pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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


contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

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
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

  function Destructible() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}

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

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="85f7e0e8e6eac5b7">[email protected]</span>π.com&gt;&#13;
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
/**&#13;
 * @title DelayedClaimable&#13;
 * @dev Extension for the Claimable contract, where the ownership needs to be claimed before/after&#13;
 * a certain block number.&#13;
 */&#13;
contract DelayedClaimable is Claimable {&#13;
&#13;
  uint256 public end;&#13;
  uint256 public start;&#13;
&#13;
  /**&#13;
   * @dev Used to specify the time period during which a pending&#13;
   * owner can claim ownership.&#13;
   * @param _start The earliest time ownership can be claimed.&#13;
   * @param _end The latest time ownership can be claimed.&#13;
   */&#13;
  function setLimits(uint256 _start, uint256 _end) onlyOwner public {&#13;
    require(_start &lt;= _end);&#13;
    end = _end;&#13;
    start = _start;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Allows the pendingOwner address to finalize the transfer, as long as it is called within&#13;
   * the specified start and end time.&#13;
   */&#13;
  function claimOwnership() onlyPendingOwner public {&#13;
    require((block.number &lt;= end) &amp;&amp; (block.number &gt;= start));&#13;
    OwnershipTransferred(owner, pendingOwner);&#13;
    owner = pendingOwner;&#13;
    pendingOwner = address(0);&#13;
    end = 0;&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Contracts that should not own Contracts&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="f88a9d959b97b8ca">[email protected]</span>π.com&gt;&#13;
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
&#13;
/**&#13;
 * @title Roles&#13;
 * @author Francisco Giordano (@frangio)&#13;
 * @dev Library for managing addresses assigned to a Role.&#13;
 *      See RBAC.sol for example usage.&#13;
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
&#13;
/**&#13;
 * @title RBAC (Role-Based Access Control)&#13;
 * @author Matt Condon (@Shrugs)&#13;
 * @dev Stores and provides setters and getters for roles and addresses.&#13;
 *      Supports unlimited numbers of roles and addresses.&#13;
 *      See //contracts/examples/RBACExample.sol for an example of usage.&#13;
 * This RBAC method uses strings to key roles. It may be beneficial&#13;
 *  for you to write your own implementation of this interface using Enums or similar.&#13;
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,&#13;
 *  to avoid typos.&#13;
 */&#13;
contract RBAC {&#13;
    using Roles for Roles.Role;&#13;
&#13;
    mapping (string =&gt; Roles.Role) private roles;&#13;
&#13;
    event RoleAdded(address addr, string roleName);&#13;
    event RoleRemoved(address addr, string roleName);&#13;
&#13;
    /**&#13;
     * A constant role name for indicating admins.&#13;
     */&#13;
    string public constant ROLE_ADMIN = "admin";&#13;
&#13;
    /**&#13;
     * @dev constructor. Sets msg.sender as admin by default&#13;
     */&#13;
    function RBAC()&#13;
        public&#13;
    {&#13;
        addRole(msg.sender, ROLE_ADMIN);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev add a role to an address&#13;
     * @param addr address&#13;
     * @param roleName the name of the role&#13;
     */&#13;
    function addRole(address addr, string roleName)&#13;
        internal&#13;
    {&#13;
        roles[roleName].add(addr);&#13;
        RoleAdded(addr, roleName);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev remove a role from an address&#13;
     * @param addr address&#13;
     * @param roleName the name of the role&#13;
     */&#13;
    function removeRole(address addr, string roleName)&#13;
        internal&#13;
    {&#13;
        roles[roleName].remove(addr);&#13;
        RoleRemoved(addr, roleName);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev reverts if addr does not have role&#13;
     * @param addr address&#13;
     * @param roleName the name of the role&#13;
     * // reverts&#13;
     */&#13;
    function checkRole(address addr, string roleName)&#13;
        // view&#13;
        public&#13;
    {&#13;
        roles[roleName].check(addr);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev determine if addr has role&#13;
     * @param addr address&#13;
     * @param roleName the name of the role&#13;
     * @return bool&#13;
     */&#13;
    function hasRole(address addr, string roleName)&#13;
        view&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        return roles[roleName].has(addr);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev add a role to an address&#13;
     * @param addr address&#13;
     * @param roleName the name of the role&#13;
     */&#13;
    function adminAddRole(address addr, string roleName)&#13;
        onlyAdmin&#13;
        public&#13;
    {&#13;
        addRole(addr, roleName);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev remove a role from an address&#13;
     * @param addr address&#13;
     * @param roleName the name of the role&#13;
     */&#13;
    function adminRemoveRole(address addr, string roleName)&#13;
        onlyAdmin&#13;
        public&#13;
    {&#13;
        removeRole(addr, roleName);&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
     * @dev modifier to scope access to a single role (uses msg.sender as addr)&#13;
     * @param roleName the name of the role&#13;
     * // reverts&#13;
     */&#13;
    modifier onlyRole(string roleName)&#13;
    {&#13;
        checkRole(msg.sender, roleName);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev modifier to scope access to admins&#13;
     * // reverts&#13;
     */&#13;
    modifier onlyAdmin()&#13;
    {&#13;
        checkRole(msg.sender, ROLE_ADMIN);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev modifier to scope access to a set of roles (uses msg.sender as addr)&#13;
     * @param roleNames the names of the roles to scope access to&#13;
     * // reverts&#13;
     *&#13;
     * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this&#13;
     *  see: https://github.com/ethereum/solidity/issues/2467&#13;
     */&#13;
    // modifier onlyRoles(string[] roleNames) {&#13;
    //     bool hasAnyRole = false;&#13;
    //     for (uint8 i = 0; i &lt; roleNames.length; i++) {&#13;
    //         if (hasRole(msg.sender, roleNames[i])) {&#13;
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
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="aad8cfc7c9c5ea98">[email protected]</span>π.com&gt;&#13;
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
    from_;&#13;
    value_;&#13;
    data_;&#13;
    revert();&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Contactable token&#13;
 * @dev Basic version of a contactable contract, allowing the owner to provide a string with their&#13;
 * contact information.&#13;
 */&#13;
contract Contactable is Ownable{&#13;
&#13;
    string public contactInformation;&#13;
&#13;
    /**&#13;
     * @dev Allows the owner to set a string with their contact information.&#13;
     * @param info The contact information to attach to the contract.&#13;
     */&#13;
    function setContactInformation(string info) onlyOwner public {&#13;
         contactInformation = info;&#13;
     }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Base contract for contracts that should not own things.&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="3c4e59515f537c0e">[email protected]</span>π.com&gt;&#13;
 * @dev Solves a class of errors where a contract accidentally becomes owner of Ether, Tokens or&#13;
 * Owned contracts. See respective base contracts for details.&#13;
 */&#13;
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title SimpleToken&#13;
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.&#13;
 * Note they can later distribute these tokens as they wish using `transfer` and other&#13;
 * `StandardToken` functions.&#13;
 */&#13;
contract SimpleToken is StandardToken {&#13;
&#13;
  string public constant name = "SimpleToken";&#13;
  string public constant symbol = "SIM";&#13;
  uint8 public constant decimals = 18;&#13;
&#13;
  uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));&#13;
&#13;
  /**&#13;
   * @dev Constructor that gives msg.sender all of existing tokens.&#13;
   */&#13;
  function SimpleToken() public {&#13;
    totalSupply = INITIAL_SUPPLY;&#13;
    balances[msg.sender] = INITIAL_SUPPLY;&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Pausable token&#13;
 *&#13;
 * @dev StandardToken modified with pausable transfers.&#13;
 **/&#13;
&#13;
contract PausableToken is StandardToken, Pausable {&#13;
&#13;
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.transfer(_to, _value);&#13;
  }&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.approve(_spender, _value);&#13;
  }&#13;
&#13;
  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {&#13;
    return super.increaseApproval(_spender, _addedValue);&#13;
  }&#13;
&#13;
  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {&#13;
    return super.decreaseApproval(_spender, _subtractedValue);&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Migrations&#13;
 * @dev This is a truffle contract, needed for truffle integration, not meant for use by Zeppelin users.&#13;
 */&#13;
contract Migrations is Ownable {&#13;
  uint256 public lastCompletedMigration;&#13;
&#13;
  function setCompleted(uint256 completed) onlyOwner public {&#13;
    lastCompletedMigration = completed;&#13;
  }&#13;
&#13;
  function upgrade(address newAddress) onlyOwner public {&#13;
    Migrations upgraded = Migrations(newAddress);&#13;
    upgraded.setCompleted(lastCompletedMigration);&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title TokenDestructible:&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="3b495e5658547b09">[email protected]</span>π.com&gt;&#13;
 * @dev Base contract that can be destroyed by owner. All funds in contract including&#13;
 * listed tokens will be sent to the owner.&#13;
 */&#13;
contract TokenDestructible is Ownable {&#13;
&#13;
  function TokenDestructible() public payable { }&#13;
&#13;
  /**&#13;
   * @notice Terminate contract and refund to owner&#13;
   * @param tokens List of addresses of ERC20 or ERC20Basic token contracts to&#13;
   refund.&#13;
   * @notice The called token contracts could try to re-enter this contract. Only&#13;
   supply token contracts you trust.&#13;
   */&#13;
  function destroy(address[] tokens) onlyOwner public {&#13;
&#13;
    // Transfer tokens to owner&#13;
    for(uint256 i = 0; i &lt; tokens.length; i++) {&#13;
      ERC20Basic token = ERC20Basic(tokens[i]);&#13;
      uint256 balance = token.balanceOf(this);&#13;
      token.transfer(owner, balance);&#13;
    }&#13;
&#13;
    // Transfer Eth to owner and terminate contract&#13;
    selfdestruct(owner);&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Mintable token&#13;
 * @dev Simple ERC20 Token example, with mintable token creation&#13;
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120&#13;
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol&#13;
 */&#13;
&#13;
contract MintableToken is StandardToken, Ownable {&#13;
  event Mint(address indexed to, uint256 amount);&#13;
  event MintFinished();&#13;
&#13;
  bool public mintingFinished = false;&#13;
&#13;
&#13;
  modifier canMint() {&#13;
    require(!mintingFinished);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to mint tokens&#13;
   * @param _to The address that will receive the minted tokens.&#13;
   * @param _amount The amount of tokens to mint.&#13;
   * @return A boolean that indicates if the operation was successful.&#13;
   */&#13;
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {&#13;
    totalSupply = totalSupply.add(_amount);&#13;
    balances[_to] = balances[_to].add(_amount);&#13;
    Mint(_to, _amount);&#13;
    Transfer(address(0), _to, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to stop minting new tokens.&#13;
   * @return True if the operation was successful.&#13;
   */&#13;
  function finishMinting() onlyOwner canMint public returns (bool) {&#13;
    mintingFinished = true;&#13;
    MintFinished();&#13;
    return true;&#13;
  }&#13;
}&#13;
/**&#13;
 * @title Capped token&#13;
 * @dev Mintable token with a token cap.&#13;
 */&#13;
&#13;
contract CappedToken is MintableToken {&#13;
&#13;
  uint256 public cap;&#13;
&#13;
  function CappedToken(uint256 _cap) public {&#13;
    require(_cap &gt; 0);&#13;
    cap = _cap;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to mint tokens&#13;
   * @param _to The address that will receive the minted tokens.&#13;
   * @param _amount The amount of tokens to mint.&#13;
   * @return A boolean that indicates if the operation was successful.&#13;
   */&#13;
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {&#13;
    require(totalSupply.add(_amount) &lt;= cap);&#13;
&#13;
    return super.mint(_to, _amount);&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
// @title Force Ether into a contract.&#13;
// @notice  even&#13;
// if the contract is not payable.&#13;
// @notice To use, construct the contract with the target as argument.&#13;
// @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="3143545c525e715f544457445f551f5e4356">[email protected]</span>&gt;&#13;
contract ForceEther  {&#13;
&#13;
  function ForceEther() public payable { }&#13;
&#13;
  function destroyAndSend(address _recipient) public {&#13;
    selfdestruct(_recipient);&#13;
  }&#13;
}&#13;
&#13;
interface Gateway {&#13;
	function open(uint _introId, uint _bid, uint _creationTime, string _hashedInfo) public;&#13;
	function accept(uint _introId, address _ambassador, uint _updateTime) public;&#13;
	function endorse(uint _introId, uint _updateTime) public;&#13;
	function dispute(uint _introId, uint _updateTime) public;&#13;
	function withdraw(uint _introId, uint _updateTime) public;&#13;
	function resolve(uint _introId, uint _updateTime, string _resolution, bool _isSpam) public;&#13;
}&#13;
&#13;
interface Score {&#13;
	function setScore(address user, uint score) public;&#13;
	function getScore(address user) public view returns (uint score);&#13;
	function scoreDown(address user) public returns (bool res);&#13;
	function scoreUp(address user) public returns (bool res);&#13;
}&#13;
&#13;
interface Share {&#13;
	function rolloutDividends(address receiver) public;&#13;
	function distributeDividends(address receiver, uint tokensPerShare) public;&#13;
}&#13;
&#13;
contract InbotProxy is RBAC, Pausable {&#13;
	MintableToken	token;&#13;
	MintableToken	share;&#13;
	Score 			score;&#13;
	Gateway 		gateway;&#13;
&#13;
	function InbotProxy(&#13;
		address _token, &#13;
		address _share, &#13;
		address _score, &#13;
		address _gateway&#13;
	) public &#13;
	{&#13;
		token = MintableToken(_token);&#13;
		share = MintableToken(_share);&#13;
		score = Score(_score);&#13;
		gateway = Gateway(_gateway);&#13;
	}&#13;
&#13;
	function setToken(address _token) public onlyAdmin {&#13;
		token = MintableToken(_token);&#13;
	}&#13;
&#13;
	function getToken() whenNotPaused public view returns (MintableToken) {&#13;
		return token;&#13;
	}&#13;
&#13;
	function setShare(address _share) public onlyAdmin {&#13;
		share = MintableToken(_share);&#13;
	}&#13;
&#13;
	function getShare() whenNotPaused public view returns (MintableToken) {&#13;
		return share;&#13;
	}&#13;
&#13;
	function setScore(address _score) public onlyAdmin {&#13;
		score = Score(_score);&#13;
	}&#13;
&#13;
	function getScore() public whenNotPaused view returns (Score) {&#13;
		return score;&#13;
	}&#13;
&#13;
	function setGateway(address _gateway) public onlyAdmin {&#13;
		gateway = Gateway(_gateway);&#13;
	}&#13;
&#13;
	function getgateway() whenNotPaused public view returns (Gateway) {&#13;
		return gateway;&#13;
	}&#13;
}&#13;
&#13;
contract InbotControlled is RBAC {&#13;
    /**&#13;
     * A constant role name for indicating vendor.&#13;
     */&#13;
    string public constant ROLE_VENDOR = "vendor";&#13;
}&#13;
&#13;
contract InbotContract is InbotControlled, TokenDestructible, CanReclaimToken, Pausable {&#13;
    using SafeMath for uint;&#13;
&#13;
    uint public constant WAD = 10**18;&#13;
    uint public constant RAY = 10**27;&#13;
    InbotProxy public proxy;&#13;
&#13;
    modifier proxyExists() {&#13;
        require(proxy != address(0x0));&#13;
        _;&#13;
    }&#13;
&#13;
    function setProxy(address _proxy) public onlyAdmin {&#13;
        proxy = InbotProxy(_proxy);&#13;
    }&#13;
&#13;
    function reclaimToken() public proxyExists onlyOwner {&#13;
        this.reclaimToken(proxy.getToken());&#13;
    }&#13;
&#13;
    function pause() public onlyAdmin whenNotPaused {&#13;
        paused = true;&#13;
        Pause();&#13;
    }&#13;
&#13;
    function unpause() public onlyAdmin whenPaused {&#13;
        paused = false;&#13;
        Unpause();&#13;
    }&#13;
&#13;
    function getTime(uint _time) internal view returns (uint t) {&#13;
        return _time == 0 ? now : _time;&#13;
    }&#13;
&#13;
    function min(uint x, uint y) internal pure returns (uint z) {&#13;
        return x &lt;= y ? x : y;&#13;
    }&#13;
&#13;
    function max(uint x, uint y) internal pure returns (uint z) {&#13;
        return x &gt;= y ? x : y;&#13;
    }&#13;
&#13;
    function wmul(uint x, uint y) internal pure returns (uint z) {&#13;
        z = x.mul(y).add(WAD.div(2)).div(WAD);&#13;
    }&#13;
&#13;
    function rmul(uint x, uint y) internal pure returns (uint z) {&#13;
        z = x.mul(y).add(RAY.div(2)).div(RAY);&#13;
    }&#13;
&#13;
    function wdiv(uint x, uint y) internal pure returns (uint z) {&#13;
        z = x.mul(WAD).add(y.div(2)).div(y);&#13;
    }&#13;
&#13;
    function rdiv(uint x, uint y) internal pure returns (uint z) {&#13;
        z = x.mul(RAY).add(y.div(2)).div(y);&#13;
    }&#13;
}&#13;
/**&#13;
 * @title Contract that will work with ERC223 tokens.&#13;
 */&#13;
contract ERC223ReceivingContract {&#13;
	event TokenReceived(address indexed from, uint value, bytes data);&#13;
	/**&#13;
	 * @dev Standard ERC223 function that will handle incoming token transfers.&#13;
	 *&#13;
	 * @param _from  Token sender address.&#13;
	 * @param _value Amount of tokens.&#13;
	 * @param _data  Transaction metadata.&#13;
	 */&#13;
    function tokenFallback(address _from, uint _value, bytes _data) public;&#13;
}&#13;
&#13;
 /**&#13;
 * @title Base Contract that will InToken and InShare inherit.&#13;
 */&#13;
contract InbotToken is InbotContract, MintableToken, BurnableToken, PausableToken, DetailedERC20 {&#13;
	event InbotTokenTransfer(address indexed from, address indexed to, uint value, bytes data);&#13;
&#13;
	function InbotToken (string _name, string _symbol, uint8 _decimals) DetailedERC20(_name, _symbol, _decimals) public {&#13;
	}&#13;
&#13;
	function callTokenFallback(address _from, address _to, uint256 _value, bytes _data) internal returns (bool) {&#13;
		uint codeLength;&#13;
&#13;
        assembly {&#13;
            // Retrieve the size of the code on target address, this needs assembly .&#13;
            codeLength := extcodesize(_to)&#13;
        }&#13;
&#13;
        if(codeLength &gt; 0) {&#13;
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);&#13;
            receiver.tokenFallback(_from, _value, _data);&#13;
        }&#13;
&#13;
        InbotTokenTransfer(_from, _to, _value, _data);&#13;
&#13;
        return true;&#13;
	}&#13;
&#13;
	/**&#13;
	* @dev Function which allows to mint tokens from another "admin" address. &#13;
	* @param _to The address that will receive the minted tokens.&#13;
	* @param _amount The amount of tokens to mint.&#13;
	* @return A boolean that indicates if the operation was successful.&#13;
	*/&#13;
	function mint(address _to, uint256 _amount) public onlyAdmin canMint returns (bool) {&#13;
		// TODO: a hook to allow other contracts call "mint" without applying parent modifiers&#13;
		totalSupply = totalSupply.add(_amount);&#13;
		balances[_to] = balances[_to].add(_amount);&#13;
		Mint(_to, _amount);&#13;
		Transfer(address(0), _to, _amount);&#13;
		return true;&#13;
	}&#13;
&#13;
	/**&#13;
	* @dev Transfer the specified amount of ERC223 compliant tokens to the specified address.&#13;
	* @param _from 	The address to transfer from.&#13;
	* @param _to 	The address to transfer to.&#13;
	* @param _value The amount to be transferred.&#13;
	* @param _data  Transaction metadata.&#13;
	* @return A boolean that indicates if the operation was successful.&#13;
	*/&#13;
	function transferFrom(address _from, address _to, uint256 _value, bytes _data) public whenNotPaused returns (bool) {&#13;
		assert(super.transferFrom(_from, _to, _value));&#13;
		return callTokenFallback(_from, _to, _value, _data);&#13;
	}&#13;
&#13;
	/**&#13;
	* @dev Transfer the specified amount of ERC223 compliant tokens to the specified address.&#13;
	* @param _from 	The address to transfer from.&#13;
	* @param _to 	The address to transfer to.&#13;
	* @param _value The amount to be transferred.&#13;
	* @return A boolean that indicates if the operation was successful.&#13;
	*/&#13;
	function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
		bytes memory empty;&#13;
		return transferFrom(_from, _to, _value, empty);&#13;
	}&#13;
&#13;
	/**&#13;
	* @dev Transfer the specified amount of ERC223 compliant tokens to the specified address.&#13;
	* @param _to 	The address to transfer to.&#13;
	* @param _value The amount to be transferred.&#13;
	* @param _data  Transaction metadata.&#13;
	* @return A boolean that indicates if the operation was successful.&#13;
	*/&#13;
	function transfer(address _to, uint256 _value, bytes _data) public whenNotPaused returns (bool) {&#13;
		assert(super.transfer(_to, _value));&#13;
		return callTokenFallback(msg.sender, _to, _value, _data);&#13;
	}&#13;
&#13;
	/**&#13;
     * @dev Transfer the specified amount of ERC223 compliant tokens to the specified address.&#13;
     *      &#13;
     * @param _to    Receiver address.&#13;
     * @param _value Amount of tokens that will be transferred.&#13;
     * @return A boolean that indicates if the operation was successful.&#13;
     */&#13;
    function transfer(address _to, uint _value) public whenNotPaused returns (bool) {&#13;
        bytes memory empty;&#13;
		return transfer(_to, _value, empty);&#13;
    }&#13;
} &#13;
/** &#13;
 * @title InToken (Inbot Token) contract. &#13;
*/&#13;
contract InToken is InbotToken("InToken", "IN", 18) {&#13;
	uint public constant MAX_SUPPLY = 13*RAY;&#13;
&#13;
	function InToken() public {&#13;
	}&#13;
&#13;
	/**&#13;
	* @dev Function to mint tokens upper limited by MAX_SUPPLY.&#13;
	* @param _to The address that will receive the minted tokens.&#13;
	* @param _amount The amount of tokens to mint.&#13;
	* @return A boolean that indicates if the operation was successful.&#13;
	*/&#13;
	function mint(address _to, uint256 _amount) onlyAdmin canMint public returns (bool) {&#13;
		require(totalSupply.add(_amount) &lt;= MAX_SUPPLY);&#13;
&#13;
		return super.mint(_to, _amount);&#13;
	}&#13;
	&#13;
}