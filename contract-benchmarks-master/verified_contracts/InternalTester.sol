pragma solidity 0.4.20;

// No deps verison.

/**
 * @title ERC20
 * @dev A standard interface for tokens.
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20 {
  
    /// @dev Returns the total token supply
    function totalSupply() public constant returns (uint256 supply);

    /// @dev Returns the account balance of the account with address _owner
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /// @dev Transfers _value number of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @dev Transfers _value number of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @dev Allows _spender to withdraw from the msg.sender's account up to the _value amount
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @dev Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

/// @title Owned
/// @author Adrià Massanet <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="264742544f47664549424345494852435e52084f49">[email protected]</a>&gt;&#13;
/// @notice The Owned contract has an owner address, and provides basic &#13;
///  authorization control functions, this simplifies &amp; the implementation of&#13;
///  user permissions; this contract has three work flows for a change in&#13;
///  ownership, the first requires the new owner to validate that they have the&#13;
///  ability to accept ownership, the second allows the ownership to be&#13;
///  directly transfered without requiring acceptance, and the third allows for&#13;
///  the ownership to be removed to allow for decentralization &#13;
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
    function Owned() public {&#13;
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
    /// @dev In this 1st option for ownership transfer `proposeOwnership()` must&#13;
    ///  be called first by the current `owner` then `acceptOwnership()` must be&#13;
    ///  called by the `newOwnerCandidate`&#13;
    /// @notice `onlyOwner` Proposes to transfer control of the contract to a&#13;
    ///  new owner&#13;
    /// @param _newOwnerCandidate The address being proposed as the new owner&#13;
    function proposeOwnership(address _newOwnerCandidate) public onlyOwner {&#13;
        newOwnerCandidate = _newOwnerCandidate;&#13;
        OwnershipRequested(msg.sender, newOwnerCandidate);&#13;
    }&#13;
&#13;
    /// @notice Can only be called by the `newOwnerCandidate`, accepts the&#13;
    ///  transfer of ownership&#13;
    function acceptOwnership() public {&#13;
        require(msg.sender == newOwnerCandidate);&#13;
&#13;
        address oldOwner = owner;&#13;
        owner = newOwnerCandidate;&#13;
        newOwnerCandidate = 0x0;&#13;
&#13;
        OwnershipTransferred(oldOwner, owner);&#13;
    }&#13;
&#13;
    /// @dev In this 2nd option for ownership transfer `changeOwnership()` can&#13;
    ///  be called and it will immediately assign ownership to the `newOwner`&#13;
    /// @notice `owner` can step down and assign some other address to this role&#13;
    /// @param _newOwner The address of the new owner&#13;
    function changeOwnership(address _newOwner) public onlyOwner {&#13;
        require(_newOwner != 0x0);&#13;
&#13;
        address oldOwner = owner;&#13;
        owner = _newOwner;&#13;
        newOwnerCandidate = 0x0;&#13;
&#13;
        OwnershipTransferred(oldOwner, owner);&#13;
    }&#13;
&#13;
    /// @dev In this 3rd option for ownership transfer `removeOwnership()` can&#13;
    ///  be called and it will immediately assign ownership to the 0x0 address;&#13;
    ///  it requires a 0xdece be input as a parameter to prevent accidental use&#13;
    /// @notice Decentralizes the contract, this operation cannot be undone &#13;
    /// @param _dac `0xdac` has to be entered for this function to work&#13;
    function removeOwnership(address _dac) public onlyOwner {&#13;
        require(_dac == 0xdac);&#13;
        owner = 0x0;&#13;
        newOwnerCandidate = 0x0;&#13;
        OwnershipRemoved();     &#13;
    }&#13;
} &#13;
&#13;
/// @dev `Escapable` is a base level contract built off of the `Owned`&#13;
///  contract; it creates an escape hatch function that can be called in an&#13;
///  emergency that will allow designated addresses to send any ether or tokens&#13;
///  held in the contract to an `escapeHatchDestination` as long as they were&#13;
///  not blacklisted&#13;
contract Escapable is Owned {&#13;
    address public escapeHatchCaller;&#13;
    address public escapeHatchDestination;&#13;
    mapping (address=&gt;bool) private escapeBlacklist; // Token contract addresses&#13;
&#13;
    /// @notice The Constructor assigns the `escapeHatchDestination` and the&#13;
    ///  `escapeHatchCaller`&#13;
    /// @param _escapeHatchCaller The address of a trusted account or contract&#13;
    ///  to call `escapeHatch()` to send the ether in this contract to the&#13;
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller`&#13;
    ///  cannot move funds out of `escapeHatchDestination`&#13;
    /// @param _escapeHatchDestination The address of a safe location (usu a&#13;
    ///  Multisig) to send the ether held in this contract; if a neutral address&#13;
    ///  is required, the WHG Multisig is an option:&#13;
    ///  0x8Ff920020c8AD673661c8117f2855C384758C572 &#13;
    function Escapable(address _escapeHatchCaller, address _escapeHatchDestination) public {&#13;
        escapeHatchCaller = _escapeHatchCaller;&#13;
        escapeHatchDestination = _escapeHatchDestination;&#13;
    }&#13;
&#13;
    /// @dev The addresses preassigned as `escapeHatchCaller` or `owner`&#13;
    ///  are the only addresses that can call a function with this modifier&#13;
    modifier onlyEscapeHatchCallerOrOwner {&#13;
        require ((msg.sender == escapeHatchCaller)||(msg.sender == owner));&#13;
        _;&#13;
    }&#13;
&#13;
    /// @notice Creates the blacklist of tokens that are not able to be taken&#13;
    ///  out of the contract; can only be done at the deployment, and the logic&#13;
    ///  to add to the blacklist will be in the constructor of a child contract&#13;
    /// @param _token the token contract address that is to be blacklisted &#13;
    function blacklistEscapeToken(address _token) internal {&#13;
        escapeBlacklist[_token] = true;&#13;
        EscapeHatchBlackistedToken(_token);&#13;
    }&#13;
&#13;
    /// @notice Checks to see if `_token` is in the blacklist of tokens&#13;
    /// @param _token the token address being queried&#13;
    /// @return False if `_token` is in the blacklist and can't be taken out of&#13;
    ///  the contract via the `escapeHatch()`&#13;
    function isTokenEscapable(address _token) view public returns (bool) {&#13;
        return !escapeBlacklist[_token];&#13;
    }&#13;
&#13;
    /// @notice The `escapeHatch()` should only be called as a last resort if a&#13;
    /// security issue is uncovered or something unexpected happened&#13;
    /// @param _token to transfer, use 0x0 for ether&#13;
    function escapeHatch(address _token) public onlyEscapeHatchCallerOrOwner {   &#13;
        require(escapeBlacklist[_token]==false);&#13;
&#13;
        uint256 balance;&#13;
&#13;
        /// @dev Logic for ether&#13;
        if (_token == 0x0) {&#13;
            balance = this.balance;&#13;
            escapeHatchDestination.transfer(balance);&#13;
            EscapeHatchCalled(_token, balance);&#13;
            return;&#13;
        }&#13;
        /// @dev Logic for tokens&#13;
        ERC20 token = ERC20(_token);&#13;
        balance = token.balanceOf(this);&#13;
        require(token.transfer(escapeHatchDestination, balance));&#13;
        EscapeHatchCalled(_token, balance);&#13;
    }&#13;
&#13;
    /// @notice Changes the address assigned to call `escapeHatch()`&#13;
    /// @param _newEscapeHatchCaller The address of a trusted account or&#13;
    ///  contract to call `escapeHatch()` to send the value in this contract to&#13;
    ///  the `escapeHatchDestination`; it would be ideal that `escapeHatchCaller`&#13;
    ///  cannot move funds out of `escapeHatchDestination`&#13;
    function changeHatchEscapeCaller(address _newEscapeHatchCaller) public onlyEscapeHatchCallerOrOwner {&#13;
        escapeHatchCaller = _newEscapeHatchCaller;&#13;
    }&#13;
&#13;
    event EscapeHatchBlackistedToken(address token);&#13;
    event EscapeHatchCalled(address token, uint amount);&#13;
}&#13;
&#13;
contract InternalTester is Escapable(0x1Ff21eCa1c3ba96ed53783aB9C92FfbF77862584, 0x1Ff21eCa1c3ba96ed53783aB9C92FfbF77862584) {&#13;
    function sendETH(address _to) payable public returns(bool) {&#13;
        _safeTransfer(_to, msg.value);&#13;
        return true;&#13;
    }&#13;
    &#13;
    function callETH(address _to) payable public returns(bool) {&#13;
        _safeCall(_to, msg.value);&#13;
        return true;&#13;
    }&#13;
    &#13;
    function sendERC20(ERC20 _token, address _to, uint _amount) public returns(bool) {&#13;
        _safeERC20Transfer(_token, _to, _amount);&#13;
        return true;&#13;
    }&#13;
    &#13;
    function _safeTransfer(address _to, uint _amount) internal {&#13;
        require(_to != 0);&#13;
        _to.transfer(_amount);&#13;
    }&#13;
&#13;
    function _safeCall(address _to, uint _amount) internal {&#13;
        require(_to != 0);&#13;
        require(_to.call.value(_amount)());&#13;
    }&#13;
&#13;
    function _safeERC20Transfer(ERC20 _token, address _to, uint _amount) internal {&#13;
        require(_to != 0);&#13;
        require(_token.transferFrom(msg.sender, _to, _amount));&#13;
    }&#13;
}