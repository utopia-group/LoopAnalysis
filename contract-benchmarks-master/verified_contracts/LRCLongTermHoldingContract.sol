/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/
pragma solidity ^0.4.11;

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
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



/// @title Long-Team Holding Incentive Program
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b3d7d2dddad6dff3dfdcdcc3c1daddd49ddcc1d4">[email protected]</a>&gt;, Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0e6561606962676f60694e6261617e7c67606920617c69">[email protected]</a>&gt;.&#13;
/// For more information, please visit https://loopring.org.&#13;
contract LRCLongTermHoldingContract {&#13;
    using SafeMath for uint;&#13;
    using Math for uint;&#13;
    &#13;
    // During the first 60 days of deployment, this contract opens for deposit of LRC.&#13;
    uint public constant DEPOSIT_PERIOD             = 60 days; // = 2 months&#13;
&#13;
    // 18 months after deposit, user can withdrawal all or part of his/her LRC with bonus.&#13;
    // The bonus is this contract's initial LRC balance.&#13;
    uint public constant WITHDRAWAL_DELAY           = 540 days; // = 1 year and 6 months&#13;
&#13;
    // This implies a 0.001ETH fee per 10000 LRC partial withdrawal;&#13;
    // for a once-for-all withdrawal, the fee is 0.&#13;
    uint public constant WITHDRAWAL_SCALE           = 1E7; // 1ETH for withdrawal of 10,000,000 LRC.&#13;
    &#13;
    address public lrcTokenAddress  = 0x0;&#13;
    address public owner            = 0x0;&#13;
&#13;
    uint public lrcDeposited        = 0;&#13;
    uint public depositStartTime    = 0;&#13;
    uint public depositStopTime     = 0;&#13;
&#13;
    struct Record {&#13;
        uint lrcAmount;&#13;
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
    /// Emitted for each sucuessful deposit.&#13;
    uint public depositId = 0;&#13;
    event Deposit(uint _depositId, address indexed _addr, uint _lrcAmount);&#13;
&#13;
    /// Emitted for each sucuessful deposit.&#13;
    uint public withdrawId = 0;&#13;
    event Withdrawal(uint _withdrawId, address indexed _addr, uint _lrcAmount);&#13;
&#13;
    /// @dev Initialize the contract&#13;
    /// @param _lrcTokenAddress LRC ERC20 token address&#13;
    function LRCLongTermHoldingContract(address _lrcTokenAddress, address _owner) {&#13;
        require(_lrcTokenAddress != address(0));&#13;
        require(_owner != address(0));&#13;
&#13;
        lrcTokenAddress = _lrcTokenAddress;&#13;
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
        Started(depositStartTime);&#13;
    }&#13;
&#13;
    function () payable {&#13;
        require(depositStartTime &gt; 0);&#13;
&#13;
        if (now &gt;= depositStartTime &amp;&amp; now &lt;= depositStopTime) {&#13;
            depositLRC();&#13;
        } else if (now &gt; depositStopTime){&#13;
            withdrawLRC();&#13;
        } else {&#13;
            revert();&#13;
        }&#13;
    }&#13;
&#13;
    /// @return Current LRC balance.&#13;
    function lrcBalance() public constant returns (uint) {&#13;
        return Token(lrcTokenAddress).balanceOf(address(this));&#13;
    }&#13;
&#13;
    /// @dev Deposit LRC.&#13;
    function depositLRC() payable {&#13;
        require(depositStartTime &gt; 0);&#13;
        require(msg.value == 0);&#13;
        require(now &gt;= depositStartTime &amp;&amp; now &lt;= depositStopTime);&#13;
        &#13;
        var lrcToken = Token(lrcTokenAddress);&#13;
        uint lrcAmount = lrcToken&#13;
            .balanceOf(msg.sender)&#13;
            .min256(lrcToken.allowance(msg.sender, address(this)));&#13;
&#13;
        require(lrcAmount &gt; 0);&#13;
&#13;
        var record = records[msg.sender];&#13;
        record.lrcAmount += lrcAmount;&#13;
        record.timestamp = now;&#13;
        records[msg.sender] = record;&#13;
&#13;
        lrcDeposited += lrcAmount;&#13;
&#13;
        Deposit(depositId++, msg.sender, lrcAmount);&#13;
        require(lrcToken.transferFrom(msg.sender, address(this), lrcAmount));&#13;
    }&#13;
&#13;
    /// @dev Withdrawal LRC.&#13;
    function withdrawLRC() payable {&#13;
        require(depositStartTime &gt; 0);&#13;
        require(lrcDeposited &gt; 0);&#13;
&#13;
        var record = records[msg.sender];&#13;
        require(now &gt;= record.timestamp + WITHDRAWAL_DELAY);&#13;
        require(record.lrcAmount &gt; 0);&#13;
&#13;
        uint lrcWithdrawalBase = record.lrcAmount;&#13;
        if (msg.value &gt; 0) {&#13;
            lrcWithdrawalBase = lrcWithdrawalBase&#13;
                .min256(msg.value.mul(WITHDRAWAL_SCALE));&#13;
        }&#13;
&#13;
        uint lrcBonus = getBonus(lrcWithdrawalBase);&#13;
        uint balance = lrcBalance();&#13;
        uint lrcAmount = balance.min256(lrcWithdrawalBase + lrcBonus);&#13;
        &#13;
        lrcDeposited -= lrcWithdrawalBase;&#13;
        record.lrcAmount -= lrcWithdrawalBase;&#13;
&#13;
        if (record.lrcAmount == 0) {&#13;
            delete records[msg.sender];&#13;
        } else {&#13;
            records[msg.sender] = record;&#13;
        }&#13;
&#13;
        Withdrawal(withdrawId++, msg.sender, lrcAmount);&#13;
        require(Token(lrcTokenAddress).transfer(msg.sender, lrcAmount));&#13;
    }&#13;
&#13;
    function getBonus(uint _lrcWithdrawalBase) constant returns (uint) {&#13;
        return internalCalculateBonus(lrcBalance() - lrcDeposited,lrcDeposited, _lrcWithdrawalBase);&#13;
    }&#13;
&#13;
    function internalCalculateBonus(uint _totalBonusRemaining, uint _lrcDeposited, uint _lrcWithdrawalBase) constant returns (uint) {&#13;
        require(_lrcDeposited &gt; 0);&#13;
        require(_totalBonusRemaining &gt;= 0);&#13;
&#13;
        // The bonus is non-linear function to incentivize later withdrawal.&#13;
        // bonus = _totalBonusRemaining * power(_lrcWithdrawalBase/_lrcDeposited, 1.0625)&#13;
        return _totalBonusRemaining&#13;
            .mul(_lrcWithdrawalBase.mul(sqrt(sqrt(sqrt(sqrt(_lrcWithdrawalBase))))))&#13;
            .div(_lrcDeposited.mul(sqrt(sqrt(sqrt(sqrt(_lrcDeposited))))));&#13;
    }&#13;
&#13;
    function sqrt(uint x) returns (uint) {&#13;
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