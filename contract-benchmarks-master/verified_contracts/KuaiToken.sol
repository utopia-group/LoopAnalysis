pragma solidity ^0.4.11;
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
library DateTime {
        /*
         *  Date and Time utilities for ethereum contracts
         *
         */
        struct MyDateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }
        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;
        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;
        uint16 constant ORIGIN_YEAR = 1970;
        function isLeapYear(uint16 year) constant returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }
        function leapYearsBefore(uint year) constant returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }
        function getDaysInMonth(uint8 month, uint16 year) constant returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }
        function parseTimestamp(uint timestamp) internal returns (MyDateTime dt) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;
                // Year
                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);
                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);
                // Month
                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }
                // Day
                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }
                // Hour
                dt.hour = 0;//getHour(timestamp);
                // Minute
                dt.minute = 0;//getMinute(timestamp);
                // Second
                dt.second = 0;//getSecond(timestamp);
                // Day of week.
                dt.weekday = 0;//getWeekday(timestamp);
        }
        function getYear(uint timestamp) constant returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;
                // Year
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);
                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);
                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }
        function getMonth(uint timestamp) constant returns (uint8) {
                return parseTimestamp(timestamp).month;
        }
        function getDay(uint timestamp) constant returns (uint8) {
                return parseTimestamp(timestamp).day;
        }
        function getHour(uint timestamp) constant returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }
        function getMinute(uint timestamp) constant returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }
        function getSecond(uint timestamp) constant returns (uint8) {
                return uint8(timestamp % 60);
        }
        function toTimestamp(uint16 year, uint8 month, uint8 day) constant returns (uint timestamp) {
                return toTimestamp(year, month, day, 0, 0, 0);
        }
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) constant returns (uint timestamp) {
                uint16 i;
                // Year
                for (i = ORIGIN_YEAR; i < year; i++) {
                        if (isLeapYear(i)) {
                                timestamp += LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                timestamp += YEAR_IN_SECONDS;
                        }
                }
                // Month
                uint8[12] memory monthDayCounts;
                monthDayCounts[0] = 31;
                if (isLeapYear(year)) {
                        monthDayCounts[1] = 29;
                }
                else {
                        monthDayCounts[1] = 28;
                }
                monthDayCounts[2] = 31;
                monthDayCounts[3] = 30;
                monthDayCounts[4] = 31;
                monthDayCounts[5] = 30;
                monthDayCounts[6] = 31;
                monthDayCounts[7] = 31;
                monthDayCounts[8] = 30;
                monthDayCounts[9] = 31;
                monthDayCounts[10] = 30;
                monthDayCounts[11] = 31;
                for (i = 1; i < month; i++) {
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
                }
                // Day
                timestamp += DAY_IN_SECONDS * (day - 1);
                // Hour
                timestamp += HOUR_IN_SECONDS * (hour);
                // Minute
                timestamp += MINUTE_IN_SECONDS * (minute);
                // Second
                timestamp += second;
                return timestamp;
        }
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
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
  function transferOwnership(address newOwner) onlyOwner {
    pendingOwner = newOwner;
  }
  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner {
    owner = pendingOwner;
    pendingOwner = 0x0;
  }
}
contract Operational is Claimable {
    address public operator;
    function Operational(address _operator) {
      operator = _operator;
    }
    modifier onlyOperator() {
      require(msg.sender == operator);
      _;
    }
    function transferOperator(address newOperator) onlyOwner {
      require(newOperator != address(0));
      operator = newOperator;
    }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
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
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
}
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
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
  mapping (address => mapping (address => uint256)) allowed;
  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];
    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {
    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}
/**
 * @title Helps contracts guard agains rentrancy attacks.
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="1361767e707c5321">[email protected]</span>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private rentrancy_lock = false;&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * @notice If you mark a function `nonReentrant`, you should also&#13;
   * mark it `external`. Calling one nonReentrant function from&#13;
   * another is not supported. Instead, you can implement a&#13;
   * `private` function doing the actual work, and a `external`&#13;
   * wrapper marked as `nonReentrant`.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    require(!rentrancy_lock);&#13;
    rentrancy_lock = true;&#13;
    _;&#13;
    rentrancy_lock = false;&#13;
  }&#13;
}&#13;
/**&#13;
 * @title Burnable Token&#13;
 * @dev Token that can be irreversibly burned (destroyed).&#13;
 */&#13;
