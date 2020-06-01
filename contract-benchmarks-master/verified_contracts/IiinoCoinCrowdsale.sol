pragma solidity ^0.4.20;

// File: contracts/Ownable.sol

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
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

// File: contracts/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transferInternal(address to, uint256 value) internal returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/SafeMath.sol

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
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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

// File: contracts/BasicToken.sol

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
    function transferInternal(address _to, uint256 _value) internal returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
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

// File: contracts/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowanceInternal(address owner, address spender) internal view returns (uint256);
    function transferFromInternal(address from, address to, uint256 value) internal returns (bool);
    function approveInternal(address spender, uint256 value) internal returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/StandardToken.sol

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
    function transferFromInternal(address _from, address _to, uint256 _value) internal returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
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
    function approveInternal(address _spender, uint256 _value) internal returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
    function allowanceInternal(address _owner, address _spender) internal view returns (uint256) {
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
    function increaseApprovalInternal(address _spender, uint _addedValue) internal returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
    function decreaseApprovalInternal(address _spender, uint _subtractedValue) internal returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

// File: contracts/MintableToken.sol

//import "./StandardToken.sol";
//import "../../ownership/Ownable.sol";



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
    address public icoContractAddress;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
    * @dev Throws if called by any account other than the icoContract.
    */
    modifier onlyIcoContract() {
        require(msg.sender == icoContractAddress);
        _;
    }
  

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) onlyIcoContract canMint external returns (bool) {
        //return true;
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner canMint external returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }

}

// File: contracts/Pausable.sol

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
    function pause() onlyOwner whenNotPaused external {
        paused = true;
        emit Pause();
    }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
    function unpause() onlyOwner whenPaused external {
        paused = false;
        emit Unpause();
    }
}

// File: contracts/PausableToken.sol

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

    function transferInternal(address _to, uint256 _value) internal whenNotPaused returns (bool) {
        return super.transferInternal(_to, _value);
    }

    function transferFromInternal(address _from, address _to, uint256 _value) internal whenNotPaused returns (bool) {
        return super.transferFromInternal(_from, _to, _value);
    }

    function approveInternal(address _spender, uint256 _value) internal whenNotPaused returns (bool) {
        return super.approveInternal(_spender, _value);
    }

    function increaseApprovalInternal(address _spender, uint _addedValue) internal whenNotPaused returns (bool success) {
        return super.increaseApprovalInternal(_spender, _addedValue);
    }

    function decreaseApprovalInternal(address _spender, uint _subtractedValue) internal whenNotPaused returns (bool success) {
        return super.decreaseApprovalInternal(_spender, _subtractedValue);
    }
}

// File: contracts/ReentrancyGuard.sol

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8cfee9e1efe3ccbe">[email protected]</a>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private reentrancy_lock = false;&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * @notice If you mark a function `nonReentrant`, you should also&#13;
   * mark it `external`. Calling one nonReentrant function from&#13;
   * another is not supported. Instead, you can implement a&#13;
   * `private` function doing the actual work, and a `external`&#13;
   * wrapper marked as `nonReentrant`.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    require(!reentrancy_lock);&#13;
    reentrancy_lock = true;&#13;
    _;&#13;
    reentrancy_lock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts/IiinoCoin.sol&#13;
