pragma solidity ^0.4.15;

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

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
} 

contract AbstractSingularDTVFund {
    function softWithdrawRewardFor(address forAddress) returns (uint);
}

/// @title Token contract - Implements token issuance.
/// @author Stefan George - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6112150407000f4f06040e13060421020e0f12040f1218124f0f0415">[email protected]</a>&gt;&#13;
/// @author Milad Mostavi - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e38e8a8f8287cd8e8c909782958aa3808c8d90868d909a90cd8d8697">[email protected]</a>&gt;&#13;
contract SingularDTVToken is StandardToken {&#13;
    string public version = "0.1.0";&#13;
&#13;
    /*&#13;
     *  External contracts&#13;
     */&#13;
    AbstractSingularDTVFund public singularDTVFund;&#13;
&#13;
    /*&#13;
     *  Token meta data&#13;
     */&#13;
    string public name;&#13;
    string public symbol;&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    /// @dev Transfers sender's tokens to a given address. Returns success.&#13;
    /// @param to Address of token receiver.&#13;
    /// @param value Number of tokens to transfer.&#13;
    function transfer(address to, uint256 value)&#13;
        returns (bool)&#13;
    {&#13;
        // Both parties withdraw their reward first&#13;
        singularDTVFund.softWithdrawRewardFor(msg.sender);&#13;
        singularDTVFund.softWithdrawRewardFor(to);&#13;
        return super.transfer(to, value);&#13;
    }&#13;
&#13;
    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.&#13;
    /// @param from Address from where tokens are withdrawn.&#13;
    /// @param to Address to where tokens are sent.&#13;
    /// @param value Number of tokens to transfer.&#13;
    function transferFrom(address from, address to, uint256 value)&#13;
        returns (bool)&#13;
    {&#13;
        // Both parties withdraw their reward first&#13;
        singularDTVFund.softWithdrawRewardFor(from);&#13;
        singularDTVFund.softWithdrawRewardFor(to);&#13;
        return super.transferFrom(from, to, value);&#13;
    }&#13;
&#13;
    function SingularDTVToken(address sDTVFundAddr, address _wallet, string _name, string _symbol, uint _totalSupply) {&#13;
        if(sDTVFundAddr == 0 || _wallet == 0) {&#13;
            // Fund and Wallet addresses should not be null.&#13;
            revert();&#13;
        }&#13;
&#13;
        balances[_wallet] = _totalSupply;&#13;
        totalSupply = _totalSupply;&#13;
&#13;
        name = _name;&#13;
        symbol = _symbol;&#13;
&#13;
        singularDTVFund = AbstractSingularDTVFund(sDTVFundAddr);&#13;
&#13;
        Transfer(this, _wallet, _totalSupply);&#13;
    }&#13;
}