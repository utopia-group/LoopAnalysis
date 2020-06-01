pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20 _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {
  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}
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
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
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
  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

/**
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="e694838b8589a6d4">[email protected]</span>π.com&gt;&#13;
 * @dev Should contracts (anything Ownable) end up being owned by this contract, it allows the owner&#13;
 * of this contract to reclaim ownership of the contracts.&#13;
 */&#13;
contract HasNoContracts is Ownable {&#13;
&#13;
  /**&#13;
   * @dev Reclaim ownership of Ownable contracts&#13;
   * @param _contractAddr The address of the Ownable to be reclaimed.&#13;
   */&#13;
  function reclaimContract(address _contractAddr) external onlyOwner {&#13;
    Ownable contractInst = Ownable(_contractAddr);&#13;
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
  using SafeERC20 for ERC20;&#13;
&#13;
  /**&#13;
   * @dev Reclaim all ERC20 compatible tokens&#13;
   * @param _token ERC20 The address of the token contract&#13;
   */&#13;
  function reclaimToken(ERC20 _token) external onlyOwner {&#13;
    uint256 balance = _token.balanceOf(this);&#13;
    _token.safeTransfer(owner, balance);&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * Automated buy back BOB tokens&#13;
 */&#13;
contract BobBuyback is Claimable, HasNoContracts, CanReclaimToken, Destructible {&#13;
    using SafeMath for uint256;    &#13;
&#13;
    ERC20 public token;                 //Address of BOB token contract&#13;
    uint256 public maxGasPrice;         //Highest gas price allowed for buyback transaction&#13;
    uint256 public maxTxValue;          //Highest amount of BOB sent in one transaction&#13;
    uint256 public roundStartTime;      //Timestamp when buyback starts (timestamp of the first block where buyback allowed)&#13;
    uint256 public rate;                //1 ETH = rate BOB&#13;
&#13;
    event Buyback(address indexed from, uint256 amountBob, uint256 amountEther);&#13;
&#13;
    constructor(ERC20 _token, uint256 _maxGasPrice, uint256 _maxTxValue) public {&#13;
        token = _token;&#13;
        maxGasPrice = _maxGasPrice;&#13;
        maxTxValue = _maxTxValue;&#13;
        roundStartTime = 0;&#13;
        rate = 0;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Somebody may call this to sell his tokens&#13;
     * @param _amount How much tokens to sell&#13;
     * Call to token.approve() required before calling this function&#13;
     */&#13;
    function buyback(uint256 _amount) external {&#13;
        require(tx.gasprice &lt;= maxGasPrice);&#13;
        require(_amount &lt;= maxTxValue);&#13;
        require(isRunning());&#13;
&#13;
        uint256 amount = _amount;&#13;
        uint256 reward = calcReward(amount);&#13;
&#13;
        if(address(this).balance &lt; reward) {&#13;
            //If not enough money to fill request, handle it partially&#13;
            reward = address(this).balance;&#13;
            amount = reward.mul(rate);&#13;
        }&#13;
&#13;
        require(token.transferFrom(msg.sender, address(this), amount));&#13;
        msg.sender.transfer(reward);&#13;
        emit Buyback(msg.sender, amount, reward);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Calculates how much ETH somebody can receive for selling amount BOB&#13;
     * @param amount How much tokens to sell&#13;
     */&#13;
    function calcReward(uint256 amount) view public returns(uint256) {&#13;
        if(rate == 0) return 0;     //Handle situation when no Buyback is planned&#13;
        return amount.div(rate);    //This operation may result in rounding. Which is fine here (rounded  amount &lt; rate / 10**18)&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Calculates how much BOB tokens this contract can buy (during current buyback round)&#13;
     */&#13;
    function calcTokensAvailableToBuyback() view public returns(uint256) {&#13;
        return address(this).balance.mul(rate);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Checks if Buyback round is running&#13;
     */&#13;
    function isRunning() view public returns(bool) {&#13;
        return (rate &gt; 0) &amp;&amp; (now &gt;= roundStartTime) &amp;&amp; (address(this).balance &gt; 0);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Changes buyback parameters&#13;
     * @param _maxGasPrice Max gas price one ca use to sell is tokens. &#13;
     * @param _maxTxValue Max amount of tokens to sell in one transaction&#13;
     */&#13;
    function setup(uint256 _maxGasPrice, uint256 _maxTxValue) onlyOwner external {&#13;
        maxGasPrice = _maxGasPrice;&#13;
        maxTxValue = _maxTxValue;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Starts buyback at specified time, with specified rate&#13;
     * @param _roundStartTime Time when Buyback round starts&#13;
     * @param _rate Rate of current Buyback round (1 ETH = rate BOB). Zero means no buyback is planned.&#13;
     */&#13;
    function startBuyback(uint256 _roundStartTime, uint256 _rate) onlyOwner external payable {&#13;
        require(_roundStartTime &gt; now);&#13;
        roundStartTime = _roundStartTime;&#13;
        rate = _rate;   //Rate is not required to be &gt; 0&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Claim all BOB tokens stored on the contract and send them to owner&#13;
     */&#13;
    function claimTokens() onlyOwner external {&#13;
        require(token.transfer(owner, token.balanceOf(address(this))));&#13;
    }&#13;
    /**&#13;
     * @notice Claim some of tokens stored on the contract&#13;
     * @param amount How much tokens to claim&#13;
     * @param beneficiary Who to send this tokens&#13;
     */&#13;
    function claimTokens(uint256 amount, address beneficiary) onlyOwner external {&#13;
        require(token.transfer(beneficiary, amount));&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Transfer all Ether held by the contract to the owner.&#13;
    */&#13;
    function reclaimEther()  onlyOwner external {&#13;
        owner.transfer(address(this).balance);&#13;
    }&#13;
&#13;
}