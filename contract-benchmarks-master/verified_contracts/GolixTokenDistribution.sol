pragma solidity 0.4.24;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/MintableToken.sol

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

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/PausableToken.sol

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

// File: contracts/GolixToken.sol

/**
 * @title Golix Token contract - ERC20 compatible token contract.
 * @author Gustavo Guimaraes - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="fd9a888e899c8b929a8894909c8f9c988ebd9a909c9491d39e9290">[email protected]</a>&gt;&#13;
 */&#13;
contract GolixToken is PausableToken, MintableToken {&#13;
    string public constant name = "Golix Token";&#13;
    string public constant symbol = "GLX";&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    /**&#13;
     * @dev Allow for staking of GLX tokens&#13;
     * function is called only from owner which is the GLX token distribution contract&#13;
     * is only triggered for a period of time and only if there are still tokens from crowdsale&#13;
     * @param staker Address of token holder&#13;
     * @param glxStakingContract Address where staking tokens goes to&#13;
     */&#13;
    function stakeGLX(address staker, address glxStakingContract) public onlyOwner {&#13;
        uint256 stakerGLXBalance = balanceOf(staker);&#13;
        balances[staker] = 0;&#13;
        balances[glxStakingContract] = balances[glxStakingContract].add(stakerGLXBalance);&#13;
        emit Transfer(staker, glxStakingContract, stakerGLXBalance);&#13;
    }&#13;
}&#13;
&#13;
// File: zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol&#13;
&#13;
/**&#13;
 * @title SafeERC20&#13;
 * @dev Wrappers around ERC20 operations that throw on failure.&#13;
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,&#13;
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.&#13;
 */&#13;
