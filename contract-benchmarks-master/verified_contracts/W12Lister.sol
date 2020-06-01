pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
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

// File: openzeppelin-solidity/contracts/ReentrancyGuard.sol

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b0c2d5ddd3dff082">[email protected]</a>π.com&gt;, Eenae &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="650409001d001c25080c1d071c1100164b0c0a">[email protected]</a>&gt;&#13;
 * @dev If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.&#13;
  /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056&#13;
  uint private constant REENTRANCY_GUARD_FREE = 1;&#13;
&#13;
  /// @dev Constant for locked guard state&#13;
  uint private constant REENTRANCY_GUARD_LOCKED = 2;&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  uint private reentrancyLock = REENTRANCY_GUARD_FREE;&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * If you mark a function `nonReentrant`, you should also&#13;
   * mark it `external`. Calling one `nonReentrant` function from&#13;
   * another is not supported. Instead, you can implement a&#13;
   * `private` function doing the actual work, and an `external`&#13;
   * wrapper marked as `nonReentrant`.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    require(reentrancyLock == REENTRANCY_GUARD_FREE);&#13;
    reentrancyLock = REENTRANCY_GUARD_LOCKED;&#13;
    _;&#13;
    reentrancyLock = REENTRANCY_GUARD_FREE;&#13;
  }&#13;
