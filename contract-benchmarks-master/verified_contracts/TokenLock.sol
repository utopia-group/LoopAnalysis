pragma solidity ^0.4.18;

// File: contracts/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) pure internal  returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) pure internal  returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) pure internal  returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) pure internal  returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/Token.sol

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
pragma solidity ^0.4.8;

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;
    address public sale;
    bool public transfersAllowed;
    
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant public returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// File: contracts/Disbursement.sol

// NOTE: ORIGINALLY THIS WAS "TOKENS/ABSTRACTTOKEN.SOL"... CHECK THAT


/// @title Disbursement contract - allows to distribute tokens over time
/// @author Stefan George - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="95e6e1f0f3f4fbd5f2fbfae6fce6bbe5f8">[email protected]</a>&gt;&#13;
contract Disbursement {&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    address public owner;&#13;
    address public receiver;&#13;
    uint public disbursementPeriod;&#13;
    uint public startDate;&#13;
    uint public withdrawnTokens;&#13;
    Token public token;&#13;
&#13;
    /*&#13;
     *  Modifiers&#13;
     */&#13;
    modifier isOwner() {&#13;
        if (msg.sender != owner)&#13;
            // Only owner is allowed to proceed&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isReceiver() {&#13;
        if (msg.sender != receiver)&#13;
            // Only receiver is allowed to proceed&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isSetUp() {&#13;
        if (address(token) == 0)&#13;
            // Contract is not set up&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Constructor function sets contract owner&#13;
    /// @param _receiver Receiver of vested tokens&#13;
    /// @param _disbursementPeriod Vesting period in seconds&#13;
    /// @param _startDate Start date of disbursement period (cliff)&#13;
    function Disbursement(address _receiver, uint _disbursementPeriod, uint _startDate)&#13;
        public&#13;
    {&#13;
        if (_receiver == 0 || _disbursementPeriod == 0)&#13;
            // Arguments are null&#13;
            revert();&#13;
        owner = msg.sender;&#13;
        receiver = _receiver;&#13;
        disbursementPeriod = _disbursementPeriod;&#13;
        startDate = _startDate;&#13;
        if (startDate == 0)&#13;
            startDate = now;&#13;
    }&#13;
&#13;
    /// @dev Setup function sets external contracts' addresses&#13;
    /// @param _token Token address&#13;
    function setup(Token _token)&#13;
        public&#13;
        isOwner&#13;
    {&#13;
        if (address(token) != 0 || address(_token) == 0)&#13;
            // Setup was executed already or address is null&#13;
            revert();&#13;
        token = _token;&#13;
    }&#13;
&#13;
    /// @dev Transfers tokens to a given address&#13;
    /// @param _to Address of token receiver&#13;
    /// @param _value Number of tokens to transfer&#13;
    function withdraw(address _to, uint256 _value)&#13;
        public&#13;
        isReceiver&#13;
        isSetUp&#13;
    {&#13;
        uint maxTokens = calcMaxWithdraw();&#13;
        if (_value &gt; maxTokens)&#13;
            revert();&#13;
        withdrawnTokens = SafeMath.add(withdrawnTokens, _value);&#13;
        token.transfer(_to, _value);&#13;
    }&#13;
&#13;
    /// @dev Calculates the maximum amount of vested tokens&#13;
    /// @return Number of vested tokens to withdraw&#13;
    function calcMaxWithdraw()&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        uint maxTokens = SafeMath.mul(SafeMath.add(token.balanceOf(this), withdrawnTokens), SafeMath.sub(now,startDate)) / disbursementPeriod;&#13;
        //uint maxTokens = (token.balanceOf(this) + withdrawnTokens) * (now - startDate) / disbursementPeriod;&#13;
        if (withdrawnTokens &gt;= maxTokens || startDate &gt; now)&#13;
            return 0;&#13;
        if (SafeMath.sub(maxTokens, withdrawnTokens) &gt; token.totalSupply())&#13;
            return token.totalSupply();&#13;
        return SafeMath.sub(maxTokens, withdrawnTokens);&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/Owned.sol&#13;
&#13;
contract Owned {&#13;
  event OwnerAddition(address indexed owner);&#13;
&#13;
  event OwnerRemoval(address indexed owner);&#13;
&#13;
  // owner address to enable admin functions&#13;
  mapping (address =&gt; bool) public isOwner;&#13;
&#13;
  address[] public owners;&#13;
&#13;
  address public operator;&#13;
&#13;
  modifier onlyOwner {&#13;
&#13;
    require(isOwner[msg.sender]);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier onlyOperator {&#13;
    require(msg.sender == operator);&#13;
    _;&#13;
  }&#13;
&#13;
  function setOperator(address _operator) external onlyOwner {&#13;
    require(_operator != address(0));&#13;
    operator = _operator;&#13;
  }&#13;
&#13;
  function removeOwner(address _owner) public onlyOwner {&#13;
    require(owners.length &gt; 1);&#13;
    isOwner[_owner] = false;&#13;
    for (uint i = 0; i &lt; owners.length - 1; i++) {&#13;
      if (owners[i] == _owner) {&#13;
        owners[i] = owners[SafeMath.sub(owners.length, 1)];&#13;
        break;&#13;
      }&#13;
    }&#13;
    owners.length = SafeMath.sub(owners.length, 1);&#13;
    OwnerRemoval(_owner);&#13;
  }&#13;
&#13;
  function addOwner(address _owner) external onlyOwner {&#13;
    require(_owner != address(0));&#13;
    if(isOwner[_owner]) return;&#13;
    isOwner[_owner] = true;&#13;
    owners.push(_owner);&#13;
    OwnerAddition(_owner);&#13;
  }&#13;
&#13;
  function setOwners(address[] _owners) internal {&#13;
    for (uint i = 0; i &lt; _owners.length; i++) {&#13;
      require(_owners[i] != address(0));&#13;
      isOwner[_owners[i]] = true;&#13;
      OwnerAddition(_owners[i]);&#13;
    }&#13;
    owners = _owners;&#13;
  }&#13;
&#13;
  function getOwners() public constant returns (address[])  {&#13;
    return owners;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts/TokenLock.sol&#13;
&#13;
/**&#13;
this contract should be the address for disbursement contract.&#13;
It should not allow to disburse any token for a given time "initialLockTime"&#13;
lock "50%" of tokens for 10 years.&#13;
transfer 50% of tokens to a given address.&#13;
*/&#13;
contract TokenLock is Owned {&#13;
  using SafeMath for uint;&#13;
&#13;
  uint public shortLock;&#13;
&#13;
  uint public longLock;&#13;
&#13;
  uint public shortShare;&#13;
&#13;
  address public levAddress;&#13;
&#13;
  address public disbursement;&#13;
&#13;
  uint public longTermTokens;&#13;
&#13;
  modifier validAddress(address _address){&#13;
    require(_address != 0);&#13;
    _;&#13;
  }&#13;
&#13;
  function TokenLock(address[] _owners, uint _shortLock, uint _longLock, uint _shortShare) public {&#13;
    require(_longLock &gt; _shortLock);&#13;
    require(_shortLock &gt; 0);&#13;
    require(_shortShare &lt;= 100);&#13;
    setOwners(_owners);&#13;
    shortLock = block.timestamp.add(_shortLock);&#13;
    longLock = block.timestamp.add(_longLock);&#13;
    shortShare = _shortShare;&#13;
  }&#13;
&#13;
  function setup(address _disbursement, address _levToken) public onlyOwner {&#13;
    require(_disbursement != address(0));&#13;
    require(_levToken != address(0));&#13;
    disbursement = _disbursement;&#13;
    levAddress = _levToken;&#13;
  }&#13;
&#13;
  function transferShortTermTokens(address _wallet) public validAddress(_wallet) onlyOwner {&#13;
    require(now &gt; shortLock);&#13;
    uint256 tokenBalance = Token(levAddress).balanceOf(disbursement);&#13;
    // long term tokens can be set only once.&#13;
    if (longTermTokens == 0) {&#13;
      longTermTokens = tokenBalance.mul(100 - shortShare).div(100);&#13;
    }&#13;
    require(tokenBalance &gt; longTermTokens);&#13;
    uint256 amountToSend = tokenBalance.sub(longTermTokens);&#13;
    Disbursement(disbursement).withdraw(_wallet, amountToSend);&#13;
  }&#13;
&#13;
  function transferLongTermTokens(address _wallet) public validAddress(_wallet) onlyOwner {&#13;
    require(now &gt; longLock);&#13;
    // 1. Get how many tokens this contract has with a token instance and check this token balance&#13;
    uint256 tokenBalance = Token(levAddress).balanceOf(disbursement);&#13;
&#13;
    // 2. Transfer those tokens with the _shortShare percentage&#13;
    Disbursement(disbursement).withdraw(_wallet, tokenBalance);&#13;
  }&#13;
}