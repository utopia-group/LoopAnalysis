pragma solidity ^0.4.24;

// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: node_modules/openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c2b0a7afa1ad82f0">[email protected]</a>π.com&gt;, Eenae &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="9efff2fbe6fbe7def3f7e6fce7eafbedb0f7f1">[email protected]</a>&gt;&#13;
 * @dev If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /// @dev counter to allow mutex lock with only one SSTORE operation&#13;
  uint256 private _guardCounter;&#13;
&#13;
  constructor() internal {&#13;
    // The counter starts at one to prevent changing it from zero to a non-zero&#13;
    // value, which is a more expensive operation.&#13;
    _guardCounter = 1;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * Calling a `nonReentrant` function from another `nonReentrant`&#13;
   * function is not supported. It is possible to prevent this from happening&#13;
   * by making the `nonReentrant` function external, and make it call a&#13;
   * `private` function that does the actual work.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    _guardCounter += 1;&#13;
    uint256 localCounter = _guardCounter;&#13;
    _;&#13;
    require(localCounter == _guardCounter);&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: node_modules/openzeppelin-solidity/contracts/math/Safemath.sol&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that revert on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, reverts on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the&#13;
    // benefit is lost if 'b' is also tested.&#13;
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    uint256 c = a * b;&#13;
    require(c / a == b);&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    require(b &gt; 0); // Solidity only automatically asserts when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    require(b &lt;= a);&#13;
    uint256 c = a - b;&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, reverts on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    require(c &gt;= a);&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),&#13;
  * reverts when dividing by zero.&#13;
  */&#13;
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    require(b != 0);&#13;
    return a % b;&#13;
  }&#13;
}&#13;
&#13;
// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
interface IERC20 {&#13;
  function totalSupply() external view returns (uint256);&#13;
&#13;
  function balanceOf(address who) external view returns (uint256);&#13;
&#13;
  function allowance(address owner, address spender)&#13;
    external view returns (uint256);&#13;
&#13;
  function transfer(address to, uint256 value) external returns (bool);&#13;
&#13;
  function approve(address spender, uint256 value)&#13;
    external returns (bool);&#13;
&#13;
  function transferFrom(address from, address to, uint256 value)&#13;
    external returns (bool);&#13;
&#13;
  event Transfer(&#13;
    address indexed from,&#13;
    address indexed to,&#13;
    uint256 value&#13;
  );&#13;
&#13;
  event Approval(&#13;
    address indexed owner,&#13;
    address indexed spender,&#13;
    uint256 value&#13;
  );&#13;
}&#13;
&#13;
// File: lib/CanReclaimToken.sol&#13;
&#13;
/**&#13;
 * @title Contracts that should be able to recover tokens&#13;
 * @author SylTi&#13;
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.&#13;
 * This will prevent any accidental loss of tokens.&#13;
 */&#13;
