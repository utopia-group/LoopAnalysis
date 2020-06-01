pragma solidity ^0.4.21;



/**
 * @title AddressTools
 * @dev Useful tools for address type
 */
library AddressTools {
	
	/**
	* @dev Returns true if given address is the contract address, otherwise - returns false
	*/
	function isContract(address a) internal view returns (bool) {
		if(a == address(0)) {
			return false;
		}
		
		uint codeSize;
		// solium-disable-next-line security/no-inline-assembly
		assembly {
			codeSize := extcodesize(a)
		}
		
		if(codeSize > 0) {
			return true;
		}
		
		return false;
	}
	
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
	
	address public owner;
	address public potentialOwner;
	
	
	event OwnershipRemoved(address indexed previousOwner);
	event OwnershipTransfer(address indexed previousOwner, address indexed newOwner);
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	
	
	/**
	 * @dev The Ownable constructor sets the original `owner` of the contract to the sender
	 * account.
	 */
	function Ownable() public {
		owner = msg.sender;
	}
	
	
	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}
	
	
	/**
	 * @dev Throws if called by any account other than the owner.
	 */
	modifier onlyPotentialOwner() {
		require(msg.sender == potentialOwner);
		_;
	}
	
	
	/**
	 * @dev Allows the current owner to transfer control of the contract to a newOwner.
	 * @param newOwner The address of potential new owner to transfer ownership to.
	 */
	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		emit OwnershipTransfer(owner, newOwner);
		potentialOwner = newOwner;
	}
	
	
	/**
	 * @dev Allow the potential owner confirm ownership of the contract.
	 */
	function confirmOwnership() public onlyPotentialOwner {
		emit OwnershipTransferred(owner, potentialOwner);
		owner = potentialOwner;
		potentialOwner = address(0);
	}
	
	
	/**
	 * @dev Remove the contract owner permanently
	 */
	function removeOwnership() public onlyOwner {
		emit OwnershipRemoved(owner);
		owner = address(0);
	}
	
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
	
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
		uint256 c = a / b;
		return c;
	}
	
	
	/**
	* @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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
	* @dev Powers the first number to the second, throws on overflow.
	*/
	function pow(uint a, uint b) internal pure returns (uint) {
		if (b == 0) {
			return 1;
		}
		uint c = a ** b;
		assert(c >= a);
		return c;
	}
	
	
	/**
	 * @dev Multiplies the given number by 10**decimals
	 */
	function withDecimals(uint number, uint decimals) internal pure returns (uint) {
		return mul(number, pow(10, decimals));
	}
	
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
	function totalSupply() public view returns (uint256);
	function balanceOf(address who) public view returns (uint256);
	function transfer(address to, uint256 value) public returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
	
	using SafeMath for uint256;
	
	mapping(address => uint256) public balances;
	
	uint256 public totalSupply_;
	
	
	/**
	* @dev total number of tokens in existence
	*/
	function totalSupply() public view returns (uint256) {
		return totalSupply_;
	}
	
	
	/**
	* @dev transfer token for a specified address
	* @param _to The address to transfer to.
	* @param _value The amount to be transferred.
	*/
	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(_value <= balances[msg.sender]);
		
		// SafeMath.sub will throw if there is not enough balance.
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}
	
	
	/**
	* @dev Gets the balance of the specified address.
	* @param _owner The address to query the the balance of.
	* @return An uint256 representing the amount owned by the passed address.
	*/
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}
	
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {
	
	event Burn(address indexed burner, uint256 value);
	
	/**
	 * @dev Burns a specific amount of tokens.
	 * @param _value The amount of token to be burned.
	 */
	function burn(uint256 _value) public {
		require(_value <= balances[msg.sender]);
		// no need to require value <= totalSupply, since that would imply the
		// sender's balance is greater than the totalSupply, which *should* be an assertion failure
		
		address burner = msg.sender;
		balances[burner] = balances[burner].sub(_value);
		totalSupply_ = totalSupply_.sub(_value);
		emit Burn(burner, _value);
		emit Transfer(burner, address(0), _value);
	}
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) public view returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title ERC223 interface
 * @dev see https://github.com/ethereum/EIPs/issues/223
 */
