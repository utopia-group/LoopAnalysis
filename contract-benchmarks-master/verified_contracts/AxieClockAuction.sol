pragma solidity ^0.4.19;

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

// File: zeppelin/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="bdcfd8d0ded2fd8f">[email protected]</span>π.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this ether.&#13;
 * @notice Ether can still be send to this contract by:&#13;
 * calling functions labeled `payable`&#13;
 * `selfdestruct(contract_address)`&#13;
 * mining directly to the contract address&#13;
*/&#13;
contract HasNoEther is Ownable {&#13;
&#13;
  /**&#13;
  * @dev Constructor that rejects incoming Ether&#13;
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we&#13;
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable&#13;
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively&#13;
  * we could use assembly to access msg.value.&#13;
  */&#13;
  function HasNoEther() payable {&#13;
    require(msg.value == 0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Disallows direct send by settings a default function without the `payable` flag.&#13;
   */&#13;
  function() external {&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfer all Ether held by the contract to the owner.&#13;
   */&#13;
  function reclaimEther() external onlyOwner {&#13;
    assert(owner.send(this.balance));&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/marketplace/AxieClockAuction.sol&#13;
&#13;
/// @title Clock auction for non-fungible tokens.&#13;
contract AxieClockAuction is HasNoEther, Pausable {&#13;
&#13;
  // Represents an auction on an NFT&#13;
  struct Auction {&#13;
    // Current owner of NFT&#13;
    address seller;&#13;
    // Price (in wei) at beginning of auction&#13;
    uint128 startingPrice;&#13;
    // Price (in wei) at end of auction&#13;
    uint128 endingPrice;&#13;
    // Duration (in seconds) of auction&#13;
    uint64 duration;&#13;
    // Time when auction started&#13;
    // NOTE: 0 if this auction has been concluded&#13;
    uint64 startedAt;&#13;
  }&#13;
&#13;
  // Cut owner takes on each auction, measured in basis points (1/100 of a percent).&#13;
  // Values 0-10,000 map to 0%-100%&#13;
  uint256 public ownerCut;&#13;
&#13;
  // Map from token ID to their corresponding auction.&#13;
  mapping (address =&gt; mapping (uint256 =&gt; Auction)) public auctions;&#13;
&#13;
  event AuctionCreated(&#13;
    address indexed _nftAddress,&#13;
    uint256 indexed _tokenId,&#13;
    uint256 _startingPrice,&#13;
    uint256 _endingPrice,&#13;
    uint256 _duration,&#13;
    address _seller&#13;
  );&#13;
&#13;
  event AuctionSuccessful(&#13;
    address indexed _nftAddress,&#13;
    uint256 indexed _tokenId,&#13;
    uint256 _totalPrice,&#13;
    address _winner&#13;
  );&#13;
&#13;
  event AuctionCancelled(&#13;
    address indexed _nftAddress,&#13;
    uint256 indexed _tokenId&#13;
  );&#13;
&#13;
  /// @dev Constructor creates a reference to the NFT ownership contract&#13;
  ///  and verifies the owner cut is in the valid range.&#13;
  /// @param _ownerCut - percent cut the owner takes on each auction, must be&#13;
  ///  between 0-10,000.&#13;
  function AxieClockAuction(uint256 _ownerCut) public {&#13;
    require(_ownerCut &lt;= 10000);&#13;
    ownerCut = _ownerCut;&#13;
  }&#13;
&#13;
  /// @dev DON'T give me your money.&#13;
  function () external {}&#13;
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
  /// @dev Returns auction info for an NFT on auction.&#13;
  /// @param _nftAddress - Address of the NFT.&#13;
  /// @param _tokenId - ID of NFT on auction.&#13;
  function getAuction(&#13;
    address _nftAddress,&#13;
    uint256 _tokenId&#13;
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
    Auction storage _auction = auctions[_nftAddress][_tokenId];&#13;
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
  /// @param _nftAddress - Address of the NFT.&#13;
  /// @param _tokenId - ID of the token price we are checking.&#13;
  function getCurrentPrice(&#13;
    address _nftAddress,&#13;
    uint256 _tokenId&#13;
  )&#13;
    external&#13;
    view&#13;
    returns (uint256)&#13;
  {&#13;
    Auction storage _auction = auctions[_nftAddress][_tokenId];&#13;
    require(_isOnAuction(_auction));&#13;
    return _getCurrentPrice(_auction);&#13;
  }&#13;
&#13;
  /// @dev Creates and begins a new auction.&#13;
  /// @param _nftAddress - address of a deployed contract implementing&#13;
  ///  the Nonfungible Interface.&#13;
  /// @param _tokenId - ID of token to auction, sender must be owner.&#13;
  /// @param _startingPrice - Price of item (in wei) at beginning of auction.&#13;
  /// @param _endingPrice - Price of item (in wei) at end of auction.&#13;
  /// @param _duration - Length of time to move between starting&#13;
  ///  price and ending price (in seconds).&#13;
  function createAuction(&#13;
    address _nftAddress,&#13;
    uint256 _tokenId,&#13;
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
    require(_owns(_nftAddress, _seller, _tokenId));&#13;
    _escrow(_nftAddress, _seller, _tokenId);&#13;
    Auction memory _auction = Auction(&#13;
      _seller,&#13;
      uint128(_startingPrice),&#13;
      uint128(_endingPrice),&#13;
      uint64(_duration),&#13;
      uint64(now)&#13;
    );&#13;
    _addAuction(_nftAddress, _tokenId, _auction, _seller);&#13;
  }&#13;
&#13;
  /// @dev Bids on an open auction, completing the auction and transferring&#13;
  ///  ownership of the NFT if enough Ether is supplied.&#13;
  /// @param _nftAddress - address of a deployed contract implementing&#13;
  ///  the Nonfungible Interface.&#13;
  /// @param _tokenId - ID of token to bid on.&#13;
  function bid(&#13;
    address _nftAddress,&#13;
    uint256 _tokenId&#13;
  )&#13;
    external&#13;
    payable&#13;
    whenNotPaused&#13;
  {&#13;
    // _bid will throw if the bid or funds transfer fails&#13;
    _bid(_nftAddress, _tokenId, msg.value);&#13;
    _transfer(_nftAddress, msg.sender, _tokenId);&#13;
  }&#13;
&#13;
  /// @dev Cancels an auction that hasn't been won yet.&#13;
  ///  Returns the NFT to original owner.&#13;
  /// @notice This is a state-modifying function that can&#13;
  ///  be called while the contract is paused.&#13;
  /// @param _nftAddress - Address of the NFT.&#13;
  /// @param _tokenId - ID of token on auction&#13;
  function cancelAuction(address _nftAddress, uint256 _tokenId) external {&#13;
    Auction storage _auction = auctions[_nftAddress][_tokenId];&#13;
    require(_isOnAuction(_auction));&#13;
    require(msg.sender == _auction.seller);&#13;
    _cancelAuction(_nftAddress, _tokenId, _auction.seller);&#13;
  }&#13;
&#13;
  /// @dev Cancels an auction when the contract is paused.&#13;
  ///  Only the owner may do this, and NFTs are returned to&#13;
  ///  the seller. This should only be used in emergencies.&#13;
  /// @param _nftAddress - Address of the NFT.&#13;
  /// @param _tokenId - ID of the NFT on auction to cancel.&#13;
  function cancelAuctionWhenPaused(&#13;
    address _nftAddress,&#13;
    uint256 _tokenId&#13;
  )&#13;
    external&#13;
    whenPaused&#13;
    onlyOwner&#13;
  {&#13;
    Auction storage _auction = auctions[_nftAddress][_tokenId];&#13;
    require(_isOnAuction(_auction));&#13;
    _cancelAuction(_nftAddress, _tokenId, _auction.seller);&#13;
  }&#13;
&#13;
  /// @dev Returns true if the NFT is on auction.&#13;
  /// @param _auction - Auction to check.&#13;
  function _isOnAuction(Auction storage _auction) internal view returns (bool) {&#13;
    return (_auction.startedAt &gt; 0);&#13;
  }&#13;
&#13;
  /// @dev Gets the NFT object from an address, validating that implementsERC721 is true.&#13;
  /// @param _nftAddress - Address of the NFT.&#13;
  function _getNftContract(address _nftAddress) internal pure returns (IERC721Base) {&#13;
    IERC721Base candidateContract = IERC721Base(_nftAddress);&#13;
    // require(candidateContract.implementsERC721());&#13;
    return candidateContract;&#13;
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
    //  _addAuction())&#13;
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
  /// @dev Returns true if the claimant owns the token.&#13;
  /// @param _nftAddress - The address of the NFT.&#13;
  /// @param _claimant - Address claiming to own the token.&#13;
  /// @param _tokenId - ID of token whose ownership to verify.&#13;
  function _owns(address _nftAddress, address _claimant, uint256 _tokenId) private view returns (bool) {&#13;
    IERC721Base _nftContract = _getNftContract(_nftAddress);&#13;
    return (_nftContract.ownerOf(_tokenId) == _claimant);&#13;
  }&#13;
&#13;
  /// @dev Adds an auction to the list of open auctions. Also fires the&#13;
  ///  AuctionCreated event.&#13;
  /// @param _tokenId The ID of the token to be put on auction.&#13;
  /// @param _auction Auction to add.&#13;
  function _addAuction(&#13;
    address _nftAddress,&#13;
    uint256 _tokenId,&#13;
    Auction _auction,&#13;
    address _seller&#13;
  ) internal {&#13;
    // Require that all auctions have a duration of&#13;
    // at least one minute. (Keeps our math from getting hairy!)&#13;
    require(_auction.duration &gt;= 1 minutes);&#13;
&#13;
    auctions[_nftAddress][_tokenId] = _auction;&#13;
&#13;
    AuctionCreated(&#13;
      _nftAddress,&#13;
      _tokenId,&#13;
      uint256(_auction.startingPrice),&#13;
      uint256(_auction.endingPrice),&#13;
      uint256(_auction.duration),&#13;
      _seller&#13;
    );&#13;
  }&#13;
&#13;
  /// @dev Removes an auction from the list of open auctions.&#13;
  /// @param _tokenId - ID of NFT on auction.&#13;
  function _removeAuction(address _nftAddress, uint256 _tokenId) internal {&#13;
    delete auctions[_nftAddress][_tokenId];&#13;
  }&#13;
&#13;
  /// @dev Cancels an auction unconditionally.&#13;
  function _cancelAuction(address _nftAddress, uint256 _tokenId, address _seller) internal {&#13;
    _removeAuction(_nftAddress, _tokenId);&#13;
    _transfer(_nftAddress, _seller, _tokenId);&#13;
    AuctionCancelled(_nftAddress, _tokenId);&#13;
  }&#13;
&#13;
  /// @dev Escrows the NFT, assigning ownership to this contract.&#13;
  /// Throws if the escrow fails.&#13;
  /// @param _nftAddress - The address of the NFT.&#13;
  /// @param _owner - Current owner address of token to escrow.&#13;
  /// @param _tokenId - ID of token whose approval to verify.&#13;
  function _escrow(address _nftAddress, address _owner, uint256 _tokenId) private {&#13;
    IERC721Base _nftContract = _getNftContract(_nftAddress);&#13;
&#13;
    // It will throw if transfer fails&#13;
    _nftContract.transferFrom(_owner, this, _tokenId);&#13;
  }&#13;
&#13;
  /// @dev Transfers an NFT owned by this contract to another address.&#13;
  /// Returns true if the transfer succeeds.&#13;
  /// @param _nftAddress - The address of the NFT.&#13;
  /// @param _receiver - Address to transfer NFT to.&#13;
  /// @param _tokenId - ID of token to transfer.&#13;
  function _transfer(address _nftAddress, address _receiver, uint256 _tokenId) internal {&#13;
    IERC721Base _nftContract = _getNftContract(_nftAddress);&#13;
&#13;
    // It will throw if transfer fails&#13;
    _nftContract.transferFrom(this, _receiver, _tokenId);&#13;
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
  /// Does NOT transfer ownership of token.&#13;
  function _bid(&#13;
    address _nftAddress,&#13;
    uint256 _tokenId,&#13;
    uint256 _bidAmount&#13;
  )&#13;
    internal&#13;
    returns (uint256)&#13;
  {&#13;
    // Get a reference to the auction struct&#13;
    Auction storage _auction = auctions[_nftAddress][_tokenId];&#13;
&#13;
    // Explicitly check that this auction is currently live.&#13;
    // (Because of how Ethereum mappings work, we can't just count&#13;
    // on the lookup above failing. An invalid _tokenId will just&#13;
    // return an auction object that is all zeros.)&#13;
    require(_isOnAuction(_auction));&#13;
&#13;
    // Check that the incoming bid is higher than the current&#13;
    // price&#13;
    uint256 _price = _getCurrentPrice(_auction);&#13;
    require(_bidAmount &gt;= _price);&#13;
&#13;
    // Grab a reference to the seller before the auction struct&#13;
    // gets deleted.&#13;
    address _seller = _auction.seller;&#13;
&#13;
    // The bid is good! Remove the auction before sending the fees&#13;
    // to the sender so we can't have a reentrancy attack.&#13;
    _removeAuction(_nftAddress, _tokenId);&#13;
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
      // accident, they can call cancelAuction(). )&#13;
      _seller.transfer(_sellerProceeds);&#13;
    }&#13;
&#13;
    if (_bidAmount &gt; _price) {&#13;
      // Calculate any excess funds included with the bid. If the excess&#13;
      // is anything worth worrying about, transfer it back to bidder.&#13;
      // NOTE: We checked above that the bid amount is greater than or&#13;
      // equal to the price so this cannot underflow.&#13;
      uint256 _bidExcess = _bidAmount - _price;&#13;
&#13;
      // Return the funds. Similar to the previous transfer, this is&#13;
      // not susceptible to a re-entry attack because the auction is&#13;
      // removed before any transfers occur.&#13;
      msg.sender.transfer(_bidExcess);&#13;
    }&#13;
&#13;
    // Tell the world!&#13;
    AuctionSuccessful(_nftAddress, _tokenId, _price, msg.sender);&#13;
&#13;
    return _price;&#13;
  }&#13;
}