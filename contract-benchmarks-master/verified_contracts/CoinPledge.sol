pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: contracts/CoinPledge.sol

/// @title CoinPledge
/// @author Igor Yalovoy
/// @notice Reach your goals and have fun with friends
/// @dev All function calls are currently implement without side effects
/// @web: ylv.io
/// @email: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3c48537c45504a125553">[email protected]</a>&#13;
/// @gitHub: https://github.com/ylv-io/coinpledge/tree/master&#13;
/// @twitter: https://twitter.com/ylv_io&#13;
&#13;
// Proofs:&#13;
// Public commitment as a motivator for weight loss (https://onlinelibrary.wiley.com/doi/pdf/10.1002/mar.20316)&#13;
&#13;
&#13;
pragma solidity ^0.4.24;&#13;
&#13;
&#13;
&#13;
contract CoinPledge is Ownable {&#13;
&#13;
  using SafeMath for uint256;&#13;
&#13;
  uint constant daysToResolve = 7 days;&#13;
  uint constant bonusPercentage = 50;&#13;
  uint constant serviceFeePercentage = 10;&#13;
  uint constant minBonus = 1 finney;&#13;
&#13;
  struct Challenge {&#13;
    address user;&#13;
    string name;&#13;
    uint value;&#13;
    address mentor;&#13;
    uint startDate;&#13;
    uint time;&#13;
    uint mentorFee;&#13;
&#13;
    bool successed;&#13;
    bool resolved;&#13;
  }&#13;
&#13;
  struct User {&#13;
    address addr;&#13;
    string name;&#13;
  }&#13;
&#13;
  // Events&#13;
  event NewChallenge(&#13;
    uint indexed challengeId,&#13;
    address indexed user,&#13;
    string name,&#13;
    uint value,&#13;
    address indexed mentor,&#13;
    uint startDate,&#13;
    uint time,&#13;
    uint mentorFee&#13;
  );&#13;
&#13;
  event ChallengeResolved(&#13;
    uint indexed challengeId,&#13;
    address indexed user,&#13;
    address indexed mentor,&#13;
    bool decision&#13;
  );&#13;
&#13;
  event BonusFundChanged(&#13;
    address indexed user,&#13;
    uint value&#13;
  );&#13;
&#13;
  event NewUsername(&#13;
    address indexed addr,&#13;
    string name&#13;
  );&#13;
&#13;
&#13;
  event Donation(&#13;
    string name,&#13;
    string url,&#13;
    uint value,&#13;
    uint timestamp&#13;
  );&#13;
&#13;
  /// @notice indicated is game over or not&#13;
  bool public isGameOver;&#13;
&#13;
  /// @notice All Challenges&#13;
  Challenge[] public challenges;&#13;
&#13;
  mapping(uint =&gt; address) public challengeToUser;&#13;
  mapping(address =&gt; uint) public userToChallengeCount;&#13;
&#13;
  mapping(uint =&gt; address) public challengeToMentor;&#13;
  mapping(address =&gt; uint) public mentorToChallengeCount;&#13;
&#13;
  /// @notice All Users&#13;
  mapping(address =&gt; User) public users;&#13;
  address[] public allUsers;&#13;
  mapping(string =&gt; address) private usernameToAddress;&#13;
  &#13;
  /// @notice User's bonuses&#13;
  mapping(address =&gt; uint) public bonusFund;&#13;
&#13;
  /// @notice Can access only if game is not over&#13;
  modifier gameIsNotOver() {&#13;
    require(!isGameOver, "Game should be not over");&#13;
    _;&#13;
  }&#13;
&#13;
  /// @notice Can access only if game is over&#13;
  modifier gameIsOver() {&#13;
    require(isGameOver, "Game should be over");&#13;
    _;&#13;
  }&#13;
&#13;
  /// @notice Get Bonus Fund For User&#13;
  function getBonusFund(address user)&#13;
  external&#13;
  view&#13;
  returns(uint) {&#13;
    return bonusFund[user];&#13;
  }&#13;
&#13;
  /// @notice Get Users Lenght&#13;
  function getUsersCount()&#13;
  external&#13;
  view&#13;
  returns(uint) {&#13;
    return allUsers.length;&#13;
  }&#13;
&#13;
  /// @notice Get Challenges For User&#13;
  function getChallengesForUser(address user)&#13;
  external&#13;
  view&#13;
  returns(uint[]) {&#13;
    require(userToChallengeCount[user] &gt; 0, "Has zero challenges");&#13;
&#13;
    uint[] memory result = new uint[](userToChallengeCount[user]);&#13;
    uint counter = 0;&#13;
    for (uint i = 0; i &lt; challenges.length; i++) {&#13;
      if (challengeToUser[i] == user)&#13;
      {&#13;
        result[counter] = i;&#13;
        counter++;&#13;
      }&#13;
    }&#13;
    return result;&#13;
  }&#13;
&#13;
  /// @notice Get Challenges For Mentor&#13;
  function getChallengesForMentor(address mentor)&#13;
  external&#13;
  view&#13;
  returns(uint[]) {&#13;
    require(mentorToChallengeCount[mentor] &gt; 0, "Has zero challenges");&#13;
&#13;
    uint[] memory result = new uint[](mentorToChallengeCount[mentor]);&#13;
    uint counter = 0;&#13;
    for (uint i = 0; i &lt; challenges.length; i++) {&#13;
      if (challengeToMentor[i] == mentor)&#13;
      {&#13;
        result[counter] = i;&#13;
        counter++;&#13;
      }&#13;
    }&#13;
    return result;&#13;
  }&#13;
  &#13;
  /// @notice Ends game&#13;
  function gameOver()&#13;
  external&#13;
  gameIsNotOver&#13;
  onlyOwner {&#13;
    isGameOver = true;&#13;
  }&#13;
&#13;
  /// @notice Set Username&#13;
  function setUsername(string name)&#13;
  external&#13;
  gameIsNotOver {&#13;
    require(bytes(name).length &gt; 2, "Provide a name longer than 2 chars");&#13;
    require(bytes(name).length &lt;= 32, "Provide a name shorter than 33 chars");&#13;
    require(users[msg.sender].addr == address(0x0), "You already have a name");&#13;
    require(usernameToAddress[name] == address(0x0), "Name already taken");&#13;
&#13;
    users[msg.sender] = User(msg.sender, name);&#13;
    usernameToAddress[name] = msg.sender;&#13;
    allUsers.push(msg.sender);&#13;
&#13;
    emit NewUsername(msg.sender, name);&#13;
  }&#13;
&#13;
  /// @notice Creates Challenge&#13;
  function createChallenge(string name, string mentor, uint time, uint mentorFee)&#13;
  external&#13;
  payable&#13;
  gameIsNotOver&#13;
  returns (uint retId) {&#13;
    require(msg.value &gt;= 0.01 ether, "Has to stake more than 0.01 ether");&#13;
    require(mentorFee &gt;= 0 ether, "Can't be negative");&#13;
    require(mentorFee &lt;= msg.value, "Can't be bigger than stake");&#13;
    require(bytes(mentor).length &gt; 0, "Has to be a mentor");&#13;
    require(usernameToAddress[mentor] != address(0x0), "Mentor has to be registered");&#13;
    require(time &gt; 0, "Time has to be greater than zero");&#13;
&#13;
    address mentorAddr = usernameToAddress[mentor];&#13;
&#13;
    require(msg.sender != mentorAddr, "Can't be mentor to yourself");&#13;
&#13;
    uint startDate = block.timestamp;&#13;
    uint id = challenges.push(Challenge(msg.sender, name, msg.value, mentorAddr, startDate, time, mentorFee, false, false)) - 1;&#13;
&#13;
    challengeToUser[id] = msg.sender;&#13;
    userToChallengeCount[msg.sender]++;&#13;
&#13;
    challengeToMentor[id] = mentorAddr;&#13;
    mentorToChallengeCount[mentorAddr]++;&#13;
&#13;
    emit NewChallenge(id, msg.sender, name, msg.value, mentorAddr, startDate, time, mentorFee);&#13;
&#13;
    return id;&#13;
  }&#13;
&#13;
  /// @notice Resolves Challenge&#13;
  function resolveChallenge(uint challengeId, bool decision)&#13;
  external&#13;
  gameIsNotOver {&#13;
    Challenge storage challenge = challenges[challengeId];&#13;
    &#13;
    require(challenge.resolved == false, "Challenge already resolved.");&#13;
&#13;
    // if more time passed than endDate + daysToResolve, then user can resolve himself&#13;
    if(block.timestamp &lt; (challenge.startDate + challenge.time + daysToResolve))&#13;
      require(challenge.mentor == msg.sender, "You are not the mentor for this challenge.");&#13;
    else require((challenge.user == msg.sender) || (challenge.mentor == msg.sender), "You are not the user or mentor for this challenge.");&#13;
&#13;
    uint mentorFee;&#13;
    uint serviceFee;&#13;
    &#13;
    address user = challengeToUser[challengeId];&#13;
    address mentor = challengeToMentor[challengeId];&#13;
&#13;
    // write decision&#13;
    challenge.successed = decision;&#13;
    challenge.resolved = true;&#13;
&#13;
    uint remainingValue = challenge.value;&#13;
&#13;
    // mentor &amp; service fee&#13;
    if(challenge.mentorFee &gt; 0) {&#13;
      serviceFee = challenge.mentorFee.div(100).mul(serviceFeePercentage);&#13;
      mentorFee = challenge.mentorFee.div(100).mul(100 - serviceFeePercentage);&#13;
    }&#13;
    &#13;
    if(challenge.mentorFee &gt; 0)&#13;
      remainingValue = challenge.value.sub(challenge.mentorFee);&#13;
&#13;
    uint valueToPay;&#13;
&#13;
    if(decision) {&#13;
      // value to pay back to user&#13;
      valueToPay = remainingValue;&#13;
      // credit bouns if any&#13;
      uint currentBonus = bonusFund[user];&#13;
      if(currentBonus &gt; 0)&#13;
      {&#13;
        uint bonusValue = bonusFund[user].div(100).mul(bonusPercentage);&#13;
        if(currentBonus &lt;= minBonus)&#13;
          bonusValue = currentBonus;&#13;
        bonusFund[user] -= bonusValue;&#13;
        emit BonusFundChanged(user, bonusFund[user]);&#13;
&#13;
        valueToPay += bonusValue;&#13;
      }&#13;
    }&#13;
    else {&#13;
      bonusFund[user] += remainingValue;&#13;
      emit BonusFundChanged(user, bonusFund[user]);&#13;
    }&#13;
&#13;
    // pay back to the challenger&#13;
    if(valueToPay &gt; 0)&#13;
      user.transfer(valueToPay);&#13;
&#13;
    if(mentorFee &gt; 0)&#13;
      mentor.transfer(mentorFee);&#13;
&#13;
    if(serviceFee &gt; 0)&#13;
      owner().transfer(serviceFee);&#13;
&#13;
    emit ChallengeResolved(challengeId, user, mentor, decision);&#13;
  }&#13;
&#13;
  function withdraw()&#13;
  external&#13;
  gameIsOver {&#13;
    require(bonusFund[msg.sender] &gt; 0, "You do not have any funds");&#13;
&#13;
    uint funds = bonusFund[msg.sender];&#13;
    bonusFund[msg.sender] = 0;&#13;
    msg.sender.transfer(funds);&#13;
  }&#13;
&#13;
  function donate(string name, string url)&#13;
  external&#13;
  payable&#13;
  gameIsNotOver {&#13;
    owner().transfer(msg.value);&#13;
    emit Donation(name, url, msg.value, block.timestamp);&#13;
  }&#13;
}