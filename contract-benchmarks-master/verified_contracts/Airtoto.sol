pragma solidity 0.4.25;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

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
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }
}


/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string name, string symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from,address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}


contract Airtoto is ERC20Pausable, ERC20Detailed, Ownable {
    using SafeMath for uint256;
	uint256 public constant initialSupply = 300000000 * (10 ** uint256(decimals()));
    uint256 public constant sum_bounties_wallet = initialSupply.mul(10).div(100);
    address public constant address_bounties_wallet = 0x5E4C4043A5C96FEFc61F6548FcF14Abc5a92654B;
    uint256 public constant sum_team_wallet = initialSupply.mul(20).div(100);
    address public constant address_team_wallet = 0xDeFb454cB3771C98144CbfC1359Eb7FE2bDd054B;	
    uint256 public constant sum_crowdsale = initialSupply.mul(70).div(100);
	
    constructor () public ERC20Detailed("Airtoto", "Att", 18) {
		_mint(address_bounties_wallet, sum_bounties_wallet);
		_mint(address_team_wallet, sum_team_wallet);
		_mint(msg.sender, sum_crowdsale);		
    }
	
    function transferForICO (address _to, uint256 _value) public onlyOwner{
        _transfer(msg.sender, _to, _value);
    }	
	 /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }
}

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7200171f111d3240">[email protected]</a>?.com&gt;, Eenae &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="60010c05180519200d091802191405134e090f">[email protected]</a>&gt;&#13;
 * @dev If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /// @dev counter to allow mutex lock with only one SSTORE operation&#13;
  uint256 private _guardCounter;&#13;
