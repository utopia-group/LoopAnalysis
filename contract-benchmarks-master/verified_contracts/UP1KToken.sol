pragma solidity ^0.4.18;

//====== Open Zeppelin Library =====
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
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0e7c6b636d614e3c">[email protected]</a>π.com&gt;&#13;
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
 * @author Remco Bloemen &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="86f4e3ebe5e9c6b4">[email protected]</a>π.com&gt;&#13;
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
//====== UP1K Contracts =====&#13;
&#13;
/**&#13;
* @title TradeableToken can be bought and sold from/to it's own contract during it's life time&#13;
* Sold tokens and Ether received to buy tokens are collected during specified period and then time comes&#13;
* contract owner should specify price for the last period and send tokens/ether to their new owners.&#13;
*/&#13;
contract TradeableToken is StandardToken, Ownable {&#13;
    using SafeMath for uint256;&#13;
&#13;
    event Sale(address indexed buyer, uint256 amount);&#13;
    event Redemption(address indexed seller, uint256 amount);&#13;
    event DistributionError(address seller, uint256 amount);&#13;
&#13;
    /**&#13;
    * State of the contract:&#13;
    * Collecting - collecting ether and tokens&#13;
    * Distribution - distribution of bought tokens and ether is in process&#13;
    */&#13;
    enum State{Collecting, Distribution}&#13;
&#13;
    State   public currentState;                //Current state of the contract&#13;
    uint256 public previousPeriodRate;          //Previous rate: how many tokens one could receive for 1 ether in the last period&#13;
    uint256 public currentPeriodEndTimestamp;   //Timestamp after which no more trades are accepted and contract is waiting to start distribution&#13;
    uint256 public currentPeriodStartBlock;     //Number of block when current perions was started&#13;
&#13;
    uint256 public currentPeriodRate;           //Current rate: how much tokens one should receive for 1 ether in current distribution period&#13;
    uint256 public currentPeriodEtherCollected; //How much ether was collected (to buy tokens) during current period and waiting for distribution&#13;
    uint256 public currentPeriodTokenCollected; //How much tokens was collected (to sell tokens) during current period and waiting for distribution&#13;
&#13;
    mapping(address =&gt; uint256) receivedEther;  //maps address of buyer to amount of ether he sent&#13;
    mapping(address =&gt; uint256) soldTokens;     //maps address of seller to amount of tokens he sent&#13;
&#13;
    uint32 constant MILLI_PERCENT_DIVIDER = 100*1000;&#13;
    uint32 public buyFeeMilliPercent;           //The buyer's fee in a thousandth of percent. So, if buyer's fee = 5%, then buyFeeMilliPercent = 5000 and if without buyer shoud receive 200 tokens with fee it will receive 200 - (200 * 5000 / MILLI_PERCENT_DIVIDER)&#13;
    uint32 public sellFeeMilliPercent;          //The seller's fee in a thousandth of percent. (see above)&#13;
&#13;
    uint256 public minBuyAmount;                //Minimal amount of ether to buy&#13;
    uint256 public minSellAmount;               //Minimal amount of tokens to sell&#13;
&#13;
    modifier canBuyAndSell() {&#13;
        require(currentState == State.Collecting);&#13;
        require(now &lt; currentPeriodEndTimestamp);&#13;
        _;&#13;
    }&#13;
&#13;
    function TradeableToken() public {&#13;
        currentState = State.Distribution;&#13;
        //currentPeriodStartBlock = 0;&#13;
        currentPeriodEndTimestamp = now;    //ensure that nothing can be collected until new period is started by owner&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Send Ether to buy tokens&#13;
    */&#13;
    function() payable public {&#13;
        require(msg.value &gt; 0);&#13;
        buy(msg.sender, msg.value);&#13;
    }    &#13;
&#13;
    /**&#13;
    * @notice Transfer or sell tokens&#13;
    * Sells tokens transferred to this contract itself or to zero address&#13;
    * @param _to The address to transfer to or token contract address to burn.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        if( (_to == address(this)) || (_to == 0) ){&#13;
            return sell(msg.sender, _value);&#13;
        }else{&#13;
            return super.transfer(_to, _value);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Transfer tokens from one address to another  or sell them if _to is this contract or zero address&#13;
    * @param _from address The address which you want to send tokens from&#13;
    * @param _to address The address which you want to transfer to&#13;
    * @param _value uint256 the amout of tokens to be transfered&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        if( (_to == address(this)) || (_to == 0) ){&#13;
            var _allowance = allowed[_from][msg.sender];&#13;
            require (_value &lt;= _allowance);&#13;
            allowed[_from][msg.sender] = _allowance.sub(_value);&#13;
            return sell(_from, _value);&#13;
        }else{&#13;
            return super.transferFrom(_from, _to, _value);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Fuction called when somebody is buying tokens&#13;
    * @param who The address of buyer (who will own bought tokens)&#13;
    * @param amount The amount to be transferred.&#13;
    */&#13;
    function buy(address who, uint256 amount) canBuyAndSell internal returns(bool){&#13;
        require(amount &gt;= minBuyAmount);&#13;
        currentPeriodEtherCollected = currentPeriodEtherCollected.add(amount);&#13;
        receivedEther[who] = receivedEther[who].add(amount);  //if this is first operation from this address, initial value of receivedEther[to] == 0&#13;
        Sale(who, amount);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Fuction called when somebody is selling his tokens&#13;
    * @param who The address of seller (whose tokens are sold)&#13;
    * @param amount The amount to be transferred.&#13;
    */&#13;
    function sell(address who, uint256 amount) canBuyAndSell internal returns(bool){&#13;
        require(amount &gt;= minSellAmount);&#13;
        currentPeriodTokenCollected = currentPeriodTokenCollected.add(amount);&#13;
        soldTokens[who] = soldTokens[who].add(amount);  //if this is first operation from this address, initial value of soldTokens[to] == 0&#13;
        totalSupply = totalSupply.sub(amount);&#13;
        Redemption(who, amount);&#13;
        Transfer(who, address(0), amount);&#13;
        return true;&#13;
    }&#13;
    /**&#13;
    * @notice Set fee applied when buying tokens&#13;
    * @param _buyFeeMilliPercent fee in thousandth of percent (5% = 5000)&#13;
    */&#13;
    function setBuyFee(uint32 _buyFeeMilliPercent) onlyOwner public {&#13;
        require(_buyFeeMilliPercent &lt; MILLI_PERCENT_DIVIDER);&#13;
        buyFeeMilliPercent = _buyFeeMilliPercent;&#13;
    }&#13;
    /**&#13;
    * @notice Set fee applied when selling tokens&#13;
    * @param _sellFeeMilliPercent fee in thousandth of percent (5% = 5000)&#13;
    */&#13;
    function setSellFee(uint32 _sellFeeMilliPercent) onlyOwner public {&#13;
        require(_sellFeeMilliPercent &lt; MILLI_PERCENT_DIVIDER);&#13;
        sellFeeMilliPercent = _sellFeeMilliPercent;&#13;
    }&#13;
    /**&#13;
    * @notice set minimal amount of ether which can be used to buy tokens&#13;
    * @param _minBuyAmount minimal amount of ether&#13;
    */&#13;
    function setMinBuyAmount(uint256 _minBuyAmount) onlyOwner public {&#13;
        minBuyAmount = _minBuyAmount;&#13;
    }&#13;
    /**&#13;
    * @notice set minimal amount of ether which can be used to buy tokens&#13;
    * @param _minSellAmount minimal amount of tokens&#13;
    */&#13;
    function setMinSellAmount(uint256 _minSellAmount) onlyOwner public {&#13;
        minSellAmount = _minSellAmount;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Collect ether received for token purshases&#13;
    * This is possible both during Collection and Distribution phases&#13;
    */&#13;
    function collectEther(uint256 amount) onlyOwner public {&#13;
        owner.transfer(amount);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Start distribution phase&#13;
    * @param _currentPeriodRate exchange rate for current distribution&#13;
    */&#13;
    function startDistribution(uint256 _currentPeriodRate) onlyOwner public {&#13;
        require(currentState != State.Distribution);    //owner should not be able to change rate after distribution is started, ensures that everyone have the same rate&#13;
        require(_currentPeriodRate != 0);                //something has to be distributed!&#13;
        //require(now &gt;= currentPeriodEndTimestamp)     //DO NOT require period end timestamp passed, because there can be some situations when it is neede to end it sooner. But this should be done with extremal care, because of possible race condition between new sales/purshases and currentPeriodRate definition&#13;
&#13;
        currentState = State.Distribution;&#13;
        currentPeriodRate = _currentPeriodRate;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Distribute tokens to buyers&#13;
    * @param buyers an array of addresses to pay tokens for their ether. Should be composed from outside by reading Sale events &#13;
    */&#13;
    function distributeTokens(address[] buyers) onlyOwner public {&#13;
        require(currentState == State.Distribution);&#13;
        require(currentPeriodRate &gt; 0);&#13;
        for(uint256 i=0; i &lt; buyers.length; i++){&#13;
            address buyer = buyers[i];&#13;
            require(buyer != address(0));&#13;
            uint256 etherAmount = receivedEther[buyer];&#13;
            if(etherAmount == 0) continue; //buyer not found or already paid&#13;
            uint256 tokenAmount = etherAmount.mul(currentPeriodRate);&#13;
            uint256 fee = tokenAmount.mul(buyFeeMilliPercent).div(MILLI_PERCENT_DIVIDER);&#13;
            tokenAmount = tokenAmount.sub(fee);&#13;
            &#13;
            receivedEther[buyer] = 0;&#13;
            currentPeriodEtherCollected = currentPeriodEtherCollected.sub(etherAmount);&#13;
            //mint tokens&#13;
            totalSupply = totalSupply.add(tokenAmount);&#13;
            balances[buyer] = balances[buyer].add(tokenAmount);&#13;
            Transfer(address(0), buyer, tokenAmount);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Distribute ether to sellers&#13;
    * If not enough ether is available on contract ballance&#13;
    * @param sellers an array of addresses to pay ether for their tokens. Should be composed from outside by reading Redemption events &#13;
    */&#13;
    function distributeEther(address[] sellers) onlyOwner payable public {&#13;
        require(currentState == State.Distribution);&#13;
        require(currentPeriodRate &gt; 0);&#13;
        for(uint256 i=0; i &lt; sellers.length; i++){&#13;
            address seller = sellers[i];&#13;
            require(seller != address(0));&#13;
            uint256 tokenAmount = soldTokens[seller];&#13;
            if(tokenAmount == 0) continue; //seller not found or already paid&#13;
            uint256 etherAmount = tokenAmount.div(currentPeriodRate);&#13;
            uint256 fee = etherAmount.mul(sellFeeMilliPercent).div(MILLI_PERCENT_DIVIDER);&#13;
            etherAmount = etherAmount.sub(fee);&#13;
            &#13;
            soldTokens[seller] = 0;&#13;
            currentPeriodTokenCollected = currentPeriodTokenCollected.sub(tokenAmount);&#13;
            if(!seller.send(etherAmount)){&#13;
                //in this case we can only log error and let owner to handle it manually&#13;
                DistributionError(seller, etherAmount);&#13;
                owner.transfer(etherAmount); //assume this should not fail..., overwise - change owner&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function startCollecting(uint256 _collectingEndTimestamp) onlyOwner public {&#13;
        require(_collectingEndTimestamp &gt; now);      //Need some time for collection&#13;
        require(currentState == State.Distribution);    //Do not allow to change collection terms after it is started&#13;
        require(currentPeriodEtherCollected == 0);      //All sold tokens are distributed&#13;
        require(currentPeriodTokenCollected == 0);      //All redeemed tokens are paid&#13;
        previousPeriodRate = currentPeriodRate;&#13;
        currentPeriodRate = 0;&#13;
        currentPeriodStartBlock = block.number;&#13;
        currentPeriodEndTimestamp = _collectingEndTimestamp;&#13;
        currentState = State.Collecting;&#13;
    }&#13;
}&#13;
&#13;
contract UP1KToken is TradeableToken, MintableToken, HasNoContracts, HasNoTokens { //MintableToken is StandardToken, Ownable&#13;
    string public symbol = "UP1K";&#13;
    string public name = "UpStart 1000";&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    address public founder;    //founder address to allow him transfer tokens while minting&#13;
    function init(address _founder, uint32 _buyFeeMilliPercent, uint32 _sellFeeMilliPercent, uint256 _minBuyAmount, uint256 _minSellAmount) onlyOwner public {&#13;
        founder = _founder;&#13;
        setBuyFee(_buyFeeMilliPercent);&#13;
        setSellFee(_sellFeeMilliPercent);&#13;
        setMinBuyAmount(_minBuyAmount);&#13;
        setMinSellAmount(_minSellAmount);&#13;
    }&#13;
&#13;
    /**&#13;
     * Allow transfer only after crowdsale finished&#13;
     */&#13;
    modifier canTransfer() {&#13;
        require(mintingFinished || msg.sender == founder);&#13;
        _;&#13;
    }&#13;
    &#13;
    function transfer(address _to, uint256 _value) canTransfer public returns(bool) {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns(bool) {&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
}