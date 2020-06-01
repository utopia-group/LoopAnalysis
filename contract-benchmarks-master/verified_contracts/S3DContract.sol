pragma solidity ^0.4.16;


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
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath32 {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint32 a, uint32 b) internal pure returns (uint32) {
    if (a == 0) {
      return 0;
    }
    uint32 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint32 a, uint32 b) internal pure returns (uint32) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint32 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint32 a, uint32 b) internal pure returns (uint32) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath8 {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint8 a, uint8 b) internal pure returns (uint8) {
    if (a == 0) {
      return 0;
    }
    uint8 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint8 a, uint8 b) internal pure returns (uint8) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint8 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint8 a, uint8 b) internal pure returns (uint8) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint8 a, uint8 b) internal pure returns (uint8) {
    uint8 c = a + b;
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
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[msg.sender]);
    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
  
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) internal allowed;
  
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    
    emit Transfer(_from, _to, _value);
    return true;
  }
  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = false;
 
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  
  modifier whenPaused() {
    require(paused);
    _;
  }
 
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }
  
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract PausableToken is StandardToken, Pausable {
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }
}
/**
 * 
 * @author <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b4c1d7dcdddcd599ddc0d5d7dcddf4d9d5ddd89ad7dbd9">[email protected]</a>&#13;
 * &#13;
 */&#13;
contract S3DContract is Ownable, PausableToken {&#13;
    &#13;
    modifier shareholderOnly {&#13;
        require(balances[msg.sender] &gt; 0);&#13;
        _;&#13;
    }&#13;
    &#13;
    modifier acceptDividend {&#13;
        require(address(this).balance &gt;= 1 ether);&#13;
        require(block.number - lastDivideBlock &gt;= freezenBlocks);&#13;
        _;&#13;
    }&#13;
    &#13;
    using SafeMath for uint256;&#13;
    &#13;
    string public name = 'Share of Lottery Token';&#13;
    string public symbol = 'SLT';&#13;
    string public version = '1.0.2';&#13;
    uint8 public decimals = 0;&#13;
    bool public ico = true;&#13;
    uint256 public ico_price = 0.1 ether;&#13;
    uint8 public ico_percent = 20;&#13;
    uint256 public ico_amount = 0;&#13;
    uint256 public initShares ;&#13;
    uint256 public totalShare = 0;&#13;
    &#13;
    event ReciveEth(address _from, uint amount);&#13;
    event SendBouns(uint _amount);&#13;
    event MyProfitRecord(address _addr, uint _amount);&#13;
    &#13;
    event ReciveFound(address _from, uint amount);&#13;
    event TransferFound(address _to, uint amount);&#13;
    event TransferShareFail(address _to, uint amount);&#13;
    &#13;
    uint256 lastDivideBlock;&#13;
    uint freezenBlocks =  5990;&#13;
    &#13;
    address[] accounts;&#13;
    &#13;
    constructor (uint256 initialSupply) public {&#13;
        totalSupply = initialSupply * 10 ** uint256(decimals);&#13;
        initShares = totalSupply;&#13;
        balances[msg.sender] = totalSupply;&#13;
        accounts.push(msg.sender);&#13;
    }&#13;
    &#13;
    function setIcoPrice(uint256 _price) external onlyOwner {&#13;
        require(_price &gt; 0);&#13;
        ico_price = _price;&#13;
    }&#13;
    &#13;
    &#13;
    function setIcoStatus(bool _flag) external onlyOwner {&#13;
        ico = _flag;&#13;
    }&#13;
    &#13;
    // Sell Shares&#13;
    function buy() external payable {&#13;
        require(ico);&#13;
        require(msg.value &gt; 0 &amp;&amp; msg.value % ico_price == 0);&#13;
        uint256 shares = msg.value.div(ico_price);&#13;
        require(ico_amount.add(shares) &lt;= initShares.div(100).mul(ico_percent));&#13;
        &#13;
        emit ReciveFound(msg.sender, msg.value);&#13;
        balances[msg.sender] = balances[msg.sender].add(shares);&#13;
        totalSupply = totalSupply.add(shares.mul(10 ** decimals));&#13;
        ico_amount = ico_amount.add(shares);&#13;
        owner.transfer(msg.value);&#13;
        emit TransferFound(owner, msg.value);&#13;
    }&#13;
    &#13;
    // Cash Desk&#13;
    function () public payable {&#13;
        emit ReciveEth(msg.sender, msg.value);&#13;
    }&#13;
    &#13;
    function sendBouns() external acceptDividend shareholderOnly {&#13;
        _sendBonus();&#13;
        &#13;
    }&#13;
    &#13;
    // dispatch bouns&#13;
    function _sendBonus() internal {&#13;
        // caculate bouns&#13;
        lastDivideBlock = block.number;&#13;
        uint256 total = address(this).balance;&#13;
        address[] memory _accounts = accounts;&#13;
        // do&#13;
        for (uint i =0; i &lt; _accounts.length; i++) {&#13;
            if (balances[_accounts[i]] &gt; 0) {&#13;
                uint256 interest = total.div(totalSupply).mul(balances[_accounts[i]]);&#13;
                if (interest &gt; 0) {&#13;
                    if (_accounts[i].send(interest)) {&#13;
                        emit MyProfitRecord(_accounts[i], interest);&#13;
                    }&#13;
                }&#13;
            }&#13;
        }&#13;
        totalShare.add(total);&#13;
        emit SendBouns(total);&#13;
    }&#13;
    &#13;
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
        if (super.transfer(_to, _value)) {&#13;
            _addAccount(_to);&#13;
        }&#13;
    }&#13;
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
        if  (super.transferFrom(_from, _to, _value)) {&#13;
            _addAccount(_to);&#13;
        }&#13;
    }&#13;
    &#13;
    function _addAccount(address _addr) internal returns(bool) {&#13;
        address[] memory _accounts = accounts;&#13;
        for (uint i = 0; i &lt; _accounts.length; i++) {&#13;
            if (_accounts[i] == _addr) {&#13;
                return false;&#13;
            }&#13;
        }&#13;
        accounts.push(_addr);&#13;
        return true;&#13;
    }&#13;
    &#13;
    &#13;
    function addAccount(address _addr) external onlyOwner {&#13;
        _addAccount(_addr);&#13;
    }&#13;
}