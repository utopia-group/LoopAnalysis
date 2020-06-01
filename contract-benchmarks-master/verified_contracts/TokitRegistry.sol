pragma solidity ^0.4.15;


contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
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



contract AbstractPaymentEscrow is Ownable {

    address public wallet;

    mapping (uint => uint) public deposits;

    event Payment(address indexed _customer, uint indexed _projectId, uint value);
    event Withdraw(address indexed _wallet, uint value);

    function withdrawFunds() public;

    /**
     * @dev Change the wallet
     * @param _wallet address of the wallet where fees will be transfered when spent
     */
    function changeWallet(address _wallet)
        public
        onlyOwner()
    {
        wallet = _wallet;
    }

    /**
     * @dev Get the amount deposited for the provided project, returns 0 if there's no deposit for that project or the amount in wei
     * @param _projectId The id of the project
     * @return 0 if there's either no deposit for _projectId, otherwise returns the deposited amount in wei
     */
    function getDeposit(uint _projectId)
        public
        constant
        returns (uint)
    {
        return deposits[_projectId];
    }
}




contract TokitRegistry is Ownable {

    struct ProjectContracts {
        address token;
        address fund;
        address campaign;
    }

    // registrar => true/false
    mapping (address => bool) public registrars;

    // customer => project_id => token/campaign
    mapping (address => mapping(uint => ProjectContracts)) public registry;
    // project_id => token/campaign
    mapping (uint => ProjectContracts) public project_registry;

    event RegisteredToken(address indexed _projectOwner, uint indexed _projectId, address _token, address _fund);
    event RegisteredCampaign(address indexed _projectOwner, uint indexed _projectId, address _campaign);

    modifier onlyRegistrars() {
        require(registrars[msg.sender]);
        _;
    }

    function TokitRegistry(address _owner) {
        setRegistrar(_owner, true);
        transferOwnership(_owner);
    }

    function register(address _customer, uint _projectId, address _token, address _fund)
        onlyRegistrars()
    {
        registry[_customer][_projectId].token = _token;
        registry[_customer][_projectId].fund = _fund;

        project_registry[_projectId].token = _token;
        project_registry[_projectId].fund = _fund;

        RegisteredToken(_customer, _projectId, _token, _fund);
    }

    function register(address _customer, uint _projectId, address _campaign)
        onlyRegistrars()
    {
        registry[_customer][_projectId].campaign = _campaign;

        project_registry[_projectId].campaign = _campaign;

        RegisteredCampaign(_customer, _projectId, _campaign);
    }

    function lookup(address _customer, uint _projectId)
        constant
        returns (address token, address fund, address campaign)
    {
        return (
            registry[_customer][_projectId].token,
            registry[_customer][_projectId].fund,
            registry[_customer][_projectId].campaign
        );
    }

    function lookupByProject(uint _projectId)
        constant
        returns (address token, address fund, address campaign)
    {
        return (
            project_registry[_projectId].token,
            project_registry[_projectId].fund,
            project_registry[_projectId].campaign
        );
    }

    function setRegistrar(address _registrar, bool enabled)
        onlyOwner()
    {
        registrars[_registrar] = enabled;
    }
}





