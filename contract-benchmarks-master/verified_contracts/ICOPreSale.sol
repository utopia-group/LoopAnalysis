pragma solidity ^0.4.13;

contract ComplianceService {
	function validate(address _from, address _to, uint256 _amount) public returns (bool allowed) {
		return true;
	}
}

contract ERC20 {
	function balanceOf(address _owner) public constant returns (uint256 balance);
	function transfer(address _to, uint256 _amount) public returns (bool success);
	function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
	function totalSupply() public constant returns (uint);
}

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

contract RefundVault is HardcodedWallets, System {
	using SafeMath for uint256;

	enum State { Active, Refunding, Closed }


	// **** DATA

	mapping (address => uint256) public deposited;
	mapping (address => uint256) public tokensAcquired;
	State public state;

	// Circular reference to ICO contract
	address public addressSCICO;
	
	

	// **** MODIFIERS

	// @notice To limit functions usage to contract owner
	modifier onlyICOContract() {
		if (msg.sender != addressSCICO) {
			error('RefundVault: onlyICOContract function called by user that is not ICOContract');
		} else {
			_;
		}
	}


	// **** FUNCTIONS

	/**
	 * @notice Constructor, set up the state
	 */
	constructor() public {
		state = State.Active;
	}

	function weisDeposited(address _investor) public constant returns (uint256) {
		return deposited[_investor];
	}

	function getTokensAcquired(address _investor) public constant returns (uint256) {
		return tokensAcquired[_investor];
	}

	/**
	 * @notice Registers how many tokens have each investor and how many ethers they spent (When ICOing through PayIn this function is not called)
	 */
	function deposit(address _investor, uint256 _tokenAmount) onlyICOContract public payable returns (bool) {
		if (state != State.Active) {
			error('deposit: state != State.Active');
			return false;
		}
		deposited[_investor] = deposited[_investor].add(msg.value);
		tokensAcquired[_investor] = tokensAcquired[_investor].add(_tokenAmount);

		return true;
	}

	/**
	 * @notice When ICO finalizes funds are transferred to founders' wallets
	 */
	function close() onlyICOContract public returns (bool) {
		if (state != State.Active) {
			error('close: state != State.Active');
			return false;
		}
		state = State.Closed;

		walletFounder1.transfer(address(this).balance.mul(33).div(100)); // Forwards 33% to 1st founder wallet
		walletFounder2.transfer(address(this).balance.mul(50).div(100)); // Forwards 33% to 2nd founder wallet
		walletFounder3.transfer(address(this).balance);                  // Forwards 34% to 3rd founder wallet

		emit Closed(); // Event log

		return true;
	}

	/**
	 * @notice When ICO finalizes owner toggles refunding
	 */
	function enableRefunds() onlyICOContract public returns (bool) {
		if (state != State.Active) {
			error('enableRefunds: state != State.Active');
			return false;
		}
		state = State.Refunding;

		emit RefundsEnabled(); // Event log

		return true;
	}

	/**
	 * @notice ICO Smart Contract can call this function for the investor to refund
	 */
	function refund(address _investor) onlyICOContract public returns (bool) {
		if (state != State.Refunding) {
			error('refund: state != State.Refunding');
			return false;
		}
		if (deposited[_investor] == 0) {
			error('refund: no deposit to refund');
			return false;
		}
		uint256 depositedValue = deposited[_investor];
		deposited[_investor] = 0;
		tokensAcquired[_investor] = 0; // tokens should have been returned previously to the ICO
		_investor.transfer(depositedValue);

		emit Refunded(_investor, depositedValue); // Event log

		return true;
	}

	/**
	 * @notice To allow ICO contracts to check whether RefundVault is ready to refund investors
	 */
	function isRefunding() public constant returns (bool) {
		return (state == State.Refunding);
	}

	/**
	 * @notice The owner must specify which ICO contract is allowed call for refunds
	 */
	function setMyICOContract(address _SCICO) public onlyOwner {
		require(address(this).balance == 0);
		addressSCICO = _SCICO;
	}



	// **** EVENTS

	// Triggered when ICO contract closes the vault and forwards funds to the founders' wallets
	event Closed();

	// Triggered when ICO contract initiates refunding
	event RefundsEnabled();

	// Triggered when an investor claims (through ICO contract) and gets its funds
	event Refunded(address indexed beneficiary, uint256 weiAmount);
}

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

