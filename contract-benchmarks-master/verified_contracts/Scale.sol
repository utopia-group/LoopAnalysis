pragma solidity ^0.4.24;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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
  constructor() public {
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**************************************************************
 * @title Scale Token Contract
 * @file Scale.sol
 * @author Jared Downing and Kane Thomas of the Scale Network
 * @version 1.0
 *
 * @section DESCRIPTION
 *
 * This is an ERC20-based token with staking and inflationary functionality.
 *
 *************************************************************/

//////////////////////////////////
/// OpenZeppelin library imports
//////////////////////////////////

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
  function transfer(address _to, uint256 _value) public returns (bool) {
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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
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

  mapping (address => mapping (address => uint256)) internal allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
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
  function approve(address _spender, uint256 _value) public returns (bool) {
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
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
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
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
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 * Modified to allow minting for non-owner addresses
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) internal returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

}

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="14667179777b5426">[email protected]</a>π.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this ether.&#13;
 * @notice Ether can still be send to this contract by:&#13;
 * calling functions labeled `payable`&#13;
 * `selfdestruct(contract_address)`&#13;
 * mining directly to the contract address&#13;
*/&#13;
contract HasNoEther is Ownable {&#13;
&#13;
  /**&#13;
  * @dev Constructor that rejects incoming Ether&#13;
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we&#13;
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable&#13;
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively&#13;
  * we could use assembly to access msg.value.&#13;
  */&#13;
  constructor() public payable {&#13;
    require(msg.value == 0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Disallows direct send by settings a default function without the `payable` flag.&#13;
   */&#13;
  function() external {&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfer all Ether held by the contract to the owner.&#13;
   */&#13;
  function reclaimEther() external onlyOwner {&#13;
    assert(owner.send(address(this).balance));&#13;
  }&#13;
}&#13;
&#13;
//////////////////////////////////&#13;
/// Scale Token&#13;
//////////////////////////////////&#13;
&#13;
contract Scale is MintableToken, HasNoEther {&#13;
&#13;
    // Libraries&#13;
    using SafeMath for uint;&#13;
&#13;
    //////////////////////&#13;
    // Token Information&#13;
    //////////////////////&#13;
    string public constant name = "SCALE";&#13;
    string public constant symbol = "SCALE";&#13;
    uint8 public constant  decimals = 18;&#13;
&#13;
    ///////////////////////////////////////////////////////////&#13;
    // Variables For Staking and Pooling&#13;
    ///////////////////////////////////////////////////////////&#13;
&#13;
    // -- Pool Minting Rates and Percentages -- //&#13;
    // Pool for Scale distribution to rewards pool&#13;
    // Set to 0 to prohibit issuing to the pool before it is assigned&#13;
    address public pool = address(0);&#13;
&#13;
    // Pool and Owner minted tokens per second&#13;
    uint public poolMintRate;&#13;
    uint public ownerMintRate;&#13;
&#13;
    // Amount of Scale to be staked to the pool, staking, and mint, as calculated through their percentages&#13;
    uint public poolMintAmount;&#13;
    uint public stakingMintAmount;&#13;
    uint public ownerMintAmount;&#13;
&#13;
    // Scale distribution percentages&#13;
    uint public poolPercentage = 70;&#13;
    uint public ownerPercentage = 5;&#13;
    uint public stakingPercentage = 25;&#13;
&#13;
    // Last time minted for owner and pool&#13;
    uint public ownerTimeLastMinted;&#13;
    uint public poolTimeLastMinted;&#13;
&#13;
    // -- Staking -- //&#13;
    // Minted tokens per second&#13;
    uint public stakingMintRate;&#13;
&#13;
    // Total Scale currently staked&#13;
    uint public totalScaleStaked;&#13;
&#13;
    // Mapping of the timestamp =&gt; totalStaking that is created each time an address stakes or unstakes&#13;
    mapping (uint =&gt; uint) totalStakingHistory;&#13;
&#13;
    // Variable for staking accuracy. Set to 86400 for seconds in a day so that staking gains are based on the day an account begins staking.&#13;
    uint timingVariable = 86400;&#13;
&#13;
    // Address staking information&#13;
    struct AddressStakeData {&#13;
        uint stakeBalance;&#13;
        uint initialStakeTime;&#13;
    }&#13;
&#13;
    // Track all tokens staked&#13;
    mapping (address =&gt; AddressStakeData) public stakeBalances;&#13;
&#13;
    // -- Inflation -- //&#13;
    // Inflation rate begins at 100% per year and decreases by 15% per year until it reaches 10% where it decreases by 0.5% per year&#13;
    uint256 inflationRate = 1000;&#13;
&#13;
    // Used to manage when to inflate. Allowed to inflate once per year until the rate reaches 1%.&#13;
    uint256 public lastInflationUpdate;&#13;
&#13;
    // -- Events -- //&#13;
    // Fired when tokens are staked&#13;
    event Stake(address indexed staker, uint256 value);&#13;
    // Fired when tokens are unstaked&#13;
    event Unstake(address indexed unstaker, uint256 stakedAmount, uint256 stakingGains);&#13;
&#13;
    //////////////////////////////////////////////////&#13;
    /// Scale Token Functionality&#13;
    //////////////////////////////////////////////////&#13;
&#13;
    /// @dev Scale token constructor&#13;
    constructor() public {&#13;
        // Assign owner&#13;
        owner = msg.sender;&#13;
&#13;
        // Assign initial owner supply&#13;
        uint _initOwnerSupply = 10000000 ether;&#13;
        // Mint given to owner only one-time&#13;
        bool _success = mint(msg.sender, _initOwnerSupply);&#13;
        // Require minting success&#13;
        require(_success);&#13;
&#13;
        // Set pool and owner last minted to ensure extra coins are not minted by either&#13;
        ownerTimeLastMinted = now;&#13;
        poolTimeLastMinted = now;&#13;
&#13;
        // Set minting amount for pool, staking, and owner over the course of 1 year&#13;
        poolMintAmount = _initOwnerSupply.mul(poolPercentage).div(100);&#13;
        ownerMintAmount = _initOwnerSupply.mul(ownerPercentage).div(100);&#13;
        stakingMintAmount = _initOwnerSupply.mul(stakingPercentage).div(100);&#13;
&#13;
        // One year in seconds&#13;
        uint _oneYearInSeconds = 31536000 ether;&#13;
&#13;
        // Set the rate of coins minted per second for the pool, owner, and global staking&#13;
        poolMintRate = calculateFraction(poolMintAmount, _oneYearInSeconds, decimals);&#13;
        ownerMintRate = calculateFraction(ownerMintAmount, _oneYearInSeconds, decimals);&#13;
        stakingMintRate = calculateFraction(stakingMintAmount, _oneYearInSeconds, decimals);&#13;
&#13;
        // Set the last time inflation was update to now so that the next time it can be updated is 1 year from now&#13;
        lastInflationUpdate = now;&#13;
    }&#13;
&#13;
    /////////////&#13;
    // Inflation&#13;
    /////////////&#13;
&#13;
    /// @dev the inflation rate begins at 100% and decreases by 15% every year until it reaches 10%&#13;
    /// at 10% the rate begins to decrease by 0.5% until it reaches 1%&#13;
    function adjustInflationRate() private {&#13;
&#13;
&#13;
      // Make sure adjustInflationRate cannot be called for at least another year&#13;
      lastInflationUpdate = now;&#13;
&#13;
      // Decrease inflation rate by 15% each year&#13;
      if (inflationRate &gt; 100) {&#13;
&#13;
        inflationRate = inflationRate.sub(300);&#13;
      }&#13;
      // Inflation rate reaches 10%. Decrease inflation rate by 0.5% from here on out until it reaches 1%.&#13;
      else if (inflationRate &gt; 10) {&#13;
&#13;
        inflationRate = inflationRate.sub(5);&#13;
      }&#13;
&#13;
      // Calculate new mint amount of Scale that should be created per year.&#13;
      // Example Inflation Past Year 1 for the poolMintAmount: 16M * 0.85 * 0.7 = 9,520,000&#13;
      poolMintAmount = totalSupply.mul(inflationRate).div(1000).mul(poolPercentage).div(100);&#13;
      ownerMintAmount = totalSupply.mul(inflationRate).div(1000).mul(ownerPercentage).div(100);&#13;
      stakingMintAmount = totalSupply.mul(inflationRate).div(1000).mul(stakingPercentage).div(100);&#13;
&#13;
        // Adjust Scale created per-second for each rate&#13;
        poolMintRate = calculateFraction(poolMintAmount, 31536000 ether, decimals);&#13;
        ownerMintRate = calculateFraction(ownerMintAmount, 31536000 ether, decimals);&#13;
        stakingMintRate = calculateFraction(stakingMintAmount, 31536000 ether, decimals);&#13;
    }&#13;
&#13;
    /// @dev anyone can call this function to update the inflation rate yearly&#13;
    function updateInflationRate() public {&#13;
&#13;
      // Require 1 year to have passed for every inflation adjustment&#13;
      require(now.sub(lastInflationUpdate) &gt;= 31536000);&#13;
&#13;
      adjustInflationRate();&#13;
&#13;
    }&#13;
&#13;
    /////////////&#13;
    // Staking&#13;
    /////////////&#13;
&#13;
    /// @dev staking function which allows users to stake an amount of tokens to gain interest for up to 30 days&#13;
    /// @param _stakeAmount how many tokens a user wants to stake&#13;
    function stakeScale(uint _stakeAmount) external {&#13;
&#13;
        // Require that tokens are staked successfully&#13;
        require(stake(msg.sender, _stakeAmount));&#13;
    }&#13;
&#13;
    /// @dev stake for a seperate address&#13;
    /// @param _stakeAmount how many tokens a user wants to stake&#13;
    function stakeFor(address _user, uint _stakeAmount) external {&#13;
&#13;
      // You can only stake tokens for another user if they have not already staked tokens&#13;
      require(stakeBalances[_user].stakeBalance == 0);&#13;
&#13;
      // Transfer Scale from to the user&#13;
      transfer( _user, _stakeAmount);&#13;
&#13;
      // Stake for the user&#13;
      stake(_user, _stakeAmount);&#13;
    }&#13;
&#13;
    /// @dev stake function reduces the user's total available balance and adds it to their staking balance&#13;
    /// @param _value how many tokens a user wants to stake&#13;
    function stake(address _user, uint256 _value) private returns (bool success) {&#13;
&#13;
        // You can only stake as many tokens as you have&#13;
        require(_value &lt;= balances[_user]);&#13;
        // You can only stake tokens if you have not already staked tokens&#13;
        require(stakeBalances[_user].stakeBalance == 0);&#13;
&#13;
        // Subtract stake amount from regular token balance&#13;
        balances[_user] = balances[_user].sub(_value);&#13;
&#13;
        // Add stake amount to staked balance&#13;
        stakeBalances[_user].stakeBalance = _value;&#13;
&#13;
        // Increment the staking staked tokens value&#13;
        totalScaleStaked = totalScaleStaked.add(_value);&#13;
&#13;
        // Save the time that the stake started&#13;
        stakeBalances[_user].initialStakeTime = now.div(timingVariable);&#13;
&#13;
        // Set the new staking history&#13;
        setTotalStakingHistory();&#13;
&#13;
        // Fire an event to tell the world of the newly staked tokens&#13;
        emit Stake(_user, _value);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev returns how much Scale a user has earned so far&#13;
    /// @param _now is passed in to allow for a gas-free analysis&#13;
    /// @return staking gains based on the amount of time passed since staking began&#13;
    function getStakingGains(uint _now) view public returns (uint) {&#13;
&#13;
        if (stakeBalances[msg.sender].stakeBalance == 0) {&#13;
&#13;
          return 0;&#13;
        }&#13;
&#13;
        return calculateStakeGains(_now);&#13;
    }&#13;
&#13;
    /// @dev allows users to reclaim any staked tokens&#13;
    /// @return bool on success&#13;
    function unstake() external returns (bool) {&#13;
&#13;
        // Require that there was some amount vested&#13;
        require(stakeBalances[msg.sender].stakeBalance &gt; 0);&#13;
&#13;
        // Require that at least 7 timing variables have passed (days)&#13;
        require(now.div(timingVariable).sub(stakeBalances[msg.sender].initialStakeTime) &gt;= 7);&#13;
&#13;
        // Calculate tokens to mint&#13;
        uint _tokensToMint = calculateStakeGains(now);&#13;
&#13;
        balances[msg.sender] = balances[msg.sender].add(stakeBalances[msg.sender].stakeBalance);&#13;
&#13;
        // Subtract stake balance from totalScaleStaked&#13;
        totalScaleStaked = totalScaleStaked.sub(stakeBalances[msg.sender].stakeBalance);&#13;
&#13;
        // Mint the new tokens to the sender&#13;
        mint(msg.sender, _tokensToMint);&#13;
&#13;
        // Scale unstaked event&#13;
        emit Unstake(msg.sender, stakeBalances[msg.sender].stakeBalance, _tokensToMint);&#13;
&#13;
        // Clear out stored data from mapping&#13;
        stakeBalances[msg.sender].stakeBalance = 0;&#13;
        stakeBalances[msg.sender].initialStakeTime = 0;&#13;
&#13;
        // Set this every time someone adjusts the totalScaleStaking amount&#13;
        setTotalStakingHistory();&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Helper function to claimStake that modularizes the minting via staking calculation&#13;
    /// @param _now when the user stopped staking. Passed in as a variable to allow for checking without using gas from the getStakingGains function.&#13;
    /// @return uint for total coins to be minted&#13;
    function calculateStakeGains(uint _now) view private returns (uint mintTotal)  {&#13;
&#13;
      uint _nowAsTimingVariable = _now.div(timingVariable);    // Today as a unique value in unix time&#13;
      uint _initialStakeTimeInVariable = stakeBalances[msg.sender].initialStakeTime; // When the user started staking as a unique day in unix time&#13;
      uint _timePassedSinceStakeInVariable = _nowAsTimingVariable.sub(_initialStakeTimeInVariable); // How much time has passed, in days, since the user started staking.&#13;
      uint _stakePercentages = 0; // Keeps an additive track of the user's staking percentages over time&#13;
      uint _tokensToMint = 0; // How many new Scale tokens to create&#13;
      uint _lastUsedVariable;  // Last day the totalScaleStaked was updated&#13;
&#13;
      // Average this msg.sender's relative percentage ownership of totalScaleStaked throughout each day since they started staking&#13;
      for (uint i = _initialStakeTimeInVariable; i &lt; _nowAsTimingVariable; i++) {&#13;
&#13;
        // If the day exists add it to the percentages&#13;
        if (totalStakingHistory[i] != 0) {&#13;
&#13;
           // If the day does exist add it to the number to be later averaged as a total average percentage of total staking&#13;
          _stakePercentages = _stakePercentages.add(calculateFraction(stakeBalances[msg.sender].stakeBalance, totalStakingHistory[i], decimals));&#13;
&#13;
          // Set this as the last day someone staked&#13;
          _lastUsedVariable = totalStakingHistory[i];&#13;
        }&#13;
        else {&#13;
&#13;
          // Use the last day found in the totalStakingHistory mapping&#13;
          _stakePercentages = _stakePercentages.add(calculateFraction(stakeBalances[msg.sender].stakeBalance, _lastUsedVariable, decimals));&#13;
        }&#13;
&#13;
      }&#13;
&#13;
        // Get the account's average percentage staked of the total stake over the course of all days they have been staking&#13;
        uint _stakePercentageAverage = calculateFraction(_stakePercentages, _timePassedSinceStakeInVariable, 0);&#13;
&#13;
        // Calculate this account's mint rate per second while staking&#13;
        uint _finalMintRate = stakingMintRate.mul(_stakePercentageAverage);&#13;
&#13;
        // Account for 18 decimals when calculating the amount of tokens to mint&#13;
        _finalMintRate = _finalMintRate.div(1 ether);&#13;
&#13;
        // Calculate total tokens to be minted. Multiply by timingVariable to convert back to seconds.&#13;
        if (_timePassedSinceStakeInVariable &gt;= 365) {&#13;
&#13;
          // Tokens were staked for the maximum amount of time, one year. Give them one year's worth of tokens. ( this limit is placed to avoid gas limits)&#13;
          _tokensToMint = calculateMintTotal(timingVariable.mul(365), _finalMintRate);&#13;
        }&#13;
        else {&#13;
&#13;
          // Tokens were staked for less than the maximum amount of time&#13;
          _tokensToMint = calculateMintTotal(_timePassedSinceStakeInVariable.mul(timingVariable), _finalMintRate);&#13;
        }&#13;
&#13;
        return  _tokensToMint;&#13;
    }&#13;
&#13;
    /// @dev set the new totalStakingHistory mapping to the current timestamp and totalScaleStaked&#13;
    function setTotalStakingHistory() private {&#13;
&#13;
      // Get now in terms of the variable staking accuracy (days in Scale's case)&#13;
      uint _nowAsTimingVariable = now.div(timingVariable);&#13;
&#13;
      // Set the totalStakingHistory as a timestamp of the totalScaleStaked today&#13;
      totalStakingHistory[_nowAsTimingVariable] = totalScaleStaked;&#13;
    }&#13;
&#13;
    /// @dev Allows user to check their staked balance&#13;
    /// @return staked balance&#13;
    function getStakedBalance() view external returns (uint stakedBalance) {&#13;
&#13;
        return stakeBalances[msg.sender].stakeBalance;&#13;
    }&#13;
&#13;
    /////////////&#13;
    // Scale Owner Claiming&#13;
    /////////////&#13;
&#13;
    /// @dev allows contract owner to claim their mint&#13;
    function ownerClaim() external onlyOwner {&#13;
&#13;
        require(now &gt; ownerTimeLastMinted);&#13;
&#13;
        uint _timePassedSinceLastMint; // The amount of time passed since the owner claimed in seconds&#13;
        uint _tokenMintCount; // The amount of new tokens to mint&#13;
        bool _mintingSuccess; // The success of minting the new Scale tokens&#13;
&#13;
        // Calculate the number of seconds that have passed since the owner last took a claim&#13;
        _timePassedSinceLastMint = now.sub(ownerTimeLastMinted);&#13;
&#13;
        assert(_timePassedSinceLastMint &gt; 0);&#13;
&#13;
        // Determine the token mint amount, determined from the number of seconds passed and the ownerMintRate&#13;
        _tokenMintCount = calculateMintTotal(_timePassedSinceLastMint, ownerMintRate);&#13;
&#13;
        // Mint the owner's tokens; this also increases totalSupply&#13;
        _mintingSuccess = mint(msg.sender, _tokenMintCount);&#13;
&#13;
        require(_mintingSuccess);&#13;
&#13;
        // New minting was a success. Set last time minted to current block.timestamp (now)&#13;
        ownerTimeLastMinted = now;&#13;
    }&#13;
&#13;
    ////////////////////////////////&#13;
    // Scale Pool Distribution&#13;
    ////////////////////////////////&#13;
&#13;
    /// @dev anyone can call this function that mints Scale to the pool dedicated to Scale distribution to rewards pool&#13;
    function poolIssue() public {&#13;
&#13;
        // Do not allow tokens to be minted to the pool until the pool is set&#13;
        require(pool != address(0));&#13;
&#13;
        // Make sure time has passed since last minted to pool&#13;
        require(now &gt; poolTimeLastMinted);&#13;
        require(pool != address(0));&#13;
&#13;
        uint _timePassedSinceLastMint; // The amount of time passed since the pool claimed in seconds&#13;
        uint _tokenMintCount; // The amount of new tokens to mint&#13;
        bool _mintingSuccess; // The success of minting the new Scale tokens&#13;
&#13;
        // Calculate the number of seconds that have passed since the owner last took a claim&#13;
        _timePassedSinceLastMint = now.sub(poolTimeLastMinted);&#13;
&#13;
        assert(_timePassedSinceLastMint &gt; 0);&#13;
&#13;
        // Determine the token mint amount, determined from the number of seconds passed and the ownerMintRate&#13;
        _tokenMintCount = calculateMintTotal(_timePassedSinceLastMint, poolMintRate);&#13;
&#13;
        // Mint the owner's tokens; this also increases totalSupply&#13;
        _mintingSuccess = mint(pool, _tokenMintCount);&#13;
&#13;
        require(_mintingSuccess);&#13;
&#13;
        // New minting was a success! Set last time minted to current block.timestamp (now)&#13;
        poolTimeLastMinted = now;&#13;
    }&#13;
&#13;
    /// @dev sets the address for the rewards pool&#13;
    /// @param _newAddress pool Address&#13;
    function setPool(address _newAddress) public onlyOwner {&#13;
&#13;
        pool = _newAddress;&#13;
    }&#13;
&#13;
    ////////////////////////////////&#13;
    // Helper Functions&#13;
    ////////////////////////////////&#13;
&#13;
    /// @dev calculateFraction allows us to better handle the Solidity ugliness of not having decimals as a native type&#13;
    /// @param _numerator is the top part of the fraction we are calculating&#13;
    /// @param _denominator is the bottom part of the fraction we are calculating&#13;
    /// @param _precision tells the function how many significant digits to calculate out to&#13;
    /// @return quotient returns the result of our fraction calculation&#13;
    function calculateFraction(uint _numerator, uint _denominator, uint _precision) pure private returns(uint quotient) {&#13;
        // Take passed value and expand it to the required precision&#13;
        _numerator = _numerator.mul(10 ** (_precision + 1));&#13;
        // Handle last-digit rounding&#13;
        uint _quotient = ((_numerator.div(_denominator)) + 5) / 10;&#13;
        return (_quotient);&#13;
    }&#13;
&#13;
    /// @dev Determines the amount of Scale to create based on the number of seconds that have passed&#13;
    /// @param _timeInSeconds is the time passed in seconds to mint for&#13;
    /// @return uint with the calculated number of new tokens to mint&#13;
    function calculateMintTotal(uint _timeInSeconds, uint _mintRate) pure private returns(uint mintAmount) {&#13;
        // Calculates the amount of tokens to mint based upon the number of seconds passed&#13;
        return(_timeInSeconds.mul(_mintRate));&#13;
    }&#13;
&#13;
}