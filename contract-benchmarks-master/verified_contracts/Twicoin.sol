pragma solidity ^0.4.21;

// File: contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
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

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

// File: contracts/token/ERC721/ERC721Basic.sol

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

// File: contracts/token/ERC721/ERC721.sol

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

// File: contracts/AddressUtils.sol

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

// File: contracts/math/SafeMath.sol

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

// File: contracts/token/ERC721/ERC721Receiver.sol

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

// File: contracts/token/ERC721/ERC721BasicToken.sol

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

// File: contracts/token/ERC721/ERC721Token.sol

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

// File: contracts/token/ERC721/strings.sol

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="99f8ebf8faf1f7f0fdd9f7f6edfdf6edb7f7fced">[email protected]</a>&gt;&#13;
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
pragma solidity ^0.4.14;&#13;
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
// File: contracts/token/ERC721/TwitterCoin.sol&#13;
&#13;
/**&#13;
 * @title ERC721 Non-Fungible Token&#13;
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md&#13;
 */&#13;
contract Twicoin is ERC721Token, Ownable {&#13;
    using strings for *;&#13;
    using SafeMath for uint256;&#13;
&#13;
    constructor(string _name, string _symbol) public ERC721Token(_name, _symbol) {}&#13;
&#13;
    address internal signer;&#13;
    string internal baseUri;&#13;
&#13;
    function mint(uint _twitterId, uint _price, string _len, uint8 _v, bytes32 _r, bytes32 _s) external payable {&#13;
        require(!exists(_twitterId));&#13;
        require(msg.value &gt;= _price);&#13;
        require(verify(_twitterId, _price, _len,  _v, _r, _s));&#13;
&#13;
        super._mint(msg.sender, _twitterId);&#13;
    }&#13;
&#13;
    function burn(uint256 _tokenId) external onlyOwnerOf(_tokenId) {&#13;
        super._burn(msg.sender, _tokenId);&#13;
    }&#13;
&#13;
    function tokenURI(uint256 _tokenId) public view returns (string) {&#13;
        require(exists(_tokenId));&#13;
        return baseUri.toSlice().concat(uintToBytes(_tokenId).toSliceB32());&#13;
    }&#13;
&#13;
    function withdraw() external onlyOwner {&#13;
        owner.transfer(address(this).balance);&#13;
    }&#13;
&#13;
    function setBaseUri(string _uri) external onlyOwner {&#13;
        baseUri = _uri;&#13;
    }&#13;
&#13;
    function seSigner(address _signer) external onlyOwner {&#13;
        signer = _signer;&#13;
    }&#13;
&#13;
    function getToken(uint _index) external view returns (uint twitterId, address owner){&#13;
        require(_index &lt; totalSupply()); &#13;
        return (allTokens[_index], ownerOf(allTokens[_index]));&#13;
    }&#13;
&#13;
    function verify(uint _tokenId, uint _price, string _len, uint8 v, bytes32 r, bytes32 s) private view returns (bool) {&#13;
&#13;
        string memory header = "\x19Ethereum Signed Message:\n";&#13;
        header = header.toSlice().concat(_len.toSlice());&#13;
        &#13;
        string memory message = uintToBytes(_tokenId).toSliceB32().concat(" ".toSlice());&#13;
        message = message.toSlice().concat(uintToBytes(_price).toSliceB32());&#13;
        &#13;
        bytes32 check = keccak256(header, message);&#13;
&#13;
        return (signer == ecrecover(check, v, r, s));&#13;
    }&#13;
&#13;
    function uintToBytes(uint v) private pure returns (bytes32 ret) {&#13;
        if (v == 0) {&#13;
            ret = '0';&#13;
        }&#13;
        else {&#13;
            while (v &gt; 0) {&#13;
                ret = bytes32(uint(ret) / (2 ** 8));&#13;
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));&#13;
                v /= 10;&#13;
            }&#13;
        }&#13;
        return ret;&#13;
    }&#13;
}