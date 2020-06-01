pragma solidity ^0.4.15;


/// @title Abstract ERC20 token interface
contract AbstractToken {

    function totalSupply() constant returns (uint256) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Issuance(address indexed to, uint256 value);
}


contract Owned {

    address public owner = msg.sender;
    address public potentialOwner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPotentialOwner {
        require(msg.sender == potentialOwner);
        _;
    }

    event NewOwner(address old, address current);
    event NewPotentialOwner(address old, address potential);

    function setOwner(address _new)
        public
        onlyOwner
    {
        NewPotentialOwner(owner, _new);
        potentialOwner = _new;
    }

    function confirmOwnership()
        public
        onlyPotentialOwner
    {
        NewOwner(owner, potentialOwner);
        owner = potentialOwner;
        potentialOwner = 0;
    }
}


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
contract StandardToken is AbstractToken, Owned {

    /*
     *  Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    /*
     *  Read and write storage functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read storage functions
     */
    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}


/// @title SafeMath contract - Math operations with safety checks.
/// @author OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
contract SafeMath {
    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
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

    function pow(uint a, uint b) internal returns (uint) {
        uint c = a ** b;
        assert(c >= a);
        return c;
    }
}


/// @title Token contract - Implements Standard ERC20 with additional features.
/// @author Zerion - <<span class="__cf_email__" data-cfemail="b3c9d6c1dadcddf3daddd1dccb9dd0dcde">[email protected]</span>&gt;&#13;
contract Token is StandardToken, SafeMath {&#13;
    // Time of the contract creation&#13;
    uint public creationTime;&#13;
&#13;
    function Token() {&#13;
        creationTime = now;&#13;
    }&#13;
&#13;
&#13;
    /// @dev Owner can transfer out any accidentally sent ERC20 tokens&#13;
    function transferERC20Token(address tokenAddress)&#13;
        public&#13;
        onlyOwner&#13;
        returns (bool)&#13;
    {&#13;
        uint balance = AbstractToken(tokenAddress).balanceOf(this);&#13;
        return AbstractToken(tokenAddress).transfer(owner, balance);&#13;
    }&#13;
&#13;
    /// @dev Multiplies the given number by 10^(decimals)&#13;
    function withDecimals(uint number, uint decimals)&#13;
        internal&#13;
        returns (uint)&#13;
    {&#13;
        return mul(number, pow(10, decimals));&#13;
    }&#13;
}&#13;
&#13;
&#13;
/// @title Token contract - Implements Standard ERC20 Token with Poet features.&#13;
/// @author Zerion - &lt;<span class="__cf_email__" data-cfemail="532936213a3c3d133a3d313c2b7d303c3e">[email protected]</span>&gt;&#13;
contract PoetToken is Token {&#13;
&#13;
    /*&#13;
     * Token meta data&#13;
     */&#13;
    string constant public name = "Poet";&#13;
    string constant public symbol = "POE";&#13;
    uint8 constant public decimals = 8;  // TODO: Confirm this number&#13;
&#13;
    // Address where all investors tokens created during the ICO stage initially allocated&#13;
    address constant public icoAllocation = 0x1111111111111111111111111111111111111111;&#13;
&#13;
    // Address where Foundation tokens are allocated&#13;
    address constant public foundationReserve = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;&#13;
&#13;
    // Number of tokens initially allocated to Foundation&#13;
    uint foundationTokens;&#13;
&#13;
    // Store number of days in each month&#13;
    mapping(uint8 =&gt; uint8) daysInMonth;&#13;
&#13;
    // UNIX timestamp for September 1, 2017&#13;
    // It's a date when first 2% of foundation reserve will be unlocked&#13;
    uint Sept1_2017 = 1504224000;&#13;
&#13;
    // Number of days since September 1, 2017 before all tokens will be unlocked&#13;
    uint reserveDelta = 456;&#13;
&#13;
&#13;
    /// @dev Contract constructor function sets totalSupply and allocates all ICO tokens to the icoAllocation address&#13;
    function PoetToken()&#13;
    {   &#13;
        // Overall, 3,141,592,653 POE tokens are distributed&#13;
        totalSupply = withDecimals(3141592653, decimals);&#13;
&#13;
        // Allocate 32% of all tokens to Foundation&#13;
        foundationTokens = div(mul(totalSupply, 32), 100);&#13;
        balances[foundationReserve] = foundationTokens;&#13;
&#13;
        // Allocate the rest to icoAllocation address&#13;
        balances[icoAllocation] = sub(totalSupply, foundationTokens);&#13;
&#13;
        // Allow owner to distribute tokens allocated on the icoAllocation address&#13;
        allowed[icoAllocation][owner] = balanceOf(icoAllocation);&#13;
&#13;
        // Fill mapping with numbers of days&#13;
        // Note: we consider only February of 2018 that has 28 days&#13;
        daysInMonth[1]  = 31; daysInMonth[2]  = 28; daysInMonth[3]  = 31;&#13;
        daysInMonth[4]  = 30; daysInMonth[5]  = 31; daysInMonth[6]  = 30;&#13;
        daysInMonth[7]  = 31; daysInMonth[8]  = 31; daysInMonth[9]  = 30;&#13;
        daysInMonth[10] = 31; daysInMonth[11] = 30; daysInMonth[12] = 31;&#13;
    }&#13;
&#13;
    /// @dev Sends tokens from icoAllocation to investor&#13;
    function distribute(address investor, uint amount)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        transferFrom(icoAllocation, investor, amount);&#13;
    }&#13;
