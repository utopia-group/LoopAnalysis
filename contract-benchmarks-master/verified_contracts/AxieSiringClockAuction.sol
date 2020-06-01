pragma solidity ^0.4.23;

// File: contracts/breeding/AxieIncubatorInterface.sol

interface AxieIncubatorInterface {
  function breedingFee() external view returns (uint256);

  function requireEnoughExpForBreeding(
    uint256 _axieId
  )
    external
    view;

  function breedAxies(
    uint256 _sireId,
    uint256 _matronId,
    uint256 _birthPlace
  )
    external
    payable
    returns (uint256 _axieId);
}

// File: contracts/erc/erc721/IERC721Base.sol

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x6466353c
interface IERC721Base /* is IERC165  */ {
  /// @dev This emits when ownership of any NFT changes by any mechanism.
  ///  This event emits when NFTs are created (`from` == 0) and destroyed
  ///  (`to` == 0). Exception: during contract creation, any number of NFTs
  ///  may be created and assigned without emitting Transfer. At the time of
  ///  any transfer, the approved address for that NFT (if any) is reset to none.
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

  /// @dev This emits when the approved address for an NFT is changed or
  ///  reaffirmed. The zero address indicates there is no approved address.
  ///  When a Transfer event emits, this also indicates that the approved
  ///  address for that NFT (if any) is reset to none.
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  /// @dev This emits when an operator is enabled or disabled for an owner.
  ///  The operator can manage all NFTs of the owner.
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  /// @notice Count all NFTs assigned to an owner
  /// @dev NFTs assigned to the zero address are considered invalid, and this
  ///  function throws for queries about the zero address.
  /// @param _owner An address for whom to query the balance
  /// @return The number of NFTs owned by `_owner`, possibly zero
  function balanceOf(address _owner) external view returns (uint256);

  /// @notice Find the owner of an NFT
  /// @param _tokenId The identifier for an NFT
  /// @dev NFTs assigned to zero address are considered invalid, and queries
  ///  about them do throw.
  /// @return The address of the owner of the NFT
  function ownerOf(uint256 _tokenId) external view returns (address);

  /// @notice Transfers the ownership of an NFT from one address to another address
  /// @dev Throws unless `msg.sender` is the current owner, an authorized
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
  ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
  ///  `onERC721Received` on `_to` and throws if the return value is not
  ///  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`.
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  /// @param _data Additional data with no specified format, sent in call to `_to`
  // solium-disable-next-line arg-overflow
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) external payable;

  /// @notice Transfers the ownership of an NFT from one address to another address
  /// @dev This works identically to the other function with an extra data parameter,
  ///  except this function just sets data to []
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

  /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
  ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
  ///  THEY MAY BE PERMANENTLY LOST
  /// @dev Throws unless `msg.sender` is the current owner, an authorized
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT.
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

  /// @notice Set or reaffirm the approved address for an NFT
  /// @dev The zero address indicates there is no approved address.
  /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized
  ///  operator of the current owner.
  /// @param _approved The new approved NFT controller
  /// @param _tokenId The NFT to approve
  function approve(address _approved, uint256 _tokenId) external payable;

  /// @notice Enable or disable approval for a third party ("operator") to manage
  ///  all your asset.
  /// @dev Emits the ApprovalForAll event
  /// @param _operator Address to add to the set of authorized operators.
  /// @param _approved True if the operators is approved, false to revoke approval
  function setApprovalForAll(address _operator, bool _approved) external;

  /// @notice Get the approved address for a single NFT
  /// @dev Throws if `_tokenId` is not a valid NFT
  /// @param _tokenId The NFT to find the approved address for
  /// @return The approved address for this NFT, or the zero address if there is none
  function getApproved(uint256 _tokenId) external view returns (address);

  /// @notice Query if an address is an authorized operator for another address
  /// @param _owner The address that owns the NFTs
  /// @param _operator The address that acts on behalf of the owner
  /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
  function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// File: zeppelin/contracts/ownership/Ownable.sol

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
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: zeppelin/contracts/lifecycle/Pausable.sol

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

// File: zeppelin/contracts/ownership/HasNoContracts.sol

/**
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="a5d7c0c8c6cae597">[email protected]</span>π.com&gt;&#13;
 * @dev Should contracts (anything Ownable) end up being owned by this contract, it allows the owner&#13;
 * of this contract to reclaim ownership of the contracts.&#13;
 */&#13;
