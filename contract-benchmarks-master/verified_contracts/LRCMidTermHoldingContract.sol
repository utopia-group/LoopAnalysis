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
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

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

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint balance) {}

    /// @dev send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint _value) returns (bool success) {}

    /// @dev send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint _value) returns (bool success) {}

    /// @dev `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint remaining) {}

    /// Event for a successful transfer.
    event Transfer(address indexed _from, address indexed _to, uint _value);

    /// Event for a successful Approval.
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


/// @title Mid-Team Holding Incentive Program
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="badedbd4d3dfd6fad6d5d5cac8d3d4dd94d5c8dd">[email protected]</a>&gt;, Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="543f3b3a33383d353a3314383b3b24263d3a337a3b2633">[email protected]</a>&gt;.&#13;
/// For more information, please visit https://loopring.org.&#13;
contract LRCMidTermHoldingContract {&#13;
    using SafeMath for uint;&#13;
&#13;
    address public lrcTokenAddress  = 0x0;&#13;
    address public owner            = 0x0;&#13;
    uint    public rate             = 7500; &#13;
&#13;
    // Some stats&#13;
    uint public lrcReceived         = 0;&#13;
    uint public lrcSent             = 0;&#13;
    uint public ethReceived         = 0;&#13;
    uint public ethSent             = 0;&#13;
&#13;
    mapping (address =&gt; uint) lrcBalances; // each user's lrc balance&#13;
    &#13;
    /* &#13;
     * EVENTS&#13;
     */&#13;
    /// Emitted for each sucuessful deposit.&#13;
    uint public depositId = 0;&#13;
    event Deposit(uint _depositId, address _addr, uint _ethAmount, uint _lrcAmount);&#13;
&#13;
    /// Emitted for each sucuessful withdrawal.&#13;
    uint public withdrawId = 0;&#13;
    event Withdrawal(uint _withdrawId, address _addr, uint _ethAmount, uint _lrcAmount);&#13;
&#13;
    /// Emitted when ETH are drained and LRC are drained by owner.&#13;
    event Drained(uint _ethAmount, uint _lrcAmount);&#13;
&#13;
    /// Emitted when rate changed by owner.&#13;
    event RateChanged(uint _oldRate, uint _newRate);&#13;
&#13;
    /// CONSTRUCTOR &#13;
    /// @dev Initialize and start the contract.&#13;
    /// @param _lrcTokenAddress LRC ERC20 token address&#13;
    /// @param _owner Owner of this contract&#13;
    function LRCMidTermHoldingContract(address _lrcTokenAddress, address _owner) {&#13;
        require(_lrcTokenAddress != 0x0);&#13;
        require(_owner != 0x0);&#13;
&#13;
        lrcTokenAddress = _lrcTokenAddress;&#13;
        owner = _owner;&#13;
    }&#13;
&#13;
    /*&#13;
     * PUBLIC FUNCTIONS&#13;
     */&#13;
    /// @dev Get back ETH to `owner`.&#13;
    /// @param _rate New rate&#13;
    function setRate(uint _rate) public  {&#13;
        require(msg.sender == owner);&#13;
        require(rate &gt; 0);&#13;
        &#13;
        RateChanged(rate, _rate);&#13;
        rate = _rate;&#13;
    }&#13;
&#13;
    /// @dev Get back ETH to `owner`.&#13;
    /// @param _ethAmount Amount of ETH to drain back to owner&#13;
    function drain(uint _ethAmount) public payable {&#13;
        require(msg.sender == owner);&#13;
        require(_ethAmount &gt;= 0);&#13;
        &#13;
        uint ethAmount = _ethAmount.min256(this.balance);&#13;
        if (ethAmount &gt; 0){&#13;
            require(owner.send(ethAmount));&#13;
        }&#13;
&#13;
        var lrcToken = Token(lrcTokenAddress);&#13;
        uint lrcAmount = lrcToken.balanceOf(address(this)) - lrcReceived + lrcSent;&#13;
        if (lrcAmount &gt; 0){&#13;
            require(lrcToken.transfer(owner, lrcAmount));&#13;
        }&#13;
&#13;
        Drained(ethAmount, lrcAmount);&#13;
    }&#13;
&#13;
    /// @dev This default function allows simple usage.&#13;
    function () payable {&#13;
        if (msg.sender != owner) {&#13;
            if (msg.value == 0) depositLRC();&#13;
            else withdrawLRC();&#13;
        }&#13;
    }&#13;
&#13;
  &#13;
    /// @dev Deposit LRC for ETH.&#13;
    /// If user send x ETH, this method will try to transfer `x * 100 * 6500` LRC from&#13;
    /// the user's address and send `x * 100` ETH to the user.&#13;
    function depositLRC() payable {&#13;
        require(msg.sender != owner);&#13;
        require(msg.value == 0);&#13;
&#13;
        var lrcToken = Token(lrcTokenAddress);&#13;
&#13;
        uint lrcAmount = this.balance.mul(rate)&#13;
            .min256(lrcToken.balanceOf(msg.sender))&#13;
            .min256(lrcToken.allowance(msg.sender, address(this)));&#13;
&#13;
        uint ethAmount = lrcAmount.div(rate);&#13;
&#13;
        require(lrcAmount &gt; 0 &amp;&amp; ethAmount &gt; 0);&#13;
        require(ethAmount.mul(rate) &lt;= lrcAmount);&#13;
&#13;
        lrcBalances[msg.sender] += lrcAmount;&#13;
&#13;
        lrcReceived += lrcAmount;&#13;
        ethSent += ethAmount;&#13;
&#13;
        require(lrcToken.transferFrom(msg.sender, address(this), lrcAmount));&#13;
        require(msg.sender.send(ethAmount));&#13;
&#13;
        Deposit(&#13;
             depositId++,&#13;
             msg.sender,&#13;
             ethAmount,&#13;
             lrcAmount&#13;
        );      &#13;
    }&#13;
&#13;
    /// @dev Withdrawal LRC with ETH transfer.&#13;
    function withdrawLRC() payable {&#13;
        require(msg.sender != owner);&#13;
        require(msg.value &gt; 0);&#13;
&#13;
        uint lrcAmount = msg.value.mul(rate)&#13;
            .min256(lrcBalances[msg.sender]);&#13;
&#13;
        uint ethAmount = lrcAmount.div(rate);&#13;
&#13;
        require(lrcAmount &gt; 0 &amp;&amp; ethAmount &gt; 0);&#13;
&#13;
        lrcBalances[msg.sender] -= lrcAmount;&#13;
&#13;
        lrcSent += lrcAmount;&#13;
        ethReceived += ethAmount;&#13;
&#13;
        require(Token(lrcTokenAddress).transfer(msg.sender, lrcAmount));&#13;
&#13;
        uint ethRefund = msg.value - ethAmount;&#13;
        if (ethRefund &gt; 0) {&#13;
            require(msg.sender.send(ethRefund));&#13;
        }&#13;
&#13;
        Withdrawal(&#13;
             withdrawId++,&#13;
             msg.sender,&#13;
             ethAmount,&#13;
             lrcAmount&#13;
        ); &#13;
    }&#13;
}