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


contract AbstractSingularDTVToken is Token {

}


/// @title Token Creation contract - Implements token creation functionality.
/// @author Stefan George - <<span class="__cf_email__" data-cfemail="82f1f6e7e4e3ecace5e7edf0e5e7c2e1edecf1e7ecf1fbf1acece7f6">[email protected]</span>&gt;&#13;
/// @author Razvan Pop - &lt;<span class="__cf_email__" data-cfemail="90e2f1eae6f1febee0ffe0d0f3fffee3f5fee3e9e3befef5e4">[email protected]</span>&gt;&#13;
/// @author Milad Mostavi - &lt;<span class="__cf_email__" data-cfemail="533e3a3f32377d3e3c202732253a13303c3d20363d202a207d3d3627">[email protected]</span>&gt;&#13;
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
}