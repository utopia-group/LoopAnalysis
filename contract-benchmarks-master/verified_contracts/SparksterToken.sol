pragma solidity 0.4.24;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
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

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


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


/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d1b0a3b0b2b9bfb8b591bfbea5b5bea5ffbfb4a5">[email protected]</a>&gt;&#13;
 *&#13;
 * @dev Functionality in this library is largely implemented using an&#13;
 *      abstraction called a 'slice'. A slice represents a part of a string -&#13;
 *      anything from the entire string to a single character, or even no&#13;
 *      characters at all (a 0-length slice). Since a slice only has to specify&#13;
 *      an offset and a length, copying and manipulating slices is a lot less&#13;
 *      expensive than copying and manipulating the strings they reference.&#13;
 *&#13;
 *      To further reduce gas costs, most functions on slice that need to return&#13;
 *      a slice modify the original one instead of allocating a new one; for&#13;
 *      instance, `s.split(".")` will return the text up to the first '.',&#13;
 *      modifying s to only contain the remainder of the string after the '.'.&#13;
 *      In situations where you do not want to modify the original slice, you&#13;
 *      can make a copy first with `.copy()`, for example:&#13;
 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since&#13;
 *      Solidity has no memory management, it will result in allocating many&#13;
 *      short-lived slices that are later discarded.&#13;
 *&#13;
 *      Functions that return two slices come in two versions: a non-allocating&#13;
 *      version that takes the second slice as an argument, modifying it in&#13;
 *      place, and an allocating version that allocates and returns the second&#13;
 *      slice; see `nextRune` for example.&#13;
 *&#13;
 *      Functions that have to copy string data will return strings rather than&#13;
 *      slices; these can be cast back to slices for further processing if&#13;
 *      required.&#13;
 *&#13;
 *      For convenience, some functions are provided with non-modifying&#13;
 *      variants that create a new slice and return both; for instance,&#13;
 *      `s.splitNew('.')` leaves s unmodified, and returns two values&#13;
 *      corresponding to the left and right parts of the string.&#13;
 */&#13;
