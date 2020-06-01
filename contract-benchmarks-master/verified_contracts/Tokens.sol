// MarketPay-System-1.2.sol

/*
MarketPay Solidity Libraries
developed by:
	MarketPay.io , 2018
	https://marketpay.io/
	https://goo.gl/kdECQu

v1.2 
	+ Haltable by SC owner
	+ Constructors upgraded to new syntax
	
v1.1 
	+ Upgraded to Solidity 0.4.22
	
v1.0
	+ System functions

*/

pragma solidity ^0.4.23;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

	/**
    * @dev Multiplies two numbers, throws on overflow.
    */
	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
		if (a == 0) {
			return 0;
		}
		c = a * b;
		assert(c / a == b);
		return c;
	}

	/**
    * @dev Integer division of two numbers, truncating the quotient.
    */
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		// uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
	}
}
/**
 * @title System
 * @dev Abstract contract that includes some useful generic functions.
 * @author https://marketpay.io/ & https://goo.gl/kdECQu
 */
contract System {
	using SafeMath for uint256;
	
	address owner;
	
	// **** MODIFIERS

	// @notice To limit functions usage to contract owner
	modifier onlyOwner() {
		if (msg.sender != owner) {
			error('System: onlyOwner function called by user that is not owner');
		} else {
			_;
		}
	}

	// **** FUNCTIONS
	
	// @notice Calls whenever an error occurs, logs it or reverts transaction
	function error(string _error) internal {
		revert(_error);
		// in case revert with error msg is not yet fully supported
		//	emit Error(_error);
		// throw;
	}

	// @notice For debugging purposes when using solidity online browser, remix and sandboxes
	function whoAmI() public constant returns (address) {
		return msg.sender;
	}
	
	// @notice Get the current timestamp from last mined block
	function timestamp() public constant returns (uint256) {
		return block.timestamp;
	}
	
	// @notice Get the balance in weis of this contract
	function contractBalance() public constant returns (uint256) {
		return address(this).balance;
	}
	
	// @notice System constructor, defines owner
	constructor() public {
		// This is the constructor, so owner should be equal to msg.sender, and this method should be called just once
		owner = msg.sender;
		
		// make sure owner address is configured
		if(owner == 0x0) error('System constructor: Owner address is 0x0'); // Never should happen, but just in case...
	}
	
	// **** EVENTS

	// @notice A generic error log
	event Error(string _error);

	// @notice For debug purposes
	event DebugUint256(uint256 _data);

}

/**
 * @title Haltable
 * @dev Abstract contract that allows children to implement an emergency stop mechanism.
 */
contract Haltable is System {
	bool public halted;
	
	// **** MODIFIERS

	modifier stopInEmergency {
		if (halted) {
			error('Haltable: stopInEmergency function called and contract is halted');
		} else {
			_;
		}
	}

	modifier onlyInEmergency {
		if (!halted) {
			error('Haltable: onlyInEmergency function called and contract is not halted');
		} {
			_;
		}
	}

	// **** FUNCTIONS
	
	// called by the owner on emergency, triggers stopped state
	function halt() external onlyOwner {
		halted = true;
		emit Halt(true, msg.sender, timestamp()); // Event log
	}

	// called by the owner on end of emergency, returns to normal state
	function unhalt() external onlyOwner onlyInEmergency {
		halted = false;
		emit Halt(false, msg.sender, timestamp()); // Event log
	}
	
	// **** EVENTS
	// @notice Triggered when owner halts contract
	event Halt(bool _switch, address _halter, uint256 _timestamp);
}

/**
 * @title Hardcoded Wallets
 * @notice This contract is used to define oracle wallets
 * @author https://marketpay.io/ & https://goo.gl/kdECQu
 */
contract HardcodedWallets {
	// **** DATA

	address public walletFounder1; // founder #1 wallet, CEO, compulsory
	address public walletFounder2; // founder #2 wallet
	address public walletFounder3; // founder #3 wallet
	address public walletCommunityReserve;	// Distribution wallet
	address public walletCompanyReserve;	// Distribution wallet
	address public walletTeamAdvisors;		// Distribution wallet
	address public walletBountyProgram;		// Distribution wallet


	// **** FUNCTIONS

	/**
	 * @notice Constructor, set up the compliance officer oracle wallet
	 */
	constructor() public {
		// set up the founders' oracle wallets
		walletFounder1             = 0x5E69332F57Ac45F5fCA43B6b007E8A7b138c2938; // founder #1 (CEO) wallet
		walletFounder2             = 0x852f9a94a29d68CB95Bf39065BED6121ABf87607; // founder #2 wallet
		walletFounder3             = 0x0a339965e52dF2c6253989F5E9173f1F11842D83; // founder #3 wallet

		// set up the wallets for distribution of the total supply of tokens
		walletCommunityReserve = 0xB79116a062939534042d932fe5DF035E68576547;
		walletCompanyReserve = 0xA6845689FE819f2f73a6b9C6B0D30aD6b4a006d8;
		walletTeamAdvisors = 0x0227038b2560dF1abf3F8C906016Af0040bc894a;
		walletBountyProgram = 0xdd401Df9a049F6788cA78b944c64D21760757D73;

	}
}