library SafeERC20 {&#13;
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {&#13;
    assert(token.transfer(to, value));&#13;
  }&#13;
&#13;
  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {&#13;
    assert(token.transferFrom(from, to, value));&#13;
  }&#13;
&#13;
  function safeApprove(ERC20 token, address spender, uint256 value) internal {&#13;
    assert(token.approve(spender, value));&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/VestTokenAllocation.sol&#13;
&#13;
/**&#13;
 * @title VestTokenAllocation contract&#13;
 * @author Gustavo Guimaraes - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="deb9abadaabfa8b1b9abb7b3bfacbfbbad9eb9b3bfb7b2f0bdb1b3">[email protected]</a>&gt;&#13;
 */&#13;
contract VestTokenAllocation is Ownable {&#13;
    using SafeMath for uint256;&#13;
    using SafeERC20 for ERC20;&#13;
&#13;
    uint256 public cliff;&#13;
    uint256 public start;&#13;
    uint256 public duration;&#13;
    uint256 public allocatedTokens;&#13;
    uint256 public canSelfDestruct;&#13;
&#13;
    mapping (address =&gt; uint256) public totalTokensLocked;&#13;
    mapping (address =&gt; uint256) public releasedTokens;&#13;
&#13;
    ERC20 public golix;&#13;
    address public tokenDistribution;&#13;
&#13;
    event Released(address beneficiary, uint256 amount);&#13;
&#13;
    /**&#13;
     * @dev creates the locking contract with vesting mechanism&#13;
     * as well as ability to set tokens for addresses and time contract can self-destruct&#13;
     * @param _token GolixToken address&#13;
     * @param _tokenDistribution GolixTokenDistribution contract address&#13;
     * @param _start timestamp representing the beginning of the token vesting process&#13;
     * @param _cliff duration in seconds of the cliff in which tokens will begin to vest. ie 1 year in secs&#13;
     * @param _duration time in seconds of the period in which the tokens completely vest. ie 4 years in secs&#13;
     * @param _canSelfDestruct timestamp of when contract is able to selfdestruct&#13;
     */&#13;
    function VestTokenAllocation&#13;
        (&#13;
            ERC20 _token,&#13;
            address _tokenDistribution,&#13;
            uint256 _start,&#13;
            uint256 _cliff,&#13;
            uint256 _duration,&#13;
            uint256 _canSelfDestruct&#13;
        )&#13;
        public&#13;
    {&#13;
        require(_token != address(0) &amp;&amp; _cliff != 0);&#13;
        require(_cliff &lt;= _duration);&#13;
        require(_start &gt; now);&#13;
        require(_canSelfDestruct &gt; _duration.add(_start));&#13;
&#13;
        duration = _duration;&#13;
        cliff = _start.add(_cliff);&#13;
        start = _start;&#13;
&#13;
        golix = ERC20(_token);&#13;
        tokenDistribution = _tokenDistribution;&#13;
        canSelfDestruct = _canSelfDestruct;&#13;
    }&#13;
&#13;
    modifier onlyOwnerOrTokenDistributionContract() {&#13;
        require(msg.sender == address(owner) || msg.sender == address(tokenDistribution));&#13;
        _;&#13;
    }&#13;
    /**&#13;
     * @dev Adds vested token allocation&#13;
     * @param beneficiary Ethereum address of a person&#13;
     * @param allocationValue Number of tokens allocated to person&#13;
     */&#13;
    function addVestTokenAllocation(address beneficiary, uint256 allocationValue)&#13;
        external&#13;
        onlyOwnerOrTokenDistributionContract&#13;
    {&#13;
        require(totalTokensLocked[beneficiary] == 0 &amp;&amp; beneficiary != address(0)); // can only add once.&#13;
&#13;
        allocatedTokens = allocatedTokens.add(allocationValue);&#13;
        require(allocatedTokens &lt;= golix.balanceOf(this));&#13;
&#13;
        totalTokensLocked[beneficiary] = allocationValue;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Transfers vested tokens to beneficiary.&#13;
     */&#13;
    function release() public {&#13;
        uint256 unreleased = releasableAmount();&#13;
&#13;
        require(unreleased &gt; 0);&#13;
&#13;
        releasedTokens[msg.sender] = releasedTokens[msg.sender].add(unreleased);&#13;
&#13;
        golix.safeTransfer(msg.sender, unreleased);&#13;
&#13;
        emit Released(msg.sender, unreleased);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Calculates the amount that has already vested but hasn't been released yet.&#13;
     */&#13;
    function releasableAmount() public view returns (uint256) {&#13;
        return vestedAmount().sub(releasedTokens[msg.sender]);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Calculates the amount that has already vested.&#13;
     */&#13;
    function vestedAmount() public view returns (uint256) {&#13;
        uint256 totalBalance = totalTokensLocked[msg.sender];&#13;
&#13;
        if (now &lt; cliff) {&#13;
            return 0;&#13;
        } else if (now &gt;= start.add(duration)) {&#13;
            return totalBalance;&#13;
        } else {&#13;
            return totalBalance.mul(now.sub(start)).div(duration);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev allow for selfdestruct possibility and sending funds to owner&#13;
     */&#13;
    function kill() public onlyOwner {&#13;
        require(now &gt;= canSelfDestruct);&#13;
        uint256 balance = golix.balanceOf(this);&#13;
&#13;
        if (balance &gt; 0) {&#13;
            golix.transfer(msg.sender, balance);&#13;
        }&#13;
&#13;
        selfdestruct(owner);&#13;
    }&#13;
}&#13;
&#13;
// File: zeppelin-solidity/contracts/crowdsale/Crowdsale.sol&#13;
&#13;
/**&#13;
 * @title Crowdsale&#13;
 * @dev Crowdsale is a base contract for managing a token crowdsale.&#13;
 * Crowdsales have a start and end timestamps, where investors can make&#13;
 * token purchases and the crowdsale will assign them tokens based&#13;
 * on a token per ETH rate. Funds collected are forwarded to a wallet&#13;
 * as they arrive.&#13;
 */&#13;
contract Crowdsale {&#13;
  using SafeMath for uint256;&#13;
&#13;
  // The token being sold&#13;
  MintableToken public token;&#13;
&#13;
  // start and end timestamps where investments are allowed (both inclusive)&#13;
  uint256 public startTime;&#13;
  uint256 public endTime;&#13;
&#13;
  // address where funds are collected&#13;
  address public wallet;&#13;
&#13;
  // how many token units a buyer gets per wei&#13;
  uint256 public rate;&#13;
&#13;
  // amount of raised money in wei&#13;
  uint256 public weiRaised;&#13;
&#13;
  /**&#13;
   * event for token purchase logging&#13;
   * @param purchaser who paid for the tokens&#13;
   * @param beneficiary who got the tokens&#13;
   * @param value weis paid for purchase&#13;
   * @param amount amount of tokens purchased&#13;
   */&#13;
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);&#13;
&#13;
&#13;
  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {&#13;
    require(_startTime &gt;= now);&#13;
    require(_endTime &gt;= _startTime);&#13;
    require(_rate &gt; 0);&#13;
    require(_wallet != address(0));&#13;
&#13;
    token = createTokenContract();&#13;
    startTime = _startTime;&#13;
    endTime = _endTime;&#13;
    rate = _rate;&#13;
    wallet = _wallet;&#13;
  }&#13;
&#13;
  // fallback function can be used to buy tokens&#13;
  function () external payable {&#13;
    buyTokens(msg.sender);&#13;
  }&#13;
&#13;
  // low level token purchase function&#13;
  function buyTokens(address beneficiary) public payable {&#13;
    require(beneficiary != address(0));&#13;
    require(validPurchase());&#13;
&#13;
    uint256 weiAmount = msg.value;&#13;
&#13;
    // calculate token amount to be created&#13;
    uint256 tokens = getTokenAmount(weiAmount);&#13;
&#13;
    // update state&#13;
    weiRaised = weiRaised.add(weiAmount);&#13;
&#13;
    token.mint(beneficiary, tokens);&#13;
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);&#13;
&#13;
    forwardFunds();&#13;
  }&#13;
&#13;
  // @return true if crowdsale event has ended&#13;
  function hasEnded() public view returns (bool) {&#13;
    return now &gt; endTime;&#13;
  }&#13;
&#13;
  // creates the token to be sold.&#13;
  // override this method to have crowdsale of a specific mintable token.&#13;
  function createTokenContract() internal returns (MintableToken) {&#13;
    return new MintableToken();&#13;
  }&#13;
&#13;
  // Override this method to have a way to add business logic to your crowdsale when buying&#13;
  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {&#13;
    return weiAmount.mul(rate);&#13;
  }&#13;
&#13;
  // send ether to the fund collection wallet&#13;
  // override to create custom fund forwarding mechanisms&#13;
  function forwardFunds() internal {&#13;
    wallet.transfer(msg.value);&#13;
  }&#13;
&#13;
  // @return true if the transaction can buy tokens&#13;
  function validPurchase() internal view returns (bool) {&#13;
    bool withinPeriod = now &gt;= startTime &amp;&amp; now &lt;= endTime;&#13;
    bool nonZeroPurchase = msg.value != 0;&#13;
    return withinPeriod &amp;&amp; nonZeroPurchase;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol&#13;
&#13;
/**&#13;
 * @title FinalizableCrowdsale&#13;
 * @dev Extension of Crowdsale where an owner can do extra work&#13;
 * after finishing.&#13;
 */&#13;
contract FinalizableCrowdsale is Crowdsale, Ownable {&#13;
  using SafeMath for uint256;&#13;
&#13;
  bool public isFinalized = false;&#13;
&#13;
  event Finalized();&#13;
&#13;
  /**&#13;
   * @dev Must be called after crowdsale ends, to do some extra finalization&#13;
   * work. Calls the contract's finalization function.&#13;
   */&#13;
  function finalize() onlyOwner public {&#13;
    require(!isFinalized);&#13;
    require(hasEnded());&#13;
&#13;
    finalization();&#13;
    Finalized();&#13;
&#13;
    isFinalized = true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Can be overridden to add finalization logic. The overriding function&#13;
   * should call super.finalization() to ensure the chain of finalization is&#13;
   * executed entirely.&#13;
   */&#13;
  function finalization() internal {&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/GolixTokenDistribution.sol&#13;
&#13;
/**&#13;
 * @title Golix token distribution contract - crowdsale contract for the Golix tokens.&#13;
 * @author Gustavo Guimaraes - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b4d3c1c7c0d5c2dbd3c1ddd9d5c6d5d1c7f4d3d9d5ddd89ad7dbd9">[email protected]</a>&gt;&#13;
 */&#13;
contract GolixTokenDistribution is FinalizableCrowdsale {&#13;
    uint256 constant public TOTAL_TOKENS_SUPPLY = 1274240097e18; // 1,274,240,097 tokens&#13;
    // =~ 10% for Marketing, investment fund, partners&#13;
    uint256 constant public MARKETING_SHARE = 127424009e18;&#13;
    // =~ 15% for issued to investors, shareholders&#13;
    uint256 constant public SHAREHOLDERS_SHARE = 191136015e18;&#13;
    // =~ 25% for founding team, future employees&#13;
    uint256 constant public FOUNDERS_SHARE = 318560024e18;&#13;
    uint256 constant public TOTAL_TOKENS_FOR_CROWDSALE = 637120049e18; // =~ 50 % of total token supply&#13;
&#13;
    VestTokenAllocation public teamVestTokenAllocation;&#13;
    VestTokenAllocation public contributorsVestTokenAllocation;&#13;
    address public marketingWallet;&#13;
    address public shareHoldersWallet;&#13;
&#13;
    bool public canFinalizeEarly;&#13;
    bool public isStakingPeriod;&#13;
&#13;
    mapping (address =&gt; uint256) public icoContributions;&#13;
&#13;
    event MintedTokensFor(address indexed investor, uint256 tokensPurchased);&#13;
    event GLXStaked(address indexed staker, uint256 amount);&#13;
&#13;
    /**&#13;
     * @dev Contract constructor function&#13;
     * @param _startTime The timestamp of the beginning of the crowdsale&#13;
     * @param _endTime Timestamp when the crowdsale will finish&#13;
     * @param _rate The token rate per ETH&#13;
     * @param _wallet Multisig wallet that will hold the crowdsale funds.&#13;
     * @param _marketingWallet address that will hold tokens for marketing campaign.&#13;
     * @param _shareHoldersWallet address that will distribute shareholders tokens.&#13;
     */&#13;
    function GolixTokenDistribution&#13;
        (&#13;
            uint256 _startTime,&#13;
            uint256 _endTime,&#13;
            uint256 _rate,&#13;
            address _wallet,&#13;
            address _marketingWallet,&#13;
            address _shareHoldersWallet&#13;
        )&#13;
        public&#13;
        FinalizableCrowdsale()&#13;
        Crowdsale(_startTime, _endTime, _rate, _wallet)&#13;
    {&#13;
        require(_marketingWallet != address(0) &amp;&amp; _shareHoldersWallet != address(0));&#13;
        require(&#13;
            MARKETING_SHARE + SHAREHOLDERS_SHARE + FOUNDERS_SHARE + TOTAL_TOKENS_FOR_CROWDSALE&#13;
            == TOTAL_TOKENS_SUPPLY&#13;
        );&#13;
&#13;
        marketingWallet = _marketingWallet;&#13;
        shareHoldersWallet = _shareHoldersWallet;&#13;
&#13;
        GolixToken(token).pause();&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Mint tokens for crowdsale participants&#13;
     * @param investorsAddress List of Purchasers addresses&#13;
     * @param amountOfTokens List of token amounts for investor&#13;
     */&#13;
    function mintTokensForCrowdsaleParticipants(address[] investorsAddress, uint256[] amountOfTokens)&#13;
        external&#13;
        onlyOwner&#13;
    {&#13;
        require(investorsAddress.length == amountOfTokens.length);&#13;
&#13;
        for (uint256 i = 0; i &lt; investorsAddress.length; i++) {&#13;
            require(token.totalSupply().add(amountOfTokens[i]) &lt;= TOTAL_TOKENS_FOR_CROWDSALE);&#13;
&#13;
            token.mint(investorsAddress[i], amountOfTokens[i]);&#13;
            icoContributions[investorsAddress[i]] = icoContributions[investorsAddress[i]].add(amountOfTokens[i]);&#13;
&#13;
            emit MintedTokensFor(investorsAddress[i], amountOfTokens[i]);&#13;
        }&#13;
    }&#13;
    &#13;
    // override buytokens so all minting comes from Golix&#13;
    function buyTokens(address beneficiary) public payable {&#13;
        revert();&#13;
    }&#13;
    &#13;
    /**&#13;
     * @dev Set addresses which should receive the vested team tokens share on finalization&#13;
     * @param _teamVestTokenAllocation address of team and advisor allocation contract&#13;
     * @param _contributorsVestTokenAllocation address of ico contributors&#13;
     * who for glx staking event in case there is still left over tokens from crowdsale&#13;
     */&#13;
    function setVestTokenAllocationAddresses&#13;
        (&#13;
            address _teamVestTokenAllocation,&#13;
            address _contributorsVestTokenAllocation&#13;
        )&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        require(_teamVestTokenAllocation != address(0) &amp;&amp; _contributorsVestTokenAllocation != address(0));&#13;
&#13;
        teamVestTokenAllocation = VestTokenAllocation(_teamVestTokenAllocation);&#13;
        contributorsVestTokenAllocation = VestTokenAllocation(_contributorsVestTokenAllocation);&#13;
    }&#13;
&#13;
    // overriding Crowdsale#hasEnded to add cap logic&#13;
    // @return true if crowdsale event has ended&#13;
    function hasEnded() public view returns (bool) {&#13;
        if (canFinalizeEarly) {&#13;
            return true;&#13;
        }&#13;
&#13;
        return super.hasEnded();&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Allow for staking of GLX tokens from crowdsale participants&#13;
     * only works if tokens from token distribution are not sold out.&#13;
     * investors must have GLX tokens in the same amount as it purchased during crowdsale&#13;
     */&#13;
    function stakeGLXForContributors() public {&#13;
        uint256 senderGlxBalance = token.balanceOf(msg.sender);&#13;
        require(senderGlxBalance == icoContributions[msg.sender] &amp;&amp; isStakingPeriod);&#13;
&#13;
        GolixToken(token).stakeGLX(msg.sender, contributorsVestTokenAllocation);&#13;
        contributorsVestTokenAllocation.addVestTokenAllocation(msg.sender, senderGlxBalance);&#13;
        emit GLXStaked(msg.sender, senderGlxBalance);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev enables early finalization of crowdsale&#13;
    */&#13;
    function prepareForEarlyFinalization() public onlyOwner {&#13;
        canFinalizeEarly = true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev disables staking period&#13;
    */&#13;
    function disableStakingPeriod() public onlyOwner {&#13;
        isStakingPeriod = false;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Creates Golix token contract. This is called on the constructor function of the Crowdsale contract&#13;
     */&#13;
    function createTokenContract() internal returns (MintableToken) {&#13;
        return new GolixToken();&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev finalizes crowdsale&#13;
     */&#13;
    function finalization() internal {&#13;
        // This must have been set manually prior to finalize() call.&#13;
        require(teamVestTokenAllocation != address(0) &amp;&amp; contributorsVestTokenAllocation != address(0));&#13;
&#13;
        if (TOTAL_TOKENS_FOR_CROWDSALE &gt; token.totalSupply()) {&#13;
            uint256 remainingTokens = TOTAL_TOKENS_FOR_CROWDSALE.sub(token.totalSupply());&#13;
            token.mint(contributorsVestTokenAllocation, remainingTokens);&#13;
            isStakingPeriod = true;&#13;
        }&#13;
&#13;
        // final minting&#13;
        token.mint(marketingWallet, MARKETING_SHARE);&#13;
        token.mint(shareHoldersWallet, SHAREHOLDERS_SHARE);&#13;
        token.mint(teamVestTokenAllocation, FOUNDERS_SHARE);&#13;
&#13;
        token.finishMinting();&#13;
        GolixToken(token).unpause();&#13;
        super.finalization();&#13;
    }&#13;
}