&#13;
contract IiinoCoin is MintableToken, PausableToken, ReentrancyGuard {&#13;
    event RewardMint(address indexed to, uint256 amount);&#13;
    event RewardMintingAmt(uint256 _amountOfTokensMintedPreCycle);&#13;
    event ResetReward();&#13;
    event RedeemReward(address indexed to, uint256 value);&#13;
&#13;
    event CreatedEscrow(bytes32 _tradeHash);&#13;
    event ReleasedEscrow(bytes32 _tradeHash);&#13;
    event Dispute(bytes32 _tradeHash);&#13;
    event CancelledBySeller(bytes32 _tradeHash);&#13;
    event CancelledByBuyer(bytes32 _tradeHash);&#13;
    event BuyerArbitratorSet(bytes32 _tradeHash);&#13;
    event SellerArbitratorSet(bytes32 _tradeHash);&#13;
    event DisputeResolved (bytes32 _tradeHash);&#13;
    event IcoContractAddressSet (address _icoContractAddress);&#13;
    &#13;
    using SafeMath for uint256;&#13;
    &#13;
    // Mapping of rewards to beneficiaries of the reward&#13;
    mapping(address =&gt; uint256) public reward;&#13;
  &#13;
    string public name;&#13;
    string public symbol;&#13;
    uint8 public decimals;&#13;
&#13;
    uint256 public amountMintPerDuration; // amount to mint during one minting cycle&#13;
    uint256 public durationBetweenRewardMints; // reward miniting cycle duration&#13;
    uint256 public previousDistribution; //EPOCH time of the previous distribution&#13;
    uint256 public totalRewardsDistributed; //Total amount of the rewards distributed&#13;
    uint256 public totalRewardsRedeemed; //Total amount of the rewards redeemed&#13;
    uint256 public minimumRewardWithdrawalLimit; //The minimum limit of rewards that can be withdrawn&#13;
    uint256 public rewardAvailableCurrentDistribution; //The amount of rewards available for the current Distribution.&#13;
&#13;
    function IiinoCoin(&#13;
        string _name, &#13;
        string _symbol, &#13;
        uint8 _decimals, &#13;
        uint256 _amountMintPerDuration, &#13;
        uint256 _durationBetweenRewardMints &#13;
    ) public {&#13;
        name = _name;&#13;
        symbol = _symbol;&#13;
        decimals = _decimals;&#13;
&#13;
        amountMintPerDuration = _amountMintPerDuration;&#13;
        durationBetweenRewardMints = _durationBetweenRewardMints;&#13;
        previousDistribution = now; // To initialize the previous distribution to the time of the creation of the contract&#13;
        totalRewardsDistributed = 0;&#13;
        totalRewardsRedeemed = 0;&#13;
        minimumRewardWithdrawalLimit = 10 ether; //Defaulted to 10 iiinos represented in iii&#13;
        rewardAvailableCurrentDistribution = amountMintPerDuration;&#13;
        icoContractAddress = msg.sender; &#13;
    }&#13;
    &#13;
    /**&#13;
    * @dev set the icoContractAddress in the token so that the ico Contract can mint the token&#13;
    * @param _icoContractAddress array of address. The address to which the reward needs to be distributed&#13;
    */&#13;
    function setIcoContractAddress(&#13;
        address _icoContractAddress&#13;
    ) external nonReentrant onlyOwner whenNotPaused {&#13;
        require (_icoContractAddress != address(0));&#13;
        emit IcoContractAddressSet(_icoContractAddress);&#13;
        icoContractAddress = _icoContractAddress;    &#13;
    }&#13;
&#13;
    /**&#13;
    * @dev distribute reward tokens to the list of addresses based on their proportion&#13;
    * @param _rewardAdresses array of address. The address to which the reward needs to be distributed&#13;
    */&#13;
    function batchDistributeReward(&#13;
        address[] _rewardAdresses,&#13;
        uint256[] _amountOfReward, &#13;
        uint256 _timestampOfDistribution&#13;
    ) external nonReentrant onlyOwner whenNotPaused {&#13;
        require(_timestampOfDistribution &gt; previousDistribution.add(durationBetweenRewardMints)); //To only allow a distribution to happen 30 days (2592000 seconds) after the previous distribution&#13;
        require(_timestampOfDistribution &lt; now); // To only allow a distribution time in the past&#13;
        require(_rewardAdresses.length == _amountOfReward.length); // To verify the length of the arrays are the same.&#13;
        &#13;
        uint256 rewardDistributed = 0;&#13;
&#13;
        for (uint j = 0; j &lt; _rewardAdresses.length; j++) {&#13;
            rewardMint(_rewardAdresses[j], _amountOfReward[j]);&#13;
            rewardDistributed = rewardDistributed.add(_amountOfReward[j]);&#13;
        }&#13;
        require(rewardAvailableCurrentDistribution &gt;= rewardDistributed);&#13;
        totalRewardsDistributed = totalRewardsDistributed.add(rewardDistributed);&#13;
        rewardAvailableCurrentDistribution = rewardAvailableCurrentDistribution.sub(rewardDistributed);&#13;
    }&#13;
    &#13;
    /**&#13;
    * @dev distribute reward tokens to a addresse based on the proportion&#13;
    * @param _rewardAddress The address to which the reward needs to be distributed&#13;
    */&#13;
    function distributeReward(&#13;
        address _rewardAddress, &#13;
        uint256 _amountOfReward, &#13;
        uint256 _timestampOfDistribution&#13;
    ) external nonReentrant onlyOwner whenNotPaused {&#13;
        &#13;
        require(_timestampOfDistribution &gt; previousDistribution);&#13;
        require(_timestampOfDistribution &lt; previousDistribution.add(durationBetweenRewardMints)); //To only allow a distribution to happen 30 days (2592000 seconds) after the previous distribution&#13;
        require(_timestampOfDistribution &lt; now); // To only allow a distribution time in the past&#13;
        //reward[_rewardAddress] = reward[_rewardAddress].add(_amountOfReward);&#13;
        rewardMint(_rewardAddress, _amountOfReward);&#13;
        &#13;
    }&#13;
&#13;
    /**&#13;
    * @dev reset reward tokensfor the new duration&#13;
    */&#13;
    function resetReward() external nonReentrant onlyOwner whenNotPaused {&#13;
        require(now &gt; previousDistribution.add(durationBetweenRewardMints)); //To only allow a distribution to happen 30 days (2592000 seconds) after the previous distribution&#13;
        previousDistribution = previousDistribution.add(durationBetweenRewardMints); // To set the new distribution period as the previous distribution timestamp&#13;
        rewardAvailableCurrentDistribution = amountMintPerDuration;&#13;
        emit ResetReward();&#13;
    }&#13;
&#13;
    /**&#13;
   * @dev Redeem Reward tokens from one rewards array to balances array&#13;
   * @param _beneficiary address The address which contains the reward as well as the address to which the balance will be transferred&#13;
   * @param _value uint256 the amount of tokens to be redeemed&#13;
   */&#13;
    function redeemReward(&#13;
        address _beneficiary, &#13;
        uint256 _value&#13;
    ) external nonReentrant whenNotPaused{&#13;
        //Need to consider what happens to rewards after the stopping of minting process&#13;
        require(msg.sender == _beneficiary);&#13;
        require(_value &gt;= minimumRewardWithdrawalLimit);&#13;
        require(reward[_beneficiary] &gt;= _value);&#13;
        reward[_beneficiary] = reward[_beneficiary].sub(_value);&#13;
        balances[_beneficiary] = balances[_beneficiary].add(_value);&#13;
        totalRewardsRedeemed = totalRewardsRedeemed.add(_value);&#13;
        emit RedeemReward(_beneficiary, _value);&#13;
    }&#13;
&#13;
    function rewardMint(&#13;
        address _to, &#13;
        uint256 _amount&#13;
    ) onlyOwner canMint whenNotPaused internal returns (bool) {&#13;
        require(_amount &gt; 0);&#13;
        require(_to != address(0));&#13;
        require(rewardAvailableCurrentDistribution &gt;= _amount);&#13;
        totalSupply_ = totalSupply_.add(_amount);&#13;
        reward[_to] = reward[_to].add(_amount);&#13;
        totalRewardsDistributed = totalRewardsDistributed.add(_amount);&#13;
        rewardAvailableCurrentDistribution = rewardAvailableCurrentDistribution.sub(_amount);&#13;
        emit RewardMint(_to, _amount);&#13;
        //Transfer(address(0), _to, _amount); //balance of the user will only be updated on claiming the coin&#13;
        return true;&#13;
    }&#13;
    function userRewardAccountBalance(&#13;
        address _address&#13;
    ) whenNotPaused external view returns (uint256) {&#13;
        require(_address != address(0));&#13;
        return reward[_address];&#13;
    }&#13;
    function changeRewardMintingAmount(&#13;
        uint256 _newRewardMintAmt&#13;
    ) whenNotPaused nonReentrant onlyOwner external {&#13;
        require(_newRewardMintAmt &lt; amountMintPerDuration);&#13;
        amountMintPerDuration = _newRewardMintAmt;&#13;
        emit RewardMintingAmt(_newRewardMintAmt);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) external nonReentrant returns (bool) {&#13;
        return transferFromInternal(_from, _to, _value);&#13;
    }&#13;
    function approve(address _spender, uint256 _value) external nonReentrant returns (bool) {&#13;
        return approveInternal(_spender, _value);&#13;
    }&#13;
    function allowance(address _owner, address _spender) external view returns (uint256) {&#13;
        return allowanceInternal(_owner, _spender);&#13;
    }&#13;
    function increaseApproval(address _spender, uint _addedValue) external nonReentrant returns (bool) {&#13;
        return increaseApprovalInternal(_spender, _addedValue);&#13;
    }&#13;
    function decreaseApproval(address _spender, uint _subtractedValue) external nonReentrant returns (bool) {&#13;
        return decreaseApprovalInternal(_spender, _subtractedValue);&#13;
    }&#13;
    function transfer(address _to, uint256 _value) external nonReentrant returns (bool) {&#13;
        return transferInternal(_to, _value);&#13;
    } &#13;
}&#13;
&#13;
// File: contracts/Crowdsale.sol&#13;
&#13;
/**&#13;
 * @title Crowdsale&#13;
 * @dev Crowdsale is a base contract for managing a token crowdsale.&#13;
 * Crowdsales have a start and end timestamps, where investors can make&#13;
 * token purchases and the crowdsale will assign them tokens based&#13;
 * on a token per ETH rate. Funds collected are forwarded to a wallet&#13;
 * as they arrive.&#13;
 */&#13;