&#13;
    /// @dev Overrides Owned.sol function&#13;
    function confirmOwnership()&#13;
        public&#13;
        onlyPotentialOwner&#13;
    {   &#13;
        // Allow new owner to distribute tokens allocated on the icoAllocation address&#13;
        allowed[icoAllocation][potentialOwner] = balanceOf(icoAllocation);&#13;
&#13;
        // Forbid old owner to distribute tokens&#13;
        allowed[icoAllocation][owner] = 0;&#13;
&#13;
        // Forbid old owner to withdraw tokens from foundation reserve&#13;
        allowed[foundationReserve][owner] = 0;&#13;
&#13;
        // Change owner&#13;
        super.confirmOwnership();&#13;
    }&#13;
&#13;
    /// @dev Overrides StandardToken.sol function&#13;
    function allowance(address _owner, address _spender)&#13;
        public&#13;
        constant&#13;
        returns (uint256 remaining)&#13;
    {&#13;
        if (_owner == foundationReserve &amp;&amp; _spender == owner) {&#13;
            return availableReserve();&#13;
        }&#13;
&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    /// @dev Returns max number of tokens that actually can be withdrawn from foundation reserve&#13;
    function availableReserve() &#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {   &#13;
        // No tokens should be available for withdrawal before September 1, 2017&#13;
        if (now &lt; Sept1_2017) {&#13;
            return 0;&#13;
        }&#13;
&#13;
        // Number of days passed  since September 1, 2017&#13;
        uint daysPassed = div(sub(now, Sept1_2017), 1 days);&#13;
&#13;
        // All tokens should be unlocked if reserveDelta days passed&#13;
        if (daysPassed &gt;= reserveDelta) {&#13;
            return balanceOf(foundationReserve);&#13;
        }&#13;
&#13;
        // Percentage of unlocked tokens by the current date&#13;
        uint unlockedPercentage = 0;&#13;
&#13;
        uint16 _days = 0;  uint8 month = 9;&#13;
        while (_days &lt;= daysPassed) {&#13;
            unlockedPercentage += 2;&#13;
            _days += daysInMonth[month];&#13;
            month = month % 12 + 1;&#13;
        }&#13;
&#13;
        // Number of unlocked tokens by the current date&#13;
        uint unlockedTokens = div(mul(totalSupply, unlockedPercentage), 100);&#13;
&#13;
        // Number of tokens that should remain locked&#13;
        uint lockedTokens = foundationTokens - unlockedTokens;&#13;
&#13;
        return balanceOf(foundationReserve) - lockedTokens;&#13;
    }&#13;
&#13;
    /// @dev Withdraws tokens from foundation reserve&#13;
    function withdrawFromReserve(uint amount)&#13;
        public&#13;
        onlyOwner&#13;
    {   &#13;
        // Allow owner to withdraw no more than this amount of tokens&#13;
        allowed[foundationReserve][owner] = availableReserve();&#13;
&#13;
        // Withdraw tokens from foundation reserve to owner address&#13;
        require(transferFrom(foundationReserve, owner, amount));&#13;
    }&#13;
}