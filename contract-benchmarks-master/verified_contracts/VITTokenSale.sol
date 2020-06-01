pragma solidity 0.4.18;

/**
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}


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
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}




/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}


/**
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="bcced9d1dfd3fc8e">[email protected]</span>π.com&gt;&#13;
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
&#13;
/**&#13;
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="fd8f98909e92bdcf">[email protected]</span>π.com&gt;&#13;
 * @dev This blocks incoming ERC23 tokens to prevent accidental loss of tokens.&#13;
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the&#13;
 * owner to reclaim the tokens.&#13;
 */&#13;
contract HasNoTokens is CanReclaimToken {&#13;
&#13;
 /**&#13;
  * @dev Reject all ERC23 compatible tokens&#13;
  * @param from_ address The address that is transferring the tokens&#13;
  * @param value_ uint256 the amount of the specified token&#13;
  * @param data_ Bytes The data passed from the caller.&#13;
  */&#13;
  function tokenFallback(address from_, uint256 value_, bytes data_) external {&#13;
    from_;&#13;
    value_;&#13;
    data_;&#13;
    revert();&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  uint256 public totalSupply;&#13;
  function balanceOf(address who) public view returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender) public view returns (uint256);&#13;
  function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances.&#13;
 */&#13;
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping(address =&gt; uint256) balances;&#13;
&#13;
  /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[msg.sender]);&#13;
&#13;
    // SafeMath.sub will throw if there is not enough balance.&#13;
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param _owner The address to query the the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
    return balances[_owner];&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 *&#13;
 * @dev Implementation of the basic standard token.&#13;
 * @dev https://github.com/ethereum/EIPs/issues/20&#13;
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
 */&#13;
