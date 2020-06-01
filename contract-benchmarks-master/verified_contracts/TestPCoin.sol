pragma solidity ^0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
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


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
   require(newOwner != address(0));
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
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


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
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
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

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}


/**
 * Pausable token
 *
 * Simple ERC20 Token example, with pausable token creation
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint _value) whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}


/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) {
    require(_wallet != 0x0);
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}

// @title The TestPCoin
/// @author Manoj Patidar
contract TestPCoin is PausableToken {
   using SafeMath for uint256;

   string public constant name = 'TestPCoin';

   string public constant symbol = 'TESTP';

   uint8 public constant decimals = 18;

   uint256 public  totalSupply = 100e24; // 100M tokens with 18 decimals

   bool public remainingTokenBurnt = false;

   // The tokens already used for the presale buyers
   uint256 public tokensDistributedPresale = 0;

   // The tokens already used for the ICO buyers
   uint256 public tokensDistributedCrowdsale = 0;

   // The address of the crowdsale
   address public crowdsale;

   // The initial supply used for platform and development as specified in the whitepaper
   uint256 public initialSupply = 40e24;

   // The maximum amount of tokens for the presale investors
   uint256 public limitPresale = 10e24;

   // The maximum amount of tokens sold in the crowdsale
   uint256 public limitCrowdsale = 50e24;

   /// @notice Only allows the execution of the function if it's comming from crowdsale
   modifier onlyCrowdsale() {
      require(msg.sender == crowdsale);
      _;
   }

   // When someone refunds tokens
   event RefundedTokens(address indexed user, uint256 tokens);

   /// @notice Constructor used to set the platform & development tokens. This is
   /// The 20% + 20% of the 100 M tokens used for platform and development team.
   /// The owner, msg.sender, is able to do allowance for other contracts. Remember
   /// to use `transferFrom()` if you're allowed
   function TestPCoin() {
      balances[msg.sender] = initialSupply; // 40M tokens wei
   }

   /// @notice Function to set the crowdsale smart contract's address only by the owner of this token
   /// @param _crowdsale The address that will be used
   function setCrowdsaleAddress(address _crowdsale) external onlyOwner whenNotPaused {
      require(_crowdsale != address(0));

      crowdsale = _crowdsale;
   }

   /// @notice Distributes the presale tokens. Only the owner can do this
   /// @param _buyer The address of the buyer
   /// @param tokens The amount of tokens corresponding to that buyer
   function distributePresaleTokens(address _buyer, uint tokens) external onlyOwner whenNotPaused {
      require(_buyer != address(0));
      require(tokens > 0 && tokens <= limitPresale);

      // Check that the limit of 10M presale tokens hasn't been met yet
      require(tokensDistributedPresale < limitPresale);
      require(tokensDistributedPresale.add(tokens) < limitPresale);

      tokensDistributedPresale = tokensDistributedPresale.add(tokens);
      balances[_buyer] = balances[_buyer].add(tokens);
   }

   /// @notice Distributes the ICO tokens. Only the crowdsale address can execute this
   /// @param _buyer The buyer address
   /// @param tokens The amount of tokens to send to that address
   function distributeICOTokens(address _buyer, uint tokens) external onlyCrowdsale whenNotPaused {
      require(_buyer != address(0));
      require(tokens > 0);

      // Check that the limit of 50M ICO tokens hasn't been met yet
      require(tokensDistributedCrowdsale < limitCrowdsale);
      require(tokensDistributedCrowdsale.add(tokens) <= limitCrowdsale);

      tokensDistributedCrowdsale = tokensDistributedCrowdsale.add(tokens);
      balances[_buyer] = balances[_buyer].add(tokens);
   }

   /// @notice Deletes the amount of tokens refunded from that buyer balance
   /// @param _buyer The buyer that wants the refund
   /// @param tokens The tokens to return
   function refundTokens(address _buyer, uint256 tokens) external onlyCrowdsale whenNotPaused {
      require(_buyer != address(0));
      require(tokens > 0);
      require(balances[_buyer] >= tokens);

      balances[_buyer] = balances[_buyer].sub(tokens);
      RefundedTokens(_buyer, tokens);
   }

   /// @notice Burn the amount of tokens remaining after ICO ends
   function burnTokens() external onlyCrowdsale whenNotPaused {
      
      uint256 remainingICOToken = limitCrowdsale.sub(tokensDistributedCrowdsale);
      if(remainingICOToken > 0 && !remainingTokenBurnt) {
      remainingTokenBurnt = true;    
      limitCrowdsale = limitCrowdsale.sub(remainingICOToken);  
      totalSupply = totalSupply.sub(remainingICOToken);
      }
   }
}
/// 1. First you set the address of the wallet in the RefundVault contract that will store the deposit of ether
// 2. If the goal is reached, the state of the vault will change and the ether will be sent to the address
// 3. If the goal is not reached , the state of the vault will change to refunding and the users will be able to call claimRefund() to get their ether

/// @author Manoj Patidar <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="70001104191411021d111e1f1a30171d11191c5e131f1d">[email protected]</a>&gt;&#13;
contract Crowdsale is Pausable {&#13;
   using SafeMath for uint256;&#13;
&#13;
   // The token being sold&#13;
   TestPCoin public token;&#13;
&#13;
   // The vault that will store the ether until the goal is reached&#13;
   RefundVault public vault;&#13;
&#13;
   // The block number of when the crowdsale starts&#13;
   // 10/15/2017 @ 11:00am (UTC)&#13;
   // 10/15/2017 @ 12:00pm (GMT + 1)&#13;
   uint256 public startTime = 1511068829;&#13;
&#13;
   // The block number of when the crowdsale ends&#13;
   // 11/13/2017 @ 11:00am (UTC)&#13;
   // 11/13/2017 @ 12:00pm (GMT + 1)&#13;
   uint256 public endTime = 1512021029;&#13;
&#13;
   // The wallet that holds the Wei raised on the crowdsale&#13;
   address public wallet;&#13;
&#13;
   // The wallet that holds the Wei raised on the crowdsale after soft cap reached&#13;
   address public walletB;&#13;
&#13;
   // The rate of tokens per ether. Only applied for the first tier, the first&#13;
   // 12.5 million tokens sold&#13;
   uint256 public rate;&#13;
&#13;
   // The rate of tokens per ether. Only applied for the second tier, at between&#13;
   // 12.5 million tokens sold and 25 million tokens sold&#13;
   uint256 public rateTier2;&#13;
&#13;
   // The rate of tokens per ether. Only applied for the third tier, at between&#13;
   // 25 million tokens sold and 37.5 million tokens sold&#13;
   uint256 public rateTier3;&#13;
&#13;
   // The rate of tokens per ether. Only applied for the fourth tier, at between&#13;
   // 37.5 million tokens sold and 50 million tokens sold&#13;
   uint256 public rateTier4;&#13;
&#13;
   // The maximum amount of wei for each tier&#13;
   uint256 public limitTier1 = 12.5e24;&#13;
   uint256 public limitTier2 = 25e24;&#13;
   uint256 public limitTier3 = 37.5e24;&#13;
&#13;
   // The amount of wei raised&#13;
   uint256 public weiRaised = 0;&#13;
&#13;
   // The amount of tokens raised&#13;
   uint256 public tokensRaised = 0;&#13;
&#13;
   // You can only buy up to 50 M tokens during the ICO&#13;
   uint256 public constant maxTokensRaised = 50e24;&#13;
&#13;
   // The minimum amount of Wei you must pay to participate in the crowdsale&#13;
   uint256 public constant minPurchase = 10 finney; // 0.01 ether&#13;
&#13;
   // The max amount of Wei that you can pay to participate in the crowdsale&#13;
   uint256 public constant maxPurchase = 2000 ether;&#13;
&#13;
   // Minimum amount of tokens to be raised. 7.5 million tokens which is the 15%&#13;
   // of the total of 50 million tokens sold in the crowdsale&#13;
   // 7.5e6 + 1e18&#13;
   uint256 public constant minimumGoal = 5.33e19;&#13;
&#13;
   // If the crowdsale wasn't successful, this will be true and users will be able&#13;
   // to claim the refund of their ether&#13;
   bool public isRefunding = false;&#13;
&#13;
   // If the crowdsale has ended or not&#13;
   bool public isEnded = false;&#13;
&#13;
   // The number of transactions&#13;
   uint256 public numberOfTransactions;&#13;
&#13;
   // The gas price to buy tokens must be 50 gwei or below&#13;
   uint256 public limitGasPrice = 50000000000 wei;&#13;
&#13;
   // How much each user paid for the crowdsale&#13;
   mapping(address =&gt; uint256) public crowdsaleBalances;&#13;
&#13;
   // How many tokens each user got for the crowdsale&#13;
   mapping(address =&gt; uint256) public tokensBought;&#13;
&#13;
   // To indicate who purchased what amount of tokens and who received what amount of wei&#13;
   event TokenPurchase(address indexed buyer, uint256 value, uint256 amountOfTokens);&#13;
&#13;
   // Indicates if the crowdsale has ended&#13;
   event Finalized();&#13;
&#13;
   // Only allow the execution of the function before the crowdsale starts&#13;
   modifier beforeStarting() {&#13;
      require(now &lt; startTime);&#13;
      _;&#13;
   }&#13;
&#13;
   /// @notice Constructor of the crowsale to set up the main variables and create a token&#13;
   /// @param _wallet The wallet address that stores the Wei raised&#13;
   /// @param _walletB The wallet address that stores the Wei raised after soft cap reached&#13;
   /// @param _tokenAddress The token used for the ICO&#13;
   function Crowdsale(&#13;
      address _wallet,&#13;
      address _walletB,&#13;
      address _tokenAddress,&#13;
      uint256 _startTime,&#13;
      uint256 _endTime&#13;
   ) public {&#13;
      require(_wallet != address(0));&#13;
      require(_tokenAddress != address(0));&#13;
      require(_walletB != address(0));&#13;
&#13;
      // If you send the start and end time on the constructor, the end must be larger&#13;
      if(_startTime &gt; 0 &amp;&amp; _endTime &gt; 0)&#13;
         require(_startTime &lt; _endTime);&#13;
&#13;
      wallet = _wallet;&#13;
      walletB = _walletB;&#13;
      token = TestPCoin(_tokenAddress);&#13;
      vault = new RefundVault(_wallet);&#13;
&#13;
      if(_startTime &gt; 0)&#13;
         startTime = _startTime;&#13;
&#13;
      if(_endTime &gt; 0)&#13;
         endTime = _endTime;&#13;
   }&#13;
&#13;
   /// @notice Fallback function to buy tokens&#13;
   function () payable {&#13;
      buyTokens();&#13;
   }&#13;
&#13;
   /// @notice To buy tokens given an address&#13;
   function buyTokens() public payable whenNotPaused {&#13;
      require(validPurchase());&#13;
&#13;
      uint256 tokens = 0;&#13;
      &#13;
      uint256 amountPaid = calculateExcessBalance();&#13;
&#13;
      if(tokensRaised &lt; limitTier1) {&#13;
&#13;
         // Tier 1&#13;
         tokens = amountPaid.mul(rate);&#13;
&#13;
         // If the amount of tokens that you want to buy gets out of this tier&#13;
         if(tokensRaised.add(tokens) &gt; limitTier1)&#13;
            tokens = calculateExcessTokens(amountPaid, limitTier1, 1, rate);&#13;
      } else if(tokensRaised &gt;= limitTier1 &amp;&amp; tokensRaised &lt; limitTier2) {&#13;
&#13;
         // Tier 2&#13;
         tokens = amountPaid.mul(rateTier2);&#13;
&#13;
         // If the amount of tokens that you want to buy gets out of this tier&#13;
         if(tokensRaised.add(tokens) &gt; limitTier2)&#13;
            tokens = calculateExcessTokens(amountPaid, limitTier2, 2, rateTier2);&#13;
      } else if(tokensRaised &gt;= limitTier2 &amp;&amp; tokensRaised &lt; limitTier3) {&#13;
&#13;
         // Tier 3&#13;
         tokens = amountPaid.mul(rateTier3);&#13;
&#13;
         // If the amount of tokens that you want to buy gets out of this tier&#13;
         if(tokensRaised.add(tokens) &gt; limitTier3)&#13;
            tokens = calculateExcessTokens(amountPaid, limitTier3, 3, rateTier3);&#13;
      } else if(tokensRaised &gt;= limitTier3) {&#13;
&#13;
         // Tier 4&#13;
         tokens = amountPaid.mul(rateTier4);&#13;
      }&#13;
&#13;
      weiRaised = weiRaised.add(amountPaid);&#13;
      uint256 tokensRaisedBeforeThisTransaction = tokensRaised;&#13;
      tokensRaised = tokensRaised.add(tokens);&#13;
      token.distributeICOTokens(msg.sender, tokens);&#13;
&#13;
      // Keep a record of how many tokens everybody gets in case we need to do refunds&#13;
      tokensBought[msg.sender] = tokensBought[msg.sender].add(tokens);&#13;
      TokenPurchase(msg.sender, amountPaid, tokens);&#13;
      numberOfTransactions = numberOfTransactions.add(1);&#13;
&#13;
      if(tokensRaisedBeforeThisTransaction &gt; minimumGoal) {&#13;
&#13;
         walletB.transfer(amountPaid);&#13;
&#13;
      } else {&#13;
         vault.deposit.value(amountPaid)(msg.sender);&#13;
         if(goalReached()) {&#13;
          vault.close();&#13;
         }&#13;
         &#13;
      }&#13;
&#13;
      // If the minimum goal of the ICO has been reach, close the vault to send&#13;
      // the ether to the wallet of the crowdsale&#13;
      checkCompletedCrowdsale();&#13;
   }&#13;
&#13;
   /// @notice Calculates how many ether will be used to generate the tokens in&#13;
   /// case the buyer sends more than the maximum balance but has some balance left&#13;
   /// and updates the balance of that buyer.&#13;
   /// For instance if he's 500 balance and he sends 1000, it will return 500&#13;
   /// and refund the other 500 ether&#13;
   function calculateExcessBalance() internal whenNotPaused returns(uint256) {&#13;
      uint256 amountPaid = msg.value;&#13;
      uint256 differenceWei = 0;&#13;
      uint256 exceedingBalance = 0;&#13;
&#13;
      // If we're in the last tier, check that the limit hasn't been reached&#13;
      // and if so, refund the difference and return what will be used to&#13;
      // buy the remaining tokens&#13;
      if(tokensRaised &gt;= limitTier3) {&#13;
         uint256 addedTokens = tokensRaised.add(amountPaid.mul(rateTier4));&#13;
&#13;
         // If tokensRaised + what you paid converted to tokens is bigger than the max&#13;
         if(addedTokens &gt; maxTokensRaised) {&#13;
&#13;
            // Refund the difference&#13;
            uint256 difference = addedTokens.sub(maxTokensRaised);&#13;
            differenceWei = difference.div(rateTier4);&#13;
            amountPaid = amountPaid.sub(differenceWei);&#13;
         }&#13;
      }&#13;
&#13;
      uint256 addedBalance = crowdsaleBalances[msg.sender].add(amountPaid);&#13;
&#13;
      // Checking that the individual limit of 1000 ETH per user is not reached&#13;
      if(addedBalance &lt;= maxPurchase) {&#13;
         crowdsaleBalances[msg.sender] = crowdsaleBalances[msg.sender].add(amountPaid);&#13;
      } else {&#13;
&#13;
         // Substracting 1000 ether in wei&#13;
         exceedingBalance = addedBalance.sub(maxPurchase);&#13;
         amountPaid = amountPaid.sub(exceedingBalance);&#13;
&#13;
         // Add that balance to the balances&#13;
         crowdsaleBalances[msg.sender] = crowdsaleBalances[msg.sender].add(amountPaid);&#13;
      }&#13;
&#13;
      // Make the transfers at the end of the function for security purposes&#13;
      if(differenceWei &gt; 0)&#13;
         msg.sender.transfer(differenceWei);&#13;
&#13;
      if(exceedingBalance &gt; 0) {&#13;
&#13;
         // Return the exceeding balance to the buyer&#13;
         msg.sender.transfer(exceedingBalance);&#13;
      }&#13;
&#13;
      return amountPaid;&#13;
   }&#13;
&#13;
   /// @notice Set's the rate of tokens per ether for each tier. Use it after the&#13;
   /// smart contract is deployed to set the price according to the ether price&#13;
   /// at the start of the ICO&#13;
   /// @param tier1 The amount of tokens you get in the tier one&#13;
   /// @param tier2 The amount of tokens you get in the tier two&#13;
   /// @param tier3 The amount of tokens you get in the tier three&#13;
   /// @param tier4 The amount of tokens you get in the tier four&#13;
   function setTierRates(uint256 tier1, uint256 tier2, uint256 tier3, uint256 tier4)&#13;
      external onlyOwner whenNotPaused&#13;
   {&#13;
      require(tier1 &gt; 0 &amp;&amp; tier2 &gt; 0 &amp;&amp; tier3 &gt; 0 &amp;&amp; tier4 &gt; 0);&#13;
      require(tier1 &gt; tier2 &amp;&amp; tier2 &gt; tier3 &amp;&amp; tier3 &gt; tier4);&#13;
&#13;
      rate = tier1;&#13;
      rateTier2 = tier2;&#13;
      rateTier3 = tier3;&#13;
      rateTier4 = tier4;&#13;
   }&#13;
&#13;
   /// @notice Allow to extend ICO end date&#13;
   /// @param _endTime Endtime of ICO&#13;
   function setEndDate(uint256 _endTime)&#13;
      external onlyOwner whenNotPaused&#13;
   {&#13;
      require(now &lt;= _endTime);&#13;
      require(startTime &lt; _endTime);&#13;
      &#13;
      endTime = _endTime;&#13;
   }&#13;
&#13;
&#13;
   /// @notice Check if the crowdsale has ended and enables refunds only in case the&#13;
   /// goal hasn't been reached&#13;
   function checkCompletedCrowdsale() public whenNotPaused {    &#13;
      if(!isEnded) {&#13;
         if(hasEnded() &amp;&amp; !goalReached()){&#13;
            vault.enableRefunds();&#13;
&#13;
            isRefunding = true;&#13;
            isEnded = true;&#13;
            Finalized();&#13;
         } else if(hasEnded()  &amp;&amp; goalReached()) {&#13;
            &#13;
            &#13;
            isEnded = true; &#13;
&#13;
&#13;
            // Burn token only when minimum goal reached and maxGoal not reached. &#13;
            if(tokensRaised &lt; maxTokensRaised) {&#13;
&#13;
               token.burnTokens();&#13;
&#13;
            } &#13;
&#13;
            Finalized();&#13;
         } &#13;
         &#13;
         &#13;
      }&#13;
   }&#13;
&#13;
   /// @notice If crowdsale is unsuccessful, investors can claim refunds here&#13;
   function claimRefund() public whenNotPaused {&#13;
     require(hasEnded() &amp;&amp; !goalReached() &amp;&amp; isRefunding);&#13;
&#13;
     vault.refund(msg.sender);&#13;
     token.refundTokens(msg.sender, tokensBought[msg.sender]);&#13;
   }&#13;
&#13;
   /// @notice Buys the tokens for the specified tier and for the next one&#13;
   /// @param amount The amount of ether paid to buy the tokens&#13;
   /// @param tokensThisTier The limit of tokens of that tier&#13;
   /// @param tierSelected The tier selected&#13;
   /// @param _rate The rate used for that `tierSelected`&#13;
   /// @return uint The total amount of tokens bought combining the tier prices&#13;
   function calculateExcessTokens(&#13;
      uint256 amount,&#13;
      uint256 tokensThisTier,&#13;
      uint256 tierSelected,&#13;
      uint256 _rate&#13;
   ) public returns(uint256 totalTokens) {&#13;
      require(amount &gt; 0 &amp;&amp; tokensThisTier &gt; 0 &amp;&amp; _rate &gt; 0);&#13;
      require(tierSelected &gt;= 1 &amp;&amp; tierSelected &lt;= 4);&#13;
&#13;
      uint weiThisTier = tokensThisTier.sub(tokensRaised).div(_rate);&#13;
      uint weiNextTier = amount.sub(weiThisTier);&#13;
      uint tokensNextTier = 0;&#13;
      bool returnTokens = false;&#13;
&#13;
      // If there's excessive wei for the last tier, refund those&#13;
      if(tierSelected != 4)&#13;
         tokensNextTier = calculateTokensTier(weiNextTier, tierSelected.add(1));&#13;
      else&#13;
         returnTokens = true;&#13;
&#13;
      totalTokens = tokensThisTier.sub(tokensRaised).add(tokensNextTier);&#13;
&#13;
      // Do the transfer at the end&#13;
      if(returnTokens) msg.sender.transfer(weiNextTier);&#13;
   }&#13;
&#13;
   /// @notice Buys the tokens given the price of the tier one and the wei paid&#13;
   /// @param weiPaid The amount of wei paid that will be used to buy tokens&#13;
   /// @param tierSelected The tier that you'll use for thir purchase&#13;
   /// @return calculatedTokens Returns how many tokens you've bought for that wei paid&#13;
   function calculateTokensTier(uint256 weiPaid, uint256 tierSelected)&#13;
        internal constant returns(uint256 calculatedTokens)&#13;
   {&#13;
      require(weiPaid &gt; 0);&#13;
      require(tierSelected &gt;= 1 &amp;&amp; tierSelected &lt;= 4);&#13;
&#13;
      if(tierSelected == 1)&#13;
         calculatedTokens = weiPaid.mul(rate);&#13;
      else if(tierSelected == 2)&#13;
         calculatedTokens = weiPaid.mul(rateTier2);&#13;
      else if(tierSelected == 3)&#13;
         calculatedTokens = weiPaid.mul(rateTier3);&#13;
      else&#13;
         calculatedTokens = weiPaid.mul(rateTier4);&#13;
   }&#13;
&#13;
&#13;
   /// @notice Checks if a purchase is considered valid&#13;
   /// @return bool If the purchase is valid or not&#13;
   function validPurchase() internal constant returns(bool) {&#13;
      bool withinPeriod = now &gt;= startTime &amp;&amp; now &lt;= endTime;&#13;
      bool nonZeroPurchase = msg.value &gt; 0;&#13;
      bool withinTokenLimit = tokensRaised &lt; maxTokensRaised;&#13;
      bool minimumPurchase = msg.value &gt;= minPurchase;&#13;
      bool hasBalanceAvailable = crowdsaleBalances[msg.sender] &lt; maxPurchase;&#13;
&#13;
      // We want to limit the gas to avoid giving priority to the biggest paying contributors&#13;
      //bool limitGas = tx.gasprice &lt;= limitGasPrice;&#13;
&#13;
      return withinPeriod &amp;&amp; nonZeroPurchase &amp;&amp; withinTokenLimit &amp;&amp; minimumPurchase &amp;&amp; hasBalanceAvailable;&#13;
   }&#13;
&#13;
   /// @notice To see if the minimum goal of tokens of the ICO has been reached&#13;
   /// @return bool True if the tokens raised are bigger than the goal or false otherwise&#13;
   function goalReached() public constant returns(bool) {&#13;
      return tokensRaised &gt;= minimumGoal;&#13;
   }&#13;
&#13;
   /// @notice Public function to check if the crowdsale has ended or not&#13;
   function hasEnded() public constant returns(bool) {&#13;
      return now &gt; endTime || tokensRaised &gt;= maxTokensRaised;&#13;
   }&#13;
}