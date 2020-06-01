pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
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
  function totalSupply() public view returns (uint256);
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
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address internal owner;

  event OwnershipRenounced(address indexed previousOwner);
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

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
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
  event MintFinished();
  event MintStarted();
 
  bool public mintingFinished = false;
 
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
 
  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
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
  function finishMinting() public onlyOwner returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
  
  /**
   * @dev Function to start minting new tokens.
   * @return True if the operation was successful.
   */
  function startMinting() public onlyOwner returns (bool) {
    mintingFinished = false;
    emit MintStarted();
    return true;
  }
  
}

contract KassotBasicToken is MintableToken {
    
  string public constant name = "Kassot Token";  
  string public constant symbol = "KATOK";  
  uint8 public constant decimals = 18;
  
  uint public constant decimalMultiply = 1000000000000000000;  
  
}
 
/*
 * @title KassotToken
 * @dev Kassot token crowdsale contract
 * @dev Author: Alexander Kazorin <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0b6a606a71647962654b6c666a626725686466">[email protected]</a>&gt;&#13;
 */ &#13;
contract KassotToken is ERC20, Ownable {&#13;
  &#13;
  using SafeMath for uint;&#13;
  &#13;
  bool public saleFinished = false;&#13;
  address internal multisig;&#13;
  address internal restricted;&#13;
  uint public restrictedPercent;&#13;
  uint public hardcap;&#13;
  uint public softcap;&#13;
  uint public firstBonusPercent;&#13;
  uint public secondBonusPercent;&#13;
  uint public thirdBonusPercent;&#13;
  uint public rate;                       // Price (%rate% KST = 1 ETH)&#13;
  uint public currentRound;&#13;
  bool public allowRefund = false;        // Set to true if under softcap&#13;
  KassotBasicToken internal token = new KassotBasicToken();&#13;
  mapping (uint =&gt; mapping (address =&gt; uint)) public balances;&#13;
  mapping(uint =&gt; uint) internal bonuses;&#13;
  mapping(uint =&gt; uint) internal amounts;&#13;
&#13;
  constructor(address _multisig, address _restricted) public {&#13;
    multisig = _multisig;&#13;
    restricted = _restricted;&#13;
    &#13;
    // Settings for first round&#13;
    restrictedPercent = 10;&#13;
    hardcap = 900 * 1 ether;&#13;
    softcap = 30 * 1 ether;&#13;
    rate = 112600 * token.decimalMultiply();&#13;
    currentRound = 1;&#13;
    firstBonusPercent = 50;&#13;
    secondBonusPercent = 25;&#13;
    thirdBonusPercent = 10;&#13;
  }&#13;
&#13;
  modifier saleIsOn() {&#13;
    require(!saleFinished);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier isUnderHardCap() {&#13;
    require(address(this).balance &lt;= hardcap);&#13;
    _;&#13;
  }&#13;
  &#13;
  // ERC20 Inteface methods&#13;
  function name() public view returns (string) {&#13;
    return token.name();&#13;
  }&#13;
  &#13;
  function symbol() public view returns (string) {&#13;
    return token.symbol();&#13;
  }&#13;
  &#13;
  function decimals() public view returns (uint8) {&#13;
    return token.decimals();&#13;
  }&#13;
  &#13;
  function totalSupply() public view returns (uint256) {&#13;
    return token.totalSupply();&#13;
  }&#13;
&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    return token.transfer(_to, _value);&#13;
  }&#13;
&#13;
  function balanceOf(address _owner) public view returns (uint256) {&#13;
    return token.balanceOf(_owner);&#13;
  }&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
    return token.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  function approve(address _spender, uint256 _value) public returns (bool) {&#13;
    return token.approve(_spender, _value);&#13;
  }&#13;
&#13;
  function allowance(address _owner, address _spender) public view returns (uint256) {&#13;
    return token.allowance(_owner, _spender);&#13;
  }&#13;
  // End of ERC20 Inteface methods&#13;
&#13;
  function setMultisig(address _multisig) public onlyOwner returns (bool) {&#13;
    multisig = _multisig;&#13;
    return true;&#13;
  }&#13;
  &#13;
  function setRestricted(address _restricted) public onlyOwner returns (bool) {&#13;
    restricted = _restricted;&#13;
    return true;&#13;
  }&#13;
  &#13;
  function setRestrictedPercent(uint _restrictedPercent) public onlyOwner returns (bool) {&#13;
    restrictedPercent = _restrictedPercent;&#13;
    return true;&#13;
  }&#13;
  &#13;
  function setHardcap(uint _hardcap) public onlyOwner returns (bool) {&#13;
    hardcap = _hardcap;&#13;
    return true;&#13;
  }&#13;
  &#13;
  function setSoftcap(uint _softcap) public onlyOwner returns (bool) {&#13;
    softcap = _softcap;&#13;
    return true;&#13;
  }&#13;
  &#13;
  function setRate(uint _rate) public onlyOwner returns (bool) {&#13;
    rate = _rate;&#13;
    return true;&#13;
  }&#13;
  &#13;
  function setCurrentRound(uint _currentRound) public onlyOwner returns (bool) {&#13;
    currentRound = _currentRound;&#13;
    return true;&#13;
  }&#13;
  &#13;
  function setFirstBonusPercent(uint _firstBonusPercent) public onlyOwner returns (bool) {&#13;
    firstBonusPercent = _firstBonusPercent;&#13;
    return true;&#13;
  }&#13;
  &#13;
  function setSecondBonusPercent(uint _secondBonusPercent) public onlyOwner returns (bool) {&#13;
    secondBonusPercent = _secondBonusPercent;&#13;
    return true;&#13;
  }&#13;
  &#13;
  function setThirdBonusPercent(uint _thirdBonusPercent) public onlyOwner returns (bool) {&#13;
    thirdBonusPercent = _thirdBonusPercent;&#13;
    return true;&#13;
  }&#13;
  &#13;
  function getMultisig() public view onlyOwner returns (address) {&#13;
    // only owner can show address for safety reasons&#13;
    return multisig;&#13;
  }&#13;
  &#13;
  function getRestricted() public view onlyOwner returns (address) {&#13;
    // only owner can show address for safety reasons&#13;
    return restricted;&#13;
  }&#13;
&#13;
  function refund() public {&#13;
    require(allowRefund);&#13;
    uint value = balances[currentRound][msg.sender]; &#13;
    balances[currentRound][msg.sender] = 0; &#13;
    msg.sender.transfer(value); &#13;
  }&#13;
&#13;
  function finishSale() public onlyOwner {&#13;
    if (address(this).balance &gt; softcap) {&#13;
      multisig.transfer(address(this).balance);&#13;
      uint issuedTokenSupply = token.totalSupply();&#13;
      uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100);&#13;
      token.mint(restricted, restrictedTokens);&#13;
    } else {&#13;
      allowRefund = true;&#13;
    }&#13;
    token.finishMinting();&#13;
    saleFinished = true;&#13;
  }&#13;
  &#13;
  function startSale() public onlyOwner {&#13;
    token.startMinting();&#13;
    allowRefund = false;&#13;
    saleFinished = false;&#13;
  }&#13;