contract ERC223 is ERC20 {
	function transfer(address to, uint256 value, bytes data) public returns (bool);
	event ERC223Transfer(address indexed from, address indexed to, uint256 value, bytes data);
}

/**
 * @title UKTTokenBasic
 * @dev UKTTokenBasic interface
 */
contract UKTTokenBasic is ERC223, BurnableToken {
	
	bool public isControlled = false;
	bool public isConfigured = false;
	bool public isAllocated = false;
	
	// mapping of string labels to initial allocated addresses
	mapping(bytes32 => address) public allocationAddressesTypes;
	// mapping of addresses to time lock period
	mapping(address => uint32) public timelockedAddresses;
	// mapping of addresses to lock flag
	mapping(address => bool) public lockedAddresses;
	
	
	function setConfiguration(string _name, string _symbol, uint _totalSupply) external returns (bool);
	function setInitialAllocation(address[] addresses, bytes32[] addressesTypes, uint[] amounts) external returns (bool);
	function setInitialAllocationLock(address allocationAddress ) external returns (bool);
	function setInitialAllocationUnlock(address allocationAddress ) external returns (bool);
	function setInitialAllocationTimelock(address allocationAddress, uint32 timelockTillDate ) external returns (bool);
	
	// fires when the token contract becomes controlled
	event Controlled(address indexed tokenController);
	// fires when the token contract becomes configured
	event Configured(string tokenName, string tokenSymbol, uint totalSupply);
	event InitiallyAllocated(address indexed owner, bytes32 addressType, uint balance);
	event InitiallAllocationLocked(address indexed owner);
	event InitiallAllocationUnlocked(address indexed owner);
	event InitiallAllocationTimelocked(address indexed owner, uint32 timestamp);
	
}

/**
 * @title  Basic controller contract for basic UKT token
 * @author  Oleg Levshin <<span class="__cf_email__" data-cfemail="09656c7f7a616067497c6a6673247d6c686427676c7d">[email protected]</span>&gt;&#13;
 */&#13;
