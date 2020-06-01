pragma solidity ^0.4.24;

// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: contracts/Ownable.sol

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
    require(msg.sender == owner, "msg.sender not owner");
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
    require(_newOwner != address(0), "_newOwner == 0");
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
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
    require(!paused, "The contract is paused");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused, "The contract is not paused");
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

// File: contracts/Destructible.sol

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

// File: contracts/ERC20Supplier.sol

/**
 * @title ERC20Supplier.
 * @author Andrea Speziale <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="dfbeacafbaa5b6beb3ba9fbab6bbb0b0f1b6b0">[email protected]</a>&gt;&#13;
 * @dev Distribute a fixed amount of ERC20 based on a rate rate from a ERC20 reserve to a _receiver for ETH.&#13;
 * Received ETH are redirected to a wallet.&#13;
 */&#13;
contract ERC20Supplier is&#13;
  Pausable,&#13;
  Destructible&#13;
{&#13;
  using SafeMath for uint;&#13;
&#13;
  ERC20 public token;&#13;
  &#13;
  address public wallet;&#13;
  address public reserve;&#13;
  &#13;
  uint public rate;&#13;
&#13;
  event LogWithdrawAirdrop(address indexed _from, address indexed _token, uint amount);&#13;
  event LogReleaseTokensTo(address indexed _from, address indexed _to, uint _amount);&#13;
  event LogSetWallet(address indexed _wallet);&#13;
  event LogSetReserve(address indexed _reserve);&#13;
  event LogSetToken(address indexed _token);&#13;
  event LogSetrate(uint _rate);&#13;
&#13;
  /**&#13;
   * @dev Contract constructor.&#13;
   * @param _wallet Where the received ETH are transfered.&#13;
   * @param _reserve From where the ERC20 token are sent to the purchaser.&#13;
   * @param _token Deployed ERC20 token address.&#13;
   * @param _rate Purchase rate, how many ERC20 for the given ETH.&#13;
   */&#13;
  constructor(&#13;
    address _wallet,&#13;
    address _reserve,&#13;
    address _token,&#13;
    uint _rate&#13;
  )&#13;
    public&#13;
  {&#13;
    require(_wallet != address(0), "_wallet == address(0)");&#13;
    require(_reserve != address(0), "_reserve == address(0)");&#13;
    require(_token != address(0), "_token == address(0)");&#13;
    require(_rate != 0, "_rate == 0");&#13;
    wallet = _wallet;&#13;
    reserve = _reserve;&#13;
    token = ERC20(_token);&#13;
    rate = _rate;&#13;
  }&#13;
&#13;
  function() public payable {&#13;
    releaseTokensTo(msg.sender);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Release purchased ERC20 to the buyer.&#13;
   * @param _receiver Where the ERC20 are transfered.&#13;
   */&#13;
  function releaseTokensTo(address _receiver)&#13;
    internal&#13;
    whenNotPaused&#13;
    returns (bool) &#13;
  {&#13;
    uint amount = msg.value.mul(rate);&#13;
    wallet.transfer(msg.value);&#13;
    require(&#13;
      token.transferFrom(reserve, _receiver, amount),&#13;
      "transferFrom reserve to _receiver failed"&#13;
    );&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Set wallet.&#13;
   * @param _wallet Where the ETH are redirected.&#13;
   */&#13;
  function setWallet(address _wallet) public onlyOwner returns (bool) {&#13;
    require(_wallet != address(0), "_wallet == 0");&#13;
    require(_wallet != wallet, "_wallet == wallet");&#13;
    wallet = _wallet;&#13;
    emit LogSetWallet(wallet);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Set ERC20 reserve.&#13;
   * @param _reserve Where ERC20 are stored.&#13;
   */&#13;
  function setReserve(address _reserve) public onlyOwner returns (bool) {&#13;
    require(_reserve != address(0), "_reserve == 0");&#13;
    require(_reserve != reserve, "_reserve == reserve");&#13;
    reserve = _reserve;&#13;
    emit LogSetReserve(reserve);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Set ERC20 token.&#13;
   * @param _token ERC20 token address.&#13;
   */&#13;
  function setToken(address _token) public onlyOwner returns (bool) {&#13;
    require(_token != address(0), "_token == 0");&#13;
    require(_token != address(token), "_token == token");&#13;
    token = ERC20(_token);&#13;
    emit LogSetToken(token);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Set rate.&#13;
   * @param _rate Multiplier, how many ERC20 for the given ETH.&#13;
   */&#13;
  function setRate(uint _rate) public onlyOwner returns (bool) {&#13;
    require(_rate != 0, "_rate == 0");&#13;
    require(_rate != rate, "_rate == rate");&#13;
    rate = _rate;&#13;
    emit LogSetrate(rate);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Eventually withdraw airdropped token.&#13;
   * @param _token ERC20 address to be withdrawed.&#13;
   */&#13;
  function withdrawAirdrop(ERC20 _token)&#13;
    public&#13;
    onlyOwner&#13;
    returns(bool)&#13;
  {&#13;
    require(address(_token) != 0, "_token address == 0");&#13;
    require(&#13;
      _token.balanceOf(this) &gt; 0,&#13;
      "dropped token balance == 0"&#13;
    );&#13;
    uint256 airdroppedTokenAmount = _token.balanceOf(this);&#13;
    _token.transfer(msg.sender, airdroppedTokenAmount);&#13;
    emit LogWithdrawAirdrop(msg.sender, _token, airdroppedTokenAmount);&#13;
    return true;&#13;
  }&#13;
}