contract Crowdsale {&#13;
    using SafeMath for uint256;&#13;
    IiinoCoin public token;&#13;
    address public iiinoTokenAddress;&#13;
    uint256 public startTime;&#13;
    uint256 public endTime;&#13;
&#13;
  // address where funds are collected&#13;
    address public wallet;&#13;
&#13;
  // how many token units a buyer gets per wei&#13;
    uint256 public rate;&#13;
&#13;
  // amount of raised money in wei&#13;
    uint256 public weiRaised;&#13;
&#13;
  /**&#13;
   * event for token purchase logging&#13;
   * @param purchaser who paid for the tokens&#13;
   * @param beneficiary who got the tokens&#13;
   * @param value weis paid for purchase&#13;
   * @param amount amount of tokens purchased&#13;
   */&#13;
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);&#13;
&#13;
&#13;
    function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {&#13;
        //require(_startTime &gt;= now);&#13;
        require(_endTime &gt;= _startTime);&#13;
        require(_rate &gt; 0);&#13;
        require(_wallet != address(0));&#13;
&#13;
        startTime = _startTime;&#13;
        endTime = _endTime;&#13;
        rate = _rate;&#13;
        wallet = _wallet;&#13;
    }&#13;
&#13;
    // fallback function can be used to buy tokens&#13;
    function () external payable {&#13;
        buyTokensInternal(msg.sender);&#13;
    }&#13;
