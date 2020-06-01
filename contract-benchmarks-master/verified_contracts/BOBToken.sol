pragma solidity ^0.4.18;

/**
 * Bob's Repair Token
 * https://bobsrepair.com/
 * Using Blockchain to eliminate review fraud and provide lower pricing in the home repair industry through a decentralized platform.
 */

//=== OpenZeppelin Library Contracts https://github.com/OpenZeppelin/zeppelin-solidity ===

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
   @title ERC827 interface, an extension of ERC20 token standard

   Interface of a ERC827 token, following the ERC20 standard with extra
   methods to transfer value and data and execute calls in transfers and
   approvals.
 */
contract ERC827 is ERC20 {

  function approve( address _spender, uint256 _value, bytes _data ) public returns (bool);
  function transfer( address _to, uint256 _value, bytes _data ) public returns (bool);
  function transferFrom( address _from, address _to, uint256 _value, bytes _data ) public returns (bool);

}

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
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

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
   @title ERC827, an extension of ERC20 token standard

   Implementation the ERC827, following the ERC20 standard with extra
   methods to transfer value and data and execute calls in transfers and
   approvals.
   Uses OpenZeppelin StandardToken.
 */
contract ERC827Token is ERC827, StandardToken {

  /**
     @dev Addition to ERC20 token methods. It allows to
     approve the transfer of value and execute a call with the sent data.

     Beware that changing an allowance with this method brings the risk that
     someone may use both the old and the new allowance by unfortunate
     transaction ordering. One possible solution to mitigate this race condition
     is to first reduce the spender's allowance to 0 and set the desired value
     afterwards:
     https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     @param _spender The address that will spend the funds.
     @param _value The amount of tokens to be spent.
     @param _data ABI-encoded contract call to call `_to` address.

     @return true if the call function was executed successfully
   */
  function approve(address _spender, uint256 _value, bytes _data) public returns (bool) {
    require(_spender != address(this));

    super.approve(_spender, _value);

    require(_spender.call(_data));

    return true;
  }

  /**
     @dev Addition to ERC20 token methods. Transfer tokens to a specified
     address and execute a call with the sent data on the same transaction

     @param _to address The address which you want to transfer to
     @param _value uint256 the amout of tokens to be transfered
     @param _data ABI-encoded contract call to call `_to` address.

     @return true if the call function was executed successfully
   */
  function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
    require(_to != address(this));

    super.transfer(_to, _value);

    require(_to.call(_data));
    return true;
  }

  /**
     @dev Addition to ERC20 token methods. Transfer tokens from one address to
     another and make a contract call on the same transaction

     @param _from The address which you want to send tokens from
     @param _to The address which you want to transfer to
     @param _value The amout of tokens to be transferred
     @param _data ABI-encoded contract call to call `_to` address.

     @return true if the call function was executed successfully
   */
  function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {
    require(_to != address(this));

    super.transferFrom(_from, _to, _value);

    require(_to.call(_data));
    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Increase the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function increaseApproval(address _spender, uint _addedValue, bytes _data) public returns (bool) {
    require(_spender != address(this));

    super.increaseApproval(_spender, _addedValue);

    require(_spender.call(_data));

    return true;
  }

  /**
   * @dev Addition to StandardToken methods. Decrease the amount of tokens that
   * an owner allowed to a spender and execute a call with the sent data.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   * @param _data ABI-encoded contract call to call `_spender` address.
   */
  function decreaseApproval(address _spender, uint _subtractedValue, bytes _data) public returns (bool) {
    require(_spender != address(this));

    super.decreaseApproval(_spender, _subtractedValue);

    require(_spender.call(_data));

    return true;
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
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
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
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="b9cbdcd4dad6f98b">[email protected]</span>π.com&gt;&#13;
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
 * @title Contracts that should not own Contracts&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="c1b3a4aca2ae81f3">[email protected]</span>π.com&gt;&#13;
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
/**&#13;
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="a2d0c7cfc1cde290">[email protected]</span>π.com&gt;&#13;
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
  function tokenFallback(address from_, uint256 value_, bytes data_) pure external {&#13;
    from_;&#13;
    value_;&#13;
    data_;&#13;
    revert();&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Base contract for contracts that should not own things.&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="44362129272b0476">[email protected]</span>π.com&gt;&#13;
 * @dev Solves a class of errors where a contract accidentally becomes owner of Ether, Tokens or&#13;
 * Owned contracts. See respective base contracts for details.&#13;
 */&#13;
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {&#13;
}&#13;
&#13;
/**&#13;
 * @title TokenVesting&#13;
 * @dev A token holder contract that can release its token balance gradually like a&#13;
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the&#13;
 * owner.&#13;
 */&#13;
contract TokenVesting is Ownable {&#13;
  using SafeMath for uint256;&#13;
  using SafeERC20 for ERC20Basic;&#13;
&#13;
  event Released(uint256 amount);&#13;
  event Revoked();&#13;
&#13;
  // beneficiary of tokens after they are released&#13;
  address public beneficiary;&#13;
&#13;
  uint256 public cliff;&#13;
  uint256 public start;&#13;
  uint256 public duration;&#13;
&#13;
  bool public revocable;&#13;
&#13;
  mapping (address =&gt; uint256) public released;&#13;
  mapping (address =&gt; bool) public revoked;&#13;
&#13;
  /**&#13;
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the&#13;
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all&#13;
   * of the balance will have vested.&#13;
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred&#13;
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest&#13;
   * @param _duration duration in seconds of the period in which the tokens will vest&#13;
   * @param _revocable whether the vesting is revocable or not&#13;
   */&#13;
  function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {&#13;
    require(_beneficiary != address(0));&#13;
    require(_cliff &lt;= _duration);&#13;
&#13;
    beneficiary = _beneficiary;&#13;
    revocable = _revocable;&#13;
    duration = _duration;&#13;
    cliff = _start.add(_cliff);&#13;
    start = _start;&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Transfers vested tokens to beneficiary.&#13;
   * @param token ERC20 token which is being vested&#13;
   */&#13;
  function release(ERC20Basic token) public {&#13;
    uint256 unreleased = releasableAmount(token);&#13;
&#13;
    require(unreleased &gt; 0);&#13;
&#13;
    released[token] = released[token].add(unreleased);&#13;
&#13;
    token.safeTransfer(beneficiary, unreleased);&#13;
&#13;
    Released(unreleased);&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Allows the owner to revoke the vesting. Tokens already vested&#13;
   * remain in the contract, the rest are returned to the owner.&#13;
   * @param token ERC20 token which is being vested&#13;
   */&#13;
  function revoke(ERC20Basic token) public onlyOwner {&#13;
    require(revocable);&#13;
    require(!revoked[token]);&#13;
&#13;
    uint256 balance = token.balanceOf(this);&#13;
&#13;
    uint256 unreleased = releasableAmount(token);&#13;
    uint256 refund = balance.sub(unreleased);&#13;
&#13;
    revoked[token] = true;&#13;
&#13;
    token.safeTransfer(owner, refund);&#13;
&#13;
    Revoked();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Calculates the amount that has already vested but hasn't been released yet.&#13;
   * @param token ERC20 token which is being vested&#13;
   */&#13;
  function releasableAmount(ERC20Basic token) public view returns (uint256) {&#13;
    return vestedAmount(token).sub(released[token]);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Calculates the amount that has already vested.&#13;
   * @param token ERC20 token which is being vested&#13;
   */&#13;
  function vestedAmount(ERC20Basic token) public view returns (uint256) {&#13;
    uint256 currentBalance = token.balanceOf(this);&#13;
    uint256 totalBalance = currentBalance.add(released[token]);&#13;
&#13;
    if (now &lt; cliff) {&#13;
      return 0;&#13;
    } else if (now &gt;= start.add(duration) || revoked[token]) {&#13;
      return totalBalance;&#13;
    } else {&#13;
      return totalBalance.mul(now.sub(start)).div(duration);&#13;
    }&#13;
  }&#13;
}&#13;
&#13;
// === Modified OpenZeppelin contracts ===&#13;
&#13;
/**&#13;
 * @title Burnable Token&#13;
 * @dev Token that can be irreversibly burned (destroyed).&#13;
 * Based on https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC20/BurnableToken.sol&#13;
 */&#13;
contract BurnableToken is BasicToken {&#13;
&#13;
    event Burn(address indexed burner, uint256 value);&#13;
&#13;
    /**&#13;
     * @dev Burns a specific amount of tokens.&#13;
     * @param _value The amount of token to be burned.&#13;
     */&#13;
    function burn(uint256 _value) public returns (bool) {&#13;
        require(_value &lt;= balances[msg.sender]);&#13;
        // no need to require value &lt;= totalSupply, since that would imply the&#13;
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure&#13;
&#13;
        address burner = msg.sender;&#13;
        balances[burner] = balances[burner].sub(_value);&#13;
        totalSupply_ = totalSupply_.sub(_value);&#13;
        Burn(burner, _value);&#13;
        Transfer(burner, address(0), _value);&#13;
        return true;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title BOBTokenVesting&#13;
 * @dev Extends TokenVesting contract to allow reclaim ether and contracts, if transfered to this by mistake.&#13;
 */&#13;
contract BOBTokenVesting is TokenVesting, HasNoEther, HasNoContracts, Destructible {&#13;
&#13;
    /**&#13;
     * @dev Call consturctor of TokenVesting with exactly same parameters&#13;
     */&#13;
    function BOBTokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) &#13;
                TokenVesting(        _beneficiary,         _start,         _cliff,         _duration,      _revocable) public {}&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Pausable ERC827token&#13;
 * @dev ERC827Token modified with pausable transfers. Based on OpenZeppelin's PausableToken&#13;
 **/&#13;
contract PausableERC827Token is ERC827Token, Pausable {&#13;
&#13;
    // ERC20 functions&#13;
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {&#13;
        return super.approve(_spender, _value);&#13;
    }&#13;
&#13;
    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {&#13;
        return super.increaseApproval(_spender, _addedValue);&#13;
    }&#13;
    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {&#13;
        return super.decreaseApproval(_spender, _subtractedValue);&#13;
    }&#13;
&#13;
    //ERC827 functions&#13;
    function transfer(address _to, uint256 _value, bytes _data) public whenNotPaused returns (bool) {&#13;
        return super.transfer(_to, _value, _data);&#13;
    }&#13;
    function transferFrom(address _from, address _to, uint256 _value, bytes _data) public whenNotPaused returns (bool) {&#13;
        return super.transferFrom(_from, _to, _value, _data);&#13;
    }&#13;
    function approve(address _spender, uint256 _value, bytes _data) public whenNotPaused returns (bool) {&#13;
        return super.approve(_spender, _value, _data);&#13;
    }&#13;
    function increaseApproval(address _spender, uint _addedValue, bytes _data) public whenNotPaused returns (bool success) {&#13;
        return super.increaseApproval(_spender, _addedValue, _data);&#13;
    }&#13;
    function decreaseApproval(address _spender, uint _subtractedValue, bytes _data) public whenNotPaused returns (bool success) {&#13;
        return super.decreaseApproval(_spender, _subtractedValue, _data);&#13;
    }&#13;
}&#13;
&#13;
// === Bob's Repair Contracts ===&#13;
&#13;
/**&#13;
 * @title Airdroppable Token&#13;
 */&#13;
contract AirdropToken is PausableERC827Token {&#13;
    using SafeMath for uint256;&#13;
    uint8 private constant PERCENT_DIVIDER = 100;  &#13;
&#13;
    event AirdropStart(uint256 multiplierPercent, uint256 airdropNumber);&#13;
    event AirdropComplete(uint256 airdropNumber);&#13;
&#13;
    uint256 public multiplierPercent = 0;               //Multiplier of current airdrop (for example, multiplierPercent = 200 and holder balance is 1 TOKEN, after airdrop it will be 2 TOKEN)&#13;
    uint256 public currentAirdrop = 0;                  //Number of current airdrop. If 0 - no airdrop started&#13;
    uint256 public undropped;                           //Amount not yet airdropped&#13;
    mapping(address =&gt; uint256) public airdropped;        //map of alreday airdropped addresses       &#13;
&#13;
    /**&#13;
    * @notice Start airdrop&#13;
    * @param _multiplierPercent Multiplier of the airdrop&#13;
    */&#13;
    function startAirdrop(uint256 _multiplierPercent) onlyOwner external returns(bool){&#13;
        pause();&#13;
        require(multiplierPercent == 0);                 //This means airdrop was finished&#13;
        require(_multiplierPercent &gt; PERCENT_DIVIDER);   //Require that after airdrop amount of tokens will be greater than before&#13;
        currentAirdrop = currentAirdrop.add(1);&#13;
        multiplierPercent = _multiplierPercent;&#13;
        undropped = totalSupply();&#13;
        assert(multiplierPercent.mul(undropped) &gt; 0);   //Assert that wrong multiplier will not result in owerflow in airdropAmount()&#13;
        AirdropStart(multiplierPercent, currentAirdrop);&#13;
    }&#13;
    /**&#13;
    * @notice Finish airdrop, unpause token transfers&#13;
    * @dev Anyone can call this function after all addresses are airdropped&#13;
    */&#13;
    function finishAirdrop() external returns(bool){&#13;
        require(undropped == 0);&#13;
        multiplierPercent = 0;&#13;
        AirdropComplete(currentAirdrop);&#13;
        unpause();&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Execute airdrop for a bunch of addresses. Should be repeated for all addresses with non-zero amount of tokens.&#13;
    * @dev This function can be called by anyone, not only the owner&#13;
    * @param holders Array of token holder addresses.&#13;
    * @return true if success&#13;
    */&#13;
    function drop(address[] holders) external returns(bool){&#13;
        for(uint256 i=0; i &lt; holders.length; i++){&#13;
            address holder = holders[i];&#13;
            if(!isAirdropped(holder)){&#13;
                uint256 balance = balances[holder];&#13;
                undropped = undropped.sub(balance);&#13;
                balances[holder] = airdropAmount(balance);&#13;
                uint256 amount = balances[holder].sub(balance);&#13;
                totalSupply_ = totalSupply_.add(amount);&#13;
                Transfer(address(0), holder, amount);&#13;
                setAirdropped(holder);&#13;
            }&#13;
        }&#13;
    }&#13;
    /**&#13;
    * @notice Calculates amount of tokens after airdrop&#13;
    * @param amount Balance before airdrop&#13;
    * @return Amount of tokens after airdrop&#13;
    */&#13;
    function airdropAmount(uint256 amount) view public returns(uint256){&#13;
        require(multiplierPercent &gt; 0);&#13;
        return multiplierPercent.mul(amount).div(PERCENT_DIVIDER);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Check if address was already airdropped&#13;
    * @param holder Address of token holder&#13;
    * @return true if address was airdropped&#13;
    */&#13;
    function isAirdropped(address holder) view internal returns(bool){&#13;
        return (airdropped[holder] == currentAirdrop);&#13;
    }&#13;
    /**&#13;
    * @dev Mark address as airdropped&#13;
    * @param holder Address of token holder&#13;
    */&#13;
    function setAirdropped(address holder) internal {&#13;
        airdropped[holder] = currentAirdrop;&#13;
    }&#13;
}&#13;
&#13;
contract BOBToken is AirdropToken, MintableToken, BurnableToken, NoOwner {&#13;
    string public symbol = 'BOB';&#13;
    string public name = 'BOB Token';&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    address founder;                //founder address to allow him transfer tokens even when transfers disabled&#13;
    bool public transferEnabled;    //allows to dissable transfers while minting and in case of emergency&#13;
&#13;
    function setFounder(address _founder) onlyOwner public {&#13;
        founder = _founder;&#13;
    }&#13;
    function setTransferEnabled(bool enable) onlyOwner public {&#13;
        transferEnabled = enable;&#13;
    }&#13;
&#13;
    /**&#13;
     * Allow transfer only after crowdsale finished&#13;
     */&#13;
    modifier canTransfer() {&#13;
        require( transferEnabled || msg.sender == founder || msg.sender == owner);&#13;
        _;&#13;
    }&#13;
    &#13;
    function transfer(address _to, uint256 _value) canTransfer public returns (bool) {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    function transfer(address _to, uint256 _value, bytes _data) canTransfer public returns (bool) {&#13;
        return super.transfer(_to, _value, _data);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value, bytes _data) canTransfer public returns (bool) {&#13;
        return super.transferFrom(_from, _to, _value, _data);&#13;
    }&#13;
}