contract StandardToken is ERC20, BasicToken {&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Transfer tokens from one address to another&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _to address The address which you want to transfer to&#13;
   * @param _value uint256 the amount of tokens to be transferred&#13;
   */&#13;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[_from]);&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    Transfer(_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
   *&#13;
   * Beware that changing an allowance with this method brings the risk that someone may use both the old&#13;
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this&#13;
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:&#13;
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _value The amount of tokens to be spent.&#13;
   */&#13;
  function approve(address _spender, uint256 _value) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = _value;&#13;
    Approval(msg.sender, _spender, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
   * @param _owner address The address which owns the funds.&#13;
   * @param _spender address The address which will spend the funds.&#13;
   * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
   */&#13;
  function allowance(address _owner, address _spender) public view returns (uint256) {&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
   *&#13;
   * approve should be called when allowed[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _addedValue The amount of tokens to increase the allowance by.&#13;
   */&#13;
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
   *&#13;
   * approve should be called when allowed[_spender] == 0. To decrement&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _subtractedValue The amount of tokens to decrease the allowance by.&#13;
   */&#13;
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {&#13;
    uint oldValue = allowed[msg.sender][_spender];&#13;
    if (_subtractedValue &gt; oldValue) {&#13;
      allowed[msg.sender][_spender] = 0;&#13;
    } else {&#13;
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
    }&#13;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Mintable token&#13;
 * @dev Simple ERC20 Token example, with mintable token creation&#13;
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120&#13;
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol&#13;
 */&#13;
&#13;
contract MintableToken is StandardToken, Ownable {&#13;
  event Mint(address indexed to, uint256 amount);&#13;
  event MintFinished();&#13;
&#13;
  bool public mintingFinished = false;&#13;
&#13;
&#13;
  modifier canMint() {&#13;
    require(!mintingFinished);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to mint tokens&#13;
   * @param _to The address that will receive the minted tokens.&#13;
   * @param _amount The amount of tokens to mint.&#13;
   * @return A boolean that indicates if the operation was successful.&#13;
   */&#13;
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {&#13;
    totalSupply = totalSupply.add(_amount);&#13;
    balances[_to] = balances[_to].add(_amount);&#13;
    Mint(_to, _amount);&#13;
    Transfer(address(0), _to, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to stop minting new tokens.&#13;
   * @return True if the operation was successful.&#13;
   */&#13;
  function finishMinting() onlyOwner canMint public returns (bool) {&#13;
    mintingFinished = true;&#13;
    MintFinished();&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title SafeERC20&#13;
 * @dev Wrappers around ERC20 operations that throw on failure.&#13;
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,&#13;
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.&#13;
 */&#13;
library SafeERC20 {&#13;
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {&#13;
    assert(token.transfer(to, value));&#13;
  }&#13;
&#13;
  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {&#13;
    assert(token.transferFrom(from, to, value));&#13;
  }&#13;
&#13;
  function safeApprove(ERC20 token, address spender, uint256 value) internal {&#13;
    assert(token.approve(spender, value));&#13;
  }&#13;
}&#13;
&#13;
&#13;
&#13;
contract VITToken is Claimable, HasNoTokens, MintableToken {&#13;
    // solhint-disable const-name-snakecase&#13;
    string public constant name = "Vice";&#13;
    string public constant symbol = "VIT";&#13;
    uint8 public constant decimals = 18;&#13;
    // solhint-enable const-name-snakecase&#13;
&#13;
    modifier cannotMint() {&#13;
        require(mintingFinished);&#13;
        _;&#13;
    }&#13;
&#13;
    function VITToken() public {&#13;
&#13;
    }&#13;
&#13;
    /// @dev Same ERC20 behavior, but reverts if still minting.&#13;
    /// @param _to address The address to transfer to.&#13;
    /// @param _value uint256 The amount to be transferred.&#13;
    function transfer(address _to, uint256 _value) public cannotMint returns (bool) {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    /// @dev Same ERC20 behavior, but reverts if still minting.&#13;
    /// @param _from address The address which you want to send tokens from.&#13;
    /// @param _to address The address which you want to transfer to.&#13;
    /// @param _value uint256 the amount of tokens to be transferred.&#13;
    function transferFrom(address _from, address _to, uint256 _value) public cannotMint returns (bool) {&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
/// @title VITToken sale contract.&#13;
contract VITTokenSale is Claimable {&#13;
    using Math for uint256;&#13;
    using SafeMath for uint256;&#13;
&#13;
    // VIT token contract.&#13;
    VITToken public vitToken;&#13;
&#13;
    // Received funds are forwarded to this address.&#13;
    address public fundingRecipient;&#13;
&#13;
    // VIT token unit.&#13;
    uint256 public constant TOKEN_UNIT = 10 ** 18;&#13;
&#13;
    // Maximum tokens offered in the sale: 2B.&#13;
    uint256 public constant MAX_TOKENS_SOLD = 2 * 10 ** 9 * TOKEN_UNIT;&#13;
&#13;
    // VIT to 1 wei ratio.&#13;
    uint256 public vitPerWei;&#13;
&#13;
    // Sale start and end timestamps.&#13;
    uint256 public constant RESTRICTED_PERIOD_DURATION = 1 days;&#13;
    uint256 public startTime;&#13;
    uint256 public endTime;&#13;
&#13;
    // Refund data and state.&#13;
    uint256 public refundEndTime;&#13;
    mapping (address =&gt; uint256) public refundableEther;&#13;
    mapping (address =&gt; uint256) public claimableTokens;&#13;
    uint256 public totalClaimableTokens = 0;&#13;
    bool public finalizedRefund = false;&#13;
&#13;
    // Amount of tokens sold until now in the sale.&#13;
    uint256 public tokensSold = 0;&#13;
&#13;
    // Accumulated amount each participant has contributed so far.&#13;
    mapping (address =&gt; uint256) public participationHistory;&#13;
&#13;
    // Maximum amount that each participant is allowed to contribute (in WEI), during the restricted period.&#13;
    mapping (address =&gt; uint256) public participationCaps;&#13;
&#13;
    // Initial allocations.&#13;
    address[20] public strategicPartnersPools;&#13;
    uint256 public constant STRATEGIC_PARTNERS_POOL_ALLOCATION = 100 * 10 ** 6 * TOKEN_UNIT; // 100M&#13;
&#13;
    event TokensIssued(address indexed to, uint256 tokens);&#13;
    event EtherRefunded(address indexed from, uint256 weiAmount);&#13;
    event TokensClaimed(address indexed from, uint256 tokens);&#13;
    event Finalized();&#13;
    event FinalizedRefunds();&#13;
&#13;
    /// @dev Reverts if called when not during sale.&#13;
    modifier onlyDuringSale() {&#13;
        require(!saleEnded() &amp;&amp; now &gt;= startTime);&#13;
&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev Reverts if called before the sale ends.&#13;
    modifier onlyAfterSale() {&#13;
        require(saleEnded());&#13;
&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev Reverts if called not doing the refund period.&#13;
    modifier onlyDuringRefund() {&#13;
        require(saleDuringRefundPeriod());&#13;
&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyAfterRefund() {&#13;
        require(saleAfterRefundPeriod());&#13;
&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev Constructor that initializes the sale conditions.&#13;
    /// @param _fundingRecipient address The address of the funding recipient.&#13;
    /// @param _startTime uint256 The start time of the token sale.&#13;
    /// @param _endTime uint256 The end time of the token sale.&#13;
    /// @param _refundEndTime uint256 The end time of the refunding period.&#13;
    /// @param _vitPerWei uint256 The exchange rate of VIT for one ETH.&#13;
    /// @param _strategicPartnersPools address[20] The addresses of the 20 strategic partners pools.&#13;
    function VITTokenSale(address _fundingRecipient, uint256 _startTime, uint256 _endTime, uint256 _refundEndTime,&#13;
        uint256 _vitPerWei, address[20] _strategicPartnersPools) public {&#13;
        require(_fundingRecipient != address(0));&#13;
        require(_startTime &gt; now &amp;&amp; _startTime &lt; _endTime &amp;&amp; _endTime &lt; _refundEndTime);&#13;
        require(_startTime.add(RESTRICTED_PERIOD_DURATION) &lt; _endTime);&#13;
        require(_vitPerWei &gt; 0);&#13;
&#13;
        for (uint i = 0; i &lt; _strategicPartnersPools.length; ++i) {&#13;
            require(_strategicPartnersPools[i] != address(0));&#13;
        }&#13;
&#13;
        fundingRecipient = _fundingRecipient;&#13;
        startTime = _startTime;&#13;
        endTime = _endTime;&#13;
        refundEndTime = _refundEndTime;&#13;
        vitPerWei = _vitPerWei;&#13;
        strategicPartnersPools = _strategicPartnersPools;&#13;
&#13;
        // Deploy new VITToken contract.&#13;
        vitToken = new VITToken();&#13;
&#13;
        // Grant initial token allocations.&#13;
        grantInitialAllocations();&#13;
    }&#13;
&#13;
    /// @dev Fallback function that will delegate the request to create().&#13;
    function () external payable onlyDuringSale {&#13;
        address recipient = msg.sender;&#13;
&#13;
        uint256 cappedWeiReceived = msg.value;&#13;
        uint256 weiAlreadyParticipated = participationHistory[recipient];&#13;
&#13;
        // If we're during the restricted period, then only the white-listed participants are allowed to participate,&#13;
        if (saleDuringRestrictedPeriod()) {&#13;
            uint256 participationCap = participationCaps[recipient];&#13;
            cappedWeiReceived = Math.min256(cappedWeiReceived, participationCap.sub(weiAlreadyParticipated));&#13;
        }&#13;
&#13;
        require(cappedWeiReceived &gt; 0);&#13;
&#13;
        // Calculate how much tokens can be sold to this participant.&#13;
        uint256 tokensLeftInSale = MAX_TOKENS_SOLD.sub(tokensSold);&#13;
        uint256 weiLeftInSale = tokensLeftInSale.div(vitPerWei);&#13;
        uint256 weiToParticipate = Math.min256(cappedWeiReceived, weiLeftInSale);&#13;
        participationHistory[recipient] = weiAlreadyParticipated.add(weiToParticipate);&#13;
&#13;
        // Issue tokens and transfer to recipient.&#13;
        uint256 tokensToIssue = weiToParticipate.mul(vitPerWei);&#13;
        if (tokensLeftInSale.sub(tokensToIssue) &lt; vitPerWei) {&#13;
            // If purchase would cause less than vitPerWei tokens left then nobody could ever buy them, so we'll gift&#13;
            // them to the last buyer.&#13;
            tokensToIssue = tokensLeftInSale;&#13;
        }&#13;
&#13;
        // Record the both the participate ETH and tokens for future refunds.&#13;
        refundableEther[recipient] = refundableEther[recipient].add(weiToParticipate);&#13;
        claimableTokens[recipient] = claimableTokens[recipient].add(tokensToIssue);&#13;
&#13;
        // Update token counters.&#13;
        totalClaimableTokens = totalClaimableTokens.add(tokensToIssue);&#13;
        tokensSold = tokensSold.add(tokensToIssue);&#13;
&#13;
        // Issue the tokens to the token sale smart contract itself, which will hold them for future refunds.&#13;
        issueTokens(address(this), tokensToIssue);&#13;
&#13;
        // Partial refund if full participation not possible, e.g. due to cap being reached.&#13;
        uint256 refund = msg.value.sub(weiToParticipate);&#13;
        if (refund &gt; 0) {&#13;
            msg.sender.transfer(refund);&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Set restricted period participation caps for a list of addresses.&#13;
    /// @param _participants address[] The list of participant addresses.&#13;
    /// @param _cap uint256 The cap amount (in ETH).&#13;
    function setRestrictedParticipationCap(address[] _participants, uint256 _cap) external onlyOwner {&#13;
        for (uint i = 0; i &lt; _participants.length; ++i) {&#13;
            participationCaps[_participants[i]] = _cap;&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Finalizes the token sale event, by stopping token minting.&#13;
    function finalize() external onlyAfterSale {&#13;
        // Issue any unsold tokens back to the company.&#13;
        if (tokensSold &lt; MAX_TOKENS_SOLD) {&#13;
            issueTokens(fundingRecipient, MAX_TOKENS_SOLD.sub(tokensSold));&#13;
        }&#13;
&#13;
        // Finish minting. Please note, that if minting was already finished - this call will revert().&#13;
        vitToken.finishMinting();&#13;
&#13;
        Finalized();&#13;
    }&#13;
&#13;
    function finalizeRefunds() external onlyAfterRefund {&#13;
        require(!finalizedRefund);&#13;
&#13;
        finalizedRefund = true;&#13;
&#13;
        // Transfer all the Ether to the beneficiary of the funding.&#13;
        fundingRecipient.transfer(this.balance);&#13;
&#13;
        FinalizedRefunds();&#13;
    }&#13;
&#13;
    /// @dev Reclaim all ERC20 compatible tokens, but not more than the VIT tokens which were reserved for refunds.&#13;
    /// @param token ERC20Basic The address of the token contract.&#13;
    function reclaimToken(ERC20Basic token) external onlyOwner {&#13;
        uint256 balance = token.balanceOf(this);&#13;
        if (token == vitToken) {&#13;
            balance = balance.sub(totalClaimableTokens);&#13;
        }&#13;
&#13;
        assert(token.transfer(owner, balance));&#13;
    }&#13;
&#13;
    /// @dev Allows participants to claim their tokens, which also transfers the Ether to the funding recipient.&#13;
    /// @param _tokensToClaim uint256 The amount of tokens to claim.&#13;
    function claimTokens(uint256 _tokensToClaim) public onlyAfterSale {&#13;
        require(_tokensToClaim != 0);&#13;
&#13;
        address participant = msg.sender;&#13;
        require(claimableTokens[participant] &gt; 0);&#13;
&#13;
        uint256 claimableTokensAmount = claimableTokens[participant];&#13;
        require(_tokensToClaim &lt;= claimableTokensAmount);&#13;
&#13;
        uint256 refundableEtherAmount = refundableEther[participant];&#13;
        uint256 etherToClaim = _tokensToClaim.mul(refundableEtherAmount).div(claimableTokensAmount);&#13;
        assert(etherToClaim &gt; 0);&#13;
&#13;
        refundableEther[participant] = refundableEtherAmount.sub(etherToClaim);&#13;
        claimableTokens[participant] = claimableTokensAmount.sub(_tokensToClaim);&#13;
        totalClaimableTokens = totalClaimableTokens.sub(_tokensToClaim);&#13;
&#13;
        // Transfer the tokens from the token sale smart contract to the participant.&#13;
        assert(vitToken.transfer(participant, _tokensToClaim));&#13;
&#13;
        // Transfer the Ether to the beneficiary of the funding (as long as the refund hasn't finalized yet).&#13;
        if (!finalizedRefund) {&#13;
            fundingRecipient.transfer(etherToClaim);&#13;
        }&#13;
&#13;
        TokensClaimed(participant, _tokensToClaim);&#13;
    }&#13;
&#13;
    /// @dev Allows participants to claim all their tokens.&#13;
    function claimAllTokens() public onlyAfterSale {&#13;
        uint256 claimableTokensAmount = claimableTokens[msg.sender];&#13;
        claimTokens(claimableTokensAmount);&#13;
    }&#13;
&#13;
    /// @dev Allows participants to claim refund for their purchased tokens.&#13;
    /// @param _etherToClaim uint256 The amount of Ether to claim.&#13;
    function refundEther(uint256 _etherToClaim) public onlyDuringRefund {&#13;
        require(_etherToClaim != 0);&#13;
&#13;
        address participant = msg.sender;&#13;
&#13;
        uint256 refundableEtherAmount = refundableEther[participant];&#13;
        require(_etherToClaim &lt;= refundableEtherAmount);&#13;
&#13;
        uint256 claimableTokensAmount = claimableTokens[participant];&#13;
        uint256 tokensToClaim = _etherToClaim.mul(claimableTokensAmount).div(refundableEtherAmount);&#13;
        assert(tokensToClaim &gt; 0);&#13;
&#13;
        refundableEther[participant] = refundableEtherAmount.sub(_etherToClaim);&#13;
        claimableTokens[participant] = claimableTokensAmount.sub(tokensToClaim);&#13;
        totalClaimableTokens = totalClaimableTokens.sub(tokensToClaim);&#13;
&#13;
        // Transfer the tokens to the beneficiary of the funding.&#13;
        assert(vitToken.transfer(fundingRecipient, tokensToClaim));&#13;
&#13;
        // Transfer the Ether to the participant.&#13;
        participant.transfer(_etherToClaim);&#13;
&#13;
        EtherRefunded(participant, _etherToClaim);&#13;
    }&#13;
&#13;
    /// @dev Allows participants to claim refund for all their purchased tokens.&#13;
    function refundAllEther() public onlyDuringRefund {&#13;
        uint256 refundableEtherAmount = refundableEther[msg.sender];&#13;
        refundEther(refundableEtherAmount);&#13;
    }&#13;
&#13;
    /// @dev Initialize token grants.&#13;
    function grantInitialAllocations() private onlyOwner {&#13;
        for (uint i = 0; i &lt; strategicPartnersPools.length; ++i) {&#13;
            issueTokens(strategicPartnersPools[i], STRATEGIC_PARTNERS_POOL_ALLOCATION);&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Issues tokens for the recipient.&#13;
    /// @param _recipient address The address of the recipient.&#13;
    /// @param _tokens uint256 The amount of tokens to issue.&#13;
    function issueTokens(address _recipient, uint256 _tokens) private {&#13;
        // Request VIT token contract to mint the requested tokens for the buyer.&#13;
        assert(vitToken.mint(_recipient, _tokens));&#13;
&#13;
        TokensIssued(_recipient, _tokens);&#13;
    }&#13;
&#13;
    /// @dev Returns whether the sale has ended.&#13;
    /// @return bool Whether the sale has ended or not.&#13;
    function saleEnded() private view returns (bool) {&#13;
        return tokensSold &gt;= MAX_TOKENS_SOLD || now &gt;= endTime;&#13;
    }&#13;
&#13;
    /// @dev Returns whether the sale is during its restricted period, where only white-listed participants are allowed&#13;
    /// to participate.&#13;
    /// @return bool Whether the sale is during its restricted period, where only white-listed participants are allowed&#13;
    /// to participate.&#13;
    function saleDuringRestrictedPeriod() private view returns (bool) {&#13;
        return now &lt;= startTime.add(RESTRICTED_PERIOD_DURATION);&#13;
    }&#13;
&#13;
    /// @dev Returns whether the sale is during its refund period.&#13;
    /// @return bool whether the sale is during its refund period.&#13;
    function saleDuringRefundPeriod() private view returns (bool) {&#13;
        return saleEnded() &amp;&amp; now &lt;= refundEndTime;&#13;
    }&#13;
&#13;
    /// @dev Returns whether the sale is during its refund period.&#13;
    /// @return bool whether the sale is during its refund period.&#13;
    function saleAfterRefundPeriod() private view returns (bool) {&#13;
        return saleEnded() &amp;&amp; now &gt; refundEndTime;&#13;
    }&#13;
}