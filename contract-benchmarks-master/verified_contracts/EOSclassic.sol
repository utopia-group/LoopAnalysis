pragma solidity ^0.4.21;


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


/**
 * @title EOSclassic
 */

// Imports









/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
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

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

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
    emit Transfer(_from, _to, _value);
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
    emit Approval(msg.sender, _spender, _value);
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
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}






/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="a3d1c6cec0cce391">[email protected]</span>π.com&gt;&#13;
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
&#13;
// Contract to help import the original EOS Crowdsale public key&#13;
contract EOSContractInterface&#13;
{&#13;
    mapping (address =&gt; string) public keys;&#13;
    function balanceOf( address who ) constant returns (uint value);&#13;
}&#13;
&#13;
// EOSclassic smart contract &#13;
contract EOSclassic is StandardToken, HasNoEther &#13;
{&#13;
    // Welcome to EOSclassic&#13;
    string public constant NAME = "EOSclassic";&#13;
    string public constant SYMBOL = "EOSC";&#13;
    uint8 public constant DECIMALS = 18;&#13;
&#13;
    // Total amount minted&#13;
    uint public constant TOTAL_SUPPLY = 1000000000 * (10 ** uint(DECIMALS));&#13;
    &#13;
    // Amount given to founders&#13;
    uint public constant foundersAllocation = 100000000 * (10 ** uint(DECIMALS));   &#13;
&#13;
    // Contract address of the original EOS contracts    &#13;
    address public constant eosTokenAddress = 0x86Fa049857E0209aa7D9e616F7eb3b3B78ECfdb0;&#13;
    address public constant eosCrowdsaleAddress = 0xd0a6E6C54DbC68Db5db3A091B171A77407Ff7ccf;&#13;
    &#13;
    // Map EOS keys; if not empty it should be favored over the original crowdsale address&#13;
    mapping (address =&gt; string) public keys;&#13;
    &#13;
    // Keep track of EOS-&gt;EOSclassic claims&#13;
    mapping (address =&gt; bool) public eosClassicClaimed;&#13;
&#13;
    // LogClaim is called any time an EOS crowdsale user claims their EOSclassic equivalent&#13;
    event LogClaim (address user, uint amount);&#13;
&#13;
    // LogRegister is called any time a user registers a new EOS public key&#13;
    event LogRegister (address user, string key);&#13;
&#13;
    // ************************************************************&#13;
    // Constructor; mints all tokens, assigns founder's allocation&#13;
    // ************************************************************&#13;
    constructor() public &#13;
    {&#13;
        // Define total supply&#13;
        totalSupply_ = TOTAL_SUPPLY;&#13;
        // Allocate total supply of tokens to smart contract for disbursement&#13;
        balances[address(this)] = TOTAL_SUPPLY;&#13;
        // Announce initial allocation&#13;
        emit Transfer(0x0, address(this), TOTAL_SUPPLY);&#13;
        &#13;
        // Transfer founder's allocation&#13;
        balances[address(this)] = balances[address(this)].sub(foundersAllocation);&#13;
        balances[msg.sender] = balances[msg.sender].add(foundersAllocation);&#13;
        // Announce founder's allocation&#13;
        emit Transfer(address(this), msg.sender, foundersAllocation);&#13;
    }&#13;
&#13;
    // Function that checks the original EOS token for a balance&#13;
    function queryEOSTokenBalance(address _address) view public returns (uint) &#13;
    {&#13;
        //return ERC20Basic(eosCrowdsaleAddress).balanceOf(_address);&#13;
        EOSContractInterface eosTokenContract = EOSContractInterface(eosTokenAddress);&#13;
        return eosTokenContract.balanceOf(_address);&#13;
    }&#13;
&#13;
    // Function that returns any registered EOS address from the original EOS crowdsale&#13;
    function queryEOSCrowdsaleKey(address _address) view public returns (string) &#13;
    {&#13;
        EOSContractInterface eosCrowdsaleContract = EOSContractInterface(eosCrowdsaleAddress);&#13;
        return eosCrowdsaleContract.keys(_address);&#13;
    }&#13;
&#13;
    // Use to claim EOS Classic from the calling address&#13;
    function claimEOSclassic() external returns (bool) &#13;
    {&#13;
        return claimEOSclassicFor(msg.sender);&#13;
    }&#13;
&#13;
    // Use to claim EOSclassic for any Ethereum address &#13;
    function claimEOSclassicFor(address _toAddress) public returns (bool)&#13;
    {&#13;
        // Ensure that an address has been passed&#13;
        require (_toAddress != address(0));&#13;
        // Ensure this address has not already been claimed&#13;
        require (isClaimed(_toAddress) == false);&#13;
        &#13;
        // Query the original EOS Crowdsale for address balance&#13;
        uint _eosContractBalance = queryEOSTokenBalance(_toAddress);&#13;
        &#13;
        // Ensure that address had some balance in the crowdsale&#13;
        require (_eosContractBalance &gt; 0);&#13;
        &#13;
        // Sanity check: ensure we have enough tokens to send&#13;
        require (_eosContractBalance &lt;= balances[address(this)]);&#13;
&#13;
        // Mark address as claimed&#13;
        eosClassicClaimed[_toAddress] = true;&#13;
        &#13;
        // Convert equivalent amount of EOS to EOSclassic&#13;
        // Transfer EOS Classic tokens from this contract to claiming address&#13;
        balances[address(this)] = balances[address(this)].sub(_eosContractBalance);&#13;
        balances[_toAddress] = balances[_toAddress].add(_eosContractBalance);&#13;
        &#13;
        // Broadcast transfer &#13;
        emit Transfer(address(this), _toAddress, _eosContractBalance);&#13;
        &#13;
        // Broadcast claim&#13;
        emit LogClaim(_toAddress, _eosContractBalance);&#13;
        &#13;
        // Success!&#13;
        return true;&#13;
    }&#13;
&#13;
    // Check any address to see if its EOSclassic has already been claimed&#13;
    function isClaimed(address _address) public view returns (bool) &#13;
    {&#13;
        return eosClassicClaimed[_address];&#13;
    }&#13;
&#13;
    // Returns the latest EOS key registered.&#13;
    // EOS token holders that never registered their EOS public key &#13;
    // can do so using the 'register' function in EOSclassic and then request restitution &#13;
    // via the EOS mainnet arbitration process.&#13;
    // EOS holders that previously registered can update their keys here;&#13;
    // This contract could be used in future key snapshots for future EOS forks.&#13;
    function getMyEOSKey() external view returns (string)&#13;
    {&#13;
        return getEOSKeyFor(msg.sender);&#13;
    }&#13;
&#13;
    // Return the registered EOS public key for the passed address&#13;
    function getEOSKeyFor(address _address) public view returns (string)&#13;
    {&#13;
        string memory _eosKey;&#13;
&#13;
        // Get any key registered with EOSclassic&#13;
        _eosKey = keys[_address];&#13;
&#13;
        if (bytes(_eosKey).length &gt; 0) {&#13;
            // EOSclassic key was registered; return this over the original crowdsale address&#13;
            return _eosKey;&#13;
        } else {&#13;
            // EOSclassic doesn't have an EOS public key registered; return any original crowdsale key&#13;
            _eosKey = queryEOSCrowdsaleKey(_address);&#13;
            return _eosKey;&#13;
        }&#13;
    }&#13;
&#13;
    // EOSclassic developer's note: the registration function is identical&#13;
    // to the original EOS crowdsale registration function with only the&#13;
    // freeze function removed, and 'emit' added to the LogRegister event,&#13;
    // per updated Solidity standards.&#13;
    //&#13;
    // Value should be a public key.  Read full key import policy.&#13;
    // Manually registering requires a base58&#13;
    // encoded using the STEEM, BTS, or EOS public key format.&#13;
    function register(string key) public {&#13;
        assert(bytes(key).length &lt;= 64);&#13;
&#13;
        keys[msg.sender] = key;&#13;
&#13;
        emit LogRegister(msg.sender, key);&#13;
    }&#13;
&#13;
}