&#13;
    function buyTokensInternal(address beneficiary) internal {&#13;
        require(beneficiary != address(0));&#13;
        require(validPurchase());&#13;
        require(msg.value &gt;= (0.01 ether));&#13;
&#13;
        uint256 weiAmount = msg.value;&#13;
        uint256 tokens = getTokenAmount(weiAmount);&#13;
        weiRaised = weiRaised.add(weiAmount);&#13;
        token.mint(beneficiary, tokens);&#13;
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);&#13;
        forwardFunds();&#13;
    }&#13;
&#13;
    // @return true if crowdsale event has ended&#13;
    function hasEnded() public view returns (bool) {&#13;
        return now &gt; endTime;&#13;
    }&#13;
&#13;
    function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {&#13;
        return weiAmount.mul(rate);&#13;
    }&#13;
&#13;
    // send ether to the fund collection wallet&#13;
    function forwardFunds() internal {&#13;
        wallet.transfer(msg.value);&#13;
    }&#13;
&#13;
    // @return true if the transaction can buy tokens&#13;
    function validPurchase() internal view returns (bool) {&#13;
        bool withinPeriod = now &gt;= startTime &amp;&amp; now &lt;= endTime;&#13;
        bool nonZeroPurchase = msg.value != 0;&#13;
        return withinPeriod &amp;&amp; nonZeroPurchase;&#13;
    }&#13;
