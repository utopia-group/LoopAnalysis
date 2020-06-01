pragma solidity ^0.4.18;

// ==== Open Zeppelin library ===

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
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="fe8c9b939d91becc">[email protected]</span>π.com&gt;&#13;
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
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="f082959d939fb0c2">[email protected]</span>π.com&gt;&#13;
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
/**&#13;
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="bcced9d1dfd3fc8e">[email protected]</span>π.com&gt;&#13;
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
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="f280979f919db2c0">[email protected]</span>π.com&gt;&#13;
 * @dev Solves a class of errors where a contract accidentally becomes owner of Ether, Tokens or&#13;
 * Owned contracts. See respective base contracts for details.&#13;
 */&#13;
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {&#13;
}&#13;
&#13;
/**&#13;
 * @title Destructible&#13;
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.&#13;
 */&#13;
contract Destructible is Ownable {&#13;
&#13;
  function Destructible() public payable { }&#13;
&#13;
  /**&#13;
   * @dev Transfers the current balance to the owner and terminates the contract.&#13;
   */&#13;
  function destroy() onlyOwner public {&#13;
    selfdestruct(owner);&#13;
  }&#13;
&#13;
  function destroyAndSend(address _recipient) onlyOwner public {&#13;
    selfdestruct(_recipient);&#13;
  }&#13;
}&#13;
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
   * approve should be called when allowed[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   */&#13;
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
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
&#13;
// ==== AALM Contracts ===&#13;
&#13;
contract AALMToken is MintableToken, NoOwner { //MintableToken is StandardToken, Ownable&#13;
    string public symbol = 'AALM';&#13;
    string public name = 'Alm Token';&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    address founder;    //founder address to allow him transfer tokens while minting&#13;
    function init(address _founder) onlyOwner public{&#13;
        founder = _founder;&#13;
    }&#13;
&#13;
    /**&#13;
     * Allow transfer only after crowdsale finished&#13;
     */&#13;
    modifier canTransfer() {&#13;
        require(mintingFinished || msg.sender == founder);&#13;
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
}&#13;
&#13;
contract AALMCrowdsale is Ownable, CanReclaimToken, Destructible {&#13;
    using SafeMath for uint256;    &#13;
&#13;
    uint32 private constant PERCENT_DIVIDER = 100;&#13;
&#13;
    struct BulkBonus {&#13;
        uint256 minAmount;      //Minimal amount to receive bonus (including this amount)&#13;
        uint32 bonusPercent;    //a bonus percent, so that bonus = amount.mul(bonusPercent).div(PERCENT_DIVIDER)&#13;
    }&#13;
&#13;
    uint64 public startTimestamp;   //Crowdsale start timestamp&#13;
    uint64 public endTimestamp;     //Crowdsale end timestamp&#13;
    uint256 public minCap;          //minimal amount of sold tokens (if not reached - ETH may be refunded)&#13;
    uint256 public hardCap;         //total amount of tokens available&#13;
    uint256 public baseRate;        //how many tokens will be minted for 1 ETH (like 1000 AALM for 1 ETH) without bonuses&#13;
&#13;
    uint32 public maxTimeBonusPercent;  //A maximum time bonus percent: at the start of crowdsale timeBonus = value.mul(baseRate).mul(maxTimeBonusPercent).div(PERCENT_DIVIDER)&#13;
    uint32 public referrerBonusPercent; //A bonus percent that refferer will receive, so that referrerBonus = value.mul(baseRate).mul(referrerBonusPercent).div(PERCENT_DIVIDER)&#13;
    uint32 public referralBonusPercent; //A bonus percent that refferal will receive, so that referralBonus = value.mul(baseRate).mul(referralBonusPercent).div(PERCENT_DIVIDER)&#13;
    BulkBonus[] public bulkBonuses;     //Bulk Bonuses sorted by ether amount (minimal amount first)&#13;
  &#13;
&#13;
    uint256 public tokensMinted;    //total amount of minted tokens&#13;
    uint256 public tokensSold;      //total amount of tokens sold(!) on ICO, including all bonuses&#13;
    uint256 public collectedEther;  //total amount of ether collected during ICO (without Pre-ICO)&#13;
&#13;
    mapping(address =&gt; uint256) contributions; //amount of ether (in wei)received from a buyer&#13;
&#13;
    AALMToken public token;&#13;
    TokenVesting public founderVestingContract; //Contract which holds Founder's tokens&#13;
&#13;
    bool public finalized;&#13;
&#13;
    function AALMCrowdsale(uint64 _startTimestamp, uint64 _endTimestamp, uint256 _hardCap, uint256 _minCap, &#13;
        uint256 _founderTokensImmediate, uint256 _founderTokensVested, uint256 _vestingDuration,&#13;
        uint256 _baseRate, uint32 _maxTimeBonusPercent, uint32 _referrerBonusPercent, uint32 _referralBonusPercent, &#13;
        uint256[] bulkBonusMinAmounts, uint32[] bulkBonusPercents &#13;
        ) public {&#13;
        require(_startTimestamp &gt; now);&#13;
        require(_startTimestamp &lt; _endTimestamp);&#13;
        startTimestamp = _startTimestamp;&#13;
        endTimestamp = _endTimestamp;&#13;
&#13;
        require(_hardCap &gt; 0);&#13;
        hardCap = _hardCap;&#13;
&#13;
        minCap = _minCap;&#13;
&#13;
        initRatesAndBonuses(_baseRate, _maxTimeBonusPercent, _referrerBonusPercent, _referralBonusPercent, bulkBonusMinAmounts, bulkBonusPercents);&#13;
&#13;
        token = new AALMToken();&#13;
        token.init(owner);&#13;
&#13;
        require(_founderTokensImmediate.add(_founderTokensVested) &lt; _hardCap);&#13;
        mintTokens(owner, _founderTokensImmediate);&#13;
&#13;
        founderVestingContract = new TokenVesting(owner, endTimestamp, 0, _vestingDuration, false);&#13;
        mintTokens(founderVestingContract, _founderTokensVested);&#13;
    }&#13;
&#13;
    function initRatesAndBonuses(&#13;
        uint256 _baseRate, uint32 _maxTimeBonusPercent, uint32 _referrerBonusPercent, uint32 _referralBonusPercent, &#13;
        uint256[] bulkBonusMinAmounts, uint32[] bulkBonusPercents &#13;
        ) internal {&#13;
&#13;
        require(_baseRate &gt; 0);&#13;
        baseRate = _baseRate;&#13;
&#13;
        maxTimeBonusPercent = _maxTimeBonusPercent;&#13;
        referrerBonusPercent = _referrerBonusPercent;&#13;
        referralBonusPercent = _referralBonusPercent;&#13;
&#13;
        uint256 prevBulkAmount = 0;&#13;
        require(bulkBonusMinAmounts.length == bulkBonusPercents.length);&#13;
        bulkBonuses.length = bulkBonusMinAmounts.length;&#13;
        for(uint8 i=0; i &lt; bulkBonuses.length; i++){&#13;
            bulkBonuses[i] = BulkBonus({minAmount:bulkBonusMinAmounts[i], bonusPercent:bulkBonusPercents[i]});&#13;
            BulkBonus storage bb = bulkBonuses[i];&#13;
            require(prevBulkAmount &lt; bb.minAmount);&#13;
            prevBulkAmount = bb.minAmount;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Distribute tokens sold during Pre-ICO&#13;
    * @param beneficiaries Array of beneficiari addresses&#13;
    * @param amounts Array of amounts of tokens to send&#13;
    */&#13;
    function distributePreICOTokens(address[] beneficiaries, uint256[] amounts) onlyOwner public {&#13;
        require(beneficiaries.length == amounts.length);&#13;
        for(uint256 i=0; i&lt;beneficiaries.length; i++){&#13;
            mintTokens(beneficiaries[i], amounts[i]);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Sell tokens directly, without referral bonuses&#13;
    */&#13;
    function () payable public {&#13;
        sale(msg.sender, msg.value, address(0));&#13;
    }&#13;
    /**&#13;
    * @notice Sell tokens via RefferalCrowdsale contract&#13;
    * @param beneficiary Original sender (buyer)&#13;
    * @param referrer The partner who referered the buyer&#13;
    */&#13;
    function referralSale(address beneficiary, address referrer) payable public returns(bool) {&#13;
        sale(beneficiary, msg.value, referrer);&#13;
        return true;&#13;
    }&#13;
    /**&#13;
    * @dev Internal functions to sell tokens&#13;
    * @param beneficiary who should receive tokens (the buyer)&#13;
    * @param value of ether sent by buyer&#13;
    * @param referrer who should receive referrer bonus, if any. Zero address if no referral bonuses should be paid&#13;
    */&#13;
    function sale(address beneficiary, uint256 value, address referrer) internal {&#13;
        require(crowdsaleOpen());&#13;
        require(value &gt; 0);&#13;
        collectedEther = collectedEther.add(value);&#13;
        contributions[beneficiary] = contributions[beneficiary].add(value);&#13;
        uint256 amount;&#13;
        if(referrer == address(0)){&#13;
            amount = getTokensWithBonuses(value, false);&#13;
        } else{&#13;
            amount = getTokensWithBonuses(value, true);&#13;
            uint256 referrerAmount  = getReferrerBonus(value);&#13;
            tokensSold = tokensSold.add(referrerAmount);&#13;
            mintTokens(referrer, referrerAmount);&#13;
        }&#13;
        tokensSold = tokensSold.add(amount);&#13;
        mintTokens(beneficiary, amount);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Mint tokens for purshases with Non-Ether currencies&#13;
    * @param beneficiary whom to send tokend&#13;
    * @param amount how much tokens to send&#13;
    * param message reason why we are sending tokens (not stored anythere, only in transaction itself)&#13;
    */&#13;
    function saleNonEther(address beneficiary, uint256 amount, string /*message*/) public onlyOwner {&#13;
        mintTokens(beneficiary, amount);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice If crowdsale is running&#13;
    */&#13;
    function crowdsaleOpen() view public returns(bool) {&#13;
        return (!finalized) &amp;&amp; (tokensMinted &lt; hardCap) &amp;&amp; (startTimestamp &lt;= now) &amp;&amp; (now &lt;= endTimestamp);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Calculates how many tokens are left to sale&#13;
    * @return amount of tokens left before hard cap reached&#13;
    */&#13;
    function getTokensLeft() view public returns(uint256) {&#13;
        return hardCap.sub(tokensMinted);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Calculates how many tokens one should receive at curent time for a specified value of ether&#13;
    * @param value of ether to get bonus for&#13;
    * @param withReferralBonus if should add referral bonus&#13;
    * @return bonus tokens&#13;
    */&#13;
    function getTokensWithBonuses(uint256 value, bool withReferralBonus) view public returns(uint256) {&#13;
        uint256 amount = value.mul(baseRate);&#13;
        amount = amount.add(getTimeBonus(value)).add(getBulkBonus(value));&#13;
        if(withReferralBonus){&#13;
            amount = amount.add(getReferralBonus(value));&#13;
        }&#13;
        return amount;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Calculates current time bonus&#13;
    * @param value of ether to get bonus for&#13;
    * @return bonus tokens&#13;
    */&#13;
    function getTimeBonus(uint256 value) view public returns(uint256) {&#13;
        uint256 maxBonus = value.mul(baseRate).mul(maxTimeBonusPercent).div(PERCENT_DIVIDER);&#13;
        return maxBonus.mul(endTimestamp - now).div(endTimestamp - startTimestamp);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Calculates a bulk bonus for a specified value of ether&#13;
    * @param value of ether to get bonus for&#13;
    * @return bonus tokens&#13;
    */&#13;
    function getBulkBonus(uint256 value) view public returns(uint256) {&#13;
        for(uint8 i=uint8(bulkBonuses.length); i &gt; 0; i--){&#13;
            uint8 idx = i - 1; //if i  = bulkBonuses.length-1 to 0, i-- fails on last iteration&#13;
            if (value &gt;= bulkBonuses[idx].minAmount) {&#13;
                return value.mul(baseRate).mul(bulkBonuses[idx].bonusPercent).div(PERCENT_DIVIDER);&#13;
            }&#13;
        }&#13;
        return 0;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Calculates referrer bonus&#13;
    * @param value of ether  to get bonus for&#13;
    * @return bonus tokens&#13;
    */&#13;
    function getReferrerBonus(uint256 value) view public returns(uint256) {&#13;
        return value.mul(baseRate).mul(referrerBonusPercent).div(PERCENT_DIVIDER);&#13;
    }&#13;
    /**&#13;
    * @notice Calculates referral bonus&#13;
    * @param value of ether  to get bonus for&#13;
    * @return bonus tokens&#13;
    */&#13;
    function getReferralBonus(uint256 value) view public returns(uint256) {&#13;
        return value.mul(baseRate).mul(referralBonusPercent).div(PERCENT_DIVIDER);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Helper function to mint tokens and increase tokensMinted counter&#13;
    */&#13;
    function mintTokens(address beneficiary, uint256 amount) internal {&#13;
        tokensMinted = tokensMinted.add(amount);&#13;
        require(tokensMinted &lt;= hardCap);&#13;
        assert(token.mint(beneficiary, amount));&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Sends all contributed ether back if minimum cap is not reached by the end of crowdsale&#13;
    */&#13;
    function refund() public returns(bool){&#13;
        return refundTo(msg.sender);&#13;
    }&#13;
    function refundTo(address beneficiary) public returns(bool) {&#13;
        require(contributions[beneficiary] &gt; 0);&#13;
        require(finalized || (now &gt; endTimestamp));&#13;
        require(tokensSold &lt; minCap);&#13;
&#13;
        uint256 _refund = contributions[beneficiary];&#13;
        contributions[beneficiary] = 0;&#13;
        beneficiary.transfer(_refund);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Closes crowdsale, finishes minting (allowing token transfers), transfers token ownership to the owner&#13;
    */&#13;
    function finalizeCrowdsale() public onlyOwner {&#13;
        finalized = true;&#13;
        token.finishMinting();&#13;
        token.transferOwnership(owner);&#13;
        if(tokensSold &gt;= minCap &amp;&amp; this.balance &gt; 0){&#13;
            owner.transfer(this.balance);&#13;
        }&#13;
    }&#13;
    /**&#13;
    * @notice Claim collected ether without closing crowdsale&#13;
    */&#13;
    function claimEther() public onlyOwner {&#13;
        require(tokensSold &gt;= minCap);&#13;
        owner.transfer(this.balance);&#13;
    }&#13;
&#13;
}