pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
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

// File: solidity-rlp/contracts/RLPReader.sol

/*
* @author Hamdi Allam <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="167e777b727f38777a7a777b2f2156717b777f7a3875797b">[email protected]</a>&#13;
* Please reach out with any questions or concerns&#13;
*/&#13;
pragma solidity ^0.4.24;&#13;
&#13;
library RLPReader {&#13;
    uint8 constant STRING_SHORT_START = 0x80;&#13;
    uint8 constant STRING_LONG_START  = 0xb8;&#13;
    uint8 constant LIST_SHORT_START   = 0xc0;&#13;
    uint8 constant LIST_LONG_START    = 0xf8;&#13;
&#13;
    uint8 constant WORD_SIZE = 32;&#13;
&#13;
    struct RLPItem {&#13;
        uint len;&#13;
        uint memPtr;&#13;
    }&#13;
&#13;
    /*&#13;
    * @param item RLP encoded bytes&#13;
    */&#13;
    function toRlpItem(bytes memory item) internal pure returns (RLPItem memory) {&#13;
        if (item.length == 0) &#13;
            return RLPItem(0, 0);&#13;
&#13;
        uint memPtr;&#13;
        assembly {&#13;
            memPtr := add(item, 0x20)&#13;
        }&#13;
&#13;
        return RLPItem(item.length, memPtr);&#13;
    }&#13;
&#13;
    /*&#13;
    * @param item RLP encoded list in bytes&#13;
    */&#13;
    function toList(RLPItem memory item) internal pure returns (RLPItem[] memory result) {&#13;
        require(isList(item));&#13;
&#13;
        uint items = numItems(item);&#13;
        result = new RLPItem[](items);&#13;
&#13;
        uint memPtr = item.memPtr + _payloadOffset(item.memPtr);&#13;
        uint dataLen;&#13;
        for (uint i = 0; i &lt; items; i++) {&#13;
            dataLen = _itemLength(memPtr);&#13;
            result[i] = RLPItem(dataLen, memPtr); &#13;
            memPtr = memPtr + dataLen;&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
    * Helpers&#13;
    */&#13;
&#13;
    // @return indicator whether encoded payload is a list. negate this function call for isData.&#13;
    function isList(RLPItem memory item) internal pure returns (bool) {&#13;
        uint8 byte0;&#13;
        uint memPtr = item.memPtr;&#13;
        assembly {&#13;
            byte0 := byte(0, mload(memPtr))&#13;
        }&#13;
&#13;
        if (byte0 &lt; LIST_SHORT_START)&#13;
            return false;&#13;
        return true;&#13;
    }&#13;
&#13;
    // @return number of payload items inside an encoded list.&#13;
    function numItems(RLPItem memory item) internal pure returns (uint) {&#13;
        uint count = 0;&#13;
        uint currPtr = item.memPtr + _payloadOffset(item.memPtr);&#13;
        uint endPtr = item.memPtr + item.len;&#13;
        while (currPtr &lt; endPtr) {&#13;
           currPtr = currPtr + _itemLength(currPtr); // skip over an item&#13;
           count++;&#13;
        }&#13;
&#13;
        return count;&#13;
    }&#13;
&#13;
    // @return entire rlp item byte length&#13;
    function _itemLength(uint memPtr) internal pure returns (uint len) {&#13;
        uint byte0;&#13;
        assembly {&#13;
            byte0 := byte(0, mload(memPtr))&#13;
        }&#13;
&#13;
        if (byte0 &lt; STRING_SHORT_START)&#13;
            return 1;&#13;
        &#13;
        else if (byte0 &lt; STRING_LONG_START)&#13;
            return byte0 - STRING_SHORT_START + 1;&#13;
&#13;
        else if (byte0 &lt; LIST_SHORT_START) {&#13;
            assembly {&#13;
                let byteLen := sub(byte0, 0xb7) // # of bytes the actual length is&#13;
                memPtr := add(memPtr, 1) // skip over the first byte&#13;
                &#13;
                /* 32 byte word size */&#13;
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to get the len&#13;
                len := add(dataLen, add(byteLen, 1))&#13;
            }&#13;
        }&#13;
&#13;
        else if (byte0 &lt; LIST_LONG_START) {&#13;
            return byte0 - LIST_SHORT_START + 1;&#13;
        } &#13;
&#13;
        else {&#13;
            assembly {&#13;
                let byteLen := sub(byte0, 0xf7)&#13;
                memPtr := add(memPtr, 1)&#13;
&#13;
                let dataLen := div(mload(memPtr), exp(256, sub(32, byteLen))) // right shifting to the correct length&#13;
                len := add(dataLen, add(byteLen, 1))&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    // @return number of bytes until the data&#13;
    function _payloadOffset(uint memPtr) internal pure returns (uint) {&#13;
        uint byte0;&#13;
        assembly {&#13;
            byte0 := byte(0, mload(memPtr))&#13;
        }&#13;
&#13;
        if (byte0 &lt; STRING_SHORT_START) &#13;
            return 0;&#13;
        else if (byte0 &lt; STRING_LONG_START || (byte0 &gt;= LIST_SHORT_START &amp;&amp; byte0 &lt; LIST_LONG_START))&#13;
            return 1;&#13;
        else if (byte0 &lt; LIST_SHORT_START)  // being explicit&#13;
            return byte0 - (STRING_LONG_START - 1) + 1;&#13;
        else&#13;
            return byte0 - (LIST_LONG_START - 1) + 1;&#13;
    }&#13;
&#13;
    /** RLPItem conversions into data types **/&#13;
&#13;
    // @returns raw rlp encoding in bytes&#13;
    function toRlpBytes(RLPItem memory item) internal pure returns (bytes) {&#13;
        bytes memory result = new bytes(item.len);&#13;
        &#13;
        uint ptr;&#13;
        assembly {&#13;
            ptr := add(0x20, result)&#13;
        }&#13;
&#13;
        copy(item.memPtr, ptr, item.len);&#13;
        return result;&#13;
    }&#13;
&#13;
    function toBoolean(RLPItem memory item) internal pure returns (bool) {&#13;
        require(item.len == 1, "Invalid RLPItem. Booleans are encoded in 1 byte");&#13;
        uint result;&#13;
        uint memPtr = item.memPtr;&#13;
        assembly {&#13;
            result := byte(0, mload(memPtr))&#13;
        }&#13;
&#13;
        return result == 0 ? false : true;&#13;
    }&#13;
&#13;
    function toAddress(RLPItem memory item) internal pure returns (address) {&#13;
        // 1 byte for the length prefix according to RLP spec&#13;
        require(item.len &lt;= 21, "Invalid RLPItem. Addresses are encoded in 20 bytes or less");&#13;
&#13;
        return address(toUint(item));&#13;
    }&#13;
&#13;
    function toUint(RLPItem memory item) internal pure returns (uint) {&#13;
        uint offset = _payloadOffset(item.memPtr);&#13;
        uint len = item.len - offset;&#13;
        uint memPtr = item.memPtr + offset;&#13;
&#13;
        uint result;&#13;
        assembly {&#13;
            result := div(mload(memPtr), exp(256, sub(32, len))) // shift to the correct location&#13;
        }&#13;
&#13;
        return result;&#13;
    }&#13;
&#13;
    function toBytes(RLPItem memory item) internal pure returns (bytes) {&#13;
        uint offset = _payloadOffset(item.memPtr);&#13;
        uint len = item.len - offset; // data length&#13;
        bytes memory result = new bytes(len);&#13;
&#13;
        uint destPtr;&#13;
        assembly {&#13;
            destPtr := add(0x20, result)&#13;
        }&#13;
&#13;
        copy(item.memPtr + offset, destPtr, len);&#13;
        return result;&#13;
    }&#13;
&#13;
&#13;
    /*&#13;
    * @param src Pointer to source&#13;
    * @param dest Pointer to destination&#13;
    * @param len Amount of memory to copy from the source&#13;
    */&#13;
    function copy(uint src, uint dest, uint len) internal pure {&#13;
        // copy as many word sizes as possible&#13;
        for (; len &gt;= WORD_SIZE; len -= WORD_SIZE) {&#13;
            assembly {&#13;
                mstore(dest, mload(src))&#13;
            }&#13;
&#13;
            src += WORD_SIZE;&#13;
            dest += WORD_SIZE;&#13;
        }&#13;
&#13;
        // left over bytes. Mask is used to remove unwanted bytes from the word&#13;
        uint mask = 256 ** (WORD_SIZE - len) - 1;&#13;
        assembly {&#13;
            let srcpart := and(mload(src), not(mask)) // zero out src&#13;
            let destpart := and(mload(dest), mask) // retrieve the bytes&#13;
            mstore(dest, or(destpart, srcpart))&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/BetStorage.sol&#13;
&#13;
/**&#13;
 * @title ClashHash&#13;
 * This product is protected under license.  Any unauthorized copy, modification, or use without&#13;
 * express written consent from the creators is prohibited.&#13;
 */&#13;
&#13;
&#13;
&#13;
&#13;
contract BetStorage is Ownable {&#13;
    using SafeMath for uint256;&#13;
&#13;
    mapping(address =&gt; mapping(address =&gt; uint256)) public bets;&#13;
    mapping(address =&gt; uint256) public betsSumByOption;&#13;
    mapping(address =&gt; uint256) public betsSumByUser;&#13;
    address public wonOption;&#13;
&#13;
    event BetAdded(address indexed user, address indexed option, uint256 value);&#13;
    event Finalized(address indexed option);&#13;
    event RewardClaimed(address indexed user, uint256 reward);&#13;
    &#13;
    function addBet(address user, address option) public payable onlyOwner {&#13;
        require(msg.value &gt; 0, "Empty bet is not allowed");&#13;
        require(betsSumByUser[user] &gt; 0 || bets[user][option] == 0, "Deny different bets for single user");&#13;
&#13;
        bets[user][option] = bets[user][option].add(msg.value);&#13;
        betsSumByOption[option] = betsSumByOption[option].add(msg.value);&#13;
        betsSumByUser[user] = betsSumByUser[user].add(msg.value);&#13;
        emit BetAdded(user, option, msg.value);&#13;
    }&#13;
&#13;
    function finalize(address option, uint256 fee) public onlyOwner {&#13;
        require(wonOption == address(0), "Finalization could be called only once");&#13;
        require(option != address(0), "Won option should not be zero");&#13;
&#13;
        wonOption = option;&#13;
        emit Finalized(option);&#13;
&#13;
        if (betsSumByOption[option] == 0) {&#13;
            selfdestruct(msg.sender);&#13;
        } else {&#13;
            msg.sender.transfer(address(this).balance.mul(fee).div(100));&#13;
        }&#13;
    }&#13;
&#13;
    function claimReward(address user) public onlyOwner returns(uint256 reward) {&#13;
        require(wonOption != address(0), "Round not yet finalized");&#13;
&#13;
        reward = address(this).balance.mul(bets[user][wonOption]).div(betsSumByOption[wonOption]);&#13;
        require(reward &gt; 0, "Reward was claimed previously or never existed");&#13;
        betsSumByOption[wonOption] = betsSumByOption[wonOption].sub(bets[user][wonOption]);&#13;
        bets[user][wonOption] = 0;&#13;
        user.transfer(reward);&#13;
        emit RewardClaimed(user, reward);&#13;
&#13;
        if (betsSumByOption[wonOption] == 0) {&#13;
            selfdestruct(msg.sender);&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/ClashHash.sol&#13;
&#13;
/**&#13;
 * @title ClashHash&#13;
 * This product is protected under license.  Any unauthorized copy, modification, or use without&#13;
 * express written consent from the creators is prohibited.&#13;
 */&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract ClashHash is Ownable {&#13;
    using SafeMath for uint256;&#13;
    using RLPReader for bytes;&#13;
    using RLPReader for RLPReader.RLPItem;&#13;
    &#13;
    struct Round {&#13;
        BetStorage records;&#13;
        uint256 usersCount;&#13;
        uint256 betsCount;&#13;
        uint256 totalReward;&#13;
        address winner;&#13;
    }&#13;
&#13;
    uint256 constant public MIN_BLOCKS_BEFORE_ROUND = 10;&#13;
    uint256 constant public MIN_BLOCKS_AFTER_ROUND = 10;&#13;
    uint256 constant public MAX_BLOCKS_AFTER_ROUND = 256;&#13;
&#13;
    uint256 constant public ADMIN_FEE = 5;&#13;
    uint256 constant public JACKPOT_FEE = 10;&#13;
    uint256 constant public ADMIN_FEE_NOONE_WON = 10;&#13;
    uint256 constant public JACKPOT_FEE_NOONE_WON = 90;&#13;
&#13;
    mapping(uint256 =&gt; Round) public rounds;&#13;
    address private _allowedSender;&#13;
    address private _admin = msg.sender;&#13;
&#13;
    //&#13;
&#13;
    event RoundCreated(uint256 indexed blockNumber, address contractAddress);&#13;
    event RoundBetAdded(uint256 indexed blockNumber, address indexed user, address indexed option, uint256 value);&#13;
    event RoundFinalized(uint256 indexed blockNumber, address indexed option);&#13;
    event RewardClaimed(uint256 indexed blockNumber, address indexed user, uint256 reward);&#13;
&#13;
    //&#13;
&#13;
    function () public payable {&#13;
        require(msg.sender == _allowedSender, "Do not send ETH directly to the contract");&#13;
    }&#13;
&#13;
    function addBet(uint256 blockNumber, address option) public payable {&#13;
        require(block.number &lt;= blockNumber - MIN_BLOCKS_BEFORE_ROUND, "It's too late");&#13;
&#13;
        Round storage round = rounds[blockNumber];&#13;
        if (round.records == address(0)) {&#13;
            round.records = new BetStorage();&#13;
            emit RoundCreated(blockNumber, round.records);&#13;
        }&#13;
&#13;
        if (round.records.betsSumByUser(msg.sender) == 0) {&#13;
            round.usersCount += 1;&#13;
        }&#13;
        round.betsCount += 1;&#13;
        round.totalReward = round.totalReward.add(msg.value);&#13;
        round.records.addBet.value(msg.value)(msg.sender, option);&#13;
&#13;
        emit RoundBetAdded(&#13;
            blockNumber,&#13;
            msg.sender,&#13;
            option,&#13;
            msg.value&#13;
        );&#13;
    }&#13;
&#13;
    function claimRewardWithBlockData(uint256 blockNumber, bytes blockData) public {&#13;
        if (blockData.length &gt; 0 &amp;&amp; rounds[blockNumber].winner == address(0)) {&#13;
            addBlockData(blockNumber, blockData);&#13;
        }&#13;
&#13;
        claimRewardForUser(blockNumber, msg.sender);&#13;
    }&#13;
&#13;
    function claimRewardForUser(uint256 blockNumber, address user) public {&#13;
        Round storage round = rounds[blockNumber];&#13;
        require(round.records.wonOption() != address(0), "Round not yet finished");&#13;
&#13;
        uint256 reward = round.records.claimReward(user);&#13;
        emit RewardClaimed(blockNumber, user, reward);&#13;
    }&#13;
&#13;
    function read(bytes data, uint i) public pure returns(uint) {&#13;
        RLPReader.RLPItem[] memory items = data.toRlpItem().toList();&#13;
        return items[i].toUint();&#13;
    }&#13;
&#13;
    function addBlockData(uint256 blockNumber, bytes blockData) public {&#13;
        require(block.number &lt;= blockNumber + MAX_BLOCKS_AFTER_ROUND, "It's too late, 256 blocks gone");&#13;
        require(block.number &gt;= blockNumber + MIN_BLOCKS_AFTER_ROUND, "Wait at least 10 blocks");&#13;
        require(keccak256(blockData) == blockhash(blockNumber), "Block data isn't valid");&#13;
&#13;
        RLPReader.RLPItem[] memory items = blockData.toRlpItem().toList();&#13;
        address blockBeneficiary = items[2].toAddress();&#13;
&#13;
        Round storage round = rounds[blockNumber];&#13;
        round.winner = blockBeneficiary;&#13;
        emit RoundFinalized(blockNumber, blockBeneficiary);&#13;
        bool noOneWon = (round.records.betsSumByOption(blockBeneficiary) == 0);&#13;
        uint256 roundBalance = address(round.records).balance;&#13;
        &#13;
        _allowedSender = round.records;&#13;
        round.records.finalize(blockBeneficiary, ADMIN_FEE.add(JACKPOT_FEE));&#13;
        delete _allowedSender;&#13;
&#13;
        if (noOneWon) {&#13;
            _admin.transfer(roundBalance.mul(ADMIN_FEE_NOONE_WON).div(100));&#13;
        } else {&#13;
            _admin.transfer(roundBalance.mul(ADMIN_FEE).div(100));&#13;
        }&#13;
    }&#13;
}