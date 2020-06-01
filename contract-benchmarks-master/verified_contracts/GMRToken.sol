pragma solidity ^0.4.19;

// File: zeppelin\ownership\Ownable.sol

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

// File: zeppelin\math\SafeMath.sol

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

// File: zeppelin\token\ERC20\ERC20Basic.sol

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

// File: zeppelin\token\ERC20\BasicToken.sol

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

// File: zeppelin\token\ERC20\ERC20.sol

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

// File: zeppelin\token\ERC20\StandardToken.sol

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

// File: zeppelin\token\ERC20\MintableToken.sol

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

// File: contracts\GMRToken.sol

/**
* @title Gimmer Token Smart Contract
* @author <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="15796076746655727c787870673b7b7061">[email protected]</a>, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b3d9dac7d6ddd7c1d2f3d0dbdac7c7dcd7d29dd0dcde">[email protected]</a>&#13;
*/&#13;
contract GMRToken is MintableToken {&#13;
    // Constants&#13;
    string public constant name = "GimmerToken";&#13;
    string public constant symbol = "GMR";&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    /**&#13;
    * @dev Modifier to only allow transfers after the token sale has finished&#13;
    */&#13;
    modifier onlyWhenTransferEnabled() {&#13;
        require(mintingFinished);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Modifier to not allow transfers&#13;
    * to 0x0 and to this contract&#13;
    */&#13;
    modifier validDestination(address _to) {&#13;
        require(_to != address(0x0));&#13;
        require(_to != address(this));&#13;
        _;&#13;
    }&#13;
&#13;
    function GMRToken() public {&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) public&#13;
        onlyWhenTransferEnabled&#13;
        validDestination(_to)&#13;
        returns (bool) {&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    function approve(address _spender, uint256 _value) public&#13;
        onlyWhenTransferEnabled&#13;
        returns (bool) {&#13;
        return super.approve(_spender, _value);&#13;
    }&#13;
&#13;
    function increaseApproval (address _spender, uint _addedValue) public&#13;
        onlyWhenTransferEnabled&#13;
        returns (bool) {&#13;
        return super.increaseApproval(_spender, _addedValue);&#13;
    }&#13;
&#13;
    function decreaseApproval (address _spender, uint _subtractedValue) public&#13;
        onlyWhenTransferEnabled&#13;
        returns (bool) {&#13;
        return super.decreaseApproval(_spender, _subtractedValue);&#13;
    }&#13;
&#13;
    function transfer(address _to, uint256 _value) public&#13;
        onlyWhenTransferEnabled&#13;
        validDestination(_to)&#13;
        returns (bool) {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
}&#13;
&#13;
// File: zeppelin\lifecycle\Pausable.sol&#13;
&#13;
/**&#13;
 * @title Pausable&#13;
 * @dev Base contract which allows children to implement an emergency stop mechanism.&#13;
 */&#13;
contract Pausable is Ownable {&#13;
  event Pause();&#13;
  event Unpause();&#13;
&#13;
  bool public paused = false;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is not paused.&#13;
   */&#13;
  modifier whenNotPaused() {&#13;
    require(!paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is paused.&#13;
   */&#13;
  modifier whenPaused() {&#13;
    require(paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to pause, triggers stopped state&#13;
   */&#13;
  function pause() onlyOwner whenNotPaused public {&#13;
    paused = true;&#13;
    Pause();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to unpause, returns to normal state&#13;
   */&#13;
  function unpause() onlyOwner whenPaused public {&#13;
    paused = false;&#13;
    Unpause();&#13;
  }&#13;
}&#13;
&#13;
// File: contracts\GimmerToken.sol&#13;
&#13;
/**&#13;
* @title Gimmer Token Smart Contract&#13;
* @author <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c5a9b0a6a4b685a2aca8a8a0b7ebaba0b1">[email protected]</a>, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5e34372a3b303a2c3f1e3d36372a2a313a3f703d3133">[email protected]</a>&#13;
*/&#13;
contract GimmerToken is MintableToken {&#13;
    // Constants&#13;
    string public constant name = "GimmerToken";&#13;
    string public constant symbol = "GMR";&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    /**&#13;
    * @dev Modifier to only allow transfers after the minting has been done&#13;
    */&#13;
    modifier onlyWhenTransferEnabled() {&#13;
        require(mintingFinished);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier validDestination(address _to) {&#13;
        require(_to != address(0x0));&#13;
        require(_to != address(this));&#13;
        _;&#13;
    }&#13;
&#13;
    function GimmerToken() public {&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) public&#13;
        onlyWhenTransferEnabled&#13;
        validDestination(_to)&#13;
        returns (bool) {&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    function approve(address _spender, uint256 _value) public&#13;
        onlyWhenTransferEnabled&#13;
        returns (bool) {&#13;
        return super.approve(_spender, _value);&#13;
    }&#13;
&#13;
    function increaseApproval (address _spender, uint _addedValue) public&#13;
        onlyWhenTransferEnabled&#13;
        returns (bool) {&#13;
        return super.increaseApproval(_spender, _addedValue);&#13;
    }&#13;
&#13;
    function decreaseApproval (address _spender, uint _subtractedValue) public&#13;
        onlyWhenTransferEnabled&#13;
        returns (bool) {&#13;
        return super.decreaseApproval(_spender, _subtractedValue);&#13;
    }&#13;
&#13;
    function transfer(address _to, uint256 _value) public&#13;
        onlyWhenTransferEnabled&#13;
        validDestination(_to)&#13;
        returns (bool) {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
}&#13;
&#13;
// File: contracts\GimmerTokenSale.sol&#13;
&#13;
/**&#13;
* @title Gimmer Token Sale Smart Contract&#13;
* @author <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b3dfc6d0d2c0f3d4dadeded6c19dddd6c7">[email protected]</a>, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4f25263b2a212b3d2e0f2c27263b3b202b2e612c2022">[email protected]</a>&#13;
*/&#13;
contract GimmerTokenSale is Pausable {&#13;
    using SafeMath for uint256;&#13;
&#13;
    /**&#13;
    * @dev Supporter structure, which allows us to track&#13;
    * how much the user has bought so far, and if he's flagged as known&#13;
    */&#13;
    struct Supporter {&#13;
        uint256 weiSpent; // the total amount of Wei this address has sent to this contract&#13;
        bool hasKYC; // if the user has KYC flagged&#13;
    }&#13;
&#13;
    // Variables&#13;
    mapping(address =&gt; Supporter) public supportersMap; // Mapping with all the campaign supporters&#13;
    GimmerToken public token; // ERC20 GMR Token contract address&#13;
    address public fundWallet; // Wallet address to forward all Ether to&#13;
    address public kycManagerWallet; // Wallet address that manages the approval of KYC&#13;
    address public currentAddress; // Wallet address that manages the approval of KYC&#13;
    uint256 public tokensSold; // How many tokens sold have been sold in total&#13;
    uint256 public weiRaised; // Total amount of raised money in Wei&#13;
    uint256 public maxTxGas; // Maximum transaction gas price allowed for fair-chance transactions&#13;
    uint256 public saleWeiLimitWithoutKYC; // The maximum amount of Wei an address can spend here without needing KYC approval during CrowdSale&#13;
    bool public finished; // Flag denoting the owner has invoked finishContract()&#13;
&#13;
    uint256 public constant ONE_MILLION = 1000000; // One million for token cap calculation reference&#13;
    uint256 public constant PRE_SALE_GMR_TOKEN_CAP = 15 * ONE_MILLION * 1 ether; // Maximum amount that can be sold during the Pre Sale period&#13;
    uint256 public constant GMR_TOKEN_SALE_CAP = 100 * ONE_MILLION * 1 ether; // Maximum amount of tokens that can be sold by this contract&#13;
    uint256 public constant MIN_ETHER = 0.1 ether; // Minimum ETH Contribution allowed during the crowd sale&#13;
&#13;
    /* Allowed Contribution in Ether */&#13;
    uint256 public constant PRE_SALE_30_ETH = 30 ether; // Minimum 30 Ether to get 25% Bonus Tokens&#13;
    uint256 public constant PRE_SALE_300_ETH = 300 ether; // Minimum 300 Ether to get 30% Bonus Tokens&#13;
    uint256 public constant PRE_SALE_1000_ETH = 1000 ether; // Minimum 3000 Ether to get 40% Bonus Tokens&#13;
&#13;
    /* Bonus Tokens based on the ETH Contributed in single transaction */&#13;
    uint256 public constant TOKEN_RATE_BASE_RATE = 2500; // Base Price for reference only&#13;
    uint256 public constant TOKEN_RATE_05_PERCENT_BONUS = 2625; // 05% Bonus Tokens During Crowd Sale's Week 4&#13;
    uint256 public constant TOKEN_RATE_10_PERCENT_BONUS = 2750; // 10% Bonus Tokens During Crowd Sale's Week 3&#13;
    uint256 public constant TOKEN_RATE_15_PERCENT_BONUS = 2875; // 15% Bonus Tokens During Crowd Sale'sWeek 2&#13;
    uint256 public constant TOKEN_RATE_20_PERCENT_BONUS = 3000; // 20% Bonus Tokens During Crowd Sale'sWeek 1&#13;
    uint256 public constant TOKEN_RATE_25_PERCENT_BONUS = 3125; // 25% Bonus Tokens, During PreSale when &gt;= 30 ETH &amp; &lt; 300 ETH&#13;
    uint256 public constant TOKEN_RATE_30_PERCENT_BONUS = 3250; // 30% Bonus Tokens, During PreSale when &gt;= 300 ETH &amp; &lt; 3000 ETH&#13;
    uint256 public constant TOKEN_RATE_40_PERCENT_BONUS = 3500; // 40% Bonus Tokens, During PreSale when &gt;= 3000 ETH&#13;
&#13;
    /* Timestamps where investments are allowed */&#13;
    uint256 public constant PRE_SALE_START_TIME = 1525176000; // PreSale Start Time : UTC: Wednesday, 17 January 2018 12:00:00&#13;
    uint256 public constant PRE_SALE_END_TIME = 1525521600; // PreSale End Time : UTC: Wednesday, 31 January 2018 12:00:00&#13;
    uint256 public constant START_WEEK_1 = 1525608000; // CrowdSale Start Week-1 : UTC: Thursday, 1 February 2018 12:00:00&#13;
    uint256 public constant START_WEEK_2 = 1526040000; // CrowdSale Start Week-2 : UTC: Thursday, 8 February 2018 12:00:00&#13;
    uint256 public constant START_WEEK_3 = 1526472000; // CrowdSale Start Week-3 : UTC: Thursday, 15 February 2018 12:00:00&#13;
    uint256 public constant START_WEEK_4 = 1526904000; // CrowdSale Start Week-4 : UTC: Thursday, 22 February 2018 12:00:00&#13;
    uint256 public constant SALE_END_TIME = 1527336000; // CrowdSale End Time : UTC: Thursday, 1 March 2018 12:00:00&#13;
&#13;
    /**&#13;
    * @dev Modifier to only allow KYCManager Wallet&#13;
    * to execute a function&#13;
    */&#13;
    modifier onlyKycManager() {&#13;
        require(msg.sender == kycManagerWallet);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
    * Event for token purchase logging&#13;
    * @param purchaser The wallet address that bought the tokens&#13;
    * @param value How many Weis were paid for the purchase&#13;
    * @param amount The amount of tokens purchased&#13;
    */&#13;
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);&#13;
&#13;
    /**&#13;
     * Event for kyc status change logging&#13;
     * @param user User who has had his KYC status changed&#13;
     * @param isApproved A boolean representing the KYC approval the user has been changed to&#13;
     */&#13;
    event KYC(address indexed user, bool isApproved);&#13;
&#13;
    /**&#13;
     * Constructor&#13;
     * @param _fundWallet Address to forward all received Ethers to&#13;
     * @param _kycManagerWallet KYC Manager wallet to approve / disapprove user's KYC&#13;
     * @param _saleWeiLimitWithoutKYC Maximum amount of Wei an address can spend in the contract without KYC during the crowdsale&#13;
     * @param _maxTxGas Maximum gas price a transaction can have before being reverted&#13;
     */&#13;
    function GimmerTokenSale(&#13;
        address _fundWallet,&#13;
        address _kycManagerWallet,&#13;
        uint256 _saleWeiLimitWithoutKYC,&#13;
        uint256 _maxTxGas&#13;
    )&#13;
    public&#13;
    {&#13;
        require(_fundWallet != address(0));&#13;
        require(_kycManagerWallet != address(0));&#13;
        require(_saleWeiLimitWithoutKYC &gt; 0);&#13;
        require(_maxTxGas &gt; 0);&#13;
&#13;
        currentAddress = this;&#13;
&#13;
        fundWallet = _fundWallet;&#13;
        kycManagerWallet = _kycManagerWallet;&#13;
        saleWeiLimitWithoutKYC = _saleWeiLimitWithoutKYC;&#13;
        maxTxGas = _maxTxGas;&#13;
&#13;
        token = new GimmerToken();&#13;
    }&#13;
&#13;
    /* fallback function can be used to buy tokens */&#13;
    function () public payable {&#13;
        buyTokens();&#13;
    }&#13;
&#13;
    /* low level token purchase function */&#13;
    function buyTokens() public payable whenNotPaused {&#13;
        // Do not allow if gasprice is bigger than the maximum&#13;
        // This is for fair-chance for all contributors, so no one can&#13;
        // set a too-high transaction price and be able to buy earlier&#13;
        require(tx.gasprice &lt;= maxTxGas);&#13;
        // valid purchase identifies which stage the contract is at (PreState/Token Sale)&#13;
        // making sure were inside the contribution period and the user&#13;
        // is sending enough Wei for the stage's rules&#13;
        require(validPurchase());&#13;
&#13;
        address sender = msg.sender;&#13;
        uint256 weiAmountSent = msg.value;&#13;
&#13;
        // calculate token amount to be created&#13;
        uint256 rate = getRate(weiAmountSent);&#13;
        uint256 newTokens = weiAmountSent.mul(rate);&#13;
&#13;
        // look if we have not yet reached the cap&#13;
        uint256 totalTokensSold = tokensSold.add(newTokens);&#13;
        if (isCrowdSaleRunning()) {&#13;
            require(totalTokensSold &lt;= GMR_TOKEN_SALE_CAP);&#13;
        } else if (isPreSaleRunning()) {&#13;
            require(totalTokensSold &lt;= PRE_SALE_GMR_TOKEN_CAP);&#13;
        }&#13;
&#13;
        // update supporter state&#13;
        Supporter storage sup = supportersMap[sender];&#13;
        uint256 totalWei = sup.weiSpent.add(weiAmountSent);&#13;
        sup.weiSpent = totalWei;&#13;
&#13;
        // update contract state&#13;
        weiRaised = weiRaised.add(weiAmountSent);&#13;
        tokensSold = totalTokensSold;&#13;
&#13;
        // mint the coins&#13;
        token.mint(sender, newTokens);&#13;
        TokenPurchase(sender, weiAmountSent, newTokens);&#13;
&#13;
        // forward the funds to the wallet&#13;
        fundWallet.transfer(msg.value);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Ends the operation of the contract&#13;
    */&#13;
    function finishContract() public onlyOwner {&#13;
        // make sure the contribution period has ended&#13;
        require(now &gt; SALE_END_TIME);&#13;
        require(!finished);&#13;
&#13;
        finished = true;&#13;
&#13;
        // send the 10% commission to Gimmer's fund wallet&#13;
        uint256 tenPC = tokensSold.div(10);&#13;
        token.mint(fundWallet, tenPC);&#13;
&#13;
        // finish the minting of the token, so the system allows transfers&#13;
        token.finishMinting();&#13;
&#13;
        // transfer ownership of the token contract to the fund wallet,&#13;
        // so it isn't locked to be a child of the crowd sale contract&#13;
        token.transferOwnership(fundWallet);&#13;
    }&#13;
&#13;
    function setSaleWeiLimitWithoutKYC(uint256 _newSaleWeiLimitWithoutKYC) public onlyKycManager {&#13;
        require(_newSaleWeiLimitWithoutKYC &gt; 0);&#13;
        saleWeiLimitWithoutKYC = _newSaleWeiLimitWithoutKYC;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Updates the maximum allowed transaction cost that can be received&#13;
    * on the buyTokens() function.&#13;
    * @param _newMaxTxGas The new maximum transaction cost&#13;
    */&#13;
    function updateMaxTxGas(uint256 _newMaxTxGas) public onlyKycManager {&#13;
        require(_newMaxTxGas &gt; 0);&#13;
        maxTxGas = _newMaxTxGas;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Flag an user as known&#13;
    * @param _user The user to flag as known&#13;
    */&#13;
    function approveUserKYC(address _user) onlyKycManager public {&#13;
        require(_user != address(0));&#13;
&#13;
        Supporter storage sup = supportersMap[_user];&#13;
        sup.hasKYC = true;&#13;
        KYC(_user, true);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Flag an user as unknown/disapproved&#13;
     * @param _user The user to flag as unknown / suspecious&#13;
     */&#13;
    function disapproveUserKYC(address _user) onlyKycManager public {&#13;
        require(_user != address(0));&#13;
&#13;
        Supporter storage sup = supportersMap[_user];&#13;
        sup.hasKYC = false;&#13;
        KYC(_user, false);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Changes the KYC manager to a new address&#13;
    * @param _newKYCManagerWallet The new address that will be managing KYC approval&#13;
    */&#13;
    function setKYCManager(address _newKYCManagerWallet) onlyOwner public {&#13;
        require(_newKYCManagerWallet != address(0));&#13;
        kycManagerWallet = _newKYCManagerWallet;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Returns true if any of the token sale stages are currently running&#13;
    * @return A boolean representing the state of this contract&#13;
    */&#13;
    function isTokenSaleRunning() public constant returns (bool) {&#13;
        return (isPreSaleRunning() || isCrowdSaleRunning());&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Returns true if the presale sale is currently running&#13;
    * @return A boolean representing the state of the presale&#13;
    */&#13;
    function isPreSaleRunning() public constant returns (bool) {&#13;
        return (now &gt;= PRE_SALE_START_TIME &amp;&amp; now &lt; PRE_SALE_END_TIME);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Returns true if the public sale is currently running&#13;
    * @return A boolean representing the state of the crowd sale&#13;
    */&#13;
    function isCrowdSaleRunning() public constant returns (bool) {&#13;
        return (now &gt;= START_WEEK_1 &amp;&amp; now &lt;= SALE_END_TIME);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Returns true if the public sale has ended&#13;
    * @return A boolean representing if we are past the contribution date for this contract&#13;
    */&#13;
    function hasEnded() public constant returns (bool) {&#13;
        return now &gt; SALE_END_TIME;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Returns true if the pre sale has ended&#13;
    * @return A boolean representing if we are past the pre sale contribution dates&#13;
    */&#13;
    function hasPreSaleEnded() public constant returns (bool) {&#13;
        return now &gt; PRE_SALE_END_TIME;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Returns if an user has KYC approval or not&#13;
    * @return A boolean representing the user's KYC status&#13;
    */&#13;
    function userHasKYC(address _user) public constant returns (bool) {&#13;
        return supportersMap[_user].hasKYC;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Returns the weiSpent of a user&#13;
     */&#13;
    function userWeiSpent(address _user) public constant returns (uint256) {&#13;
        return supportersMap[_user].weiSpent;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Returns the rate the user will be paying at,&#13;
     * based on the amount of Wei sent to the contract, and the current time&#13;
     * @return An uint256 representing the rate the user will pay for the GMR tokens&#13;
     */&#13;
    function getRate(uint256 _weiAmount) internal constant returns (uint256) {&#13;
        if (isCrowdSaleRunning()) {&#13;
            if (now &gt;= START_WEEK_4) { return TOKEN_RATE_05_PERCENT_BONUS; }&#13;
            else if (now &gt;= START_WEEK_3) { return TOKEN_RATE_10_PERCENT_BONUS; }&#13;
            else if (now &gt;= START_WEEK_2) { return TOKEN_RATE_15_PERCENT_BONUS; }&#13;
            else if (now &gt;= START_WEEK_1) { return TOKEN_RATE_20_PERCENT_BONUS; }&#13;
        }&#13;
        else if (isPreSaleRunning()) {&#13;
            if (_weiAmount &gt;= PRE_SALE_1000_ETH) { return TOKEN_RATE_40_PERCENT_BONUS; }&#13;
            else if (_weiAmount &gt;= PRE_SALE_300_ETH) { return TOKEN_RATE_30_PERCENT_BONUS; }&#13;
            else if (_weiAmount &gt;= PRE_SALE_30_ETH) { return TOKEN_RATE_25_PERCENT_BONUS; }&#13;
        }&#13;
    }&#13;
&#13;
    /* @return true if the transaction can buy tokens, otherwise false */&#13;
    function validPurchase() internal constant returns (bool) {&#13;
        bool userHasKyc = userHasKYC(msg.sender);&#13;
&#13;
        if (isCrowdSaleRunning()) {&#13;
            // crowdsale restrictions (KYC only needed after wei limit, minimum of 0.1 ETH tx)&#13;
            if(!userHasKyc) {&#13;
                Supporter storage sup = supportersMap[msg.sender];&#13;
                uint256 ethContribution = sup.weiSpent.add(msg.value);&#13;
                if (ethContribution &gt; saleWeiLimitWithoutKYC) {&#13;
                    return false;&#13;
                }&#13;
            }&#13;
            return msg.value &gt;= MIN_ETHER;&#13;
        }&#13;
        else if (isPreSaleRunning()) {&#13;
            // presale restrictions (at least 30 eth, always KYC)&#13;
            return userHasKyc &amp;&amp; msg.value &gt;= PRE_SALE_30_ETH;&#13;
        } else {&#13;
            return false;&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
// File: contracts\GMRTokenManager.sol&#13;
&#13;
/**&#13;
* @title Gimmer Token Sale Manager Smart Contract&#13;
* @author <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="deb2abbdbfad9eb9b7b3b3bbacf0b0bbaa">[email protected]</a>, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2842415c4d464c5a49684b40415c5c474c49064b4745">[email protected]</a>&#13;
*/&#13;
contract GMRTokenManager is Ownable {&#13;
    using SafeMath for uint256;&#13;
&#13;
    /* Contracts */&#13;
    GMRToken public token;&#13;
    GimmerTokenSale public oldTokenSale;&#13;
&#13;
    /* Flags for tracking contract usage */&#13;
    bool public finishedMigration;&#13;
&#13;
    /* Constants */&#13;
    uint256 public constant TOKEN_BONUS_RATE = 8785; // The rate for the bonus given to precontract contributors&#13;
&#13;
    /**&#13;
     * Constructor&#13;
     * @param _oldTokenSaleAddress Old Token Sale contract address&#13;
     */&#13;
    function GMRTokenManager(address _oldTokenSaleAddress) public {&#13;
        // access the old token sale&#13;
        oldTokenSale = GimmerTokenSale(_oldTokenSaleAddress);&#13;
&#13;
        // deploy the token contract&#13;
        token = new GMRToken();&#13;
    }&#13;
&#13;
    /**&#13;
     * Prepopulates the specified wallet&#13;
     * @param _wallet Wallet to mint the reserve tokens to&#13;
     */&#13;
    function prepopulate(address _wallet) public onlyOwner {&#13;
        require(!finishedMigration);&#13;
        require(_wallet != address(0));&#13;
&#13;
        // get the balance the user spent in the last sale&#13;
        uint256 spent = oldTokenSale.userWeiSpent(_wallet);&#13;
        require(spent != 0);&#13;
&#13;
        // make sure we have not prepopulated already&#13;
        uint256 balance = token.balanceOf(_wallet);&#13;
        require(balance == 0);&#13;
&#13;
        // calculate the new balance with bonus&#13;
        uint256 tokens = spent.mul(TOKEN_BONUS_RATE);&#13;
&#13;
        // mint the coins&#13;
        token.mint(_wallet, tokens);&#13;
    }&#13;
&#13;
    /**&#13;
     * Ends the migration process by giving the token&#13;
     * contract back to the owner&#13;
     */&#13;
    function endMigration() public onlyOwner {&#13;
        require(!finishedMigration);&#13;
        finishedMigration = true;&#13;
&#13;
        token.transferOwnership(owner);&#13;
    }&#13;
}