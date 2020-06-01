pragma solidity ^0.4.24;

/**
 * @title SafeMath from zeppelin-solidity
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
 * @title PNS - Physical Form of CryptoCurrency Name System
 * @dev Physical form cryptocurrency name system smart contract is implemented 
 * to manage and record physical form cryptocurrency manufacturers' 
 * informations, such as the name of the manufacturer, the public key 
 * of the key pair whose private key signed the certificate of the physical 
 * form cryptocurrency, etc.
 * 
 * @author Hui Xie - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="aec6dbc780999a9c9d9897eec9c3cfc7c280cdc1c3">[email protected]</a>&gt;&#13;
 */&#13;
contract PNS {&#13;
&#13;
    using SafeMath for uint256; &#13;
&#13;
    // Event of register&#13;
    event Register(address indexed _from, string _mfr, bytes32 _mid);&#13;
&#13;
    // Event of transfer ownership&#13;
    event Transfer(address indexed _from, string _mfr, bytes32 _mid, address _owner);&#13;
&#13;
    // Event of push a new batch&#13;
    event Push(address indexed _from, string _mfr, bytes32 _mid, string _bn, bytes32 _bid, bytes _key);&#13;
&#13;
    // Event of set batch number&#13;
    event SetBn(address indexed _from, string _mfr, bytes32 _mid, string _bn, bytes32 _bid, bytes _key);&#13;
&#13;
    // Event of set public key&#13;
    event SetKey(address indexed _from, string _mfr, bytes32 _mid, string _bn, bytes32 _bid, bytes _key);&#13;
&#13;
    // Event of lock a batch&#13;
    event Lock(address indexed _from, string _mfr, bytes32 _mid, string _bn, bytes32 _bid, bytes _key);&#13;
&#13;
    // Manufacturer informations&#13;
    struct Manufacturer {&#13;
        address owner; // owner address&#13;
        string mfr; // manufacturer name&#13;
        mapping (bytes32 =&gt; Batch) batchmapping; // mapping of batch: mapping (batch ID =&gt; batch structure)&#13;
        mapping (uint256 =&gt; bytes32) bidmapping; // mapping of batch ID: mapping (storage index =&gt; batch ID), batch ID = keccak256(batch number)&#13;
        uint256 bidcounter; // storage index counter of bidmapping&#13;
    }&#13;
&#13;
    // Product batch informations&#13;
    struct Batch {&#13;
        string bn; // batch number&#13;
        bytes key; // public key&#13;
        bool lock; // is changeable or not&#13;
    }&#13;
&#13;
    // Mapping of manufactures: mapping (manufacturer ID =&gt; manufacturer struct), Manufacturer ID = keccak256(uppercaseOf(manufacturer name))&#13;
    mapping (bytes32 =&gt; Manufacturer) internal mfrmapping;&#13;
&#13;
    // Mapping of manufacturer ID: mapping (storage index =&gt; manufacturer ID)&#13;
    mapping (uint256 =&gt; bytes32) internal midmapping;&#13;
&#13;
    // Storage index counter of midmapping&#13;
    uint256 internal midcounter;&#13;
    &#13;
    /**&#13;
     * @dev Register a manufacturer.&#13;
     * &#13;
     * @param _mfr Manufacturer name&#13;
     * @return Manufacturer ID&#13;
     */&#13;
    function register(string _mfr) public returns (bytes32) {&#13;
        require(lengthOf(_mfr) &gt; 0);&#13;
        require(msg.sender != address(0));&#13;
&#13;
        bytes32 mid = keccak256(bytes(uppercaseOf(_mfr)));&#13;
        require(mfrmapping[mid].owner == address(0));&#13;
&#13;
        midcounter = midcounter.add(1);&#13;
        midmapping[midcounter] = mid;&#13;
&#13;
        mfrmapping[mid].owner = msg.sender;&#13;
        mfrmapping[mid].mfr = _mfr;&#13;
        &#13;
        emit Register(msg.sender, _mfr, mid);&#13;
&#13;
        return mid;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Transfer ownership of a manufacturer.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @param _owner Address of new owner&#13;
     * @return Batch ID&#13;
     */&#13;
    function transfer(bytes32 _mid, address _owner) public returns (bytes32) {&#13;
        require(_mid != bytes32(0));&#13;
        require(_owner != address(0));&#13;
&#13;
        require(mfrmapping[_mid].owner != address(0));&#13;
        require(msg.sender == mfrmapping[_mid].owner);&#13;
&#13;
        mfrmapping[_mid].owner = _owner;&#13;
&#13;
        emit Transfer(msg.sender, mfrmapping[_mid].mfr, _mid, _owner);&#13;
&#13;
        return _mid;&#13;
    }&#13;
    &#13;
    /**&#13;
     * @dev Push(add) a batch.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @param _bn Batch number&#13;
     * @param _key Public key&#13;
     * @return Batch ID&#13;
     */&#13;
    function push(bytes32 _mid, string _bn, bytes _key) public returns (bytes32) {&#13;
        require(_mid != bytes32(0));&#13;
        require(lengthOf(_bn) &gt; 0);&#13;
        require(_key.length == 33 || _key.length == 65);&#13;
&#13;
        require(mfrmapping[_mid].owner != address(0));&#13;
        require(msg.sender == mfrmapping[_mid].owner);&#13;
&#13;
        bytes32 bid = keccak256(bytes(_bn));&#13;
        require(lengthOf(mfrmapping[_mid].batchmapping[bid].bn) == 0);&#13;
        require(mfrmapping[_mid].batchmapping[bid].key.length == 0);&#13;
        require(mfrmapping[_mid].batchmapping[bid].lock == false);&#13;
&#13;
        mfrmapping[_mid].bidcounter = mfrmapping[_mid].bidcounter.add(1);&#13;
        mfrmapping[_mid].bidmapping[mfrmapping[_mid].bidcounter] = bid;&#13;
        mfrmapping[_mid].batchmapping[bid].bn = _bn;&#13;
        mfrmapping[_mid].batchmapping[bid].key = _key;&#13;
        mfrmapping[_mid].batchmapping[bid].lock = false;&#13;
&#13;
        emit Push(msg.sender, mfrmapping[_mid].mfr, _mid, _bn, bid, _key);&#13;
&#13;
        return bid;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Set(change) batch number of an unlocked batch.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @param _bid Batch ID&#13;
     * @param _bn Batch number&#13;
     * @return Batch ID&#13;
     */&#13;
    function setBn(bytes32 _mid, bytes32 _bid, string _bn) public returns (bytes32) {&#13;
        require(_mid != bytes32(0));&#13;
        require(_bid != bytes32(0));&#13;
        require(lengthOf(_bn) &gt; 0);&#13;
&#13;
        require(mfrmapping[_mid].owner != address(0));&#13;
        require(msg.sender == mfrmapping[_mid].owner);&#13;
&#13;
        bytes32 bid = keccak256(bytes(_bn));&#13;
        require(bid != _bid);&#13;
        require(lengthOf(mfrmapping[_mid].batchmapping[_bid].bn) &gt; 0);&#13;
        require(mfrmapping[_mid].batchmapping[_bid].key.length &gt; 0);&#13;
        require(mfrmapping[_mid].batchmapping[_bid].lock == false);&#13;
        require(lengthOf(mfrmapping[_mid].batchmapping[bid].bn) == 0);&#13;
        require(mfrmapping[_mid].batchmapping[bid].key.length == 0);&#13;
        require(mfrmapping[_mid].batchmapping[bid].lock == false);&#13;
&#13;
        uint256 counter = 0;&#13;
        for (uint256 i = 1; i &lt;= mfrmapping[_mid].bidcounter; i++) {&#13;
            if (mfrmapping[_mid].bidmapping[i] == _bid) {&#13;
                counter = i;&#13;
                break;&#13;
            }&#13;
        }&#13;
        require(counter &gt; 0);&#13;
&#13;
        mfrmapping[_mid].bidmapping[counter] = bid;&#13;
        mfrmapping[_mid].batchmapping[bid].bn = _bn;&#13;
        mfrmapping[_mid].batchmapping[bid].key = mfrmapping[_mid].batchmapping[_bid].key;&#13;
        mfrmapping[_mid].batchmapping[bid].lock = false;&#13;
        delete mfrmapping[_mid].batchmapping[_bid];&#13;
&#13;
        emit SetBn(msg.sender, mfrmapping[_mid].mfr, _mid, _bn, bid, mfrmapping[_mid].batchmapping[bid].key);&#13;
&#13;
        return bid;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Set(change) public key of an unlocked batch.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @param _bid Batch ID&#13;
     * @param _key Public key&#13;
     * @return Batch ID&#13;
     */&#13;
    function setKey(bytes32 _mid, bytes32 _bid, bytes _key) public returns (bytes32) {&#13;
        require(_mid != bytes32(0));&#13;
        require(_bid != bytes32(0));&#13;
        require(_key.length == 33 || _key.length == 65);&#13;
&#13;
        require(mfrmapping[_mid].owner != address(0));&#13;
        require(msg.sender == mfrmapping[_mid].owner);&#13;
&#13;
        require(lengthOf(mfrmapping[_mid].batchmapping[_bid].bn) &gt; 0);&#13;
        require(mfrmapping[_mid].batchmapping[_bid].key.length &gt; 0);&#13;
        require(mfrmapping[_mid].batchmapping[_bid].lock == false);&#13;
&#13;
        mfrmapping[_mid].batchmapping[_bid].key = _key;&#13;
&#13;
        emit SetKey(msg.sender, mfrmapping[_mid].mfr, _mid, mfrmapping[_mid].batchmapping[_bid].bn, _bid, _key);&#13;
&#13;
        return _bid;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Lock batch. Batch number and public key is unchangeable after it is locked.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @param _bid Batch ID&#13;
     * @return Batch ID&#13;
     */&#13;
    function lock(bytes32 _mid, bytes32 _bid) public returns (bytes32) {&#13;
        require(_mid != bytes32(0));&#13;
        require(_bid != bytes32(0));&#13;
&#13;
        require(mfrmapping[_mid].owner != address(0));&#13;
        require(msg.sender == mfrmapping[_mid].owner);&#13;
&#13;
        require(lengthOf(mfrmapping[_mid].batchmapping[_bid].bn) &gt; 0);&#13;
        require(mfrmapping[_mid].batchmapping[_bid].key.length &gt; 0);&#13;
&#13;
        mfrmapping[_mid].batchmapping[_bid].lock = true;&#13;
&#13;
        emit Lock(msg.sender, mfrmapping[_mid].mfr, _mid, mfrmapping[_mid].batchmapping[_bid].bn, _bid, mfrmapping[_mid].batchmapping[_bid].key);&#13;
&#13;
        return _bid;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Check batch by its batch ID and public key.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @param _bid Batch ID&#13;
     * @param _key Public key&#13;
     * @return True or false&#13;
     */&#13;
    function check(bytes32 _mid, bytes32 _bid, bytes _key) public view returns (bool) {&#13;
        if (mfrmapping[_mid].batchmapping[_bid].key.length != _key.length) {&#13;
            return false;&#13;
        }&#13;
        for (uint256 i = 0; i &lt; _key.length; i++) {&#13;
            if (mfrmapping[_mid].batchmapping[_bid].key[i] != _key[i]) {&#13;
                return false;&#13;
            }&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Get total number of manufacturers.&#13;
     * &#13;
     * @return Total number of manufacturers&#13;
     */&#13;
    function totalMfr() public view returns (uint256) {&#13;
        return midcounter;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Get manufacturer ID.&#13;
     * &#13;
     * @param _midcounter Storage index counter of midmapping&#13;
     * @return Manufacturer ID&#13;
     */&#13;
    function midOf(uint256 _midcounter) public view returns (bytes32) {&#13;
        return midmapping[_midcounter];&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Get manufacturer owner.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @return Manufacturer owner&#13;
     */&#13;
    function ownerOf(bytes32 _mid) public view returns (address) {&#13;
        return mfrmapping[_mid].owner;&#13;
    }&#13;
    &#13;
    /**&#13;
     * @dev Get manufacturer name.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @return Manufacturer name (Uppercase)&#13;
     */&#13;
    function mfrOf(bytes32 _mid) public view returns (string) {&#13;
        return mfrmapping[_mid].mfr;&#13;
    }&#13;
    &#13;
    /**&#13;
     * @dev Get total batch number of a manufacturer.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @return Total batch number&#13;
     */&#13;
    function totalBatchOf(bytes32 _mid) public view returns (uint256) {&#13;
        return mfrmapping[_mid].bidcounter;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Get batch ID.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @param _bidcounter Storage index counter of bidmapping&#13;
     * @return Batch ID&#13;
     */&#13;
    function bidOf(bytes32 _mid, uint256 _bidcounter) public view returns (bytes32) {&#13;
        return mfrmapping[_mid].bidmapping[_bidcounter];&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Get batch number.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @param _bid Batch ID&#13;
     * @return Batch number&#13;
     */&#13;
    function bnOf(bytes32 _mid, bytes32 _bid) public view returns (string) {&#13;
        return mfrmapping[_mid].batchmapping[_bid].bn;&#13;
    }&#13;
    &#13;
    /**&#13;
     * @dev Get batch public key.&#13;
     * &#13;
     * @param _mid Manufacturer ID&#13;
     * @param _bid Batch ID&#13;
     * @return bytes Batch public key&#13;
     */&#13;
    function keyOf(bytes32 _mid, bytes32 _bid) public view returns (bytes) {&#13;
        if (mfrmapping[_mid].batchmapping[_bid].lock == true) {&#13;
            return mfrmapping[_mid].batchmapping[_bid].key;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Convert string to uppercase.&#13;
     * &#13;
     * @param _s String to convert&#13;
     * @return Converted string&#13;
     */&#13;
    function uppercaseOf(string _s) internal pure returns (string) {&#13;
        bytes memory b1 = bytes(_s);&#13;
        uint256 l = b1.length;&#13;
        bytes memory b2 = new bytes(l);&#13;
        for (uint256 i = 0; i &lt; l; i++) {&#13;
            if (b1[i] &gt;= 0x61 &amp;&amp; b1[i] &lt;= 0x7A) {&#13;
                b2[i] = bytes1(uint8(b1[i]) - 32);&#13;
            } else {&#13;
                b2[i] = b1[i];&#13;
            }&#13;
        }&#13;
        return string(b2);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Get string length.&#13;
     * &#13;
     * @param _s String&#13;
     * @return length&#13;
     */&#13;
    function lengthOf(string _s) internal pure returns (uint256) {&#13;
        return bytes(_s).length;&#13;
    }&#13;
}