// Minimal interface of ERC20 token contract, just to cast the contract address and make it callable from the ICO and other contracts
contract ERC20 {
	function balanceOf(address _owner) public constant returns (uint256 balance);
	function transfer(address _to, uint256 _amount) public returns (bool success);
	function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
	function totalSupply() public constant returns (uint);
}

/**
 * @title Escrow
 * @author https://marketpay.io/ & https://goo.gl/kdECQu
 */
contract Escrow is System, HardcodedWallets {
	using SafeMath for uint256;

	// **** DATA
	mapping (address => uint256) public deposited;
	uint256 nextStage;

	// Circular reference to ICO contract
	address public addressSCICO;

	// Circular reference to Tokens contract
	address public addressSCTokens;
	Tokens public SCTokens;


	// **** FUNCTIONS

	/**
	 * @notice Constructor, set up the state
	 */
	constructor() public {
		// copy totalSupply from Tokens to save gas
		uint256 totalSupply = 1350000000 ether;


		deposited[this] = totalSupply.mul(50).div(100);
		deposited[walletCommunityReserve] = totalSupply.mul(20).div(100);
		deposited[walletCompanyReserve] = totalSupply.mul(14).div(100);
		deposited[walletTeamAdvisors] = totalSupply.mul(15).div(100);
		deposited[walletBountyProgram] = totalSupply.mul(1).div(100);
	}

	function deposit(uint256 _amount) public returns (bool) {
		// only ICO could deposit
		if (msg.sender != addressSCICO) {
			error('Escrow: not allowed to deposit');
			return false;
		}
		deposited[this] = deposited[this].add(_amount);
		return true;
	}

	/**
	 * @notice Withdraw funds from the tokens contract
	 */
	function withdraw(address _address, uint256 _amount) public onlyOwner returns (bool) {
		if (deposited[_address]<_amount) {
			error('Escrow: not enough balance');
			return false;
		}
		deposited[_address] = deposited[_address].sub(_amount);
		return SCTokens.transfer(_address, _amount);
	}

	/**
	 * @notice Withdraw funds from the tokens contract
	 */
	function fundICO(uint256 _amount, uint8 _stage) public returns (bool) {
		if(nextStage !=_stage) {
			error('Escrow: ICO stage already funded');
			return false;
		}

		if (msg.sender != addressSCICO || tx.origin != owner) {
			error('Escrow: not allowed to fund the ICO');
			return false;
		}
		if (deposited[this]<_amount) {
			error('Escrow: not enough balance');
			return false;
		}
		bool success = SCTokens.transfer(addressSCICO, _amount);
		if(success) {
			deposited[this] = deposited[this].sub(_amount);
			nextStage++;
			emit FundICO(addressSCICO, _amount);
		}
		return success;
	}

	/**
 	* @notice The owner can specify which ICO contract is allowed to transfer tokens while timelock is on
 	*/
	function setMyICOContract(address _SCICO) public onlyOwner {
		addressSCICO = _SCICO;
	}

	/**
 	* @notice Set the tokens contract
 	*/
	function setTokensContract(address _addressSCTokens) public onlyOwner {
		addressSCTokens = _addressSCTokens;
		SCTokens = Tokens(_addressSCTokens);
	}

	/**
	 * @notice Returns balance of given address
	 */
	function balanceOf(address _address) public constant returns (uint256 balance) {
		return deposited[_address];
	}


	// **** EVENTS

	// Triggered when an investor buys some tokens directly with Ethers
	event FundICO(address indexed _addressICO, uint256 _amount);


}

contract ComplianceService {
	function validate(address _from, address _to, uint256 _amount) public returns (bool allowed) {
		return true;
	}
}



/**
 * @title Tokens
 * @notice ERC20 implementation of TRT tokens
 * @author https://marketpay.io/ & https://goo.gl/kdECQu
 */