&#13;
}&#13;
&#13;
// File: contracts/IiinoCoinCrowdsale.sol&#13;
&#13;
contract IiinoCoinCrowdsale is Crowdsale, Pausable, ReentrancyGuard {&#13;
    event ReferralAwarded(address indexed purchaser, address indexed referrer, uint256 iiinoPurchased, uint256 iiinoAwarded);&#13;
&#13;
    using SafeMath for uint256;&#13;
    &#13;
    address devWallet;&#13;
    uint256 noOfTokenAlocatedForDev;&#13;
    uint256 public noOfTokenAlocatedForSeedRound;&#13;
    uint256 public noOfTokenAlocatedForPresaleRound;&#13;
    uint256 public totalNoOfTokenAlocated;&#13;
    uint256 public noOfTokenAlocatedPerICOPhase; //The token allocation for each phase of the ICO&#13;
    uint256 public noOfICOPhases; //No. of ICO phases&#13;
    uint256 public seedRoundEndTime; // to be in seconds&#13;
    uint256 public thresholdEtherLimitForSeedRound; //minimum amount of wei needed to participate&#13;
    uint256 public moreTokenPerEtherForSeedRound; // the more amount of Iiinos given per ether during seed round&#13;
    uint256 public moreTokenPerEtherForPresaleRound; //the more amount of Iiinos given per ether during presale round&#13;
    &#13;
    uint256 public referralTokensAvailable; //To hold the value of the referral token limit.&#13;
    uint256 public referralPercent; //The percentage of referral to be awarded on each order with a referrer&#13;
    uint256 public referralTokensAllocated; // To hold the total number of token allocated to referrals&#13;
&#13;
    uint256 public presaleEndTime; // to be in seconds&#13;
    uint256 public issueRateDecDuringICO; //The number of iiino that needs to be decreased for every next phase of the ICO &#13;
    //uint256 public percentToMintPerDuration; //The percentage of Genesis ICO that will be minted every minting cycle&#13;
    //uint256 public durationBetweenRewardMints; //The length of a reward minting cycle&#13;
    &#13;
&#13;
    function IiinoCoinCrowdsale(&#13;
        uint256[] _params, // All the params that need to initialize the crowdsale as well as the iiino Token&#13;
        address _wallet, &#13;
        address _devTeamWallet,&#13;
        address _iiinoTokenAddress&#13;
    ) public Crowdsale(_params[0], _params[1], _params[4], _wallet) {&#13;
        devWallet = _devTeamWallet;&#13;
        issueRateDecDuringICO = _params[5];&#13;
        seedRoundEndTime = _params[2];&#13;
        presaleEndTime = _params[3];&#13;
          &#13;
        moreTokenPerEtherForSeedRound = _params[13];&#13;
        moreTokenPerEtherForPresaleRound = _params[14];&#13;
          &#13;
        referralTokensAvailable = _params[15];&#13;
        referralTokensAllocated = _params[15]; //Initially all the allocated tokens are available&#13;
        referralPercent = _params[16];&#13;
&#13;
        noOfTokenAlocatedForDev = _params[6];&#13;
        noOfTokenAlocatedForSeedRound = _params[7];&#13;
        noOfTokenAlocatedForPresaleRound = _params[8];&#13;
        totalNoOfTokenAlocated = _params[10];&#13;
        noOfTokenAlocatedPerICOPhase = _params[9];&#13;
        noOfICOPhases = _params[11];&#13;
        thresholdEtherLimitForSeedRound = _params[12];&#13;
&#13;
        //Neeed to test the total allocation with the sum of all allocations.&#13;
        //token.transferOwnership(msg.sender);&#13;
&#13;
        //token.mint(_devTeamWallet, noOfTokenAlocatedForDev);&#13;
        //iiinoTokenAddress = _iiinoTokenAddress;&#13;
        token = IiinoCoin(_iiinoTokenAddress);&#13;
    }&#13;
&#13;
    function initialTransferToDevTeam() nonReentrant onlyOwner whenNotPaused external {&#13;
        require(devWallet != address(0));&#13;
        //To assign the initial dev tokens to the dev wallet&#13;
        token.mint(devWallet, noOfTokenAlocatedForDev);&#13;
        //Sets the devTeamWallet to 0x00, to restrict future transfers&#13;
        devWallet = address(0);&#13;
    }&#13;
&#13;
    /*&#13;
    //Temp Function to retreive values&#13;
    function tempGetDataToCheck (uint indx, uint256 weiAmt) public view returns (uint256) {&#13;
      //string temp = "thresholdEtherLimitForSeedRound =&gt;" + thresholdEtherLimitForSeedRound + "Total Supply =&gt; " + token.totalSupply() + "noOfTokenAlocatedForSeedRound =&gt; " + noOfTokenAlocatedForSeedRound + "noOfTokenAlocatedForDev =&gt; " + noOfTokenAlocatedForDev + "rate =&gt; " + rate;&#13;
        if (indx == 0)&#13;
          return issueRateDecDuringICO;&#13;
        else if (indx == 1)&#13;
          return seedRoundEndTime;&#13;
        else if (indx == 2)&#13;
          return presaleEndTime;&#13;
        else if (indx == 3)&#13;
          return moreTokenPerEtherForSeedRound;&#13;
        else if (indx == 4)&#13;
          return moreTokenPerEtherForPresaleRound;&#13;
        else if (indx == 5)&#13;
          return noOfTokenAlocatedForDev;&#13;
        else if (indx == 6)&#13;
          return noOfTokenAlocatedForSeedRound;&#13;
        else if (indx == 61)&#13;
          return noOfTokenAlocatedForPresaleRound;&#13;
        else if (indx == 7)&#13;
          return totalNoOfTokenAlocated;&#13;
        else if (indx == 8)&#13;
          return noOfTokenAlocatedPerICOPhase;&#13;
        else if (indx == 9)&#13;
          return noOfICOPhases;&#13;
        else if (indx == 10)&#13;
          return thresholdEtherLimitForSeedRound;&#13;
        else if (indx == 11)&#13;
          return 0;//percentToMintPerDuration;&#13;
        else if (indx == 12)&#13;
        {&#13;
            uint currentRate;&#13;
            uint256 icoMultiplier;&#13;
            (currentRate, icoMultiplier) = getCurrentRateInternal();&#13;
            return currentRate;//durationBetweenRewardMints;&#13;
        }  &#13;
        else if (indx == 13)&#13;
          return token.totalSupply();&#13;
        else if (indx == 14)&#13;
          return getTokenAmount(weiAmt);&#13;
        else if (indx == 15)&#13;
          return now;&#13;
        else if (indx == 16)&#13;
          return startTime;&#13;
        else if (indx == 17)&#13;
          return endTime;&#13;
        &#13;
    }&#13;
    */&#13;
    function getTokenAmount (uint256 weiAmount) whenNotPaused internal view returns (uint256) {&#13;
        uint currRate;&#13;
        uint256 multiplierForICO;&#13;
        uint256 amountOfIiino = 0;&#13;
        uint256 referralsDistributed = referralTokensAllocated.sub(referralTokensAvailable);&#13;
        uint256 _totalSupply = (token.totalSupply()).sub(referralsDistributed);&#13;
        if (now &lt;= seedRoundEndTime) {&#13;
          &#13;
            require(weiAmount &gt;= thresholdEtherLimitForSeedRound);&#13;
            require(_totalSupply &lt; noOfTokenAlocatedForSeedRound.add(noOfTokenAlocatedForDev));&#13;
            (currRate, multiplierForICO) = getCurrentRateInternal();&#13;
            &#13;
            amountOfIiino = weiAmount.mul(currRate);&#13;
            &#13;
            //Only if there is enough available amount of iiino in the phase will it allocate it, else it will just revert the transaction and return the ether &#13;
            require (_totalSupply.add(amountOfIiino) &lt;= noOfTokenAlocatedForSeedRound.add(noOfTokenAlocatedForDev));&#13;
            return amountOfIiino;&#13;
&#13;
        } else if (now &lt;= presaleEndTime) {&#13;
            require(_totalSupply &lt; noOfTokenAlocatedForSeedRound.add(noOfTokenAlocatedForPresaleRound).add(noOfTokenAlocatedForDev));&#13;
            (currRate, multiplierForICO) = getCurrentRateInternal();&#13;
            &#13;
            amountOfIiino = weiAmount.mul(currRate);&#13;
            //Only if there is enough available amount of iiino in the phase will it allocate it, else it will just revert the transaction and return the ether &#13;
            require (_totalSupply.add(amountOfIiino) &lt;= noOfTokenAlocatedForSeedRound.add(noOfTokenAlocatedForPresaleRound).add(noOfTokenAlocatedForDev));&#13;
            return amountOfIiino;&#13;
        } else {&#13;
            &#13;
           &#13;
            require(_totalSupply &lt; noOfTokenAlocatedForSeedRound.add(noOfTokenAlocatedForPresaleRound).add(noOfTokenAlocatedForDev));&#13;
            require(now &lt; endTime);&#13;
            &#13;
            (currRate,multiplierForICO) = getCurrentRateInternal();&#13;
            //To check if the amount of tokens for the current ICO phase is exhausted&#13;
            //uint256 a = 1;&#13;
            //amountOfIiino = (weiAmount.mul(currRate)).div(a);&#13;
            &#13;
            amountOfIiino = weiAmount * currRate;&#13;
            &#13;
            require(_totalSupply.add(amountOfIiino) &lt;= noOfTokenAlocatedForSeedRound.add(noOfTokenAlocatedForPresaleRound).add(noOfTokenAlocatedForDev).add(noOfTokenAlocatedPerICOPhase.mul(multiplierForICO.add(1))));&#13;
            return amountOfIiino;&#13;
          &#13;
        }&#13;
      &#13;
    }&#13;
&#13;
  //function getCurrentRate returns the amount of iii for the amount of wei at the current point in time (now)&#13;
    function getCurrentRateInternal() whenNotPaused internal view returns (uint,uint256) {&#13;
        uint currRate;&#13;
        uint256 multiplierForICO = 0; &#13;
&#13;
        if (now &lt;= seedRoundEndTime) {&#13;
            currRate = rate.add(moreTokenPerEtherForSeedRound);&#13;
        } else if (now &lt;= presaleEndTime) {&#13;
            currRate = rate.add(moreTokenPerEtherForPresaleRound);&#13;
        } else {&#13;
            multiplierForICO = (now.sub(presaleEndTime)).div(30 days); //86400 seconds in a day&#13;
            currRate = rate.sub((issueRateDecDuringICO.mul(multiplierForICO)));&#13;
            require(multiplierForICO &lt; noOfICOPhases);&#13;
        }&#13;
        return (currRate,multiplierForICO);&#13;
    }&#13;
    &#13;
    function buyTokensWithReferrer(address referrer) nonReentrant whenNotPaused external payable {&#13;
        address beneficiary = msg.sender;&#13;
        require(referrer != address(0));&#13;
        require(beneficiary != address(0));&#13;
        require(validPurchase());&#13;
        require(msg.value &gt;= (0.01 ether));&#13;
&#13;
        uint256 weiAmount = msg.value;&#13;
&#13;
        // calculate token amount to be created&#13;
        uint256 tokens = getTokenAmount(weiAmount);&#13;
&#13;
        // update state&#13;
        weiRaised = weiRaised.add(weiAmount);&#13;
&#13;
        token.mint(beneficiary, tokens);&#13;
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);&#13;
&#13;
        //To send the referrer his percentage of tokens.&#13;
        uint256 referrerTokens = tokens.mul(referralPercent).div(100);&#13;
        if (referralTokensAvailable &gt; 0) {&#13;
            if (referrerTokens &gt; referralTokensAvailable) {&#13;
                referrerTokens = referralTokensAvailable;&#13;
            }&#13;
            &#13;
            token.mint(referrer, referrerTokens);&#13;
            referralTokensAvailable = referralTokensAvailable.sub(referrerTokens);&#13;
            emit ReferralAwarded(msg.sender, referrer, tokens, referrerTokens);&#13;
&#13;
        }&#13;
        &#13;
        forwardFunds();&#13;
&#13;
    }&#13;
&#13;
    function getCurrentRate() whenNotPaused external view returns (uint,uint256) {&#13;
        return getCurrentRateInternal ();&#13;
    }&#13;
&#13;
    function buyTokens(address beneficiary) nonReentrant whenNotPaused external payable {&#13;
        buyTokensInternal(beneficiary);&#13;
    }&#13;
&#13;
    function forwardFunds() whenNotPaused internal {&#13;
        super.forwardFunds();&#13;
    }&#13;
&#13;
}