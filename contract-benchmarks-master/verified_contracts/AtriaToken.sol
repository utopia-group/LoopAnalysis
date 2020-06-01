pragma solidity 0.4.23;

//
// This source file is part of the current-contracts open source project
// Copyright 2018 Zerion LLC
// Licensed under Apache License v2.0
//


// @title Abstract ERC20 token interface
contract AbstractToken {
	function balanceOf(address owner) public view returns (uint256 balance);
	function transfer(address to, uint256 value) public returns (bool success);
	function transferFrom(address from, address to, uint256 value) public returns (bool success);
	function approve(address spender, uint256 value) public returns (bool success);
	function allowance(address owner, address spender) public view returns (uint256 remaining);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
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
		emit NewPotentialOwner(owner, _new);
		potentialOwner = _new;
	}

	function confirmOwnership()
		public
		onlyPotentialOwner
	{
		emit NewOwner(owner, potentialOwner);
		owner = potentialOwner;
		potentialOwner = address(0);
	}
}

// @title SafeMath contract - Math operations with safety checks.
// @author OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
contract SafeMath {
	/**
	* @dev Multiplies two numbers, throws on overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	/**
	* @dev Integer division of two numbers, truncating the quotient.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}

	/**
	* @dev Raises `a` to the `b`th power, throws on overflow.
	*/
	function pow(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a ** b;
		assert(c >= a);
		return c;
	}
}

/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
contract StandardToken is AbstractToken, Owned, SafeMath {

	/*
	 *  Data structures
	 */
	mapping (address => uint256) internal balances;
	mapping (address => mapping (address => uint256)) internal allowed;
	uint256 public totalSupply;

	/*
	 *  Read and write storage functions
	 */
	/// @dev Transfers sender's tokens to a given address. Returns success.
	/// @param _to Address of token receiver.
	/// @param _value Number of tokens to transfer.
	function transfer(address _to, uint256 _value) public returns (bool success) {
		return _transfer(msg.sender, _to, _value);
	}

	/// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
	/// @param _from Address from where tokens are withdrawn.
	/// @param _to Address to where tokens are sent.
	/// @param _value Number of tokens to transfer.
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(allowed[_from][msg.sender] >= _value);
		allowed[_from][msg.sender] -= _value;

		return _transfer(_from, _to, _value);
	}

	/// @dev Returns number of tokens owned by given address.
	/// @param _owner Address of token owner.
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}

	/// @dev Sets approved amount of tokens for spender. Returns success.
	/// @param _spender Address of allowed account.
	/// @param _value Number of approved tokens.
	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	/*
	 * Read storage functions
	 */
	/// @dev Returns number of allowed tokens for given address.
	/// @param _owner Address of token owner.
	/// @param _spender Address of token spender.
	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

	/**
	* @dev Private transfer, can only be called by this contract.
	* @param _from The address of the sender.
	* @param _to The address of the recipient.
	* @param _value The amount to send.
	* @return success True if the transfer was successful, or throws.
	*/
	function _transfer(address _from, address _to, uint256 _value) private returns (bool success) {
		require(_to != address(0));
		require(balances[_from] >= _value);
		balances[_from] -= _value;
		balances[_to] = add(balances[_to], _value);
		emit Transfer(_from, _to, _value);
		return true;
	}
}

