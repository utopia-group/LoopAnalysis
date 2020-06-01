pragma solidity ^0.4.21;



/**
 * @title BytesTools
 * @dev Useful tools for bytes type
 */
library BytesTools {
	
	/**
	 * @dev Parses n of type bytes to uint256
	 */
	function parseInt(bytes n) internal pure returns (uint256) {
		
		uint256 parsed = 0;
		bool decimals = false;
		
		for (uint256 i = 0; i < n.length; i++) {
			if ( n[i] >= 48 && n[i] <= 57) {
				
				if (decimals) break;
				
				parsed *= 10;
				parsed += uint256(n[i]) - 48;
			} else if (n[i] == 46) {
				decimals = true;
			}
		}
		
		return parsed;
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
* @title Contract that will work with ERC223 tokens
*/
contract ERC223Reciever {
	
	/**
	 * @dev Standard ERC223 function that will handle incoming token transfers
	 *
	 * @param _from address  Token sender address
	 * @param _value uint256 Amount of tokens
	 * @param _data bytes  Transaction metadata
	 */
	function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool);
	
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
 * @title  UKT Token Voting contract
 * @author  Oleg Levshin <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bcd0d9cacfd4d5d2fcc9dfd3c691c8d9ddd192d2d9c8">[email protected]</a>&gt;&#13;
 */&#13;
contract UKTTokenVoting is ERC223Reciever, Ownable {&#13;
	&#13;
	using SafeMath for uint256;&#13;
	using BytesTools for bytes;&#13;
	&#13;
	struct Vote {&#13;
		uint256 proposalIdx;&#13;
		uint256 tokensValue;&#13;
		uint256 weight;&#13;
		address tokenContractAddress;&#13;
		uint256 blockNumber;&#13;
	}&#13;
	&#13;
	mapping(address =&gt; bool) public acceptedTokens;&#13;
	mapping(address =&gt; uint256) public acceptedTokensValues;&#13;
	&#13;
	bytes32[] public proposals;&#13;
	mapping (uint256 =&gt; uint256) public proposalsWeights;&#13;
	&#13;
	uint256 public dateStart;&#13;
	uint256 public dateEnd;&#13;
	&#13;
	address[] public voters;&#13;
	mapping (address =&gt; Vote) public votes;&#13;
	&#13;
	bool public isFinalized = false;&#13;
	bool public isFinalizedValidly = false;&#13;
	&#13;
	event NewVote(address indexed voter, uint256 proposalIdx, uint256 proposalWeight);&#13;
	event TokensClaimed(address to);&#13;
	event TokensRefunded(address to);&#13;
	&#13;
	&#13;
	function UKTTokenVoting(&#13;
		uint256 _dateEnd,&#13;
		bytes32[] _proposals,&#13;
		address[] _acceptedTokens,&#13;
		uint256[] _acceptedTokensValues&#13;
	) public {&#13;
		require(_dateEnd &gt; now);&#13;
		require(_proposals.length &gt; 1);&#13;
		require(_acceptedTokens.length &gt; 0);&#13;
		require(_acceptedTokensValues.length &gt; 0);&#13;
		require(_acceptedTokens.length == _acceptedTokensValues.length);&#13;
		&#13;
		dateStart = now;&#13;
		dateEnd = _dateEnd;&#13;
		&#13;
		proposals.push("Not valid proposal");&#13;
		proposalsWeights[0] = 0;&#13;
		for(uint256 i = 0; i &lt; _proposals.length; i++) {&#13;
			proposals.push(_proposals[i]);&#13;
			proposalsWeights[i+1] = 0;&#13;
		}&#13;
		&#13;
		for(uint256 j = 0; j &lt; _acceptedTokens.length; j++) {&#13;
			acceptedTokens[_acceptedTokens[j]] = true;&#13;
			acceptedTokensValues[_acceptedTokens[j]] = _acceptedTokensValues[j];&#13;
		}&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Executes automatically when user transfer his token to this contract address&#13;
	 */&#13;
	function tokenFallback(&#13;
		address _from,&#13;
		uint256 _value,&#13;
		bytes _data&#13;
	) external returns (bool) {&#13;
		// voting hasn't ended yet&#13;
		require(now &lt; dateEnd);&#13;
		&#13;
		// executed from contract in acceptedTokens&#13;
		require(acceptedTokens[msg.sender] == true);&#13;
		&#13;
		// value of tokens is enough for voting&#13;
		require(_value &gt;= acceptedTokensValues[msg.sender]);&#13;
		&#13;
		// give proposal index is valid&#13;
		uint256 proposalIdx = _data.parseInt();&#13;
		require(isValidProposal(proposalIdx));&#13;
		&#13;
		// user hasn't voted yet&#13;
		require(isAddressNotVoted(_from));&#13;
		&#13;
		uint256 weight = _value.div(acceptedTokensValues[msg.sender]);&#13;
		&#13;
		votes[_from] = Vote(proposalIdx, _value, weight, msg.sender, block.number);&#13;
		voters.push(_from);&#13;
		&#13;
		proposalsWeights[proposalIdx] = proposalsWeights[proposalIdx].add(weight);&#13;
		&#13;
		emit NewVote(_from, proposalIdx, proposalsWeights[proposalIdx]);&#13;
		&#13;
		return true;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Gets winner tuple after voting is finished&#13;
	 */&#13;
	function getWinner() external view returns (uint256 winnerIdx, bytes32 winner, uint256 winnerWeight) {&#13;
		require(now &gt;= dateEnd);&#13;
		&#13;
		winnerIdx = 0;&#13;
		winner = proposals[winnerIdx];&#13;
		winnerWeight = proposalsWeights[winnerIdx];&#13;
		&#13;
		for(uint256 i = 1; i &lt; proposals.length; i++) {&#13;
			if(proposalsWeights[i] &gt;= winnerWeight) {&#13;
				winnerIdx = i;&#13;
				winner = proposals[winnerIdx];&#13;
				winnerWeight = proposalsWeights[i];&#13;
			}&#13;
		}&#13;
		&#13;
		if (winnerIdx &gt; 0) {&#13;
			for(uint256 j = 1; j &lt; proposals.length; j++) {&#13;
				if(j != winnerIdx &amp;&amp; proposalsWeights[j] == proposalsWeights[winnerIdx]) {&#13;
					return (0, proposals[0], proposalsWeights[0]);&#13;
				}&#13;
			}&#13;
		}&#13;
		&#13;
		return (winnerIdx, winner, winnerWeight);&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Finalizes voting&#13;
	 */&#13;
	function finalize(bool _isFinalizedValidly) external onlyOwner {&#13;
		require(now &gt;= dateEnd &amp;&amp; ! isFinalized);&#13;
		&#13;
		isFinalized = true;&#13;
		isFinalizedValidly = _isFinalizedValidly;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Allows voter to claim his tokens back to address&#13;
	 */&#13;
	function claimTokens() public returns (bool) {&#13;
		require(isAddressVoted(msg.sender));&#13;
		&#13;
		require(transferTokens(msg.sender));&#13;
		emit TokensClaimed(msg.sender);&#13;
		&#13;
		return true;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Refunds tokens for all voters&#13;
	 */&#13;
	function refundTokens(address to) public onlyOwner returns (bool) {&#13;
		if(to != address(0)) {&#13;
			return _refundTokens(to);&#13;
		}&#13;
		&#13;
		for(uint256 i = 0; i &lt; voters.length; i++) {&#13;
			_refundTokens(voters[i]);&#13;
		}&#13;
		&#13;
		return true;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Checks proposal index for validity&#13;
	 */&#13;
	function isValidProposal(uint256 proposalIdx) private view returns (bool) {&#13;
		return (&#13;
			proposalIdx &gt; 0 &amp;&amp;&#13;
			proposals[proposalIdx].length &gt; 0&#13;
		);&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Return true if address not voted yet&#13;
	 */&#13;
	function isAddressNotVoted(address _address) private view returns (bool) {&#13;
		// solium-disable-next-line operator-whitespace&#13;
		return (&#13;
			// solium-disable-next-line operator-whitespace&#13;
			votes[_address].proposalIdx == 0 &amp;&amp;&#13;
			votes[_address].tokensValue == 0 &amp;&amp;&#13;
			votes[_address].weight == 0 &amp;&amp;&#13;
			votes[_address].tokenContractAddress == address(0) &amp;&amp;&#13;
			votes[_address].blockNumber == 0&#13;
		);&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Return true if address already voted&#13;
	 */&#13;
	function isAddressVoted(address _address) private view returns (bool) {&#13;
		return ! isAddressNotVoted(_address);&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Trasnfer tokens to voter&#13;
	 */&#13;
	function transferTokens(address to) private returns (bool) {&#13;
		&#13;
		Vote memory vote = votes[to];&#13;
		&#13;
		if(vote.tokensValue == 0) {&#13;
			return true;&#13;
		}&#13;
		votes[to].tokensValue = 0;&#13;
		&#13;
		if ( ! isFinalized) {&#13;
			votes[to] = Vote(0, 0, 0, address(0), 0);&#13;
			proposalsWeights[vote.proposalIdx] = proposalsWeights[vote.proposalIdx].sub(vote.weight);&#13;
		}&#13;
		&#13;
		return vote.tokenContractAddress.call(bytes4(keccak256("transfer(address,uint256)")), to, vote.tokensValue);&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Refunds tokens to particular address&#13;
	 */&#13;
	function _refundTokens(address to) private returns (bool) {&#13;
		require(transferTokens(to));&#13;
		emit TokensRefunded(to);&#13;
		&#13;
		return true;&#13;
	}&#13;
	&#13;
}&#13;
&#13;
/**&#13;
 * @title  UKT Token Voting Factory contract&#13;
 * @author  Oleg Levshin &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6a060f1c190203042a1f090510471e0f0b0744040f1e">[email protected]</a>&gt;&#13;
 */&#13;
contract UKTTokenVotingFactory is Ownable {&#13;
	&#13;
	address[] public votings;&#13;
	mapping(address =&gt; int256) public votingsWinners;&#13;
	&#13;
	event VotingCreated(address indexed votingAddress, uint256 dateEnd, bytes32[] proposals, address[] acceptedTokens, uint256[] acceptedTokensValues);&#13;
	event WinnerSetted(address indexed votingAddress, uint256 winnerIdx, bytes32 winner, uint256 winnerWeight);&#13;
	event VotingFinalized(address indexed votingAddress, bool isFinalizedValidly);&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Checks voting contract address for validity&#13;
	 */&#13;
	function isValidVoting(address votingAddress) private view returns (bool) {&#13;
		for (uint256 i = 0; i &lt; votings.length; i++) {&#13;
			if (votings[i] == votingAddress) {&#13;
				return true;&#13;
			}&#13;
		}&#13;
		&#13;
		return false;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Creates new instance of UKTTokenVoting contract with given params&#13;
	 */&#13;
	function getNewVoting(&#13;
		uint256 dateEnd,&#13;
		bytes32[] proposals,&#13;
		address[] acceptedTokens,&#13;
		uint256[] acceptedTokensValues&#13;
	) public onlyOwner returns (address votingAddress) {&#13;
		&#13;
		votingAddress = address(new UKTTokenVoting(dateEnd, proposals, acceptedTokens, acceptedTokensValues));&#13;
		&#13;
		emit VotingCreated(votingAddress, dateEnd, proposals, acceptedTokens, acceptedTokensValues);&#13;
		&#13;
		votings.push(votingAddress);&#13;
		votingsWinners[votingAddress] = -1;&#13;
		&#13;
		return votingAddress;&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Refunds tokens for all voters&#13;
	 */&#13;
	function refundVotingTokens(address votingAddress, address to) public onlyOwner returns (bool) {&#13;
		require(isValidVoting(votingAddress));&#13;
		&#13;
		return UKTTokenVoting(votingAddress).refundTokens(to);&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Sets calculated proposalIdx as voting winner&#13;
	 */&#13;
	function setVotingWinner(address votingAddress) public onlyOwner {&#13;
		require(votingsWinners[votingAddress] == -1);&#13;
		&#13;
		uint256 winnerIdx;&#13;
		bytes32 winner;&#13;
		uint256 winnerWeight;&#13;
		&#13;
		(winnerIdx, winner, winnerWeight) = UKTTokenVoting(votingAddress).getWinner();&#13;
		&#13;
		bool isFinalizedValidly = winnerIdx &gt; 0;&#13;
		&#13;
		UKTTokenVoting(votingAddress).finalize(isFinalizedValidly);&#13;
		&#13;
		emit VotingFinalized(votingAddress, isFinalizedValidly);&#13;
		&#13;
		votingsWinners[votingAddress] = int256(winnerIdx);&#13;
		&#13;
		emit WinnerSetted(votingAddress, winnerIdx, winner, winnerWeight);&#13;
	}&#13;
	&#13;
	&#13;
	/**&#13;
	 * @dev Gets voting winner&#13;
	 */&#13;
	function getVotingWinner(address votingAddress) public view returns (bytes32) {&#13;
		require(votingsWinners[votingAddress] &gt; -1);&#13;
		&#13;
		return UKTTokenVoting(votingAddress).proposals(uint256(votingsWinners[votingAddress]));&#13;
	}&#13;
}