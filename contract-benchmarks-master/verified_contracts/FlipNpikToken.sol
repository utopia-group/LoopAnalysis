pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



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



contract TokenReceiver {
    /**
    * @dev Method to be triggerred during approveAndCall execution
    * @param _sender A wallet that initiated the operation
    * @param _value Amount of approved tokens
    * @param _data Additional arguments
    */
    function tokenFallback(address _sender, uint256 _value, bytes _data) external returns (bool);
}

/**
* @title Timestamped
* @dev Timestamped contract has a separate method for receiving current timestamp.
* This simplifies derived contracts testability.
*/
contract Timestamped {
    /**
    * @dev Returns current timestamp.
    */
    function _currentTime() internal view returns(uint256) {
        // solium-disable-next-line security/no-block-members
        return block.timestamp;
    }
}





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










/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

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
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
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
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}






/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}






/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d9abbcb4bab699eb">[email protected]</a>π.com&gt;&#13;
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
&#13;
&#13;
&#13;
/**&#13;
* @title FlipNpikToken&#13;
* @dev The FlipNpikToken is a ERC20 token &#13;
*/&#13;
contract FlipNpikToken is Timestamped, StandardToken, DetailedERC20, HasNoEther {&#13;
    using SafeMath for uint256;&#13;
&#13;
    // A wallet that will hold tokens&#13;
    address public mainWallet;&#13;
    // A wallet that is required to unlock reserve tokens&#13;
    address public financeWallet;&#13;
&#13;
    // Locked reserve tokens amount is 500M FNP&#13;
    uint256 public reserveSize = uint256(500000000).mul(10 ** 18);&#13;
    // List of signatures required to unlock reserve tokens&#13;
    mapping (address =&gt; bool) public reserveHolders;&#13;
    // Total amount of unlocked reserve tokens&#13;
    uint256 public totalUnlocked = 0;&#13;
&#13;
    // Scheduled for minting reserve tokens amount is 575M FNP&#13;
    uint256 public mintSize = uint256(575000000).mul(10 ** 18);&#13;
    // Datetime when minting according to schedule becomes available&#13;
    uint256 public mintStart;&#13;
    // Total amount of minted reserve tokens&#13;
    uint256 public totalMinted = 0;    &#13;
&#13;
    /**&#13;
    * Describes minting stage structure fields&#13;
    * @param start Minting stage start date&#13;
    * @param volumt Total tokens available for the stage&#13;
    */&#13;
    struct MintStage {&#13;
        uint256 start;&#13;
        uint256 volume;       &#13;
    }&#13;
&#13;
    // Array of stages&#13;
    MintStage[] public stages;&#13;
&#13;
    /**&#13;
    * @dev Event for reserve tokens minting operation logging&#13;
    * @param _amount Amount minted&#13;
    */&#13;
    event MintReserveLog(uint256 _amount);&#13;
&#13;
    /**&#13;
    * @dev Event for reserve tokens unlock operation logging&#13;
    * @param _amount Amount unlocked&#13;
    */&#13;
    event UnlockReserveLog(uint256 _amount);&#13;
&#13;
    /**&#13;
    * @param _mintStart Datetime when minting according to schedule becomes available&#13;
    * @param _mainWallet A wallet that will hold tokens&#13;
    * @param _financeWallet A wallet that is required to unlock reserve tokens&#13;
    * @param _owner Smart contract owner address&#13;
    */&#13;
    constructor (uint256 _mintStart, address _mainWallet, address _financeWallet, address _owner)&#13;
        DetailedERC20("FlipNpik", "FNP", 18) public {&#13;
&#13;
        require(_mainWallet != address(0), "Main address is invalid.");&#13;
        mainWallet = _mainWallet;       &#13;
&#13;
        require(_financeWallet != address(0), "Finance address is invalid.");&#13;
        financeWallet = _financeWallet;        &#13;
&#13;
        require(_owner != address(0), "Owner address is invalid.");&#13;
        owner = _owner;&#13;
&#13;
        _setStages(_mintStart);&#13;
        _setReserveHolders();&#13;
&#13;
        // 425M FNP should be minted initially&#13;
        _mint(uint256(425000000).mul(10 ** 18));&#13;
    }       &#13;
&#13;
    /**&#13;
    * @dev Mints reserved tokens&#13;
    */&#13;
    function mintReserve() public onlyOwner {&#13;
        require(mintStart &lt; _currentTime(), "Minting has not been allowed yet.");&#13;
        require(totalMinted &lt; mintSize, "No tokens are available for minting.");&#13;
        &#13;
        // Get stage based on current datetime&#13;
        MintStage memory currentStage = _getCurrentStage();&#13;
        // Get amount available for minting&#13;
        uint256 mintAmount = currentStage.volume.sub(totalMinted);&#13;
&#13;
        if (mintAmount &gt; 0 &amp;&amp; _mint(mintAmount)) {&#13;
            emit MintReserveLog(mintAmount);&#13;
            totalMinted = totalMinted.add(mintAmount);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Unlocks reserve&#13;
    */&#13;
    function unlockReserve() public {&#13;
        require(msg.sender == owner || msg.sender == financeWallet, "Operation is not allowed for the wallet.");&#13;
        require(totalUnlocked &lt; reserveSize, "Reserve has been unlocked.");        &#13;
        &#13;
        // Save sender's signature for reserve tokens unlock&#13;
        reserveHolders[msg.sender] = true;&#13;
&#13;
        if (_isReserveUnlocked() &amp;&amp; _mint(reserveSize)) {&#13;
            emit UnlockReserveLog(reserveSize);&#13;
            totalUnlocked = totalUnlocked.add(reserveSize);&#13;
        }        &#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Executes regular token approve operation and trigger receiver SC accordingly&#13;
    * @param _to Address (SC) that should receive approval and be triggerred&#13;
    * @param _value Amount of tokens for approve operation&#13;
    * @param _data Additional arguments to be passed to the contract&#13;
    */&#13;
    function approveAndCall(address _to, uint256 _value, bytes _data) public returns(bool) {&#13;
        require(super.approve(_to, _value), "Approve operation failed.");&#13;
&#13;
        // Check if destination address is SC&#13;
        if (isContract(_to)) {&#13;
            TokenReceiver receiver = TokenReceiver(_to);&#13;
            return receiver.tokenFallback(msg.sender, _value, _data);&#13;
        }&#13;
&#13;
        return true;&#13;
    } &#13;
&#13;
    /**&#13;
    * @dev Mints tokens to main wallet balance&#13;
    * @param _amount Amount to be minted&#13;
    */&#13;
    function _mint(uint256 _amount) private returns(bool) {&#13;
        totalSupply_ = totalSupply_.add(_amount);&#13;
        balances[mainWallet] = balances[mainWallet].add(_amount);&#13;
&#13;
        emit Transfer(address(0), mainWallet, _amount);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Configures minting stages&#13;
    * @param _mintStart Datetime when minting according to schedule becomes available&#13;
    */&#13;
    function _setStages(uint256 _mintStart) private {&#13;
        require(_mintStart &gt;= _currentTime(), "Mint start date is invalid.");&#13;
        mintStart = _mintStart;&#13;
&#13;
        stages.push(MintStage(_mintStart, uint256(200000000).mul(10 ** 18)));&#13;
        stages.push(MintStage(_mintStart.add(365 days), uint256(325000000).mul(10 ** 18)));&#13;
        stages.push(MintStage(_mintStart.add(2 * 365 days), uint256(450000000).mul(10 ** 18)));&#13;
        stages.push(MintStage(_mintStart.add(3 * 365 days), uint256(575000000).mul(10 ** 18)));&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Configures unlock signature holders list&#13;
    */&#13;
    function _setReserveHolders() private {&#13;
        reserveHolders[mainWallet] = false;&#13;
        reserveHolders[financeWallet] = false;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Finds current stage parameters according to the rules and current date and time&#13;
    * @return Current stage parameters (stage start date and available volume of tokens)&#13;
    */&#13;
    function _getCurrentStage() private view returns (MintStage) {&#13;
        uint256 index = 0;&#13;
        uint256 time = _currentTime();        &#13;
&#13;
        MintStage memory result;&#13;
&#13;
        while (index &lt; stages.length) {&#13;
            MintStage memory activeStage = stages[index];&#13;
&#13;
            if (time &gt;= activeStage.start) {&#13;
                result = activeStage;&#13;
            }&#13;
&#13;
            index++;             &#13;
        }&#13;
&#13;
        return result;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Checks if an address is a SC&#13;
    */&#13;
    function isContract(address _addr) private view returns (bool) {&#13;
        uint256 size;&#13;
        // solium-disable-next-line security/no-inline-assembly&#13;
        assembly { size := extcodesize(_addr) }&#13;
        return size &gt; 0;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Checks if reserve tokens have all required signatures for unlock operation&#13;
    */&#13;
    function _isReserveUnlocked() private view returns(bool) {&#13;
        return reserveHolders[owner] == reserveHolders[financeWallet] &amp;&amp; reserveHolders[owner];&#13;
    }&#13;
}