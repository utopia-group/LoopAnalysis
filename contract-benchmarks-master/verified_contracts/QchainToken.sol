pragma solidity ^0.4.18;


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
/// @author Zerion - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f59c9b979a8db58f90879c9a9bdb9c9a">[email protected]</a>&gt;&#13;
contract Token is StandardToken, SafeMath {&#13;
&#13;
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
/// @title Token contract - Implements Standard ERC20 Token for Qchain project.&#13;
/// @author Zerion - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ddb4b3bfb2a59da7b8afb4b2b3f3b4b2">[email protected]</a>&gt;&#13;
contract QchainToken is Token {&#13;
&#13;
    /*&#13;
     * Token meta data&#13;
     */&#13;
    string constant public name = "Ethereum Qchain Token";&#13;
    string constant public symbol = "EQC";&#13;
    uint8 constant public decimals = 8;&#13;
&#13;
    // Address where Foundation tokens are allocated&#13;
    address constant public foundationReserve = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;&#13;
&#13;
    // Address where all tokens for the ICO stage are initially allocated&#13;
    address constant public icoAllocation = 0x1111111111111111111111111111111111111111;&#13;
&#13;
    // Address where all tokens for the PreICO are initially allocated&#13;
    address constant public preIcoAllocation = 0x2222222222222222222222222222222222222222;&#13;
&#13;
    // ICO start date. 10/24/2017 @ 9:00pm (UTC)&#13;
    uint256 constant public startDate = 1508878800;&#13;
    uint256 constant public duration = 42 days;&#13;
&#13;
    // Public key of the signer&#13;
    address public signer;&#13;
&#13;
    // Foundation multisignature wallet, all Ether is collected there&#13;
    address public multisig;&#13;
&#13;
    /// @dev Contract constructor, sets totalSupply&#13;
    function QchainToken(address _signer, address _multisig)&#13;
    {&#13;
        // Overall, 375,000,000 EQC tokens are distributed&#13;
        totalSupply = withDecimals(375000000, decimals);&#13;
&#13;
        // 11,500,000 tokens were sold during the PreICO&#13;
        uint preIcoTokens = withDecimals(11500000, decimals);&#13;
&#13;
        // 40% of total supply is allocated for the Foundation&#13;
        balances[foundationReserve] = div(mul(totalSupply, 40), 100);&#13;
&#13;
        // PreICO tokens are allocated to the special address and will be distributed manually&#13;
        balances[preIcoAllocation] = preIcoTokens;&#13;
&#13;
        // The rest of the tokens is available for sale&#13;
        balances[icoAllocation] = totalSupply - preIcoTokens - balanceOf(foundationReserve);&#13;
&#13;
        // Allow the owner to distribute tokens from the PreICO allocation address&#13;
        allowed[preIcoAllocation][msg.sender] = balanceOf(preIcoAllocation);&#13;
&#13;
        // Allow the owner to withdraw tokens from the Foundation reserve&#13;
        allowed[foundationReserve][msg.sender] = balanceOf(foundationReserve);&#13;
&#13;
        signer = _signer;&#13;
        multisig = _multisig;&#13;
    }&#13;
&#13;
    modifier icoIsActive {&#13;
        require(now &gt;= startDate &amp;&amp; now &lt; startDate + duration);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier icoIsCompleted {&#13;
        require(now &gt;= startDate + duration);&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev Settle an investment and distribute tokens&#13;
    function invest(address investor, uint256 tokenPrice, uint256 value, bytes32 hash, uint8 v, bytes32 r, bytes32 s)&#13;
        public&#13;
        icoIsActive&#13;
        payable&#13;
    {&#13;
        // Check the hash&#13;
        require(sha256(uint(investor) &lt;&lt; 96 | tokenPrice) == hash);&#13;
&#13;
        // Check the signature&#13;
        require(ecrecover(hash, v, r, s) == signer);&#13;
&#13;
        // Difference between the value argument and actual value should not be&#13;
        // more than 0.005 ETH (gas commission)&#13;
        require(sub(value, msg.value) &lt;= withDecimals(5, 15));&#13;
&#13;
        // Number of tokens to distribute&#13;
        uint256 tokensNumber = div(withDecimals(value, decimals), tokenPrice);&#13;
&#13;
        // Check if there is enough tokens left&#13;
        require(balances[icoAllocation] &gt;= tokensNumber);&#13;
&#13;
        // Send Ether to the multisig&#13;
        require(multisig.send(msg.value));&#13;
&#13;
        // Allocate tokens to an investor&#13;
        balances[icoAllocation] = sub(balances[icoAllocation], tokensNumber);&#13;
        balances[investor] = add(balances[icoAllocation], tokensNumber);&#13;
        Transfer(icoAllocation, investor, tokensNumber);&#13;
    }&#13;
&#13;
    /// @dev Overrides Owned.sol function&#13;
    function confirmOwnership()&#13;
        public&#13;
        onlyPotentialOwner&#13;
    {&#13;
        // Allow new owner to withdraw tokens from Foundation reserve and&#13;
        // preICO allocation address&#13;
        allowed[foundationReserve][potentialOwner] = balanceOf(foundationReserve);&#13;
        allowed[preIcoAllocation][potentialOwner] = balanceOf(preIcoAllocation);&#13;
&#13;
        // Forbid old owner to withdraw tokens from Foundation reserve and&#13;
        // preICO allocation address&#13;
        allowed[foundationReserve][owner] = 0;&#13;
        allowed[preIcoAllocation][owner] = 0;&#13;
&#13;
        // Change owner&#13;
        super.confirmOwnership();&#13;
    }&#13;
&#13;
    /// @dev Withdraws tokens from Foundation reserve&#13;
    function withdrawFromReserve(uint amount)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        // Withdraw tokens from Foundation reserve to multisig address&#13;
        require(transferFrom(foundationReserve, multisig, amount));&#13;
    }&#13;
&#13;
    /// @dev Changes multisig address&#13;
    function changeMultisig(address _multisig)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        multisig = _multisig;&#13;
    }&#13;
&#13;
    /// @dev Burns the rest of the tokens after the crowdsale end&#13;
    function burn()&#13;
        public&#13;
        onlyOwner&#13;
        icoIsCompleted&#13;
    {&#13;
        totalSupply = sub(totalSupply, balanceOf(icoAllocation));&#13;
        balances[icoAllocation] = 0;&#13;
    }&#13;
}