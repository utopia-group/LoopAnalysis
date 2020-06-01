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
        function isLeapYear(uint16 year) internal pure returns (bool) {
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
        function leapYearsBefore(uint year) internal pure returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }
        function getDaysInMonth(uint8 month, uint16 year) internal pure returns (uint8) {
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
        function parseTimestamp(uint timestamp) internal pure returns (MyDateTime dt) {
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
        function getYear(uint timestamp) internal pure returns (uint16) {
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
        function getMonth(uint timestamp) internal pure returns (uint8) {
                return parseTimestamp(timestamp).month;
        }
        function getDay(uint timestamp) internal pure returns (uint8) {
                return parseTimestamp(timestamp).day;
        }
        function getHour(uint timestamp) internal pure returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }
        function getMinute(uint timestamp) internal pure returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }
        function getSecond(uint timestamp) internal pure returns (uint8) {
                return uint8(timestamp % 60);
        }
        function toTimestamp(uint16 year, uint8 month, uint8 day) internal pure returns (uint timestamp) {
                return toTimestamp(year, month, day, 0, 0, 0);
        }
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) internal pure returns (uint timestamp) {
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
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }
  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
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
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="097b6c646a66493b">[email protected]</span>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private reentrancy_lock = false;&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * @notice If you mark a function `nonReentrant`, you should also&#13;
   * mark it `external`. Calling one nonReentrant function from&#13;
   * another is not supported. Instead, you can implement a&#13;
   * `private` function doing the actual work, and a `external`&#13;
   * wrapper marked as `nonReentrant`.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    require(!reentrancy_lock);&#13;
    reentrancy_lock = true;&#13;
    _;&#13;
    reentrancy_lock = false;&#13;
  }&#13;
}&#13;
/**&#13;
 * @title Burnable Token&#13;
 * @dev Token that can be irreversibly burned (destroyed).&#13;
 */&#13;
