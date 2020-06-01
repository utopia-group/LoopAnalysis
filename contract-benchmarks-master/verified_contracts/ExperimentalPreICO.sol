pragma solidity ^0.4.11;

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
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


/**
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="5a283f3739351a68">[email protected]</span>π.com&gt;&#13;
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
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  uint256 public totalSupply;&#13;
  function balanceOf(address who) constant returns (uint256);&#13;
  function transfer(address to, uint256 value) returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="4735222a24280775">[email protected]</span>π.com&gt;&#13;
 * @dev This blocks incoming ERC23 tokens to prevent accidental loss of tokens.&#13;
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the&#13;
 * owner to reclaim the tokens.&#13;
 */&#13;
contract reclaimTokens is Ownable {&#13;
&#13;
  /**&#13;
   * @dev Reclaim all ERC20Basic compatible tokens&#13;
   * @param tokenAddr address The address of the token contract&#13;
   */&#13;
  function reclaimToken(address tokenAddr) external onlyOwner {&#13;
    ERC20Basic tokenInst = ERC20Basic(tokenAddr);&#13;
    uint256 balance = tokenInst.balanceOf(this);&#13;
    tokenInst.transfer(owner, balance);&#13;
  }&#13;
}&#13;
&#13;
contract ExperimentalPreICO is reclaimTokens, HasNoContracts {&#13;
  using SafeMath for uint256;&#13;
&#13;
  address public beneficiary;&#13;
  bool public fundingGoalReached = false;&#13;
  bool public crowdsaleClosed = false;&#13;
  ERC20Basic public rewardToken;&#13;
  uint256 public fundingGoal;&#13;
  uint256 public fundingCap;&#13;
  uint256 public paymentMin;&#13;
  uint256 public paymentMax;&#13;
  uint256 public amountRaised;&#13;
  uint256 public rate;&#13;
&#13;
  mapping(address =&gt; uint256) public balanceOf;&#13;
  mapping(address =&gt; bool) public whitelistedAddresses;&#13;
  event GoalReached(address beneficiaryAddress, uint256 amount);&#13;
  event FundTransfer(address backer, uint256 amount, bool isContribution);&#13;
&#13;
  /**&#13;
   * @dev data structure to hold information about campaign contributors&#13;
   */&#13;
  function ExperimentalPreICO(address _wallet,&#13;
                              uint256 _goalInEthers,&#13;
                              uint256 _capInEthers,&#13;
                              uint256 _minPaymentInEthers,&#13;
                              uint256 _maxPaymentInEthers,&#13;
                              uint256 _rate,&#13;
                              address _rewardToken) {&#13;
    require(_goalInEthers &gt; 0);&#13;
    require(_capInEthers &gt;= _goalInEthers);&#13;
    require(_minPaymentInEthers &gt; 0);&#13;
    require(_maxPaymentInEthers &gt; _minPaymentInEthers);&#13;
    require(_rate &gt; 0);&#13;
    require(_wallet != 0x0);&#13;
    beneficiary = _wallet;&#13;
    fundingGoal = _goalInEthers.mul(1 ether);&#13;
    fundingCap = _capInEthers.mul(1 ether);&#13;
    paymentMin = _minPaymentInEthers.mul(1 ether);&#13;
    paymentMax = _maxPaymentInEthers.mul(1 ether);&#13;
    rate = _rate;&#13;
    rewardToken = ERC20Basic(_rewardToken);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev The default function that is called whenever anyone sends funds to the contract&#13;
   */&#13;
  function () external payable crowdsaleActive {&#13;
    require(validPurchase());&#13;
&#13;
    uint256 amount = msg.value;&#13;
    balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);&#13;
    amountRaised = amountRaised.add(amount);&#13;
    rewardToken.transfer(msg.sender, amount.mul(rate));&#13;
    FundTransfer(msg.sender, amount, true);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Throws if called when crowdsale is still open.&#13;
   */&#13;
  modifier crowdsaleEnded() {&#13;
    require(crowdsaleClosed == true);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Throws if called when crowdsale has closed.&#13;
   */&#13;
  modifier crowdsaleActive() {&#13;
    require(crowdsaleClosed == false);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev return true if the transaction can buy tokens&#13;
   */&#13;
  function validPurchase() internal returns (bool) {&#13;
    bool whitelisted = whitelistedAddresses[msg.sender] == true;&#13;
    bool validAmmount = msg.value &gt;= paymentMin &amp;&amp; msg.value &lt;= paymentMax;&#13;
    bool availableFunding = fundingCap &gt;= amountRaised.add(msg.value);&#13;
    return whitelisted &amp;&amp; validAmmount &amp;&amp; availableFunding;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev checks if the goal has been reached&#13;
   */&#13;
  function checkGoal() external onlyOwner {&#13;
    if (amountRaised &gt;= fundingGoal){&#13;
      fundingGoalReached = true;&#13;
      GoalReached(beneficiary, amountRaised);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev ends or resumes the crowdsale&#13;
   */&#13;
  function endCrowdsale() external onlyOwner {&#13;
    crowdsaleClosed = true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows backers to withdraw their funds in the crowdsale was unsuccessful,&#13;
   * and allow the owner to send the amount raised to the beneficiary&#13;
   */&#13;
  function safeWithdrawal() external crowdsaleEnded {&#13;
    if (!fundingGoalReached) {&#13;
      uint256 amount = balanceOf[msg.sender];&#13;
      balanceOf[msg.sender] = 0;&#13;
      if (amount &gt; 0) {&#13;
        if (msg.sender.send(amount)) {&#13;
          FundTransfer(msg.sender, amount, false);&#13;
        } else {&#13;
          balanceOf[msg.sender] = amount;&#13;
        }&#13;
      }&#13;
    }&#13;
&#13;
    if (fundingGoalReached &amp;&amp; owner == msg.sender) {&#13;
      if (beneficiary.send(amountRaised)) {&#13;
        FundTransfer(beneficiary, amountRaised, false);&#13;
      } else {&#13;
        //If we fail to send the funds to beneficiary, unlock funders balance&#13;
        fundingGoalReached = false;&#13;
      }&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Whitelists a list of addresses&#13;
   */&#13;
  function whitelistAddress (address[] addresses) external onlyOwner crowdsaleActive {&#13;
    for (uint i = 0; i &lt; addresses.length; i++) {&#13;
      whitelistedAddresses[addresses[i]] = true;&#13;
    }&#13;
  }&#13;
&#13;
}