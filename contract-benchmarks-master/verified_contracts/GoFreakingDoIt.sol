pragma solidity ^0.4.4;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract GoFreakingDoIt is Ownable {
    struct Goal {
    	bytes32 hash;
        address owner; // goal owner addr
        string description; // set goal description
        uint amount; // set goal amount
        string supervisorEmail; // email of friend
        string creatorEmail; // email of friend
        string deadline;
        bool emailSent;
        bool completed;
    }

    // address owner;
	mapping (bytes32 => Goal) public goals;
	Goal[] public activeGoals;

	// Events
    event setGoalEvent (
    	address _owner,
        string _description,
        uint _amount,
        string _supervisorEmail,
        string _creatorEmail,
        string _deadline,
        bool _emailSent,
        bool _completed
    );

    event setGoalSucceededEvent(bytes32 hash, bool _completed);
    event setGoalFailedEvent(bytes32 hash, bool _completed);

	// app.setGoal("Finish cleaning", "<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3e565b5252517e555f4c5152574d4c5f53105d5153">[email protected]</a>", "<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0f676a6363604f646e7d6063667c7d6e62216c6062">[email protected]</a>", "2017-12-12", {value: web3.toWei(11.111, 'ether')})&#13;
	// app.setGoal("Finish cleaning", "<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7a121f1616153a111b0815161309081b1754191517">[email protected]</a>", "<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c8a0ada4a4a788a3a9baa7a4a1bbbaa9a5e6aba7a5">[email protected]</a>", "2017-12-12", {value: web3.toWei(11.111, 'ether'), from: web3.eth.accounts[1]})&#13;
	function setGoal(string _description, string _supervisorEmail, string _creatorEmail, string _deadline) payable returns (bytes32, address, string, uint, string, string, string) {&#13;
		require(msg.value &gt; 0);&#13;
		require(keccak256(_description) != keccak256(''));&#13;
		require(keccak256(_creatorEmail) != keccak256(''));&#13;
		require(keccak256(_deadline) != keccak256(''));&#13;
&#13;
		bytes32 hash = keccak256(msg.sender, _description, msg.value, _deadline);&#13;
&#13;
		Goal memory goal = Goal({&#13;
			hash: hash,&#13;
			owner: msg.sender,&#13;
			description: _description,&#13;
			amount: msg.value,&#13;
			supervisorEmail: _supervisorEmail,&#13;
			creatorEmail: _creatorEmail,&#13;
			deadline: _deadline,&#13;
			emailSent: false,&#13;
			completed: false&#13;
		});&#13;
&#13;
		goals[hash] = goal;&#13;
		activeGoals.push(goal);&#13;
&#13;
		setGoalEvent(goal.owner, goal.description, goal.amount, goal.supervisorEmail, goal.creatorEmail, goal.deadline, goal.emailSent, goal.completed);&#13;
&#13;
		return (hash, goal.owner, goal.description, goal.amount, goal.supervisorEmail, goal.creatorEmail, goal.deadline);&#13;
	}&#13;
&#13;
	function getGoalsCount() constant returns (uint count) {&#13;
	    return activeGoals.length;&#13;
	}&#13;
&#13;
	// app.setEmailSent("0x00f2484d16ad04b395c6261b978fb21f0c59210d98e9ac361afc4772ab811393", {from: web3.eth.accounts[1]})&#13;
	function setEmailSent(uint _index, bytes32 _hash) onlyOwner {&#13;
		assert(goals[_hash].amount &gt; 0);&#13;
&#13;
		goals[_hash].emailSent = true;&#13;
		activeGoals[_index].emailSent = true;&#13;
	}&#13;
&#13;
	function setGoalSucceeded(uint _index, bytes32 _hash) onlyOwner {&#13;
		assert(goals[_hash].amount &gt; 0);&#13;
&#13;
		goals[_hash].completed = true;&#13;
		activeGoals[_index].completed = true;&#13;
&#13;
		goals[_hash].owner.transfer(goals[_hash].amount); // send ether back to person who set the goal&#13;
&#13;
		setGoalSucceededEvent(_hash, true);&#13;
	}&#13;
&#13;
	// app.setGoalFailed(0, '0xf7a1a8aa52aeaaaa353ab49ab5cd735f3fd02598b4ff861b314907a414121ba4')&#13;
	function setGoalFailed(uint _index, bytes32 _hash) {&#13;
		assert(goals[_hash].amount &gt; 0);&#13;
		// assert(goals[_hash].emailSent == true);&#13;
&#13;
		goals[_hash].completed = false;&#13;
		activeGoals[_index].completed = false;&#13;
&#13;
		owner.transfer(goals[_hash].amount); // send ether to contract owner&#13;
&#13;
		setGoalFailedEvent(_hash, false);&#13;
	}&#13;
&#13;
	// Fallback function in case someone sends ether to the contract so it doesn't get lost&#13;
	function() payable {}&#13;
&#13;
    function kill() onlyOwner { &#13;
    	selfdestruct(owner);&#13;
    }&#13;
}