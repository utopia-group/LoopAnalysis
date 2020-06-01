pragma solidity ^0.4.22;

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

/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {
  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}

/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface ERC165 {

  /**
   * @notice Query if a contract implements an interface
   * @param _interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic is ERC165 {

  bytes4 internal constant InterfaceId_ERC721 = 0x80ac58cd;
  /*
   * 0x80ac58cd ===
   *   bytes4(keccak256('balanceOf(address)')) ^
   *   bytes4(keccak256('ownerOf(uint256)')) ^
   *   bytes4(keccak256('approve(address,uint256)')) ^
   *   bytes4(keccak256('getApproved(uint256)')) ^
   *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^
   *   bytes4(keccak256('isApprovedForAll(address,address)')) ^
   *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
   */

  bytes4 internal constant InterfaceId_ERC721Enumerable = 0x780e9d63;
  /**
   * 0x780e9d63 ===
   *   bytes4(keccak256('totalSupply()')) ^
   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
   *   bytes4(keccak256('tokenByIndex(uint256)'))
   */

  bytes4 internal constant InterfaceId_ERC721Metadata = 0x5b5e139f;
  /**
   * 0x5b5e139f ===
   *   bytes4(keccak256('name()')) ^
   *   bytes4(keccak256('symbol()')) ^
   *   bytes4(keccak256('tokenURI(uint256)'))
   */

  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);

  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId)
    public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public;
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256 _tokenId);

  function tokenByIndex(uint256 _index) public view returns (uint256);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
  function name() external view returns (string _name);
  function symbol() external view returns (string _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

/**
 * @title SupportsInterfaceWithLookup
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract SupportsInterfaceWithLookup is ERC165 {

  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
  /**
   * 0x01ffc9a7 ===
   *   bytes4(keccak256('supportsInterface(bytes4)'))
   */

  /**
   * @dev a mapping of interface id to whether or not it's supported
   */
  mapping(bytes4 => bool) internal supportedInterfaces;

  /**
   * @dev A contract implementing SupportsInterfaceWithLookup
   * implement ERC165 itself
   */
  constructor()
    public
  {
    _registerInterface(InterfaceId_ERC165);
  }

  /**
   * @dev implement supportsInterface(bytes4) using a lookup table
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceId];
  }

  /**
   * @dev private method for registering an interface
   */
  function _registerInterface(bytes4 _interfaceId)
    internal
  {
    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

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

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param _account address of the account to check
   * @return whether the target address is a contract
   */
  function isContract(address _account) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(_account) }
    return size > 0;
  }

}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   * after a `safetransfer`. This function MAY throw to revert and reject the
   * transfer. Return of other than the magic value MUST result in the
   * transaction being reverted.
   * Note: the contract address is always the message sender.
   * @param _operator The address which called `safeTransferFrom` function
   * @param _from The address which previously owned the token
   * @param _tokenId The NFT identifier which is being transferred
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
   */
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes _data
  )
    public
    returns(bytes4);
}

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721BasicToken is SupportsInterfaceWithLookup, ERC721Basic {

  using SafeMath for uint256;
  using AddressUtils for address;

  // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  constructor()
    public
  {
    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(InterfaceId_ERC721);
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
   * @dev Approves another address to transfer the given token ID
   * The zero address indicates there is no approved address.
   * There can only be one approved address per token at a given time.
   * Can only be called by the token owner or an approved operator.
   * @param _to address to be approved for the given token ID
   * @param _tokenId uint256 ID of the token to be approved
   */
  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    tokenApprovals[_tokenId] = _to;
    emit Approval(owner, _to, _tokenId);
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }

  /**
   * @dev Sets or unsets the approval of a given operator
   * An operator is allowed to transfer all tokens of the sender on their behalf
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
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    public
    view
    returns (bool)
  {
    return operatorApprovals[_owner][_operator];
  }

  /**
   * @dev Transfers the ownership of a given token ID to another address
   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
  {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);

    emit Transfer(_from, _to, _tokenId);
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   *
   * Requires the msg sender to be the owner, approved, or operator
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
  {
    // solium-disable-next-line arg-overflow
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   * Requires the msg sender to be the owner, approved, or operator
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
  {
    transferFrom(_from, _to, _tokenId);
    // solium-disable-next-line arg-overflow
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  /**
   * @dev Returns whether the specified token exists
   * @param _tokenId uint256 ID of the token to query the existence of
   * @return whether the token exists
   */
  function _exists(uint256 _tokenId) internal view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function isApprovedOrOwner(
    address _spender,
    uint256 _tokenId
  )
    internal
    view
    returns (bool)
  {
    address owner = ownerOf(_tokenId);
    // Disable solium check because of
    // https://github.com/duaraghav8/Solium/issues/175
    // solium-disable-next-line operator-whitespace
    return (
      _spender == owner ||
      getApproved(_tokenId) == _spender ||
      isApprovedForAll(owner, _spender)
    );
  }

  /**
   * @dev Internal function to mint a new token
   * Reverts if the given token ID already exists
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
   * Reverts if the token does not exist
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    emit Transfer(_owner, address(0), _tokenId);
  }

  /**
   * @dev Internal function to clear current approval of a given token ID
   * Reverts if the given address is not indeed the owner of the token
   * @param _owner owner of the token
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
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
   * The call is not executed if the target address is not a contract
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
    bytes4 retval = ERC721Receiver(_to).onERC721Received(
      msg.sender, _from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}

/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Token is SupportsInterfaceWithLookup, ERC721BasicToken, ERC721 {

  // Token name
  string internal name_;

  // Token symbol
  string internal symbol_;

  // Mapping from owner to list of owned token IDs
  mapping(address => uint256[]) internal ownedTokens;

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
  constructor(string _name, string _symbol) public {
    name_ = _name;
    symbol_ = _symbol;

    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(InterfaceId_ERC721Enumerable);
    _registerInterface(InterfaceId_ERC721Metadata);
  }

  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() external view returns (string) {
    return name_;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function symbol() external view returns (string) {
    return symbol_;
  }

  /**
   * @dev Returns an URI for a given token ID
   * Throws if the token ID does not exist. May return an empty string.
   * @param _tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 _tokenId) public view returns (string) {
    require(_exists(_tokenId));
    return tokenURIs[_tokenId];
  }

  /**
   * @dev Gets the token ID at a given index of the tokens list of the requested owner
   * @param _owner address owning the tokens list to be accessed
   * @param _index uint256 representing the index to be accessed of the requested tokens list
   * @return uint256 token ID at the given index of the tokens list owned by the requested address
   */
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256)
  {
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
   * Reverts if the index is greater or equal to the total number of tokens
   * @param _index uint256 representing the index to be accessed of the tokens list
   * @return uint256 token ID at the given index of the tokens list
   */
  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

  /**
   * @dev Internal function to set the token URI for a given token
   * Reverts if the token ID does not exist
   * @param _tokenId uint256 ID of the token to set its URI
   * @param _uri string URI to assign
   */
  function _setTokenURI(uint256 _tokenId, string _uri) internal {
    require(_exists(_tokenId));
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

    // To prevent a gap in the array, we store the last token in the index of the token to delete, and
    // then delete the last slot.
    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    // This also deletes the contents at the last position of the array
    ownedTokens[_from].length--;

    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  /**
   * @dev Internal function to mint a new token
   * Reverts if the given token ID already exists
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
   * Reverts if the token does not exist
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



/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ea8b988b898284838eaa84859e8e859ec4848f9e">[email protected]</a>&gt;&#13;
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
    function toSlice(string memory self) internal pure returns (slice memory) {&#13;
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
    function toSliceB32(bytes32 self) internal pure returns (slice memory ret) {&#13;
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
    function copy(slice memory self) internal pure returns (slice memory) {&#13;
        return slice(self._len, self._ptr);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Copies a slice to a new string.&#13;
     * @param self The slice to copy.&#13;
     * @return A newly allocated string containing the slice's text.&#13;
     */&#13;
    function toString(slice memory self) internal pure returns (string memory) {&#13;
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
    function len(slice memory self) internal pure returns (uint l) {&#13;
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
    function empty(slice memory self) internal pure returns (bool) {&#13;
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
    function compare(slice memory self, slice memory other) internal pure returns (int) {&#13;
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
    function equals(slice memory self, slice memory other) internal pure returns (bool) {&#13;
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
    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {&#13;
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
    function nextRune(slice memory self) internal pure returns (slice memory ret) {&#13;
        nextRune(self, ret);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns the number of the first codepoint in the slice.&#13;
     * @param self The slice to operate on.&#13;
     * @return The number of the first codepoint in the slice.&#13;
     */&#13;
    function ord(slice memory self) internal pure returns (uint ret) {&#13;
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
    function keccak(slice memory self) internal pure returns (bytes32 ret) {&#13;
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
    function startsWith(slice memory self, slice memory needle) internal pure returns (bool) {&#13;
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
    function beyond(slice memory self, slice memory needle) internal pure returns (slice memory) {&#13;
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
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))&#13;
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
    function endsWith(slice memory self, slice memory needle) internal pure returns (bool) {&#13;
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
    function until(slice memory self, slice memory needle) internal pure returns (slice memory) {&#13;
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
                assembly { hash := keccak256(needleptr, needlelen) }&#13;
&#13;
                for (idx = 0; idx &lt;= selflen - needlelen; idx++) {&#13;
                    bytes32 testHash;&#13;
                    assembly { testHash := keccak256(ptr, needlelen) }&#13;
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
                assembly { hash := keccak256(needleptr, needlelen) }&#13;
                ptr = selfptr + (selflen - needlelen);&#13;
                while (ptr &gt;= selfptr) {&#13;
                    bytes32 testHash;&#13;
                    assembly { testHash := keccak256(ptr, needlelen) }&#13;
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
    function find(slice memory self, slice memory needle) internal pure returns (slice memory) {&#13;
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
    function rfind(slice memory self, slice memory needle) internal pure returns (slice memory) {&#13;
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
    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {&#13;
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
    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {&#13;
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
    function rsplit(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {&#13;
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
    function rsplit(slice memory self, slice memory needle) internal pure returns (slice memory token) {&#13;
        rsplit(self, needle, token);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.&#13;
     * @param self The slice to search.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @return The number of occurrences of `needle` found in `self`.&#13;
     */&#13;
    function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {&#13;
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
    function contains(slice memory self, slice memory needle) internal pure returns (bool) {&#13;
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
    function concat(slice memory self, slice memory other) internal pure returns (string memory) {&#13;
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
    function join(slice memory self, slice[] memory parts) internal pure returns (string memory) {&#13;
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
contract CarFactory is Ownable {&#13;
    using strings for *;&#13;
&#13;
    uint256 public constant MAX_CARS = 30000 + 150000 + 1000000;&#13;
    uint256 public mintedCars = 0;&#13;
    address preOrderAddress;&#13;
    CarToken token;&#13;
&#13;
    mapping(uint256 =&gt; uint256) public tankSizes;&#13;
    mapping(uint256 =&gt; uint) public savedTypes;&#13;
    mapping(uint256 =&gt; bool) public giveawayCar;&#13;
    &#13;
    mapping(uint =&gt; uint256[]) public availableIds;&#13;
    mapping(uint =&gt; uint256) public idCursor;&#13;
&#13;
    event CarMinted(uint256 _tokenId, string _metadata, uint cType);&#13;
    event CarSellingBeings();&#13;
&#13;
&#13;
&#13;
    modifier onlyPreOrder {&#13;
        require(msg.sender == preOrderAddress, "Not authorized");&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isInitialized {&#13;
        require(preOrderAddress != address(0), "No linked preorder");&#13;
        require(address(token) != address(0), "No linked token");&#13;
        _;&#13;
    }&#13;
&#13;
    function uintToString(uint v) internal pure returns (string) {&#13;
        uint maxlength = 100;&#13;
        bytes memory reversed = new bytes(maxlength);&#13;
        uint i = 0;&#13;
        while (v != 0) {&#13;
            uint remainder = v % 10;&#13;
            v = v / 10;&#13;
            reversed[i++] = byte(48 + remainder);&#13;
        }&#13;
        bytes memory s = new bytes(i); // i + 1 is inefficient&#13;
        for (uint j = 0; j &lt; i; j++) {&#13;
            s[j] = reversed[i - j - 1]; // to avoid the off-by-one error&#13;
        }&#13;
        string memory str = string(s);  // memory isn't implicitly convertible to storage&#13;
        return str; // this was missing&#13;
    }&#13;
&#13;
    function mintFor(uint cType, address newOwner) public onlyPreOrder isInitialized returns (uint256) {&#13;
        require(mintedCars &lt; MAX_CARS, "Factory has minted the max number of cars");&#13;
        &#13;
        uint256 _tokenId = nextAvailableId(cType);&#13;
        require(!token.exists(_tokenId), "Token already exists");&#13;
&#13;
        string memory id = uintToString(_tokenId).toSlice().concat(".json".toSlice());&#13;
&#13;
        uint256 tankSize = tankSizes[_tokenId];&#13;
        string memory _metadata = "https://vault.warriders.com/".toSlice().concat(id.toSlice());&#13;
&#13;
        token.mint(_tokenId, _metadata, cType, tankSize, newOwner);&#13;
        mintedCars++;&#13;
        &#13;
        return _tokenId;&#13;
    }&#13;
&#13;
    function giveaway(uint256 _tokenId, uint256 _tankSize, uint cType, bool markCar, address dst) public onlyOwner isInitialized {&#13;
        require(dst != address(0), "No destination address given");&#13;
        require(!token.exists(_tokenId), "Token already exists");&#13;
        require(dst != owner);&#13;
        require(dst != address(this));&#13;
        require(_tankSize &lt;= token.maxTankSizes(cType));&#13;
            &#13;
        tankSizes[_tokenId] = _tankSize;&#13;
        savedTypes[_tokenId] = cType;&#13;
&#13;
        string memory id = uintToString(_tokenId).toSlice().concat(".json".toSlice());&#13;
        string memory _metadata = "https://vault.warriders.com/".toSlice().concat(id.toSlice());&#13;
&#13;
        token.mint(_tokenId, _metadata, cType, _tankSize, dst);&#13;
        mintedCars++;&#13;
&#13;
        giveawayCar[_tokenId] = markCar;&#13;
    }&#13;
&#13;
    function setTokenMeta(uint256[] _tokenIds, uint256[] ts, uint[] cTypes) public onlyOwner isInitialized {&#13;
        for (uint i = 0; i &lt; _tokenIds.length; i++) {&#13;
            uint256 _tokenId = _tokenIds[i];&#13;
            uint cType = cTypes[i];&#13;
            uint256 _tankSize = ts[i];&#13;
&#13;
            require(_tankSize &lt;= token.maxTankSizes(cType));&#13;
            &#13;
            tankSizes[_tokenId] = _tankSize;&#13;
            savedTypes[_tokenId] = cType;&#13;
            &#13;
            &#13;
            availableIds[cTypes[i]].push(_tokenId);&#13;
        }&#13;
    }&#13;
    &#13;
    function nextAvailableId(uint cType) private returns (uint256) {&#13;
        uint256 currentCursor = idCursor[cType];&#13;
        &#13;
        require(currentCursor &lt; availableIds[cType].length);&#13;
        &#13;
        uint256 nextId = availableIds[cType][currentCursor];&#13;
        idCursor[cType] = currentCursor + 1;&#13;
        return nextId;&#13;
    }&#13;
&#13;
    /**&#13;
    Attach the preOrder that will be receiving tokens being marked for sale by the&#13;
    sellCar function&#13;
    */&#13;
    function attachPreOrder(address dst) public onlyOwner {&#13;
        require(preOrderAddress == address(0));&#13;
        require(dst != address(0));&#13;
&#13;
        //Enforce that address is indeed a preorder&#13;
        PreOrder preOrder = PreOrder(dst);&#13;
&#13;
        preOrderAddress = address(preOrder);&#13;
    }&#13;
&#13;
    /**&#13;
    Attach the token being used for things&#13;
    */&#13;
    function attachToken(address dst) public onlyOwner {&#13;
        require(address(token) == address(0));&#13;
        require(dst != address(0));&#13;
&#13;
        //Enforce that address is indeed a preorder&#13;
        CarToken ct = CarToken(dst);&#13;
&#13;
        token = ct;&#13;
    }&#13;
}&#13;
&#13;
contract CarToken is ERC721Token, Ownable {&#13;
    using strings for *;&#13;
    &#13;
    address factory;&#13;
&#13;
    /*&#13;
    * Car Types:&#13;
    * 0 - Unknown&#13;
    * 1 - SUV&#13;
    * 2 - Truck&#13;
    * 3 - Hovercraft&#13;
    * 4 - Tank&#13;
    * 5 - Lambo&#13;
    * 6 - Buggy&#13;
    * 7 - midgrade type 2&#13;
    * 8 - midgrade type 3&#13;
    * 9 - Hatchback&#13;
    * 10 - regular type 2&#13;
    * 11 - regular type 3&#13;
    */&#13;
    uint public constant UNKNOWN_TYPE = 0;&#13;
    uint public constant SUV_TYPE = 1;&#13;
    uint public constant TANKER_TYPE = 2;&#13;
    uint public constant HOVERCRAFT_TYPE = 3;&#13;
    uint public constant TANK_TYPE = 4;&#13;
    uint public constant LAMBO_TYPE = 5;&#13;
    uint public constant DUNE_BUGGY = 6;&#13;
    uint public constant MIDGRADE_TYPE2 = 7;&#13;
    uint public constant MIDGRADE_TYPE3 = 8;&#13;
    uint public constant HATCHBACK = 9;&#13;
    uint public constant REGULAR_TYPE2 = 10;&#13;
    uint public constant REGULAR_TYPE3 = 11;&#13;
    &#13;
    string public constant METADATA_URL = "https://vault.warriders.com/";&#13;
    &#13;
    //Number of premium type cars&#13;
    uint public PREMIUM_TYPE_COUNT = 5;&#13;
    //Number of midgrade type cars&#13;
    uint public MIDGRADE_TYPE_COUNT = 3;&#13;
    //Number of regular type cars&#13;
    uint public REGULAR_TYPE_COUNT = 3;&#13;
&#13;
    mapping(uint256 =&gt; uint256) public maxBznTankSizeOfPremiumCarWithIndex;&#13;
    mapping(uint256 =&gt; uint256) public maxBznTankSizeOfMidGradeCarWithIndex;&#13;
    mapping(uint256 =&gt; uint256) public maxBznTankSizeOfRegularCarWithIndex;&#13;
&#13;
    /**&#13;
     * Whether any given car (tokenId) is special&#13;
     */&#13;
    mapping(uint256 =&gt; bool) public isSpecial;&#13;
    /**&#13;
     * The type of any given car (tokenId)&#13;
     */&#13;
    mapping(uint256 =&gt; uint) public carType;&#13;
    /**&#13;
     * The total supply for any given type (int)&#13;
     */&#13;
    mapping(uint =&gt; uint256) public carTypeTotalSupply;&#13;
    /**&#13;
     * The current supply for any given type (int)&#13;
     */&#13;
    mapping(uint =&gt; uint256) public carTypeSupply;&#13;
    /**&#13;
     * Whether any given type (int) is special&#13;
     */&#13;
    mapping(uint =&gt; bool) public isTypeSpecial;&#13;
&#13;
    /**&#13;
    * How much BZN any given car (tokenId) can hold&#13;
    */&#13;
    mapping(uint256 =&gt; uint256) public tankSizes;&#13;
    &#13;
    /**&#13;
     * Given any car type (uint), get the max tank size for that type (uint256)&#13;
     */&#13;
    mapping(uint =&gt; uint256) public maxTankSizes;&#13;
    &#13;
    mapping (uint =&gt; uint[]) public premiumTotalSupplyForCar;&#13;
    mapping (uint =&gt; uint[]) public midGradeTotalSupplyForCar;&#13;
    mapping (uint =&gt; uint[]) public regularTotalSupplyForCar;&#13;
&#13;
    modifier onlyFactory {&#13;
        require(msg.sender == factory, "Not authorized");&#13;
        _;&#13;
    }&#13;
&#13;
    constructor(address factoryAddress) public ERC721Token("WarRiders", "WR") {&#13;
        factory = factoryAddress;&#13;
&#13;
        carTypeTotalSupply[UNKNOWN_TYPE] = 0; //Unknown&#13;
        carTypeTotalSupply[SUV_TYPE] = 20000; //SUV&#13;
        carTypeTotalSupply[TANKER_TYPE] = 9000; //Tanker&#13;
        carTypeTotalSupply[HOVERCRAFT_TYPE] = 600; //Hovercraft&#13;
        carTypeTotalSupply[TANK_TYPE] = 300; //Tank&#13;
        carTypeTotalSupply[LAMBO_TYPE] = 100; //Lambo&#13;
        carTypeTotalSupply[DUNE_BUGGY] = 40000; //migrade type 1&#13;
        carTypeTotalSupply[MIDGRADE_TYPE2] = 50000; //midgrade type 2&#13;
        carTypeTotalSupply[MIDGRADE_TYPE3] = 60000; //midgrade type 3&#13;
        carTypeTotalSupply[HATCHBACK] = 200000; //regular type 1&#13;
        carTypeTotalSupply[REGULAR_TYPE2] = 300000; //regular type 2&#13;
        carTypeTotalSupply[REGULAR_TYPE3] = 500000; //regular type 3&#13;
        &#13;
        maxTankSizes[SUV_TYPE] = 200; //SUV tank size&#13;
        maxTankSizes[TANKER_TYPE] = 450; //Tanker tank size&#13;
        maxTankSizes[HOVERCRAFT_TYPE] = 300; //Hovercraft tank size&#13;
        maxTankSizes[TANK_TYPE] = 200; //Tank tank size&#13;
        maxTankSizes[LAMBO_TYPE] = 250; //Lambo tank size&#13;
        maxTankSizes[DUNE_BUGGY] = 120; //migrade type 1 tank size&#13;
        maxTankSizes[MIDGRADE_TYPE2] = 110; //midgrade type 2 tank size&#13;
        maxTankSizes[MIDGRADE_TYPE3] = 100; //midgrade type 3 tank size&#13;
        maxTankSizes[HATCHBACK] = 90; //regular type 1 tank size&#13;
        maxTankSizes[REGULAR_TYPE2] = 70; //regular type 2 tank size&#13;
        maxTankSizes[REGULAR_TYPE3] = 40; //regular type 3 tank size&#13;
        &#13;
        maxBznTankSizeOfPremiumCarWithIndex[1] = 200; //SUV tank size&#13;
        maxBznTankSizeOfPremiumCarWithIndex[2] = 450; //Tanker tank size&#13;
        maxBznTankSizeOfPremiumCarWithIndex[3] = 300; //Hovercraft tank size&#13;
        maxBznTankSizeOfPremiumCarWithIndex[4] = 200; //Tank tank size&#13;
        maxBznTankSizeOfPremiumCarWithIndex[5] = 250; //Lambo tank size&#13;
        maxBznTankSizeOfMidGradeCarWithIndex[1] = 100; //migrade type 1 tank size&#13;
        maxBznTankSizeOfMidGradeCarWithIndex[2] = 110; //midgrade type 2 tank size&#13;
        maxBznTankSizeOfMidGradeCarWithIndex[3] = 120; //midgrade type 3 tank size&#13;
        maxBznTankSizeOfRegularCarWithIndex[1] = 40; //regular type 1 tank size&#13;
        maxBznTankSizeOfRegularCarWithIndex[2] = 70; //regular type 2 tank size&#13;
        maxBznTankSizeOfRegularCarWithIndex[3] = 90; //regular type 3 tank size&#13;
&#13;
        isTypeSpecial[HOVERCRAFT_TYPE] = true;&#13;
        isTypeSpecial[TANK_TYPE] = true;&#13;
        isTypeSpecial[LAMBO_TYPE] = true;&#13;
    }&#13;
&#13;
    function isCarSpecial(uint256 tokenId) public view returns (bool) {&#13;
        return isSpecial[tokenId];&#13;
    }&#13;
&#13;
    function getCarType(uint256 tokenId) public view returns (uint) {&#13;
        return carType[tokenId];&#13;
    }&#13;
&#13;
    function mint(uint256 _tokenId, string _metadata, uint cType, uint256 tankSize, address newOwner) public onlyFactory {&#13;
        //Since any invalid car type would have a total supply of 0 &#13;
        //This require will also enforce that a valid cType is given&#13;
        require(carTypeSupply[cType] &lt; carTypeTotalSupply[cType], "This type has reached total supply");&#13;
        &#13;
        //This will enforce the tank size is less than the max&#13;
        require(tankSize &lt;= maxTankSizes[cType], "Tank size provided bigger than max for this type");&#13;
        &#13;
        if (isPremium(cType)) {&#13;
            premiumTotalSupplyForCar[cType].push(_tokenId);&#13;
        } else if (isMidGrade(cType)) {&#13;
            midGradeTotalSupplyForCar[cType].push(_tokenId);&#13;
        } else {&#13;
            regularTotalSupplyForCar[cType].push(_tokenId);&#13;
        }&#13;
&#13;
        super._mint(newOwner, _tokenId);&#13;
        super._setTokenURI(_tokenId, _metadata);&#13;
&#13;
        carType[_tokenId] = cType;&#13;
        isSpecial[_tokenId] = isTypeSpecial[cType];&#13;
        carTypeSupply[cType] = carTypeSupply[cType] + 1;&#13;
        tankSizes[_tokenId] = tankSize;&#13;
    }&#13;
    &#13;
    function isPremium(uint cType) public pure returns (bool) {&#13;
        return cType == SUV_TYPE || cType == TANKER_TYPE || cType == HOVERCRAFT_TYPE || cType == TANK_TYPE || cType == LAMBO_TYPE;&#13;
    }&#13;
    &#13;
    function isMidGrade(uint cType) public pure returns (bool) {&#13;
        return cType == DUNE_BUGGY || cType == MIDGRADE_TYPE2 || cType == MIDGRADE_TYPE3;&#13;
    }&#13;
    &#13;
    function isRegular(uint cType) public pure returns (bool) {&#13;
        return cType == HATCHBACK || cType == REGULAR_TYPE2 || cType == REGULAR_TYPE3;&#13;
    }&#13;
    &#13;
    function getTotalSupplyForType(uint cType) public view returns (uint256) {&#13;
        return carTypeSupply[cType];&#13;
    }&#13;
    &#13;
    function getPremiumCarsForVariant(uint variant) public view returns (uint[]) {&#13;
        return premiumTotalSupplyForCar[variant];&#13;
    }&#13;
    &#13;
    function getMidgradeCarsForVariant(uint variant) public view returns (uint[]) {&#13;
        return midGradeTotalSupplyForCar[variant];&#13;
    }&#13;
&#13;
    function getRegularCarsForVariant(uint variant) public view returns (uint[]) {&#13;
        return regularTotalSupplyForCar[variant];&#13;
    }&#13;
&#13;
    function getPremiumCarSupply(uint variant) public view returns (uint) {&#13;
        return premiumTotalSupplyForCar[variant].length;&#13;
    }&#13;
    &#13;
    function getMidgradeCarSupply(uint variant) public view returns (uint) {&#13;
        return midGradeTotalSupplyForCar[variant].length;&#13;
    }&#13;
&#13;
    function getRegularCarSupply(uint variant) public view returns (uint) {&#13;
        return regularTotalSupplyForCar[variant].length;&#13;
    }&#13;
    &#13;
    function exists(uint256 _tokenId) public view returns (bool) {&#13;
        return super._exists(_tokenId);&#13;
    }&#13;
}&#13;
&#13;
contract PreOrder is Destructible {&#13;
    /**&#13;
     * The current price for any given type (int)&#13;
     */&#13;
    mapping(uint =&gt; uint256) public currentTypePrice;&#13;
&#13;
    // Maps Premium car variants to the tokens minted for their description&#13;
    // INPUT: variant #&#13;
    // OUTPUT: list of cars&#13;
    mapping(uint =&gt; uint256[]) public premiumCarsBought;&#13;
    mapping(uint =&gt; uint256[]) public midGradeCarsBought;&#13;
    mapping(uint =&gt; uint256[]) public regularCarsBought;&#13;
    mapping(uint256 =&gt; address) public tokenReserve;&#13;
&#13;
    event consumerBulkBuy(uint256[] variants, address reserver, uint category);&#13;
    event CarBought(uint256 carId, uint256 value, address purchaser, uint category);&#13;
    event Withdrawal(uint256 amount);&#13;
&#13;
    uint256 public constant COMMISSION_PERCENT = 5;&#13;
&#13;
    //Max number of premium cars&#13;
    uint256 public constant MAX_PREMIUM = 30000;&#13;
    //Max number of midgrade cars&#13;
    uint256 public constant MAX_MIDGRADE = 150000;&#13;
    //Max number of regular cars&#13;
    uint256 public constant MAX_REGULAR = 1000000;&#13;
&#13;
    //Max number of premium type cars&#13;
    uint public PREMIUM_TYPE_COUNT = 5;&#13;
    //Max number of midgrade type cars&#13;
    uint public MIDGRADE_TYPE_COUNT = 3;&#13;
    //Max number of regular type cars&#13;
    uint public REGULAR_TYPE_COUNT = 3;&#13;
&#13;
    uint private midgrade_offset = 5;&#13;
    uint private regular_offset = 6;&#13;
&#13;
    uint256 public constant GAS_REQUIREMENT = 250000;&#13;
&#13;
    //Premium type id&#13;
    uint public constant PREMIUM_CATEGORY = 1;&#13;
    //Midgrade type id&#13;
    uint public constant MID_GRADE_CATEGORY = 2;&#13;
    //Regular type id&#13;
    uint public constant REGULAR_CATEGORY = 3;&#13;
    &#13;
    mapping(address =&gt; uint256) internal commissionRate;&#13;
    &#13;
    address internal constant OPENSEA = 0x5b3256965e7C3cF26E11FCAf296DfC8807C01073;&#13;
&#13;
    //The percent increase for any given type&#13;
    mapping(uint =&gt; uint256) internal percentIncrease;&#13;
    mapping(uint =&gt; uint256) internal percentBase;&#13;
    //uint public constant PERCENT_INCREASE = 101;&#13;
&#13;
    //How many car is in each category currently&#13;
    uint256 public premiumHold = 30000;&#13;
    uint256 public midGradeHold = 150000;&#13;
    uint256 public regularHold = 1000000;&#13;
&#13;
    bool public premiumOpen = false;&#13;
    bool public midgradeOpen = false;&#13;
    bool public regularOpen = false;&#13;
&#13;
    //Reference to other contracts&#13;
    CarToken public token;&#13;
    //AuctionManager public auctionManager;&#13;
    CarFactory internal factory;&#13;
&#13;
    address internal escrow;&#13;
&#13;
    modifier premiumIsOpen {&#13;
        //Ensure we are selling at least 1 car&#13;
        require(premiumHold &gt; 0, "No more premium cars");&#13;
        require(premiumOpen, "Premium store not open for sale");&#13;
        _;&#13;
    }&#13;
&#13;
    modifier midGradeIsOpen {&#13;
        //Ensure we are selling at least 1 car&#13;
        require(midGradeHold &gt; 0, "No more midgrade cars");&#13;
        require(midgradeOpen, "Midgrade store not open for sale");&#13;
        _;&#13;
    }&#13;
&#13;
    modifier regularIsOpen {&#13;
        //Ensure we are selling at least 1 car&#13;
        require(regularHold &gt; 0, "No more regular cars");&#13;
        require(regularOpen, "Regular store not open for sale");&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyFactory {&#13;
        //Only factory can use this function&#13;
        require(msg.sender == address(factory), "Not authorized");&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyFactoryOrOwner {&#13;
        //Only factory or owner can use this function&#13;
        require(msg.sender == address(factory) || msg.sender == owner, "Not authorized");&#13;
        _;&#13;
    }&#13;
&#13;
    function() public payable { }&#13;
&#13;
    constructor(&#13;
        address tokenAddress,&#13;
        address tokenFactory,&#13;
        address e&#13;
    ) public {&#13;
        token = CarToken(tokenAddress);&#13;
&#13;
        factory = CarFactory(tokenFactory);&#13;
&#13;
        escrow = e;&#13;
&#13;
        //Set percent increases&#13;
        percentIncrease[1] = 100008;&#13;
        percentBase[1] = 100000;&#13;
        percentIncrease[2] = 100015;&#13;
        percentBase[2] = 100000;&#13;
        percentIncrease[3] = 1002;&#13;
        percentBase[3] = 1000;&#13;
        percentIncrease[4] = 1004;&#13;
        percentBase[4] = 1000;&#13;
        percentIncrease[5] = 102;&#13;
        percentBase[5] = 100;&#13;
        &#13;
        commissionRate[OPENSEA] = 10;&#13;
    }&#13;
    &#13;
    function setCommission(address referral, uint256 percent) public onlyOwner {&#13;
        require(percent &gt; COMMISSION_PERCENT);&#13;
        require(percent &lt; 95);&#13;
        percent = percent - COMMISSION_PERCENT;&#13;
        &#13;
        commissionRate[referral] = percent;&#13;
    }&#13;
    &#13;
    function setPercentIncrease(uint256 increase, uint256 base, uint cType) public onlyOwner {&#13;
        require(increase &gt; base);&#13;
        &#13;
        percentIncrease[cType] = increase;&#13;
        percentBase[cType] = base;&#13;
    }&#13;
&#13;
    function openShop(uint category) public onlyOwner {&#13;
        require(category == 1 || category == 2 || category == 3, "Invalid category");&#13;
&#13;
        if (category == PREMIUM_CATEGORY) {&#13;
            premiumOpen = true;&#13;
        } else if (category == MID_GRADE_CATEGORY) {&#13;
            midgradeOpen = true;&#13;
        } else if (category == REGULAR_CATEGORY) {&#13;
            regularOpen = true;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Set the starting price for any given type. Can only be set once, and value must be greater than 0&#13;
     */&#13;
    function setTypePrice(uint cType, uint256 price) public onlyOwner {&#13;
        if (currentTypePrice[cType] == 0) {&#13;
            require(price &gt; 0, "Price already set");&#13;
            currentTypePrice[cType] = price;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    Withdraw the amount from the contract's balance. Only the contract owner can execute this function&#13;
    */&#13;
    function withdraw(uint256 amount) public onlyOwner {&#13;
        uint256 balance = address(this).balance;&#13;
&#13;
        require(amount &lt;= balance, "Requested to much");&#13;
        owner.transfer(amount);&#13;
&#13;
        emit Withdrawal(amount);&#13;
    }&#13;
&#13;
    function reserveManyTokens(uint[] cTypes, uint category) public payable returns (bool) {&#13;
        if (category == PREMIUM_CATEGORY) {&#13;
            require(premiumOpen, "Premium is not open for sale");&#13;
        } else if (category == MID_GRADE_CATEGORY) {&#13;
            require(midgradeOpen, "Midgrade is not open for sale");&#13;
        } else if (category == REGULAR_CATEGORY) {&#13;
            require(regularOpen, "Regular is not open for sale");&#13;
        } else {&#13;
            revert();&#13;
        }&#13;
&#13;
        address reserver = msg.sender;&#13;
&#13;
        uint256 ether_required = 0;&#13;
        for (uint i = 0; i &lt; cTypes.length; i++) {&#13;
            uint cType = cTypes[i];&#13;
&#13;
            uint256 price = priceFor(cType);&#13;
&#13;
            ether_required += (price + GAS_REQUIREMENT);&#13;
&#13;
            currentTypePrice[cType] = price;&#13;
        }&#13;
&#13;
        require(msg.value &gt;= ether_required);&#13;
&#13;
        uint256 refundable = msg.value - ether_required;&#13;
&#13;
        escrow.transfer(ether_required);&#13;
&#13;
        if (refundable &gt; 0) {&#13;
            reserver.transfer(refundable);&#13;
        }&#13;
&#13;
        emit consumerBulkBuy(cTypes, reserver, category);&#13;
    }&#13;
&#13;
     function buyBulkPremiumCar(address referal, uint[] variants, address new_owner) public payable premiumIsOpen returns (bool) {&#13;
         uint n = variants.length;&#13;
         require(n &lt;= 10, "Max bulk buy is 10 cars");&#13;
&#13;
         for (uint i = 0; i &lt; n; i++) {&#13;
             buyCar(referal, variants[i], false, new_owner, PREMIUM_CATEGORY);&#13;
         }&#13;
     }&#13;
&#13;
     function buyBulkMidGradeCar(address referal, uint[] variants, address new_owner) public payable midGradeIsOpen returns (bool) {&#13;
         uint n = variants.length;&#13;
         require(n &lt;= 10, "Max bulk buy is 10 cars");&#13;
&#13;
         for (uint i = 0; i &lt; n; i++) {&#13;
             buyCar(referal, variants[i], false, new_owner, MID_GRADE_CATEGORY);&#13;
         }&#13;
     }&#13;
&#13;
     function buyBulkRegularCar(address referal, uint[] variants, address new_owner) public payable regularIsOpen returns (bool) {&#13;
         uint n = variants.length;&#13;
         require(n &lt;= 10, "Max bulk buy is 10 cars");&#13;
&#13;
         for (uint i = 0; i &lt; n; i++) {&#13;
             buyCar(referal, variants[i], false, new_owner, REGULAR_CATEGORY);&#13;
         }&#13;
     }&#13;
&#13;
    function buyCar(address referal, uint cType, bool give_refund, address new_owner, uint category) public payable returns (bool) {&#13;
        require(category == PREMIUM_CATEGORY || category == MID_GRADE_CATEGORY || category == REGULAR_CATEGORY);&#13;
        if (category == PREMIUM_CATEGORY) {&#13;
            require(cType == 1 || cType == 2 || cType == 3 || cType == 4 || cType == 5, "Invalid car type");&#13;
            require(premiumHold &gt; 0, "No more premium cars");&#13;
            require(premiumOpen, "Premium store not open for sale");&#13;
        } else if (category == MID_GRADE_CATEGORY) {&#13;
            require(cType == 6 || cType == 7 || cType == 8, "Invalid car type");&#13;
            require(midGradeHold &gt; 0, "No more midgrade cars");&#13;
            require(midgradeOpen, "Midgrade store not open for sale");&#13;
        } else if (category == REGULAR_CATEGORY) {&#13;
            require(cType == 9 || cType == 10 || cType == 11, "Invalid car type");&#13;
            require(regularHold &gt; 0, "No more regular cars");&#13;
            require(regularOpen, "Regular store not open for sale");&#13;
        }&#13;
&#13;
        uint256 price = priceFor(cType);&#13;
        require(price &gt; 0, "Price not yet set");&#13;
        require(msg.value &gt;= price, "Not enough ether sent");&#13;
        /*if (tokenReserve[_tokenId] != address(0)) {&#13;
            require(new_owner == tokenReserve[_tokenId], "You don't have the rights to buy this token");&#13;
        }*/&#13;
        currentTypePrice[cType] = price; //Set new type price&#13;
&#13;
        uint256 _tokenId = factory.mintFor(cType, new_owner); //Now mint the token&#13;
        &#13;
        if (category == PREMIUM_CATEGORY) {&#13;
            premiumCarsBought[cType].push(_tokenId);&#13;
            premiumHold--;&#13;
        } else if (category == MID_GRADE_CATEGORY) {&#13;
            midGradeCarsBought[cType - 5].push(_tokenId);&#13;
            midGradeHold--;&#13;
        } else if (category == REGULAR_CATEGORY) {&#13;
            regularCarsBought[cType - 8].push(_tokenId);&#13;
            regularHold--;&#13;
        }&#13;
&#13;
        if (give_refund &amp;&amp; msg.value &gt; price) {&#13;
            uint256 change = msg.value - price;&#13;
&#13;
            msg.sender.transfer(change);&#13;
        }&#13;
&#13;
        if (referal != address(0)) {&#13;
            require(referal != msg.sender, "The referal cannot be the sender");&#13;
            require(referal != tx.origin, "The referal cannot be the tranaction origin");&#13;
            require(referal != new_owner, "The referal cannot be the new owner");&#13;
&#13;
            //The commissionRate map adds any partner bonuses, or 0 if a normal user referral&#13;
            uint256 totalCommision = COMMISSION_PERCENT + commissionRate[referal];&#13;
&#13;
            uint256 commision = (price * totalCommision) / 100;&#13;
&#13;
            referal.transfer(commision);&#13;
        }&#13;
&#13;
        emit CarBought(_tokenId, price, new_owner, category);&#13;
    }&#13;
&#13;
    /**&#13;
    Get the price for any car with the given _tokenId&#13;
    */&#13;
    function priceFor(uint cType) public view returns (uint256) {&#13;
        uint256 percent = percentIncrease[cType];&#13;
        uint256 base = percentBase[cType];&#13;
&#13;
        uint256 currentPrice = currentTypePrice[cType];&#13;
        uint256 nextPrice = (currentPrice * percent);&#13;
&#13;
        //Return the next price, as this is the true price&#13;
        return nextPrice / base;&#13;
    }&#13;
&#13;
    function sold(uint256 _tokenId) public view returns (bool) {&#13;
        return token.exists(_tokenId);&#13;
    }&#13;
}