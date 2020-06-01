// File: node_modules\zeppelin-solidity\contracts\ownership\Ownable.sol

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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: node_modules\zeppelin-solidity\contracts\token\ERC721\ERC721Basic.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);

  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId) public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator) public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public;
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC721\ERC721.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
  function tokenByIndex(uint256 _index) public view returns (uint256);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
  function name() public view returns (string _name);
  function symbol() public view returns (string _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

// File: node_modules\zeppelin-solidity\contracts\AddressUtils.sol

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   *  as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    assembly { size := extcodesize(addr) }  // solium-disable-line security/no-inline-assembly
    return size > 0;
  }

}

// File: node_modules\zeppelin-solidity\contracts\math\SafeMath.sol

/**
 * @title SafeMath
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

// File: node_modules\zeppelin-solidity\contracts\token\ERC721\ERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 *  from ERC721 asset contracts.
 */
contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   *  after a `safetransfer`. This function MAY throw to revert and reject the
   *  transfer. This function MUST use 50,000 gas or less. Return of other
   *  than the magic value MUST result in the transaction being reverted.
   *  Note: the contract address is always the message sender.
   * @param _from The sending address
   * @param _tokenId The NFT identifier which is being transfered
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
   */
  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC721\ERC721BasicToken.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721BasicToken is ERC721Basic {
  using SafeMath for uint256;
  using AddressUtils for address;

  // Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  /**
   * @dev Guarantees msg.sender is owner of the given token
   * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
   */
  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

  /**
   * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
   * @param _tokenId uint256 ID of the token to validate
   */
  modifier canTransfer(uint256 _tokenId) {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    _;
  }

  /**
   * @dev Gets the balance of the specified address
   * @param _owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

  /**
   * @dev Gets the owner of the specified token ID
   * @param _tokenId uint256 ID of the token to query the owner of
   * @return owner address currently marked as the owner of the given token ID
   */
  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  /**
   * @dev Returns whether the specified token exists
   * @param _tokenId uint256 ID of the token to query the existance of
   * @return whether the token exists
   */
  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  /**
   * @dev Approves another address to transfer the given token ID
   * @dev The zero address indicates there is no approved address.
   * @dev There can only be one approved address per token at a given time.
   * @dev Can only be called by the token owner or an approved operator.
   * @param _to address to be approved for the given token ID
   * @param _tokenId uint256 ID of the token to be approved
   */
  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    if (getApproved(_tokenId) != address(0) || _to != address(0)) {
      tokenApprovals[_tokenId] = _to;
      emit Approval(owner, _to, _tokenId);
    }
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for a the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }

  /**
   * @dev Sets or unsets the approval of a given operator
   * @dev An operator is allowed to transfer all tokens of the sender on their behalf
   * @param _to operator address to set the approval
   * @param _approved representing the status of the approval to be set
   */
  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }

  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param _owner owner address which you want to query the approval of
   * @param _operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
    return operatorApprovals[_owner][_operator];
  }

  /**
   * @dev Transfers the ownership of a given token ID to another address
   * @dev Usage of this method is discouraged, use `safeTransferFrom` whenever possible
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);

    emit Transfer(_from, _to, _tokenId);
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * @dev If the target address is a contract, it must implement `onERC721Received`,
   *  which is called upon a safe transfer, and return the magic value
   *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
   *  the transfer is reverted.
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
    canTransfer(_tokenId)
  {
    // solium-disable-next-line arg-overflow
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * @dev If the target address is a contract, it must implement `onERC721Received`,
   *  which is called upon a safe transfer, and return the magic value
   *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
   *  the transfer is reverted.
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes data to send along with a safe transfer check
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public
    canTransfer(_tokenId)
  {
    transferFrom(_from, _to, _tokenId);
    // solium-disable-next-line arg-overflow
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
    address owner = ownerOf(_tokenId);
    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
  }

  /**
   * @dev Internal function to mint a new token
   * @dev Reverts if the given token ID already exists
   * @param _to The address that will own the minted token
   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    emit Transfer(address(0), _to, _tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * @dev Reverts if the token does not exist
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    emit Transfer(_owner, address(0), _tokenId);
  }

  /**
   * @dev Internal function to clear current approval of a given token ID
   * @dev Reverts if the given address is not indeed the owner of the token
   * @param _owner owner of the token
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
      emit Approval(_owner, address(0), _tokenId);
    }
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }

  /**
   * @dev Internal function to invoke `onERC721Received` on a target address
   * @dev The call is not executed if the target address is not a contract
   * @param _from address representing the previous owner of the given token ID
   * @param _to target address that will receive the tokens
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes optional data to send along with the call
   * @return whether the call correctly returned the expected magic value
   */
  function checkAndCallSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    internal
    returns (bool)
  {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC721\ERC721Token.sol

/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Token is ERC721, ERC721BasicToken {
  // Token name
  string internal name_;

  // Token symbol
  string internal symbol_;

  // Mapping from owner to list of owned token IDs
  mapping (address => uint256[]) internal ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) internal ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] internal allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) internal allTokensIndex;

  // Optional mapping for token URIs
  mapping(uint256 => string) internal tokenURIs;

  /**
   * @dev Constructor function
   */
  function ERC721Token(string _name, string _symbol) public {
    name_ = _name;
    symbol_ = _symbol;
  }

  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() public view returns (string) {
    return name_;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function symbol() public view returns (string) {
    return symbol_;
  }

  /**
   * @dev Returns an URI for a given token ID
   * @dev Throws if the token ID does not exist. May return an empty string.
   * @param _tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 _tokenId) public view returns (string) {
    require(exists(_tokenId));
    return tokenURIs[_tokenId];
  }

  /**
   * @dev Gets the token ID at a given index of the tokens list of the requested owner
   * @param _owner address owning the tokens list to be accessed
   * @param _index uint256 representing the index to be accessed of the requested tokens list
   * @return uint256 token ID at the given index of the tokens list owned by the requested address
   */
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  /**
   * @dev Gets the total amount of tokens stored by the contract
   * @return uint256 representing the total amount of tokens
   */
  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

  /**
   * @dev Gets the token ID at a given index of all the tokens in this contract
   * @dev Reverts if the index is greater or equal to the total number of tokens
   * @param _index uint256 representing the index to be accessed of the tokens list
   * @return uint256 token ID at the given index of the tokens list
   */
  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

  /**
   * @dev Internal function to set the token URI for a given token
   * @dev Reverts if the token ID does not exist
   * @param _tokenId uint256 ID of the token to set its URI
   * @param _uri string URI to assign
   */
  function _setTokenURI(uint256 _tokenId, string _uri) internal {
    require(exists(_tokenId));
    tokenURIs[_tokenId] = _uri;
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    super.addTokenTo(_to, _tokenId);
    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    super.removeTokenFrom(_from, _tokenId);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;
    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  /**
   * @dev Internal function to mint a new token
   * @dev Reverts if the given token ID already exists
   * @param _to address the beneficiary that will own the minted token
   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address _to, uint256 _tokenId) internal {
    super._mint(_to, _tokenId);

    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * @dev Reverts if the token does not exist
   * @param _owner owner of the token to burn
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address _owner, uint256 _tokenId) internal {
    super._burn(_owner, _tokenId);

    // Clear metadata (if any)
    if (bytes(tokenURIs[_tokenId]).length != 0) {
      delete tokenURIs[_tokenId];
    }

    // Reorg all tokens array
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 lastTokenIndex = allTokens.length.sub(1);
    uint256 lastToken = allTokens[lastTokenIndex];

    allTokens[tokenIndex] = lastToken;
    allTokens[lastTokenIndex] = 0;

    allTokens.length--;
    allTokensIndex[_tokenId] = 0;
    allTokensIndex[lastToken] = tokenIndex;
  }

}

// File: contracts\Integers.sol

/**
 * Integers Library
 *
 * In summary this is a simple library of integer functions which allow a simple
 * conversion to and from strings
 *
 * @author James Lockhart <<span class="__cf_email__" data-cfemail="1b717a767e685b75286f6c2b6970357874356e70">[email protected]</span>&gt;&#13;
 */&#13;
library Integers {&#13;
    /**&#13;
     * Parse Int&#13;
     *&#13;
     * Converts an ASCII string value into an uint as long as the string&#13;
     * its self is a valid unsigned integer&#13;
     *&#13;
     * @param _value The ASCII string to be converted to an unsigned integer&#13;
     * @return uint The unsigned value of the ASCII string&#13;
     */&#13;
    function parseInt(string _value)&#13;
        public&#13;
        returns (uint _ret) {&#13;
        bytes memory _bytesValue = bytes(_value);&#13;
        uint j = 1;&#13;
        for(uint i = _bytesValue.length-1; i &gt;= 0 &amp;&amp; i &lt; _bytesValue.length; i--) {&#13;
            assert(_bytesValue[i] &gt;= 48 &amp;&amp; _bytesValue[i] &lt;= 57);&#13;
            _ret += (uint(_bytesValue[i]) - 48)*j;&#13;
            j*=10;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * To String&#13;
     *&#13;
     * Converts an unsigned integer to the ASCII string equivalent value&#13;
     *&#13;
     * @param _base The unsigned integer to be converted to a string&#13;
     * @return string The resulting ASCII string value&#13;
     */&#13;
    function toString(uint _base)&#13;
        internal&#13;
        returns (string) {&#13;
        bytes memory _tmp = new bytes(32);&#13;
        uint i;&#13;
        for(i = 0;_base &gt; 0;i++) {&#13;
            _tmp[i] = byte((_base % 10) + 48);&#13;
            _base /= 10;&#13;
        }&#13;
        bytes memory _real = new bytes(i--);&#13;
        for(uint j = 0; j &lt; _real.length; j++) {&#13;
            _real[j] = _tmp[i--];&#13;
        }&#13;
        return string(_real);&#13;
    }&#13;
&#13;
    /**&#13;
     * To Byte&#13;
     *&#13;
     * Convert an 8 bit unsigned integer to a byte&#13;
     *&#13;
     * @param _base The 8 bit unsigned integer&#13;
     * @return byte The byte equivalent&#13;
     */&#13;
    function toByte(uint8 _base)&#13;
        public&#13;
        returns (byte _ret) {&#13;
        assembly {&#13;
            let m_alloc := add(msize(),0x1)&#13;
            mstore8(m_alloc, _base)&#13;
            _ret := mload(m_alloc)&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * To Bytes&#13;
     *&#13;
     * Converts an unsigned integer to bytes&#13;
     *&#13;
     * @param _base The integer to be converted to bytes&#13;
     * @return bytes The bytes equivalent&#13;
     */&#13;
    function toBytes(uint _base)&#13;
        internal&#13;
        returns (bytes _ret) {&#13;
        assembly {&#13;
            let m_alloc := add(msize(),0x1)&#13;
            _ret := mload(m_alloc)&#13;
            mstore(_ret, 0x20)&#13;
            mstore(add(_ret, 0x20), _base)&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
// File: contracts\Strings.sol&#13;
&#13;
/**&#13;
 * Strings Library&#13;
 *&#13;
 * In summary this is a simple library of string functions which make simple&#13;
 * string operations less tedious in solidity.&#13;
 *&#13;
 * Please be aware these functions can be quite gas heavy so use them only when&#13;
 * necessary not to clog the blockchain with expensive transactions.&#13;
 *&#13;
 * @author James Lockhart &lt;<span class="__cf_email__" data-cfemail="a1cbc0ccc4d2e1cf92d5d691d3ca8fc2ce8fd4ca">[email protected]</span>&gt;&#13;
 */&#13;
library Strings {&#13;
&#13;
    /**&#13;
     * Concat (High gas cost)&#13;
     *&#13;
     * Appends two strings together and returns a new value&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string which will be the concatenated&#13;
     *              prefix&#13;
     * @param _value The value to be the concatenated suffix&#13;
     * @return string The resulting string from combinging the base and value&#13;
     */&#13;
    function concat(string _base, string _value)&#13;
        internal&#13;
        returns (string) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        bytes memory _valueBytes = bytes(_value);&#13;
&#13;
        assert(_valueBytes.length &gt; 0);&#13;
&#13;
        string memory _tmpValue = new string(_baseBytes.length +&#13;
            _valueBytes.length);&#13;
        bytes memory _newValue = bytes(_tmpValue);&#13;
&#13;
        uint i;&#13;
        uint j;&#13;
&#13;
        for(i = 0; i &lt; _baseBytes.length; i++) {&#13;
            _newValue[j++] = _baseBytes[i];&#13;
        }&#13;
&#13;
        for(i = 0; i&lt;_valueBytes.length; i++) {&#13;
            _newValue[j++] = _valueBytes[i];&#13;
        }&#13;
&#13;
        return string(_newValue);&#13;
    }&#13;
&#13;
    /**&#13;
     * Index Of&#13;
     *&#13;
     * Locates and returns the position of a character within a string&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string acting as the haystack to be&#13;
     *              searched&#13;
     * @param _value The needle to search for, at present this is currently&#13;
     *               limited to one character&#13;
     * @return int The position of the needle starting from 0 and returning -1&#13;
     *             in the case of no matches found&#13;
     */&#13;
    function indexOf(string _base, string _value)&#13;
        internal&#13;
        returns (int) {&#13;
        return _indexOf(_base, _value, 0);&#13;
    }&#13;
&#13;
    /**&#13;
     * Index Of&#13;
     *&#13;
     * Locates and returns the position of a character within a string starting&#13;
     * from a defined offset&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string acting as the haystack to be&#13;
     *              searched&#13;
     * @param _value The needle to search for, at present this is currently&#13;
     *               limited to one character&#13;
     * @param _offset The starting point to start searching from which can start&#13;
     *                from 0, but must not exceed the length of the string&#13;
     * @return int The position of the needle starting from 0 and returning -1&#13;
     *             in the case of no matches found&#13;
     */&#13;
    function _indexOf(string _base, string _value, uint _offset)&#13;
        internal&#13;
        returns (int) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        bytes memory _valueBytes = bytes(_value);&#13;
&#13;
        assert(_valueBytes.length == 1);&#13;
&#13;
        for(uint i = _offset; i &lt; _baseBytes.length; i++) {&#13;
            if (_baseBytes[i] == _valueBytes[0]) {&#13;
                return int(i);&#13;
            }&#13;
        }&#13;
&#13;
        return -1;&#13;
    }&#13;
&#13;
    /**&#13;
     * Length&#13;
     *&#13;
     * Returns the length of the specified string&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string to be measured&#13;
     * @return uint The length of the passed string&#13;
     */&#13;
    function length(string _base)&#13;
        internal&#13;
        returns (uint) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        return _baseBytes.length;&#13;
    }&#13;
&#13;
    /**&#13;
     * Sub String&#13;
     *&#13;
     * Extracts the beginning part of a string based on the desired length&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string that will be used for&#13;
     *              extracting the sub string from&#13;
     * @param _length The length of the sub string to be extracted from the base&#13;
     * @return string The extracted sub string&#13;
     */&#13;
    function substring(string _base, int _length)&#13;
        internal&#13;
        returns (string) {&#13;
        return _substring(_base, _length, 0);&#13;
    }&#13;
&#13;
    /**&#13;
     * Sub String&#13;
     *&#13;
     * Extracts the part of a string based on the desired length and offset. The&#13;
     * offset and length must not exceed the lenth of the base string.&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string that will be used for&#13;
     *              extracting the sub string from&#13;
     * @param _length The length of the sub string to be extracted from the base&#13;
     * @param _offset The starting point to extract the sub string from&#13;
     * @return string The extracted sub string&#13;
     */&#13;
    function _substring(string _base, int _length, int _offset)&#13;
        internal&#13;
        returns (string) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
&#13;
        assert(uint(_offset+_length) &lt;= _baseBytes.length);&#13;
&#13;
        string memory _tmp = new string(uint(_length));&#13;
        bytes memory _tmpBytes = bytes(_tmp);&#13;
&#13;
        uint j = 0;&#13;
        for(uint i = uint(_offset); i &lt; uint(_offset+_length); i++) {&#13;
          _tmpBytes[j++] = _baseBytes[i];&#13;
        }&#13;
&#13;
        return string(_tmpBytes);&#13;
    }&#13;
&#13;
    /**&#13;
     * String Split (Very high gas cost)&#13;
     *&#13;
     * Splits a string into an array of strings based off the delimiter value.&#13;
     * Please note this can be quite a gas expensive function due to the use of&#13;
     * storage so only use if really required.&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *               otherwise this is the string value to be split.&#13;
     * @param _value The delimiter to split the string on which must be a single&#13;
     *               character&#13;
     * @return string[] An array of values split based off the delimiter, but&#13;
     *                  do not container the delimiter.&#13;
     */&#13;
    function split(string _base, string _value)&#13;
        internal&#13;
        returns (string[] storage splitArr) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        uint _offset = 0;&#13;
&#13;
        while(_offset &lt; _baseBytes.length-1) {&#13;
&#13;
            int _limit = _indexOf(_base, _value, _offset);&#13;
            if (_limit == -1) {&#13;
                _limit = int(_baseBytes.length);&#13;
            }&#13;
&#13;
            string memory _tmp = new string(uint(_limit)-_offset);&#13;
            bytes memory _tmpBytes = bytes(_tmp);&#13;
&#13;
            uint j = 0;&#13;
            for(uint i = _offset; i &lt; uint(_limit); i++) {&#13;
                _tmpBytes[j++] = _baseBytes[i];&#13;
            }&#13;
            _offset = uint(_limit) + 1;&#13;
            splitArr.push(string(_tmpBytes));&#13;
        }&#13;
        return splitArr;&#13;
    }&#13;
&#13;
    /**&#13;
     * Compare To&#13;
     *&#13;
     * Compares the characters of two strings, to ensure that they have an&#13;
     * identical footprint&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *               otherwise this is the string base to compare against&#13;
     * @param _value The string the base is being compared to&#13;
     * @return bool Simply notates if the two string have an equivalent&#13;
     */&#13;
    function compareTo(string _base, string _value)&#13;
        internal&#13;
        returns (bool) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        bytes memory _valueBytes = bytes(_value);&#13;
&#13;
        if (_baseBytes.length != _valueBytes.length) {&#13;
            return false;&#13;
        }&#13;
&#13;
        for(uint i = 0; i &lt; _baseBytes.length; i++) {&#13;
            if (_baseBytes[i] != _valueBytes[i]) {&#13;
                return false;&#13;
            }&#13;
        }&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Compare To Ignore Case (High gas cost)&#13;
     *&#13;
     * Compares the characters of two strings, converting them to the same case&#13;
     * where applicable to alphabetic characters to distinguish if the values&#13;
     * match.&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *               otherwise this is the string base to compare against&#13;
     * @param _value The string the base is being compared to&#13;
     * @return bool Simply notates if the two string have an equivalent value&#13;
     *              discarding case&#13;
     */&#13;
    function compareToIgnoreCase(string _base, string _value)&#13;
        internal&#13;
        returns (bool) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        bytes memory _valueBytes = bytes(_value);&#13;
&#13;
        if (_baseBytes.length != _valueBytes.length) {&#13;
            return false;&#13;
        }&#13;
&#13;
        for(uint i = 0; i &lt; _baseBytes.length; i++) {&#13;
            if (_baseBytes[i] != _valueBytes[i] &amp;&amp;&#13;
                _upper(_baseBytes[i]) != _upper(_valueBytes[i])) {&#13;
                return false;&#13;
            }&#13;
        }&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Upper&#13;
     *&#13;
     * Converts all the values of a string to their corresponding upper case&#13;
     * value.&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string base to convert to upper case&#13;
     * @return string&#13;
     */&#13;
    function upper(string _base)&#13;
        internal&#13;
        returns (string) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        for (uint i = 0; i &lt; _baseBytes.length; i++) {&#13;
            _baseBytes[i] = _upper(_baseBytes[i]);&#13;
        }&#13;
        return string(_baseBytes);&#13;
    }&#13;
&#13;
    /**&#13;
     * Lower&#13;
     *&#13;
     * Converts all the values of a string to their corresponding lower case&#13;
     * value.&#13;
     *&#13;
     * @param _base When being used for a data type this is the extended object&#13;
     *              otherwise this is the string base to convert to lower case&#13;
     * @return string&#13;
     */&#13;
    function lower(string _base)&#13;
        internal&#13;
        returns (string) {&#13;
        bytes memory _baseBytes = bytes(_base);&#13;
        for (uint i = 0; i &lt; _baseBytes.length; i++) {&#13;
            _baseBytes[i] = _lower(_baseBytes[i]);&#13;
        }&#13;
        return string(_baseBytes);&#13;
    }&#13;
&#13;
    /**&#13;
     * Upper&#13;
     *&#13;
     * Convert an alphabetic character to upper case and return the original&#13;
     * value when not alphabetic&#13;
     *&#13;
     * @param _b1 The byte to be converted to upper case&#13;
     * @return bytes1 The converted value if the passed value was alphabetic&#13;
     *                and in a lower case otherwise returns the original value&#13;
     */&#13;
    function _upper(bytes1 _b1)&#13;
        private&#13;
        constant&#13;
        returns (bytes1) {&#13;
&#13;
        if (_b1 &gt;= 0x61 &amp;&amp; _b1 &lt;= 0x7A) {&#13;
            return bytes1(uint8(_b1)-32);&#13;
        }&#13;
&#13;
        return _b1;&#13;
    }&#13;
&#13;
    /**&#13;
     * Lower&#13;
     *&#13;
     * Convert an alphabetic character to lower case and return the original&#13;
     * value when not alphabetic&#13;
     *&#13;
     * @param _b1 The byte to be converted to lower case&#13;
     * @return bytes1 The converted value if the passed value was alphabetic&#13;
     *                and in a upper case otherwise returns the original value&#13;
     */&#13;
    function _lower(bytes1 _b1)&#13;
        private&#13;
        constant&#13;
        returns (bytes1) {&#13;
&#13;
        if (_b1 &gt;= 0x41 &amp;&amp; _b1 &lt;= 0x5A) {&#13;
            return bytes1(uint8(_b1)+32);&#13;
        }&#13;
&#13;
        return _b1;&#13;
    }&#13;
}&#13;
&#13;
// File: contracts\EtherBrosMaker.sol&#13;
&#13;
contract EtherBrosMaker is Ownable, ERC721Token {&#13;
    using Strings for string;&#13;
    using Integers for uint;&#13;
&#13;
    event AuctionCreated(uint256 tokenId, uint256 price);&#13;
    event AuctionSuccessful(uint256 tokenId, uint256 price, address buyer);&#13;
    event AuctionCancelled(uint256 tokenId);&#13;
&#13;
    struct Auction {&#13;
        address seller;&#13;
        uint128 price;&#13;
    }&#13;
&#13;
    mapping (uint256 =&gt; Auction) public tokenIdToAuction;&#13;
    mapping (uint256 =&gt; string) public tokenImage;&#13;
&#13;
    uint128 public mintingFee = 0.001 ether;&#13;
    uint8 prefix = 1;&#13;
    string preURI = "https://enigmatic-castle-32612.herokuapp.com/api/meta?tokenId=";&#13;
    string image = "http://app.givinglog.com/game/ether-bros-maker/img/Etherbro";&#13;
    uint private nonce = 0;&#13;
    uint16[] public etherBros;&#13;
    uint128 ownerCut = 100;&#13;
&#13;
    function EtherBrosMaker () ERC721Token("EtherBrosMaker" ,"EBM") public {&#13;
&#13;
    }&#13;
&#13;
    /*** Owner Action ***/&#13;
    function withdraw() public onlyOwner {&#13;
        owner.transfer(this.balance);&#13;
    }&#13;
&#13;
    function setPrefix(uint8 _prefix) external onlyOwner {&#13;
        require(prefix &gt; 0);&#13;
        prefix = _prefix;&#13;
    }&#13;
&#13;
    function setPreURI(string _preURI) external onlyOwner {&#13;
        preURI = _preURI;&#13;
    }&#13;
&#13;
    function _createEtherBro(uint16 _genes,address _owner) internal returns (uint32){&#13;
        uint32 newEtherBroId = uint32(etherBros.push(_genes) - 1);&#13;
        _mint(_owner, newEtherBroId);&#13;
        string memory _uri = preURI.concat(uint(_genes).toString());&#13;
        tokenImage[newEtherBroId] = image.concat(uint(_genes).toString()).concat(".png");&#13;
        _setTokenURI(newEtherBroId, _uri);&#13;
        return newEtherBroId;&#13;
    }&#13;
&#13;
    function _gensGenerate() internal returns(uint16){&#13;
        uint16 result = prefix * 10000;&#13;
        uint8 _randam1 = rand();&#13;
        uint8 _randam2 = rand();&#13;
        uint8 _randam3 = rand();&#13;
        uint8 _randam4 = rand();&#13;
&#13;
        if (_randam1 &gt; 0 &amp;&amp; _randam1 &lt;4){&#13;
            result = result + 1000;&#13;
        } else if (_randam1 &gt; 3 &amp;&amp; _randam1 &lt;7){&#13;
            result = result + 2000;&#13;
        } else if (_randam1 &gt; 6){&#13;
            result = result + 3000;&#13;
        }&#13;
&#13;
        if (_randam2 &gt; 0 &amp;&amp; _randam2 &lt;4){&#13;
            result = result + 100;&#13;
        } else if (_randam2 &gt; 3 &amp;&amp; _randam2 &lt;7){&#13;
            result = result + 200;&#13;
        } else if (_randam2 &gt; 6){&#13;
            result = result + 300;&#13;
        }&#13;
&#13;
        if (_randam3 &gt; 0 &amp;&amp; _randam3 &lt;4){&#13;
            result = result + 10;&#13;
        } else if (_randam3 &gt; 3 &amp;&amp; _randam3 &lt;7){&#13;
            result = result + 20;&#13;
        } else if (_randam3 &gt; 6){&#13;
            result = result + 30;&#13;
        }&#13;
&#13;
        if (_randam4 &gt; 0 &amp;&amp; _randam4 &lt;4){&#13;
            result = result + 1;&#13;
        } else if (_randam4 &gt; 3 &amp;&amp; _randam4 &lt;7){&#13;
            result = result + 2;&#13;
        } else if (_randam4 &gt; 6){&#13;
            result = result + 3;&#13;
        }&#13;
&#13;
        return result;&#13;
    }&#13;
&#13;
&#13;
    function mintEtherBro () public {&#13;
        _createEtherBro(_gensGenerate(),msg.sender);&#13;
    }&#13;
&#13;
    function mintPromoEtherBro (uint16 _gens) public onlyOwner {&#13;
        uint16 _promoGens = prefix * 10000 + _gens;&#13;
        _createEtherBro(_promoGens, msg.sender);&#13;
    }&#13;
&#13;
    function rand() internal returns (uint8){&#13;
        nonce++;&#13;
        return uint8(uint256(keccak256(nonce))%10);&#13;
    }&#13;
&#13;
    function myEtherBros(address _owner) public view returns (uint256[]) {&#13;
        return ownedTokens[_owner];&#13;
    }&#13;
&#13;
    function myEtherBrosCount(address _owner) public view returns (uint256) {&#13;
        return ownedTokensCount[_owner];&#13;
    }&#13;
&#13;
    function returnIdImage(uint32 _id) public view returns (uint32, string){&#13;
        return (_id, tokenImage[_id]);&#13;
    }&#13;
&#13;
&#13;
//  function addEtherBroAuction(uint256 _tokenId, uint128 _price) public returns (bool) {&#13;
    function addEtherBroAuction(uint256 _tokenId, uint128 _price) public {&#13;
        require(ownerOf(_tokenId) == msg.sender);&#13;
        require(tokenIdToAuction[_tokenId].seller == address(0));&#13;
        require(_price &gt;= 0);&#13;
&#13;
        Auction memory _auction = Auction(msg.sender, _price);&#13;
        tokenIdToAuction[_tokenId] = _auction;&#13;
&#13;
        approve(address(this), _tokenId);&#13;
        transferFrom(msg.sender, address(this), _tokenId);&#13;
&#13;
        AuctionCreated(uint256(_tokenId), uint256(_auction.price));&#13;
&#13;
    }&#13;
&#13;
    function cancelEtherBroAuction(uint256 _tokenId) public {&#13;
        require(tokenIdToAuction[_tokenId].seller == msg.sender);&#13;
        this.transferFrom(address(this), tokenIdToAuction[_tokenId].seller, _tokenId);&#13;
        delete tokenIdToAuction[_tokenId];&#13;
        AuctionCancelled(_tokenId);&#13;
    }&#13;
&#13;
    function purchase(uint256 _tokenId) public payable {&#13;
        require(tokenIdToAuction[_tokenId].seller != address(0));&#13;
        require(tokenIdToAuction[_tokenId].seller != msg.sender);&#13;
        require(tokenIdToAuction[_tokenId].price == msg.value);&#13;
&#13;
        Auction memory auction = tokenIdToAuction[_tokenId];&#13;
&#13;
        if (auction.price &gt; 0) {&#13;
            uint128 actualOwnerCut = _computeOwnerCut(auction.price);&#13;
            uint128 proceeds = auction.price - actualOwnerCut;&#13;
            auction.seller.transfer(proceeds);&#13;
        }&#13;
        delete tokenIdToAuction[_tokenId];&#13;
        this.transferFrom(address(this), msg.sender, _tokenId);&#13;
        AuctionSuccessful(_tokenId, auction.price, msg.sender);&#13;
    }&#13;
&#13;
    /*** Tools ***/&#13;
    function _computeOwnerCut(uint128 _price) internal view returns (uint128) {&#13;
        return _price * ownerCut / 10000;&#13;
    }&#13;
&#13;
}