&#13;
  constructor() internal {&#13;
    // The counter starts at one to prevent changing it from zero to a non-zero&#13;
    // value, which is a more expensive operation.&#13;
    _guardCounter = 1;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * Calling a `nonReentrant` function from another `nonReentrant`&#13;
   * function is not supported. It is possible to prevent this from happening&#13;
   * by making the `nonReentrant` function external, and make it call a&#13;
   * `private` function that does the actual work.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    _guardCounter += 1;&#13;
    uint256 localCounter = _guardCounter;&#13;
    _;&#13;
    require(localCounter == _guardCounter);&#13;
  }&#13;
}&#13;
&#13;
contract Crowdsale is Ownable, ReentrancyGuard {&#13;
&#13;
  using SafeMath for uint256;  &#13;
  &#13;
  Airtoto public token;&#13;
  //IERC20 public token;&#13;
  &#13;
  //start and end timestamps where investments are allowed (both inclusive)&#13;
  uint256 public   startPreICOStage;&#13;
  uint256 public   endPreICOStage;&#13;
  uint256 public   startICOStage1;&#13;
  uint256 public   endICOStage1;  &#13;
  uint256 public   startICOStage2;&#13;
  uint256 public   endICOStage2; &#13;
  uint256 public   startICOStage3;&#13;
  uint256 public   endICOStage3;  &#13;
&#13;
  //balances for softcap&#13;
  mapping(address =&gt; uint256) public balances;  &#13;
  //token distribution&#13;
  uint256 public amountOfTokensSold; &#13;
  uint256 public minimumPayment;  &#13;
  //AirDrop&#13;
  uint256 public valueAirDrop;&#13;
  uint8 public airdropOn;&#13;
  uint8 public referralSystemOn;&#13;
  mapping (address =&gt; uint8) public payedAddress; &#13;
  // rate ETH/USD&#13;
  uint256 public rateETHUSD;    &#13;
  // address where funds are collected&#13;
  address public wallet;&#13;
&#13;
/**&#13;
* event for token Procurement logging&#13;
* @param contributor who Pledged for the tokens&#13;
* @param beneficiary who got the tokens&#13;
* @param value weis Contributed for Procurement&#13;
* @param amount amount of tokens Procured&#13;
*/&#13;
  event TokenProcurement(address indexed contributor, address indexed beneficiary, uint256 value, uint256 amount, address indexed referrer, uint256 amountReferrer);&#13;
&#13;
  constructor() public {    &#13;
    token = createTokenContract();&#13;
	// rate ETH - USD&#13;
    rateETHUSD = 10000; //2 decimals&#13;
    // start and end timestamps where investments are allowed&#13;
    // start/end for stage of ICO&#13;
    startPreICOStage  = 1544875200; //Sat, 15 Dec 2018 12:00:00 +0000&#13;
    endPreICOStage    = 1546084800; //Sat, 29 Dec 2018 12:00:00 +0000	 &#13;
    startICOStage1    = 1546084800; //Sat, 29 Dec 2018 12:00:00 +0000&#13;
    endICOStage1      = 1547294400; //Sat, 12 Jan 2019 12:00:00 +0000&#13;
    startICOStage2    = 1547294400; //Sat, 12 Jan 2019 12:00:00 +0000  &#13;
    endICOStage2      = 1550059200; //Wed, 13 Feb 2019 12:00:00 +0000&#13;
    startICOStage3    = 1550059200; //Wed, 13 Feb 2019 12:00:00 +0000 &#13;
    endICOStage3      = 1552564800; //Thu, 14 Mar 2019 12:00:00 +0000	&#13;
&#13;
    // minimum payment in ETH	&#13;
    minimumPayment = 980000000000000000; // 0.98 ether = ca. 150 USD&#13;
&#13;
    // valueAirDrop in tokens&#13;
    valueAirDrop = 1 * 1 ether;	&#13;
    // address where funds are collected&#13;
    wallet = 0xfc19e8fD7564A48b82a51d106e6D0E6098032811;&#13;
  }&#13;
  &#13;
  function setMinimumPayment(uint256 _minimumPayment) public onlyOwner{&#13;
    minimumPayment = _minimumPayment;&#13;
  } &#13;
  function setValueAirDrop(uint256 _valueAirDrop) public onlyOwner{&#13;
    valueAirDrop = _valueAirDrop;&#13;
  } &#13;
&#13;
  function setRateIco(uint256 _rateETHUSD) public onlyOwner  {&#13;
    rateETHUSD = _rateETHUSD;&#13;
  }  &#13;
  // fallback function can be used to Procure tokens&#13;
  function () external payable {&#13;
    buyTokens(msg.sender);&#13;
  }&#13;
  &#13;
  function createTokenContract() internal returns (Airtoto) {&#13;
    return new Airtoto();&#13;
  }&#13;
  &#13;
  function getRateTokeUSD() public view returns (uint256) {&#13;
    uint256 rate; //6 decimals&#13;
    if (now &gt;= startPreICOStage &amp;&amp; now &lt; endPreICOStage){&#13;
      rate = 100000;    &#13;
    }	&#13;
    if (now &gt;= startICOStage1 &amp;&amp; now &lt; endICOStage1){&#13;
      rate = 100000;    &#13;
    } &#13;
    if (now &gt;= startICOStage2 &amp;&amp; now &lt; endICOStage2){&#13;
      rate = 150000;    &#13;
    }    &#13;
    if (now &gt;= startICOStage3 &amp;&amp; now &lt; endICOStage3){&#13;
      rate = 200000;    &#13;
    }    	&#13;
    return rate;&#13;
  }&#13;
  &#13;
  function getRateIcoWithBonus() public view returns (uint256) {&#13;
    uint256 bonus;&#13;
    if (now &gt;= startPreICOStage &amp;&amp; now &lt; endPreICOStage){&#13;
      bonus = 20;    &#13;
    }&#13;
    if (now &gt;= startICOStage1 &amp;&amp; now &lt; endICOStage1){&#13;
      bonus = 15;    &#13;
    }&#13;
    if (now &gt;= startICOStage2 &amp;&amp; now &lt; endICOStage2){&#13;
      bonus = 10;    &#13;
    }   &#13;
    if (now &gt;= startICOStage3 &amp;&amp; now &lt; endICOStage3){&#13;
      bonus = 5;    &#13;
    }       &#13;
    return rateETHUSD + rateETHUSD.mul(bonus).div(100);&#13;
  }  &#13;
 &#13;
  function bytesToAddress(bytes source) internal pure returns(address) {&#13;
    uint result;&#13;
    uint mul = 1;&#13;
    for(uint i = 20; i &gt; 0; i--) {&#13;
      result += uint8(source[i-1])*mul;&#13;
      mul = mul*256;&#13;
    }&#13;
    return address(result);&#13;
  }&#13;
  function setAirdropOn(uint8 _flag) public onlyOwner{&#13;
    airdropOn = _flag;&#13;
  } &#13;
  function setReferralSystemOn(uint8 _flag) public onlyOwner{&#13;
    referralSystemOn = _flag;&#13;
  }   &#13;
  function buyTokens(address _beneficiary) public nonReentrant payable {&#13;
    uint256 tokensAmount;&#13;
    uint256 weiAmount = msg.value;&#13;
    uint256 rate;&#13;
	uint256 referrerTokens;&#13;
	uint256 restTokensAmount;&#13;
	uint256 restWeiAmount;&#13;
	address referrer; &#13;
    address _this = this;&#13;
    uint256 rateTokenUSD;  &#13;
    require(now &gt;= startPreICOStage);&#13;
    require(now &lt;= endICOStage3);&#13;
	require(token.balanceOf(_this) &gt; 0);&#13;
    require(_beneficiary != address(0));&#13;
	&#13;
	if (weiAmount == 0 &amp;&amp; airdropOn == 1){ &#13;
	  require(payedAddress[_beneficiary] == 0);&#13;
      payedAddress[_beneficiary] = 1;&#13;
	  token.transferForICO(_beneficiary, valueAirDrop);&#13;
	}&#13;
	else{	&#13;
	  require(weiAmount &gt;= minimumPayment);&#13;
      rate = getRateIcoWithBonus();&#13;
	  rateTokenUSD = getRateTokeUSD();&#13;
      tokensAmount = weiAmount.mul(rate).mul(10000).div(rateTokenUSD);&#13;
	  // referral system&#13;
	  if(msg.data.length == 20 &amp;&amp; referralSystemOn == 1) {&#13;
        referrer = bytesToAddress(bytes(msg.data));&#13;
        require(referrer != msg.sender);&#13;
	    // add tokensAmount to the referrer&#13;
        referrerTokens = tokensAmount.mul(5).div(100);&#13;
	    // add tokensAmount to the referral&#13;
	    tokensAmount = tokensAmount + tokensAmount.mul(5).div(100);&#13;
      }&#13;
	  // last sale of tokens&#13;
      if (tokensAmount.add(referrerTokens) &gt; token.balanceOf(_this)) {&#13;
	    restTokensAmount = tokensAmount.add(referrerTokens) - token.balanceOf(_this);&#13;
	    tokensAmount = token.balanceOf(_this);&#13;
	    referrerTokens = 0;&#13;
	    restWeiAmount = restTokensAmount.mul(rateTokenUSD).div(rate).div(10000);&#13;
	  }&#13;
        amountOfTokensSold = amountOfTokensSold.add(tokensAmount);&#13;
	    balances[_beneficiary] = balances[_beneficiary].add(msg.value);&#13;
	  if (referrerTokens != 0){&#13;
        token.transferForICO(referrer, referrerTokens);	  &#13;
	  }&#13;
	  if (restWeiAmount != 0){&#13;
	    _beneficiary.transfer(restWeiAmount);&#13;
		weiAmount = weiAmount.sub(restWeiAmount);&#13;
	  }&#13;
      token.transferForICO(_beneficiary, tokensAmount);&#13;
	  wallet.transfer(weiAmount);&#13;
      emit TokenProcurement(msg.sender, _beneficiary, weiAmount, tokensAmount, referrer, referrerTokens);&#13;
	}&#13;
  }&#13;
  function manualSendTokens(address _to, uint256 _value) public onlyOwner{&#13;
    address _this = this;&#13;
    require(_value &gt; 0);&#13;
	require(_value &lt;= token.balanceOf(_this));&#13;
    require(_to != address(0));&#13;
    amountOfTokensSold = amountOfTokensSold.add(_value);&#13;
    token.transferForICO(_to, _value);&#13;
	emit TokenProcurement(msg.sender, _to, 0, _value, address(0), 0);&#13;
  } &#13;
  function pause() public onlyOwner{&#13;
    token.pause();&#13;
  }&#13;
  function unpause() public onlyOwner{&#13;
    token.unpause();&#13;
  }&#13;
 &#13;
}