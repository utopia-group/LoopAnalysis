pragma solidity 0.4.24;

// File: contracts\lib\Ownable.sol

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
    require(msg.sender == owner, "only owner is able to call this function");
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

// File: contracts\lib\Pausable.sol

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
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

// File: contracts\lib\SafeMath.sol

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

// File: contracts\lib\Crowdsale.sol

/**
 * @title Crowdsale - modified from zeppelin-solidity library
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;


    // event for token purchase logging
    // purchaser who paid for the tokens
    // beneficiary who got the tokens
    // value weis paid for purchase
    // amount amount of tokens purchased
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function initCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
        require(
            startTime == 0 && endTime == 0 && rate == 0 && wallet == address(0),
            "Global variables must be empty when initializing crowdsale!"
        );
        require(_startTime >= now, "_startTime must be more than current time!");
        require(_endTime >= _startTime, "_endTime must be more than _startTime!");
        require(_wallet != address(0), "_wallet parameter must not be empty!");

        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = _wallet;
    }

    // @return true if crowdsale event has ended
    function hasEnded() public view returns (bool) {
        return now > endTime;
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }
}

// File: contracts\lib\FinalizableCrowdsale.sol

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }
}

// File: contracts\lib\ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts\Whitelist.sol

/**
 * @title Whitelist - crowdsale whitelist contract
 * @author Gustavo Guimaraes - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d2b5a7a1a6b3a4bd92a1a6b3a0b0b3a1b7fcb1bd">[email protected]</a>&gt;&#13;
 */&#13;
