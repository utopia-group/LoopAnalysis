pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
 * @title Math
 * @dev Assorted math operations
 */
library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
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
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/// @title BibBom Token Holding Incentive Program
/// @author TranTho - <<span class="__cf_email__" data-cfemail="bcc8d4d3dadafcded5dbded3d192dfd3d1">[email protected]</span>&gt;.&#13;
/// For more information, please visit https://bigbom.com.&#13;
contract BBOHoldingContract {&#13;
    using SafeMath for uint;&#13;
    using Math for uint;&#13;
   &#13;
    // During the first 60 days of deployment, this contract opens for deposit of BBO.&#13;
    uint public constant DEPOSIT_PERIOD             = 60 days; // = 2 months&#13;
&#13;
    // 18 months after deposit, user can withdrawal all or part of his/her BBO with bonus.&#13;
    // The bonus is this contract's initial BBO balance.&#13;
    uint public constant WITHDRAWAL_DELAY           = 360 days; // = 1 year &#13;
&#13;
    // Send 0.001ETH per 10000 BBO partial withdrawal, or 0 for a once-for-all withdrawal.&#13;
    // All ETH will be returned.&#13;
    uint public constant WITHDRAWAL_SCALE           = 1E7; // 1ETH for withdrawal of 10,000,000 BBO.&#13;
&#13;
    // Ower can drain all remaining BBO after 3 years.&#13;
    uint public constant DRAIN_DELAY                = 720 days; // = 2 years.&#13;
    &#13;
    address public bboTokenAddress  = 0x0;&#13;
    address public owner            = 0x0;&#13;
&#13;
    uint public bboDeposited        = 0;&#13;
    uint public depositStartTime    = 0;&#13;
    uint public depositStopTime     = 0;&#13;
&#13;
    struct Record {&#13;
        uint bboAmount;&#13;
        uint timestamp;&#13;
    }&#13;
&#13;
    mapping (address =&gt; Record) records;&#13;
    &#13;
    /* &#13;
     * EVENTS&#13;
     */&#13;
&#13;
    /// Emitted when program starts.&#13;
    event Started(uint _time);&#13;
&#13;
    /// Emitted when all BBO are drained.&#13;
    event Drained(uint _bboAmount);&#13;
&#13;
    /// Emitted for each sucuessful deposit.&#13;
    uint public depositId = 0;&#13;
    event Deposit(uint _depositId, address indexed _addr, uint _bboAmount);&#13;
&#13;
    /// Emitted for each sucuessful deposit.&#13;
    uint public withdrawId = 0;&#13;
    event Withdrawal(uint _withdrawId, address indexed _addr, uint _bboAmount);&#13;
&#13;
    /// @dev Initialize the contract&#13;
    /// @param _bboTokenAddress BBO ERC20 token address&#13;
    constructor (address _bboTokenAddress, address _owner) public {&#13;
        require(_bboTokenAddress != address(0));&#13;
        require(_owner != address(0));&#13;
&#13;
        bboTokenAddress = _bboTokenAddress;&#13;
        owner = _owner;&#13;
    }&#13;
&#13;
    /*&#13;
     * PUBLIC FUNCTIONS&#13;
     */&#13;
&#13;
    /// @dev start the program.&#13;
    function start() public {&#13;
        require(msg.sender == owner);&#13;
        require(depositStartTime == 0);&#13;
&#13;
        depositStartTime = now;&#13;
        depositStopTime  = depositStartTime + DEPOSIT_PERIOD;&#13;
&#13;
        emit Started(depositStartTime);&#13;
    }&#13;
&#13;
&#13;
    /// @dev drain BBO.&#13;
    function drain() public {&#13;
        require(msg.sender == owner);&#13;
        require(depositStartTime &gt; 0 &amp;&amp; now &gt;= depositStartTime + DRAIN_DELAY);&#13;
&#13;
        uint balance = bboBalance();&#13;
        require(balance &gt; 0);&#13;
&#13;
        require(ERC20(bboTokenAddress).transfer(owner, balance));&#13;
&#13;
        emit Drained(balance);&#13;
    }&#13;
&#13;
    function () payable {&#13;
        require(depositStartTime &gt; 0);&#13;
&#13;
        if (now &gt;= depositStartTime &amp;&amp; now &lt;= depositStopTime) {&#13;
            depositBBO();&#13;
        } else if (now &gt; depositStopTime){&#13;
            withdrawBBO();&#13;
        } else {&#13;
            revert();&#13;
        }&#13;
    }&#13;
&#13;
    /// @return Current BBO balance.&#13;
    function bboBalance() public constant returns (uint) {&#13;
        return ERC20(bboTokenAddress).balanceOf(address(this));&#13;
    }&#13;
    function holdBalance() public constant returns (uint) {&#13;
        return records[msg.sender].bboAmount;&#13;
    }&#13;
    function lastDeposit() public constant returns (uint) {&#13;
        return records[msg.sender].timestamp;&#13;
    }&#13;
    /// @dev Deposit BBO.&#13;
    function depositBBO() payable {&#13;
        require(depositStartTime &gt; 0);&#13;
        require(msg.value == 0);&#13;
        require(now &gt;= depositStartTime &amp;&amp; now &lt;= depositStopTime);&#13;
        &#13;
        ERC20 bboToken = ERC20(bboTokenAddress);&#13;
        uint bboAmount = bboToken&#13;
            .balanceOf(msg.sender)&#13;
            .min256(bboToken.allowance(msg.sender, address(this)));&#13;
&#13;
        if(bboAmount &gt; 0){&#13;
            require(bboToken.transferFrom(msg.sender, address(this), bboAmount));&#13;
            Record storage record = records[msg.sender];&#13;
            record.bboAmount = record.bboAmount.add(bboAmount);&#13;
            record.timestamp = now;&#13;
            records[msg.sender] = record;&#13;
&#13;
            bboDeposited = bboDeposited.add(bboAmount);&#13;
            emit Deposit(depositId++, msg.sender, bboAmount);&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Withdrawal BBO.&#13;
    function withdrawBBO() payable {&#13;
        require(depositStartTime &gt; 0);&#13;
        require(bboDeposited &gt; 0);&#13;
&#13;
        Record storage record = records[msg.sender];&#13;
        require(now &gt;= record.timestamp + WITHDRAWAL_DELAY);&#13;
        require(record.bboAmount &gt; 0);&#13;
&#13;
        uint bboWithdrawalBase = record.bboAmount;&#13;
        if (msg.value &gt; 0) {&#13;
            bboWithdrawalBase = bboWithdrawalBase&#13;
                .min256(msg.value.mul(WITHDRAWAL_SCALE));&#13;
        }&#13;
&#13;
        uint bboBonus = getBonus(bboWithdrawalBase);&#13;
        uint balance = bboBalance();&#13;
        uint bboAmount = balance.min256(bboWithdrawalBase + bboBonus);&#13;
        &#13;
        bboDeposited = bboDeposited.sub(bboWithdrawalBase);&#13;
        record.bboAmount = record.bboAmount.sub(bboWithdrawalBase);&#13;
&#13;
        if (record.bboAmount == 0) {&#13;
            delete records[msg.sender];&#13;
        } else {&#13;
            records[msg.sender] = record;&#13;
        }&#13;
&#13;
        emit Withdrawal(withdrawId++, msg.sender, bboAmount);&#13;
&#13;
        require(ERC20(bboTokenAddress).transfer(msg.sender, bboAmount));&#13;
        if (msg.value &gt; 0) {&#13;
            msg.sender.transfer(msg.value);&#13;
        }&#13;
    }&#13;
&#13;
    function getBonus(uint _bboWithdrawalBase) constant returns (uint) {&#13;
        return internalCalculateBonus(bboBalance() - bboDeposited,bboDeposited, _bboWithdrawalBase);&#13;
    }&#13;
&#13;
    function internalCalculateBonus(uint _totalBonusRemaining, uint _bboDeposited, uint _bboWithdrawalBase) constant returns (uint) {&#13;
        require(_bboDeposited &gt; 0);&#13;
        require(_totalBonusRemaining &gt;= 0);&#13;
&#13;
        // The bonus is non-linear function to incentivize later withdrawal.&#13;
        // bonus = _totalBonusRemaining * power(_bboWithdrawalBase/_bboDeposited, 1.0625)&#13;
        return _totalBonusRemaining&#13;
            .mul(_bboWithdrawalBase.mul(sqrt(sqrt(sqrt(sqrt(_bboWithdrawalBase))))))&#13;
            .div(_bboDeposited.mul(sqrt(sqrt(sqrt(sqrt(_bboDeposited))))));&#13;
    }&#13;
&#13;
    function sqrt(uint x) internal constant returns (uint) {&#13;
        uint y = x;&#13;
        while (true) {&#13;
            uint z = (y + (x / y)) / 2;&#13;
            uint w = (z + (x / z)) / 2;&#13;
            if (w == y) {&#13;
                if (w &lt; y) return w;&#13;
                else return y;&#13;
            }&#13;
            y = w;&#13;
        }&#13;
    }&#13;
}