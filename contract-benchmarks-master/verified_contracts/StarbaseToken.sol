pragma solidity ^0.4.13;

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
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
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


contract AbstractStarbaseCrowdsale {
    function workshop() constant returns (address) {}
    function startDate() constant returns (uint256) {}
    function endedAt() constant returns (uint256) {}
    function isEnded() constant returns (bool);
    function totalRaisedAmountInCny() constant returns (uint256);
    function numOfPurchasedTokensOnCsBy(address purchaser) constant returns (uint256);
    function numOfPurchasedTokensOnEpBy(address purchaser) constant returns (uint256);
}

contract AbstractStarbaseMarketingCampaign {
    function workshop() constant returns (address) {}
}

/// @title Token contract - ERC20 compatible Starbase token contract.
/// @author Starbase PTE. LTD. - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="670e090108271413061505061402490408">[email protected]</a>&gt;&#13;
contract StarbaseToken is StandardToken {&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event PublicOfferingPlanDeclared(uint256 tokenCount, uint256 unlockCompanysTokensAt);&#13;
    event MvpLaunched(uint256 launchedAt);&#13;
    event LogNewFundraiser (address indexed fundraiserAddress, bool isBonaFide);&#13;
    event LogUpdateFundraiser(address indexed fundraiserAddress, bool isBonaFide);&#13;
&#13;
    /*&#13;
     *  Types&#13;
     */&#13;
    struct PublicOfferingPlan {&#13;
        uint256 tokenCount;&#13;
        uint256 unlockCompanysTokensAt;&#13;
        uint256 declaredAt;&#13;
    }&#13;
&#13;
    /*&#13;
     *  External contracts&#13;
     */&#13;
    AbstractStarbaseCrowdsale public starbaseCrowdsale;&#13;
    AbstractStarbaseMarketingCampaign public starbaseMarketingCampaign;&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    address public company;&#13;
    PublicOfferingPlan[] public publicOfferingPlans;  // further crowdsales&#13;
    mapping(address =&gt; uint256) public initialEcTokenAllocation;    // Initial token allocations for Early Contributors&#13;
    uint256 public mvpLaunchedAt;  // 0 until a MVP of Starbase Platform launches&#13;
    mapping(address =&gt; bool) private fundraisers; // Fundraisers are vetted addresses that are allowed to execute functions within the contract&#13;
&#13;
    /*&#13;
     *  Constants / Token meta data&#13;
     */&#13;
    string constant public name = "Starbase";  // Token name&#13;
    string constant public symbol = "STAR";  // Token symbol&#13;
    uint8 constant public decimals = 18;&#13;
    uint256 constant public initialSupply = 1000000000e18; // 1B STAR tokens&#13;
    uint256 constant public initialCompanysTokenAllocation = 750000000e18;  // 750M&#13;
&#13;
&#13;
    /*&#13;
     *  Modifiers&#13;
     */&#13;
    modifier onlyCrowdsaleContract() {&#13;
        assert(msg.sender == address(starbaseCrowdsale));&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyMarketingCampaignContract() {&#13;
        assert(msg.sender == address(starbaseMarketingCampaign));&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyFundraiser() {&#13;
        // Only rightful fundraiser is permitted.&#13;
        assert(isFundraiser(msg.sender));&#13;
        _;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Contract functions&#13;
     */&#13;
&#13;
    /**&#13;
     * @dev Contract constructor function&#13;
     * @param starbaseCompanyAddr The address that will holds untransferrable tokens&#13;
     * @param starbaseCrowdsaleAddr Address of the crowdsale contract&#13;
     * @param starbaseMarketingCampaignAddr The address of the marketing campaign contract&#13;
     */&#13;
&#13;
    function StarbaseToken(&#13;
        address starbaseCompanyAddr,&#13;
        address starbaseCrowdsaleAddr,&#13;
        address starbaseMarketingCampaignAddr&#13;
    ) {&#13;
        assert(&#13;
            starbaseCompanyAddr != 0 &amp;&amp;&#13;
            starbaseCrowdsaleAddr != 0 &amp;&amp;&#13;
            starbaseMarketingCampaignAddr != 0);&#13;
&#13;
        starbaseCrowdsale = AbstractStarbaseCrowdsale(starbaseCrowdsaleAddr);&#13;
        starbaseMarketingCampaign = AbstractStarbaseMarketingCampaign(starbaseMarketingCampaignAddr);&#13;
        company = starbaseCompanyAddr;&#13;
&#13;
        // msg.sender becomes first fundraiser&#13;
        fundraisers[msg.sender] = true;&#13;
        LogNewFundraiser(msg.sender, true);&#13;
&#13;
        // Tokens for crowdsale and early purchasers&#13;
        balances[starbaseCrowdsale.workshop()] = 175000000e18; // CS(125M)+EP(50M)&#13;
&#13;
        // Tokens for marketing campaign supporters&#13;
        balances[starbaseMarketingCampaign.workshop()] = 12500000e18; // 12.5M&#13;
&#13;
        // Tokens for early contributors, should be allocated by function&#13;
        balances[0] = 62500000e18; // 62.5M&#13;
&#13;
        // Starbase company holds untransferrable tokens initially&#13;
        balances[starbaseCompanyAddr] = initialCompanysTokenAllocation; // 750M&#13;
&#13;
        totalSupply = initialSupply;    // 1B&#13;
    }&#13;
&#13;
    /*&#13;
     *  External functions&#13;
     */&#13;
&#13;
    /**&#13;
     * @dev Returns number of declared public offering plans&#13;
     */&#13;
    function numOfDeclaredPublicOfferingPlans()&#13;
        external&#13;
        constant&#13;
        returns (uint256)&#13;
    {&#13;
        return publicOfferingPlans.length;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Declares a public offering plan to make company's tokens transferable&#13;
     * @param tokenCount Number of tokens to transfer.&#13;
     * @param unlockCompanysTokensAt Time of the tokens will be unlocked&#13;
     */&#13;
    function declarePulicOfferingPlan(uint256 tokenCount, uint256 unlockCompanysTokensAt)&#13;
        external&#13;
        onlyFundraiser()&#13;
        returns (bool)&#13;
    {&#13;
        assert(tokenCount &lt;= 100000000e18);    // shall not exceed 100M tokens&#13;
        assert(SafeMath.sub(now, starbaseCrowdsale.endedAt()) &gt;= 180 days);   // shall not be declared for 6 months after the crowdsale ended&#13;
        assert(SafeMath.sub(unlockCompanysTokensAt, now) &gt;= 60 days);   // tokens must be untransferable at least for 2 months&#13;
&#13;
        // check if last declaration was more than 6 months ago&#13;
        if (publicOfferingPlans.length &gt; 0) {&#13;
            uint256 lastDeclaredAt =&#13;
                publicOfferingPlans[publicOfferingPlans.length - 1].declaredAt;&#13;
            assert(SafeMath.sub(now, lastDeclaredAt) &gt;= 180 days);&#13;
        }&#13;
&#13;
        uint256 totalDeclaredTokenCount = tokenCount;&#13;
        for (uint8 i; i &lt; publicOfferingPlans.length; i++) {&#13;
            totalDeclaredTokenCount += publicOfferingPlans[i].tokenCount;&#13;
        }&#13;
        assert(totalDeclaredTokenCount &lt;= initialCompanysTokenAllocation);   // shall not exceed the initial token allocation&#13;
&#13;
        publicOfferingPlans.push(&#13;
            PublicOfferingPlan(tokenCount, unlockCompanysTokensAt, now));&#13;
&#13;
        PublicOfferingPlanDeclared(tokenCount, unlockCompanysTokensAt);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Allocate tokens to a marketing supporter from the marketing campaign share&#13;
     * @param to Address to where tokens are allocated&#13;
     * @param value Number of tokens to transfer&#13;
     */&#13;
    function allocateToMarketingSupporter(address to, uint256 value)&#13;
        external&#13;
        onlyMarketingCampaignContract&#13;
        returns (bool)&#13;
    {&#13;
        return allocateFrom(starbaseMarketingCampaign.workshop(), to, value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Allocate tokens to an early contributor from the early contributor share&#13;
     * @param to Address to where tokens are allocated&#13;
     * @param value Number of tokens to transfer&#13;
     */&#13;
    function allocateToEarlyContributor(address to, uint256 value)&#13;
        external&#13;
        onlyFundraiser()&#13;
        returns (bool)&#13;
    {&#13;
        initialEcTokenAllocation[to] =&#13;
            SafeMath.add(initialEcTokenAllocation[to], value);&#13;
        return allocateFrom(0, to, value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Issue new tokens according to the STAR token inflation limits&#13;
     * @param _for Address to where tokens are allocated&#13;
     * @param value Number of tokens to issue&#13;
     */&#13;
    function issueTokens(address _for, uint256 value)&#13;
        external&#13;
        onlyFundraiser()&#13;
        returns (bool)&#13;
    {&#13;
        // check if the value under the limits&#13;
        assert(value &lt;= numOfInflatableTokens());&#13;
&#13;
        totalSupply = SafeMath.add(totalSupply, value);&#13;
        balances[_for] += value;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Declares Starbase MVP has been launched&#13;
     * @param launchedAt When the MVP launched (timestamp)&#13;
     */&#13;
    function declareMvpLaunched(uint256 launchedAt) external onlyFundraiser() returns (bool) {&#13;
        require(mvpLaunchedAt == 0); // overwriting the launch date is not permitted&#13;
        require(launchedAt &lt;= now);&#13;
        require(starbaseCrowdsale.isEnded());&#13;
&#13;
        mvpLaunchedAt = launchedAt;&#13;
        MvpLaunched(launchedAt);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Allocate tokens to a crowdsale or early purchaser from the crowdsale share&#13;
     * @param to Address to where tokens are allocated&#13;
     * @param value Number of tokens to transfer&#13;
     */&#13;
    function allocateToCrowdsalePurchaser(address to, uint256 value)&#13;
        external&#13;
        onlyCrowdsaleContract&#13;
        returns (bool)&#13;
    {&#13;
        return allocateFrom(starbaseCrowdsale.workshop(), to, value);&#13;
    }&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
&#13;
    /**&#13;
     * @dev Transfers sender's tokens to a given address. Returns success.&#13;
     * @param to Address of token receiver.&#13;
     * @param value Number of tokens to transfer.&#13;
     */&#13;
    function transfer(address to, uint256 value) public returns (bool) {&#13;
        assert(isTransferable(msg.sender, value));&#13;
        return super.transfer(to, value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Allows third party to transfer tokens from one address to another. Returns success.&#13;
     * @param from Address from where tokens are withdrawn.&#13;
     * @param to Address to where tokens are sent.&#13;
     * @param value Number of tokens to transfer.&#13;
     */&#13;
    function transferFrom(address from, address to, uint256 value) public returns (bool) {&#13;
        assert(isTransferable(from, value));&#13;
        return super.transferFrom(from, to, value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Adds fundraiser. Only called by another fundraiser.&#13;
     * @param fundraiserAddress The address in check&#13;
     */&#13;
    function addFundraiser(address fundraiserAddress) public onlyFundraiser {&#13;
        assert(!isFundraiser(fundraiserAddress));&#13;
&#13;
        fundraisers[fundraiserAddress] = true;&#13;
        LogNewFundraiser(fundraiserAddress, true);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Update fundraiser address rights.&#13;
     * @param fundraiserAddress The address to update&#13;
     * @param isBonaFide Boolean that denotes whether fundraiser is active or not.&#13;
     */&#13;
    function updateFundraiser(address fundraiserAddress, bool isBonaFide)&#13;
       public&#13;
       onlyFundraiser&#13;
       returns(bool)&#13;
    {&#13;
        assert(isFundraiser(fundraiserAddress));&#13;
&#13;
        fundraisers[fundraiserAddress] = isBonaFide;&#13;
        LogUpdateFundraiser(fundraiserAddress, isBonaFide);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Returns whether fundraiser address has rights.&#13;
     * @param fundraiserAddress The address in check&#13;
     */&#13;
    function isFundraiser(address fundraiserAddress) constant public returns(bool) {&#13;
        return fundraisers[fundraiserAddress];&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Returns whether the transferring of tokens is available fundraiser.&#13;
     * @param from Address of token sender&#13;
     * @param tokenCount Number of tokens to transfer.&#13;
     */&#13;
    function isTransferable(address from, uint256 tokenCount)&#13;
        constant&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        if (tokenCount == 0 || balances[from] &lt; tokenCount) {&#13;
            return false;&#13;
        }&#13;
&#13;
        // company's tokens may be locked up&#13;
        if (from == company) {&#13;
            if (tokenCount &gt; numOfTransferableCompanysTokens()) {&#13;
                return false;&#13;
            }&#13;
        }&#13;
&#13;
        uint256 untransferableTokenCount = 0;&#13;
&#13;
        // early contributor's tokens may be locked up&#13;
        if (initialEcTokenAllocation[from] &gt; 0) {&#13;
            untransferableTokenCount = SafeMath.add(&#13;
                untransferableTokenCount,&#13;
                numOfUntransferableEcTokens(from));&#13;
        }&#13;
&#13;
        // EP and CS purchasers' tokens should be untransferable initially&#13;
        if (starbaseCrowdsale.isEnded()) {&#13;
            uint256 passedDays =&#13;
                SafeMath.sub(now, starbaseCrowdsale.endedAt()) / 86400; // 1d = 86400s&#13;
            if (passedDays &lt; 7) {  // within a week&#13;
                // crowdsale purchasers cannot transfer their tokens for a week&#13;
                untransferableTokenCount = SafeMath.add(&#13;
                    untransferableTokenCount,&#13;
                    starbaseCrowdsale.numOfPurchasedTokensOnCsBy(from));&#13;
            }&#13;
            if (passedDays &lt; 14) {  // within two weeks&#13;
                // early purchasers cannot transfer their tokens for two weeks&#13;
                untransferableTokenCount = SafeMath.add(&#13;
                    untransferableTokenCount,&#13;
                    starbaseCrowdsale.numOfPurchasedTokensOnEpBy(from));&#13;
            }&#13;
        }&#13;
&#13;
        uint256 transferableTokenCount =&#13;
            SafeMath.sub(balances[from], untransferableTokenCount);&#13;
&#13;
        if (transferableTokenCount &lt; tokenCount) {&#13;
            return false;&#13;
        } else {&#13;
            return true;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Returns the number of transferable company's tokens&#13;
     */&#13;
    function numOfTransferableCompanysTokens() constant public returns (uint256) {&#13;
        uint256 unlockedTokens = 0;&#13;
        for (uint8 i; i &lt; publicOfferingPlans.length; i++) {&#13;
            PublicOfferingPlan memory plan = publicOfferingPlans[i];&#13;
            if (plan.unlockCompanysTokensAt &lt;= now) {&#13;
                unlockedTokens += plan.tokenCount;&#13;
            }&#13;
        }&#13;
        return SafeMath.sub(&#13;
            balances[company],&#13;
            initialCompanysTokenAllocation - unlockedTokens);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Returns the number of untransferable tokens of the early contributor&#13;
     * @param _for Address of early contributor to check&#13;
     */&#13;
    function numOfUntransferableEcTokens(address _for) constant public returns (uint256) {&#13;
        uint256 initialCount = initialEcTokenAllocation[_for];&#13;
        if (mvpLaunchedAt == 0) {&#13;
            return initialCount;&#13;
        }&#13;
&#13;
        uint256 passedWeeks = SafeMath.sub(now, mvpLaunchedAt) / 7 days;&#13;
        if (passedWeeks &lt;= 52) {    // a year ≈ 52 weeks&#13;
            // all tokens should be locked up for a year&#13;
            return initialCount;&#13;
        }&#13;
&#13;
        // unlock 1/52 tokens every weeks after a year&#13;
        uint256 transferableTokenCount = initialCount / 52 * (passedWeeks - 52);&#13;
        if (transferableTokenCount &gt;= initialCount) {&#13;
            return 0;&#13;
        } else {&#13;
            return SafeMath.sub(initialCount, transferableTokenCount);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Returns number of tokens which can be issued according to the inflation rules&#13;
     */&#13;
    function numOfInflatableTokens() constant public returns (uint256) {&#13;
        if (starbaseCrowdsale.endedAt() == 0) {&#13;
            return 0;&#13;
        }&#13;
        uint256 passedDays = SafeMath.sub(now, starbaseCrowdsale.endedAt()) / 86400;  // 1d = 60s * 60m * 24h = 86400s&#13;
        uint256 passedYears = passedDays * 100 / 36525;    // about 365.25 days in a year&#13;
        uint256 inflatedSupply = initialSupply;&#13;
        for (uint256 i; i &lt; passedYears; i++) {&#13;
            inflatedSupply += SafeMath.mul(inflatedSupply, 25) / 1000; // 2.5%/y = 0.025/y&#13;
        }&#13;
&#13;
        uint256 remainderedDays = passedDays * 100 % 36525 / 100;&#13;
        if (remainderedDays &gt; 0) {&#13;
            uint256 inflatableTokensOfNextYear =&#13;
                SafeMath.mul(inflatedSupply, 25) / 1000;&#13;
            inflatedSupply += SafeMath.mul(&#13;
                inflatableTokensOfNextYear, remainderedDays * 100) / 36525;&#13;
        }&#13;
&#13;
        return SafeMath.sub(inflatedSupply, totalSupply);&#13;
    }&#13;
&#13;
    /*&#13;
     *  Internal functions&#13;
     */&#13;
&#13;
    /**&#13;
     * @dev Allocate tokens value from an address to another one. This function is only called internally.&#13;
     * @param from Address from where tokens come&#13;
     * @param to Address to where tokens are allocated&#13;
     * @param value Number of tokens to transfer&#13;
     */&#13;
    function allocateFrom(address from, address to, uint256 value) internal returns (bool) {&#13;
        assert(value &gt; 0 &amp;&amp; balances[from] &gt;= value);&#13;
        balances[from] -= value;&#13;
        balances[to] += value;&#13;
        Transfer(from, to, value);&#13;
        return true;&#13;
    }&#13;
}