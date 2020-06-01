pragma solidity ^0.4.21;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
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
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b3c1d6ded0dcf381">[email protected]</a>π.com&gt;&#13;
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
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f98b9c949a96b9cb">[email protected]</a>π.com&gt;&#13;
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
&#13;
/**&#13;
 * @title Contracts that should not own Ether&#13;
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="aad8cfc7c9c5ea98">[email protected]</a>π.com&gt;&#13;
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
&#13;
/**&#13;
 * @title Base contract for contracts that should not own things.&#13;
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c1b3a4aca2ae81f3">[email protected]</a>π.com&gt;&#13;
 * @dev Solves a class of errors where a contract accidentally becomes owner of Ether, Tokens or&#13;
 * Owned contracts. See respective base contracts for details.&#13;
 */&#13;
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances.&#13;
 */&#13;
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping(address =&gt; uint256) balances;&#13;
&#13;
  uint256 totalSupply_;&#13;
&#13;
  /**&#13;
  * @dev total number of tokens in existence&#13;
  */&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return totalSupply_;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[msg.sender]);&#13;
&#13;
    // SafeMath.sub will throw if there is not enough balance.&#13;
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    Transfer(msg.sender, _to, _value);&#13;
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
}&#13;
&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 *&#13;
 * @dev Implementation of the basic standard token.&#13;
 * @dev https://github.com/ethereum/EIPs/issues/20&#13;
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
 */&#13;