&#13;
library strings {&#13;
    struct slice {&#13;
        uint _len;&#13;
        uint _ptr;&#13;
    }&#13;
&#13;
    function memcpy(uint dest, uint src, uint len) private pure {&#13;
        // Copy word-length chunks while possible&#13;
        for(; len &gt;= 32; len -= 32) {&#13;
            assembly {&#13;
                mstore(dest, mload(src))&#13;
            }&#13;
            dest += 32;&#13;
            src += 32;&#13;
        }&#13;
&#13;
        // Copy remaining bytes&#13;
        uint mask = 256 ** (32 - len) - 1;&#13;
        assembly {&#13;
            let srcpart := and(mload(src), not(mask))&#13;
            let destpart := and(mload(dest), mask)&#13;
            mstore(dest, or(destpart, srcpart))&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns a slice containing the entire string.&#13;
     * @param self The string to make a slice from.&#13;
     * @return A newly allocated slice containing the entire string.&#13;
     */&#13;
    function toSlice(string self) internal pure returns (slice) {&#13;
        uint ptr;&#13;
        assembly {&#13;
            ptr := add(self, 0x20)&#13;
        }&#13;
        return slice(bytes(self).length, ptr);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns the length of a null-terminated bytes32 string.&#13;
     * @param self The value to find the length of.&#13;
     * @return The length of the string, from 0 to 32.&#13;
     */&#13;
    function len(bytes32 self) internal pure returns (uint) {&#13;
        uint ret;&#13;
        if (self == 0)&#13;
            return 0;&#13;
        if (self &amp; 0xffffffffffffffffffffffffffffffff == 0) {&#13;
            ret += 16;&#13;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);&#13;
        }&#13;
        if (self &amp; 0xffffffffffffffff == 0) {&#13;
            ret += 8;&#13;
            self = bytes32(uint(self) / 0x10000000000000000);&#13;
        }&#13;
        if (self &amp; 0xffffffff == 0) {&#13;
            ret += 4;&#13;
            self = bytes32(uint(self) / 0x100000000);&#13;
        }&#13;
        if (self &amp; 0xffff == 0) {&#13;
            ret += 2;&#13;
            self = bytes32(uint(self) / 0x10000);&#13;
        }&#13;
        if (self &amp; 0xff == 0) {&#13;
            ret += 1;&#13;
        }&#13;
        return 32 - ret;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns a slice containing the entire bytes32, interpreted as a&#13;
     *      null-terminated utf-8 string.&#13;
     * @param self The bytes32 value to convert to a slice.&#13;
     * @return A new slice containing the value of the input argument up to the&#13;
     *         first null.&#13;
     */&#13;
    function toSliceB32(bytes32 self) internal pure returns (slice ret) {&#13;
        // Allocate space for `self` in memory, copy it there, and point ret at it&#13;
        assembly {&#13;
            let ptr := mload(0x40)&#13;
            mstore(0x40, add(ptr, 0x20))&#13;
            mstore(ptr, self)&#13;
            mstore(add(ret, 0x20), ptr)&#13;
        }&#13;
        ret._len = len(self);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns a new slice containing the same data as the current slice.&#13;
     * @param self The slice to copy.&#13;
     * @return A new slice containing the same data as `self`.&#13;
     */&#13;
    function copy(slice self) internal pure returns (slice) {&#13;
        return slice(self._len, self._ptr);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Copies a slice to a new string.&#13;
     * @param self The slice to copy.&#13;
     * @return A newly allocated string containing the slice's text.&#13;
     */&#13;
    function toString(slice self) internal pure returns (string) {&#13;
        string memory ret = new string(self._len);&#13;
        uint retptr;&#13;
        assembly { retptr := add(ret, 32) }&#13;
&#13;
        memcpy(retptr, self._ptr, self._len);&#13;
        return ret;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns the length in runes of the slice. Note that this operation&#13;
     *      takes time proportional to the length of the slice; avoid using it&#13;
     *      in loops, and call `slice.empty()` if you only need to know whether&#13;
     *      the slice is empty or not.&#13;
     * @param self The slice to operate on.&#13;
     * @return The length of the slice in runes.&#13;
     */&#13;
    function len(slice self) internal pure returns (uint l) {&#13;
        // Starting at ptr-31 means the LSB will be the byte we care about&#13;
        uint ptr = self._ptr - 31;&#13;
        uint end = ptr + self._len;&#13;
        for (l = 0; ptr &lt; end; l++) {&#13;
            uint8 b;&#13;
            assembly { b := and(mload(ptr), 0xFF) }&#13;
            if (b &lt; 0x80) {&#13;
                ptr += 1;&#13;
            } else if(b &lt; 0xE0) {&#13;
                ptr += 2;&#13;
            } else if(b &lt; 0xF0) {&#13;
                ptr += 3;&#13;
            } else if(b &lt; 0xF8) {&#13;
                ptr += 4;&#13;
            } else if(b &lt; 0xFC) {&#13;
                ptr += 5;&#13;
            } else {&#13;
                ptr += 6;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns true if the slice is empty (has a length of 0).&#13;
     * @param self The slice to operate on.&#13;
     * @return True if the slice is empty, False otherwise.&#13;
     */&#13;
    function empty(slice self) internal pure returns (bool) {&#13;
        return self._len == 0;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns a positive number if `other` comes lexicographically after&#13;
     *      `self`, a negative number if it comes before, or zero if the&#13;
     *      contents of the two slices are equal. Comparison is done per-rune,&#13;
     *      on unicode codepoints.&#13;
     * @param self The first slice to compare.&#13;
     * @param other The second slice to compare.&#13;
     * @return The result of the comparison.&#13;
     */&#13;
    function compare(slice self, slice other) internal pure returns (int) {&#13;
        uint shortest = self._len;&#13;
        if (other._len &lt; self._len)&#13;
            shortest = other._len;&#13;
&#13;
        uint selfptr = self._ptr;&#13;
        uint otherptr = other._ptr;&#13;
        for (uint idx = 0; idx &lt; shortest; idx += 32) {&#13;
            uint a;&#13;
            uint b;&#13;
            assembly {&#13;
                a := mload(selfptr)&#13;
                b := mload(otherptr)&#13;
            }&#13;
            if (a != b) {&#13;
                // Mask out irrelevant bytes and check again&#13;
                uint256 mask = uint256(-1); // 0xffff...&#13;
                if(shortest &lt; 32) {&#13;
                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);&#13;
                }&#13;
                uint256 diff = (a &amp; mask) - (b &amp; mask);&#13;
                if (diff != 0)&#13;
                    return int(diff);&#13;
            }&#13;
            selfptr += 32;&#13;
            otherptr += 32;&#13;
        }&#13;
        return int(self._len) - int(other._len);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns true if the two slices contain the same text.&#13;
     * @param self The first slice to compare.&#13;
     * @param self The second slice to compare.&#13;
     * @return True if the slices are equal, false otherwise.&#13;
     */&#13;
    function equals(slice self, slice other) internal pure returns (bool) {&#13;
        return compare(self, other) == 0;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Extracts the first rune in the slice into `rune`, advancing the&#13;
     *      slice to point to the next rune and returning `self`.&#13;
     * @param self The slice to operate on.&#13;
     * @param rune The slice that will contain the first rune.&#13;
     * @return `rune`.&#13;
     */&#13;
    function nextRune(slice self, slice rune) internal pure returns (slice) {&#13;
        rune._ptr = self._ptr;&#13;
&#13;
        if (self._len == 0) {&#13;
            rune._len = 0;&#13;
            return rune;&#13;
        }&#13;
&#13;
        uint l;&#13;
        uint b;&#13;
        // Load the first byte of the rune into the LSBs of b&#13;
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }&#13;
        if (b &lt; 0x80) {&#13;
            l = 1;&#13;
        } else if(b &lt; 0xE0) {&#13;
            l = 2;&#13;
        } else if(b &lt; 0xF0) {&#13;
            l = 3;&#13;
        } else {&#13;
            l = 4;&#13;
        }&#13;
&#13;
        // Check for truncated codepoints&#13;
        if (l &gt; self._len) {&#13;
            rune._len = self._len;&#13;
            self._ptr += self._len;&#13;
            self._len = 0;&#13;
            return rune;&#13;
        }&#13;
&#13;
        self._ptr += l;&#13;
        self._len -= l;&#13;
        rune._len = l;&#13;
        return rune;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns the first rune in the slice, advancing the slice to point&#13;
     *      to the next rune.&#13;
     * @param self The slice to operate on.&#13;
     * @return A slice containing only the first rune from `self`.&#13;
     */&#13;
    function nextRune(slice self) internal pure returns (slice ret) {&#13;
        nextRune(self, ret);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns the number of the first codepoint in the slice.&#13;
     * @param self The slice to operate on.&#13;
     * @return The number of the first codepoint in the slice.&#13;
     */&#13;
    function ord(slice self) internal pure returns (uint ret) {&#13;
        if (self._len == 0) {&#13;
            return 0;&#13;
        }&#13;
&#13;
        uint word;&#13;
        uint length;&#13;
        uint divisor = 2 ** 248;&#13;
&#13;
        // Load the rune into the MSBs of b&#13;
        assembly { word:= mload(mload(add(self, 32))) }&#13;
        uint b = word / divisor;&#13;
        if (b &lt; 0x80) {&#13;
            ret = b;&#13;
            length = 1;&#13;
        } else if(b &lt; 0xE0) {&#13;
            ret = b &amp; 0x1F;&#13;
            length = 2;&#13;
        } else if(b &lt; 0xF0) {&#13;
            ret = b &amp; 0x0F;&#13;
            length = 3;&#13;
        } else {&#13;
            ret = b &amp; 0x07;&#13;
            length = 4;&#13;
        }&#13;
&#13;
        // Check for truncated codepoints&#13;
        if (length &gt; self._len) {&#13;
            return 0;&#13;
        }&#13;
&#13;
        for (uint i = 1; i &lt; length; i++) {&#13;
            divisor = divisor / 256;&#13;
            b = (word / divisor) &amp; 0xFF;&#13;
            if (b &amp; 0xC0 != 0x80) {&#13;
                // Invalid UTF-8 sequence&#13;
                return 0;&#13;
            }&#13;
            ret = (ret * 64) | (b &amp; 0x3F);&#13;
        }&#13;
&#13;
        return ret;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns the keccak-256 hash of the slice.&#13;
     * @param self The slice to hash.&#13;
     * @return The hash of the slice.&#13;
     */&#13;
    function keccak(slice self) internal pure returns (bytes32 ret) {&#13;
        assembly {&#13;
            ret := keccak256(mload(add(self, 32)), mload(self))&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns true if `self` starts with `needle`.&#13;
     * @param self The slice to operate on.&#13;
     * @param needle The slice to search for.&#13;
     * @return True if the slice starts with the provided text, false otherwise.&#13;
     */&#13;
    function startsWith(slice self, slice needle) internal pure returns (bool) {&#13;
        if (self._len &lt; needle._len) {&#13;
            return false;&#13;
        }&#13;
&#13;
        if (self._ptr == needle._ptr) {&#13;
            return true;&#13;
        }&#13;
&#13;
        bool equal;&#13;
        assembly {&#13;
            let length := mload(needle)&#13;
            let selfptr := mload(add(self, 0x20))&#13;
            let needleptr := mload(add(needle, 0x20))&#13;
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))&#13;
        }&#13;
        return equal;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev If `self` starts with `needle`, `needle` is removed from the&#13;
     *      beginning of `self`. Otherwise, `self` is unmodified.&#13;
     * @param self The slice to operate on.&#13;
     * @param needle The slice to search for.&#13;
     * @return `self`&#13;
     */&#13;
    function beyond(slice self, slice needle) internal pure returns (slice) {&#13;
        if (self._len &lt; needle._len) {&#13;
            return self;&#13;
        }&#13;
&#13;
        bool equal = true;&#13;
        if (self._ptr != needle._ptr) {&#13;
            assembly {&#13;
                let length := mload(needle)&#13;
                let selfptr := mload(add(self, 0x20))&#13;
                let needleptr := mload(add(needle, 0x20))&#13;
                equal := eq(sha3(selfptr, length), sha3(needleptr, length))&#13;
            }&#13;
        }&#13;
&#13;
        if (equal) {&#13;
            self._len -= needle._len;&#13;
            self._ptr += needle._len;&#13;
        }&#13;
&#13;
        return self;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns true if the slice ends with `needle`.&#13;
     * @param self The slice to operate on.&#13;
     * @param needle The slice to search for.&#13;
     * @return True if the slice starts with the provided text, false otherwise.&#13;
     */&#13;
    function endsWith(slice self, slice needle) internal pure returns (bool) {&#13;
        if (self._len &lt; needle._len) {&#13;
            return false;&#13;
        }&#13;
&#13;
        uint selfptr = self._ptr + self._len - needle._len;&#13;
&#13;
        if (selfptr == needle._ptr) {&#13;
            return true;&#13;
        }&#13;
&#13;
        bool equal;&#13;
        assembly {&#13;
            let length := mload(needle)&#13;
            let needleptr := mload(add(needle, 0x20))&#13;
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))&#13;
        }&#13;
&#13;
        return equal;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev If `self` ends with `needle`, `needle` is removed from the&#13;
     *      end of `self`. Otherwise, `self` is unmodified.&#13;
     * @param self The slice to operate on.&#13;
     * @param needle The slice to search for.&#13;
     * @return `self`&#13;
     */&#13;
    function until(slice self, slice needle) internal pure returns (slice) {&#13;
        if (self._len &lt; needle._len) {&#13;
            return self;&#13;
        }&#13;
&#13;
        uint selfptr = self._ptr + self._len - needle._len;&#13;
        bool equal = true;&#13;
        if (selfptr != needle._ptr) {&#13;
            assembly {&#13;
                let length := mload(needle)&#13;
                let needleptr := mload(add(needle, 0x20))&#13;
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))&#13;
            }&#13;
        }&#13;
&#13;
        if (equal) {&#13;
            self._len -= needle._len;&#13;
        }&#13;
&#13;
        return self;&#13;
    }&#13;
&#13;
    event log_bytemask(bytes32 mask);&#13;
&#13;
    // Returns the memory address of the first byte of the first occurrence of&#13;
    // `needle` in `self`, or the first byte after `self` if not found.&#13;
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {&#13;
        uint ptr = selfptr;&#13;
        uint idx;&#13;
&#13;
        if (needlelen &lt;= selflen) {&#13;
            if (needlelen &lt;= 32) {&#13;
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));&#13;
&#13;
                bytes32 needledata;&#13;
                assembly { needledata := and(mload(needleptr), mask) }&#13;
&#13;
                uint end = selfptr + selflen - needlelen;&#13;
                bytes32 ptrdata;&#13;
                assembly { ptrdata := and(mload(ptr), mask) }&#13;
&#13;
                while (ptrdata != needledata) {&#13;
                    if (ptr &gt;= end)&#13;
                        return selfptr + selflen;&#13;
                    ptr++;&#13;
                    assembly { ptrdata := and(mload(ptr), mask) }&#13;
                }&#13;
                return ptr;&#13;
            } else {&#13;
                // For long needles, use hashing&#13;
                bytes32 hash;&#13;
                assembly { hash := sha3(needleptr, needlelen) }&#13;
&#13;
                for (idx = 0; idx &lt;= selflen - needlelen; idx++) {&#13;
                    bytes32 testHash;&#13;
                    assembly { testHash := sha3(ptr, needlelen) }&#13;
                    if (hash == testHash)&#13;
                        return ptr;&#13;
                    ptr += 1;&#13;
                }&#13;
            }&#13;
        }&#13;
        return selfptr + selflen;&#13;
    }&#13;
&#13;
    // Returns the memory address of the first byte after the last occurrence of&#13;
    // `needle` in `self`, or the address of `self` if not found.&#13;
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {&#13;
        uint ptr;&#13;
&#13;
        if (needlelen &lt;= selflen) {&#13;
            if (needlelen &lt;= 32) {&#13;
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));&#13;
&#13;
                bytes32 needledata;&#13;
                assembly { needledata := and(mload(needleptr), mask) }&#13;
&#13;
                ptr = selfptr + selflen - needlelen;&#13;
                bytes32 ptrdata;&#13;
                assembly { ptrdata := and(mload(ptr), mask) }&#13;
&#13;
                while (ptrdata != needledata) {&#13;
                    if (ptr &lt;= selfptr)&#13;
                        return selfptr;&#13;
                    ptr--;&#13;
                    assembly { ptrdata := and(mload(ptr), mask) }&#13;
                }&#13;
                return ptr + needlelen;&#13;
            } else {&#13;
                // For long needles, use hashing&#13;
                bytes32 hash;&#13;
                assembly { hash := sha3(needleptr, needlelen) }&#13;
                ptr = selfptr + (selflen - needlelen);&#13;
                while (ptr &gt;= selfptr) {&#13;
                    bytes32 testHash;&#13;
                    assembly { testHash := sha3(ptr, needlelen) }&#13;
                    if (hash == testHash)&#13;
                        return ptr + needlelen;&#13;
                    ptr -= 1;&#13;
                }&#13;
            }&#13;
        }&#13;
        return selfptr;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Modifies `self` to contain everything from the first occurrence of&#13;
     *      `needle` to the end of the slice. `self` is set to the empty slice&#13;
     *      if `needle` is not found.&#13;
     * @param self The slice to search and modify.&#13;
     * @param needle The text to search for.&#13;
     * @return `self`.&#13;
     */&#13;
    function find(slice self, slice needle) internal pure returns (slice) {&#13;
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);&#13;
        self._len -= ptr - self._ptr;&#13;
        self._ptr = ptr;&#13;
        return self;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Modifies `self` to contain the part of the string from the start of&#13;
     *      `self` to the end of the first occurrence of `needle`. If `needle`&#13;
     *      is not found, `self` is set to the empty slice.&#13;
     * @param self The slice to search and modify.&#13;
     * @param needle The text to search for.&#13;
     * @return `self`.&#13;
     */&#13;
    function rfind(slice self, slice needle) internal pure returns (slice) {&#13;
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);&#13;
        self._len = ptr - self._ptr;&#13;
        return self;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Splits the slice, setting `self` to everything after the first&#13;
     *      occurrence of `needle`, and `token` to everything before it. If&#13;
     *      `needle` does not occur in `self`, `self` is set to the empty slice,&#13;
     *      and `token` is set to the entirety of `self`.&#13;
     * @param self The slice to split.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @param token An output parameter to which the first token is written.&#13;
     * @return `token`.&#13;
     */&#13;
    function split(slice self, slice needle, slice token) internal pure returns (slice) {&#13;
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);&#13;
        token._ptr = self._ptr;&#13;
        token._len = ptr - self._ptr;&#13;
        if (ptr == self._ptr + self._len) {&#13;
            // Not found&#13;
            self._len = 0;&#13;
        } else {&#13;
            self._len -= token._len + needle._len;&#13;
            self._ptr = ptr + needle._len;&#13;
        }&#13;
        return token;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Splits the slice, setting `self` to everything after the first&#13;
     *      occurrence of `needle`, and returning everything before it. If&#13;
     *      `needle` does not occur in `self`, `self` is set to the empty slice,&#13;
     *      and the entirety of `self` is returned.&#13;
     * @param self The slice to split.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @return The part of `self` up to the first occurrence of `delim`.&#13;
     */&#13;
    function split(slice self, slice needle) internal pure returns (slice token) {&#13;
        split(self, needle, token);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Splits the slice, setting `self` to everything before the last&#13;
     *      occurrence of `needle`, and `token` to everything after it. If&#13;
     *      `needle` does not occur in `self`, `self` is set to the empty slice,&#13;
     *      and `token` is set to the entirety of `self`.&#13;
     * @param self The slice to split.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @param token An output parameter to which the first token is written.&#13;
     * @return `token`.&#13;
     */&#13;
    function rsplit(slice self, slice needle, slice token) internal pure returns (slice) {&#13;
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);&#13;
        token._ptr = ptr;&#13;
        token._len = self._len - (ptr - self._ptr);&#13;
        if (ptr == self._ptr) {&#13;
            // Not found&#13;
            self._len = 0;&#13;
        } else {&#13;
            self._len -= token._len + needle._len;&#13;
        }&#13;
        return token;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Splits the slice, setting `self` to everything before the last&#13;
     *      occurrence of `needle`, and returning everything after it. If&#13;
     *      `needle` does not occur in `self`, `self` is set to the empty slice,&#13;
     *      and the entirety of `self` is returned.&#13;
     * @param self The slice to split.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @return The part of `self` after the last occurrence of `delim`.&#13;
     */&#13;
    function rsplit(slice self, slice needle) internal pure returns (slice token) {&#13;
        rsplit(self, needle, token);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.&#13;
     * @param self The slice to search.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @return The number of occurrences of `needle` found in `self`.&#13;
     */&#13;
    function count(slice self, slice needle) internal pure returns (uint cnt) {&#13;
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;&#13;
        while (ptr &lt;= self._ptr + self._len) {&#13;
            cnt++;&#13;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns True if `self` contains `needle`.&#13;
     * @param self The slice to search.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @return True if `needle` is found in `self`, false otherwise.&#13;
     */&#13;
    function contains(slice self, slice needle) internal pure returns (bool) {&#13;
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns a newly allocated string containing the concatenation of&#13;
     *      `self` and `other`.&#13;
     * @param self The first slice to concatenate.&#13;
     * @param other The second slice to concatenate.&#13;
     * @return The concatenation of the two strings.&#13;
     */&#13;
    function concat(slice self, slice other) internal pure returns (string) {&#13;
        string memory ret = new string(self._len + other._len);&#13;
        uint retptr;&#13;
        assembly { retptr := add(ret, 32) }&#13;
        memcpy(retptr, self._ptr, self._len);&#13;
        memcpy(retptr + self._len, other._ptr, other._len);&#13;
        return ret;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Joins an array of slices, using `self` as a delimiter, returning a&#13;
     *      newly allocated string.&#13;
     * @param self The delimiter to use.&#13;
     * @param parts A list of slices to join.&#13;
     * @return A newly allocated string containing all the slices in `parts`,&#13;
     *         joined with `self`.&#13;
     */&#13;
    function join(slice self, slice[] parts) internal pure returns (string) {&#13;
        if (parts.length == 0)&#13;
            return "";&#13;
&#13;
        uint length = self._len * (parts.length - 1);&#13;
        for(uint i = 0; i &lt; parts.length; i++)&#13;
            length += parts[i]._len;&#13;
&#13;
        string memory ret = new string(length);&#13;
        uint retptr;&#13;
        assembly { retptr := add(ret, 32) }&#13;
&#13;
        for(i = 0; i &lt; parts.length; i++) {&#13;
            memcpy(retptr, parts[i]._ptr, parts[i]._len);&#13;
            retptr += parts[i]._len;&#13;
            if (i &lt; parts.length - 1) {&#13;
                memcpy(retptr, self._ptr, self._len);&#13;
                retptr += self._len;&#13;
            }&#13;
        }&#13;
&#13;
        return ret;&#13;
    }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, throws on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the&#13;
    // benefit is lost if 'b' is also tested.&#13;
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    // uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return a / b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
&#13;
pragma solidity 0.4.24;&#13;
&#13;
contract SparksterToken is StandardToken, Ownable{&#13;
	using strings for *;&#13;
	using SafeMath for uint256;&#13;
	struct Member {&#13;
		address walletAddress;&#13;
		mapping(uint256 =&gt; bool) groupMemberships; // What groups does this member belong to?&#13;
		mapping(uint256 =&gt; uint256) ethBalance; // How much eth has this member contributed for this group?&#13;
		mapping(uint256 =&gt; uint256) tokenBalance; // The member's token balance in a specific group.&#13;
		uint256 max1; // Maximum amount this user can contribute for phase1.&#13;
		int256 transferred; // The amount of tokens the member has transferred out or been transferred in. Sending tokens out will increase this value and accepting tokens in will decrease it. In other words, the more negative this value is, the more unlocked tokens the member holds.&#13;
		bool exists; // A flag to see if we have a record of this member or not. If we don't, they won't be allowed to purchase.&#13;
	}&#13;
&#13;
	struct Group {&#13;
		bool distributed; // Whether or not tokens in this group have been distributed.&#13;
		bool distributing; // This flag is set when we first enter the distribute function and is there to prevent race conditions, since distribution might take a long time.&#13;
		bool unlocked; // Whether or not tokens in this group have been unlocked.&#13;
		uint256 groupNumber; // This group's number&#13;
		uint256 ratio; // 1 eth:ratio tokens. This amount represents the decimal amount. ratio*10**decimal = ratio sparks.&#13;
		uint256 startTime; // Epoch of crowdsale start time.&#13;
		uint256 phase1endTime; // Epoch of phase1 end time.&#13;
		uint256 phase2endTime; // Epoch of phase2 end time.&#13;
		uint256 deadline; // No contributions allowed after this epoch.&#13;
		uint256 max2; // cap of phase2&#13;
		uint256 max3; // Total ether this group can collect in phase 3.&#13;
		uint256 ethTotal; // How much ether has this group collected?&#13;
		uint256 cap; // The hard ether cap.&#13;
		uint256 howManyDistributed;&#13;
	}&#13;
&#13;
	bool internal transferLock = true; // A Global transfer lock. Set to lock down all tokens from all groups.&#13;
	bool internal allowedToSell = false;&#13;
	bool internal allowedToPurchase = false;&#13;
	string public name;									 // name for display&#13;
	string public symbol;								 //An identifier&#13;
	uint8 public decimals;							//How many decimals to show.&#13;
	uint256 internal maxGasPrice; // The maximum allowed gas for the purchase function.&#13;
	uint256 internal nextGroupNumber;&#13;
	uint256 public sellPrice; // sellPrice wei:1 spark token; we won't allow to sell back parts of a token.&#13;
	address[] internal allMembers;	&#13;
	address[] internal allNonMembers;&#13;
	mapping(address =&gt; bool) internal nonMemberTransfers;&#13;
	mapping(address =&gt; Member) internal members;&#13;
	mapping(uint256 =&gt; Group) internal groups;&#13;
	mapping(uint256 =&gt; address[]) internal associations; // Will hold a record of which addresses belong to which group.&#13;
	uint256 internal openGroupNumber;&#13;
	event PurchaseSuccess(address indexed _addr, uint256 _weiAmount,uint256 _totalEthBalance,uint256 _totalTokenBalance);&#13;
	event DistributeDone(uint256 groupNumber);&#13;
	event UnlockDone(uint256 groupNumber);&#13;
	event GroupCreated(uint256 groupNumber, uint256 startTime, uint256 phase1endTime, uint256 phase2endTime, uint256 deadline, uint256 phase2cap, uint256 phase3cap, uint256 cap, uint256 ratio);&#13;
	event ChangedAllowedToSell(bool allowedToSell);&#13;
	event ChangedAllowedToPurchase(bool allowedToPurchase);&#13;
	event ChangedTransferLock(bool transferLock);&#13;
	event SetSellPrice(uint256 sellPrice);&#13;
	event Added(address walletAddress, uint256 group, uint256 tokens, uint256 maxContribution1);&#13;
	event SplitTokens(uint256 splitFactor);&#13;
	event ReverseSplitTokens(uint256 splitFactor);&#13;
	&#13;
	// Fix for the ERC20 short address attack http://vessenes.com/the-erc20-short-address-attack-explained/&#13;
	modifier onlyPayloadSize(uint size) {	 &#13;
		require(msg.data.length == size + 4);&#13;
		_;&#13;
	}&#13;
&#13;
	modifier canTransfer() {&#13;
		require(!transferLock);&#13;
		_;&#13;
	}&#13;
&#13;
	modifier canPurchase() {&#13;
		require(allowedToPurchase);&#13;
		_;&#13;
	}&#13;
&#13;
	modifier canSell() {&#13;
		require(allowedToSell);&#13;
		_;&#13;
	}&#13;
&#13;
	function() public payable {&#13;
		purchase();&#13;
	}&#13;
&#13;
	constructor() public {&#13;
		name = "Sparkster";									// Set the name for display purposes&#13;
		decimals = 18;					 // Amount of decimals for display purposes&#13;
		symbol = "SPRK";							// Set the symbol for display purposes&#13;
		setMaximumGasPrice(40);&#13;
		// Give all the tokens to the owner to start with.&#13;
		mintTokens(435000000);&#13;
	}&#13;
	&#13;
	function setMaximumGasPrice(uint256 gweiPrice) public onlyOwner returns(bool success) {&#13;
		maxGasPrice = gweiPrice.mul(10**9); // Convert the gwei value to wei.&#13;
		return true;&#13;
	}&#13;
	&#13;
	function parseAddr(string _a) pure internal returns (address){ // From Oraclize&#13;
		bytes memory tmp = bytes(_a);&#13;
		uint160 iaddr = 0;&#13;
		uint160 b1;&#13;
		uint160 b2;&#13;
		for (uint i=2; i&lt;2+2*20; i+=2){&#13;
			iaddr *= 256;&#13;
			b1 = uint160(tmp[i]);&#13;
			b2 = uint160(tmp[i+1]);&#13;
			if ((b1 &gt;= 97)&amp;&amp;(b1 &lt;= 102)) b1 -= 87;&#13;
			else if ((b1 &gt;= 48)&amp;&amp;(b1 &lt;= 57)) b1 -= 48;&#13;
			if ((b2 &gt;= 97)&amp;&amp;(b2 &lt;= 102)) b2 -= 87;&#13;
			else if ((b2 &gt;= 48)&amp;&amp;(b2 &lt;= 57)) b2 -= 48;&#13;
			iaddr += (b1*16+b2);&#13;
		}&#13;
		return address(iaddr);&#13;
	}&#13;
&#13;
	function parseInt(string _a, uint _b) pure internal returns (uint) {&#13;
		bytes memory bresult = bytes(_a);&#13;
		uint mint = 0;&#13;
		bool decim = false;&#13;
		for (uint i = 0; i &lt; bresult.length; i++) {&#13;
			if ((bresult[i] &gt;= 48) &amp;&amp; (bresult[i] &lt;= 57)) {&#13;
				if (decim) {&#13;
					if (_b == 0) break;&#13;
						else _b--;&#13;
				}&#13;
				mint *= 10;&#13;
				mint += uint(bresult[i]) - 48;&#13;
			} else if (bresult[i] == 46) decim = true;&#13;
		}&#13;
		return mint;&#13;
	}&#13;
&#13;
	function mintTokens(uint256 amount) public onlyOwner {&#13;
		// Here, we'll consider amount to be the full token amount, so we have to get its decimal value.&#13;
		uint256 decimalAmount = amount.mul(uint(10)**decimals);&#13;
		totalSupply_ = totalSupply_.add(decimalAmount);&#13;
		balances[msg.sender] = balances[msg.sender].add(decimalAmount);&#13;
		emit Transfer(address(0), msg.sender, decimalAmount); // Per erc20 standards-compliance.&#13;
	}&#13;
	&#13;
	function purchase() public canPurchase payable{&#13;
		require(msg.sender != address(0)); // Don't allow the 0 address.&#13;
		Member storage memberRecord = members[msg.sender];&#13;
		Group storage openGroup = groups[openGroupNumber];&#13;
		require(openGroup.ratio &gt; 0); // Group must be initialized.&#13;
		require(memberRecord.exists &amp;&amp; memberRecord.groupMemberships[openGroup.groupNumber] &amp;&amp; !openGroup.distributing &amp;&amp; !openGroup.distributed &amp;&amp; !openGroup.unlocked); // member must exist; Don't allow to purchase if we're in the middle of distributing this group; Don't let someone buy tokens on the current group if that group is already distributed, unlocked or both; don't allow member to purchase if they're not part of the open group.&#13;
		uint256 currentTimestamp = block.timestamp;&#13;
		require(currentTimestamp &gt;= openGroup.startTime &amp;&amp; currentTimestamp &lt;= openGroup.deadline);																 //the timestamp must be greater than or equal to the start time and less than or equal to the deadline time&#13;
		require(tx.gasprice &lt;= maxGasPrice); // Restrict maximum gas this transaction is allowed to consume.&#13;
		uint256 weiAmount = msg.value;																		// The amount purchased by the current member&#13;
		require(weiAmount &gt;= 0.1 ether);&#13;
		uint256 ethTotal = openGroup.ethTotal.add(weiAmount); // Calculate total contribution of all members in this group.&#13;
		require(ethTotal &lt;= openGroup.cap);														// Check to see if accepting these funds will put us above the hard ether cap.&#13;
		uint256 userETHTotal = memberRecord.ethBalance[openGroup.groupNumber].add(weiAmount);	// Calculate the total amount purchased by the current member&#13;
		if(currentTimestamp &lt;= openGroup.phase1endTime){																			 // whether the current timestamp is in the first phase&#13;
			require(userETHTotal &lt;= memberRecord.max1);														 // Will these new funds put the member over their first phase contribution limit?&#13;
		} else if (currentTimestamp &lt;= openGroup.phase2endTime) { // Are we in phase 2?&#13;
			require(userETHTotal &lt;= openGroup.max2); // Allow to contribute no more than max2 in phase 2.&#13;
		} else { // We've passed both phases 1 and 2.&#13;
			require(userETHTotal &lt;= openGroup.max3); // Don't allow to contribute more than max3 in phase 3.&#13;
		}&#13;
		uint256 tokenAmount = weiAmount.mul(openGroup.ratio);						 //calculate member token amount.&#13;
		uint256 newLeftOver = balances[owner].sub(tokenAmount); // Won't pass if result is &lt; 0.&#13;
		openGroup.ethTotal = ethTotal;								 // Calculate the total amount purchased by all members in this group.&#13;
		memberRecord.ethBalance[openGroup.groupNumber] = userETHTotal;														 // Record the total amount purchased by the current member&#13;
		memberRecord.tokenBalance[openGroup.groupNumber] = memberRecord.tokenBalance[openGroup.groupNumber].add(tokenAmount); // Update the member's token amount.&#13;
		balances[owner] = newLeftOver; // Update the available number of tokens.&#13;
		owner.transfer(weiAmount); // Transfer to owner, don't keep funds in the contract.&#13;
		emit PurchaseSuccess(msg.sender,weiAmount,memberRecord.ethBalance[openGroup.groupNumber],memberRecord.tokenBalance[openGroup.groupNumber]); &#13;
	}&#13;
	&#13;
	function sell(uint256 amount) public canSell { // Can't sell unless owner has allowed it.&#13;
		uint256 decimalAmount = amount.mul(uint(10)**decimals); // convert the full token value to the smallest unit possible.&#13;
		if (members[msg.sender].exists) { // If this seller exists, they have an unlocked balance we need to take care of.&#13;
			int256 sellValue = members[msg.sender].transferred + int(decimalAmount);&#13;
			require(sellValue &gt;= members[msg.sender].transferred); // Check for overflow.&#13;
			require(sellValue &lt;= int(getUnlockedBalanceLimit(msg.sender))); // Make sure they're not selling more than their unlocked amount.&#13;
			members[msg.sender].transferred = sellValue;&#13;
		}&#13;
		balances[msg.sender] = balances[msg.sender].sub(decimalAmount); // Do this before transferring to avoid re-entrance attacks; will throw if result &lt; 0.&#13;
		// Amount is considered to be how many full tokens the user wants to sell.&#13;
		uint256 totalCost = amount.mul(sellPrice); // sellPrice is the per-full-token value.&#13;
		require(address(this).balance &gt;= totalCost); // The contract must have enough funds to cover the selling.&#13;
		balances[owner] = balances[owner].add(decimalAmount); // Put these tokens back into the available pile.&#13;
		msg.sender.transfer(totalCost); // Pay the seller for their tokens.&#13;
		emit Transfer(msg.sender, owner, decimalAmount); // Notify exchanges of the sell.&#13;
	}&#13;
&#13;
	function fundContract() public onlyOwner payable { // For the owner to put funds into the contract.&#13;
	}&#13;
&#13;
	function setSellPrice(uint256 thePrice) public onlyOwner {&#13;
		sellPrice = thePrice;&#13;
		emit SetSellPrice(sellPrice);&#13;
	}&#13;
	&#13;
	function setAllowedToSell(bool value) public onlyOwner {&#13;
		allowedToSell = value;&#13;
		emit ChangedAllowedToSell(allowedToSell);&#13;
	}&#13;
&#13;
	function setAllowedToPurchase(bool value) public onlyOwner {&#13;
		allowedToPurchase = value;&#13;
		emit ChangedAllowedToPurchase(allowedToPurchase);&#13;
	}&#13;
	&#13;
	function createGroup(uint256 startEpoch, uint256 phase1endEpoch, uint256 phase2endEpoch, uint256 deadlineEpoch, uint256 phase2cap, uint256 phase3cap, uint256 etherCap, uint256 ratio) public onlyOwner returns (bool success, uint256 createdGroupNumber) {&#13;
		Group storage theGroup = groups[nextGroupNumber];&#13;
		theGroup.groupNumber = nextGroupNumber;&#13;
		theGroup.startTime = startEpoch;&#13;
		theGroup.phase1endTime = phase1endEpoch;&#13;
		theGroup.phase2endTime = phase2endEpoch;&#13;
		theGroup.deadline = deadlineEpoch;&#13;
		theGroup.max2 = phase2cap;&#13;
		theGroup.max3 = phase3cap;&#13;
		theGroup.cap = etherCap;&#13;
		theGroup.ratio = ratio;&#13;
		createdGroupNumber = nextGroupNumber;&#13;
		nextGroupNumber++;&#13;
		success = true;&#13;
		emit GroupCreated(createdGroupNumber, startEpoch, phase1endEpoch, phase2endEpoch, deadlineEpoch, phase2cap, phase3cap, etherCap, ratio);&#13;
	}&#13;
&#13;
	function createGroup() public onlyOwner returns (bool success, uint256 createdGroupNumber) {&#13;
		return createGroup(0, 0, 0, 0, 0, 0, 0, 0);&#13;
	}&#13;
&#13;
	function getGroup(uint256 groupNumber) public view onlyOwner returns(bool distributed, bool unlocked, uint256 phase2cap, uint256 phase3cap, uint256 cap, uint256 ratio, uint256 startTime, uint256 phase1endTime, uint256 phase2endTime, uint256 deadline, uint256 ethTotal, uint256 howManyDistributed) {&#13;
		require(groupNumber &lt; nextGroupNumber);&#13;
		Group storage theGroup = groups[groupNumber];&#13;
		distributed = theGroup.distributed;&#13;
		unlocked = theGroup.unlocked;&#13;
		phase2cap = theGroup.max2;&#13;
		phase3cap = theGroup.max3;&#13;
		cap = theGroup.cap;&#13;
		ratio = theGroup.ratio;&#13;
		startTime = theGroup.startTime;&#13;
		phase1endTime = theGroup.phase1endTime;&#13;
		phase2endTime = theGroup.phase2endTime;&#13;
		deadline = theGroup.deadline;&#13;
		ethTotal = theGroup.ethTotal;&#13;
		howManyDistributed = theGroup.howManyDistributed;&#13;
	}&#13;
&#13;
	function getHowManyLeftToDistribute(uint256 groupNumber) public view returns(uint256 howManyLeftToDistribute) {&#13;
		require(groupNumber &lt; nextGroupNumber);&#13;
		Group storage theGroup = groups[groupNumber];&#13;
		howManyLeftToDistribute = associations[groupNumber].length - theGroup.howManyDistributed; // No need to use SafeMath here since we're guaranteed to not underflow on this line.&#13;
	}&#13;
	&#13;
	function getMembersInGroup(uint256 groupNumber) public view returns (address[]) {&#13;
		require(groupNumber &lt; nextGroupNumber); // Check for nonexistent group&#13;
		return associations[groupNumber];&#13;
	}&#13;
&#13;
	function addMember(address walletAddress, uint256 groupNumber, uint256 tokens, uint256 maxContribution1) public onlyOwner returns (bool success) {&#13;
		Member storage theMember = members[walletAddress];&#13;
		Group storage theGroup = groups[groupNumber];&#13;
		require(groupNumber &lt; nextGroupNumber); // Don't let the owner assign to a group that doesn't exist, protect against mistypes.&#13;
		require(!theGroup.distributed &amp;&amp; !theGroup.distributing &amp;&amp; !theGroup.unlocked); // Don't let us add to a distributed group, a group that's distributing right now, or a group that's already been unlocked.&#13;
		require(!theMember.exists); // Don't let the owner re-add a member.&#13;
		theMember.walletAddress = walletAddress;&#13;
		theMember.groupMemberships[groupNumber] = true;&#13;
		balances[owner] = balances[owner].sub(tokens);&#13;
		theMember.tokenBalance[groupNumber] = tokens;&#13;
		theMember.max1 = maxContribution1;&#13;
		theMember.transferred = -int(balances[walletAddress]); // Don't lock the tokens they come in with if they already hold a balance.&#13;
		theMember.exists = true;&#13;
		associations[groupNumber].push(walletAddress); // Push this user's address to the associations array so we can easily keep track of which users belong to which group...&#13;
		// ... Solidity doesn't allow to iterate over a map.&#13;
		allMembers.push(walletAddress); // Push this address to allMembers array so we can easily loop through all addresses...&#13;
		// Used for splitTokens and reverseSplitTokens.&#13;
		emit Added(walletAddress, groupNumber, tokens, maxContribution1);&#13;
		return true;&#13;
	}&#13;
&#13;
	function addMemberToGroup(address walletAddress, uint256 groupNumber) public onlyOwner returns(bool success) {&#13;
		Member storage memberRecord = members[walletAddress];&#13;
		require(memberRecord.exists &amp;&amp; groupNumber &lt; nextGroupNumber &amp;&amp; !memberRecord.groupMemberships[groupNumber]); // Don't add this user to a group if they already exist in that group.&#13;
		memberRecord.groupMemberships[groupNumber] = true;&#13;
		associations[groupNumber].push(walletAddress);&#13;
		return true;&#13;
	}&#13;
	function upload(string uploadedData) public onlyOwner returns (bool success) {&#13;
		// We'll separate records by a | and individual entries in the record by a :.&#13;
		strings.slice memory uploadedSlice = uploadedData.toSlice();&#13;
		strings.slice memory nextRecord = "".toSlice();&#13;
		strings.slice memory nextDatum = "".toSlice();&#13;
		strings.slice memory recordSeparator = "|".toSlice();&#13;
		strings.slice memory datumSeparator = ":".toSlice();&#13;
		while (!uploadedSlice.empty()) {&#13;
			nextRecord = uploadedSlice.split(recordSeparator);&#13;
			nextDatum = nextRecord.split(datumSeparator);&#13;
			address memberAddress = parseAddr(nextDatum.toString());&#13;
			nextDatum = nextRecord.split(datumSeparator);&#13;
			uint256 memberGroup = parseInt(nextDatum.toString(), 0);&#13;
			nextDatum = nextRecord.split(datumSeparator);&#13;
			uint256 memberTokens = parseInt(nextDatum.toString(), 0);&#13;
			nextDatum = nextRecord.split(datumSeparator);&#13;
			uint256 memberMaxContribution1 = parseInt(nextDatum.toString(), 0);&#13;
			addMember(memberAddress, memberGroup, memberTokens, memberMaxContribution1);&#13;
		}&#13;
		return true;&#13;
	}&#13;
	&#13;
	function distribute(uint256 groupNumber, uint256 howMany) public onlyOwner returns (bool success) {&#13;
		Group storage theGroup = groups[groupNumber];&#13;
		require(groupNumber &lt; nextGroupNumber &amp;&amp; !theGroup.distributed ); // can't have already distributed&#13;
		uint256 inclusiveStartIndex = theGroup.howManyDistributed;&#13;
		uint256 exclusiveEndIndex = inclusiveStartIndex.add(howMany);&#13;
		theGroup.distributing = true;&#13;
		uint256 n = associations[groupNumber].length;&#13;
		require(n &gt; 0 ); // We must have more than 0 members in this group&#13;
		if (exclusiveEndIndex &gt; n) { // This batch will overrun the array.&#13;
			exclusiveEndIndex = n;&#13;
		}&#13;
		for (uint256 i = inclusiveStartIndex; i &lt; exclusiveEndIndex; i++) { // This section might be expensive in terms of gas cost!&#13;
			address memberAddress = associations[groupNumber][i];&#13;
			Member storage currentMember = members[memberAddress];&#13;
			uint256 balance = currentMember.tokenBalance[groupNumber];&#13;
			if (balance &gt; 0) { // No need to waste ticks if they have no tokens to distribute&#13;
				balances[memberAddress] = balances[memberAddress].add(balance);&#13;
				emit Transfer(owner, memberAddress, balance); // Notify exchanges of the distribution.&#13;
			}&#13;
			theGroup.howManyDistributed++;&#13;
		}&#13;
		if (theGroup.howManyDistributed == n) { // Done distributing all members.&#13;
			theGroup.distributed = true;&#13;
			theGroup.distributing = false;&#13;
			emit DistributeDone(groupNumber);&#13;
		}&#13;
		return true;&#13;
	}&#13;
&#13;
	function getUnlockedBalanceLimit(address walletAddress) internal view returns(uint256 balance) {&#13;
		Member storage theMember = members[walletAddress];&#13;
		if (!theMember.exists) {&#13;
			return balances[walletAddress];&#13;
		}&#13;
		for (uint256 i = 0; i &lt; nextGroupNumber; i++) {&#13;
			if (groups[i].unlocked) {&#13;
				balance = balance.add(theMember.tokenBalance[i]);&#13;
			}&#13;
		}&#13;
		return balance;&#13;
	}&#13;
&#13;
	function getUnlockedTokens(address walletAddress) public view returns(uint256 balance) {&#13;
		Member storage theMember = members[walletAddress];&#13;
		if (!theMember.exists) {&#13;
			return balances[walletAddress];&#13;
		}&#13;
		return uint256(int(getUnlockedBalanceLimit(walletAddress)) - theMember.transferred);&#13;
	}&#13;
&#13;
	function unlock(uint256 groupNumber) public onlyOwner returns (bool success) {&#13;
		Group storage theGroup = groups[groupNumber];&#13;
		require(theGroup.distributed &amp;&amp; !theGroup.unlocked); // Distribution must have occurred first.&#13;
		theGroup.unlocked = true;&#13;
		emit UnlockDone(groupNumber);&#13;
		return true;&#13;
	}&#13;
	&#13;
	function setTransferLock(bool value) public onlyOwner {&#13;
		transferLock = value;&#13;
		emit ChangedTransferLock(transferLock);&#13;
	}&#13;
	&#13;
	function burn(uint256 amount) public onlyOwner {&#13;
		// Burns tokens from the owner's supply and doesn't touch allocated tokens.&#13;
		// Decrease totalSupply and leftOver by the amount to burn so we can decrease the circulation.&#13;
		balances[msg.sender] = balances[msg.sender].sub(amount); // Will throw if result &lt; 0&#13;
		totalSupply_ = totalSupply_.sub(amount); // Will throw if result &lt; 0&#13;
		emit Transfer(msg.sender, address(0), amount);&#13;
	}&#13;
	&#13;
	function splitTokensBeforeDistribution(uint256 splitFactor) public onlyOwner returns (bool success) {&#13;
		// SplitFactor is the multiplier per decimal of spark. splitFactor * 10**decimals = splitFactor sparks&#13;
		uint256 n = allMembers.length;&#13;
		uint256 ownerBalance = balances[msg.sender];&#13;
		uint256 increaseSupplyBy = ownerBalance.mul(splitFactor).sub(ownerBalance); // We need to mint owner*splitFactor - owner additional tokens.&#13;
		balances[msg.sender] = balances[msg.sender].mul(splitFactor);&#13;
		totalSupply_ = totalSupply_.mul(splitFactor);&#13;
		emit Transfer(address(0), msg.sender, increaseSupplyBy); // Notify exchange that we've minted tokens.&#13;
		for (uint256 i = 0; i &lt; n; i++) {&#13;
			Member storage currentMember = members[allMembers[i]];&#13;
			// Take care of transferred balance.&#13;
			currentMember.transferred = currentMember.transferred * int(splitFactor);&#13;
			// Iterate over all of this user's balances for all groups. If a user is not a part of a group their balance will be 0.&#13;
			for (uint256 j = 0; j &lt; nextGroupNumber; j++) {&#13;
				uint256 memberBalance = currentMember.tokenBalance[j];&#13;
				uint256 multiplier = memberBalance.mul(splitFactor);&#13;
				currentMember.tokenBalance[j] = multiplier;&#13;
			}&#13;
		}&#13;
		// Next, increase group ratios by splitFactor, so users will receive ratio + splitFactor tokens per ether.&#13;
		n = nextGroupNumber;&#13;
		require(n &gt; 0); // Must have at least one group.&#13;
		for (i = 0; i &lt; n; i++) {&#13;
			Group storage currentGroup = groups[i];&#13;
			currentGroup.ratio = currentGroup.ratio.mul(splitFactor);&#13;
		}&#13;
		emit SplitTokens(splitFactor);&#13;
		return true;&#13;
	}&#13;
	&#13;
	function reverseSplitTokensBeforeDistribution(uint256 splitFactor) public onlyOwner returns (bool success) {&#13;
		// SplitFactor is the multiplier per decimal of spark. splitFactor * 10**decimals = splitFactor sparks&#13;
		uint256 n = allMembers.length;&#13;
		uint256 ownerBalance = balances[msg.sender];&#13;
		uint256 decreaseSupplyBy = ownerBalance.sub(ownerBalance.div(splitFactor));&#13;
		// We don't use burnTokens here since the amount to subtract might be more than what the owner currently holds in their unallocated supply which will cause the function to throw.&#13;
		totalSupply_ = totalSupply_.div(splitFactor);&#13;
		balances[msg.sender] = ownerBalance.div(splitFactor);&#13;
		// Notify the exchanges of how many tokens were burned.&#13;
		emit Transfer(msg.sender, address(0), decreaseSupplyBy);&#13;
		for (uint256 i = 0; i &lt; n; i++) {&#13;
			Member storage currentMember = members[allMembers[i]];&#13;
			// Take care of the member's transferred balance.&#13;
			currentMember.transferred = currentMember.transferred / int(splitFactor);&#13;
			for (uint256 j = 0; j &lt; nextGroupNumber; j++) {&#13;
				uint256 memberBalance = currentMember.tokenBalance[j];&#13;
				uint256 divier = memberBalance.div(splitFactor);&#13;
				currentMember.tokenBalance[j] = divier;&#13;
			}&#13;
		}&#13;
		// Next, decrease group ratios by splitFactor, so users will receive ratio - splitFactor tokens per ether.&#13;
		n = nextGroupNumber;&#13;
		require(n &gt; 0); // Must have at least one group. Groups are 0-indexed.&#13;
		for (i = 0; i &lt; n; i++) {&#13;
			Group storage currentGroup = groups[i];&#13;
			currentGroup.ratio = currentGroup.ratio.div(splitFactor);&#13;
		}&#13;
		emit ReverseSplitTokens(splitFactor);&#13;
		return true;&#13;
	}&#13;
&#13;
	function splitTokensAfterDistribution(uint256 splitFactor) public onlyOwner returns (bool success) {&#13;
		splitTokensBeforeDistribution(splitFactor);&#13;
		uint256 n = allMembers.length;&#13;
		for (uint256 i = 0; i &lt; n; i++) {&#13;
			address currentMember = allMembers[i];&#13;
			uint256 memberBalance = balances[currentMember];&#13;
			if (memberBalance &gt; 0) {&#13;
				uint256 multiplier1 = memberBalance.mul(splitFactor);&#13;
				uint256 increaseMemberSupplyBy = multiplier1.sub(memberBalance);&#13;
				balances[currentMember] = multiplier1;&#13;
				emit Transfer(address(0), currentMember, increaseMemberSupplyBy);&#13;
			}&#13;
		}&#13;
		n = allNonMembers.length;&#13;
		for (i = 0; i &lt; n; i++) {&#13;
			address currentNonMember = allNonMembers[i];&#13;
			// If this address started out as a nonmember and then became a member, we've seen them already in allMembers so don't grow or shrink them twice.&#13;
			if (members[currentNonMember].exists) {&#13;
				continue;&#13;
			}&#13;
			uint256 nonMemberBalance = balances[currentNonMember];&#13;
			if (nonMemberBalance &gt; 0) {&#13;
				uint256 multiplier2 = nonMemberBalance.mul(splitFactor);&#13;
				uint256 increaseNonMemberSupplyBy = multiplier2.sub(nonMemberBalance);&#13;
				balances[currentNonMember] = multiplier2;&#13;
				emit Transfer(address(0), currentNonMember, increaseNonMemberSupplyBy);&#13;
			}&#13;
		}&#13;
		emit SplitTokens(splitFactor);&#13;
		return true;&#13;
	}&#13;
&#13;
	function reverseSplitTokensAfterDistribution(uint256 splitFactor) public onlyOwner returns (bool success) {&#13;
		reverseSplitTokensBeforeDistribution(splitFactor);&#13;
		uint256 n = allMembers.length;&#13;
		for (uint256 i = 0; i &lt; n; i++) {&#13;
			address currentMember = allMembers[i];&#13;
			uint256 memberBalance = balances[currentMember];&#13;
			if (memberBalance &gt; 0) {&#13;
				uint256 divier1 = memberBalance.div(splitFactor);&#13;
				uint256 decreaseMemberSupplyBy = memberBalance.sub(divier1);&#13;
				balances[currentMember] = divier1;&#13;
				emit Transfer(currentMember, address(0), decreaseMemberSupplyBy);&#13;
			}&#13;
		}&#13;
		n = allNonMembers.length;&#13;
		for (i = 0; i &lt; n; i++) {&#13;
			address currentNonMember = allNonMembers[i];&#13;
			// If this address started out as a nonmember and then became a member, we've seen them already in allMembers so don't grow or shrink them twice.&#13;
			if (members[currentNonMember].exists) {&#13;
				continue;&#13;
			}&#13;
			uint256 nonMemberBalance = balances[currentNonMember];&#13;
			if (nonMemberBalance &gt; 0) {&#13;
				uint256 divier2 = nonMemberBalance.div(splitFactor);&#13;
				uint256 decreaseNonMemberSupplyBy = nonMemberBalance.sub(divier2);&#13;
				balances[currentNonMember] = divier2;&#13;
				emit Transfer(currentNonMember, address(0), decreaseNonMemberSupplyBy);&#13;
			}&#13;
		}&#13;
		emit ReverseSplitTokens(splitFactor);&#13;
		return true;&#13;
	}&#13;
&#13;
	function changeMaxContribution(address memberAddress, uint256 newMax1) public onlyOwner {&#13;
		// Allows to change a member's maximum contribution for phase 1.&#13;
		Member storage theMember = members[memberAddress];&#13;
		require(theMember.exists); // Don't allow to change for a nonexistent member.&#13;
		theMember.max1 = newMax1;&#13;
	}&#13;
	&#13;
	function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) canTransfer returns (bool success) {		&#13;
		// If the transferrer has purchased tokens, they must be unlocked before they can be used.&#13;
		Member storage fromMember = members[msg.sender];&#13;
		if (fromMember.exists) { // If this is the owner, this check will be false so no need to check specifically for owner here.&#13;
			int256 transferValue = fromMember.transferred + int(_value);&#13;
			require(transferValue &gt;= fromMember.transferred); // Check for overflow.&#13;
			require(transferValue &lt;= int(getUnlockedBalanceLimit(msg.sender))); // Make sure they don't transfer out more than their unlocked limit.&#13;
			fromMember.transferred = transferValue;&#13;
		}&#13;
		// If any of the parties involved are not members, add them to the nonmembers list.&#13;
		// Don't add the owner, since they're a special case.&#13;
		if (!fromMember.exists &amp;&amp; msg.sender != owner) {&#13;
			bool fromTransferee = nonMemberTransfers[msg.sender];&#13;
			if (!fromTransferee) { // If we haven't added this transferee before.&#13;
				nonMemberTransfers[msg.sender] = true;&#13;
				allNonMembers.push(msg.sender);&#13;
			}&#13;
		}&#13;
		if (!members[_to].exists &amp;&amp; _to != owner) {&#13;
			bool toTransferee = nonMemberTransfers[_to];&#13;
			if (!toTransferee) { // If we haven't added this transferee before.&#13;
				nonMemberTransfers[_to] = true;&#13;
				allNonMembers.push(_to);&#13;
			}&#13;
		} else if (members[_to].exists) { // Add this transfer to the unlocked balance&#13;
			int256 transferInValue = members[_to].transferred - int(_value);&#13;
			require(transferInValue &lt;= members[_to].transferred); // Check for underflow.&#13;
			members[_to].transferred = transferInValue;&#13;
		}&#13;
		return super.transfer(_to, _value);&#13;
	}&#13;
&#13;
	function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3 * 32) canTransfer returns (bool success) {&#13;
		// If the transferrer has purchased tokens, they must be unlocked before they can be used.&#13;
		Member storage fromMember = members[_from];&#13;
		if (fromMember.exists) { // If _from is the owner, this check will always fail, so we don't need to check specifically for owner here.&#13;
			int256 transferValue = fromMember.transferred + int(_value);&#13;
			require(transferValue &gt;= fromMember.transferred); // Check for overflow.&#13;
			require(transferValue &lt;= int(getUnlockedBalanceLimit(msg.sender))); // Make sure they don't transfer out more than their unlocked limit.&#13;
			fromMember.transferred = transferValue;&#13;
		}&#13;
		// If any of the parties involved are not members, add them to the nonmembers list.&#13;
		// Don't add the owner since they're a special case.&#13;
		if (!fromMember.exists &amp;&amp; _from != owner) {&#13;
			bool fromTransferee = nonMemberTransfers[_from];&#13;
			if (!fromTransferee) { // If we haven't added this transferee before.&#13;
				nonMemberTransfers[_from] = true;&#13;
				allNonMembers.push(_from);&#13;
			}&#13;
		}&#13;
		if (!members[_to].exists &amp;&amp; _to != owner) {&#13;
			bool toTransferee = nonMemberTransfers[_to];&#13;
			if (!toTransferee) { // If we haven't added this transferee before.&#13;
				nonMemberTransfers[_to] = true;&#13;
				allNonMembers.push(_to);&#13;
			}&#13;
		} else if (members[_to].exists) { // Add this transfer to the unlocked balance&#13;
			int256 transferInValue = members[_to].transferred - int(_value);&#13;
			require(transferInValue &lt;= members[_to].transferred); // Check for underflow.&#13;
			members[_to].transferred = transferInValue;&#13;
		}&#13;
		return super.transferFrom(_from, _to, _value);&#13;
	}&#13;
&#13;
	function setOpenGroup(uint256 groupNumber) public onlyOwner returns (bool success) {&#13;
		require(groupNumber &lt; nextGroupNumber);&#13;
		openGroupNumber = groupNumber;&#13;
		return true;&#13;
	}&#13;
&#13;
	function getUndistributedBalanceOf(address walletAddress, uint256 groupNumber) public view returns (uint256 balance) {&#13;
		Member storage theMember = members[walletAddress];&#13;
		require(theMember.exists);&#13;
		if (groups[groupNumber].distributed) // Here, the group will be distributed but tokenBalance will still have a value, so that we know how many tokens to allocate to the unlocked balance.&#13;
			return 0;&#13;
		return theMember.tokenBalance[groupNumber];&#13;
	}&#13;
&#13;
	function checkMyUndistributedBalance(uint256 groupNumber) public view returns (uint256 balance) {&#13;
		return getUndistributedBalanceOf(msg.sender, groupNumber);&#13;
	}&#13;
&#13;
	function transferRecovery(address _from, address _to, uint256 _value) public onlyOwner returns (bool success) {&#13;
		// Will be used if someone sends tokens to an incorrect address by accident. This way, we have the ability to recover the tokens. For example, sometimes there's a problem of lost tokens if someone sends tokens to a contract address that can't utilize the tokens.&#13;
		allowed[_from][msg.sender] = allowed[_from][msg.sender].add(_value); // Authorize the owner to spend on someone's behalf.&#13;
		Member storage fromMember = members[_from];&#13;
		if (fromMember.exists) {&#13;
			int256 oldTransferred = fromMember.transferred;&#13;
			fromMember.transferred -= int(_value); // Unlock this amount.&#13;
			require(oldTransferred &gt;= fromMember.transferred); // Check for underflow.&#13;
		}&#13;
		return transferFrom(_from, _to, _value);&#13;
	}&#13;
}