/// @title Token contract - Implements Standard ERC20 with additional features.
/// @author Zerion - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c4adaaa6abbc84bea1b6adabaaeaadab">[email protected]</a>&gt;&#13;
contract Token is StandardToken {&#13;
&#13;
	// Time of the contract creation&#13;
	uint256 public creationTime;&#13;
&#13;
	function Token() public {&#13;
		/* solium-disable-next-line security/no-block-members */&#13;
		creationTime = now;&#13;
	}&#13;
&#13;
	/// @dev Owner can transfer out any accidentally sent ERC20 tokens&#13;
	function transferERC20Token(AbstractToken _token, address _to, uint256 _value)&#13;
		public&#13;
		onlyOwner&#13;
		returns (bool success)&#13;
	{&#13;
		require(_token.balanceOf(address(this)) &gt;= _value);&#13;
		uint256 receiverBalance = _token.balanceOf(_to);&#13;
		require(_token.transfer(_to, _value));&#13;
&#13;
		uint256 receiverNewBalance = _token.balanceOf(_to);&#13;
		assert(receiverNewBalance == add(receiverBalance, _value));&#13;
&#13;
		return true;&#13;
	}&#13;
&#13;
	/// @dev Increases approved amount of tokens for spender. Returns success.&#13;
	function increaseApproval(address _spender, uint256 _value) public returns (bool success) {&#13;
		allowed[msg.sender][_spender] = add(allowed[msg.sender][_spender], _value);&#13;
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
		return true;&#13;
	}&#13;
&#13;
	/// @dev Decreases approved amount of tokens for spender. Returns success.&#13;
	function decreaseApproval(address _spender, uint256 _value) public returns (bool success) {&#13;
		uint256 oldValue = allowed[msg.sender][_spender];&#13;
		if (_value &gt; oldValue) {&#13;
			allowed[msg.sender][_spender] = 0;&#13;
		} else {&#13;
			allowed[msg.sender][_spender] = sub(oldValue, _value);&#13;
		}&#13;
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
		return true;&#13;
	}&#13;
}&#13;
&#13;
// @title Token contract - Implements Standard ERC20 Token for Atria project.&#13;
/// @author Zerion - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c5acaba7aabd85bfa0b7acaaabebacaa">[email protected]</a>&gt;&#13;
contract AtriaToken is Token {&#13;
&#13;
	/// TOKEN META DATA&#13;
	string constant public name = 'Atria';&#13;
	string constant public symbol = 'ATR';&#13;
	uint8  constant public decimals = 18;&#13;
&#13;
&#13;
	/// ALOCATIONS&#13;
	// To calculate vesting periods we assume that 1 month is always equal to 30 days&#13;
&#13;
&#13;
	/*** Initial Investors' tokens ***/&#13;
&#13;
	// 600,000,000 (60%) tokens are distributed among initial investors&#13;
	// These tokens will be distributed without vesting&#13;
&#13;
	address public investorsAllocation = address(0x109FFda33B402c9ef7b143a4B3BBA33e0d184Bd2);&#13;
	uint256 public investorsTotal = 600000000e18;&#13;
&#13;
&#13;
	/*** Overdraft Reserves ***/&#13;
&#13;
	// 200,000,000 (20%) tokens will be eventually available for overdraft&#13;
	// These tokens will be distributed monthly with a 3 month cliff within a year&#13;
	// 33,333,333 tokens will be unlocked every month after the cliff&#13;
	// 2 tokens will be unlocked without vesting to ensure that total amount sums up to 200,000,000.&#13;
&#13;
	address public overdraftAllocation = address(0x0843CeE0526CA0EABD1a114b32BA80945AA11318);&#13;
	uint256 public overdraftTotal = 200000000e18;&#13;
	uint256 public overdraftPeriodAmount = 33333333e18;&#13;
	uint256 public overdraftUnvested = 2e18;&#13;
	uint256 public overdraftCliff = 3 * 30 days;&#13;
	uint256 public overdraftPeriodLength = 30 days;&#13;
	uint8   public overdraftPeriodsNumber = 6;&#13;
&#13;
&#13;
	/*** Tokens reserved for Founders and Team ***/&#13;
&#13;
	// 112,500,000 (11.25%) tokens will be eventually available for the team&#13;
	// These tokens will be distributed every 3 month without a cliff within 4 years&#13;
	// 7,031,250 tokens will be unlocked every 3 month&#13;
&#13;
	address public teamAllocation  = address(0x6aE3B1424f8EFB82d23C6238728a01E6DEf9bC1B);&#13;
	uint256 public teamTotal = 112500000e18;&#13;
	uint256 public teamPeriodAmount = 7031250e18;&#13;
	uint256 public teamUnvested = 0;&#13;
	uint256 public teamCliff = 0;&#13;
	uint256 public teamPeriodLength = 3 * 30 days;&#13;
	uint8   public teamPeriodsNumber = 16;&#13;
&#13;
&#13;
&#13;
	/*** Tokens reserved for Community Building and Airdrop Campaigns ***/&#13;
&#13;
	// 60,000,000 (6%) tokens will be eventually available for the community&#13;
	// 10,000,002 tokens will be available instantly without vesting&#13;
	// 49,999,998 tokens will be distributed every 3 month without a cliff within 18 months&#13;
	// 8,333,333 tokens will be unlocked every 3 month&#13;
&#13;
&#13;
	address public communityAllocation  = address(0xd1a47e1434D4f8115399f001e4303Ea7573543f8);&#13;
	uint256 public communityTotal = 60000000e18;&#13;
	uint256 public communityPeriodAmount = 8333333e18;&#13;
	uint256 public communityUnvested = 10000002e18;&#13;
	uint256 public communityCliff = 0;&#13;
	uint256 public communityPeriodLength = 3 * 30 days;&#13;
	uint8   public communityPeriodsNumber = 6;&#13;
&#13;
&#13;
&#13;
	/*** Tokens reserved for Advisors, Legal and PR ***/&#13;
&#13;
	// 27,500,000 (2.75%) tokens will be eventually available for advisers&#13;
	// 15,500,000 tokens will be available instantly without vesting&#13;
	// 12 000 000 tokens will be distributed monthly without a cliff within 6 months&#13;
	// 2,000,000 tokens will be unlocked every month&#13;
&#13;
	address public advisersAllocation  = address(0x38dB66CF226D48e673236bb0ee700b04fE777b76);&#13;
	uint256 public advisersTotal = 27500000e18;&#13;
	uint256 public advisersPeriodAmount = 2000000e18;&#13;
	uint256 public advisersUnvested = 15500000e18;&#13;
	uint256 public advisersCliff = 0;&#13;
	uint256 public advisersPeriodLength = 30 days;&#13;
	uint8   public advisersPeriodsNumber = 6;&#13;
&#13;
&#13;
	/// CONSTRUCTOR&#13;
&#13;
	function AtriaToken() public {&#13;
		//  Overall, 1,000,000,000 tokens exist&#13;
		totalSupply = 1000000000e18;&#13;
&#13;
		balances[investorsAllocation] = investorsTotal;&#13;
		balances[overdraftAllocation] = overdraftTotal;&#13;
		balances[teamAllocation] = teamTotal;&#13;
		balances[communityAllocation] = communityTotal;&#13;
		balances[advisersAllocation] = advisersTotal;&#13;
&#13;
		// Unlock some tokens without vesting&#13;
		allowed[investorsAllocation][msg.sender] = investorsTotal;&#13;
		allowed[overdraftAllocation][msg.sender] = overdraftUnvested;&#13;
		allowed[communityAllocation][msg.sender] = communityUnvested;&#13;
		allowed[advisersAllocation][msg.sender] = advisersUnvested;&#13;
	}&#13;
&#13;
	/// DISTRIBUTION&#13;
&#13;
	function distributeInvestorsTokens(address _to, uint256 _amountWithDecimals)&#13;
		public&#13;
		onlyOwner&#13;
	{&#13;
		require(transferFrom(investorsAllocation, _to, _amountWithDecimals));&#13;
	}&#13;
&#13;
	/// VESTING&#13;
&#13;
	function withdrawOverdraftTokens(address _to, uint256 _amountWithDecimals)&#13;
		public&#13;
		onlyOwner&#13;
	{&#13;
		allowed[overdraftAllocation][msg.sender] = allowance(overdraftAllocation, msg.sender);&#13;
		require(transferFrom(overdraftAllocation, _to, _amountWithDecimals));&#13;
	}&#13;
&#13;
	function withdrawTeamTokens(address _to, uint256 _amountWithDecimals)&#13;
		public&#13;
		onlyOwner &#13;
	{&#13;
		allowed[teamAllocation][msg.sender] = allowance(teamAllocation, msg.sender);&#13;
		require(transferFrom(teamAllocation, _to, _amountWithDecimals));&#13;
	}&#13;
&#13;
	function withdrawCommunityTokens(address _to, uint256 _amountWithDecimals)&#13;
		public&#13;
		onlyOwner &#13;
	{&#13;
		allowed[communityAllocation][msg.sender] = allowance(communityAllocation, msg.sender);&#13;
		require(transferFrom(communityAllocation, _to, _amountWithDecimals));&#13;
	}&#13;
&#13;
	function withdrawAdvisersTokens(address _to, uint256 _amountWithDecimals)&#13;
		public&#13;
		onlyOwner &#13;
	{&#13;
		allowed[advisersAllocation][msg.sender] = allowance(advisersAllocation, msg.sender);&#13;
		require(transferFrom(advisersAllocation, _to, _amountWithDecimals));&#13;
	}&#13;
&#13;
	/// @dev Overrides StandardToken.sol function&#13;
	function allowance(address _owner, address _spender)&#13;
		public&#13;
		view&#13;
		returns (uint256 remaining)&#13;
	{   &#13;
		if (_spender != owner) {&#13;
			return allowed[_owner][_spender];&#13;
		}&#13;
&#13;
		uint256 unlockedTokens;&#13;
		uint256 spentTokens;&#13;
&#13;
		if (_owner == overdraftAllocation) {&#13;
			unlockedTokens = _calculateUnlockedTokens(&#13;
				overdraftCliff,&#13;
				overdraftPeriodLength,&#13;
				overdraftPeriodAmount,&#13;
				overdraftPeriodsNumber,&#13;
				overdraftUnvested&#13;
			);&#13;
			spentTokens = sub(overdraftTotal, balanceOf(overdraftAllocation));&#13;
		} else if (_owner == teamAllocation) {&#13;
			unlockedTokens = _calculateUnlockedTokens(&#13;
				teamCliff,&#13;
				teamPeriodLength,&#13;
				teamPeriodAmount,&#13;
				teamPeriodsNumber,&#13;
				teamUnvested&#13;
			);&#13;
			spentTokens = sub(teamTotal, balanceOf(teamAllocation));&#13;
		} else if (_owner == communityAllocation) {&#13;
			unlockedTokens = _calculateUnlockedTokens(&#13;
				communityCliff,&#13;
				communityPeriodLength,&#13;
				communityPeriodAmount,&#13;
				communityPeriodsNumber,&#13;
				communityUnvested&#13;
			);&#13;
			spentTokens = sub(communityTotal, balanceOf(communityAllocation));&#13;
		} else if (_owner == advisersAllocation) {&#13;
			unlockedTokens = _calculateUnlockedTokens(&#13;
				advisersCliff,&#13;
				advisersPeriodLength,&#13;
				advisersPeriodAmount,&#13;
				advisersPeriodsNumber,&#13;
				advisersUnvested&#13;
			);&#13;
			spentTokens = sub(advisersTotal, balanceOf(advisersAllocation));&#13;
		} else {&#13;
			return allowed[_owner][_spender];&#13;
		}&#13;
&#13;
		return sub(unlockedTokens, spentTokens);&#13;
	}&#13;
&#13;
	/// @dev Overrides Owned.sol function&#13;
	function confirmOwnership()&#13;
		public&#13;
		onlyPotentialOwner&#13;
	{   &#13;
		// Forbid the old owner to distribute investors' tokens&#13;
		allowed[investorsAllocation][owner] = 0;&#13;
&#13;
		// Allow the new owner to distribute investors' tokens&#13;
		allowed[investorsAllocation][msg.sender] = balanceOf(investorsAllocation);&#13;
&#13;
		// Forbid the old owner to withdraw any tokens from the reserves&#13;
		allowed[overdraftAllocation][owner] = 0;&#13;
		allowed[teamAllocation][owner] = 0;&#13;
		allowed[communityAllocation][owner] = 0;&#13;
		allowed[advisersAllocation][owner] = 0;&#13;
&#13;
		super.confirmOwnership();&#13;
	}&#13;
&#13;
	function _calculateUnlockedTokens(&#13;
		uint256 _cliff,&#13;
		uint256 _periodLength,&#13;
		uint256 _periodAmount,&#13;
		uint8 _periodsNumber,&#13;
		uint256 _unvestedAmount&#13;
	)&#13;
		private&#13;
		view&#13;
		returns (uint256) &#13;
	{&#13;
		/* solium-disable-next-line security/no-block-members */&#13;
		if (now &lt; add(creationTime, _cliff)) {&#13;
			return _unvestedAmount;&#13;
		}&#13;
		/* solium-disable-next-line security/no-block-members */&#13;
		uint256 periods = div(sub(now, add(creationTime, _cliff)), _periodLength);&#13;
		periods = periods &gt; _periodsNumber ? _periodsNumber : periods;&#13;
		return add(_unvestedAmount, mul(periods, _periodAmount));&#13;
	}&#13;
}