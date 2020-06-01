pragma solidity ^0.4.18;

/// @title Abstract token contract - Functions to be implemented by token contracts.
contract Token {
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);

    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions.
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/// @title Standard token contract - Standard token interface implementation.
contract StandardToken is Token {

    /*
     *  Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    /*
     *  Public functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    /// @return Returns success of function call.
    function transfer(address _to, uint256 _value)
        public
        returns (bool)
    {
        if (balances[msg.sender] < _value) {
            // Balance too low
            throw;
        }
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    /// @return Returns success of function call.
    function transferFrom(address _from, address _to, uint256 _value)
        public
        returns (bool)
    {
        if (balances[_from] < _value || allowed[_from][msg.sender] < _value) {
            // Balance or allowance too low
            throw;
        }
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    /// @return Returns success of function call.
    function approve(address _spender, uint256 _value)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read functions
     */
    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    /// @return Returns remaining allowance for spender.
    function allowance(address _owner, address _spender)
        constant
        public
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    /// @return Returns balance of owner.
    function balanceOf(address _owner)
        constant
        public
        returns (uint256)
    {
        return balances[_owner];
    }
}


/// @title Gnosis token contract
/// @author Stefan George - <<span class="__cf_email__" data-cfemail="7d0e09181b1c13531a18120f1a183d1e12130e18130e040e53131809">[email protected]</span>&gt;&#13;
contract GnosisToken is StandardToken {&#13;
&#13;
    /*&#13;
     *  Token meta data&#13;
     */&#13;
    string constant public name = "Gnosis Token";&#13;
    string constant public symbol = "GNO";&#13;
    uint8 constant public decimals = 18;&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Contract constructor function sets dutch auction contract address and assigns all tokens to dutch auction.&#13;
    /// @param dutchAuction Address of dutch auction contract.&#13;
    /// @param owners Array of addresses receiving preassigned tokens.&#13;
    /// @param tokens Array of preassigned token amounts.&#13;
    function GnosisToken(address dutchAuction, address[] owners, uint[] tokens)&#13;
        public&#13;
    {&#13;
        if (dutchAuction == 0)&#13;
            // Address should not be null.&#13;
            throw;&#13;
        totalSupply = 10000000 * 10**18;&#13;
        balances[dutchAuction] = 9000000 * 10**18;&#13;
        Transfer(0, dutchAuction, balances[dutchAuction]);&#13;
        uint assignedTokens = balances[dutchAuction];&#13;
        for (uint i=0; i&lt;owners.length; i++) {&#13;
            if (owners[i] == 0)&#13;
                // Address should not be null.&#13;
                throw;&#13;
            balances[owners[i]] += tokens[i];&#13;
            Transfer(0, owners[i], tokens[i]);&#13;
            assignedTokens += tokens[i];&#13;
        }&#13;
        if (assignedTokens != totalSupply)&#13;
            throw;&#13;
    }&#13;
}&#13;
&#13;
contract eda {&#13;
	// 1491955200 = 12. 4. 2017&#13;
	uint edaBirthday = 1491955200;&#13;
&#13;
	address dom = 0xC5c83A12501C6470B002E54409B024C02624AaAA;&#13;
	address majaALubo = 0x67f38b53c3aD78F045F75C805deFeA7086711e75;&#13;
&#13;
	address GNO = 0x6810e776880C02933D47DB1b9fc05908e5386b96;&#13;
&#13;
	bool domEarlyWithdrawApproval;&#13;
	bool majaALuboEarlyWithdrawApproval;&#13;
&#13;
	function withdrawEarly(address to)&#13;
		public&#13;
	{&#13;
		if (msg.sender == dom) {&#13;
			if (majaALuboEarlyWithdrawApproval == true) {&#13;
				withdraw(to);&#13;
			} else {&#13;
				domEarlyWithdrawApproval = true;&#13;
			}&#13;
		} else if (msg.sender == majaALubo) {&#13;
			if (domEarlyWithdrawApproval == true) {&#13;
				withdraw(to);&#13;
			} else {&#13;
				majaALuboEarlyWithdrawApproval = true;&#13;
			}&#13;
		}&#13;
	}&#13;
&#13;
	function withdraw(address to)&#13;
		internal&#13;
	{&#13;
		uint balance = GnosisToken(GNO).balanceOf(this);&#13;
		GnosisToken(GNO).transfer(to, balance);&#13;
	}&#13;
&#13;
	function withdrawAfter18Years(address to)&#13;
		public&#13;
	{&#13;
		// 567,648,000 = 18 years in s	&#13;
		require(now &gt;= edaBirthday + 567648000);&#13;
&#13;
		require(msg.sender == dom || msg.sender == majaALubo);&#13;
&#13;
		withdraw(to);&#13;
	}&#13;
}