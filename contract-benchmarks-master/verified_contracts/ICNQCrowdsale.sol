pragma solidity 0.4.19;

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

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/token/BasicToken.sol

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

// File: zeppelin-solidity/contracts/token/ERC20.sol

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

// File: zeppelin-solidity/contracts/token/StandardToken.sol

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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

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

// File: zeppelin-solidity/contracts/token/MintableToken.sol

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
    totalSupply = totalSupply.add(_amount);
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

// File: zeppelin-solidity/contracts/token/PausableToken.sol

/**
 * @title Pausable token
 *
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

// File: contracts/ICNQToken.sol

/**
 * @title ICNQ Token contract - ERC20 compatible token contract.
 * @author Gustavo Guimaraes - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="365143454257405951435f5b574457534576515b575f5a1855595b">[email protected]</a>&gt;&#13;
 */&#13;
contract ICNQToken is PausableToken, MintableToken {&#13;
    string public constant name = "Iconiq Lab Token";&#13;
    string public constant symbol = "ICNQ";&#13;
    uint8 public constant decimals = 18;&#13;
}&#13;
&#13;
// File: contracts/Whitelist.sol&#13;
&#13;
contract Whitelist is Ownable {&#13;
    mapping(address =&gt; bool) public allowedAddresses;&#13;
&#13;
    event WhitelistUpdated(uint256 timestamp, string operation, address indexed member);&#13;
&#13;
    function addToWhitelist(address[] _addresses) public onlyOwner {&#13;
        for (uint256 i = 0; i &lt; _addresses.length; i++) {&#13;
            allowedAddresses[_addresses[i]] = true;&#13;
            WhitelistUpdated(now, "Added", _addresses[i]);&#13;
        }&#13;
    }&#13;
&#13;
    function removeFromWhitelist(address[] _addresses) public onlyOwner {&#13;
        for (uint256 i = 0; i &lt; _addresses.length; i++) {&#13;
            allowedAddresses[_addresses[i]] = false;&#13;
            WhitelistUpdated(now, "Removed", _addresses[i]);&#13;
        }&#13;
    }&#13;
&#13;
    function isWhitelisted(address _address) public view returns (bool) {&#13;
        return allowedAddresses[_address];&#13;
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
  // creates the token to be sold.&#13;
  // override this method to have crowdsale of a specific mintable token.&#13;
  function createTokenContract() internal returns (MintableToken) {&#13;
    return new MintableToken();&#13;
  }&#13;
&#13;
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
    uint256 tokens = weiAmount.mul(rate);&#13;
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
  // @return true if crowdsale event has ended&#13;
  function hasEnded() public view returns (bool) {&#13;
    return now &gt; endTime;&#13;
  }&#13;
&#13;
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
// File: contracts/ICNQCrowdsale.sol&#13;
&#13;
/**&#13;
 * @title ICNQ Crowdsale contract - crowdsale contract for the ICNQ tokens.&#13;
 * @author Gustavo Guimaraes - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="375042444356415850425e5a564556524477505a565e5b1954585a">[email protected]</a>&gt;&#13;
 */&#13;
contract ICNQCrowdsale is FinalizableCrowdsale, Pausable {&#13;
    uint256 public presaleEndTime;&#13;
&#13;
    // token supply figures&#13;
    uint256 constant public TOTAL_TOKENS_SUPPLY = 20000000e18; // 20M&#13;
&#13;
    uint256 public constant OPTIONAL_POOL = 4650000e18; // 4.65M&#13;
    uint256 public constant FINLAB_PRESALE = 2000000e18; // 2M&#13;
    uint256 public constant EOS = 2000000e18; // 2M&#13;
    uint256 public constant US_INSTITUTIONAL = 1500000e18; // 1.5M&#13;
    uint256 public constant PRIVATE_SALE_TOTAL = OPTIONAL_POOL + FINLAB_PRESALE + EOS + US_INSTITUTIONAL; // 10.15M&#13;
&#13;
    // 10.15 of the private sale + 750K for presale&#13;
    uint256 constant public PRE_SALE_TOTAL_TOKENS = PRIVATE_SALE_TOTAL + 750000e18;&#13;
    // 10.15 of the private sale + 750K for presale + 3M for crowdsale&#13;
    uint256 constant public TOTAL_TOKENS_FOR_CROWDSALE = PRE_SALE_TOTAL_TOKENS + 3000000e18;&#13;
&#13;
    uint256 public constant TEAM_ADVISORS_SHARE = 3100000e18; // 3.1M&#13;
    uint256 public constant COMPANY_SHARE = 2000000e18; // 2M&#13;
    uint256 public constant BOUNTY_CAMPAIGN_SHARE = 1000000e18; // 1M&#13;
&#13;
    address public teamAndAdvisorsAllocation;&#13;
&#13;
    event PrivateInvestorTokenPurchase(address indexed investor, uint256 tokensPurchased);&#13;
    event TokenRateChanged(uint256 previousRate, uint256 newRate);&#13;
&#13;
    // external contracts&#13;
    Whitelist public whitelist;&#13;
&#13;
    /**&#13;
     * @dev Contract constructor function&#13;
     * @param _startTime The timestamp of the beginning of the crowdsale&#13;
     * @param _presaleEndTime End of presale in timestamp&#13;
     * @param _endTime Timestamp when the crowdsale will finish&#13;
     * @param _whitelist contract containing the whitelisted addresses&#13;
     * @param _rate The token rate per ETH&#13;
     * @param _wallet Multisig wallet that will hold the crowdsale funds.&#13;
     */&#13;
    function ICNQCrowdsale&#13;
        (&#13;
            uint256 _startTime,&#13;
            uint256 _presaleEndTime,&#13;
            uint256 _endTime,&#13;
            address _whitelist,&#13;
            uint256 _rate,&#13;
            address _wallet&#13;
        )&#13;
        public&#13;
        FinalizableCrowdsale()&#13;
        Crowdsale(_startTime, _endTime, _rate, _wallet)&#13;
    {&#13;
        require(_whitelist != address(0));&#13;
&#13;
        presaleEndTime = _presaleEndTime;&#13;
        whitelist = Whitelist(_whitelist);&#13;
        ICNQToken(token).pause();&#13;
    }&#13;
&#13;
    modifier whitelisted(address beneficiary) {&#13;
        require(whitelist.isWhitelisted(beneficiary));&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Mint tokens for private investors before crowdsale starts&#13;
     * @param investorsAddress Purchaser's address&#13;
     * @param tokensPurchased Tokens purchased during pre crowdsale&#13;
     */&#13;
    function mintTokenForPrivateInvestors(address investorsAddress, uint256 tokensPurchased)&#13;
        external&#13;
        onlyOwner&#13;
    {&#13;
        require(now &lt; startTime &amp;&amp; investorsAddress != address(0));&#13;
        require(token.totalSupply().add(tokensPurchased) &lt;= PRIVATE_SALE_TOTAL);&#13;
&#13;
        token.mint(investorsAddress, tokensPurchased);&#13;
        PrivateInvestorTokenPurchase(investorsAddress, tokensPurchased);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev change crowdsale rate&#13;
     * @param newRate Figure that corresponds to the new rate per token&#13;
     */&#13;
    function setRate(uint256 newRate) external onlyOwner {&#13;
        require(newRate != 0);&#13;
&#13;
        TokenRateChanged(rate, newRate);&#13;
        rate = newRate;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Set the address which should receive the vested team tokens share on finalization&#13;
     * @param _teamAndAdvisorsAllocation address of team and advisor allocation contract&#13;
     */&#13;
    function setTeamWalletAddress(address _teamAndAdvisorsAllocation) public onlyOwner {&#13;
        // only able to set teamAndAdvisorsAllocation once.&#13;
        // TeamAndAdvisorsAllocation contract requires token contract already deployed.&#13;
        // token contract is created within crowdsale,&#13;
        // thus the TeamAndAdvisorsAllocation must be set up after crowdsale's deployment&#13;
        require(teamAndAdvisorsAllocation == address(0x0) &amp;&amp; _teamAndAdvisorsAllocation != address(0x0));&#13;
&#13;
        teamAndAdvisorsAllocation = _teamAndAdvisorsAllocation;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev payable function that allow token purchases&#13;
     * @param beneficiary Address of the purchaser&#13;
     */&#13;
    function buyTokens(address beneficiary)&#13;
        public&#13;
        whenNotPaused&#13;
        whitelisted(beneficiary)&#13;
        payable&#13;
    {&#13;
        // minimum of 1 ether for purchase in the public presale and sale&#13;
        require(beneficiary != address(0) &amp;&amp; msg.value &gt;= 1 ether);&#13;
        require(validPurchase() &amp;&amp; token.totalSupply() &lt; TOTAL_TOKENS_FOR_CROWDSALE);&#13;
&#13;
        uint256 weiAmount = msg.value;&#13;
&#13;
        // calculate token amount to be created&#13;
        uint256 tokens = weiAmount.mul(rate);&#13;
&#13;
        if (now &gt;= startTime &amp;&amp; now &lt;= presaleEndTime) {&#13;
            uint256 bonus = 50;&#13;
            uint256 bonusTokens = tokens.mul(bonus).div(100);&#13;
&#13;
            tokens = tokens.add(bonusTokens);&#13;
            require(token.totalSupply().add(tokens) &lt;= PRE_SALE_TOTAL_TOKENS);&#13;
        }&#13;
&#13;
        //remainder logic&#13;
        if (token.totalSupply().add(tokens) &gt; TOTAL_TOKENS_FOR_CROWDSALE) {&#13;
            tokens = TOTAL_TOKENS_FOR_CROWDSALE.sub(token.totalSupply());&#13;
            weiAmount = tokens.div(rate);&#13;
&#13;
            // send remainder wei to sender&#13;
            uint256 remainderAmount = msg.value.sub(weiAmount);&#13;
            msg.sender.transfer(remainderAmount);&#13;
        }&#13;
&#13;
        // update state&#13;
        weiRaised = weiRaised.add(weiAmount);&#13;
&#13;
        token.mint(beneficiary, tokens);&#13;
&#13;
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);&#13;
&#13;
        forwardFunds(weiAmount);&#13;
    }&#13;
&#13;
    // overriding Crowdsale#hasEnded to add cap logic&#13;
    // @return true if crowdsale event has ended&#13;
    function hasEnded() public view returns (bool) {&#13;
        if (token.totalSupply() == TOTAL_TOKENS_FOR_CROWDSALE) {&#13;
            return true;&#13;
        }&#13;
&#13;
        return super.hasEnded();&#13;
    }&#13;
&#13;
    // send ether to the fund collection wallet&#13;
    // override to create custom fund forwarding mechanisms&#13;
    function forwardFunds(uint256 weiAmount) internal {&#13;
        wallet.transfer(weiAmount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev finalizes crowdsale&#13;
     */&#13;
    function finalization() internal {&#13;
        // This must have been set manually prior to finalize().&#13;
        require(teamAndAdvisorsAllocation != address(0));&#13;
&#13;
        token.mint(wallet, COMPANY_SHARE);&#13;
        token.mint(wallet, BOUNTY_CAMPAIGN_SHARE); // allocate BOUNTY_CAMPAIGN_SHARE to company wallet as well&#13;
        token.mint(teamAndAdvisorsAllocation, TEAM_ADVISORS_SHARE);&#13;
&#13;
        if (TOTAL_TOKENS_SUPPLY &gt; token.totalSupply()) {&#13;
            uint256 remainingTokens = TOTAL_TOKENS_SUPPLY.sub(token.totalSupply());&#13;
            // burn remaining tokens&#13;
            token.mint(address(0), remainingTokens);&#13;
        }&#13;
&#13;
        token.finishMinting();&#13;
        ICNQToken(token).unpause();&#13;
        super.finalization();&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Creates ICNQ token contract. This is called on the constructor function of the Crowdsale contract&#13;
     */&#13;
    function createTokenContract() internal returns (MintableToken) {&#13;
        return new ICNQToken();&#13;
    }&#13;
}