contract StandardToken is ERC20, BasicToken {&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Transfer tokens from one address to another&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _to address The address which you want to transfer to&#13;
   * @param _value uint256 the amount of tokens to be transferred&#13;
   */&#13;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[_from]);&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    Transfer(_from, _to, _value);&#13;
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
    Approval(msg.sender, _spender, _value);&#13;
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
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
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
    if (_subtractedValue &gt; oldValue) {&#13;
      allowed[msg.sender][_spender] = 0;&#13;
    } else {&#13;
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
    }&#13;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title BetexToken&#13;
 */&#13;
contract BetexToken is StandardToken, NoOwner {&#13;
&#13;
    string public constant name = "Betex Token"; // solium-disable-line uppercase&#13;
    string public constant symbol = "BETEX"; // solium-disable-line uppercase&#13;
    uint8 public constant decimals = 18; // solium-disable-line uppercase&#13;
&#13;
    // transfer unlock time (except team and broker recipients)&#13;
    uint256 public firstUnlockTime;&#13;
&#13;
    // transfer unlock time for the team and broker recipients&#13;
    uint256 public secondUnlockTime; &#13;
&#13;
    // addresses locked till second unlock time&#13;
    mapping (address =&gt; bool) public blockedTillSecondUnlock;&#13;
&#13;
    // token holders&#13;
    address[] public holders;&#13;
&#13;
    // holder number&#13;
    mapping (address =&gt; uint256) public holderNumber;&#13;
&#13;
    // ICO address&#13;
    address public icoAddress;&#13;
&#13;
    // supply constants&#13;
    uint256 public constant TOTAL_SUPPLY = 10000000 * (10 ** uint256(decimals));&#13;
    uint256 public constant SALE_SUPPLY = 5000000 * (10 ** uint256(decimals));&#13;
&#13;
    // funds supply constants&#13;
    uint256 public constant BOUNTY_SUPPLY = 200000 * (10 ** uint256(decimals));&#13;
    uint256 public constant RESERVE_SUPPLY = 800000 * (10 ** uint256(decimals));&#13;
    uint256 public constant BROKER_RESERVE_SUPPLY = 1000000 * (10 ** uint256(decimals));&#13;
    uint256 public constant TEAM_SUPPLY = 3000000 * (10 ** uint256(decimals));&#13;
&#13;
    // funds addresses constants&#13;
    address public constant BOUNTY_ADDRESS = 0x48c15e5A9343E3220cdD8127620AE286A204448a;&#13;
    address public constant RESERVE_ADDRESS = 0xC8fE659AaeF73b6e41DEe427c989150e3eDAf57D;&#13;
    address public constant BROKER_RESERVE_ADDRESS = 0x8697d46171aBCaD2dC5A4061b8C35f909a402417;&#13;
    address public constant TEAM_ADDRESS = 0x1761988F02C75E7c3432fa31d179cad6C5843F24;&#13;
&#13;
    // min tokens to be a holder, 0.1&#13;
    uint256 public constant MIN_HOLDER_TOKENS = 10 ** uint256(decimals - 1);&#13;
    &#13;
    /**&#13;
     * @dev Constructor&#13;
     * @param _firstUnlockTime first unlock time&#13;
     * @param _secondUnlockTime second unlock time&#13;
     */&#13;
    function BetexToken&#13;
    (&#13;
        uint256 _firstUnlockTime, &#13;
        uint256 _secondUnlockTime&#13;
    )&#13;
        public &#13;
    {        &#13;
        require(_secondUnlockTime &gt; firstUnlockTime);&#13;
&#13;
        firstUnlockTime = _firstUnlockTime;&#13;
        secondUnlockTime = _secondUnlockTime;&#13;
&#13;
        // Allocate tokens to the bounty fund&#13;
        balances[BOUNTY_ADDRESS] = BOUNTY_SUPPLY;&#13;
        holders.push(BOUNTY_ADDRESS);&#13;
        emit Transfer(0x0, BOUNTY_ADDRESS, BOUNTY_SUPPLY);&#13;
&#13;
        // Allocate tokens to the reserve fund&#13;
        balances[RESERVE_ADDRESS] = RESERVE_SUPPLY;&#13;
        holders.push(RESERVE_ADDRESS);&#13;
        emit Transfer(0x0, RESERVE_ADDRESS, RESERVE_SUPPLY);&#13;
&#13;
        // Allocate tokens to the broker reserve fund&#13;
        balances[BROKER_RESERVE_ADDRESS] = BROKER_RESERVE_SUPPLY;&#13;
        holders.push(BROKER_RESERVE_ADDRESS);&#13;
        emit Transfer(0x0, BROKER_RESERVE_ADDRESS, BROKER_RESERVE_SUPPLY);&#13;
&#13;
        // Allocate tokens to the team fund&#13;
        balances[TEAM_ADDRESS] = TEAM_SUPPLY;&#13;
        holders.push(TEAM_ADDRESS);&#13;
        emit Transfer(0x0, TEAM_ADDRESS, TEAM_SUPPLY);&#13;
&#13;
        totalSupply_ = TOTAL_SUPPLY.sub(SALE_SUPPLY);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev set ICO address and allocate sale supply to it&#13;
     */&#13;
    function setICO(address _icoAddress) public onlyOwner {&#13;
        require(_icoAddress != address(0));&#13;
        require(icoAddress == address(0));&#13;
        require(totalSupply_ == TOTAL_SUPPLY.sub(SALE_SUPPLY));&#13;
        &#13;
        // Allocate tokens to the ico contract&#13;
        balances[_icoAddress] = SALE_SUPPLY;&#13;
        emit Transfer(0x0, _icoAddress, SALE_SUPPLY);&#13;
&#13;
        icoAddress = _icoAddress;&#13;
        totalSupply_ = TOTAL_SUPPLY;&#13;
    }&#13;
    &#13;
    // standard transfer function with timelocks&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        require(transferAllowed(msg.sender));&#13;
        enforceSecondLock(msg.sender, _to);&#13;
        preserveHolders(msg.sender, _to, _value);&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    // standard transferFrom function with timelocks&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        require(transferAllowed(msg.sender));&#13;
        enforceSecondLock(msg.sender, _to);&#13;
        preserveHolders(_from, _to, _value);&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    // get holders count&#13;
    function getHoldersCount() public view returns (uint256) {&#13;
        return holders.length;&#13;
    }&#13;
&#13;
    // enforce second lock on receiver&#13;
    function enforceSecondLock(address _from, address _to) internal {&#13;
        if (now &lt; secondUnlockTime) { // solium-disable-line security/no-block-members&#13;
            if (_from == TEAM_ADDRESS || _from == BROKER_RESERVE_ADDRESS) {&#13;
                require(balances[_to] == uint256(0) || blockedTillSecondUnlock[_to]);&#13;
                blockedTillSecondUnlock[_to] = true;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    // preserve holders list&#13;
    function preserveHolders(address _from, address _to, uint256 _value) internal {&#13;
        if (balances[_from].sub(_value) &lt; MIN_HOLDER_TOKENS) &#13;
            removeHolder(_from);&#13;
        if (balances[_to].add(_value) &gt;= MIN_HOLDER_TOKENS) &#13;
            addHolder(_to);   &#13;
    }&#13;
&#13;
    // remove holder from the holders list&#13;
    function removeHolder(address _holder) internal {&#13;
        uint256 _number = holderNumber[_holder];&#13;
&#13;
        if (_number == 0 || holders.length == 0 || _number &gt; holders.length)&#13;
            return;&#13;
&#13;
        uint256 _index = _number.sub(1);&#13;
        uint256 _lastIndex = holders.length.sub(1);&#13;
        address _lastHolder = holders[_lastIndex];&#13;
&#13;
        if (_index != _lastIndex) {&#13;
            holders[_index] = _lastHolder;&#13;
            holderNumber[_lastHolder] = _number;&#13;
        }&#13;
&#13;
        holderNumber[_holder] = 0;&#13;
        holders.length = _lastIndex;&#13;
    } &#13;
&#13;
    // add holder to the holders list&#13;
    function addHolder(address _holder) internal {&#13;
        if (holderNumber[_holder] == 0) {&#13;
            holders.push(_holder);&#13;
            holderNumber[_holder] = holders.length;&#13;
        }&#13;
    }&#13;
&#13;
    // @return true if transfer operation is allowed&#13;
    function transferAllowed(address _sender) internal view returns(bool) {&#13;
        if (now &gt; secondUnlockTime || _sender == icoAddress) // solium-disable-line security/no-block-members&#13;
            return true;&#13;
        if (now &lt; firstUnlockTime) // solium-disable-line security/no-block-members&#13;
            return false;&#13;
        if (blockedTillSecondUnlock[_sender])&#13;
            return false;&#13;
        return true;&#13;
    }&#13;
&#13;
}