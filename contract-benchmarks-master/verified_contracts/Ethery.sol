pragma solidity ^0.4.18;


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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7200171f111d3240">[email protected]</a>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private reentrancy_lock = false;&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * @notice If you mark a function `nonReentrant`, you should also&#13;
   * mark it `external`. Calling one nonReentrant function from&#13;
   * another is not supported. Instead, you can implement a&#13;
   * `private` function doing the actual work, and a `external`&#13;
   * wrapper marked as `nonReentrant`.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    require(!reentrancy_lock);&#13;
    reentrancy_lock = true;&#13;
    _;&#13;
    reentrancy_lock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
contract Ethery is Pausable, ReentrancyGuard{&#13;
  event NewBet(uint id, address player, uint wager, uint targetBlock);&#13;
  event BetResolved(uint id, BetStatus status);&#13;
  &#13;
  bytes32 constant byteMask = bytes32(0xF);&#13;
&#13;
  enum BetStatus { Pending, PlayerWon, HouseWon, Refunded }&#13;
  &#13;
  struct Bet {&#13;
    address player;&#13;
    uint wager;&#13;
    uint digits;&#13;
    bytes32 guess;&#13;
    BetStatus status;&#13;
    uint targetBlock;&#13;
  }&#13;
  &#13;
  Bet[] public bets;&#13;
  &#13;
  mapping (uint =&gt; address) public betToOwner;&#13;
  mapping (address =&gt; uint) ownerBetCount;&#13;
  &#13;
  uint resolverFee = 0.1 finney;&#13;
  uint maxPayout = 1 ether;&#13;
  uint pendingPay;&#13;
  &#13;
  function setResolverFee(uint _resolverFee) external onlyOwner {&#13;
    resolverFee = _resolverFee;&#13;
  }&#13;
  &#13;
  function getResolverFee() external view returns (uint){&#13;
    return resolverFee;&#13;
  }&#13;
  &#13;
  function setMaxPayout(uint _maxPayout) external onlyOwner {&#13;
    maxPayout = _maxPayout;&#13;
  }&#13;
&#13;
  function getMaxPayout() external view returns (uint){&#13;
    return maxPayout;&#13;
  }&#13;
  &#13;
  function withDraw(uint _amount) external onlyOwner {&#13;
    require(_amount &lt; this.balance - pendingPay);&#13;
    msg.sender.transfer(_amount);&#13;
  }&#13;
  &#13;
  function () public payable {}&#13;
  &#13;
  function createBet(uint _digits, bytes32 _guess, uint _targetBlock) public payable whenNotPaused {&#13;
    require(&#13;
      msg.value &gt;= resolverFee &amp;&amp;&#13;
      _targetBlock &gt; block.number &amp;&amp;&#13;
      block.number + 256 &gt;= _targetBlock &amp;&amp;&#13;
      payout(msg.value, _digits) &lt;= maxPayout &amp;&amp;&#13;
      payout(msg.value, _digits) &lt;= this.balance - pendingPay&#13;
    );&#13;
    uint id = bets.push(Bet(msg.sender, msg.value, _digits, _guess, BetStatus.Pending, _targetBlock)) - 1;&#13;
    betToOwner[id] = msg.sender;&#13;
    ownerBetCount[msg.sender]++;&#13;
    pendingPay += payout(msg.value, _digits);&#13;
    NewBet(id, msg.sender, msg.value, _targetBlock);&#13;
  }&#13;
  &#13;
  function resolveBet(uint _betId) public nonReentrant returns (BetStatus) {&#13;
    Bet storage myBet = bets[_betId];  &#13;
    require(&#13;
      myBet.status == BetStatus.Pending &amp;&amp;    // only resolve pending bets&#13;
      myBet.targetBlock &lt; block.number        // only resolve targetBlock &gt; current block&#13;
    );&#13;
    &#13;
    pendingPay -= payout(myBet.wager, uint(myBet.digits));&#13;
    &#13;
    if (myBet.targetBlock + 255 &lt; block.number) {    // too late to determine out come issue refund&#13;
      myBet.status = BetStatus.Refunded;&#13;
      betToOwner[_betId].transfer(myBet.wager);&#13;
    } else {&#13;
      bytes32 targetBlockHash = block.blockhash(myBet.targetBlock);&#13;
      if (isCorrectGuess(targetBlockHash, myBet.guess, uint(myBet.digits))) {&#13;
        myBet.status = BetStatus.PlayerWon;&#13;
        betToOwner[_betId].transfer(payout(myBet.wager, uint(myBet.digits)));&#13;
      } else {&#13;
        myBet.status = BetStatus.HouseWon;&#13;
      }&#13;
    }&#13;
    msg.sender.transfer(resolverFee);&#13;
    BetResolved(_betId, myBet.status);&#13;
    return myBet.status;&#13;
  }&#13;
  &#13;
  function isCorrectGuess(bytes32 _blockHash, bytes32 _guess, uint _digits) public pure returns (bool) {&#13;
    for (uint i = 0; i &lt; uint(_digits); i++) {&#13;
      if (byteMask &amp; _guess != _blockHash &amp; byteMask) {&#13;
        return false;&#13;
      }&#13;
      _blockHash = _blockHash &gt;&gt; 4;&#13;
      _guess = _guess &gt;&gt; 4;&#13;
    }&#13;
    return true;&#13;
  }&#13;
  &#13;
  function payout(uint _wager, uint _digits) public view returns (uint) {&#13;
    uint baseWager = (100 - houseFee(_digits)) * (_wager - resolverFee) / 100;&#13;
    return baseWager * 16 ** _digits;&#13;
  }&#13;
  &#13;
  function houseFee(uint _digits) public pure returns (uint) {    // in percent&#13;
    require(0 &lt; _digits &amp;&amp; _digits &lt;= 4);&#13;
    if (_digits == 1) { return 2; }&#13;
    else if(_digits == 2) { return 3; }&#13;
    else if(_digits == 3) { return 4; }&#13;
    else { return 5; }&#13;
  }&#13;
  &#13;
  function getBet(uint index) public view returns(address, uint, uint, bytes32, BetStatus, uint) {&#13;
    return (bets[index].player, bets[index].wager, bets[index].digits, bets[index].guess, bets[index].status, bets[index].targetBlock);&#13;
  }&#13;
  &#13;
  function getPlayerBets() external view returns(uint[]) {&#13;
    return getBetsByOwner(msg.sender);  &#13;
  }&#13;
  &#13;
  function getBetsByOwner(address _owner) private view returns(uint[]) {&#13;
    uint[] memory result = new uint[](ownerBetCount[_owner]);&#13;
    uint counter = 0;&#13;
    for (uint i = 0; i &lt; bets.length; i++) {&#13;
      if (betToOwner[i] == _owner) {&#13;
        result[counter] = i;&#13;
        counter++;&#13;
      }&#13;
    }&#13;
    return result;&#13;
  }&#13;
  &#13;
  function getTotalWins() external view returns(uint) {&#13;
    uint pays = 0;&#13;
    for (uint i = 0; i &lt; bets.length; i++) {&#13;
      if (bets[i].status == BetStatus.PlayerWon) {&#13;
        pays += payout(bets[i].wager, bets[i].digits);&#13;
      }&#13;
    }&#13;
    return pays;&#13;
  }&#13;
&#13;
  function recentWinners() external view returns(uint[]) {&#13;
    uint len = 5;&#13;
    uint[] memory result = new uint[](len);&#13;
    uint counter = 0;&#13;
&#13;
    for (uint i = 1; i &lt;= bets.length &amp;&amp; counter &lt; len; i++) {&#13;
      if (bets[bets.length - i].status == BetStatus.PlayerWon) {&#13;
        result[counter] = bets.length - i;&#13;
        counter++;&#13;
      }&#13;
    }&#13;
    return result;&#13;
  }&#13;
&#13;
}