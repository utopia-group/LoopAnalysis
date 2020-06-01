/**
 * LockRule.sol
 * Rule to lock all tokens on a schedule and define a whitelist of exceptions.

 * More info about MPS : https://github.com/MtPelerin/MtPelerin-share-MPS

 * The unflattened code is available through this github tag:
 * https://github.com/MtPelerin/MtPelerin-protocol/tree/etherscan-verify-batch-2

 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved

 * @notice All matters regarding the intellectual property of this code 
 * @notice or software are subject to Swiss Law without reference to its 
 * @notice conflicts of law rules.

 * @notice License for each contract is available in the respective file
 * @notice or in the LICENSE.md file.
 * @notice https://github.com/MtPelerin/

 * @notice Code by OpenZeppelin is copyrighted and licensed on their repository:
 * @notice https://github.com/OpenZeppelin/openzeppelin-solidity
 */


 pragma solidity ^0.4.24;

// File: contracts/zeppelin/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/Authority.sol

/**
 * @title Authority
 * @dev The Authority contract has an authority address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * Authority means to represent a legal entity that is entitled to specific rights
 *
 * @author Cyril Lapinte - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="02617b706b6e2c6e63726b6c7667426f7672676e67706b6c2c616d6f">[email protected]</a>&gt;&#13;
 *&#13;
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved&#13;
 * @notice Please refer to the top of this file for the license.&#13;
 *&#13;
 * Error messages&#13;
 * AU01: Message sender must be an authority&#13;
 */&#13;
