pragma solidity ^0.4.11;

/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
contract Ownable {
  address public owner;


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
    if (msg.sender != owner) {
      throw;
    }
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to. 
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
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
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    if (paused) throw;
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    if (!paused) throw;
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
  uint public _totalSupply;
  function totalSupply() constant returns (uint);
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is Ownable, ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

  // additional variables for use if transaction fees ever became necessary
  uint public basisPointsRate = 0;
  uint public maximumFee = 0;

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    uint fee = (_value.mul(basisPointsRate)).div(10000);
    if (fee > maximumFee) {
      fee = maximumFee;
    }
    uint sendAmount = _value.sub(fee);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(sendAmount);
    balances[owner] = balances[owner].add(fee);
    Transfer(msg.sender, _to, sendAmount);
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint balance) {
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
contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;

  uint constant MAX_UINT = 2**256 - 1;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    uint fee = (_value.mul(basisPointsRate)).div(10000);
    if (fee > maximumFee) {
      fee = maximumFee;
    }
    uint sendAmount = _value.sub(fee);

    balances[_to] = balances[_to].add(sendAmount);
    balances[owner] = balances[owner].add(fee);
    balances[_from] = balances[_from].sub(_value);
    if (_allowance < MAX_UINT) {
      allowed[_from][msg.sender] = _allowance.sub(_value);
    }
    Transfer(_from, _to, sendAmount);
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint _value) onlyPayloadSize(2 * 32) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  /**
   * @dev Function to check the amount of tokens than an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}


/// @title - Tether Token Contract - Tether.to
/// @author Enrico Rubboli - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="01646f7368626e4163687567686f64792f626e6c">[email protected]</a>&gt;&#13;
/// @author Will Harborne - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ec9b858080ac8998848a85828994c28f8381">[email protected]</a>&gt;&#13;
&#13;
contract TetherToken is Pausable, StandardToken {&#13;
&#13;
  string public name;&#13;
  string public symbol;&#13;
  uint public decimals;&#13;
  address public upgradedAddress;&#13;
  bool public deprecated;&#13;
&#13;
  //  The contract can be initialized with a number of tokens&#13;
  //  All the tokens are deposited to the owner address&#13;
  //&#13;
  // @param _balance Initial supply of the contract&#13;
  // @param _name Token Name&#13;
  // @param _symbol Token symbol&#13;
  // @param _decimals Token decimals&#13;
  function TetherToken(uint _initialSupply, string _name, string _symbol, uint _decimals){&#13;
      _totalSupply = _initialSupply;&#13;
      name = _name;&#13;
      symbol = _symbol;&#13;
      decimals = _decimals;&#13;
      balances[owner] = _initialSupply;&#13;
      deprecated = false;&#13;
  }&#13;
&#13;
  // Forward ERC20 methods to upgraded contract if this one is deprecated&#13;
  function transfer(address _to, uint _value) whenNotPaused {&#13;
    if (deprecated) {&#13;
      return StandardToken(upgradedAddress).transfer(_to, _value);&#13;
    } else {&#13;
      return super.transfer(_to, _value);&#13;
    }&#13;
  }&#13;
&#13;
  // Forward ERC20 methods to upgraded contract if this one is deprecated&#13;
  function transferFrom(address _from, address _to, uint _value) whenNotPaused {&#13;
    if (deprecated) {&#13;
      return StandardToken(upgradedAddress).transferFrom(_from, _to, _value);&#13;
    } else {&#13;
      return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
  }&#13;
&#13;
  // Forward ERC20 methods to upgraded contract if this one is deprecated&#13;
  function balanceOf(address who) constant returns (uint){&#13;
    if (deprecated) {&#13;
      return StandardToken(upgradedAddress).balanceOf(who);&#13;
    } else {&#13;
      return super.balanceOf(who);&#13;
    }&#13;
  }&#13;
&#13;
  // Forward ERC20 methods to upgraded contract if this one is deprecated&#13;
  function approve(address _spender, uint _value) onlyPayloadSize(2 * 32) {&#13;
    if (deprecated) {&#13;
      return StandardToken(upgradedAddress).approve(_spender, _value);&#13;
    } else {&#13;
      return super.approve(_spender, _value);&#13;
    }&#13;
  }&#13;
&#13;
  // Forward ERC20 methods to upgraded contract if this one is deprecated&#13;
  function allowance(address _owner, address _spender) constant returns (uint remaining) {&#13;
    if (deprecated) {&#13;
      return StandardToken(upgradedAddress).allowance(_owner, _spender);&#13;
    } else {&#13;
      return super.allowance(_owner, _spender);&#13;
    }&#13;
  }&#13;
&#13;
  // deprecate current contract in favour of a new one&#13;
  function deprecate(address _upgradedAddress) onlyOwner {&#13;
    deprecated = true;&#13;
    upgradedAddress = _upgradedAddress;&#13;
    Deprecate(_upgradedAddress);&#13;
  }&#13;
&#13;
  // deprecate current contract if favour of a new one&#13;
  function totalSupply() constant returns (uint){&#13;
    if (deprecated) {&#13;
      return StandardToken(upgradedAddress).totalSupply();&#13;
    } else {&#13;
      return _totalSupply;&#13;
    }&#13;
  }&#13;
&#13;
  // Issue a new amount of tokens&#13;
  // these tokens are deposited into the owner address&#13;
  //&#13;
  // @param _amount Number of tokens to be issued&#13;
  function issue(uint amount) onlyOwner {&#13;
    if (_totalSupply + amount &lt; _totalSupply) throw;&#13;
    if (balances[owner] + amount &lt; balances[owner]) throw;&#13;
&#13;
    balances[owner] += amount;&#13;
    _totalSupply += amount;&#13;
    Issue(amount);&#13;
  }&#13;
&#13;
  // Redeem tokens.&#13;
  // These tokens are withdrawn from the owner address&#13;
  // if the balance must be enough to cover the redeem&#13;
  // or the call will fail.&#13;
  // @param _amount Number of tokens to be issued&#13;
  function redeem(uint amount) onlyOwner {&#13;
      if (_totalSupply &lt; amount) throw;&#13;
      if (balances[owner] &lt; amount) throw;&#13;
&#13;
      _totalSupply -= amount;&#13;
      balances[owner] -= amount;&#13;
      Redeem(amount);&#13;
  }&#13;
&#13;
  function setParams(uint newBasisPoints, uint newMaxFee) onlyOwner {&#13;
      // Ensure transparency by hardcoding limit beyond which fees can never be added&#13;
      if (newBasisPoints &gt; 20) throw;&#13;
      if (newMaxFee &gt; 50) throw;&#13;
&#13;
      basisPointsRate = newBasisPoints;&#13;
      maximumFee = newMaxFee.mul(10**decimals);&#13;
&#13;
      Params(basisPointsRate, decimals);&#13;
  }&#13;
&#13;
  // Called when new token are issued&#13;
  event Issue(uint amount);&#13;
&#13;
  // Called when tokens are redeemed&#13;
  event Redeem(uint amount);&#13;
&#13;
  // Called when contract is deprecated&#13;
  event Deprecate(address newAddress);&#13;
&#13;
  // Called if contract ever adds fees&#13;
  event Params(uint feeBasisPoints, uint maxFee);&#13;
}