&#13;
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
// File: openzeppelin-solidity/contracts/access/rbac/Roles.sol&#13;
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
  function add(Role storage _role, address _addr)&#13;
    internal&#13;
  {&#13;
    _role.bearer[_addr] = true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove an address' access to this role&#13;
   */&#13;
  function remove(Role storage _role, address _addr)&#13;
    internal&#13;
  {&#13;
    _role.bearer[_addr] = false;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev check if an address has this role&#13;
   * // reverts&#13;
   */&#13;
  function check(Role storage _role, address _addr)&#13;
    internal&#13;
    view&#13;
  {&#13;
    require(has(_role, _addr));&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev check if an address has this role&#13;
   * @return bool&#13;
   */&#13;
  function has(Role storage _role, address _addr)&#13;
    internal&#13;
    view&#13;
    returns (bool)&#13;
  {&#13;
    return _role.bearer[_addr];&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/access/rbac/RBAC.sol&#13;
&#13;
/**&#13;
 * @title RBAC (Role-Based Access Control)&#13;
 * @author Matt Condon (@Shrugs)&#13;
 * @dev Stores and provides setters and getters for roles and addresses.&#13;
 * Supports unlimited numbers of roles and addresses.&#13;
 * See //contracts/mocks/RBACMock.sol for an example of usage.&#13;
 * This RBAC method uses strings to key roles. It may be beneficial&#13;
 * for you to write your own implementation of this interface using Enums or similar.&#13;
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
    public&#13;
    view&#13;
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
    public&#13;
    view&#13;
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
// File: openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol&#13;
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
// File: contracts/token/WToken.sol&#13;
&#13;
contract WToken is DetailedERC20, Ownable {&#13;
    using SafeMath for uint256;&#13;
&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;&#13;
&#13;
    mapping(address =&gt; uint256) public balances;&#13;
&#13;
    uint256 private _totalSupply;&#13;
&#13;
    mapping (address =&gt; mapping (uint256 =&gt; uint256)) public vestingBalanceOf;&#13;
&#13;
    mapping (address =&gt; uint[]) vestingTimes;&#13;
&#13;
    mapping (address =&gt; bool) trustedAccounts;&#13;
&#13;
    event VestingTransfer(address from, address to, uint256 value, uint256 agingTime);&#13;
    event Burn(address indexed burner, uint256 value);&#13;
&#13;
    /**&#13;
    * @dev total number of tokens in existence&#13;
    */&#13;
    function totalSupply() public view returns (uint256) {&#13;
        return _totalSupply;&#13;
    }&#13;
&#13;
    constructor(string _name, string _symbol, uint8 _decimals) DetailedERC20(_name, _symbol, _decimals) public {&#13;
        trustedAccounts[msg.sender] = true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev transfer token for a specified address&#13;
    * @param _to The address to transfer to.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        _checkMyVesting(msg.sender);&#13;
        require(_to != address(0));&#13;
        require(_value &lt;= accountBalance(msg.sender));&#13;
&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
&#13;
        balances[_to] = balances[_to].add(_value);&#13;
&#13;
        emit Transfer(msg.sender, _to, _value);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    function vestingTransfer(address _to, uint256 _value, uint32 _vestingTime) external onlyTrusted(msg.sender) returns (bool) {&#13;
        transfer(_to, _value);&#13;
&#13;
        if (_vestingTime &gt; now) {&#13;
            _addToVesting(address(0), _to, _vestingTime, _value);&#13;
        }&#13;
&#13;
        emit VestingTransfer(msg.sender, _to, _value, _vestingTime);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Gets the balance of the specified address.&#13;
    * @param _owner The address to query the the balance of.&#13;
    * @return An uint256 representing the amount owned by the passed address.&#13;
    */&#13;
    function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
        return balances[_owner];&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Transfer tokens from one address to another&#13;
    * @param _from address The address which you want to send tokens from&#13;
    * @param _to address The address which you want to transfer to&#13;
    * @param _value uint256 the amount of tokens to be transferred&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        _checkMyVesting(_from);&#13;
&#13;
        require(_to != address(0));&#13;
        require(_value &lt;= accountBalance(_from));&#13;
        require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
&#13;
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
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
    * @param _owner address The address which owns the funds.&#13;
    * @param _spender address The address which will spend the funds.&#13;
    * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
    */&#13;
    function allowance(address _owner, address _spender) public view returns (uint256) {&#13;
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
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
&#13;
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
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {&#13;
        uint oldValue = allowed[msg.sender][_spender];&#13;
        if (_subtractedValue &gt;= oldValue) {&#13;
            allowed[msg.sender][_spender] = 0;&#13;
        } else {&#13;
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
        }&#13;
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    function mint(address _to, uint _amount, uint32 _vestingTime) external onlyTrusted(msg.sender) returns (bool) {&#13;
        balances[_to] = balances[_to].add(_amount);&#13;
        _totalSupply = _totalSupply.add(_amount);&#13;
&#13;
        if (_vestingTime &gt; now) {&#13;
            _addToVesting(address(0), _to, _vestingTime, _amount);&#13;
        }&#13;
&#13;
        emit Transfer(address(0), _to, _amount);&#13;
        emit VestingTransfer(address(0), _to, _amount, _vestingTime);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    function _addToVesting(address _from, address _to, uint256 _vestingTime, uint256 _amount) internal {&#13;
        vestingBalanceOf[_to][0] = vestingBalanceOf[_to][0].add(_amount);&#13;
&#13;
        if(vestingBalanceOf[_to][_vestingTime] == 0)&#13;
            vestingTimes[_to].push(_vestingTime);&#13;
&#13;
        vestingBalanceOf[_to][_vestingTime] = vestingBalanceOf[_to][_vestingTime].add(_amount);&#13;
    }&#13;
&#13;
    /**&#13;
      * @dev Burns a specific amount of tokens.&#13;
      * @param _value The amount of token to be burned.&#13;
      */&#13;
    function burn(uint256 _value) public {&#13;
        _burn(msg.sender, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Burns a specific amount of tokens from the target address and decrements allowance&#13;
     * @param _from address The address which you want to send tokens from&#13;
     * @param _value uint256 The amount of token to be burned&#13;
     */&#13;
    function burnFrom(address _from, uint256 _value) public {&#13;
        require(_value &lt;= allowed[_from][msg.sender]);&#13;
        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,&#13;
        // this function needs to emit an event with the updated approval.&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
        _burn(_from, _value);&#13;
    }&#13;
&#13;
    function _burn(address _who, uint256 _value) internal {&#13;
        _checkMyVesting(_who);&#13;
&#13;
        require(_value &lt;= accountBalance(_who));&#13;
        // no need to require value &lt;= totalSupply, since that would imply the&#13;
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure&#13;
&#13;
        balances[_who] = balances[_who].sub(_value);&#13;
        _totalSupply = _totalSupply.sub(_value);&#13;
        emit Burn(_who, _value);&#13;
        emit Transfer(_who, address(0), _value);&#13;
    }&#13;
&#13;
    function _checkMyVesting(address _from) internal {&#13;
        if (vestingBalanceOf[_from][0] == 0) return;&#13;
&#13;
        for (uint256 k = 0; k &lt; vestingTimes[_from].length; k++) {&#13;
            if (vestingTimes[_from][k] &lt; now) {&#13;
                vestingBalanceOf[_from][0] = vestingBalanceOf[_from][0]&#13;
                    .sub(vestingBalanceOf[_from][vestingTimes[_from][k]]);&#13;
                vestingBalanceOf[_from][vestingTimes[_from][k]] = 0;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function accountBalance(address _address) public view returns (uint256 balance) {&#13;
        balance = balances[_address];&#13;
&#13;
        if (vestingBalanceOf[_address][0] == 0) return;&#13;
&#13;
        for (uint256 k = 0; k &lt; vestingTimes[_address].length; k++) {&#13;
            if (vestingTimes[_address][k] &gt;= now) {&#13;
                balance = balance.sub(vestingBalanceOf[_address][vestingTimes[_address][k]]);&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function addTrustedAccount(address caller) external onlyOwner {&#13;
        trustedAccounts[caller] = true;&#13;
    }&#13;
&#13;
    function removeTrustedAccount(address caller) external onlyOwner {&#13;
        trustedAccounts[caller] = false;&#13;
    }&#13;
&#13;
    modifier onlyTrusted(address caller) {&#13;
        require(trustedAccounts[caller]);&#13;
        _;&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/interfaces/IW12Crowdsale.sol&#13;
&#13;
interface IW12Crowdsale {&#13;
    function setParameters(uint price) external;&#13;
&#13;
    // TODO: this should be external&#13;
    // See https://github.com/ethereum/solidity/issues/4832&#13;
    function setup(&#13;
        uint[6][] parametersOfStages,&#13;
        uint[] bonusConditionsOfStages,&#13;
        uint[4][] parametersOfMilestones,&#13;
        uint32[] nameAndDescriptionsOffsetOfMilestones,&#13;
        bytes nameAndDescriptionsOfMilestones&#13;
    ) external;&#13;
&#13;
    function getWToken() external view returns(WToken);&#13;
&#13;
    function getMilestone(uint index) external view returns (uint32, uint, uint32, uint32, bytes, bytes);&#13;
&#13;
    function getStage(uint index) external view returns (uint32, uint32, uint, uint32, uint[], uint[]);&#13;
&#13;
    function getCurrentMilestoneIndex() external view returns (uint, bool);&#13;
&#13;
    function getLastMilestoneIndex() external view returns (uint index, bool found);&#13;
&#13;
    function milestonesLength() external view returns (uint);&#13;
&#13;
    function getCurrentStageIndex() external view returns (uint index, bool found);&#13;
&#13;
    function getSaleVolumeBonus(uint value) external view returns (uint bonus);&#13;
&#13;
    function isEnded() external view returns (bool);&#13;
&#13;
    function isSaleActive() external view returns (bool);&#13;
&#13;
    function () payable external;&#13;
&#13;
    function buyTokens() payable external;&#13;
&#13;
    function transferOwnership(address newOwner) external;&#13;
}&#13;
&#13;
// File: contracts/interfaces/IW12CrowdsaleFactory.sol&#13;
&#13;
interface IW12CrowdsaleFactory {&#13;
    function createCrowdsale(&#13;
        address tokenAddress,&#13;
        address _wTokenAddress,&#13;
        uint price,&#13;
        address serviceWallet,&#13;
        uint serviceFee,&#13;
        uint WTokenSaleFeePercent,&#13;
        uint trancheFeePercent ,&#13;
        address swap,&#13;
        address owner&#13;
    )&#13;
        external returns (IW12Crowdsale);&#13;
}&#13;
&#13;
// File: contracts/libs/Percent.sol&#13;
&#13;
library Percent {&#13;
    using SafeMath for uint;&#13;
&#13;
    function ADD_EXP() public pure returns (uint) { return 2; }&#13;
    function EXP() public pure returns (uint) { return 2 + ADD_EXP(); }&#13;
    function MIN() public pure returns (uint) { return 0; }&#13;
    function MAX() public pure returns (uint) { return 10 ** EXP(); }&#13;
&#13;
    function percent(uint _a, uint _b) internal pure returns (uint) {&#13;
        require(isPercent(_b));&#13;
&#13;
        return _a.mul(_b).div(MAX());&#13;
    }&#13;
&#13;
    function isPercent(uint _a) internal pure returns (bool) {&#13;
        return _a &gt;= MIN() &amp;&amp; _a &lt;= MAX();&#13;
    }&#13;
&#13;
    function toPercent(uint _a) internal pure returns (uint) {&#13;
        require(_a &lt;= 100);&#13;
&#13;
        return _a.mul(10 ** ADD_EXP());&#13;
    }&#13;
&#13;
    function fromPercent(uint _a) internal pure returns (uint) {&#13;
        require(isPercent(_a));&#13;
&#13;
        return _a.div(10 ** ADD_EXP());&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/token/exchanger/ITokenExchange.sol&#13;
&#13;
contract ITokenExchange {&#13;
    function approve(ERC20 token, address spender, uint amount) external returns (bool);&#13;
&#13;
    function exchange(ERC20 fromToken, uint amount) external;&#13;
}&#13;
&#13;
// File: contracts/token/exchanger/ITokenLedger.sol&#13;
&#13;
contract ITokenLedger {&#13;
    function addTokenToListing(ERC20 token, WToken wToken) external;&#13;
&#13;
    function hasPair(ERC20 token1, ERC20 token2) public view returns (bool);&#13;
&#13;
    function getWTokenByToken(address token) public view returns (WToken wTokenAddress);&#13;
&#13;
    function getTokenByWToken(address wToken) public view returns (ERC20 tokenAddress);&#13;
}&#13;
&#13;
// File: contracts/token/exchanger/ITokenExchanger.sol&#13;
&#13;
contract ITokenExchanger is ITokenExchange, ITokenLedger {}&#13;
&#13;
// File: contracts/versioning/Versionable.sol&#13;
&#13;
contract Versionable {&#13;
    uint public version;&#13;
&#13;
    constructor(uint _version) public {&#13;
        version = _version;&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/W12Lister.sol&#13;
&#13;
contract W12Lister is Versionable, RBAC, Ownable, ReentrancyGuard {&#13;
    using SafeMath for uint;&#13;
    using Percent for uint;&#13;
&#13;
    string public ROLE_ADMIN = "admin";&#13;
&#13;
    ITokenExchanger public exchanger;&#13;
    IW12CrowdsaleFactory public factory;&#13;
    // get token index in approvedTokens list by token address and token owner address&#13;
    mapping (address =&gt; mapping (address =&gt; uint16)) public approvedTokensIndex;&#13;
    ListedToken[] public approvedTokens;&#13;
    // return owners by token address&#13;
    mapping ( address =&gt; address[] ) approvedOwnersList;&#13;
    uint16 public approvedTokensLength;&#13;
    address public serviceWallet;&#13;
&#13;
    event OwnerWhitelisted(address indexed tokenAddress, address indexed tokenOwner, string name, string symbol);&#13;
    event TokenPlaced(address indexed originalTokenAddress, address indexed tokenOwner, uint tokenAmount, address placedTokenAddress);&#13;
    event CrowdsaleInitialized(address indexed tokenAddress, address indexed tokenOwner, uint amountForSale);&#13;
    event CrowdsaleTokenMinted(address indexed tokenAddress, address indexed tokenOwner, uint amount);&#13;
&#13;
    struct ListedToken {&#13;
        string name;&#13;
        string symbol;&#13;
        uint8 decimals;&#13;
        mapping(address =&gt; bool) approvedOwners;&#13;
        uint feePercent;&#13;
        uint ethFeePercent;&#13;
        uint WTokenSaleFeePercent;&#13;
        uint trancheFeePercent;&#13;
        IW12Crowdsale crowdsaleAddress;&#13;
        uint tokensForSaleAmount;&#13;
        uint wTokensIssuedAmount;&#13;
        address tokenAddress;&#13;
    }&#13;
&#13;
    constructor(&#13;
        uint version,&#13;
        address _serviceWallet,&#13;
        IW12CrowdsaleFactory _factory,&#13;
        ITokenExchanger _exchanger&#13;
    ) Versionable(version) public {&#13;
        require(_serviceWallet != address(0));&#13;
        require(_factory != address(0));&#13;
        require(_exchanger != address(0));&#13;
&#13;
        exchanger = _exchanger;&#13;
        serviceWallet = _serviceWallet;&#13;
        factory = _factory;&#13;
        approvedTokens.length++; // zero-index element should never be used&#13;
&#13;
        addRole(msg.sender, ROLE_ADMIN);&#13;
    }&#13;
&#13;
    function addAdmin(address _operator) public onlyOwner {&#13;
        addRole(_operator, ROLE_ADMIN);&#13;
    }&#13;
&#13;
    function removeAdmin(address _operator) public onlyOwner {&#13;
        removeRole(_operator, ROLE_ADMIN);&#13;
    }&#13;
&#13;
    function whitelistToken(&#13;
        address tokenOwner,&#13;
        address tokenAddress,&#13;
        string name,&#13;
        string symbol,&#13;
        uint8 decimals,&#13;
        uint feePercent,&#13;
        uint ethFeePercent,&#13;
        uint WTokenSaleFeePercent,&#13;
        uint trancheFeePercent&#13;
    )&#13;
        external onlyRole(ROLE_ADMIN)&#13;
    {&#13;
&#13;
        require(tokenOwner != address(0));&#13;
        require(tokenAddress != address(0));&#13;
        require(feePercent.isPercent() &amp;&amp; feePercent.fromPercent() &lt; 100);&#13;
        require(ethFeePercent.isPercent() &amp;&amp; ethFeePercent.fromPercent() &lt; 100);&#13;
        require(WTokenSaleFeePercent.isPercent() &amp;&amp; WTokenSaleFeePercent.fromPercent() &lt; 100);&#13;
        require(trancheFeePercent.isPercent() &amp;&amp; trancheFeePercent.fromPercent() &lt; 100);&#13;
        require(getApprovedToken(tokenAddress, tokenOwner).tokenAddress != tokenAddress);&#13;
        require(!getApprovedToken(tokenAddress, tokenOwner).approvedOwners[tokenOwner]);&#13;
&#13;
        uint16 index = uint16(approvedTokens.length);&#13;
&#13;
        approvedTokensIndex[tokenAddress][tokenOwner] = index;&#13;
&#13;
        approvedTokensLength = uint16(approvedTokens.length++);&#13;
&#13;
        approvedOwnersList[tokenAddress].push(tokenOwner);&#13;
&#13;
        approvedTokens[index].approvedOwners[tokenOwner] = true;&#13;
        approvedTokens[index].name = name;&#13;
        approvedTokens[index].symbol = symbol;&#13;
        approvedTokens[index].decimals = decimals;&#13;
        approvedTokens[index].feePercent = feePercent;&#13;
        approvedTokens[index].ethFeePercent = ethFeePercent;&#13;
        approvedTokens[index].WTokenSaleFeePercent = WTokenSaleFeePercent;&#13;
        approvedTokens[index].trancheFeePercent = trancheFeePercent;&#13;
        approvedTokens[index].tokenAddress = tokenAddress;&#13;
&#13;
        emit OwnerWhitelisted(tokenAddress, tokenOwner, name, symbol);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Place token for sale&#13;
     * @param tokenAddress Token that will be placed&#13;
     * @param amount Token amount to place&#13;
     */&#13;
    function placeToken(address tokenAddress, uint amount) external nonReentrant {&#13;
        require(amount &gt; 0);&#13;
        require(tokenAddress != address(0));&#13;
        require(getApprovedToken(tokenAddress, msg.sender).tokenAddress == tokenAddress);&#13;
        require(getApprovedToken(tokenAddress, msg.sender).approvedOwners[msg.sender]);&#13;
&#13;
        DetailedERC20 token = DetailedERC20(tokenAddress);&#13;
&#13;
        require(token.allowance(msg.sender, address(this)) &gt;= amount);&#13;
&#13;
        ListedToken storage listedToken = getApprovedToken(tokenAddress, msg.sender);&#13;
&#13;
        require(token.decimals() == listedToken.decimals);&#13;
&#13;
        uint fee = listedToken.feePercent &gt; 0&#13;
            ? amount.percent(listedToken.feePercent)&#13;
            : 0;&#13;
        uint amountWithoutFee = amount.sub(fee);&#13;
&#13;
        _secureTokenTransfer(token, exchanger, amountWithoutFee);&#13;
        _secureTokenTransfer(token, serviceWallet, fee);&#13;
&#13;
        listedToken.tokensForSaleAmount = listedToken.tokensForSaleAmount.add(amountWithoutFee);&#13;
&#13;
        if (exchanger.getWTokenByToken(tokenAddress) == address(0)) {&#13;
            WToken wToken = new WToken(listedToken.name, listedToken.symbol, listedToken.decimals);&#13;
&#13;
            exchanger.addTokenToListing(ERC20(tokenAddress), wToken);&#13;
        }&#13;
&#13;
        emit TokenPlaced(tokenAddress, msg.sender, amountWithoutFee, exchanger.getWTokenByToken(tokenAddress));&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Securely transfer token from sender to account&#13;
     */&#13;
    function _secureTokenTransfer(ERC20 token, address to, uint value) internal {&#13;
        // check for overflow before. we are not sure that the placed token has implemented save math&#13;
        uint expectedBalance = token.balanceOf(to).add(value);&#13;
&#13;
        token.transferFrom(msg.sender, to, value);&#13;
&#13;
        // check balance to be sure it was filled correctly&#13;
        assert(token.balanceOf(to) == expectedBalance);&#13;
    }&#13;
&#13;
    function initCrowdsale(address tokenAddress, uint amountForSale, uint price) external nonReentrant {&#13;
        require(getApprovedToken(tokenAddress, msg.sender).approvedOwners[msg.sender] == true);&#13;
        require(getApprovedToken(tokenAddress, msg.sender).tokensForSaleAmount &gt;= getApprovedToken(tokenAddress, msg.sender).wTokensIssuedAmount.add(amountForSale));&#13;
        require(getApprovedToken(tokenAddress, msg.sender).crowdsaleAddress == address(0));&#13;
&#13;
        WToken wtoken = exchanger.getWTokenByToken(tokenAddress);&#13;
&#13;
        IW12Crowdsale crowdsale = factory.createCrowdsale(&#13;
            address(tokenAddress),&#13;
            address(wtoken),&#13;
            price,&#13;
            serviceWallet,&#13;
            getApprovedToken(tokenAddress, msg.sender).ethFeePercent,&#13;
            getApprovedToken(tokenAddress, msg.sender).WTokenSaleFeePercent,&#13;
            getApprovedToken(tokenAddress, msg.sender).trancheFeePercent,&#13;
            exchanger,&#13;
            msg.sender&#13;
        );&#13;
&#13;
        getApprovedToken(tokenAddress, msg.sender).crowdsaleAddress = crowdsale;&#13;
        wtoken.addTrustedAccount(crowdsale);&#13;
&#13;
        if (getApprovedToken(tokenAddress, msg.sender).WTokenSaleFeePercent &gt; 0) {&#13;
            exchanger.approve(&#13;
                ERC20(tokenAddress),&#13;
                address(crowdsale),&#13;
                getApprovedToken(tokenAddress, msg.sender).tokensForSaleAmount&#13;
                    .percent(getApprovedToken(tokenAddress, msg.sender).WTokenSaleFeePercent)&#13;
            );&#13;
        }&#13;
&#13;
        addTokensToCrowdsale(tokenAddress, amountForSale);&#13;
&#13;
        emit CrowdsaleInitialized(tokenAddress, msg.sender, amountForSale);&#13;
    }&#13;
&#13;
    function addTokensToCrowdsale(address tokenAddress, uint amountForSale) public {&#13;
        require(amountForSale &gt; 0);&#13;
        require(tokenAddress != address(0));&#13;
        require(exchanger.getWTokenByToken(tokenAddress) != address(0));&#13;
        require(getApprovedToken(tokenAddress, msg.sender).crowdsaleAddress != address(0));&#13;
        require(getApprovedToken(tokenAddress, msg.sender).approvedOwners[msg.sender] == true);&#13;
        require(getApprovedToken(tokenAddress, msg.sender).tokensForSaleAmount &gt;= getApprovedToken(tokenAddress, msg.sender).wTokensIssuedAmount.add(amountForSale));&#13;
&#13;
        WToken token = exchanger.getWTokenByToken(tokenAddress);&#13;
        IW12Crowdsale crowdsale = getApprovedToken(tokenAddress, msg.sender).crowdsaleAddress;&#13;
&#13;
        getApprovedToken(tokenAddress, msg.sender).wTokensIssuedAmount = getApprovedToken(tokenAddress, msg.sender)&#13;
            .wTokensIssuedAmount.add(amountForSale);&#13;
&#13;
        token.mint(crowdsale, amountForSale, 0);&#13;
&#13;
        emit CrowdsaleTokenMinted(tokenAddress, msg.sender, amountForSale);&#13;
    }&#13;
&#13;
    function getTokenCrowdsale(address tokenAddress, address ownerAddress) view external returns (address) {&#13;
        return getApprovedToken(tokenAddress, ownerAddress).crowdsaleAddress;&#13;
    }&#13;
&#13;
    function getTokenOwners(address token) public view returns (address[]) {&#13;
        return approvedOwnersList[token];&#13;
    }&#13;
&#13;
    function getExchanger() view external returns (ITokenExchanger) {&#13;
        return exchanger;&#13;
    }&#13;
&#13;
    function getApprovedToken(address tokenAddress, address ownerAddress) internal view returns (ListedToken storage result) {&#13;
        return approvedTokens[approvedTokensIndex[tokenAddress][ownerAddress]];&#13;
    }&#13;
}