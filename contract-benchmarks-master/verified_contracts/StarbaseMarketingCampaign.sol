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
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract AbstractStarbaseToken is ERC20 {
    function isFundraiser(address fundraiserAddress) public returns (bool);
    function company() public returns (address);
    function allocateToCrowdsalePurchaser(address to, uint256 value) public returns (bool);
    function allocateToMarketingSupporter(address to, uint256 value) public returns (bool);
}

/**
 * @title Crowdsale contract - Starbase marketing campaign contract to reward supportors
 * @author Starbase PTE. LTD. - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5930373f36192a2d382b3b382a3c773a36">[email protected]</a>&gt;&#13;
 */&#13;
contract StarbaseMarketingCampaign is Ownable {&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event NewContributor (address indexed contributorAddress, uint256 tokenCount);&#13;
    event UpdateContributorsTokens(address indexed contributorAddress, uint256 tokenCount);&#13;
    event WithdrawContributorsToken(address indexed contributorAddress, uint256 tokenWithdrawn, uint remainingTokens);&#13;
&#13;
    /**&#13;
     *  External contracts&#13;
     */&#13;
    AbstractStarbaseToken public starbaseToken;&#13;
&#13;
    /**&#13;
     * Types&#13;
     */&#13;
    struct Contributor {&#13;
        uint256 rewardTokens;&#13;
        uint256 transferredRewardTokens;&#13;
        mapping (bytes32 =&gt; bool) contributions;  // example: keccak256(bcm-xda98sdf) =&gt; true&#13;
    }&#13;
&#13;
    /**&#13;
     *  Storage&#13;
     */&#13;
    address public workshop;  // holds undelivered STARs&#13;
    address[] public contributors;&#13;
    mapping (address =&gt; Contributor) public contributor;&#13;
&#13;
    /**&#13;
     *  Modifiers&#13;
     */&#13;
    modifier onlyOwnerOr(address _allowed) {&#13;
        // Only owner or specified address are allowed to do this action.&#13;
        assert(msg.sender == owner || msg.sender == _allowed);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     *  Functions&#13;
     */&#13;
&#13;
    /**&#13;
     * @dev Contract constructor sets owner and workshop address.&#13;
     * @param workshopAddr The address that will hold undelivered Star tokens&#13;
     */&#13;
    function StarbaseMarketingCampaign(address workshopAddr) {&#13;
        require(workshopAddr != address(0));&#13;
        owner = msg.sender;&#13;
        workshop = workshopAddr;&#13;
    }&#13;
&#13;
    /*&#13;
     *  External Functions&#13;
     */&#13;
&#13;
    /**&#13;
     * @dev Allows for marketing contributor's reward withdrawl&#13;
     * @param contributorAddress The address of the contributor&#13;
     * @param tokensToTransfer Token number to withdraw&#13;
     */&#13;
    function withdrawRewardedTokens (address contributorAddress, uint256 tokensToTransfer)&#13;
        external&#13;
        onlyOwnerOr(contributorAddress)&#13;
    {&#13;
        require(contributor[contributorAddress].rewardTokens &gt; 0 &amp;&amp; tokensToTransfer &lt;= contributor[contributorAddress].rewardTokens &amp;&amp; address(starbaseToken) != 0);&#13;
&#13;
        contributor[contributorAddress].rewardTokens = SafeMath.sub(contributor[contributorAddress].rewardTokens, tokensToTransfer);&#13;
&#13;
        contributor[contributorAddress].transferredRewardTokens = SafeMath.add(contributor[contributorAddress].transferredRewardTokens, tokensToTransfer);&#13;
&#13;
        starbaseToken.allocateToMarketingSupporter(contributorAddress, tokensToTransfer);&#13;
        WithdrawContributorsToken(contributorAddress, tokensToTransfer, contributor[contributorAddress].rewardTokens);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Setup function sets external contracts' addresses.&#13;
     * @param starbaseTokenAddress Token address.&#13;
     */&#13;
    function setup(address starbaseTokenAddress)&#13;
        external&#13;
        onlyOwner&#13;
        returns (bool)&#13;
    {&#13;
        assert(address(starbaseToken) == 0);&#13;
        starbaseToken = AbstractStarbaseToken(starbaseTokenAddress);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Include new contributor&#13;
     * @param contributorAddress A contributor's address&#13;
     * @param tokenCount number of tokens assigned to contributor on their inclusion&#13;
     * @param contributionId Id of contribution from bounty app db&#13;
     */&#13;
    function addRewardforNewContributor&#13;
        (&#13;
            address contributorAddress,&#13;
            uint256 tokenCount,&#13;
            string contributionId&#13;
        )&#13;
            external&#13;
            onlyOwner&#13;
    {&#13;
        bytes32 id = keccak256(contributionId);&#13;
&#13;
        require(!contributor[contributorAddress].contributions[id]);&#13;
        assert(contributor[contributorAddress].rewardTokens == 0 &amp;&amp; contributor[contributorAddress].transferredRewardTokens == 0);&#13;
&#13;
        contributor[contributorAddress].rewardTokens = tokenCount;&#13;
        contributor[contributorAddress].contributions[id] = true;&#13;
        contributors.push(contributorAddress);&#13;
        NewContributor(contributorAddress, tokenCount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Updates contributors rewardTokens&#13;
     * @param contributorAddress A contributor's address&#13;
     * @param tokenCount number of tokens to update for the contributor&#13;
     * @param contributionId Id of contribution from bounty app db&#13;
     */&#13;
    function updateRewardForContributor (address contributorAddress, uint256 tokenCount, string contributionId)&#13;
        external&#13;
        onlyOwner&#13;
        returns (bool)&#13;
    {&#13;
        bytes32 id = keccak256(contributionId);&#13;
&#13;
        require(contributor[contributorAddress].contributions[id]);&#13;
&#13;
        contributor[contributorAddress].rewardTokens = SafeMath.add(contributor[contributorAddress].rewardTokens, tokenCount);&#13;
        UpdateContributorsTokens(contributorAddress, tokenCount);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     *  Public Functions&#13;
     */&#13;
&#13;
    /**&#13;
     * @dev Informs about contributors rewardTokens and transferredRewardTokens status&#13;
     * @param contributorAddress A contributor's address&#13;
     * @param contributionId Id of contribution from bounty app db&#13;
     */&#13;
    function getContributorInfo(address contributorAddress, string contributionId)&#13;
      constant&#13;
      public&#13;
      returns (uint256, uint256, bool)&#13;
    {&#13;
        bytes32 id = keccak256(contributionId);&#13;
&#13;
        return(&#13;
          contributor[contributorAddress].rewardTokens,&#13;
          contributor[contributorAddress].transferredRewardTokens,&#13;
          contributor[contributorAddress].contributions[id]&#13;
        );&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Returns number of contributors.&#13;
     */&#13;
    function numberOfContributors()&#13;
      constant&#13;
      public&#13;
      returns (uint256)&#13;
    {&#13;
      return contributors.length;&#13;
    }&#13;
}