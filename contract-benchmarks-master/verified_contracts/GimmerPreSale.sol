pragma solidity ^0.4.17;



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


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    mapping(address => uint256) balances;
    function balanceOf(address _owner) public constant returns (uint256) { return balances[_owner]; }
    // Transfer is disabled for users, as these are PreSale tokens
    //function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
* @title Gimmer PreSale Smart Contract
* @author <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a8c4ddcbc9dbe8cfc1c5c5cdda86c6cddc">[email protected]</a>, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e882819c8d868c9a89a88b80819c9c878c89c68b8785">[email protected]</a>&#13;
*/&#13;
contract GimmerPreSale is ERC20Basic, Pausable {&#13;
    using SafeMath for uint256;&#13;
&#13;
    /**&#13;
    * @dev Supporter structure, which allows us to track&#13;
    * how much the user has bought so far, and if he's flagged as known&#13;
    */&#13;
    struct Supporter {&#13;
        uint256 weiSpent;   // the total amount of Wei this address has sent to this contract&#13;
        bool hasKYC;        // if the user has KYC flagged&#13;
    }&#13;
&#13;
    mapping(address =&gt; Supporter) public supportersMap; // Mapping with all the campaign supporters&#13;
    address public fundWallet;      // Address to forward all Ether to&#13;
    address public kycManager;      // Address that manages approval of KYC&#13;
    uint256 public tokensSold;      // How many tokens sold in PreSale&#13;
    uint256 public weiRaised;       // amount of raised money in wei&#13;
&#13;
    uint256 public constant ONE_MILLION = 1000000;&#13;
    // Maximum amount that can be sold during the Pre Sale period&#13;
    uint256 public constant PRE_SALE_GMRP_TOKEN_CAP = 15 * ONE_MILLION * 1 ether; //15 Million GMRP Tokens&#13;
&#13;
    /* Allowed Contribution in Ether */&#13;
    uint256 public constant PRE_SALE_30_ETH     = 30 ether;  // Minimum 30 Ether to get 25% Bonus Tokens&#13;
    uint256 public constant PRE_SALE_300_ETH    = 300 ether; // Minimum 300 Ether to get 30% Bonus Tokens&#13;
    uint256 public constant PRE_SALE_3000_ETH   = 3000 ether;// Minimum 3000 Ether to get 40% Bonus Tokens&#13;
&#13;
    /* Bonus Tokens based on the ETH Contributed in single transaction */&#13;
    uint256 public constant TOKEN_RATE_25_PERCENT_BONUS = 1250; // 25% Bonus Tokens, when &gt;= 30 ETH &amp; &lt; 300 ETH&#13;
    uint256 public constant TOKEN_RATE_30_PERCENT_BONUS = 1300; // 30% Bonus Tokens, when &gt;= 300 ETH &amp; &lt; 3000 ETH&#13;
    uint256 public constant TOKEN_RATE_40_PERCENT_BONUS = 1400; // 40% Bonus Tokens, when &gt;= 3000 ETH&#13;
&#13;
    /* start and end timestamps where investments are allowed (both inclusive) */&#13;
    uint256 public constant START_TIME  = 1511524800;   //GMT: Friday, 24 November 2017 12:00:00&#13;
    uint256 public constant END_TIME    = 1514894400;   //GMT: Tuesday, 2 January  2018 12:00:00&#13;
&#13;
    /* Token metadata */&#13;
    string public constant name = "GimmerPreSale Token";&#13;
    string public constant symbol = "GMRP";&#13;
    uint256 public constant decimals = 18;&#13;
&#13;
    /**&#13;
    * @dev Modifier to only allow KYCManager&#13;
    */&#13;
    modifier onlyKycManager() {&#13;
        require(msg.sender == kycManager);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
    * Event for token purchase logging&#13;
    * @param purchaser  who bought the tokens&#13;
    * @param value      weis paid for purchase&#13;
    * @param amount     amount of tokens purchased&#13;
    */&#13;
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);&#13;
&#13;
    /**&#13;
    * Event for minting new tokens&#13;
    * @param to         The person that received tokens&#13;
    * @param amount     Amount of tokens received&#13;
    */&#13;
    event Mint(address indexed to, uint256 amount);&#13;
&#13;
    /**&#13;
     * Event to log a user is approved or disapproved&#13;
     * @param user          User who has been approved/disapproved&#13;
     * @param isApproved    true : User is approved, false : User is disapproved&#13;
     */&#13;
    event KYC(address indexed user, bool isApproved);&#13;
&#13;
    /**&#13;
     * Constructor&#13;
     * @param _fundWallet           Address to forward all received Ethers to&#13;
     * @param _kycManagerWallet     KYC Manager wallet to approve / disapprove user's KYC&#13;
     */&#13;
    function GimmerPreSale(address _fundWallet, address _kycManagerWallet) public {&#13;
        require(_fundWallet != address(0));&#13;
        require(_kycManagerWallet != address(0));&#13;
&#13;
        fundWallet = _fundWallet;&#13;
        kycManager = _kycManagerWallet;&#13;
    }&#13;
&#13;
    /* fallback function can be used to buy tokens */&#13;
    function () whenNotPaused public payable {&#13;
        buyTokens();&#13;
    }&#13;
&#13;
    /* @return true if the transaction can buy tokens, otherwise false */&#13;
    function validPurchase() internal constant returns (bool) {&#13;
        bool withinPeriod = now &gt;= START_TIME &amp;&amp; now &lt;= END_TIME;&#13;
        bool higherThanMin30ETH = msg.value &gt;= PRE_SALE_30_ETH;&#13;
        return withinPeriod &amp;&amp; higherThanMin30ETH;&#13;
    }&#13;
&#13;
    /* low level token purchase function */&#13;
    function buyTokens() whenNotPaused public payable {&#13;
        address sender = msg.sender;&#13;
&#13;
        // make sure the user buying tokens has KYC&#13;
        require(userHasKYC(sender));&#13;
        require(validPurchase());&#13;
&#13;
        // calculate token amount to be created&#13;
        uint256 weiAmountSent = msg.value;&#13;
        uint256 rate = getRate(weiAmountSent);&#13;
        uint256 newTokens = weiAmountSent.mul(rate);&#13;
&#13;
        // look if we have not yet reached the cap&#13;
        uint256 totalTokensSold = tokensSold.add(newTokens);&#13;
        require(totalTokensSold &lt;= PRE_SALE_GMRP_TOKEN_CAP);&#13;
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
        // finally mint the coins&#13;
        mint(sender, newTokens);&#13;
        TokenPurchase(sender, weiAmountSent, newTokens);&#13;
&#13;
        // and forward the funds to the wallet&#13;
        forwardFunds();&#13;
    }&#13;
&#13;
    /**&#13;
     * returns the rate the user will be paying at,&#13;
     * based on the amount of wei sent to the contract&#13;
     */&#13;
    function getRate(uint256 weiAmount) public pure returns (uint256) {&#13;
        if (weiAmount &gt;= PRE_SALE_3000_ETH) {&#13;
            return TOKEN_RATE_40_PERCENT_BONUS;&#13;
        } else if(weiAmount &gt;= PRE_SALE_300_ETH) {&#13;
            return TOKEN_RATE_30_PERCENT_BONUS;&#13;
        } else if(weiAmount &gt;= PRE_SALE_30_ETH) {&#13;
            return TOKEN_RATE_25_PERCENT_BONUS;&#13;
        } else {&#13;
            return 0;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * send ether to the fund collection wallet&#13;
     * override to create custom fund forwarding mechanisms&#13;
     */&#13;
    function forwardFunds() internal {&#13;
        fundWallet.transfer(msg.value);&#13;
    }&#13;
&#13;
    // @return true if crowdsale event has ended&#13;
    function hasEnded() public constant returns (bool) {&#13;
        return now &gt; END_TIME;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Approves an User's KYC&#13;
    * @param _user The user to flag as known&#13;
    */&#13;
    function approveUserKYC(address _user) onlyKycManager public {&#13;
        Supporter storage sup = supportersMap[_user];&#13;
        sup.hasKYC = true;&#13;
        KYC(_user, true);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Disapproves an User's KYC&#13;
     * @param _user The user to flag as unknown / suspecious&#13;
     */&#13;
    function disapproveUserKYC(address _user) onlyKycManager public {&#13;
        Supporter storage sup = supportersMap[_user];&#13;
        sup.hasKYC = false;&#13;
        KYC(_user, false);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Changes the KYC manager to a new address&#13;
    * @param _newKYCManager The new address that will be managing KYC approval&#13;
    */&#13;
    function setKYCManager(address _newKYCManager) onlyOwner public {&#13;
        require(_newKYCManager != address(0));&#13;
        kycManager = _newKYCManager;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Returns if an users has KYC approval or not&#13;
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
    * @dev Function to mint tokens&#13;
    * @param _to The address that will receive the minted tokens.&#13;
    * @param _amount The amount of tokens to mint.&#13;
    * @return A boolean that indicates if the operation was successful.&#13;
    */&#13;
    function mint(address _to, uint256 _amount) internal returns (bool) {&#13;
        totalSupply = totalSupply.add(_amount);&#13;
        balances[_to] = balances[_to].add(_amount);&#13;
        Mint(_to, _amount);&#13;
        Transfer(0x0, _to, _amount);&#13;
        return true;&#13;
    }&#13;
}