contract ICO is HardcodedWallets, Haltable {
	// **** DATA

	// Linked Contracts
	Tokens public SCTokens;	// The token being sold
	RefundVault public SCRefundVault;	// The vault for softCap refund
	Whitelist public SCWhitelist;	// The whitelist of allowed wallets to buy tokens on ICO
	Escrow public SCEscrow; // Escrow service

	// start and end timestamps where investments are allowed (both inclusive)
	uint256 public startTime;
	uint256 public endTime;
	bool public isFinalized = false;

	uint256 public weisPerBigToken; // how many weis a buyer pays to get a big token (10^18 tokens)
	uint256 public weisPerEther;
	uint256 public tokensPerEther; // amount of tokens with multiplier received on ICO when paying with 1 Ether, discounts included
	uint256 public bigTokensPerEther; // amount of tokens w/omultiplier received on ICO when paying with 1 Ether, discounts included

	uint256 public weisRaised; // amount of Weis raised
	uint256 public etherHardCap; // Max amount of Ethers to raise
	uint256 public tokensHardCap; // Max amount of Tokens for sale
	uint256 public weisHardCap; // Max amount of Weis raised
	uint256 public weisMinInvestment; // Min amount of Weis to perform a token sale
	uint256 public etherSoftCap; // Min amount of Ethers for sale to ICO become successful
	uint256 public tokensSoftCap; // Min amount of Tokens for sale to ICO become successful
	uint256 public weisSoftCap; // Min amount of Weis raised to ICO become successful

	uint256 public discount; // Applies to token price when investor buys tokens. It is a number between 0-100
	uint256 discountedPricePercentage;
	uint8 ICOStage;



	// **** MODIFIERS

	
	// **** FUNCTIONS

	// fallback function can be used to buy tokens
	function () payable public {
		buyTokens();
	}
	

	/**
	 * @notice Token purchase function direclty through ICO Smart Contract. Beneficiary = msg.sender
	 */
	function buyTokens() public stopInEmergency payable returns (bool) {
		if (msg.value == 0) {
			error('buyTokens: ZeroPurchase');
			return false;
		}

		uint256 tokenAmount = buyTokensLowLevel(msg.sender, msg.value);

		// Send the investor's ethers to the vault
		if (!SCRefundVault.deposit.value(msg.value)(msg.sender, tokenAmount)) {
			revert('buyTokens: unable to transfer collected funds from ICO contract to Refund Vault'); // Revert needed to refund investor on error
			// error('buyTokens: unable to transfer collected funds from ICO contract to Refund Vault');
			// return false;
		}

		emit BuyTokens(msg.sender, msg.value, tokenAmount); // Event log

		return true;
	}

	/**
	 * @notice Token purchase function through Oracle PayIn by MarketPay.io API
	 */
	/* // Deactivated to save ICO contract deployment gas cost
	function buyTokensOraclePayIn(address _beneficiary, uint256 _weisAmount) public onlyCustodyFiat stopInEmergency returns (bool) {
		uint256 tokenAmount = buyTokensLowLevel(_beneficiary, _weisAmount);

		emit BuyTokensOraclePayIn(msg.sender, _beneficiary, _weisAmount, tokenAmount); // Event log

		return true;
	}*/

	/**
	 * @notice Low level token purchase function, w/o ether transfer from investor
	 */
	function buyTokensLowLevel(address _beneficiary, uint256 _weisAmount) private stopInEmergency returns (uint256 tokenAmount) {
		if (_beneficiary == 0x0) {
			revert('buyTokensLowLevel: _beneficiary == 0x0'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: _beneficiary == 0x0');
			// return 0;
		}
		if (timestamp() < startTime || timestamp() > endTime) {
			revert('buyTokensLowLevel: Not withinPeriod'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: Not withinPeriod');
			// return 0;
		}
		if (!SCWhitelist.isInvestor(_beneficiary)) {
			revert('buyTokensLowLevel: Investor is not registered on the whitelist'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: Investor is not registered on the whitelist');
			// return 0;
		}
		if (isFinalized) {
			revert('buyTokensLowLevel: ICO is already finalized'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: ICO is already finalized');
			// return 0;
		}

		// Verify whether enough ether has been sent to buy the min amount of investment
		if (_weisAmount < weisMinInvestment) {
			revert('buyTokensLowLevel: Minimal investment not reached. Not enough ethers to perform the minimal purchase'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: Minimal investment not reached. Not enough ethers to perform the minimal purchase');
			// return 0;
		}

		// Verify whether there are enough tokens to sell
		if (weisRaised.add(_weisAmount) > weisHardCap) {
			revert('buyTokensLowLevel: HardCap reached. Not enough tokens on ICO contract to perform this purchase'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: HardCap reached. Not enough tokens on ICO contract to perform this purchase');
			// return 0;
		}

		// Calculate token amount to be sold
		tokenAmount = _weisAmount.mul(weisPerEther).div(weisPerBigToken);

		// Applying discount
		tokenAmount = tokenAmount.mul(100).div(discountedPricePercentage);

		// Update state
		weisRaised = weisRaised.add(_weisAmount);

		// Send the tokens to the investor
		if (!SCTokens.transfer(_beneficiary, tokenAmount)) {
			revert('buyTokensLowLevel: unable to transfer tokens from ICO contract to beneficiary'); // Revert needed to refund investor on error
			// error('buyTokensLowLevel: unable to transfer tokens from ICO contract to beneficiary');
			// return 0;
		}
		emit BuyTokensLowLevel(msg.sender, _beneficiary, _weisAmount, tokenAmount); // Event log

		return tokenAmount;
	}

	/**
	 * @return true if ICO event has ended
	 */
	/* // Deactivated to save ICO contract deployment gas cost
	function hasEnded() public constant returns (bool) {
		return timestamp() > endTime;
	}*/

	/**
	 * @notice Called by owner to alter the ICO deadline
	 */
	function updateEndTime(uint256 _endTime) onlyOwner public returns (bool) {
		endTime = _endTime;

		emit UpdateEndTime(_endTime); // Event log
	}


	/**
	 * @notice Must be called by owner before or after ICO ends, to check whether soft cap is reached and transfer collected funds
	 */
	function finalize(bool _forceRefund) onlyOwner public returns (bool) {
		if (isFinalized) {
			error('finalize: ICO is already finalized.');
			return false;
		}

		if (weisRaised >= weisSoftCap && !_forceRefund) {
			if (!SCRefundVault.close()) {
				error('finalize: SCRefundVault.close() failed');
				return false;
			}
		} else {
			if (!SCRefundVault.enableRefunds()) {
				error('finalize: SCRefundVault.enableRefunds() failed');
				return false;
			}
			if(_forceRefund) {
				emit ForceRefund(); // Event log
			}
		}

		// Move remaining ICO tokens back to the Escrow
		uint256 balanceAmount = SCTokens.balanceOf(this);
		if (!SCTokens.transfer(address(SCEscrow), balanceAmount)) {
			error('finalize: unable to return remaining ICO tokens');
			return false;
		}
		// Adjust Escrow balance correctly
		if(!SCEscrow.deposit(balanceAmount)) {
			error('finalize: unable to return remaining ICO tokens');
			return false;
		}

		isFinalized = true;

		emit Finalized(); // Event log

		return true;
	}

	/**
	 * @notice If ICO is unsuccessful, investors can claim refunds here
	 */
	function claimRefund() public stopInEmergency returns (bool) {
		if (!isFinalized) {
			error('claimRefund: ICO is not yet finalized.');
			return false;
		}

		if (!SCRefundVault.isRefunding()) {
			error('claimRefund: RefundVault state != State.Refunding');
			return false;
		}

		// Before transfering the ETHs to the investor, get back the tokens bought on ICO
		uint256 tokenAmount = SCRefundVault.getTokensAcquired(msg.sender);
		emit GetBackTokensOnRefund(msg.sender, this, tokenAmount); // Event Log
		if (!SCTokens.refundTokens(msg.sender, tokenAmount)) {
			error('claimRefund: unable to transfer investor tokens to ICO contract before refunding');
			return false;
		}

		if (!SCRefundVault.refund(msg.sender)) {
			error('claimRefund: SCRefundVault.refund() failed');
			return false;
		}

		return true;
	}

	function fundICO() public onlyOwner {
		if (!SCEscrow.fundICO(tokensHardCap, ICOStage)) {
			revert('ICO funding failed');
		}
	}




// **** EVENTS

	// Triggered when an investor buys some tokens directly with Ethers
	event BuyTokens(address indexed _purchaser, uint256 _value, uint256 _amount);

	// Triggered when Owner says some investor has requested tokens on PayIn MarketPay.io API
	event BuyTokensOraclePayIn(address indexed _purchaser, address indexed _beneficiary, uint256 _weisAmount, uint256 _tokenAmount);

	// Triggered when an investor buys some tokens directly with Ethers or through payin Oracle
	event BuyTokensLowLevel(address indexed _purchaser, address indexed _beneficiary, uint256 _value, uint256 _amount);

	// Triggered when an SC owner request to end the ICO, transferring funds to founders wallet or ofeering them as a refund
	event Finalized();

	// Triggered when an SC owner request to end the ICO and allow transfer of funds to founders wallets as a refund
	event ForceRefund();

	// Triggered when RefundVault is created
	//event AddressSCRefundVault(address _scAddress);

	// Triggered when investor refund and their tokens got back to ICO contract
	event GetBackTokensOnRefund(address _from, address _to, uint256 _amount);

	// Triggered when Owner updates ICO deadlines
	event UpdateEndTime(uint256 _endTime);
}

contract ICOPreSale is ICO {
	/**
	 * @notice ICO constructor. Definition of ICO parameters and subcontracts autodeployment
	 */
	constructor(address _SCEscrow, address _SCTokens, address _SCWhitelist, address _SCRefundVault) public {
		if (_SCTokens == 0x0) {
			revert('Tokens Constructor: _SCTokens == 0x0');
		}
		if (_SCWhitelist == 0x0) {
			revert('Tokens Constructor: _SCWhitelist == 0x0');
		}
		if (_SCRefundVault == 0x0) {
			revert('Tokens Constructor: _SCRefundVault == 0x0');
		}
		
		SCTokens = Tokens(_SCTokens);
		SCWhitelist = Whitelist(_SCWhitelist);
		SCRefundVault = RefundVault(_SCRefundVault);
		
		weisPerEther = 1 ether; // 10e^18 multiplier

		// Deadline
		startTime = timestamp();
		endTime = timestamp().add(24 days); // from 8th June to 2th July 2018

		// Token Price
		bigTokensPerEther = 7500; // tokens (w/o multiplier) got for 1 ether
		tokensPerEther = bigTokensPerEther.mul(weisPerEther); // tokens (with multiplier) got for 1 ether

		discount = 45; // pre-sale 45%
		discountedPricePercentage = 100;
		discountedPricePercentage = discountedPricePercentage.sub(discount);

		weisMinInvestment = weisPerEther.mul(1);

		// 2018-05-10: <span class="__cf_email__" data-cfemail="7415180215061b5a15061d1100341815171b19011a1d000d5a171b19">[email protected]</span> Los Hardcap que indicas no son los últimos comentados. Los correctos serían:&#13;
		//    Pre-Sale:     8.470 ETH&#13;
		//    1st Tier:       8.400 ETH&#13;
		//    2nd Tier:     68.600 ETH&#13;
&#13;
		// HardCap&#13;
		// etherHardCap = 8500; // As of 2018-05-09 =&gt; Hardcap pre sale: 8.500 ETH&#13;
		 // As of 2018-05-10 =&gt; Pre-Sale:     8.470 ETH&#13;
		etherHardCap = 8067; // As of 2018-05-24 =&gt; Pre-Sale:     8067 ETH&#13;
		tokensHardCap = tokensPerEther.mul(etherHardCap).mul(100).div(discountedPricePercentage);&#13;
&#13;
		weisPerBigToken = weisPerEther.div(bigTokensPerEther);&#13;
		// weisHardCap = weisPerBigToken.mul(tokensHardCap).div(weisPerEther);&#13;
		weisHardCap = weisPerEther.mul(etherHardCap);&#13;
&#13;
		// SoftCap&#13;
		etherSoftCap = 750; // As of 2018-05-09 =&gt; Softcap pre sale: 750 ETH&#13;
		weisSoftCap = weisPerEther.mul(etherSoftCap);&#13;
&#13;
		SCEscrow = Escrow(_SCEscrow);&#13;
&#13;
		ICOStage = 0;&#13;
	}&#13;
&#13;
}&#13;
&#13;
contract Tokens is HardcodedWallets, ERC20, Haltable {&#13;
&#13;
	// **** DATA&#13;
&#13;
	mapping (address =&gt; uint256) balances;&#13;
	mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
	uint256 public _totalSupply; &#13;
&#13;
	// Public variables of the token, all used for display&#13;
	string public name;&#13;
	string public symbol;&#13;
	uint8 public decimals;&#13;
	string public standard = 'H0.1'; // HumanStandardToken is a specialisation of ERC20 defining these parameters&#13;
&#13;
	// Timelock&#13;
	uint256 public timelockEndTime;&#13;
&#13;
	// Circular reference to ICO contract&#13;
	address public addressSCICO;&#13;
&#13;
	// Circular reference to Escrow contract&#13;
	address public addressSCEscrow;&#13;
&#13;
	// Reference to ComplianceService contract&#13;
	address public addressSCComplianceService;&#13;
	ComplianceService public SCComplianceService;&#13;
&#13;
	// **** MODIFIERS&#13;
&#13;
	// @notice To limit token transfers while timelocked&#13;
	modifier notTimeLocked() {&#13;
		if (now &lt; timelockEndTime &amp;&amp; msg.sender != addressSCICO &amp;&amp; msg.sender != addressSCEscrow) {&#13;
			error('notTimeLocked: Timelock still active. Function is yet unavailable.');&#13;
		} else {&#13;
			_;&#13;
		}&#13;
	}&#13;
&#13;
&#13;
	// **** FUNCTIONS&#13;
	/**&#13;
	 * @notice Constructor: set up token properties and owner token balance&#13;
	 */&#13;
	constructor(address _addressSCEscrow, address _addressSCComplianceService) public {&#13;
		name = "TheRentalsToken";&#13;
		symbol = "TRT";&#13;
		decimals = 18; // 18 decimal places, the same as ETH&#13;
&#13;
		// initialSupply = 2000000000 ether; // 2018-04-21: ICO summary.docx: ...Dicho valor generaría un Total Supply de 2.000 millones de TRT.&#13;
        _totalSupply = 1350000000 ether; // 2018-05-10: <span class="__cf_email__" data-cfemail="1d7c716b7c6f72337c6f7478695d717c7e72706873746964337e7270">[email protected]</span> ...tenemos una emisión de 1.350 millones de Tokens&#13;
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
}&#13;
&#13;
contract Whitelist is HardcodedWallets, System {&#13;
	// **** DATA&#13;
&#13;
	mapping (address =&gt; bool) public walletsICO;&#13;
	mapping (address =&gt; bool) public managers;&#13;
&#13;
	// Checks whether a given wallet is authorized to ICO investing&#13;
	function isInvestor(address _wallet) public constant returns (bool) {&#13;
		return (walletsICO[_wallet]);&#13;
	}&#13;
&#13;
	/**&#13;
	 * @notice Registers an investor&#13;
	 */&#13;
	function addInvestor(address _wallet) external isManager returns (bool) {&#13;
		// Checks whether this wallet has been previously added as an investor&#13;
		if (walletsICO[_wallet]) {&#13;
			error('addInvestor: this wallet has been previously granted as ICO investor');&#13;
			return false;&#13;
		}&#13;
&#13;
		walletsICO[_wallet] = true;&#13;
&#13;
		emit AddInvestor(_wallet, timestamp()); // Event log&#13;
		return true;&#13;
	}&#13;
&#13;
	modifier isManager(){&#13;
		if (managers[msg.sender] || msg.sender == owner) {&#13;
			_;&#13;
		} else {&#13;
			error("isManager: called by user that is not owner or manager");&#13;
		}&#13;
	}&#13;
&#13;
	// adds an address that will have the right to add investors&#13;
	function addManager(address _managerAddr) external onlyOwner returns (bool) {&#13;
		if(managers[_managerAddr]){&#13;
			error("addManager: manager account already exists.");&#13;
			return false;&#13;
		}&#13;
&#13;
		managers[_managerAddr] = true;&#13;
&#13;
		emit AddManager(_managerAddr, timestamp());&#13;
	}&#13;
&#13;
	// removes a manager address&#13;
	function delManager(address _managerAddr) external onlyOwner returns (bool) {&#13;
		if(!managers[_managerAddr]){&#13;
			error("delManager: manager account not found.");&#13;
			return false;&#13;
		}&#13;
&#13;
		delete managers[_managerAddr];&#13;
&#13;
		emit DelManager(_managerAddr, timestamp());&#13;
	}&#13;
&#13;
	// **** EVENTS&#13;
&#13;
	// Triggered when a wallet is granted to become an ICO investor&#13;
	event AddInvestor(address indexed _wallet, uint256 _timestamp);&#13;
	// Triggered when a manager is added&#13;
	event AddManager(address indexed _managerAddr, uint256 _timestamp);&#13;
	// Triggered when a manager is removed&#13;
	event DelManager(address indexed _managerAddr, uint256 _timestamp);&#13;
}