contract BurnableToken is StandardToken {&#13;
    event Burn(address indexed burner, uint256 value);&#13;
    /**&#13;
     * @dev Burns a specific amount of tokens.&#13;
     * @param _value The amount of token to be burned.&#13;
     */&#13;
    function burn(uint256 _value) public returns (bool) {&#13;
        require(_value &gt; 0);&#13;
        require(_value &lt;= balances[msg.sender]);&#13;
        // no need to require value &lt;= totalSupply, since that would imply the&#13;
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure&#13;
        address burner = msg.sender;&#13;
        balances[burner] = balances[burner].sub(_value);&#13;
        totalSupply = totalSupply.sub(_value);&#13;
        Burn(burner, _value);&#13;
        return true;&#13;
    }&#13;
}&#13;
contract BonusToken is BurnableToken, Operational {&#13;
    using SafeMath for uint;&#13;
    using DateTime for uint256;&#13;
    uint256 public createTime;&#13;
    uint256 standardDecimals = 100000000;&#13;
    uint256 minMakeBonusAmount = standardDecimals.mul(10);&#13;
    function BonusToken(&#13;
                     address operator&#13;
                     ) Operational(operator) {}&#13;
    function makeBonus(address[] _to, uint256[] _bonus) onlyOperator returns(bool) {&#13;
        for(uint i = 0; i &lt; _to.length; i++){&#13;
            require(transfer(_to[i], _bonus[i]));&#13;
        }&#13;
        return true;&#13;
    }&#13;
}&#13;
contract KuaiMintableToken is BonusToken {&#13;
    uint256 public standardDailyLimit; // maximum amount of token can mint per day&#13;
    uint256 public dailyLimitLeft = standardDecimals.mul(1000000); // daily limit left&#13;
    uint256 public lastMintTime = 0;&#13;
    event Mint(address indexed operator, uint256 value, uint256 mintTime);&#13;
    event SetDailyLimit(address indexed operator, uint256 time);&#13;
    function KuaiMintableToken(&#13;
                    address operator,&#13;
                    uint256 _dailyLimit&#13;
                ) BonusToken(operator) {&#13;
        totalSupply = 0;&#13;
        createTime = now;&#13;
        lastMintTime = createTime;&#13;
        standardDailyLimit = standardDecimals.mul(_dailyLimit);&#13;
    }&#13;
    // mint mintAmount token&#13;
    function mint(uint256 mintAmount) onlyOperator returns(uint256 _actualRelease) {&#13;
        require(!judgeIsReachDailyLimit(mintAmount, timestamp));&#13;
        uint256 timestamp = now;&#13;
        balances[owner] = balances[owner].add(mintAmount);&#13;
        totalSupply = totalSupply.add(mintAmount);&#13;
        Mint(msg.sender, mintAmount, timestamp);&#13;
        return mintAmount;&#13;
    }&#13;
    function judgeIsReachDailyLimit(uint256 mintAmount, uint256 timestamp) internal returns(bool _exist) {&#13;
        bool reached = false;&#13;
        if (dailyLimitLeft &gt; 0) {&#13;
            if ((timestamp.parseTimestamp().year == lastMintTime.parseTimestamp().year)&#13;
                &amp;&amp; (timestamp.parseTimestamp().month == lastMintTime.parseTimestamp().month)&#13;
                &amp;&amp; (timestamp.parseTimestamp().day == lastMintTime.parseTimestamp().day)) {&#13;
                if (dailyLimitLeft &lt; mintAmount) {&#13;
                    reached = true;&#13;
                } else {&#13;
                    dailyLimitLeft = dailyLimitLeft.sub(mintAmount);&#13;
                    lastMintTime = timestamp;&#13;
                }&#13;
            } else {&#13;
                dailyLimitLeft = standardDailyLimit;&#13;
                lastMintTime = timestamp;&#13;
                if (dailyLimitLeft &lt; mintAmount) {&#13;
                    reached = true;&#13;
                } else {&#13;
                    dailyLimitLeft = dailyLimitLeft.sub(mintAmount);&#13;
                }&#13;
            }&#13;
        }&#13;
        return reached;&#13;
    }&#13;
    // set standard daily limit&#13;
    function setDailyLimit(uint256 _dailyLimit) onlyOwner returns(bool){&#13;
        standardDailyLimit = _dailyLimit;&#13;
        SetDailyLimit(msg.sender, now);&#13;
        return true;&#13;
    }&#13;
}&#13;
contract KuaiToken is KuaiMintableToken {&#13;
    string public standard = '2017122806';&#13;
    string public name = 'KuaiToken';&#13;
    string public symbol = 'KT';&#13;
    uint8 public decimals = 8;&#13;
    function KuaiToken(&#13;
                    address operator,&#13;
                    uint256 dailyLimit&#13;
                     ) KuaiMintableToken(operator, dailyLimit) {}&#13;
}