contract Authority is Ownable {&#13;
&#13;
  address authority;&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the authority.&#13;
   */&#13;
  modifier onlyAuthority {&#13;
    require(msg.sender == authority, "AU01");&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Returns the address associated to the authority&#13;
   */&#13;
  function authorityAddress() public view returns (address) {&#13;
    return authority;&#13;
  }&#13;
&#13;
  /** Define an address as authority, with an arbitrary name included in the event&#13;
   * @dev returns the authority of the&#13;
   * @param _name the authority name&#13;
   * @param _address the authority address.&#13;
   */&#13;
  function defineAuthority(string _name, address _address) public onlyOwner {&#13;
    emit AuthorityDefined(_name, _address);&#13;
    authority = _address;&#13;
  }&#13;
&#13;
  event AuthorityDefined(&#13;
    string name,&#13;
    address _address&#13;
  );&#13;
}&#13;
&#13;
// File: contracts/interface/IRule.sol&#13;
&#13;
/**&#13;
 * @title IRule&#13;
 * @dev IRule interface&#13;
 * @author Cyril Lapinte - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="90f3e9e2f9fcbefcf1e0f9fee4f5d0fde4e0f5fcf5e2f9febef3fffd">[email protected]</a>&gt;&#13;
 *&#13;
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved&#13;
 * @notice Please refer to the top of this file for the license.&#13;
 **/&#13;
interface IRule {&#13;
  function isAddressValid(address _address) external view returns (bool);&#13;
  function isTransferValid(address _from, address _to, uint256 _amount)&#13;
    external view returns (bool);&#13;
}&#13;
&#13;
// File: contracts/rule/LockRule.sol&#13;
&#13;
/**&#13;
 * @title LockRule&#13;
 * @dev LockRule contract&#13;
 * This rule allow to lock assets for a period of time&#13;
 * for event such as investment vesting&#13;
 *&#13;
 * @author Cyril Lapinte - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a2c1dbd0cbce8ccec3d2cbccd6c7e2cfd6d2c7cec7d0cbcc8cc1cdcf">[email protected]</a>&gt;&#13;
 *&#13;
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved&#13;
 * @notice Please refer to the top of this file for the license.&#13;
 *&#13;
 * Error messages&#13;
 * LOR01: definePass() call have failed&#13;
 * LOR02: startAt must be before or equal to endAt&#13;
 */&#13;
contract LockRule is IRule, Authority {&#13;
&#13;
  enum Direction {&#13;
    NONE,&#13;
    RECEIVE,&#13;
    SEND,&#13;
    BOTH&#13;
  }&#13;
&#13;
  struct ScheduledLock {&#13;
    Direction restriction;&#13;
    uint256 startAt;&#13;
    uint256 endAt;&#13;
    bool scheduleInverted;&#13;
  }&#13;
&#13;
  mapping(address =&gt; Direction) individualPasses;&#13;
  ScheduledLock lock = ScheduledLock(&#13;
    Direction.NONE,&#13;
    0,&#13;
    0,&#13;
    false&#13;
  );&#13;
&#13;
  /**&#13;
   * @dev hasSendDirection&#13;
   */&#13;
  function hasSendDirection(Direction _direction) public pure returns (bool) {&#13;
    return _direction == Direction.SEND || _direction == Direction.BOTH;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev hasReceiveDirection&#13;
   */&#13;
  function hasReceiveDirection(Direction _direction)&#13;
    public pure returns (bool)&#13;
  {&#13;
    return _direction == Direction.RECEIVE || _direction == Direction.BOTH;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev restriction&#13;
   */&#13;
  function restriction() public view returns (Direction) {&#13;
    return lock.restriction;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev scheduledStartAt&#13;
   */&#13;
  function scheduledStartAt() public view returns (uint256) {&#13;
    return lock.startAt;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev scheduledEndAt&#13;
   */&#13;
  function scheduledEndAt() public view returns (uint256) {&#13;
    return lock.endAt;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev lock inverted&#13;
   */&#13;
  function isScheduleInverted() public view returns (bool) {&#13;
    return lock.scheduleInverted;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev isLocked&#13;
   */&#13;
  function isLocked() public view returns (bool) {&#13;
    // solium-disable-next-line security/no-block-members&#13;
    return (lock.startAt &lt;= now &amp;&amp; lock.endAt &gt; now)&#13;
      ? !lock.scheduleInverted : lock.scheduleInverted;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev individualPass&#13;
   */&#13;
  function individualPass(address _address)&#13;
    public view returns (Direction)&#13;
  {&#13;
    return individualPasses[_address];&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev can the address send&#13;
   */&#13;
  function canSend(address _address) public view returns (bool) {&#13;
    if (isLocked() &amp;&amp; hasSendDirection(lock.restriction)) {&#13;
      return hasSendDirection(individualPasses[_address]);&#13;
    }&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev can the address receive&#13;
   */&#13;
  function canReceive(address _address) public view returns (bool) {&#13;
    if (isLocked() &amp;&amp; hasReceiveDirection(lock.restriction)) {&#13;
      return hasReceiveDirection(individualPasses[_address]);&#13;
    }&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev allow authority to provide a pass to an address&#13;
   */&#13;
  function definePass(address _address, uint256 _lock)&#13;
    public onlyAuthority returns (bool)&#13;
  {&#13;
    individualPasses[_address] = Direction(_lock);&#13;
    emit PassDefinition(_address, Direction(_lock));&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev allow authority to provide addresses with lock passes&#13;
   */&#13;
  function defineManyPasses(address[] _addresses, uint256 _lock)&#13;
    public onlyAuthority returns (bool)&#13;
  {&#13;
    for (uint256 i = 0; i &lt; _addresses.length; i++) {&#13;
      require(definePass(_addresses[i], _lock), "LOR01");&#13;
    }&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev schedule lock&#13;
   */&#13;
  function scheduleLock(&#13;
    Direction _restriction,&#13;
    uint256 _startAt, uint256 _endAt, bool _scheduleInverted)&#13;
    public onlyAuthority returns (bool)&#13;
  {&#13;
    require(_startAt &lt;= _endAt, "LOR02");&#13;
    lock = ScheduledLock(&#13;
      _restriction,&#13;
      _startAt,&#13;
      _endAt,&#13;
      _scheduleInverted&#13;
    );&#13;
    emit LockDefinition(&#13;
      lock.restriction, lock.startAt, lock.endAt, lock.scheduleInverted);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev validates an address&#13;
   */&#13;
  function isAddressValid(address /*_address*/) public view returns (bool) {&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev validates a transfer of ownership&#13;
   */&#13;
  function isTransferValid(address _from, address _to, uint256 /* _amount */)&#13;
    public view returns (bool)&#13;
  {&#13;
    return (canSend(_from) &amp;&amp; canReceive(_to));&#13;
  }&#13;
&#13;
  event LockDefinition(&#13;
    Direction restriction,&#13;
    uint256 startAt,&#13;
    uint256 endAt,&#13;
    bool scheduleInverted&#13;
  );&#13;
  event PassDefinition(address _address, Direction pass);&#13;
}