contract HasNoContracts is Ownable {&#13;
&#13;
  /**&#13;
   * @dev Reclaim ownership of Ownable contracts&#13;
   * @param contractAddr The address of the Ownable to be reclaimed.&#13;
   */&#13;
  function reclaimContract(address contractAddr) external onlyOwner {&#13;
    Ownable contractInst = Ownable(contractAddr);&#13;
    contractInst.transferOwnership(owner);&#13;
  }&#13;
}&#13;
&#13;
// File: zeppelin/contracts/token/ERC20Basic.sol&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  uint256 public totalSupply;&#13;
  function balanceOf(address who) public constant returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
// File: zeppelin/contracts/token/ERC20.sol&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender) public constant returns (uint256);&#13;
  function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
// File: zeppelin/contracts/token/SafeERC20.sol&#13;
&#13;
/**&#13;
 * @title SafeERC20&#13;
 * @dev Wrappers around ERC20 operations that throw on failure.&#13;
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,&#13;
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.&#13;
 */&#13;
library SafeERC20 {&#13;
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {&#13;
    assert(token.transfer(to, value));&#13;
  }&#13;
&#13;
  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {&#13;
    assert(token.transferFrom(from, to, value));&#13;
  }&#13;
&#13;
  function safeApprove(ERC20 token, address spender, uint256 value) internal {&#13;
    assert(token.approve(spender, value));&#13;
  }&#13;
}&#13;
&#13;
// File: zeppelin/contracts/ownership/CanReclaimToken.sol&#13;
&#13;
/**&#13;
 * @title Contracts that should be able to recover tokens&#13;
 * @author SylTi&#13;
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.&#13;
 * This will prevent any accidental loss of tokens.&#13;
 */&#13;
