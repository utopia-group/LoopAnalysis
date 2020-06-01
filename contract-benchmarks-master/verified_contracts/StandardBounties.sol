pragma solidity 0.4.18;
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

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardToken is StandardToken {

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HumanStandardToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}

/// @title StandardBounties
/// @dev Used to pay out individuals or groups for task fulfillment through
/// stepwise work submission, acceptance, and payment
/// @author Mark Beylin <<span class="__cf_email__" data-cfemail="96fbf7e4fdb8f4f3effafff8d6f5f9f8e5f3f8e5efe5b8f8f3e2">[email protected]</span>&gt;, Gonçalo Sá &lt;<span class="__cf_email__" data-cfemail="d6b1b9b8b5b7bab9f8a5b796b5b9b8a5b3b8a5afa5f8b8b3a2">[email protected]</span>&gt;&#13;
contract StandardBounties {&#13;
&#13;
  /*&#13;
   * Events&#13;
   */&#13;
  event BountyIssued(uint bountyId);&#13;
  event BountyActivated(uint bountyId, address issuer);&#13;
  event BountyFulfilled(uint bountyId, address indexed fulfiller, uint256 indexed _fulfillmentId);&#13;
  event FulfillmentUpdated(uint _bountyId, uint _fulfillmentId);&#13;
  event FulfillmentAccepted(uint bountyId, address indexed fulfiller, uint256 indexed _fulfillmentId);&#13;
  event BountyKilled(uint bountyId, address indexed issuer);&#13;
  event ContributionAdded(uint bountyId, address indexed contributor, uint256 value);&#13;
  event DeadlineExtended(uint bountyId, uint newDeadline);&#13;
  event BountyChanged(uint bountyId);&#13;
  event IssuerTransferred(uint _bountyId, address indexed _newIssuer);&#13;
  event PayoutIncreased(uint _bountyId, uint _newFulfillmentAmount);&#13;
&#13;
&#13;
  /*&#13;
   * Storage&#13;
   */&#13;
&#13;
  address public owner;&#13;
&#13;
  Bounty[] public bounties;&#13;
&#13;
  mapping(uint=&gt;Fulfillment[]) fulfillments;&#13;
  mapping(uint=&gt;uint) numAccepted;&#13;
  mapping(uint=&gt;HumanStandardToken) tokenContracts;&#13;
&#13;
  /*&#13;
   * Enums&#13;
   */&#13;
&#13;
  enum BountyStages {&#13;
      Draft,&#13;
      Active,&#13;
      Dead&#13;
  }&#13;
&#13;
  /*&#13;
   * Structs&#13;
   */&#13;
&#13;
  struct Bounty {&#13;
      address issuer;&#13;
      uint deadline;&#13;
      string data;&#13;
      uint fulfillmentAmount;&#13;
      address arbiter;&#13;
      bool paysTokens;&#13;
      BountyStages bountyStage;&#13;
      uint balance;&#13;
  }&#13;
&#13;
  struct Fulfillment {&#13;
      bool accepted;&#13;
      address fulfiller;&#13;
      string data;&#13;
  }&#13;
&#13;
  /*&#13;
   * Modifiers&#13;
   */&#13;
&#13;
  modifier validateNotTooManyBounties(){&#13;
    require((bounties.length + 1) &gt; bounties.length);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier validateNotTooManyFulfillments(uint _bountyId){&#13;
    require((fulfillments[_bountyId].length + 1) &gt; fulfillments[_bountyId].length);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier validateBountyArrayIndex(uint _bountyId){&#13;
    require(_bountyId &lt; bounties.length);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier onlyIssuer(uint _bountyId) {&#13;
      require(msg.sender == bounties[_bountyId].issuer);&#13;
      _;&#13;
  }&#13;
&#13;
  modifier onlyFulfiller(uint _bountyId, uint _fulfillmentId) {&#13;
      require(msg.sender == fulfillments[_bountyId][_fulfillmentId].fulfiller);&#13;
      _;&#13;
  }&#13;
&#13;
  modifier amountIsNotZero(uint _amount) {&#13;
      require(_amount != 0);&#13;
      _;&#13;
  }&#13;
&#13;
  modifier transferredAmountEqualsValue(uint _bountyId, uint _amount) {&#13;
      if (bounties[_bountyId].paysTokens){&#13;
        require(msg.value == 0);&#13;
        uint oldBalance = tokenContracts[_bountyId].balanceOf(this);&#13;
        if (_amount != 0){&#13;
          require(tokenContracts[_bountyId].transferFrom(msg.sender, this, _amount));&#13;
        }&#13;
        require((tokenContracts[_bountyId].balanceOf(this) - oldBalance) == _amount);&#13;
&#13;
      } else {&#13;
        require((_amount * 1 wei) == msg.value);&#13;
      }&#13;
      _;&#13;
  }&#13;
&#13;
  modifier isBeforeDeadline(uint _bountyId) {&#13;
      require(now &lt; bounties[_bountyId].deadline);&#13;
      _;&#13;
  }&#13;
&#13;
  modifier validateDeadline(uint _newDeadline) {&#13;
      require(_newDeadline &gt; now);&#13;
      _;&#13;
  }&#13;
&#13;
  modifier isAtStage(uint _bountyId, BountyStages _desiredStage) {&#13;
      require(bounties[_bountyId].bountyStage == _desiredStage);&#13;
      _;&#13;
  }&#13;
&#13;
  modifier validateFulfillmentArrayIndex(uint _bountyId, uint _index) {&#13;
      require(_index &lt; fulfillments[_bountyId].length);&#13;
      _;&#13;
  }&#13;
&#13;
  modifier notYetAccepted(uint _bountyId, uint _fulfillmentId){&#13;
      require(fulfillments[_bountyId][_fulfillmentId].accepted == false);&#13;
      _;&#13;
  }&#13;
&#13;
  /*&#13;
   * Public functions&#13;
   */&#13;
&#13;
&#13;
  /// @dev StandardBounties(): instantiates&#13;
  /// @param _owner the issuer of the standardbounties contract, who has the&#13;
  /// ability to remove bounties&#13;
  function StandardBounties(address _owner)&#13;
      public&#13;
  {&#13;
      owner = _owner;&#13;
  }&#13;
&#13;
  /// @dev issueBounty(): instantiates a new draft bounty&#13;
  /// @param _issuer the address of the intended issuer of the bounty&#13;
  /// @param _deadline the unix timestamp after which fulfillments will no longer be accepted&#13;
  /// @param _data the requirements of the bounty&#13;
  /// @param _fulfillmentAmount the amount of wei to be paid out for each successful fulfillment&#13;
  /// @param _arbiter the address of the arbiter who can mediate claims&#13;
  /// @param _paysTokens whether the bounty pays in tokens or in ETH&#13;
  /// @param _tokenContract the address of the contract if _paysTokens is true&#13;
  function issueBounty(&#13;
      address _issuer,&#13;
      uint _deadline,&#13;
      string _data,&#13;
      uint256 _fulfillmentAmount,&#13;
      address _arbiter,&#13;
      bool _paysTokens,&#13;
      address _tokenContract&#13;
  )&#13;
      public&#13;
      validateDeadline(_deadline)&#13;
      amountIsNotZero(_fulfillmentAmount)&#13;
      validateNotTooManyBounties&#13;
      returns (uint)&#13;
  {&#13;
      bounties.push(Bounty(_issuer, _deadline, _data, _fulfillmentAmount, _arbiter, _paysTokens, BountyStages.Draft, 0));&#13;
      if (_paysTokens){&#13;
        tokenContracts[bounties.length - 1] = HumanStandardToken(_tokenContract);&#13;
      }&#13;
      BountyIssued(bounties.length - 1);&#13;
      return (bounties.length - 1);&#13;
  }&#13;
&#13;
  /// @dev issueAndActivateBounty(): instantiates a new draft bounty&#13;
  /// @param _issuer the address of the intended issuer of the bounty&#13;
  /// @param _deadline the unix timestamp after which fulfillments will no longer be accepted&#13;
  /// @param _data the requirements of the bounty&#13;
  /// @param _fulfillmentAmount the amount of wei to be paid out for each successful fulfillment&#13;
  /// @param _arbiter the address of the arbiter who can mediate claims&#13;
  /// @param _paysTokens whether the bounty pays in tokens or in ETH&#13;
  /// @param _tokenContract the address of the contract if _paysTokens is true&#13;
  /// @param _value the total number of tokens being deposited upon activation&#13;
  function issueAndActivateBounty(&#13;
      address _issuer,&#13;
      uint _deadline,&#13;
      string _data,&#13;
      uint256 _fulfillmentAmount,&#13;
      address _arbiter,&#13;
      bool _paysTokens,&#13;
      address _tokenContract,&#13;
      uint256 _value&#13;
  )&#13;
      public&#13;
      payable&#13;
      validateDeadline(_deadline)&#13;
      amountIsNotZero(_fulfillmentAmount)&#13;
      validateNotTooManyBounties&#13;
      returns (uint)&#13;
  {&#13;
      require (_value &gt;= _fulfillmentAmount);&#13;
      if (_paysTokens){&#13;
        require(msg.value == 0);&#13;
        tokenContracts[bounties.length] = HumanStandardToken(_tokenContract);&#13;
        require(tokenContracts[bounties.length].transferFrom(msg.sender, this, _value));&#13;
      } else {&#13;
        require((_value * 1 wei) == msg.value);&#13;
      }&#13;
      bounties.push(Bounty(_issuer,&#13;
                            _deadline,&#13;
                            _data,&#13;
                            _fulfillmentAmount,&#13;
                            _arbiter,&#13;
                            _paysTokens,&#13;
                            BountyStages.Active,&#13;
                            _value));&#13;
      BountyIssued(bounties.length - 1);&#13;
      ContributionAdded(bounties.length - 1, msg.sender, _value);&#13;
      BountyActivated(bounties.length - 1, msg.sender);&#13;
      return (bounties.length - 1);&#13;
  }&#13;
&#13;
  modifier isNotDead(uint _bountyId) {&#13;
      require(bounties[_bountyId].bountyStage != BountyStages.Dead);&#13;
      _;&#13;
  }&#13;
&#13;
  /// @dev contribute(): a function allowing anyone to contribute tokens to a&#13;
  /// bounty, as long as it is still before its deadline. Shouldn't keep&#13;
  /// them by accident (hence 'value').&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _value the amount being contributed in ether to prevent accidental deposits&#13;
  /// @notice Please note you funds will be at the mercy of the issuer&#13;
  ///  and can be drained at any moment. Be careful!&#13;
  function contribute (uint _bountyId, uint _value)&#13;
      payable&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      isBeforeDeadline(_bountyId)&#13;
      isNotDead(_bountyId)&#13;
      amountIsNotZero(_value)&#13;
      transferredAmountEqualsValue(_bountyId, _value)&#13;
  {&#13;
      bounties[_bountyId].balance += _value;&#13;
&#13;
      ContributionAdded(_bountyId, msg.sender, _value);&#13;
  }&#13;
&#13;
  /// @notice Send funds to activate the bug bounty&#13;
  /// @dev activateBounty(): activate a bounty so it may pay out&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _value the amount being contributed in ether to prevent&#13;
  /// accidental deposits&#13;
  function activateBounty(uint _bountyId, uint _value)&#13;
      payable&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      isBeforeDeadline(_bountyId)&#13;
      onlyIssuer(_bountyId)&#13;
      transferredAmountEqualsValue(_bountyId, _value)&#13;
  {&#13;
      bounties[_bountyId].balance += _value;&#13;
      require (bounties[_bountyId].balance &gt;= bounties[_bountyId].fulfillmentAmount);&#13;
      transitionToState(_bountyId, BountyStages.Active);&#13;
&#13;
      ContributionAdded(_bountyId, msg.sender, _value);&#13;
      BountyActivated(_bountyId, msg.sender);&#13;
  }&#13;
&#13;
  modifier notIssuerOrArbiter(uint _bountyId) {&#13;
      require(msg.sender != bounties[_bountyId].issuer &amp;&amp; msg.sender != bounties[_bountyId].arbiter);&#13;
      _;&#13;
  }&#13;
&#13;
  /// @dev fulfillBounty(): submit a fulfillment for the given bounty&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _data the data artifacts representing the fulfillment of the bounty&#13;
  function fulfillBounty(uint _bountyId, string _data)&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      validateNotTooManyFulfillments(_bountyId)&#13;
      isAtStage(_bountyId, BountyStages.Active)&#13;
      isBeforeDeadline(_bountyId)&#13;
      notIssuerOrArbiter(_bountyId)&#13;
  {&#13;
      fulfillments[_bountyId].push(Fulfillment(false, msg.sender, _data));&#13;
&#13;
      BountyFulfilled(_bountyId, msg.sender, (fulfillments[_bountyId].length - 1));&#13;
  }&#13;
&#13;
  /// @dev updateFulfillment(): Submit updated data for a given fulfillment&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _fulfillmentId the index of the fulfillment&#13;
  /// @param _data the new data being submitted&#13;
  function updateFulfillment(uint _bountyId, uint _fulfillmentId, string _data)&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      validateFulfillmentArrayIndex(_bountyId, _fulfillmentId)&#13;
      onlyFulfiller(_bountyId, _fulfillmentId)&#13;
      notYetAccepted(_bountyId, _fulfillmentId)&#13;
  {&#13;
      fulfillments[_bountyId][_fulfillmentId].data = _data;&#13;
      FulfillmentUpdated(_bountyId, _fulfillmentId);&#13;
  }&#13;
&#13;
  modifier onlyIssuerOrArbiter(uint _bountyId) {&#13;
      require(msg.sender == bounties[_bountyId].issuer ||&#13;
         (msg.sender == bounties[_bountyId].arbiter &amp;&amp; bounties[_bountyId].arbiter != address(0)));&#13;
      _;&#13;
  }&#13;
&#13;
  modifier fulfillmentNotYetAccepted(uint _bountyId, uint _fulfillmentId) {&#13;
      require(fulfillments[_bountyId][_fulfillmentId].accepted == false);&#13;
      _;&#13;
  }&#13;
&#13;
  modifier enoughFundsToPay(uint _bountyId) {&#13;
      require(bounties[_bountyId].balance &gt;= bounties[_bountyId].fulfillmentAmount);&#13;
      _;&#13;
  }&#13;
&#13;
  /// @dev acceptFulfillment(): accept a given fulfillment&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _fulfillmentId the index of the fulfillment being accepted&#13;
  function acceptFulfillment(uint _bountyId, uint _fulfillmentId)&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      validateFulfillmentArrayIndex(_bountyId, _fulfillmentId)&#13;
      onlyIssuerOrArbiter(_bountyId)&#13;
      isAtStage(_bountyId, BountyStages.Active)&#13;
      fulfillmentNotYetAccepted(_bountyId, _fulfillmentId)&#13;
      enoughFundsToPay(_bountyId)&#13;
  {&#13;
      fulfillments[_bountyId][_fulfillmentId].accepted = true;&#13;
      numAccepted[_bountyId]++;&#13;
      bounties[_bountyId].balance -= bounties[_bountyId].fulfillmentAmount;&#13;
      if (bounties[_bountyId].paysTokens){&#13;
        require(tokenContracts[_bountyId].transfer(fulfillments[_bountyId][_fulfillmentId].fulfiller, bounties[_bountyId].fulfillmentAmount));&#13;
      } else {&#13;
        fulfillments[_bountyId][_fulfillmentId].fulfiller.transfer(bounties[_bountyId].fulfillmentAmount);&#13;
      }&#13;
      FulfillmentAccepted(_bountyId, msg.sender, _fulfillmentId);&#13;
  }&#13;
&#13;
  /// @dev killBounty(): drains the contract of it's remaining&#13;
  /// funds, and moves the bounty into stage 3 (dead) since it was&#13;
  /// either killed in draft stage, or never accepted any fulfillments&#13;
  /// @param _bountyId the index of the bounty&#13;
  function killBounty(uint _bountyId)&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      onlyIssuer(_bountyId)&#13;
  {&#13;
      transitionToState(_bountyId, BountyStages.Dead);&#13;
      uint oldBalance = bounties[_bountyId].balance;&#13;
      bounties[_bountyId].balance = 0;&#13;
      if (oldBalance &gt; 0){&#13;
        if (bounties[_bountyId].paysTokens){&#13;
          require(tokenContracts[_bountyId].transfer(bounties[_bountyId].issuer, oldBalance));&#13;
        } else {&#13;
          bounties[_bountyId].issuer.transfer(oldBalance);&#13;
        }&#13;
      }&#13;
      BountyKilled(_bountyId, msg.sender);&#13;
  }&#13;
&#13;
  modifier newDeadlineIsValid(uint _bountyId, uint _newDeadline) {&#13;
      require(_newDeadline &gt; bounties[_bountyId].deadline);&#13;
      _;&#13;
  }&#13;
&#13;
  /// @dev extendDeadline(): allows the issuer to add more time to the&#13;
  /// bounty, allowing it to continue accepting fulfillments&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _newDeadline the new deadline in timestamp format&#13;
  function extendDeadline(uint _bountyId, uint _newDeadline)&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      onlyIssuer(_bountyId)&#13;
      newDeadlineIsValid(_bountyId, _newDeadline)&#13;
  {&#13;
      bounties[_bountyId].deadline = _newDeadline;&#13;
&#13;
      DeadlineExtended(_bountyId, _newDeadline);&#13;
  }&#13;
&#13;
  /// @dev transferIssuer(): allows the issuer to transfer ownership of the&#13;
  /// bounty to some new address&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _newIssuer the address of the new issuer&#13;
  function transferIssuer(uint _bountyId, address _newIssuer)&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      onlyIssuer(_bountyId)&#13;
  {&#13;
      bounties[_bountyId].issuer = _newIssuer;&#13;
      IssuerTransferred(_bountyId, _newIssuer);&#13;
  }&#13;
&#13;
&#13;
  /// @dev changeBountyDeadline(): allows the issuer to change a bounty's deadline&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _newDeadline the new deadline for the bounty&#13;
  function changeBountyDeadline(uint _bountyId, uint _newDeadline)&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      onlyIssuer(_bountyId)&#13;
      validateDeadline(_newDeadline)&#13;
      isAtStage(_bountyId, BountyStages.Draft)&#13;
  {&#13;
      bounties[_bountyId].deadline = _newDeadline;&#13;
      BountyChanged(_bountyId);&#13;
  }&#13;
&#13;
  /// @dev changeData(): allows the issuer to change a bounty's data&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _newData the new requirements of the bounty&#13;
  function changeBountyData(uint _bountyId, string _newData)&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      onlyIssuer(_bountyId)&#13;
      isAtStage(_bountyId, BountyStages.Draft)&#13;
  {&#13;
      bounties[_bountyId].data = _newData;&#13;
      BountyChanged(_bountyId);&#13;
  }&#13;
&#13;
  /// @dev changeBountyfulfillmentAmount(): allows the issuer to change a bounty's fulfillment amount&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _newFulfillmentAmount the new fulfillment amount&#13;
  function changeBountyFulfillmentAmount(uint _bountyId, uint _newFulfillmentAmount)&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      onlyIssuer(_bountyId)&#13;
      isAtStage(_bountyId, BountyStages.Draft)&#13;
  {&#13;
      bounties[_bountyId].fulfillmentAmount = _newFulfillmentAmount;&#13;
      BountyChanged(_bountyId);&#13;
  }&#13;
&#13;
  /// @dev changeBountyArbiter(): allows the issuer to change a bounty's arbiter&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _newArbiter the new address of the arbiter&#13;
  function changeBountyArbiter(uint _bountyId, address _newArbiter)&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      onlyIssuer(_bountyId)&#13;
      isAtStage(_bountyId, BountyStages.Draft)&#13;
  {&#13;
      bounties[_bountyId].arbiter = _newArbiter;&#13;
      BountyChanged(_bountyId);&#13;
  }&#13;
&#13;
  /// @dev changeBountyPaysTokens(): allows the issuer to change a bounty's issuer&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _newPaysTokens the new bool for whether the contract pays tokens&#13;
  /// @param _newTokenContract the new address of the token&#13;
  function changeBountyPaysTokens(uint _bountyId, bool _newPaysTokens, address _newTokenContract)&#13;
      public&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      onlyIssuer(_bountyId)&#13;
      isAtStage(_bountyId, BountyStages.Draft)&#13;
  {&#13;
      HumanStandardToken oldToken = tokenContracts[_bountyId];&#13;
      bool oldPaysTokens = bounties[_bountyId].paysTokens;&#13;
      bounties[_bountyId].paysTokens = _newPaysTokens;&#13;
      tokenContracts[_bountyId] = HumanStandardToken(_newTokenContract);&#13;
      if (bounties[_bountyId].balance &gt; 0){&#13;
        uint oldBalance = bounties[_bountyId].balance;&#13;
        bounties[_bountyId].balance = 0;&#13;
        if (oldPaysTokens){&#13;
            require(oldToken.transfer(bounties[_bountyId].issuer, oldBalance));&#13;
        } else {&#13;
            bounties[_bountyId].issuer.transfer(oldBalance);&#13;
        }&#13;
      }&#13;
      BountyChanged(_bountyId);&#13;
  }&#13;
&#13;
  modifier newFulfillmentAmountIsIncrease(uint _bountyId, uint _newFulfillmentAmount) {&#13;
      require(bounties[_bountyId].fulfillmentAmount &lt; _newFulfillmentAmount);&#13;
      _;&#13;
  }&#13;
&#13;
  /// @dev increasePayout(): allows the issuer to increase a given fulfillment&#13;
  /// amount in the active stage&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _newFulfillmentAmount the new fulfillment amount&#13;
  /// @param _value the value of the additional deposit being added&#13;
  function increasePayout(uint _bountyId, uint _newFulfillmentAmount, uint _value)&#13;
      public&#13;
      payable&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      onlyIssuer(_bountyId)&#13;
      newFulfillmentAmountIsIncrease(_bountyId, _newFulfillmentAmount)&#13;
      transferredAmountEqualsValue(_bountyId, _value)&#13;
  {&#13;
      bounties[_bountyId].balance += _value;&#13;
      require(bounties[_bountyId].balance &gt;= _newFulfillmentAmount);&#13;
      bounties[_bountyId].fulfillmentAmount = _newFulfillmentAmount;&#13;
      PayoutIncreased(_bountyId, _newFulfillmentAmount);&#13;
  }&#13;
&#13;
  /// @dev getFulfillment(): Returns the fulfillment at a given index&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _fulfillmentId the index of the fulfillment to return&#13;
  /// @return Returns a tuple for the fulfillment&#13;
  function getFulfillment(uint _bountyId, uint _fulfillmentId)&#13;
      public&#13;
      constant&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      validateFulfillmentArrayIndex(_bountyId, _fulfillmentId)&#13;
      returns (bool, address, string)&#13;
  {&#13;
      return (fulfillments[_bountyId][_fulfillmentId].accepted,&#13;
              fulfillments[_bountyId][_fulfillmentId].fulfiller,&#13;
              fulfillments[_bountyId][_fulfillmentId].data);&#13;
  }&#13;
&#13;
  /// @dev getBounty(): Returns the details of the bounty&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @return Returns a tuple for the bounty&#13;
  function getBounty(uint _bountyId)&#13;
      public&#13;
      constant&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      returns (address, uint, uint, bool, uint, uint)&#13;
  {&#13;
      return (bounties[_bountyId].issuer,&#13;
              bounties[_bountyId].deadline,&#13;
              bounties[_bountyId].fulfillmentAmount,&#13;
              bounties[_bountyId].paysTokens,&#13;
              uint(bounties[_bountyId].bountyStage),&#13;
              bounties[_bountyId].balance);&#13;
  }&#13;
&#13;
  /// @dev getBountyArbiter(): Returns the arbiter of the bounty&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @return Returns an address for the arbiter of the bounty&#13;
  function getBountyArbiter(uint _bountyId)&#13;
      public&#13;
      constant&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      returns (address)&#13;
  {&#13;
      return (bounties[_bountyId].arbiter);&#13;
  }&#13;
&#13;
  /// @dev getBountyData(): Returns the data of the bounty&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @return Returns a string for the bounty data&#13;
  function getBountyData(uint _bountyId)&#13;
      public&#13;
      constant&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      returns (string)&#13;
  {&#13;
      return (bounties[_bountyId].data);&#13;
  }&#13;
&#13;
  /// @dev getBountyToken(): Returns the token contract of the bounty&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @return Returns an address for the token that the bounty uses&#13;
  function getBountyToken(uint _bountyId)&#13;
      public&#13;
      constant&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      returns (address)&#13;
  {&#13;
      return (tokenContracts[_bountyId]);&#13;
  }&#13;
&#13;
  /// @dev getNumBounties() returns the number of bounties in the registry&#13;
  /// @return Returns the number of bounties&#13;
  function getNumBounties()&#13;
      public&#13;
      constant&#13;
      returns (uint)&#13;
  {&#13;
      return bounties.length;&#13;
  }&#13;
&#13;
  /// @dev getNumFulfillments() returns the number of fulfillments for a given milestone&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @return Returns the number of fulfillments&#13;
  function getNumFulfillments(uint _bountyId)&#13;
      public&#13;
      constant&#13;
      validateBountyArrayIndex(_bountyId)&#13;
      returns (uint)&#13;
  {&#13;
      return fulfillments[_bountyId].length;&#13;
  }&#13;
&#13;
  /*&#13;
   * Internal functions&#13;
   */&#13;
&#13;
  /// @dev transitionToState(): transitions the contract to the&#13;
  /// state passed in the parameter `_newStage` given the&#13;
  /// conditions stated in the body of the function&#13;
  /// @param _bountyId the index of the bounty&#13;
  /// @param _newStage the new stage to transition to&#13;
  function transitionToState(uint _bountyId, BountyStages _newStage)&#13;
      internal&#13;
  {&#13;
      bounties[_bountyId].bountyStage = _newStage;&#13;
  }&#13;
}