contract CanReclaimToken is Ownable {&#13;
&#13;
  /**&#13;
   * @dev Reclaim all ERC20 compatible tokens&#13;
   * @param token ERC20 The address of the token contract&#13;
   */&#13;
  function reclaimToken(IERC20 token) external onlyOwner {&#13;
    if (address(token) == address(0)) {&#13;
      owner().transfer(address(this).balance);&#13;
      return;&#13;
    }&#13;
    uint256 balance = token.balanceOf(this);&#13;
    token.transfer(owner(), balance);&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts/Mentoring.sol&#13;
&#13;
interface HEROES {&#13;
  function getLevel(uint256 tokenId) external view returns (uint256);&#13;
  function getGenes(uint256 tokenId) external view returns (uint256);&#13;
  function getRace(uint256 tokenId) external view returns (uint256);&#13;
  function lock(uint256 tokenId, uint256 lockedTo, bool onlyFreeze) external returns (bool);&#13;
  function unlock(uint256 tokenId) external returns (bool);&#13;
  function ownerOf(uint256 tokenId) external view returns (address);&#13;
  function isCallerAgentOf(uint tokenId) external view returns (bool);&#13;
  function addWin(uint256 tokenId, uint winsCount, uint levelUp) external returns (bool);&#13;
  function addLoss(uint256 tokenId, uint256 lossesCount, uint levelDown) external returns (bool);&#13;
}&#13;
&#13;
&#13;
contract Mentoring is Ownable, ReentrancyGuard, CanReclaimToken  {&#13;
  using SafeMath for uint256;&#13;
&#13;
  event BecomeMentor(uint256 indexed mentorId);&#13;
  event BreakMentoring(uint256 indexed mentorId);&#13;
  event ChangeLevelPrice(uint256 indexed mentorId, uint256 newLevelPrice);&#13;
  event Income(address source, uint256 amount);&#13;
&#13;
  event StartLecture(uint256 indexed lectureId,&#13;
    uint256 indexed mentorId,&#13;
    uint256 indexed studentId,&#13;
    uint256 mentorLevel,&#13;
    uint256 studentLevel,&#13;
    uint256 levelUp,&#13;
    uint256 levelPrice,&#13;
    uint256 startedAt,&#13;
    uint256 endsAt);&#13;
&#13;
//  event Withdraw(address to, uint256 amount);&#13;
&#13;
  struct Lecture {&#13;
    uint256 mentorId;&#13;
    uint256 studentId;&#13;
    uint256 mentorLevel;&#13;
    uint256 studentLevel;&#13;
    uint256 levelUp;&#13;
    uint256 levelPrice;&#13;
//    uint256 cost;&#13;
    uint256 startedAt;&#13;
    uint256 endsAt;&#13;
  }&#13;
&#13;
  HEROES public heroes;&#13;
&#13;
  uint256 public fee = 290; //2.9%&#13;
  uint256 public levelUpTime = 20 minutes;&#13;
&#13;
  mapping(uint256 =&gt; uint256) internal prices;&#13;
&#13;
  Lecture[] internal lectures;&#13;
  /* tokenId =&gt; lecture index */&#13;
  mapping(uint256 =&gt; uint256[]) studentToLecture;&#13;
  mapping(uint256 =&gt; uint256[]) mentorToLecture;&#13;
&#13;
  modifier onlyOwnerOf(uint256 _tokenId) {&#13;
    require(heroes.ownerOf(_tokenId) == msg.sender);&#13;
    _;&#13;
  }&#13;
&#13;
  constructor (HEROES _heroes) public {&#13;
    require(address(_heroes) != address(0));&#13;
    heroes = _heroes;&#13;
&#13;
    //fix lectureId issue - add zero lecture&#13;
    lectures.length = 1;&#13;
  }&#13;
&#13;
  /// @notice The fallback function payable&#13;
  function() external payable {&#13;
    require(msg.value &gt; 0);&#13;
    _flushBalance();&#13;
  }&#13;
&#13;
  function _flushBalance() private {&#13;
    uint256 balance = address(this).balance;&#13;
    if (balance &gt; 0) {&#13;
      address(heroes).transfer(balance);&#13;
      emit Income(address(this), balance);&#13;
    }&#13;
  }&#13;
&#13;
&#13;
  function _distributePayment(address _account, uint256 _amount) internal {&#13;
    uint256 pcnt = _getPercent(_amount, fee);&#13;
    uint256 amount = _amount.sub(pcnt);&#13;
    _account.transfer(amount);&#13;
  }&#13;
&#13;
  /**&#13;
   * Set fee&#13;
   */&#13;
  function setFee(uint256 _fee) external onlyOwner&#13;
  {&#13;
    fee = _fee;&#13;
  }&#13;
&#13;
  // MENTORING&#13;
&#13;
  /**&#13;
   * Set the one level up time&#13;
   */&#13;
&#13;
  function setLevelUpTime(uint256 _newLevelUpTime) external onlyOwner&#13;
  {&#13;
    levelUpTime = _newLevelUpTime;&#13;
  }&#13;
&#13;
  function isMentor(uint256 _mentorId) public view returns (bool)&#13;
  {&#13;
    //проверяем установлена ли цена обучения и текущий агент пресонажа =менторство&#13;
    return heroes.isCallerAgentOf(_mentorId); // &amp;&amp; prices[_mentorId] != 0;&#13;
  }&#13;
&#13;
  function inStudying(uint256 _tokenId) public view returns (bool) {&#13;
    return now &lt;= lectures[getLastLectureIdAsStudent(_tokenId)].endsAt;&#13;
  }&#13;
&#13;
  function inMentoring(uint256 _tokenId) public view returns (bool) {&#13;
    return now &lt;= lectures[getLastLectureIdAsMentor(_tokenId)].endsAt;&#13;
  }&#13;
&#13;
  function inLecture(uint256 _tokenId) public view returns (bool)&#13;
  {&#13;
    return inMentoring(_tokenId) || inStudying(_tokenId);&#13;
  }&#13;
&#13;
  /**&#13;
   * Set the character as mentor&#13;
   */&#13;
  function becomeMentor(uint256 _mentorId, uint256 _levelPrice) external onlyOwnerOf(_mentorId) {&#13;
    require(_levelPrice &gt; 0);&#13;
    require(heroes.lock(_mentorId, 0, false));&#13;
    prices[_mentorId] = _levelPrice;&#13;
    emit BecomeMentor(_mentorId);&#13;
    emit ChangeLevelPrice(_mentorId, _levelPrice);&#13;
  }&#13;
&#13;
  /**&#13;
   * Change price&#13;
   */&#13;
  function changeLevelPrice(uint256 _mentorId, uint256 _levelPrice) external onlyOwnerOf(_mentorId) {&#13;
    require(_levelPrice &gt; 0);&#13;
    require(isMentor(_mentorId));&#13;
    prices[_mentorId] = _levelPrice;&#13;
    emit ChangeLevelPrice(_mentorId, _levelPrice);&#13;
  }&#13;
&#13;
  /**&#13;
   * Break mentoring for character&#13;
   */&#13;
  function breakMentoring(uint256 _mentorId) external onlyOwnerOf(_mentorId)&#13;
  {&#13;
    require(heroes.unlock(_mentorId));&#13;
    emit BreakMentoring(_mentorId);&#13;
  }&#13;
&#13;
  function getMentor(uint256 _mentorId) external view returns (uint256 level, uint256 price) {&#13;
    require(isMentor(_mentorId));&#13;
    return (heroes.getLevel(_mentorId), prices[_mentorId]);&#13;
  }&#13;
&#13;
  function _calcLevelIncrease(uint256 _mentorLevel, uint256 _studentLevel) internal pure returns (uint256) {&#13;
    if (_mentorLevel &lt; _studentLevel) {&#13;
      return 0;&#13;
    }&#13;
    uint256 levelDiff = _mentorLevel - _studentLevel;&#13;
    return (levelDiff &gt;&gt; 1) + (levelDiff &amp; 1);&#13;
  }&#13;
&#13;
  /**&#13;
   * calc full cost of study&#13;
   */&#13;
  function calcCost(uint256 _mentorId, uint256 _studentId) external view returns (uint256) {&#13;
    uint256 levelUp = _calcLevelIncrease(heroes.getLevel(_mentorId), heroes.getLevel(_studentId));&#13;
    return levelUp.mul(prices[_mentorId]);&#13;
  }&#13;
&#13;
  function isRaceSuitable(uint256 _mentorId, uint256 _studentId) public view returns (bool) {&#13;
    uint256 mentorRace = heroes.getGenes(_mentorId) &amp; 0xFFFF;&#13;
    uint256 studentRace = heroes.getGenes(_studentId) &amp; 0xFFFF;&#13;
    return (mentorRace == 1 || mentorRace == studentRace);&#13;
  }&#13;
&#13;
  /**&#13;
   * Start the study&#13;
   */&#13;
  function startLecture(uint256 _mentorId, uint256 _studentId) external payable onlyOwnerOf(_studentId) {&#13;
    require(isMentor(_mentorId));&#13;
&#13;
    // Check race&#13;
    require(isRaceSuitable(_mentorId, _studentId));&#13;
&#13;
    uint256 mentorLevel = heroes.getLevel(_mentorId);&#13;
    uint256 studentLevel = heroes.getLevel(_studentId);&#13;
&#13;
    uint256 levelUp = _calcLevelIncrease(mentorLevel, studentLevel);&#13;
    require(levelUp &gt; 0);&#13;
&#13;
    // check sum is enough&#13;
    uint256 cost = levelUp.mul(prices[_mentorId]);&#13;
    require(cost == msg.value);&#13;
&#13;
    Lecture memory lecture = Lecture({&#13;
      mentorId : _mentorId,&#13;
      studentId : _studentId,&#13;
      mentorLevel: mentorLevel,&#13;
      studentLevel: studentLevel,&#13;
      levelUp: levelUp,&#13;
      levelPrice : prices[_mentorId],&#13;
      startedAt : now,&#13;
      endsAt : now + levelUp.mul(levelUpTime)&#13;
      });&#13;
&#13;
    //locking mentor&#13;
    require(heroes.lock(_mentorId, lecture.endsAt, true));&#13;
&#13;
    //locking student&#13;
    require(heroes.lock(_studentId, lecture.endsAt, true));&#13;
&#13;
&#13;
    //save lecture&#13;
    //id starts from 1&#13;
    uint256 lectureId = lectures.push(lecture) - 1;&#13;
&#13;
    studentToLecture[_studentId].push(lectureId);&#13;
    mentorToLecture[_mentorId].push(lectureId);&#13;
&#13;
    heroes.addWin(_studentId, 0, levelUp);&#13;
&#13;
    emit StartLecture(&#13;
      lectureId,&#13;
      _mentorId,&#13;
      _studentId,&#13;
      lecture.mentorLevel,&#13;
      lecture.studentLevel,&#13;
      lecture.levelUp,&#13;
      lecture.levelPrice,&#13;
      lecture.startedAt,&#13;
      lecture.endsAt&#13;
    );&#13;
&#13;
    _distributePayment(heroes.ownerOf(_mentorId), cost);&#13;
&#13;
    _flushBalance();&#13;
  }&#13;
&#13;
  function lectureExists(uint256 _lectureId) public view returns (bool)&#13;
  {&#13;
    return (_lectureId &gt; 0 &amp;&amp; _lectureId &lt; lectures.length);&#13;
  }&#13;
&#13;
  function getLecture(uint256 lectureId) external view returns (&#13;
    uint256 mentorId,&#13;
    uint256 studentId,&#13;
    uint256 mentorLevel,&#13;
    uint256 studentLevel,&#13;
    uint256 levelUp,&#13;
    uint256 levelPrice,&#13;
    uint256 cost,&#13;
    uint256 startedAt,&#13;
    uint256 endsAt)&#13;
  {&#13;
    require(lectureExists(lectureId));&#13;
    Lecture memory l = lectures[lectureId];&#13;
    return (l.mentorId, l.studentId, l.mentorLevel, l.studentLevel, l.levelUp, l.levelPrice, l.levelUp.mul(l.levelPrice), l.startedAt, l.endsAt);&#13;
  }&#13;
&#13;
  function getLastLectureIdAsMentor(uint256 _tokenId) public view returns (uint256) {&#13;
    return mentorToLecture[_tokenId].length &gt; 0 ? mentorToLecture[_tokenId][mentorToLecture[_tokenId].length - 1] : 0;&#13;
  }&#13;
  function getLastLectureIdAsStudent(uint256 _tokenId) public view returns (uint256) {&#13;
    return studentToLecture[_tokenId].length &gt; 0 ? studentToLecture[_tokenId][studentToLecture[_tokenId].length - 1] : 0;&#13;
  }&#13;
 &#13;
&#13;
  function getLastLecture(uint256 tokenId) external view returns (&#13;
    uint256 lectureId,&#13;
    uint256 mentorId,&#13;
    uint256 studentId,&#13;
    uint256 mentorLevel,&#13;
    uint256 studentLevel,&#13;
    uint256 levelUp,&#13;
    uint256 levelPrice,&#13;
    uint256 cost,&#13;
    uint256 startedAt,&#13;
    uint256 endsAt)&#13;
  {&#13;
    uint256 mentorLectureId = getLastLectureIdAsMentor(tokenId);&#13;
    uint256 studentLectureId = getLastLectureIdAsStudent(tokenId);&#13;
    lectureId = studentLectureId &gt; mentorLectureId ? studentLectureId : mentorLectureId;&#13;
    require(lectureExists(lectureId));&#13;
    Lecture storage l = lectures[lectureId];&#13;
    return (lectureId, l.mentorId, l.studentId, l.mentorLevel, l.studentLevel, l.levelUp, l.levelPrice, l.levelUp.mul(l.levelPrice), l.startedAt, l.endsAt);&#13;
  }&#13;
&#13;
  //// SERVICE&#13;
  //1% - 100, 10% - 1000 50% - 5000&#13;
  function _getPercent(uint256 _v, uint256 _p) internal pure returns (uint)    {&#13;
    return _v.mul(_p).div(10000);&#13;
  }&#13;
}