contract CanReclaimToken is Ownable {&#13;
  using SafeERC20 for ERC20Basic;&#13;
&#13;
  /**&#13;
   * @dev Reclaim all ERC20Basic compatible tokens&#13;
   * @param token ERC20Basic The address of the token contract&#13;
   */&#13;
  function reclaimToken(ERC20Basic token) external onlyOwner {&#13;
    uint256 balance = token.balanceOf(this);&#13;
    token.safeTransfer(owner, balance);&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: zeppelin/contracts/ownership/HasNoTokens.sol&#13;
&#13;
/**&#13;
 * @title Contracts that should not own Tokens&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="ff8d9a929c90bfcd">[email protected]</span>π.com&gt;&#13;
 * @dev This blocks incoming ERC23 tokens to prevent accidental loss of tokens.&#13;
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the&#13;
 * owner to reclaim the tokens.&#13;
 */&#13;
contract HasNoTokens is CanReclaimToken {&#13;
&#13;
 /**&#13;
  * @dev Reject all ERC23 compatible tokens&#13;
  * @param from_ address The address that is transferring the tokens&#13;
  * @param value_ uint256 the amount of the specified token&#13;
  * @param data_ Bytes The data passed from the caller.&#13;
  */&#13;
  function tokenFallback(address from_, uint256 value_, bytes data_) external {&#13;
    revert();&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts/marketplace/AxieSiringClockAuction.sol&#13;
&#13;
/// @title Clock auction for Axie siring.&#13;
contract AxieSiringClockAuction is HasNoContracts, HasNoTokens, Pausable {&#13;
  // Represents an auction on an NFT.&#13;
  struct Auction {&#13;
    // Current owner of NFT.&#13;
    address seller;&#13;
    // Price (in wei) at beginning of auction.&#13;
    uint128 startingPrice;&#13;
    // Price (in wei) at end of auction.&#13;
    uint128 endingPrice;&#13;
    // Duration (in seconds) of auction.&#13;
    uint64 duration;&#13;
    // Time when auction started.&#13;
    // NOTE: 0 if this auction has been concluded.&#13;
    uint64 startedAt;&#13;
  }&#13;
&#13;
  // Cut owner takes on each auction, measured in basis points (1/100 of a percent).&#13;
  // Values 0-10,000 map to 0%-100%.&#13;
  uint256 public ownerCut;&#13;
&#13;
  IERC721Base coreContract;&#13;
  AxieIncubatorInterface incubatorContract;&#13;
&#13;
  // Map from Axie ID to their corresponding auction.&#13;
  mapping (uint256 =&gt; Auction) public auctions;&#13;
&#13;
  event AuctionCreated(&#13;
    uint256 indexed _axieId,&#13;
    uint256 _startingPrice,&#13;
    uint256 _endingPrice,&#13;
    uint256 _duration,&#13;
    address _seller&#13;
  );&#13;
&#13;
  event AuctionSuccessful(&#13;
    uint256 indexed _sireId,&#13;
    uint256 indexed _matronId,&#13;
    uint256 _totalPrice,&#13;
    address _winner&#13;
  );&#13;
&#13;
  event AuctionCancelled(uint256 indexed _axieId);&#13;
&#13;
  /// @dev Constructor creates a reference to the NFT ownership contract&#13;
  ///  and verifies the owner cut is in the valid range.&#13;
  /// @param _ownerCut - percent cut the owner takes on each auction, must be&#13;
  ///  between 0-10,000.&#13;
  constructor(uint256 _ownerCut) public {&#13;
    require(_ownerCut &lt;= 10000);&#13;
    ownerCut = _ownerCut;&#13;
  }&#13;
&#13;
  function () external payable onlyOwner {&#13;
  }&#13;
&#13;
  // Modifiers to check that inputs can be safely stored with a certain&#13;
  // number of bits. We use constants and multiple modifiers to save gas.&#13;
  modifier canBeStoredWith64Bits(uint256 _value) {&#13;
    require(_value &lt;= 18446744073709551615);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier canBeStoredWith128Bits(uint256 _value) {&#13;
    require(_value &lt; 340282366920938463463374607431768211455);&#13;
    _;&#13;
  }&#13;
&#13;
  function reclaimEther() external onlyOwner {&#13;
    owner.transfer(address(this).balance);&#13;
  }&#13;
&#13;
  function setCoreContract(address _coreAddress) external onlyOwner {&#13;
    coreContract = IERC721Base(_coreAddress);&#13;
  }&#13;
&#13;
  function setIncubatorContract(address _incubatorAddress) external onlyOwner {&#13;
    incubatorContract = AxieIncubatorInterface(_incubatorAddress);&#13;
  }&#13;
&#13;
  /// @dev Returns auction info for an NFT on auction.&#13;
  /// @param _axieId - ID of NFT on auction.&#13;
  function getAuction(&#13;
    uint256 _axieId&#13;
  )&#13;
    external&#13;
    view&#13;
    returns (&#13;
      address seller,&#13;
      uint256 startingPrice,&#13;
      uint256 endingPrice,&#13;
      uint256 duration,&#13;
      uint256 startedAt&#13;
    )&#13;
  {&#13;
    Auction storage _auction = auctions[_axieId];&#13;
    require(_isOnAuction(_auction));&#13;
    return (&#13;
      _auction.seller,&#13;
      _auction.startingPrice,&#13;
      _auction.endingPrice,&#13;
      _auction.duration,&#13;
      _auction.startedAt&#13;
    );&#13;
  }&#13;
&#13;
  /// @dev Returns the current price of an auction.&#13;
  /// @param _axieId - ID of the Axie price we are checking.&#13;
  function getCurrentPrice(&#13;
    uint256 _axieId&#13;
  )&#13;
    external&#13;
    view&#13;
    returns (uint256)&#13;
  {&#13;
    Auction storage _auction = auctions[_axieId];&#13;
    require(_isOnAuction(_auction));&#13;
    return _getCurrentPrice(_auction);&#13;
  }&#13;
&#13;
  /// @dev Creates and begins a new auction.&#13;
  /// @param _axieId - ID of Axie to auction, sender must be owner.&#13;
  /// @param _startingPrice - Price of item (in wei) at beginning of auction.&#13;
  /// @param _endingPrice - Price of item (in wei) at end of auction.&#13;
  /// @param _duration - Length of time to move between starting&#13;
  ///  price and ending price (in seconds).&#13;
  function createAuction(&#13;
    uint256 _axieId,&#13;
    uint256 _startingPrice,&#13;
    uint256 _endingPrice,&#13;
    uint256 _duration&#13;
  )&#13;
    external&#13;
    whenNotPaused&#13;
    canBeStoredWith128Bits(_startingPrice)&#13;
    canBeStoredWith128Bits(_endingPrice)&#13;
    canBeStoredWith64Bits(_duration)&#13;
  {&#13;
    address _seller = msg.sender;&#13;
&#13;
    require(coreContract.ownerOf(_axieId) == _seller);&#13;
    incubatorContract.requireEnoughExpForBreeding(_axieId); // Validate EXP for breeding.&#13;
&#13;
    _escrow(_seller, _axieId);&#13;
&#13;
    Auction memory _auction = Auction(&#13;
      _seller,&#13;
      uint128(_startingPrice),&#13;
      uint128(_endingPrice),&#13;
      uint64(_duration),&#13;
      uint64(now)&#13;
    );&#13;
&#13;
    _addAuction(&#13;
      _axieId,&#13;
      _auction,&#13;
      _seller&#13;
    );&#13;
  }&#13;
&#13;
  /// @dev Bids on an siring auction and completing it.&#13;
  /// @param _sireId - ID of Axie to bid on siring.&#13;
  /// @param _matronId - ID of matron Axie.&#13;
  function bidOnSiring(&#13;
    uint256 _sireId,&#13;
    uint256 _matronId,&#13;
    uint256 _birthPlace&#13;
  )&#13;
    external&#13;
    payable&#13;
    whenNotPaused&#13;
    returns (uint256 /* _axieId */)&#13;
  {&#13;
    Auction storage _auction = auctions[_sireId];&#13;
    require(_isOnAuction(_auction));&#13;
&#13;
    require(msg.sender == coreContract.ownerOf(_matronId));&#13;
&#13;
    // Save seller address here since `_bid` will clear it.&#13;
    address _seller = _auction.seller;&#13;
&#13;
    // _bid will throw if the bid or funds transfer fails.&#13;
    _bid(_sireId, _matronId, msg.value, _auction);&#13;
&#13;
    uint256 _axieId = incubatorContract.breedAxies.value(&#13;
      incubatorContract.breedingFee()&#13;
    )(&#13;
      _sireId,&#13;
      _matronId,&#13;
      _birthPlace&#13;
    );&#13;
&#13;
    _transfer(_seller, _sireId);&#13;
&#13;
    return _axieId;&#13;
  }&#13;
&#13;
  /// @dev Cancels an auction that hasn't been won yet.&#13;
  ///  Returns the NFT to original owner.&#13;
  /// @notice This is a state-modifying function that can&#13;
  ///  be called while the contract is paused.&#13;
  /// @param _axieId - ID of Axie on auction.&#13;
  function cancelAuction(uint256 _axieId) external {&#13;
    Auction storage _auction = auctions[_axieId];&#13;
    require(_isOnAuction(_auction));&#13;
    require(msg.sender == _auction.seller);&#13;
    _cancelAuction(_axieId, _auction.seller);&#13;
  }&#13;
&#13;
  /// @dev Cancels an auction when the contract is paused.&#13;
  ///  Only the owner may do this, and NFTs are returned to&#13;
  ///  the seller. This should only be used in emergencies.&#13;
  /// @param _axieId - ID of the NFT on auction to cancel.&#13;
  function cancelAuctionWhenPaused(&#13;
    uint256 _axieId&#13;
  )&#13;
    external&#13;
    whenPaused&#13;
    onlyOwner&#13;
  {&#13;
    Auction storage _auction = auctions[_axieId];&#13;
    require(_isOnAuction(_auction));&#13;
    _cancelAuction(_axieId, _auction.seller);&#13;
  }&#13;
&#13;
  /// @dev Returns true if the NFT is on auction.&#13;
  /// @param _auction - Auction to check.&#13;
  function _isOnAuction(Auction storage _auction) internal view returns (bool) {&#13;
    return (_auction.startedAt &gt; 0);&#13;
  }&#13;
&#13;
  /// @dev Returns current price of an NFT on auction. Broken into two&#13;
  ///  functions (this one, that computes the duration from the auction&#13;
  ///  structure, and the other that does the price computation) so we&#13;
  ///  can easily test that the price computation works correctly.&#13;
  function _getCurrentPrice(&#13;
    Auction storage _auction&#13;
  )&#13;
    internal&#13;
    view&#13;
    returns (uint256)&#13;
  {&#13;
    uint256 _secondsPassed = 0;&#13;
&#13;
    // A bit of insurance against negative values (or wraparound).&#13;
    // Probably not necessary (since Ethereum guarantees that the&#13;
    // now variable doesn't ever go backwards).&#13;
    if (now &gt; _auction.startedAt) {&#13;
      _secondsPassed = now - _auction.startedAt;&#13;
    }&#13;
&#13;
    return _computeCurrentPrice(&#13;
      _auction.startingPrice,&#13;
      _auction.endingPrice,&#13;
      _auction.duration,&#13;
      _secondsPassed&#13;
    );&#13;
  }&#13;
&#13;
  /// @dev Computes the current price of an auction. Factored out&#13;
  ///  from _currentPrice so we can run extensive unit tests.&#13;
  ///  When testing, make this function external and turn on&#13;
  ///  `Current price computation` test suite.&#13;
  function _computeCurrentPrice(&#13;
    uint256 _startingPrice,&#13;
    uint256 _endingPrice,&#13;
    uint256 _duration,&#13;
    uint256 _secondsPassed&#13;
  )&#13;
    internal&#13;
    pure&#13;
    returns (uint256)&#13;
  {&#13;
    // NOTE: We don't use SafeMath (or similar) in this function because&#13;
    //  all of our external functions carefully cap the maximum values for&#13;
    //  time (at 64-bits) and currency (at 128-bits). _duration is&#13;
    //  also known to be non-zero (see the require() statement in&#13;
    //  _addAuction()).&#13;
    if (_secondsPassed &gt;= _duration) {&#13;
      // We've reached the end of the dynamic pricing portion&#13;
      // of the auction, just return the end price.&#13;
      return _endingPrice;&#13;
    } else {&#13;
      // Starting price can be higher than ending price (and often is!), so&#13;
      // this delta can be negative.&#13;
      int256 _totalPriceChange = int256(_endingPrice) - int256(_startingPrice);&#13;
&#13;
      // This multiplication can't overflow, _secondsPassed will easily fit within&#13;
      // 64-bits, and _totalPriceChange will easily fit within 128-bits, their product&#13;
      // will always fit within 256-bits.&#13;
      int256 _currentPriceChange = _totalPriceChange * int256(_secondsPassed) / int256(_duration);&#13;
&#13;
      // _currentPriceChange can be negative, but if so, will have a magnitude&#13;
      // less that _startingPrice. Thus, this result will always end up positive.&#13;
      int256 _currentPrice = int256(_startingPrice) + _currentPriceChange;&#13;
&#13;
      return uint256(_currentPrice);&#13;
    }&#13;
  }&#13;
&#13;
  /// @dev Adds an auction to the list of open auctions. Also fires the&#13;
  ///  AuctionCreated event.&#13;
  /// @param _axieId The ID of the Axie to be put on auction.&#13;
  /// @param _auction Auction to add.&#13;
  function _addAuction(&#13;
    uint256 _axieId,&#13;
    Auction memory _auction,&#13;
    address _seller&#13;
  )&#13;
    internal&#13;
  {&#13;
    // Require that all auctions have a duration of&#13;
    // at least one minute. (Keeps our math from getting hairy!).&#13;
    require(_auction.duration &gt;= 1 minutes);&#13;
&#13;
    auctions[_axieId] = _auction;&#13;
&#13;
    emit AuctionCreated(&#13;
      _axieId,&#13;
      uint256(_auction.startingPrice),&#13;
      uint256(_auction.endingPrice),&#13;
      uint256(_auction.duration),&#13;
      _seller&#13;
    );&#13;
  }&#13;
&#13;
  /// @dev Removes an auction from the list of open auctions.&#13;
  /// @param _axieId - ID of NFT on auction.&#13;
  function _removeAuction(uint256 _axieId) internal {&#13;
    delete auctions[_axieId];&#13;
  }&#13;
&#13;
  /// @dev Cancels an auction unconditionally.&#13;
  function _cancelAuction(uint256 _axieId, address _seller) internal {&#13;
    _removeAuction(_axieId);&#13;
    _transfer(_seller, _axieId);&#13;
    emit AuctionCancelled(_axieId);&#13;
  }&#13;
&#13;
  /// @dev Escrows the NFT, assigning ownership to this contract.&#13;
  /// Throws if the escrow fails.&#13;
  /// @param _owner - Current owner address of Axie to escrow.&#13;
  /// @param _axieId - ID of Axie whose approval to verify.&#13;
  function _escrow(address _owner, uint256 _axieId) internal {&#13;
    // It will throw if transfer fails.&#13;
    coreContract.transferFrom(_owner, this, _axieId);&#13;
  }&#13;
&#13;
  /// @dev Transfers an NFT owned by this contract to another address.&#13;
  /// Returns true if the transfer succeeds.&#13;
  /// @param _receiver - Address to transfer NFT to.&#13;
  /// @param _axieId - ID of Axie to transfer.&#13;
  function _transfer(address _receiver, uint256 _axieId) internal {&#13;
    // It will throw if transfer fails&#13;
    coreContract.transferFrom(this, _receiver, _axieId);&#13;
  }&#13;
&#13;
  /// @dev Computes owner's cut of a sale.&#13;
  /// @param _price - Sale price of NFT.&#13;
  function _computeCut(uint256 _price) internal view returns (uint256) {&#13;
    // NOTE: We don't use SafeMath (or similar) in this function because&#13;
    //  all of our entry functions carefully cap the maximum values for&#13;
    //  currency (at 128-bits), and ownerCut &lt;= 10000 (see the require()&#13;
    //  statement in the ClockAuction constructor). The result of this&#13;
    //  function is always guaranteed to be &lt;= _price.&#13;
    return _price * ownerCut / 10000;&#13;
  }&#13;
&#13;
  /// @dev Computes the price and transfers winnings.&#13;
  /// Does NOT transfer ownership of Axie.&#13;
  function _bid(&#13;
    uint256 _sireId,&#13;
    uint256 _matronId,&#13;
    uint256 _bidAmount,&#13;
    Auction storage _auction&#13;
  )&#13;
    internal&#13;
    returns (uint256)&#13;
  {&#13;
    // Check that the incoming bid is higher than the current price.&#13;
    uint256 _price = _getCurrentPrice(_auction);&#13;
    uint256 _priceWithFee = _price + incubatorContract.breedingFee();&#13;
&#13;
    // Technically this shouldn't happen as `_price` fits in 128 bits.&#13;
    // However, we could set `breedingFee` to a very large number accidentally.&#13;
    assert(_priceWithFee &gt;= _price);&#13;
&#13;
    require(_bidAmount &gt;= _priceWithFee);&#13;
&#13;
    // Grab a reference to the seller before the auction struct&#13;
    // gets deleted.&#13;
    address _seller = _auction.seller;&#13;
&#13;
    // The bid is good! Remove the auction before sending the fees&#13;
    // to the sender so we can't have a reentrancy attack.&#13;
    _removeAuction(_sireId);&#13;
&#13;
    // Transfer proceeds to seller (if there are any!)&#13;
    if (_price &gt; 0) {&#13;
      //  Calculate the auctioneer's cut.&#13;
      // (NOTE: _computeCut() is guaranteed to return a&#13;
      //  value &lt;= price, so this subtraction can't go negative.)&#13;
      uint256 _auctioneerCut = _computeCut(_price);&#13;
      uint256 _sellerProceeds = _price - _auctioneerCut;&#13;
&#13;
      // NOTE: Doing a transfer() in the middle of a complex&#13;
      // method like this is generally discouraged because of&#13;
      // reentrancy attacks and DoS attacks if the seller is&#13;
      // a contract with an invalid fallback function. We explicitly&#13;
      // guard against reentrancy attacks by removing the auction&#13;
      // before calling transfer(), and the only thing the seller&#13;
      // can DoS is the sale of their own asset! (And if it's an&#13;
      // accident, they can call cancelAuction().)&#13;
      _seller.transfer(_sellerProceeds);&#13;
    }&#13;
&#13;
    if (_bidAmount &gt; _priceWithFee) {&#13;
      // Calculate any excess funds included with the bid. If the excess&#13;
      // is anything worth worrying about, transfer it back to bidder.&#13;
      // NOTE: We checked above that the bid amount is greater than or&#13;
      // equal to the price so this cannot underflow.&#13;
      uint256 _bidExcess = _bidAmount - _priceWithFee;&#13;
&#13;
      // Return the funds. Similar to the previous transfer, this is&#13;
      // not susceptible to a re-entry attack because the auction is&#13;
      // removed before any transfers occur.&#13;
      msg.sender.transfer(_bidExcess);&#13;
    }&#13;
&#13;
    // Tell the world!&#13;
    emit AuctionSuccessful(&#13;
      _sireId,&#13;
      _matronId,&#13;
      _price,&#13;
      msg.sender&#13;
    );&#13;
&#13;
    return _price;&#13;
  }&#13;
}