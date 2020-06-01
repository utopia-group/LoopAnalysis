pragma solidity ^0.4.18;

/**
 * WorldCoin: https://worldcoin.cash
 */

//====== Open Zeppelin Library =====
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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
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
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="25574048464a6517">[email protected]</a>π.com&gt;&#13;
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
/**&#13;
 * @title Contracts that should not own Contracts&#13;
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="087a6d656b67483a">[email protected]</a>π.com&gt;&#13;
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
 * @title Contracts that should be able to recover tokens&#13;
 * @author SylTi&#13;
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.&#13;
 * This will prevent any accidental loss of tokens.&#13;
 */&#13;
contract CanReclaimToken is Ownable {&#13;
  using SafeERC20 for ERC20Basic;&#13;
&#13;
  /**&#13;
   * @dev Reclaim all ERC20Basic compatible tokens&#13;
   * @param token ERC20Basic The address of the token contract&#13;
   */&#13;
  function reclaimToken(ERC20Basic token) external onlyOwner {&#13;
    uint256 balance = token.balanceOf(this);&#13;
    token.safeTransfer(owner, balance);&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="34465159575b7406">[email protected]</a>π.com&gt;&#13;
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
   * approve should be called when allowed[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   */&#13;
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
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
//====== BurnableToken =====&#13;
&#13;
contract BurnableToken is StandardToken {&#13;
    using SafeMath for uint256;&#13;
&#13;
    event Burn(address indexed from, uint256 amount);&#13;
    event BurnRewardIncreased(address indexed from, uint256 value);&#13;
&#13;
    /**&#13;
    * @dev Sending ether to contract increases burning reward &#13;
    */&#13;
    function() payable public {&#13;
        if(msg.value &gt; 0){&#13;
            BurnRewardIncreased(msg.sender, msg.value);    &#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Calculates how much ether one will receive in reward for burning tokens&#13;
     * @param _amount of tokens to be burned&#13;
     */&#13;
    function burnReward(uint256 _amount) public constant returns(uint256){&#13;
        return this.balance.mul(_amount).div(totalSupply);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Burns tokens and send reward&#13;
    * This is internal function because it DOES NOT check &#13;
    * if _from has allowance to burn tokens.&#13;
    * It is intended to be used in transfer() and transferFrom() which do this check.&#13;
    * @param _from The address which you want to burn tokens from&#13;
    * @param _amount of tokens to be burned&#13;
    */&#13;
    function burn(address _from, uint256 _amount) internal returns(bool){&#13;
        require(balances[_from] &gt;= _amount);&#13;
        &#13;
        uint256 reward = burnReward(_amount);&#13;
        assert(this.balance - reward &gt; 0);&#13;
&#13;
        balances[_from] = balances[_from].sub(_amount);&#13;
        totalSupply = totalSupply.sub(_amount);&#13;
        //assert(totalSupply &gt;= 0); //Check is not needed because totalSupply.sub(value) will already throw if this condition is not met&#13;
        &#13;
        _from.transfer(reward);&#13;
        Burn(_from, _amount);&#13;
        Transfer(_from, address(0), _amount);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Transfers or burns tokens&#13;
    * Burns tokens transferred to this contract itself or to zero address&#13;
    * @param _to The address to transfer to or token contract address to burn.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        if( (_to == address(this)) || (_to == 0) ){&#13;
            return burn(msg.sender, _value);&#13;
        }else{&#13;
            return super.transfer(_to, _value);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Transfer tokens from one address to another &#13;
    * or burns them if _to is this contract or zero address&#13;
    * @param _from address The address which you want to send tokens from&#13;
    * @param _to address The address which you want to transfer to&#13;
    * @param _value uint256 the amout of tokens to be transfered&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        if( (_to == address(this)) || (_to == 0) ){&#13;
            var _allowance = allowed[_from][msg.sender];&#13;
            //require (_value &lt;= _allowance); //Check is not needed because _allowance.sub(_value) will already throw if this condition is not met&#13;
            allowed[_from][msg.sender] = _allowance.sub(_value);&#13;
            return burn(_from, _value);&#13;
        }else{&#13;
            return super.transferFrom(_from, _to, _value);&#13;
        }&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
//====== WorldCoin Contracts =====&#13;
&#13;
/**&#13;
 * @title WorldCoin token&#13;
 */&#13;
contract WorldCoin is BurnableToken, MintableToken, HasNoContracts, HasNoTokens { //MintableToken is StandardToken, Ownable&#13;
    using SafeMath for uint256;&#13;
&#13;
    string public name = "World Coin Network";&#13;
    string public symbol = "WCN";&#13;
    uint256 public decimals = 18;&#13;
&#13;
&#13;
    /**&#13;
     * Allow transfer only after crowdsale finished&#13;
     */&#13;
    modifier canTransfer() {&#13;
        require(mintingFinished);&#13;
        _;&#13;
    }&#13;
    &#13;
    function transfer(address _to, uint256 _value) canTransfer public returns (bool) {&#13;
        return BurnableToken.transfer(_to, _value);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {&#13;
        return BurnableToken.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title WorldCoin Crowdsale&#13;
 */&#13;
contract WorldCoinCrowdsale is Ownable, HasNoContracts, HasNoTokens {&#13;
    using SafeMath for uint256;&#13;
&#13;
    uint32 private constant PERCENT_DIVIDER = 100;&#13;
&#13;
    WorldCoin public token;&#13;
&#13;
    struct Round {&#13;
        uint256 start;      //Timestamp of crowdsale round start&#13;
        uint256 end;        //Timestamp of crowdsale round end&#13;
        uint256 rate;       //Rate: how much TOKEN one will get fo 1 ETH during this round&#13;
    }&#13;
    Round[] public rounds;  //Array of crowdsale rounds&#13;
&#13;
&#13;
    uint256 public founderPercent;      //how many tokens will be sent to founder (percent of purshased token)&#13;
    uint256 public partnerBonusPercent; //referral partner bonus (percent of purshased token)&#13;
    uint256 public referralBonusPercent;//referral buyer bonus (percent of purshased token)&#13;
    uint256 public hardCap;             //Maximum amount of tokens mined&#13;
    uint256 public totalCollected;      //total amount of collected funds (in ethereum wei)&#13;
    uint256 public tokensMinted;        //total amount of minted tokens&#13;
    bool public finalized;              //crowdsale is finalized&#13;
&#13;
    /**&#13;
     * @dev WorldCoin Crowdsale Contract&#13;
     * @param _founderPercent Amount of tokens sent to founder with each purshase (percent of purshased token)&#13;
     * @param _partnerBonusPercent Referral partner bonus (percent of purshased token)&#13;
     * @param _referralBonusPercent Referral buyer bonus (percent of purshased token)&#13;
     * @param _hardCap Maximum amount of ether (in wei) to be collected during crowdsale&#13;
     * @param roundStarts List of round start timestams&#13;
     * @param roundEnds List of round end timestams &#13;
     * @param roundRates List of round rates (tokens for 1 ETH)&#13;
     */&#13;
    function WorldCoinCrowdsale (&#13;
        uint256 _founderPercent,&#13;
        uint256 _partnerBonusPercent,&#13;
        uint256 _referralBonusPercent,&#13;
        uint256 _hardCap,&#13;
        uint256[] roundStarts,&#13;
        uint256[] roundEnds,&#13;
        uint256[] roundRates&#13;
    ) public {&#13;
&#13;
        //Check all paramaters are correct and create rounds&#13;
        require(_hardCap &gt; 0);                    //Need something to sell&#13;
        require(&#13;
            (roundStarts.length &gt; 0)  &amp;&amp;                //There should be at least one round&#13;
            (roundStarts.length == roundEnds.length) &amp;&amp;&#13;
            (roundStarts.length == roundRates.length)&#13;
        );                   &#13;
        uint256 prevRoundEnd = now;&#13;
        rounds.length = roundStarts.length;             //initialize rounds array&#13;
        for(uint8 i=0; i &lt; roundStarts.length; i++){&#13;
            rounds[i] = Round(roundStarts[i], roundEnds[i], roundRates[i]);&#13;
            Round storage r = rounds[i];&#13;
            require(prevRoundEnd &lt;= r.start);&#13;
            require(r.start &lt; r.end);&#13;
            require(r.rate &gt; 0);&#13;
            prevRoundEnd = rounds[i].end;&#13;
        }&#13;
&#13;
        hardCap = _hardCap;&#13;
        partnerBonusPercent = _partnerBonusPercent;&#13;
        referralBonusPercent = _referralBonusPercent;&#13;
        founderPercent = _founderPercent;&#13;
        //founderPercentWithReferral = founderPercent * (rate + partnerBonusPercent + referralBonusPercent) / rate;  //Did not use SafeMath here, because this parameters defined by contract creator should not be malicious. Also have checked result on the next line.&#13;
        //assert(founderPercentWithReferral &gt;= founderPercent);&#13;
&#13;
        token = new WorldCoin();&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Fetches current Round number&#13;
    * @return round number (index in rounds array + 1) or 0 if none&#13;
    */&#13;
    function currentRoundNum() constant public returns(uint8) {&#13;
        for(uint8 i=0; i &lt; rounds.length; i++){&#13;
            if( (now &gt; rounds[i].start) &amp;&amp; (now &lt;= rounds[i].end) ) return i+1;&#13;
        }&#13;
        return 0;&#13;
    }&#13;
    /**&#13;
    * @dev Fetches current rate (how many tokens you get for 1 ETH)&#13;
    * @return calculated rate or zero if no round of crowdsale is running&#13;
    */&#13;
    function currentRate() constant public returns(uint256) {&#13;
        uint8 roundNum = currentRoundNum();&#13;
        if(roundNum == 0) {&#13;
            return 0;&#13;
        }else{&#13;
            return rounds[roundNum-1].rate;&#13;
        }&#13;
    }&#13;
&#13;
    function firstRoundStartTimestamp() constant public returns(uint256){&#13;
        return rounds[0].start;&#13;
    }&#13;
    function lastRoundEndTimestamp() constant public returns(uint256){&#13;
        return rounds[rounds.length - 1].end;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Shows if crowdsale is running&#13;
    */ &#13;
    function crowdsaleRunning() constant public returns(bool){&#13;
        return !finalized &amp;&amp; (tokensMinted &lt; hardCap) &amp;&amp; (currentRoundNum() &gt; 0);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Buy WorldCoin tokens&#13;
    */&#13;
    function() payable public {&#13;
        sale(msg.sender, 0x0);&#13;
    } &#13;
&#13;
    /**&#13;
    * @dev Buy WorldCoin tokens witn referral program&#13;
    */&#13;
    function sale(address buyer, address partner) public payable {&#13;
        if(!crowdsaleRunning()) revert();&#13;
        require(msg.value &gt; 0);&#13;
        uint256 rate = currentRate();&#13;
        assert(rate &gt; 0);&#13;
&#13;
        uint256 referralTokens; uint256 partnerTokens; uint256 ownerTokens;&#13;
        uint256 tokens = rate.mul(msg.value);&#13;
        assert(tokens &gt; 0);&#13;
        totalCollected = totalCollected.add(msg.value);&#13;
        if(partner == 0x0){&#13;
            ownerTokens     = tokens.mul(founderPercent).div(PERCENT_DIVIDER);&#13;
            mintTokens(buyer, tokens);&#13;
            mintTokens(owner, ownerTokens);&#13;
        }else{&#13;
            partnerTokens   = tokens.mul(partnerBonusPercent).div(PERCENT_DIVIDER);&#13;
            referralTokens  = tokens.mul(referralBonusPercent).div(PERCENT_DIVIDER);&#13;
            ownerTokens     = (tokens.add(partnerTokens).add(referralTokens)).mul(founderPercent).div(PERCENT_DIVIDER);&#13;
            &#13;
            uint256 totalBuyerTokens = tokens.add(referralTokens);&#13;
            mintTokens(buyer, totalBuyerTokens);&#13;
            mintTokens(partner, partnerTokens);&#13;
            mintTokens(owner, ownerTokens);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Mint tokens for purshases with Non-Ether currencies&#13;
    * @param beneficiary whom to send tokend&#13;
    * @param amount how much tokens to send&#13;
    * param message reason why we are sending tokens (not stored anythere, only in transaction itself)&#13;
    */&#13;
    function saleNonEther(address beneficiary, uint256 amount, string /*message*/) public onlyOwner {&#13;
        mintTokens(beneficiary, amount);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Updates rate for the round&#13;
    */&#13;
    function setRoundRate(uint32 roundNum, uint256 rate) public onlyOwner {&#13;
        require(roundNum &lt; rounds.length);&#13;
        rounds[roundNum].rate = rate;&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
    * @notice Sends collected funds to owner&#13;
    * May be executed only if goal reached and no refunds are possible&#13;
    */&#13;
    function claimEther() public onlyOwner {&#13;
        if(this.balance &gt; 0){&#13;
            owner.transfer(this.balance);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Finalizes ICO when one of conditions met:&#13;
    * - end time reached OR&#13;
    * - no more tokens available (cap reached) OR&#13;
    * - message sent by owner&#13;
    */&#13;
    function finalizeCrowdsale() public {&#13;
        require ( (now &gt; lastRoundEndTimestamp()) || (totalCollected == hardCap) || (msg.sender == owner) );&#13;
        finalized = token.finishMinting();&#13;
        token.transferOwnership(owner);&#13;
        if(this.balance &gt; 0){&#13;
            owner.transfer(this.balance);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Helper function to mint tokens and increase tokensMinted counter&#13;
    */&#13;
    function mintTokens(address beneficiary, uint256 amount) internal {&#13;
        tokensMinted = tokensMinted.add(amount);&#13;
        require(tokensMinted &lt;= hardCap);&#13;
        assert(token.mint(beneficiary, amount));&#13;
    }&#13;
}