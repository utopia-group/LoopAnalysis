pragma solidity ^0.4.18;


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


/**************************************************************
 * @title Bela Token Contract
 * @file Bela.sol
 * @author Joe Jordan, BurgTech Solutions
 * @version 1.0
 *
 * @section LICENSE
 *
 * Contact for licensing details. All rights reserved.
 *
 * @section DESCRIPTION
 *
 * This is an ERC20-based token with staking functionality.
 *
 *************************************************************/
//////////////////////////////////
/// OpenZeppelin library imports
//////////////////////////////////

///* Truffle format 













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
    Transfer(msg.sender, _to, _value);
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
    Transfer(_from, _to, _value);
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
    Approval(msg.sender, _spender, _value);
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
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}





/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  //event MintFinished();

  //bool public mintingFinished = false;

  /*
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
  */

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) internal returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  */
}





/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="a2d0c7cfc1cde290">[email protected]</span>π.com&gt;&#13;
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
  function HasNoEther() public payable {&#13;
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
    assert(owner.send(this.balance));&#13;
  }&#13;
}&#13;
&#13;
&#13;
///* Remix format&#13;
//import "./MintableToken.sol";&#13;
//import "./HasNoEther.sol";&#13;
&#13;
&#13;
contract Bela is MintableToken, HasNoEther &#13;
{&#13;
    // Using libraries &#13;
    using SafeMath for uint;&#13;
&#13;
    //////////////////////////////////////////////////&#13;
    /// State Variables for the Bela token contract&#13;
    //////////////////////////////////////////////////&#13;
    &#13;
    //////////////////////&#13;
    // ERC20 token state&#13;
    //////////////////////&#13;
    &#13;
    /**&#13;
    These state vars are handled in the OpenZeppelin libraries;&#13;
    we display them here for the developer's information.&#13;
    ***&#13;
    // ERC20Basic - Store account balances&#13;
    mapping (address =&gt; uint256) public balances;&#13;
&#13;
    // StandardToken - Owner of account approves transfer of an amount to another account&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) public allowed;&#13;
&#13;
    // &#13;
    uint256 public totalSupply;&#13;
    */&#13;
    &#13;
    //////////////////////&#13;
    // Human token state&#13;
    //////////////////////&#13;
    string public constant name = "Bela";&#13;
    string public constant symbol = "BELA";&#13;
    uint8 public constant  decimals = 18;&#13;
&#13;
    ///////////////////////////////////////////////////////////&#13;
    // State vars for custom staking and budget functionality&#13;
    ///////////////////////////////////////////////////////////&#13;
&#13;
    // Owner last minted time&#13;
    uint public ownerTimeLastMinted;&#13;
    // Owner minted tokens per second&#13;
    uint public ownerMintRate;&#13;
&#13;
    /// Stake minting&#13;
    // Minted tokens per second for all stakers&#13;
    uint private globalMintRate;&#13;
    // Total tokens currently staked&#13;
    uint public totalBelaStaked; &#13;
&#13;
    // struct that will hold user stake&#13;
    struct TokenStakeData {&#13;
        uint initialStakeBalance;&#13;
        uint initialStakeTime;&#13;
        uint initialStakePercentage;&#13;
        address stakeSplitAddress;&#13;
    }&#13;
    &#13;
    // Track all tokens staked&#13;
    mapping (address =&gt; TokenStakeData) public stakeBalances;&#13;
&#13;
    // Fire a loggable event when tokens are staked&#13;
    event Stake(address indexed staker, address indexed stakeSplitAddress, uint256 value);&#13;
&#13;
    // Fire a loggable event when staked tokens are vested&#13;
    event Vest(address indexed vester, address indexed stakeSplitAddress, uint256 stakedAmount, uint256 stakingGains);&#13;
&#13;
    //////////////////////////////////////////////////&#13;
    /// Begin Bela token functionality&#13;
    //////////////////////////////////////////////////&#13;
&#13;
    /// @dev Bela token constructor&#13;
    function Bela() public&#13;
    {&#13;
        // Define owner&#13;
        owner = msg.sender;&#13;
        // Define initial owner supply. (ether here is used only to get the decimals right)&#13;
        uint _initOwnerSupply = 41000000 ether;&#13;
        // One-time bulk mint given to owner&#13;
        bool _success = mint(msg.sender, _initOwnerSupply);&#13;
        // Abort if initial minting failed for whatever reason&#13;
        require(_success);&#13;
&#13;
        ////////////////////////////////////&#13;
        // Set up state minting variables&#13;
        ////////////////////////////////////&#13;
&#13;
        // Set last minted to current block.timestamp ('now')&#13;
        ownerTimeLastMinted = now;&#13;
        &#13;
        // 4500 minted tokens per day, 86400 seconds in a day&#13;
        ownerMintRate = calculateFraction(4500, 86400, decimals);&#13;
        &#13;
        // 4,900,000 targeted minted tokens per year via staking; 31,536,000 seconds per year&#13;
        globalMintRate = calculateFraction(4900000, 31536000, decimals);&#13;
    }&#13;
&#13;
    /// @dev staking function which allows users to stake an amount of tokens to gain interest for up to 30 days &#13;
    function stakeBela(uint _stakeAmount) external&#13;
    {&#13;
        // Require that tokens are staked successfully&#13;
        require(stakeTokens(_stakeAmount));&#13;
    }&#13;
&#13;
    /// @dev staking function which allows users to split the interest earned with another address&#13;
    function stakeBelaSplit(uint _stakeAmount, address _stakeSplitAddress) external&#13;
    {&#13;
        // Require that a Bela split actually be split with an address&#13;
        require(_stakeSplitAddress &gt; 0);&#13;
        // Store split address into stake mapping&#13;
        stakeBalances[msg.sender].stakeSplitAddress = _stakeSplitAddress;&#13;
        // Require that tokens are staked successfully&#13;
        require(stakeTokens(_stakeAmount));&#13;
&#13;
    }&#13;
&#13;
    /// @dev allows users to reclaim any staked tokens&#13;
    /// @return bool on success&#13;
    function claimStake() external returns (bool success)&#13;
    {&#13;
        /// Sanity checks: &#13;
        // require that there was some amount vested&#13;
        require(stakeBalances[msg.sender].initialStakeBalance &gt; 0);&#13;
        // require that time has elapsed&#13;
        require(now &gt; stakeBalances[msg.sender].initialStakeTime);&#13;
&#13;
        // Calculate the time elapsed since the tokens were originally staked&#13;
        uint _timePassedSinceStake = now.sub(stakeBalances[msg.sender].initialStakeTime);&#13;
&#13;
        // Calculate tokens to mint&#13;
        uint _tokensToMint = calculateStakeGains(_timePassedSinceStake);&#13;
&#13;
        // Add the original stake back to the user's balance&#13;
        balances[msg.sender] += stakeBalances[msg.sender].initialStakeBalance;&#13;
        &#13;
        // Subtract stake balance from totalBelaStaked&#13;
        totalBelaStaked -= stakeBalances[msg.sender].initialStakeBalance;&#13;
        &#13;
        // Mint the new tokens; the new tokens are added to the user's balance&#13;
        if (stakeBalances[msg.sender].stakeSplitAddress &gt; 0) &#13;
        {&#13;
            // Splitting stake, so mint half to sender and half to stakeSplitAddress&#13;
            mint(msg.sender, _tokensToMint.div(2));&#13;
            mint(stakeBalances[msg.sender].stakeSplitAddress, _tokensToMint.div(2));&#13;
        } else {&#13;
            // Not spliting stake; mint all new tokens and give them to msg.sender &#13;
            mint(msg.sender, _tokensToMint);&#13;
        }&#13;
        &#13;
        // Fire an event to tell the world of the newly vested tokens&#13;
        Vest(msg.sender, stakeBalances[msg.sender].stakeSplitAddress, stakeBalances[msg.sender].initialStakeBalance, _tokensToMint);&#13;
&#13;
        // Clear out stored data from mapping&#13;
        stakeBalances[msg.sender].initialStakeBalance = 0;&#13;
        stakeBalances[msg.sender].initialStakeTime = 0;&#13;
        stakeBalances[msg.sender].initialStakePercentage = 0;&#13;
        stakeBalances[msg.sender].stakeSplitAddress = 0;&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Allows user to check their staked balance&#13;
    function getStakedBalance() view external returns (uint stakedBalance) &#13;
    {&#13;
        return stakeBalances[msg.sender].initialStakeBalance;&#13;
    }&#13;
&#13;
    /// @dev allows contract owner to claim their mint&#13;
    function ownerClaim() external onlyOwner&#13;
    {&#13;
        // Sanity check: ensure that we didn't travel back in time&#13;
        require(now &gt; ownerTimeLastMinted);&#13;
        &#13;
        uint _timePassedSinceLastMint;&#13;
        uint _tokenMintCount;&#13;
        bool _mintingSuccess;&#13;
&#13;
        // Calculate the number of seconds that have passed since the owner last took a claim&#13;
        _timePassedSinceLastMint = now.sub(ownerTimeLastMinted);&#13;
&#13;
        // Sanity check: ensure that some time has passed since the owner last claimed&#13;
        assert(_timePassedSinceLastMint &gt; 0);&#13;
&#13;
        // Determine the token mint amount, determined from the number of seconds passed and the ownerMintRate&#13;
        _tokenMintCount = calculateMintTotal(_timePassedSinceLastMint, ownerMintRate);&#13;
&#13;
        // Mint the owner's tokens; this also increases totalSupply&#13;
        _mintingSuccess = mint(msg.sender, _tokenMintCount);&#13;
&#13;
        // Sanity check: ensure that the minting was successful&#13;
        require(_mintingSuccess);&#13;
        &#13;
        // New minting was a success! Set last time minted to current block.timestamp (now)&#13;
        ownerTimeLastMinted = now;&#13;
    }&#13;
&#13;
    /// @dev stake function reduces the user's total available balance. totalSupply is unaffected&#13;
    /// @param _value determines how many tokens a user wants to stake&#13;
    function stakeTokens(uint256 _value) private returns (bool success)&#13;
    {&#13;
        /// Sanity Checks:&#13;
        // You can only stake as many tokens as you have&#13;
        require(_value &lt;= balances[msg.sender]);&#13;
        // You can only stake tokens if you have not already staked tokens&#13;
        require(stakeBalances[msg.sender].initialStakeBalance == 0);&#13;
&#13;
        // Subtract stake amount from regular token balance&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
&#13;
        // Add stake amount to staked balance&#13;
        stakeBalances[msg.sender].initialStakeBalance = _value;&#13;
&#13;
        // Increment the global staked tokens value&#13;
        totalBelaStaked += _value;&#13;
&#13;
        /// Determine percentage of global stake&#13;
        stakeBalances[msg.sender].initialStakePercentage = calculateFraction(_value, totalBelaStaked, decimals);&#13;
        &#13;
        // Save the time that the stake started&#13;
        stakeBalances[msg.sender].initialStakeTime = now;&#13;
&#13;
        // Fire an event to tell the world of the newly staked tokens&#13;
        Stake(msg.sender, stakeBalances[msg.sender].stakeSplitAddress, _value);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Helper function to claimStake that modularizes the minting via staking calculation &#13;
    function calculateStakeGains(uint _timePassedSinceStake) view private returns (uint mintTotal)&#13;
    {&#13;
        // Store seconds in a day (need it in variable to use SafeMath)&#13;
        uint _secondsPerDay = 86400;&#13;
        uint _finalStakePercentage;     // store our stake percentage at the time of stake claim&#13;
        uint _stakePercentageAverage;   // store our calculated average minting rate ((initial+final) / 2)&#13;
        uint _finalMintRate;            // store our calculated final mint rate (in Bela-per-second)&#13;
        uint _tokensToMint = 0;         // store number of new tokens to be minted&#13;
        &#13;
        // Determine the amount to be newly minted upon vesting, if any&#13;
        if (_timePassedSinceStake &gt; _secondsPerDay) {&#13;
            &#13;
            /// We've passed the minimum staking time; calculate minting rate average ((initialRate + finalRate) / 2)&#13;
            &#13;
            // First, calculate our final stake percentage based upon the total amount of Bela staked&#13;
            _finalStakePercentage = calculateFraction(stakeBalances[msg.sender].initialStakeBalance, totalBelaStaked, decimals);&#13;
&#13;
            // Second, calculate average of initial and final stake percentage&#13;
            _stakePercentageAverage = calculateFraction((stakeBalances[msg.sender].initialStakePercentage.add(_finalStakePercentage)), 2, 0);&#13;
&#13;
            // Finally, calculate our final mint rate (in Bela-per-second)&#13;
            _finalMintRate = globalMintRate.mul(_stakePercentageAverage); &#13;
            _finalMintRate = _finalMintRate.div(1 ether);&#13;
            &#13;
            // Tokens were staked for enough time to mint new tokens; determine how many&#13;
            if (_timePassedSinceStake &gt; _secondsPerDay.mul(30)) {&#13;
                // Tokens were staked for the maximum amount of time (30 days)&#13;
                _tokensToMint = calculateMintTotal(_secondsPerDay.mul(30), _finalMintRate);&#13;
            } else {&#13;
                // Tokens were staked for a mintable amount of time, but less than the 30-day max&#13;
                _tokensToMint = calculateMintTotal(_timePassedSinceStake, _finalMintRate);&#13;
            }&#13;
        } &#13;
        &#13;
        // Return the amount of new tokens to be minted&#13;
        return _tokensToMint;&#13;
&#13;
    }&#13;
&#13;
    /// @dev calculateFraction allows us to better handle the Solidity ugliness of not having decimals as a native type &#13;
    /// @param _numerator is the top part of the fraction we are calculating&#13;
    /// @param _denominator is the bottom part of the fraction we are calculating&#13;
    /// @param _precision tells the function how many significant digits to calculate out to&#13;
    /// @return quotient returns the result of our fraction calculation&#13;
    function calculateFraction(uint _numerator, uint _denominator, uint _precision) pure private returns(uint quotient) &#13;
    {&#13;
        // Take passed value and expand it to the required precision&#13;
        _numerator = _numerator.mul(10 ** (_precision + 1));&#13;
        // handle last-digit rounding&#13;
        uint _quotient = ((_numerator.div(_denominator)) + 5) / 10;&#13;
        return (_quotient);&#13;
    }&#13;
&#13;
    /// @dev Determines mint total based upon how many seconds have passed&#13;
    /// @param _timeInSeconds takes the time that has elapsed since the last minting&#13;
    /// @return uint with the calculated number of new tokens to mint&#13;
    function calculateMintTotal(uint _timeInSeconds, uint _mintRate) pure private returns(uint mintAmount)&#13;
    {&#13;
        // Calculates the amount of tokens to mint based upon the number of seconds passed&#13;
        return(_timeInSeconds.mul(_mintRate));&#13;
    }&#13;
&#13;
}