contract Tokens is HardcodedWallets, ERC20, Haltable {

	// **** DATA

	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	uint256 public _totalSupply; 

	// Public variables of the token, all used for display
	string public name;
	string public symbol;
	uint8 public decimals;
	string public standard = 'H0.1'; // HumanStandardToken is a specialisation of ERC20 defining these parameters

	// Timelock
	uint256 public timelockEndTime;

	// Circular reference to ICO contract
	address public addressSCICO;

	// Circular reference to Escrow contract
	address public addressSCEscrow;

	// Reference to ComplianceService contract
	address public addressSCComplianceService;
	ComplianceService public SCComplianceService;

	// **** MODIFIERS

	// @notice To limit token transfers while timelocked
	modifier notTimeLocked() {
		if (now < timelockEndTime && msg.sender != addressSCICO && msg.sender != addressSCEscrow) {
			error('notTimeLocked: Timelock still active. Function is yet unavailable.');
		} else {
			_;
		}
	}


	// **** FUNCTIONS
	/**
	 * @notice Constructor: set up token properties and owner token balance
	 */
	constructor(address _addressSCEscrow, address _addressSCComplianceService) public {
		name = "TheRentalsToken";
		symbol = "TRT";
		decimals = 18; // 18 decimal places, the same as ETH

		// initialSupply = 2000000000 ether; // 2018-04-21: ICO summary.docx: ...Dicho valor generaría un Total Supply de 2.000 millones de TRT.
        _totalSupply = 1350000000 ether; // 2018-05-10: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1978756f786b7637786b707c6d5975787a76746c77706d60377a7674">[email protected]</a> ...tenemos una emisión de 1.350 millones de Tokens&#13;
&#13;
		timelockEndTime = timestamp().add(45 days); // Default timelock&#13;
&#13;
		addressSCEscrow = _addressSCEscrow;&#13;
		addressSCComplianceService = _addressSCComplianceService;&#13;
		SCComplianceService = ComplianceService(addressSCComplianceService);&#13;
&#13;
		// Token distribution&#13;
		balances[_addressSCEscrow] = _totalSupply;&#13;
		emit Transfer(0x0, _addressSCEscrow, _totalSupply);&#13;
&#13;
	}&#13;
&#13;
    /**&#13;
     * @notice Get the token total supply&#13;
     */&#13;
    function totalSupply() public constant returns (uint) {&#13;
&#13;
        return _totalSupply  - balances[address(0)];&#13;
&#13;
    }&#13;
&#13;
	/**&#13;
	 * @notice Get the token balance of a wallet with address _owner&#13;
	 */&#13;
	function balanceOf(address _owner) public constant returns (uint256 balance) {&#13;
		return balances[_owner];&#13;
	}&#13;
&#13;
	/**&#13;
	 * @notice Send _amount amount of tokens to address _to&#13;
	 */&#13;
	function transfer(address _to, uint256 _amount) public notTimeLocked stopInEmergency returns (bool success) {&#13;
		if (balances[msg.sender] &lt; _amount) {&#13;
			error('transfer: the amount to transfer is higher than your token balance');&#13;
			return false;&#13;
		}&#13;
&#13;
		if(!SCComplianceService.validate(msg.sender, _to, _amount)) {&#13;
			error('transfer: not allowed by the compliance service');&#13;
			return false;&#13;
		}&#13;
&#13;
		balances[msg.sender] = balances[msg.sender].sub(_amount);&#13;
		balances[_to] = balances[_to].add(_amount);&#13;
		emit Transfer(msg.sender, _to, _amount); // Event log&#13;
&#13;
		return true;&#13;
	}&#13;
&#13;
	/**&#13;
	 * @notice Send _amount amount of tokens from address _from to address _to&#13;
 	 * @notice The transferFrom method is used for a withdraw workflow, allowing contracts to send &#13;
 	 * @notice tokens on your behalf, for example to "deposit" to a contract address and/or to charge &#13;
 	 * @notice fees in sub-currencies; the command should fail unless the _from account has &#13;
 	 * @notice deliberately authorized the sender of the message via some mechanism&#13;
 	 */&#13;
	function transferFrom(address _from, address _to, uint256 _amount) public notTimeLocked stopInEmergency returns (bool success) {&#13;
		if (balances[_from] &lt; _amount) {&#13;
			error('transferFrom: the amount to transfer is higher than the token balance of the source');&#13;
			return false;&#13;
		}&#13;
		if (allowed[_from][msg.sender] &lt; _amount) {&#13;
			error('transferFrom: the amount to transfer is higher than the maximum token transfer allowed by the source');&#13;
			return false;&#13;
		}&#13;
&#13;
		if(!SCComplianceService.validate(_from, _to, _amount)) {&#13;
			error('transfer: not allowed by the compliance service');&#13;
			return false;&#13;
		}&#13;
&#13;
		balances[_from] = balances[_from].sub(_amount);&#13;
		balances[_to] = balances[_to].add(_amount);&#13;
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);&#13;
		emit Transfer(_from, _to, _amount); // Event log&#13;
&#13;
		return true;&#13;
	}&#13;