contract Whitelist is Ownable {&#13;
    mapping(address =&gt; bool) public allowedAddresses;&#13;
&#13;
    event WhitelistUpdated(uint256 timestamp, string operation, address indexed member);&#13;
&#13;
    /**&#13;
    * @dev Adds single address to whitelist.&#13;
    * @param _address Address to be added to the whitelist&#13;
    */&#13;
    function addToWhitelist(address _address) external onlyOwner {&#13;
        allowedAddresses[_address] = true;&#13;
        emit WhitelistUpdated(now, "Added", _address);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev add various whitelist addresses&#13;
     * @param _addresses Array of ethereum addresses&#13;
     */&#13;
    function addManyToWhitelist(address[] _addresses) external onlyOwner {&#13;
        for (uint256 i = 0; i &lt; _addresses.length; i++) {&#13;
            allowedAddresses[_addresses[i]] = true;&#13;
            emit WhitelistUpdated(now, "Added", _addresses[i]);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev remove whitelist addresses&#13;
     * @param _addresses Array of ethereum addresses&#13;
     */&#13;
    function removeManyFromWhitelist(address[] _addresses) public onlyOwner {&#13;
        for (uint256 i = 0; i &lt; _addresses.length; i++) {&#13;
            allowedAddresses[_addresses[i]] = false;&#13;
            emit WhitelistUpdated(now, "Removed", _addresses[i]);&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
// File: contracts\TokenSaleInterface.sol&#13;
&#13;
/**&#13;
 * @title TokenSale contract interface&#13;
 */&#13;
interface TokenSaleInterface {&#13;
    function init&#13;
    (&#13;
        uint256 _startTime,&#13;
        uint256 _endTime,&#13;
        address _whitelist,&#13;
        address _starToken,&#13;
        address _companyToken,&#13;
        uint256 _rate,&#13;
        uint256 _starRate,&#13;
        address _wallet,&#13;
        uint256 _crowdsaleCap,&#13;
        bool    _isWeiAccepted&#13;
    )&#13;
    external;&#13;
}&#13;
&#13;
// File: contracts\TokenSaleForAlreadyDeployedERC20Tokens.sol&#13;
&#13;
/**&#13;
 * @title Token Sale contract - crowdsale of company tokens.&#13;
 * @author Gustavo Guimaraes - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="315644424550475e7142455043535042541f525e">[email protected]</a>&gt;&#13;
 */&#13;
contract TokenSaleForAlreadyDeployedERC20Tokens is FinalizableCrowdsale, Pausable {&#13;
    uint256 public crowdsaleCap;&#13;
    // amount of raised money in STAR&#13;
    uint256 public starRaised;&#13;
    uint256 public starRate;&#13;
    bool public isWeiAccepted;&#13;
&#13;
    // external contracts&#13;
    Whitelist public whitelist;&#13;
    ERC20 public starToken;&#13;
    // The token being sold&#13;
    ERC20 public tokenOnSale;&#13;
&#13;
    event TokenRateChanged(uint256 previousRate, uint256 newRate);&#13;
    event TokenStarRateChanged(uint256 previousStarRate, uint256 newStarRate);&#13;
    event TokenPurchaseWithStar(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);&#13;
&#13;
    /**&#13;
     * @dev initialization function&#13;
     * @param _startTime The timestamp of the beginning of the crowdsale&#13;
     * @param _endTime Timestamp when the crowdsale will finish&#13;
     * @param _whitelist contract containing the whitelisted addresses&#13;
     * @param _starToken STAR token contract address&#13;
     * @param _tokenOnSale ERC20 token for sale&#13;
     * @param _rate The token rate per ETH&#13;
     * @param _starRate The token rate per STAR&#13;
     * @param _wallet Multisig wallet that will hold the crowdsale funds.&#13;
     * @param _crowdsaleCap Cap for the token sale&#13;
     * @param _isWeiAccepted Bool for acceptance of ether in token sale&#13;
     */&#13;
    function init(&#13;
        uint256 _startTime,&#13;
        uint256 _endTime,&#13;
        address _whitelist,&#13;
        address _starToken,&#13;
        address _tokenOnSale,&#13;
        uint256 _rate,&#13;
        uint256 _starRate,&#13;
        address _wallet,&#13;
        uint256 _crowdsaleCap,&#13;
        bool    _isWeiAccepted&#13;
    )&#13;
        external&#13;
    {&#13;
        require(&#13;
            whitelist == address(0) &amp;&amp;&#13;
            starToken == address(0) &amp;&amp;&#13;
            rate == 0 &amp;&amp;&#13;
            starRate == 0 &amp;&amp;&#13;
            tokenOnSale == address(0) &amp;&amp;&#13;
            crowdsaleCap == 0,&#13;
            "Global variables should not have been set before!"&#13;
        );&#13;
&#13;
        require(&#13;
            _whitelist != address(0) &amp;&amp;&#13;
            _starToken != address(0) &amp;&amp;&#13;
            !(_rate == 0 &amp;&amp; _starRate == 0) &amp;&amp;&#13;
            _tokenOnSale != address(0) &amp;&amp;&#13;
            _crowdsaleCap != 0,&#13;
            "Parameter variables cannot be empty!"&#13;
        );&#13;
&#13;
        initCrowdsale(_startTime, _endTime, _rate, _wallet);&#13;
        tokenOnSale = ERC20(_tokenOnSale);&#13;
        whitelist = Whitelist(_whitelist);&#13;
        starToken = ERC20(_starToken);&#13;
        starRate = _starRate;&#13;
        isWeiAccepted = _isWeiAccepted;&#13;
        owner = tx.origin;&#13;
&#13;
        crowdsaleCap = _crowdsaleCap;&#13;
    }&#13;
&#13;
    modifier isWhitelisted(address beneficiary) {&#13;
        require(whitelist.allowedAddresses(beneficiary), "Beneficiary not whitelisted!");&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev override fallback function. cannot use it&#13;
     */&#13;
    function () external payable {&#13;
        revert("No fallback function defined!");&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev change crowdsale ETH rate&#13;
     * @param newRate Figure that corresponds to the new ETH rate per token&#13;
     */&#13;
    function setRate(uint256 newRate) external onlyOwner {&#13;
        require(newRate != 0, "ETH rate must be more than 0");&#13;
&#13;
        emit TokenRateChanged(rate, newRate);&#13;
        rate = newRate;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev change crowdsale STAR rate&#13;
     * @param newStarRate Figure that corresponds to the new STAR rate per token&#13;
     */&#13;
    function setStarRate(uint256 newStarRate) external onlyOwner {&#13;
        require(newStarRate != 0, "Star rate must be more than 0!");&#13;
&#13;
        emit TokenStarRateChanged(starRate, newStarRate);&#13;
        starRate = newStarRate;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev allows sale to receive wei or not&#13;
     */&#13;
    function setIsWeiAccepted(bool _isWeiAccepted) external onlyOwner {&#13;
        require(rate != 0, "When accepting Wei you need to set a conversion rate!");&#13;
        isWeiAccepted = _isWeiAccepted;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev function that allows token purchases with STAR&#13;
     * @param beneficiary Address of the purchaser&#13;
     */&#13;
    function buyTokens(address beneficiary)&#13;
        public&#13;
        payable&#13;
        whenNotPaused&#13;
        isWhitelisted(beneficiary)&#13;
    {&#13;
        require(beneficiary != address(0));&#13;
        require(validPurchase() &amp;&amp; tokenOnSale.balanceOf(address(this)) &gt; 0);&#13;
&#13;
        if (!isWeiAccepted) {&#13;
            require(msg.value == 0);&#13;
        } else if (msg.value &gt; 0) {&#13;
            buyTokensWithWei(beneficiary);&#13;
        }&#13;
&#13;
        // beneficiary must allow TokenSale address to transfer star tokens on its behalf&#13;
        uint256 starAllocationToTokenSale = starToken.allowance(beneficiary, address(this));&#13;
        if (starAllocationToTokenSale &gt; 0) {&#13;
            // calculate token amount to be created&#13;
            uint256 tokens = starAllocationToTokenSale.mul(starRate);&#13;
&#13;
            //remainder logic&#13;
            if (tokens &gt; tokenOnSale.balanceOf(address(this))) {&#13;
                tokens = tokenOnSale.balanceOf(address(this));&#13;
&#13;
                starAllocationToTokenSale = tokens.div(starRate);&#13;
            }&#13;
&#13;
            // update state&#13;
            starRaised = starRaised.add(starAllocationToTokenSale);&#13;
&#13;
            tokenOnSale.transfer(beneficiary, tokens);&#13;
            emit TokenPurchaseWithStar(msg.sender, beneficiary, starAllocationToTokenSale, tokens);&#13;
&#13;
            // forward funds&#13;
            starToken.transferFrom(beneficiary, wallet, starAllocationToTokenSale);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev function that allows token purchases with Wei&#13;
     * @param beneficiary Address of the purchaser&#13;
     */&#13;
    function buyTokensWithWei(address beneficiary)&#13;
        internal&#13;
    {&#13;
        uint256 weiAmount = msg.value;&#13;
        uint256 weiRefund = 0;&#13;
&#13;
        // calculate token amount to be created&#13;
        uint256 tokens = weiAmount.mul(rate);&#13;
&#13;
        //remainder logic&#13;
        if (tokens &gt; tokenOnSale.balanceOf(address(this))) {&#13;
            tokens = tokenOnSale.balanceOf(address(this));&#13;
            weiAmount = tokens.div(rate);&#13;
&#13;
            weiRefund = msg.value.sub(weiAmount);&#13;
        }&#13;
&#13;
        // update state&#13;
        weiRaised = weiRaised.add(weiAmount);&#13;
&#13;
        tokenOnSale.transfer(beneficiary, tokens);&#13;
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);&#13;
&#13;
        wallet.transfer(weiAmount);&#13;
        if (weiRefund &gt; 0) {&#13;
            msg.sender.transfer(weiRefund);&#13;
        }&#13;
    }&#13;
&#13;
    // override Crowdsale#hasEnded to add cap logic&#13;
    // @return true if crowdsale event has ended&#13;
    function hasEnded() public view returns (bool) {&#13;
        if (tokenOnSale.balanceOf(address(this)) == uint(0) &amp;&amp; (starRaised &gt; 0 || weiRaised &gt; 0)) {&#13;
            return true;&#13;
        }&#13;
&#13;
        return super.hasEnded();&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev override Crowdsale#validPurchase&#13;
     * @return true if the transaction can buy tokens&#13;
     */&#13;
    function validPurchase() internal view returns (bool) {&#13;
        return now &gt;= startTime &amp;&amp; now &lt;= endTime;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev finalizes crowdsale&#13;
     */&#13;
    function finalization() internal {&#13;
        if (tokenOnSale.balanceOf(address(this)) &gt; 0) {&#13;
            uint256 remainingTokens = tokenOnSale.balanceOf(address(this));&#13;
&#13;
            tokenOnSale.transfer(wallet, remainingTokens);&#13;
        }&#13;
&#13;
        super.finalization();&#13;
    }&#13;
}