contract UKTTokenController is Ownable {&#13;
	&#13;
	using SafeMath for uint256;&#13;
	using AddressTools for address;&#13;
	&#13;
	bool public isFinalized = false;&#13;
	&#13;
	// address of the controlled token&#13;
	UKTTokenBasic public token;&#13;
	// finalize function type. One of two values is possible: "transfer" or "burn"&#13;
	bytes32 public finalizeType = "transfer";&#13;
	// address type where finalize function will transfer undistributed tokens&#13;
	bytes32 public finalizeTransferAddressType = "";&#13;
	// maximum quantity of addresses to distribute&#13;
	uint8 internal MAX_ADDRESSES_FOR_DISTRIBUTE = 100;&#13;
	// list of locked initial allocation addresses&#13;
	address[] internal lockedAddressesList;&#13;
	&#13;
	&#13;
	// fires when tokens distributed to holder&#13;
	event Distributed(address indexed holder, bytes32 indexed trackingId, uint256 amount);&#13;
	// fires when tokens distribution is finalized&#13;
	event Finalized();&#13;
	&#13;
	/**&#13;
	 * @dev The UKTTokenController constructor&#13;
	 */&#13;
	function UKTTokenController(&#13;
		bytes32 _finalizeType,&#13;
		bytes32 _finalizeTransferAddressType&#13;
	) public {&#13;
		require(_finalizeType == "transfer" || _finalizeType == "burn");&#13;
		&#13;
		if (_finalizeType == "transfer") {&#13;
			require(_finalizeTransferAddressType != "");&#13;
		} else if (_finalizeType == "burn") {&#13;
			require(_finalizeTransferAddressType == "");&#13;
		}&#13;
		&#13;
		finalizeType = _finalizeType;&#13;
		finalizeTransferAddressType = _finalizeTransferAddressType;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Sets controlled token&#13;
	 */&#13;
	function setToken (&#13;
		address _token&#13;
	) public onlyOwner returns (bool) {&#13;
		require(token == address(0));&#13;
		require(_token.isContract());&#13;
		&#13;
		token = UKTTokenBasic(_token);&#13;
		&#13;
		return true;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Configures controlled token params&#13;
	 */&#13;
	function configureTokenParams(&#13;
		string _name,&#13;
		string _symbol,&#13;
		uint _totalSupply&#13;
	) public onlyOwner returns (bool) {&#13;
		require(token != address(0));&#13;
		return token.setConfiguration(_name, _symbol, _totalSupply);&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Allocates initial ICO balances (like team, advisory tokens and others)&#13;
	 */&#13;
	function allocateInitialBalances(&#13;
		address[] addresses,&#13;
		bytes32[] addressesTypes,&#13;
		uint[] amounts&#13;
	) public onlyOwner returns (bool) {&#13;
		require(token != address(0));&#13;
		return token.setInitialAllocation(addresses, addressesTypes, amounts);&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Locks given allocation address&#13;
	 */&#13;
	function lockAllocationAddress(&#13;
		address allocationAddress&#13;
	) public onlyOwner returns (bool) {&#13;
		require(token != address(0));&#13;
		token.setInitialAllocationLock(allocationAddress);&#13;
		lockedAddressesList.push(allocationAddress);&#13;
		return true;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Unlocks given allocation address&#13;
	 */&#13;
	function unlockAllocationAddress(&#13;
		address allocationAddress&#13;
	) public onlyOwner returns (bool) {&#13;
		require(token != address(0));&#13;
		&#13;
		token.setInitialAllocationUnlock(allocationAddress);&#13;
		&#13;
		for (uint idx = 0; idx &lt; lockedAddressesList.length; idx++) {&#13;
			if (lockedAddressesList[idx] == allocationAddress) {&#13;
				lockedAddressesList[idx] = address(0);&#13;
				break;&#13;
			}&#13;
		}&#13;
		&#13;
		return true;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Unlocks all allocation addresses&#13;
	 */&#13;
	function unlockAllAllocationAddresses() public onlyOwner returns (bool) {&#13;
		for(uint a = 0; a &lt; lockedAddressesList.length; a++) {&#13;
			if (lockedAddressesList[a] == address(0)) {&#13;
				continue;&#13;
			}&#13;
			unlockAllocationAddress(lockedAddressesList[a]);&#13;
		}&#13;
		&#13;
		return true;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Locks given allocation address with timestamp&#13;
	 */&#13;
	function timelockAllocationAddress(&#13;
		address allocationAddress,&#13;
		uint32 timelockTillDate&#13;
	) public onlyOwner returns (bool) {&#13;
		require(token != address(0));&#13;
		return token.setInitialAllocationTimelock(allocationAddress, timelockTillDate);&#13;
	}&#13;
	&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Distributes tokens to holders (investors)&#13;
	 */&#13;
	function distribute(&#13;
		address[] addresses,&#13;
		uint[] amounts,&#13;
		bytes32[] trackingIds&#13;
	) public onlyOwner returns (bool) {&#13;
		require(token != address(0));&#13;
		// quantity of addresses should be less than MAX_ADDRESSES_FOR_DISTRIBUTE&#13;
		require(addresses.length &lt; MAX_ADDRESSES_FOR_DISTRIBUTE);&#13;
		// the array of addresses should be the same length as the array of amounts&#13;
		require(addresses.length == amounts.length &amp;&amp; addresses.length == trackingIds.length);&#13;
		&#13;
		for(uint a = 0; a &lt; addresses.length; a++) {&#13;
			token.transfer(addresses[a], amounts[a]);&#13;
			emit Distributed(addresses[a], trackingIds[a], amounts[a]);&#13;
		}&#13;
		&#13;
		return true;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Finalizes the ability to use the controller and destructs it&#13;
	 */&#13;
	function finalize() public onlyOwner {&#13;
		&#13;
		if (finalizeType == "transfer") {&#13;
			// transfer all undistributed tokens to particular address&#13;
			token.transfer(&#13;
				token.allocationAddressesTypes(finalizeTransferAddressType),&#13;
				token.balanceOf(this)&#13;
			);&#13;
		} else if (finalizeType == "burn") {&#13;
			// burn all undistributed tokens&#13;
			token.burn(token.balanceOf(this));&#13;
		}&#13;
		&#13;
		require(unlockAllAllocationAddresses());&#13;
		&#13;
		removeOwnership();&#13;
		&#13;
		isFinalized = true;&#13;
		emit Finalized();&#13;
	}&#13;
	&#13;
}