&#13;
	/**&#13;
	 * @notice Allow _spender to withdraw from your account, multiple times, up to the _amount amount. &#13;
 	 * @notice If this function is called again it overwrites the current allowance with _amount.&#13;
	 */&#13;
	function approve(address _spender, uint256 _amount) public returns (bool success) {&#13;
		allowed[msg.sender][_spender] = _amount;&#13;
		emit Approval(msg.sender, _spender, _amount); // Event log&#13;
&#13;
		return true;&#13;
	}&#13;
&#13;
	/**&#13;
	 * @notice Returns the amount which _spender is still allowed to withdraw from _owner&#13;
	 */&#13;
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {&#13;
		return allowed[_owner][_spender];&#13;
	}&#13;
&#13;
	/**&#13;
       * @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
       *&#13;
       * approve should be called when allowed[_spender] == 0. To increment&#13;
       * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
       * the first transaction is mined)&#13;
       * From MonolithDAO Token.sol&#13;
       * @param _spender The address which will spend the funds.&#13;
       * @param _addedValue The amount of tokens to increase the allowance by.&#13;
       */&#13;
	function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
		allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
		return true;&#13;
	}&#13;
&#13;
	/**&#13;
     * @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
     *&#13;
     * approve should be called when allowed[_spender] == 0. To decrement&#13;
     * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
     * the first transaction is mined)&#13;
     * From MonolithDAO Token.sol&#13;
     * @param _spender The address which will spend the funds.&#13;
     * @param _subtractedValue The amount of tokens to decrease the allowance by.&#13;
     */&#13;
	function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {&#13;
		uint oldValue = allowed[msg.sender][_spender];&#13;
		if (_subtractedValue &gt; oldValue) {&#13;
			allowed[msg.sender][_spender] = 0;&#13;
		} else {&#13;
			allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
		}&#13;
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
		return true;&#13;
	}&#13;
	&#13;
	/**&#13;
	 * @notice This is out of ERC20 standard but it is necessary to build market escrow contracts of assets&#13;
	 * @notice Send _amount amount of tokens to from tx.origin to address _to&#13;
	 */&#13;
	function refundTokens(address _from, uint256 _amount) public notTimeLocked stopInEmergency returns (bool success) {&#13;
        if (tx.origin != _from) {&#13;
            error('refundTokens: tx.origin did not request the refund directly');&#13;
            return false;&#13;
        }&#13;
&#13;
        if (addressSCICO != msg.sender) {&#13;
            error('refundTokens: caller is not the current ICO address');&#13;
            return false;&#13;
        }&#13;
&#13;
        if (balances[_from] &lt; _amount) {&#13;
            error('refundTokens: the amount to transfer is higher than your token balance');&#13;
            return false;&#13;
        }&#13;
&#13;
        if(!SCComplianceService.validate(_from, addressSCICO, _amount)) {&#13;
			error('transfer: not allowed by the compliance service');&#13;
			return false;&#13;
		}&#13;
&#13;
		balances[_from] = balances[_from].sub(_amount);&#13;
		balances[addressSCICO] = balances[addressSCICO].add(_amount);&#13;
		emit Transfer(_from, addressSCICO, _amount); // Event log&#13;
&#13;
		return true;&#13;
	}&#13;
&#13;
	/**&#13;
	 * @notice The owner can specify which ICO contract is allowed to transfer tokens while timelock is on&#13;
	 */&#13;
	function setMyICOContract(address _SCICO) public onlyOwner {&#13;
		addressSCICO = _SCICO;&#13;
	}&#13;
&#13;
	function setComplianceService(address _addressSCComplianceService) public onlyOwner {&#13;
		addressSCComplianceService = _addressSCComplianceService;&#13;
		SCComplianceService = ComplianceService(addressSCComplianceService);&#13;
	}&#13;
&#13;
	/**&#13;
	 * @notice Called by owner to alter the token timelock&#13;
	 */&#13;
	function updateTimeLock(uint256 _timelockEndTime) onlyOwner public returns (bool) {&#13;
		timelockEndTime = _timelockEndTime;&#13;
&#13;
		emit UpdateTimeLock(_timelockEndTime); // Event log&#13;
&#13;
		return true;&#13;
	}&#13;
&#13;
&#13;
	// **** EVENTS&#13;
&#13;
	// Triggered when tokens are transferred&#13;
	event Transfer(address indexed _from, address indexed _to, uint256 _amount);&#13;
&#13;
	// Triggered when someone approves a spender to move its tokens&#13;
	event Approval(address indexed _owner, address indexed _spender, uint256 _amount);&#13;
&#13;
	// Triggered when Owner updates token timelock&#13;
	event UpdateTimeLock(uint256 _timelockEndTime);&#13;
}