contract StandardBurnableToken is StandardToken {&#13;
    event Burn(address indexed burner, uint256 value);&#13;
    /**&#13;
     * @dev Burns a specific amount of tokens.&#13;
     * @param _value The amount of token to be burned.&#13;
     */&#13;
    function burn(uint256 _value) public returns (bool) {&#13;
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
contract Operational is Claimable {&#13;
    address public operator;&#13;
    function Operational(address _operator) public {&#13;
      operator = _operator;&#13;
    }&#13;
    modifier onlyOperator() {&#13;
      require(msg.sender == operator);&#13;
      _;&#13;
    }&#13;
    function transferOperator(address newOperator) public onlyOwner {&#13;
      require(newOperator != address(0));&#13;
      operator = newOperator;&#13;
    }&#13;
}&#13;
contract Frozenable is Operational, StandardBurnableToken, ReentrancyGuard {&#13;
    struct FrozenBalance {&#13;
        address owner;&#13;
        uint256 value;&#13;
        uint256 unfreezeTime;&#13;
    }&#13;
    mapping (uint =&gt; FrozenBalance) public frozenBalances;&#13;
    uint public frozenBalanceCount;&#13;
    uint256 mulDecimals = 100000000; // match decimals&#13;
    event SystemFreeze(address indexed owner, uint256 value, uint256 unfreezeTime);&#13;
    event Unfreeze(address indexed owner, uint256 value, uint256 unfreezeTime);&#13;
    event TransferSystemFreeze(address indexed owner, uint256 value, uint256 time);&#13;
    function Frozenable(address _operator) Operational(_operator) public {}&#13;
    // freeze system' balance&#13;
    function systemFreeze(uint256 _value, uint256 _unfreezeTime) internal {&#13;
        balances[owner] = balances[owner].sub(_value);&#13;
        frozenBalances[frozenBalanceCount] = FrozenBalance({owner: owner, value: _value, unfreezeTime: _unfreezeTime});&#13;
        frozenBalanceCount++;&#13;
        SystemFreeze(owner, _value, _unfreezeTime);&#13;
    }&#13;
    // get frozen balance&#13;
    function frozenBalanceOf(address _owner) public constant returns (uint256 value) {&#13;
        for (uint i = 0; i &lt; frozenBalanceCount; i++) {&#13;
            FrozenBalance storage frozenBalance = frozenBalances[i];&#13;
            if (_owner == frozenBalance.owner) {&#13;
                value = value.add(frozenBalance.value);&#13;
            }&#13;
        }&#13;
        return value;&#13;
    }&#13;
    // unfreeze frozen amount&#13;
    // everyone can call this function to unfreeze balance&#13;
    function unfreeze() public returns (uint256 releaseAmount) {&#13;
        uint index = 0;&#13;
        while (index &lt; frozenBalanceCount) {&#13;
            if (now &gt;= frozenBalances[index].unfreezeTime) {&#13;
                releaseAmount += frozenBalances[index].value;&#13;
                unfreezeBalanceByIndex(index);&#13;
            } else {&#13;
                index++;&#13;
            }&#13;
        }&#13;
        return releaseAmount;&#13;
    }&#13;
    function unfreezeBalanceByIndex(uint index) internal {&#13;
        FrozenBalance storage frozenBalance = frozenBalances[index];&#13;
        balances[frozenBalance.owner] = balances[frozenBalance.owner].add(frozenBalance.value);&#13;
        Unfreeze(frozenBalance.owner, frozenBalance.value, frozenBalance.unfreezeTime);&#13;
        frozenBalances[index] = frozenBalances[frozenBalanceCount - 1];&#13;
        delete frozenBalances[frozenBalanceCount - 1];&#13;
        frozenBalanceCount--;&#13;
    }&#13;
    function transferSystemFreeze() internal {&#13;
        uint256 totalTransferSysFreezeAmount = 0;&#13;
        for (uint i = 0; i &lt; frozenBalanceCount; i++) {&#13;
            frozenBalances[i].owner = owner;&#13;
            totalTransferSysFreezeAmount += frozenBalances[i].value;&#13;
        }&#13;
        TransferSystemFreeze(owner, totalTransferSysFreezeAmount, now);&#13;
    }&#13;
}&#13;
contract Releaseable is Frozenable {&#13;
    using SafeMath for uint;&#13;
    using DateTime for uint256;&#13;
    uint256 public createTime;&#13;
    uint256 public standardReleaseAmount = mulDecimals.mul(1024000); //&#13;
    uint256 public releaseAmountPerDay = mulDecimals.mul(1024000);&#13;
    uint256 public releasedSupply = 0;&#13;
    event Release(address indexed receiver, uint256 value, uint256 sysAmount, uint256 releaseTime);&#13;
    struct ReleaseRecord {&#13;
        uint256 amount; // release amount&#13;
        uint256 releaseTime; // release time&#13;
    }&#13;
    mapping (uint =&gt; ReleaseRecord) public releaseRecords;&#13;
    uint public releaseRecordsCount = 0;&#13;
    function Releaseable(&#13;
                    address _operator, uint256 _initialSupply&#13;
                ) Frozenable(_operator) public {&#13;
        createTime = 1514563200;&#13;
        releasedSupply = _initialSupply;&#13;
        balances[owner] = _initialSupply;&#13;
        totalSupply = mulDecimals.mul(369280000);&#13;
    }&#13;
    function release(uint256 timestamp, uint256 sysAmount) public onlyOperator returns(uint256 _actualRelease) {&#13;
        require(timestamp &gt;= createTime &amp;&amp; timestamp &lt;= now);&#13;
        require(!checkIsReleaseRecordExist(timestamp));&#13;
        updateReleaseAmount(timestamp);&#13;
        require(sysAmount &lt;= releaseAmountPerDay.mul(4).div(5));&#13;
        require(totalSupply &gt;= releasedSupply.add(releaseAmountPerDay));&#13;
        balances[owner] = balances[owner].add(releaseAmountPerDay);&#13;
        releasedSupply = releasedSupply.add(releaseAmountPerDay);&#13;
        releaseRecords[releaseRecordsCount] = ReleaseRecord(releaseAmountPerDay, timestamp);&#13;
        releaseRecordsCount++;&#13;
        Release(owner, releaseAmountPerDay, sysAmount, timestamp);&#13;
        systemFreeze(sysAmount.div(5), timestamp.add(180 days));&#13;
        systemFreeze(sysAmount.mul(7).div(10), timestamp.add(70 years));&#13;
        return releaseAmountPerDay;&#13;
    }&#13;
    // check is release record existed&#13;
    // if existed return true, else return false&#13;
    function checkIsReleaseRecordExist(uint256 timestamp) internal view returns(bool _exist) {&#13;
        bool exist = false;&#13;
        if (releaseRecordsCount &gt; 0) {&#13;
            for (uint index = 0; index &lt; releaseRecordsCount; index++) {&#13;
                if ((releaseRecords[index].releaseTime.parseTimestamp().year == timestamp.parseTimestamp().year)&#13;
                    &amp;&amp; (releaseRecords[index].releaseTime.parseTimestamp().month == timestamp.parseTimestamp().month)&#13;
                    &amp;&amp; (releaseRecords[index].releaseTime.parseTimestamp().day == timestamp.parseTimestamp().day)) {&#13;
                    exist = true;&#13;
                }&#13;
            }&#13;
        }&#13;
        return exist;&#13;
    }&#13;
    // update release amount for single day&#13;
    // according to dividend rule in https://coinhot.com&#13;
    function updateReleaseAmount(uint256 timestamp) internal {&#13;
        uint256 timeElapse = timestamp.sub(createTime);&#13;
        uint256 cycles = timeElapse.div(180 days);&#13;
        if (cycles &gt; 0) {&#13;
            if (cycles &lt;= 10) {&#13;
                releaseAmountPerDay = standardReleaseAmount;&#13;
                for (uint index = 0; index &lt; cycles; index++) {&#13;
                    releaseAmountPerDay = releaseAmountPerDay.div(2);&#13;
                }&#13;
            } else {&#13;
                releaseAmountPerDay = 0;&#13;
            }&#13;
        }&#13;
    }&#13;
    function claimOwnership() onlyPendingOwner public {&#13;
        OwnershipTransferred(owner, pendingOwner);&#13;
        owner = pendingOwner;&#13;
        pendingOwner = address(0);&#13;
        transferSystemFreeze();&#13;
    }&#13;
}&#13;
contract CoinHot is Releaseable {&#13;
    string public standard = '2018011603';&#13;
    string public name = 'CoinHot';&#13;
    string public symbol = 'CHT';&#13;
    uint8 public decimals = 8;&#13;
    function CoinHot(&#13;
                     address _operator, uint256 _initialSupply&#13;
                     ) Releaseable(_operator, _initialSupply) public {}&#13;
}