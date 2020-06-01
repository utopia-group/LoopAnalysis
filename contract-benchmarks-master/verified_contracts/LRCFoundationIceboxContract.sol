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
}

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


/// @title LRC Foundation Icebox Program
/// @author Daniel Wang - <<span class="__cf_email__" data-cfemail="9ffbfef1f6faf3dff3f0f0efedf6f1f8b1f0edf8">[email protected]</span>&gt;.&#13;
/// For more information, please visit https://loopring.org.&#13;
&#13;
/// Loopring Foundation's LRC (20% of total supply) will be locked during the first two years，&#13;
/// two years later, 1/24 of all locked LRC fund can be unlocked every month.&#13;
&#13;
contract LRCFoundationIceboxContract {&#13;
    using SafeMath for uint;&#13;
    &#13;
    uint public constant FREEZE_PERIOD = 720 days; // = 2 years&#13;
&#13;
    address public lrcTokenAddress  = 0x0;&#13;
    address public owner            = 0x0;&#13;
&#13;
    uint public lrcInitialBalance   = 0;&#13;
    uint public lrcWithdrawn         = 0;&#13;
    uint public lrcUnlockPerMonth   = 0;&#13;
    uint public startTime           = 0;&#13;
&#13;
    /* &#13;
     * EVENTS&#13;
     */&#13;
&#13;
    /// Emitted when program starts.&#13;
    event Started(uint _time);&#13;
&#13;
    /// Emitted for each sucuessful deposit.&#13;
    uint public withdrawId = 0;&#13;
    event Withdrawal(uint _withdrawId, uint _lrcAmount);&#13;
&#13;
    /// @dev Initialize the contract&#13;
    /// @param _lrcTokenAddress LRC ERC20 token address&#13;
    /// @param _owner Owner's address&#13;
    function LRCFoundationIceboxContract(address _lrcTokenAddress, address _owner) {&#13;
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
        require(startTime == 0);&#13;
&#13;
        lrcInitialBalance = Token(lrcTokenAddress).balanceOf(address(this));&#13;
        require(lrcInitialBalance &gt; 0);&#13;
&#13;
        lrcUnlockPerMonth = lrcInitialBalance.div(24); // 24 month&#13;
        startTime = now;&#13;
&#13;
        Started(startTime);&#13;
    }&#13;
&#13;
&#13;
    function () payable {&#13;
        require(msg.sender == owner);&#13;
        require(msg.value == 0);&#13;
        require(startTime &gt; 0);&#13;
        require(now &gt; startTime + FREEZE_PERIOD);&#13;
&#13;
        var token = Token(lrcTokenAddress);&#13;
        uint balance = token.balanceOf(address(this));&#13;
        require(balance &gt; 0);&#13;
&#13;
        uint lrcAmount = calculateLRCUnlockAmount(now, balance);&#13;
        if (lrcAmount &gt; 0) {&#13;
            lrcWithdrawn += lrcAmount;&#13;
&#13;
            Withdrawal(withdrawId++, lrcAmount);&#13;
            require(token.transfer(owner, lrcAmount));&#13;
        }&#13;
    }&#13;
&#13;
&#13;
    /*&#13;
     * INTERNAL FUNCTIONS&#13;
     */&#13;
&#13;
    function calculateLRCUnlockAmount(uint _now, uint _balance) internal returns (uint lrcAmount) {&#13;
        uint unlockable = (_now - startTime - FREEZE_PERIOD)&#13;
            .div(30 days)&#13;
            .mul(lrcUnlockPerMonth) - lrcWithdrawn;&#13;
&#13;
        require(unlockable &gt; 0);&#13;
&#13;
        if (unlockable &gt; _balance) return _balance;&#13;
        else return unlockable;&#13;
    }&#13;
&#13;
}