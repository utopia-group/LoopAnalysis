pragma solidity ^0.4.15;
/*
    Copyright 2017, Arthur Lunn

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * @title ERC20
 * @dev A standard interface for tokens.
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20 {
  
    /// @dev Returns the total token supply.
    function totalSupply() public constant returns (uint256 supply);

    /// @dev Returns the account balance of another account with address _owner.
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /// @dev Transfers _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @dev Transfers _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @dev Allows _spender to withdraw from your account multiple times, up to the _value amount
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @dev Returns the amount which _spender is still allowed to withdraw from _owner.
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

/// @title Owned
/// @author Adrià Massanet <<span class="__cf_email__" data-cfemail="422326302b2302212d2627212d2c36273a366c2b2d">[email protected]</span>&gt;&#13;
/// @notice The Owned contract has an owner address, and provides basic &#13;
///  authorization control functions, this simplifies &amp; the implementation of&#13;
///  "user permissions"&#13;
contract Owned {&#13;
&#13;
    address public owner;&#13;
    address public newOwnerCandidate;&#13;
&#13;
    event OwnershipRequested(address indexed by, address indexed to);&#13;
    event OwnershipTransferred(address indexed from, address indexed to);&#13;
    event OwnershipRemoved();&#13;
&#13;
    /// @dev The constructor sets the `msg.sender` as the`owner` of the contract&#13;
    function Owned() {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    /// @dev `owner` is the only address that can call a function with this&#13;
    /// modifier&#13;
    modifier onlyOwner() {&#13;
        require (msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    /// @notice `owner` can step down and assign some other address to this role&#13;
    /// @param _newOwner The address of the new owner.&#13;
    function changeOwnership(address _newOwner) onlyOwner {&#13;
        require(_newOwner != 0x0);&#13;
&#13;
        address oldOwner = owner;&#13;
        owner = _newOwner;&#13;
        newOwnerCandidate = 0x0;&#13;
&#13;
        OwnershipTransferred(oldOwner, owner);&#13;
    }&#13;
&#13;
    /// @notice `onlyOwner` Proposes to transfer control of the contract to a&#13;
    ///  new owner&#13;
    /// @param _newOwnerCandidate The address being proposed as the new owner&#13;
    function proposeOwnership(address _newOwnerCandidate) onlyOwner {&#13;
        newOwnerCandidate = _newOwnerCandidate;&#13;
        OwnershipRequested(msg.sender, newOwnerCandidate);&#13;
    }&#13;
&#13;
    /// @notice Can only be called by the `newOwnerCandidate`, accepts the&#13;
    ///  transfer of ownership&#13;
    function acceptOwnership() {&#13;
        require(msg.sender == newOwnerCandidate);&#13;
&#13;
        address oldOwner = owner;&#13;
        owner = newOwnerCandidate;&#13;
        newOwnerCandidate = 0x0;&#13;
&#13;
        OwnershipTransferred(oldOwner, owner);&#13;
    }&#13;
&#13;
    /// @notice Decentralizes the contract, this operation cannot be undone &#13;
    /// @param _dece `0xdece` has to be entered for this function to work&#13;
    function removeOwnership(address _dece) onlyOwner {&#13;
        require(_dece == 0xdece);&#13;
        owner = 0x0;&#13;
        newOwnerCandidate = 0x0;&#13;
        OwnershipRemoved();     &#13;
    }&#13;
&#13;
} &#13;
&#13;
/// @dev `Escapable` is a base level contract built off of the `Owned`&#13;
///  contract that creates an escape hatch function to send its ether to&#13;
///  `escapeHatchDestination` when called by the `escapeHatchCaller` in the case that&#13;
///  something unexpected happens&#13;
contract Escapable is Owned {&#13;
    address public escapeHatchCaller;&#13;
    address public escapeHatchDestination;&#13;
    mapping (address=&gt;bool) private escapeBlacklist;&#13;
&#13;
    /// @notice The Constructor assigns the `escapeHatchDestination` and the&#13;
    ///  `escapeHatchCaller`&#13;
    /// @param _escapeHatchDestination The address of a safe location (usu a&#13;
    ///  Multisig) to send the ether held in this contract&#13;
    /// @param _escapeHatchCaller The address of a trusted account or contract to&#13;
    ///  call `escapeHatch()` to send the ether in this contract to the&#13;
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller` cannot move&#13;
    ///  funds out of `escapeHatchDestination`&#13;
    function Escapable(address _escapeHatchCaller, address _escapeHatchDestination) {&#13;
        escapeHatchCaller = _escapeHatchCaller;&#13;
        escapeHatchDestination = _escapeHatchDestination;&#13;
    }&#13;
&#13;
    modifier onlyEscapeHatchCallerOrOwner {&#13;
        require ((msg.sender == escapeHatchCaller)||(msg.sender == owner));&#13;
        _;&#13;
    }&#13;
&#13;
    /// @notice The `blacklistEscapeTokens()` marks a token in a whitelist to be&#13;
    ///   escaped. The proupose is to be done at construction time.&#13;
    /// @param _token the be bloacklisted for escape&#13;
    function blacklistEscapeToken(address _token) internal {&#13;
        escapeBlacklist[_token] = true;&#13;
        EscapeHatchBlackistedToken(_token);&#13;
    }&#13;
&#13;
    function isTokenEscapable(address _token) constant public returns (bool) {&#13;
        return !escapeBlacklist[_token];&#13;
    }&#13;
&#13;
    /// @notice The `escapeHatch()` should only be called as a last resort if a&#13;
    /// security issue is uncovered or something unexpected happened&#13;
    /// @param _token to transfer, use 0x0 for ethers&#13;
    function escapeHatch(address _token) public onlyEscapeHatchCallerOrOwner {   &#13;
        require(escapeBlacklist[_token]==false);&#13;
&#13;
        uint256 balance;&#13;
&#13;
        if (_token == 0x0) {&#13;
            balance = this.balance;&#13;
            escapeHatchDestination.transfer(balance);&#13;
            EscapeHatchCalled(_token, balance);&#13;
            return;&#13;
        }&#13;
&#13;
        ERC20 token = ERC20(_token);&#13;
        balance = token.balanceOf(this);&#13;
        token.transfer(escapeHatchDestination, balance);&#13;
        EscapeHatchCalled(_token, balance);&#13;
    }&#13;
&#13;
    /// @notice Changes the address assigned to call `escapeHatch()`&#13;
    /// @param _newEscapeHatchCaller The address of a trusted account or contract to&#13;
    ///  call `escapeHatch()` to send the ether in this contract to the&#13;
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller` cannot&#13;
    ///  move funds out of `escapeHatchDestination`&#13;
    function changeEscapeCaller(address _newEscapeHatchCaller) onlyEscapeHatchCallerOrOwner {&#13;
        escapeHatchCaller = _newEscapeHatchCaller;&#13;
    }&#13;
&#13;
    event EscapeHatchBlackistedToken(address token);&#13;
    event EscapeHatchCalled(address token, uint amount);&#13;
}&#13;
&#13;
&#13;
/// @dev This is an empty contract to declare `proxyPayment()` to comply with&#13;
///  Giveth Campaigns so that tokens will be generated when donations are sent&#13;
contract Campaign {&#13;
    /// @notice `proxyPayment()` allows the caller to send ether to the Campaign and&#13;
    /// have the tokens created in an address of their choosing&#13;
    /// @param _owner The address that will hold the newly created tokens&#13;
    function proxyPayment(address _owner) payable returns(bool);&#13;
}&#13;
&#13;
&#13;
/// @title Fund Forwarder&#13;
/// @authors Vojtech Simetka, Jordi Baylina, Dani Philia, Arthur Lunn (hardly)&#13;
/// @notice This contract is used to forward funds to a Giveth Campaign &#13;
///  with an escapeHatch.The fund value is sent directly to designated Campaign.&#13;
///  The escapeHatch allows removal of any other tokens deposited by accident.&#13;
/*&#13;
    Copyright 2016, Jordi Baylina&#13;
    Contributor: Adrià Massanet &lt;<span class="__cf_email__" data-cfemail="e8898c9a8189a88b878c8d8b87869c8d909cc68187">[email protected]</span>&gt;&#13;
&#13;
    This program is free software: you can redistribute it and/or modify&#13;
    it under the terms of the GNU General Public License as published by&#13;
    the Free Software Foundation, either version 3 of the License, or&#13;
    (at your option) any later version.&#13;
&#13;
    This program is distributed in the hope that it will be useful,&#13;
    but WITHOUT ANY WARRANTY; without even the implied warranty of&#13;
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the&#13;
    GNU General Public License for more details.&#13;
&#13;
    You should have received a copy of the GNU General Public License&#13;
    along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.&#13;
*/&#13;
&#13;
/// @dev The main contract which forwards funds sent to contract.&#13;
contract FundForwarder is Escapable {&#13;
    Campaign public beneficiary; // expected to be a Giveth campaign&#13;
&#13;
    /// @notice The Constructor assigns the `beneficiary`, the&#13;
    ///  `escapeHatchDestination` and the `escapeHatchCaller` as well as deploys&#13;
    ///  the contract to the blockchain (obviously)&#13;
    /// @param _beneficiary The address of the CAMPAIGN CONTROLLER for the Campaign&#13;
    ///  that is to receive donations&#13;
    /// @param _escapeHatchDestination The address of a safe location (usually a&#13;
    ///  Multisig) to send the ether held in this contract&#13;
    /// @param _escapeHatchCaller The address of a trusted account or contract&#13;
    ///  to call `escapeHatch()` to send the ether in this contract to the &#13;
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller`&#13;
    ///  cannot move funds out of `escapeHatchDestination`&#13;
    function FundForwarder(&#13;
            Campaign _beneficiary, // address that receives ether&#13;
            address _escapeHatchCaller,&#13;
            address _escapeHatchDestination&#13;
        )&#13;
        // Set the escape hatch to accept ether (0x0)&#13;
        Escapable(_escapeHatchCaller, _escapeHatchDestination)&#13;
    {&#13;
        beneficiary = _beneficiary;&#13;
    }&#13;
&#13;
    /// @notice Directly forward Eth to `beneficiary`. The `msg.sender` is rewarded with Campaign tokens.&#13;
    ///  This contract may have a high gasLimit requirement dependent on beneficiary.&#13;
    function () payable {&#13;
        uint amount;&#13;
        amount = msg.value;&#13;
        // Send the ETH to the beneficiary so that they receive Campaign tokens&#13;
        require (beneficiary.proxyPayment.value(amount)&#13;
        (msg.sender)&#13;
        );&#13;
        FundsSent(msg.sender, amount);&#13;
    }&#13;
    event FundsSent(address indexed sender, uint amount);&#13;
}