&#13;
  function calculateTokens(uint _amount, uint _stage, uint _stageAmount) public returns (uint) {&#13;
    bonuses[1] = firstBonusPercent;&#13;
    bonuses[2] = secondBonusPercent;&#13;
    bonuses[3] = thirdBonusPercent;&#13;
    bonuses[4] = 0;&#13;
    &#13;
    amounts[1] = 0;&#13;
    amounts[2] = 0;&#13;
    amounts[3] = 0;&#13;
    amounts[4] = 0;&#13;
    &#13;
    int amount = int(_amount);&#13;
    &#13;
    uint i = _stage;&#13;
    while (amount &gt; 0) {&#13;
      if (i &gt; 3) {&#13;
        amounts[i] = uint(amount);&#13;
        break;&#13;
      }&#13;
      if (amount - int(_stageAmount) &gt; 0) {&#13;
        amounts[i] = _stageAmount;&#13;
        amount -= int(_stageAmount);&#13;
        i++;&#13;
      } else {&#13;
        amounts[i] = uint(amount);&#13;
        break;&#13;
      }&#13;
    }&#13;
    &#13;
    uint tokens = 0;&#13;
    uint bonusTokens = 0;&#13;
    uint _tokens = 0;&#13;
    for (i = _stage; i &lt;= 4; i++) {&#13;
      if (amounts[i] == 0) {&#13;
        break;&#13;
      }&#13;
      _tokens = rate.mul(amounts[i]).div(1 ether);&#13;
      bonusTokens = _tokens * bonuses[i] / 100;&#13;
      tokens += _tokens + bonusTokens;&#13;
    }&#13;
    &#13;
    return tokens;&#13;
  }&#13;
  &#13;
  function createTokens() public isUnderHardCap saleIsOn payable {&#13;
    uint amount = msg.value;&#13;
    uint tokens = 0;    &#13;
    uint stageAmount = hardcap.div(4);&#13;
    &#13;
    if (address(this).balance &lt;= stageAmount) {&#13;
      tokens = calculateTokens(amount, 1, stageAmount);&#13;
    } else if (address(this).balance &lt;= stageAmount * 2) {&#13;
      tokens = calculateTokens(amount, 2, stageAmount);&#13;
    } else if (address(this).balance &lt;= stageAmount * 3) {&#13;
      tokens = calculateTokens(amount, 3, stageAmount);&#13;
    } else {&#13;
      tokens = calculateTokens(amount, 4, stageAmount);&#13;
    }&#13;
    &#13;
    token.mint(msg.sender, tokens);&#13;
    balances[currentRound][msg.sender] = balances[currentRound][msg.sender].add(amount);&#13;
  }&#13;
&#13;
  function() external payable {&#13;
    createTokens();&#13;
  }&#13;
  &#13;
}