/// @title Fund contract - Implements reward distribution.
/// @author Stefan George - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="186b6c7d7e7976367f7d776a7f7d587b77766b7d766b616b36767d6c">[email protected]</a>&gt;&#13;
/// @author Milad Mostavi - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2d4044414c490340425e594c5b446d4e42435e48435e545e03434859">[email protected]</a>&gt;&#13;
contract SingularDTVFund {&#13;
    string public version = "0.1.0";&#13;
&#13;
    /*&#13;
     *  External contracts&#13;
     */&#13;
    AbstractSingularDTVToken public singularDTVToken;&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    address public owner;&#13;
    uint public totalReward;&#13;
&#13;
    // User's address =&gt; Reward at time of withdraw&#13;
    mapping (address =&gt; uint) public rewardAtTimeOfWithdraw;&#13;
&#13;
    // User's address =&gt; Reward which can be withdrawn&#13;
    mapping (address =&gt; uint) public owed;&#13;
&#13;
    modifier onlyOwner() {&#13;
        // Only guard is allowed to do this action.&#13;
        if (msg.sender != owner) {&#13;
            revert();&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Contract functions&#13;
     */&#13;
    /// @dev Deposits reward. Returns success.&#13;
    function depositReward()&#13;
        public&#13;
        payable&#13;
        returns (bool)&#13;
    {&#13;
        totalReward += msg.value;&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Withdraws reward for user. Returns reward.&#13;
    /// @param forAddress user's address.&#13;
    function calcReward(address forAddress) private returns (uint) {&#13;
        return singularDTVToken.balanceOf(forAddress) * (totalReward - rewardAtTimeOfWithdraw[forAddress]) / singularDTVToken.totalSupply();&#13;
    }&#13;
&#13;
    /// @dev Withdraws reward for user. Returns reward.&#13;
    function withdrawReward()&#13;
        public&#13;
        returns (uint)&#13;
    {&#13;
        uint value = calcReward(msg.sender) + owed[msg.sender];&#13;
        rewardAtTimeOfWithdraw[msg.sender] = totalReward;&#13;
        owed[msg.sender] = 0;&#13;
        if (value &gt; 0 &amp;&amp; !msg.sender.send(value)) {&#13;
            revert();&#13;
        }&#13;
        return value;&#13;
    }&#13;
&#13;
    /// @dev Credits reward to owed balance.&#13;
    /// @param forAddress user's address.&#13;
    function softWithdrawRewardFor(address forAddress)&#13;
        external&#13;
        returns (uint)&#13;
    {&#13;
        uint value = calcReward(forAddress);&#13;
        rewardAtTimeOfWithdraw[forAddress] = totalReward;&#13;
        owed[forAddress] += value;&#13;
        return value;&#13;
    }&#13;
&#13;
    /// @dev Setup function sets external token address.&#13;
    /// @param singularDTVTokenAddress Token address.&#13;
    function setup(address singularDTVTokenAddress)&#13;
        external&#13;
        onlyOwner&#13;
        returns (bool)&#13;
    {&#13;
        if (address(singularDTVToken) == 0) {&#13;
            singularDTVToken = AbstractSingularDTVToken(singularDTVTokenAddress);&#13;
            return true;&#13;
        }&#13;
        return false;&#13;
    }&#13;
&#13;
    /// @dev Contract constructor function sets guard address.&#13;
    function SingularDTVFund() {&#13;
        // Set owner address&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    /// @dev Fallback function acts as depositReward()&#13;
    function ()&#13;
        public&#13;
        payable&#13;
    {&#13;
        if (msg.value == 0) {&#13;
            withdrawReward();&#13;
        } else {&#13;
            depositReward();&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract StandardToken is Token {&#13;
&#13;
    function transfer(address _to, uint256 _value) returns (bool success) {&#13;
        //Default assumes totalSupply can't be over max (2^256 - 1).&#13;
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.&#13;
        //Replace the if with this one instead.&#13;
        //require(balances[msg.sender] &gt;= _value &amp;&amp; balances[_to] + _value &gt; balances[_to]);&#13;
        require(balances[msg.sender] &gt;= _value);&#13;
        balances[msg.sender] -= _value;&#13;
        balances[_to] += _value;&#13;
        Transfer(msg.sender, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {&#13;
        //same as above. Replace this line with the following if you want to protect against wrapping uints.&#13;
        //require(balances[_from] &gt;= _value &amp;&amp; allowed[_from][msg.sender] &gt;= _value &amp;&amp; balances[_to] + _value &gt; balances[_to]);&#13;
        require(balances[_from] &gt;= _value &amp;&amp; allowed[_from][msg.sender] &gt;= _value);&#13;
        balances[_to] += _value;&#13;
        balances[_from] -= _value;&#13;
        allowed[_from][msg.sender] -= _value;&#13;
        Transfer(_from, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    function balanceOf(address _owner) constant returns (uint256 balance) {&#13;
        return balances[_owner];&#13;
    }&#13;
&#13;
    function approve(address _spender, uint256 _value) returns (bool success) {&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {&#13;
      return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    /* Approves and then calls the receiving contract */&#13;
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        Approval(msg.sender, _spender, _value);&#13;
&#13;
        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.&#13;
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)&#13;
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.&#13;
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));&#13;
        return true;&#13;
    }&#13;
&#13;
    mapping (address =&gt; uint256) balances;&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
}&#13;
&#13;
&#13;
&#13;
contract AbstractSingularDTVFund {&#13;
    function softWithdrawRewardFor(address forAddress) returns (uint);&#13;
}&#13;
&#13;
/// @title Token contract - Implements token issuance.&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5d2e29383b3c33733a38322f3a381d3e32332e38332e242e73333829">[email protected]</a>&gt;&#13;
/// @author Milad Mostavi - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3f5256535e5b1152504c4b5e49567f5c50514c5a514c464c11515a4b">[email protected]</a>&gt;&#13;
contract SingularDTVToken is StandardToken {&#13;
    string public version = "0.1.0";&#13;
&#13;
    /*&#13;
     *  External contracts&#13;
     */&#13;
    AbstractSingularDTVFund public singularDTVFund;&#13;
&#13;
    /*&#13;
     *  Token meta data&#13;
     */&#13;
    string public name;&#13;
    string public symbol;&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    /// @dev Transfers sender's tokens to a given address. Returns success.&#13;
    /// @param to Address of token receiver.&#13;
    /// @param value Number of tokens to transfer.&#13;
    function transfer(address to, uint256 value)&#13;
        returns (bool)&#13;
    {&#13;
        // Both parties withdraw their reward first&#13;
        singularDTVFund.softWithdrawRewardFor(msg.sender);&#13;
        singularDTVFund.softWithdrawRewardFor(to);&#13;
        return super.transfer(to, value);&#13;
    }&#13;
&#13;
    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.&#13;
    /// @param from Address from where tokens are withdrawn.&#13;
    /// @param to Address to where tokens are sent.&#13;
    /// @param value Number of tokens to transfer.&#13;
    function transferFrom(address from, address to, uint256 value)&#13;
        returns (bool)&#13;
    {&#13;
        // Both parties withdraw their reward first&#13;
        singularDTVFund.softWithdrawRewardFor(from);&#13;
        singularDTVFund.softWithdrawRewardFor(to);&#13;
        return super.transferFrom(from, to, value);&#13;
    }&#13;
&#13;
    function SingularDTVToken(address sDTVFundAddr, address _wallet, string _name, string _symbol, uint _totalSupply) {&#13;
        if(sDTVFundAddr == 0 || _wallet == 0) {&#13;
            // Fund and Wallet addresses should not be null.&#13;
            revert();&#13;
        }&#13;
&#13;
        balances[_wallet] = _totalSupply;&#13;
        totalSupply = _totalSupply;&#13;
&#13;
        name = _name;&#13;
        symbol = _symbol;&#13;
&#13;
        singularDTVFund = AbstractSingularDTVFund(sDTVFundAddr);&#13;
&#13;
        Transfer(this, _wallet, _totalSupply);&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract AbstractSingularDTVToken is Token {&#13;
&#13;
}&#13;
&#13;
&#13;
/// @title Token Creation contract - Implements token creation functionality.&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ddaea9b8bbbcb3f3bab8b2afbab89dbeb2b3aeb8b3aea4aef3b3b8a9">[email protected]</a>&gt;&#13;
/// @author Razvan Pop - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f88a99828e9996d6889788b89b97968b9d968b818bd6969d8c">[email protected]</a>&gt;&#13;
/// @author Milad Mostavi - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f8959194999cd695978b8c998e91b89b97968b9d968b818bd6969d8c">[email protected]</a>&gt;&#13;
contract SingularDTVLaunch {&#13;
    string public version = "0.1.0";&#13;
&#13;
    event Contributed(address indexed contributor, uint contribution, uint tokens);&#13;
&#13;
    /*&#13;
     *  External contracts&#13;
     */&#13;
    AbstractSingularDTVToken public singularDTVToken;&#13;
    address public workshop;&#13;
    address public SingularDTVWorkshop = 0xc78310231aA53bD3D0FEA2F8c705C67730929D8f;&#13;
    uint public SingularDTVWorkshopFee;&#13;
&#13;
    /*&#13;
     *  Constants&#13;
     */&#13;
    uint public CAP; // in wei scale of tokens&#13;
    uint public DURATION; // in seconds&#13;
    uint public TOKEN_TARGET; // Goal threshold in wei scale of tokens&#13;
&#13;
    /*&#13;
     *  Enums&#13;
     */&#13;
    enum Stages {&#13;
        Deployed,&#13;
        GoingAndGoalNotReached,&#13;
        EndedAndGoalNotReached,&#13;
        GoingAndGoalReached,&#13;
        EndedAndGoalReached&#13;
    }&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    address public owner;&#13;
    uint public startDate;&#13;
    uint public fundBalance;&#13;
    uint public valuePerToken; //in wei&#13;
    uint public tokensSent;&#13;
&#13;
    // participant address =&gt; value in Wei&#13;
    mapping (address =&gt; uint) public contributions;&#13;
&#13;
    // participant address =&gt; token amount in wei scale&#13;
    mapping (address =&gt; uint) public sentTokens;&#13;
&#13;
    // Initialize stage&#13;
    Stages public stage = Stages.Deployed;&#13;
&#13;
    modifier onlyOwner() {&#13;
        // Only owner is allowed to do this action.&#13;
        if (msg.sender != owner) {&#13;
            revert();&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    modifier atStage(Stages _stage) {&#13;
        if (stage != _stage) {&#13;
            revert();&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    modifier atStageOR(Stages _stage1, Stages _stage2) {&#13;
        if (stage != _stage1 &amp;&amp; stage != _stage2) {&#13;
            revert();&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    modifier timedTransitions() {&#13;
        uint timeElapsed = now - startDate;&#13;
&#13;
        if (timeElapsed &gt;= DURATION) {&#13;
            if (stage == Stages.GoingAndGoalNotReached) {&#13;
                stage = Stages.EndedAndGoalNotReached;&#13;
            } else if (stage == Stages.GoingAndGoalReached) {&#13;
                stage = Stages.EndedAndGoalReached;&#13;
            }&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Contract functions&#13;
     */&#13;
    /// dev Validates invariants.&#13;
    function checkInvariants() constant internal {&#13;
        if (fundBalance &gt; this.balance) {&#13;
            revert();&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Can be triggered if an invariant fails.&#13;
    function emergencyCall()&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        if (fundBalance &gt; this.balance) {&#13;
            if (this.balance &gt; 0 &amp;&amp; !SingularDTVWorkshop.send(this.balance)) {&#13;
                revert();&#13;
            }&#13;
            return true;&#13;
        }&#13;
        return false;&#13;
    }&#13;
&#13;
    /// @dev Allows user to create tokens if token creation is still going and cap not reached. Returns token count.&#13;
    function fund()&#13;
        public&#13;
        timedTransitions&#13;
        atStageOR(Stages.GoingAndGoalNotReached, Stages.GoingAndGoalReached)&#13;
        payable&#13;
        returns (uint)&#13;
    {&#13;
        uint tokenCount = (msg.value * (10**18)) / valuePerToken; // Token count in wei is rounded down. Sent ETH should be multiples of valuePerToken.&#13;
        require(tokenCount &gt; 0);&#13;
        if (tokensSent + tokenCount &gt; CAP) {&#13;
            // User wants to create more tokens than available. Set tokens to possible maximum.&#13;
            tokenCount = CAP - tokensSent;&#13;
        }&#13;
        tokensSent += tokenCount;&#13;
&#13;
        uint contribution = (tokenCount * valuePerToken) / (10**18); // Ether spent by user.&#13;
        // Send change back to user.&#13;
        if (msg.value &gt; contribution &amp;&amp; !msg.sender.send(msg.value - contribution)) {&#13;
            revert();&#13;
        }&#13;
        // Update fund and user's balance and total supply of tokens.&#13;
        fundBalance += contribution;&#13;
        contributions[msg.sender] += contribution;&#13;
        sentTokens[msg.sender] += tokenCount;&#13;
        if (!singularDTVToken.transfer(msg.sender, tokenCount)) {&#13;
            // Tokens could not be issued.&#13;
            revert();&#13;
        }&#13;
        // Update stage&#13;
        if (stage == Stages.GoingAndGoalNotReached) {&#13;
            if (tokensSent &gt;= TOKEN_TARGET) {&#13;
                stage = Stages.GoingAndGoalReached;&#13;
            }&#13;
        }&#13;
        // not an else clause for the edge case that the CAP and TOKEN_TARGET are reached in one call&#13;
        if (stage == Stages.GoingAndGoalReached) {&#13;
            if (tokensSent == CAP) {&#13;
                stage = Stages.EndedAndGoalReached;&#13;
            }&#13;
        }&#13;
        checkInvariants();&#13;
&#13;
        Contributed(msg.sender, contribution, tokenCount);&#13;
&#13;
        return tokenCount;&#13;
    }&#13;
&#13;
    /// @dev Allows user to withdraw ETH if token creation period ended and target was not reached. Returns contribution.&#13;
    function withdrawContribution()&#13;
        public&#13;
        timedTransitions&#13;
        atStage(Stages.EndedAndGoalNotReached)&#13;
        returns (uint)&#13;
    {&#13;
        // We get back the tokens from the contributor before giving back his contribution&#13;
        uint tokensReceived = sentTokens[msg.sender];&#13;
        sentTokens[msg.sender] = 0;&#13;
        if (!singularDTVToken.transferFrom(msg.sender, owner, tokensReceived)) {&#13;
            revert();&#13;
        }&#13;
&#13;
        // Update fund's and user's balance and total supply of tokens.&#13;
        uint contribution = contributions[msg.sender];&#13;
        contributions[msg.sender] = 0;&#13;
        fundBalance -= contribution;&#13;
        // Send ETH back to user.&#13;
        if (contribution &gt; 0) {&#13;
            msg.sender.transfer(contribution);&#13;
        }&#13;
        checkInvariants();&#13;
        return contribution;&#13;
    }&#13;
&#13;
    /// @dev Withdraws ETH to workshop address. Returns success.&#13;
    function withdrawForWorkshop()&#13;
        public&#13;
        timedTransitions&#13;
        atStage(Stages.EndedAndGoalReached)&#13;
        returns (bool)&#13;
    {&#13;
        uint value = fundBalance;&#13;
        fundBalance = 0;&#13;
&#13;
        require(value &gt; 0);&#13;
&#13;
        uint networkFee = value * SingularDTVWorkshopFee / 100;&#13;
        workshop.transfer(value - networkFee);&#13;
        SingularDTVWorkshop.transfer(networkFee);&#13;
&#13;
        uint remainingTokens = CAP - tokensSent;&#13;
        if (remainingTokens &gt; 0 &amp;&amp; !singularDTVToken.transfer(owner, remainingTokens)) {&#13;
            revert();&#13;
        }&#13;
&#13;
        checkInvariants();&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Allows owner to get back unsent tokens in case of launch failure (EndedAndGoalNotReached).&#13;
    function withdrawUnsentTokensForOwner()&#13;
        public&#13;
        timedTransitions&#13;
        atStage(Stages.EndedAndGoalNotReached)&#13;
        returns (uint)&#13;
    {&#13;
        uint remainingTokens = CAP - tokensSent;&#13;
        if (remainingTokens &gt; 0 &amp;&amp; !singularDTVToken.transfer(owner, remainingTokens)) {&#13;
            revert();&#13;
        }&#13;
&#13;
        checkInvariants();&#13;
        return remainingTokens;&#13;
    }&#13;
&#13;
    /// @dev Sets token value in Wei.&#13;
    /// @param valueInWei New value.&#13;
    function changeValuePerToken(uint valueInWei)&#13;
        public&#13;
        onlyOwner&#13;
        atStage(Stages.Deployed)&#13;
        returns (bool)&#13;
    {&#13;
        valuePerToken = valueInWei;&#13;
        return true;&#13;
    }&#13;
&#13;
    // updateStage allows calls to receive correct stage. It can be used for transactions but is not part of the regular token creation routine.&#13;
    // It is not marked as constant because timedTransitions modifier is altering state and constant is not yet enforced by solc.&#13;
    /// @dev returns correct stage, even if a function with timedTransitions modifier has not yet been called successfully.&#13;
    function updateStage()&#13;
        public&#13;
        timedTransitions&#13;
        returns (Stages)&#13;
    {&#13;
        return stage;&#13;
    }&#13;
&#13;
    function start()&#13;
        public&#13;
        onlyOwner&#13;
        atStage(Stages.Deployed)&#13;
        returns (uint)&#13;
    {&#13;
        if (!singularDTVToken.transferFrom(msg.sender, this, CAP)) {&#13;
            revert();&#13;
        }&#13;
&#13;
        startDate = now;&#13;
        stage = Stages.GoingAndGoalNotReached;&#13;
&#13;
        checkInvariants();&#13;
        return startDate;&#13;
    }&#13;
&#13;
    /// @dev Contract constructor function sets owner and start date.&#13;
    function SingularDTVLaunch(&#13;
        address singularDTVTokenAddress,&#13;
        address _workshop,&#13;
        address _owner,&#13;
        uint _total,&#13;
        uint _unit_price,&#13;
        uint _duration,&#13;
        uint _threshold,&#13;
        uint _singulardtvwoskhop_fee&#13;
        ) {&#13;
        singularDTVToken = AbstractSingularDTVToken(singularDTVTokenAddress);&#13;
        workshop = _workshop;&#13;
        owner = _owner;&#13;
        CAP = _total; // Total number of tokens (wei scale)&#13;
        valuePerToken = _unit_price; // wei per token&#13;
        DURATION = _duration; // in seconds&#13;
        TOKEN_TARGET = _threshold; // Goal threshold&#13;
        SingularDTVWorkshopFee = _singulardtvwoskhop_fee;&#13;
    }&#13;
&#13;
    /// @dev Fallback function acts as fund() when stage GoingAndGoalNotReached&#13;
    /// or GoingAndGoalReached. And act as withdrawFunding() when EndedAndGoalNotReached.&#13;
    /// otherwise throw.&#13;
    function ()&#13;
        public&#13;
        payable&#13;
    {&#13;
        if (stage == Stages.GoingAndGoalNotReached || stage == Stages.GoingAndGoalReached)&#13;
            fund();&#13;
        else if (stage == Stages.EndedAndGoalNotReached)&#13;
            withdrawContribution();&#13;
        else&#13;
            revert();&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract TokitDeployer is Ownable {&#13;
&#13;
    TokitRegistry public registry;&#13;
&#13;
    // payment_type =&gt; payment_contract&#13;
    mapping (uint8 =&gt; AbstractPaymentEscrow) public paymentContracts;&#13;
&#13;
    event DeployedToken(address indexed _customer, uint indexed _projectId, address _token, address _fund);&#13;
    event DeployedCampaign(address indexed _customer, uint indexed _projectId, address _campaign);&#13;
&#13;
&#13;
    function TokitDeployer(address _owner, address _registry) {&#13;
        transferOwnership(_owner);&#13;
        registry = TokitRegistry(_registry);&#13;
    }&#13;
&#13;
    function deployToken(&#13;
        address _customer, uint _projectId, uint8 _payedWith, uint _amountNeeded,&#13;
        // SingularDTVToken&#13;
        address _wallet, string _name, string _symbol, uint _totalSupply&#13;
    )&#13;
        onlyOwner()&#13;
    {&#13;
        // payed for&#13;
        require(AbstractPaymentEscrow(paymentContracts[_payedWith]).getDeposit(_projectId) &gt;= _amountNeeded);&#13;
&#13;
        var (t,,) = registry.lookup(_customer, _projectId);&#13;
        // not deployed yet&#13;
        require(t == address(0));&#13;
&#13;
&#13;
        SingularDTVFund fund = new SingularDTVFund();&#13;
        SingularDTVToken token = new SingularDTVToken(fund, _wallet, _name, _symbol, _totalSupply);&#13;
        fund.setup(token);&#13;
&#13;
        registry.register(_customer, _projectId, token, fund);&#13;
&#13;
        DeployedToken(_customer, _projectId, token, fund);&#13;
    }&#13;
&#13;
    function deployCampaign(&#13;
        address _customer, uint _projectId,&#13;
        // SingularDTVLaunch&#13;
        address _workshop, uint _total, uint _unitPrice, uint _duration, uint _threshold, uint _networkFee&#13;
    )&#13;
        onlyOwner()&#13;
    {&#13;
        var (t,f,c) = registry.lookup(_customer, _projectId);&#13;
        // not deployed yet&#13;
        require(c == address(0));&#13;
&#13;
        // payed for, token &amp; fund deployed&#13;
        require(t != address(0) &amp;&amp; f != address(0));&#13;
&#13;
        SingularDTVLaunch campaign = new SingularDTVLaunch(t, _workshop, _customer, _total, _unitPrice, _duration, _threshold, _networkFee);&#13;
&#13;
        registry.register(_customer, _projectId, campaign);&#13;
&#13;
        DeployedCampaign(_customer, _projectId, campaign);&#13;
    }&#13;
&#13;
    function setRegistryContract(address _registry)&#13;
        onlyOwner()&#13;
    {&#13;
        registry = TokitRegistry(_registry);&#13;
    }&#13;
&#13;
    function setPaymentContract(uint8 _paymentType, address _paymentContract)&#13;
        onlyOwner()&#13;
    {&#13;
        paymentContracts[_paymentType] = AbstractPaymentEscrow(_paymentContract);&#13;
    }&#13;
&#13;
    function deletePaymentContract(uint8 _paymentType)&#13;
        onlyOwner()&#13;
    {&#13;
        delete paymentContracts[_paymentType];&#13;
    }&#13;
}