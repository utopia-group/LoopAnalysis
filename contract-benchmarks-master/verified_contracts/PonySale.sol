pragma solidity ^0.4.11;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


pragma solidity ^0.4.11;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract IERC20 {

    function totalSupply() public constant returns (uint256);
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public;
    function transferFrom(address from, address to, uint256 value) public;
    function approve(address spender, uint256 value) public;
    function allowance(address owner, address spender) public constant returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract PonySale is IERC20 {

    using SafeMath for uint256;

    // Token properties
    string public name = "Reales";
    string public symbol = "RLS";
    uint public decimals = 18;

    uint public _totalSupply = 1000000000e18;

    uint public _icoSupply = 500000000e18; // crowdsale

    uint public _futureSupply = 500000000e18; // futureUse

    // Balances for each account
    mapping (address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping(address => uint256)) allowed;

    uint256 public startTime;

    // Owner of Token
    address public owner;

    // how many token units a buyer gets per wei
    uint public PRICE = 1000;

    uint public maxCap = 700000e18 ether; // 50000 ether

    // amount of raised money in wei
    uint256 public fundRaised;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value);

    // modifier to allow only owner has full control on the function
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // Constructor
    // @notice RLSToken Contract
    // @return the transaction address
    function PonySale() public payable {
        startTime = now;
        owner = msg.sender;

        balances[owner] = _totalSupply; 
    }

    // Payable method
    // @notice Anyone can buy the tokens on tokensale by paying ether
    function () public payable {
        tokensale(msg.sender);
    }

    // @notice tokensale
    // @param recipient The address of the recipient
    // @return the transaction address and send the event as Transfer
    function tokensale(address recipient) public payable {
        require(recipient != 0x0);

        uint256 weiAmount = msg.value;

        owner.transfer(msg.value);
        TokenPurchase(msg.sender, recipient, weiAmount);
    }

    // @return total tokens supplied
    function totalSupply() public constant returns (uint256) {
        return _totalSupply;
    }

    // What is the balance of a particular account?
    // @param who The address of the particular account
    // @return the balanace the particular account
    function balanceOf(address who) public constant returns (uint256) {
        return balances[who];
    }

    // Token distribution to founder, develoment team, partners, charity, and bounty
    function sendFutureSupplyToken(address to, uint256 value) public onlyOwner {
        require (
            to != 0x0 && value > 0 && _futureSupply >= value
        );

        balances[owner] = balances[owner].sub(value);
        balances[to] = balances[to].add(value);
        _futureSupply = _futureSupply.sub(value);
        Transfer(owner, to, value);
    }

    // @notice send `value` token to `to` from `msg.sender`
    // @param to The address of the recipient
    // @param value The amount of token to be transferred
    // @return the transaction address and send the event as Transfer
    function transfer(address to, uint256 value) public {
        require (
            balances[msg.sender] >= value && value > 0
        );
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        Transfer(msg.sender, to, value);
    }

    // @notice send `value` token to `to` from `from`
    // @param from The address of the sender
    // @param to The address of the recipient
    // @param value The amount of token to be transferred
    // @return the transaction address and send the event as Transfer
    function transferFrom(address from, address to, uint256 value) public {
        require (
            allowed[from][msg.sender] >= value && balances[from] >= value && value > 0
        );
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        Transfer(from, to, value);
    }

    // Allow spender to withdraw from your account, multiple times, up to the value amount.
    // If this function is called again it overwrites the current allowance with value.
    // @param spender The address of the sender
    // @param value The amount to be approved
    // @return the transaction address and send the event as Approval
    function approve(address spender, uint256 value) public {
        require (
            balances[msg.sender] >= value && value > 0
        );
        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
    }

    // Check the allowed value for the spender to withdraw from owner
    // @param owner The address of the owner
    // @param spender The address of the spender
    // @return the amount which spender is still allowed to withdraw from owner
    function allowance(address _owner, address spender) public constant returns (uint256) {
        return allowed[_owner][spender];
    }


}



/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5b3f3e2f3e1b3a23323436213e35753834">[email protected]</a>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
    // Required methods&#13;
    function totalSupply() public view returns (uint256 total);&#13;
    function balanceOf(address _owner) public view returns (uint256 balance);&#13;
    function ownerOf(uint256 _tokenId) external view returns (address owner);&#13;
    function approve(address _to, uint256 _tokenId) external;&#13;
    function transfer(address _to, uint256 _tokenId) external;&#13;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;&#13;
&#13;
    // Events&#13;
    event Transfer(address from, address to, uint256 tokenId);&#13;
    event Approval(address owner, address approved, uint256 tokenId);&#13;
&#13;
    // Optional&#13;
    // function name() public view returns (string name);&#13;
    // function symbol() public view returns (string symbol);&#13;
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);&#13;
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);&#13;
&#13;
    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)&#13;
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);&#13;
}&#13;
&#13;
/// @title Auction Core&#13;
/// @dev Contains models, variables, and internal methods for the auction.&#13;
/// @notice We omit a fallback function to prevent accidental sends to this contract.&#13;
contract ClockAuctionBase {&#13;
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
    // Reference to contract tracking NFT ownership&#13;
    ERC721 public nonFungibleContract;&#13;
&#13;
    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).&#13;
    // Values 0-10,000 map to 0%-100%&#13;
    uint256 public ownerCut;&#13;
&#13;
    // Map from token ID to their corresponding auction.&#13;
    mapping (uint256 =&gt; Auction) tokenIdToAuction;&#13;
&#13;
    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);&#13;
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);&#13;
    event AuctionCancelled(uint256 tokenId);&#13;
&#13;
    /// @dev Returns true if the claimant owns the token.&#13;
    /// @param _claimant - Address claiming to own the token.&#13;
    /// @param _tokenId - ID of token whose ownership to verify.&#13;
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {&#13;
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);&#13;
    }&#13;
&#13;
    /// @dev Escrows the NFT, assigning ownership to this contract.&#13;
    /// Throws if the escrow fails.&#13;
    /// @param _owner - Current owner address of token to escrow.&#13;
    /// @param _tokenId - ID of token whose approval to verify.&#13;
    function _escrow(address _owner, uint256 _tokenId) internal {&#13;
        // it will throw if transfer fails&#13;
        nonFungibleContract.transferFrom(_owner, this, _tokenId);&#13;
    }&#13;
&#13;
    /// @dev Transfers an NFT owned by this contract to another address.&#13;
    /// Returns true if the transfer succeeds.&#13;
    /// @param _receiver - Address to transfer NFT to.&#13;
    /// @param _tokenId - ID of token to transfer.&#13;
    function _transfer(address _receiver, uint256 _tokenId) internal {&#13;
        // it will throw if transfer fails&#13;
        nonFungibleContract.transfer(_receiver, _tokenId);&#13;
    }&#13;
&#13;
    /// @dev Adds an auction to the list of open auctions. Also fires the&#13;
    ///  AuctionCreated event.&#13;
    /// @param _tokenId The ID of the token to be put on auction.&#13;
    /// @param _auction Auction to add.&#13;
    function _addAuction(uint256 _tokenId, Auction _auction) internal {&#13;
        // Require that all auctions have a duration of&#13;
        // at least one minute. (Keeps our math from getting hairy!)&#13;
        require(_auction.duration &gt;= 1 minutes);&#13;
&#13;
        tokenIdToAuction[_tokenId] = _auction;&#13;
&#13;
        AuctionCreated(&#13;
            uint256(_tokenId),&#13;
            uint256(_auction.startingPrice),&#13;
            uint256(_auction.endingPrice),&#13;
            uint256(_auction.duration)&#13;
        );&#13;
    }&#13;
&#13;
    /// @dev Cancels an auction unconditionally.&#13;
    function _cancelAuction(uint256 _tokenId, address _seller) internal {&#13;
        _removeAuction(_tokenId);&#13;
        _transfer(_seller, _tokenId);&#13;
        AuctionCancelled(_tokenId);&#13;
    }&#13;
&#13;
    /// @dev Computes the price and transfers winnings.&#13;
    /// Does NOT transfer ownership of token.&#13;
    function _bid(uint256 _tokenId, uint256 _bidAmount)&#13;
        internal&#13;
        returns (uint256)&#13;
    {&#13;
        // Get a reference to the auction struct&#13;
        Auction storage auction = tokenIdToAuction[_tokenId];&#13;
&#13;
        // Explicitly check that this auction is currently live.&#13;
        // (Because of how Ethereum mappings work, we can't just count&#13;
        // on the lookup above failing. An invalid _tokenId will just&#13;
        // return an auction object that is all zeros.)&#13;
        require(_isOnAuction(auction));&#13;
&#13;
        // Check that the bid is greater than or equal to the current price&#13;
        uint256 price = _currentPrice(auction);&#13;
        require(_bidAmount &gt;= price);&#13;
&#13;
        // Grab a reference to the seller before the auction struct&#13;
        // gets deleted.&#13;
        address seller = auction.seller;&#13;
&#13;
        // The bid is good! Remove the auction before sending the fees&#13;
        // to the sender so we can't have a reentrancy attack.&#13;
        _removeAuction(_tokenId);&#13;
&#13;
        // Transfer proceeds to seller (if there are any!)&#13;
        if (price &gt; 0) {&#13;
            // Calculate the auctioneer's cut.&#13;
            // (NOTE: _computeCut() is guaranteed to return a&#13;
            // value &lt;= price, so this subtraction can't go negative.)&#13;
            uint256 auctioneerCut = _computeCut(price);&#13;
            uint256 sellerProceeds = price - auctioneerCut;&#13;
&#13;
            // NOTE: Doing a transfer() in the middle of a complex&#13;
            // method like this is generally discouraged because of&#13;
            // reentrancy attacks and DoS attacks if the seller is&#13;
            // a contract with an invalid fallback function. We explicitly&#13;
            // guard against reentrancy attacks by removing the auction&#13;
            // before calling transfer(), and the only thing the seller&#13;
            // can DoS is the sale of their own asset! (And if it's an&#13;
            // accident, they can call cancelAuction(). )&#13;
            seller.transfer(sellerProceeds);&#13;
        }&#13;
&#13;
        // Calculate any excess funds included with the bid. If the excess&#13;
        // is anything worth worrying about, transfer it back to bidder.&#13;
        // NOTE: We checked above that the bid amount is greater than or&#13;
        // equal to the price so this cannot underflow.&#13;
        uint256 bidExcess = _bidAmount - price;&#13;
&#13;
        // Return the funds. Similar to the previous transfer, this is&#13;
        // not susceptible to a re-entry attack because the auction is&#13;
        // removed before any transfers occur.&#13;
        msg.sender.transfer(bidExcess);&#13;
&#13;
        // Tell the world!&#13;
        AuctionSuccessful(_tokenId, price, msg.sender);&#13;
&#13;
        return price;&#13;
    }&#13;
&#13;
    /// @dev Removes an auction from the list of open auctions.&#13;
    /// @param _tokenId - ID of NFT on auction.&#13;
    function _removeAuction(uint256 _tokenId) internal {&#13;
        delete tokenIdToAuction[_tokenId];&#13;
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
    function _currentPrice(Auction storage _auction)&#13;
        internal&#13;
        view&#13;
        returns (uint256)&#13;
    {&#13;
        uint256 secondsPassed = 0;&#13;
&#13;
        // A bit of insurance against negative values (or wraparound).&#13;
        // Probably not necessary (since Ethereum guarnatees that the&#13;
        // now variable doesn't ever go backwards).&#13;
        if (now &gt; _auction.startedAt) {&#13;
            secondsPassed = now - _auction.startedAt;&#13;
        }&#13;
&#13;
        return _computeCurrentPrice(&#13;
            _auction.startingPrice,&#13;
            _auction.endingPrice,&#13;
            _auction.duration,&#13;
            secondsPassed&#13;
        );&#13;
    }&#13;
&#13;
    /// @dev Computes the current price of an auction. Factored out&#13;
    ///  from _currentPrice so we can run extensive unit tests.&#13;
    ///  When testing, make this function public and turn on&#13;
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
        //  all of our public functions carefully cap the maximum values for&#13;
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
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);&#13;
&#13;
            // This multiplication can't overflow, _secondsPassed will easily fit within&#13;
            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product&#13;
            // will always fit within 256-bits.&#13;
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);&#13;
&#13;
            // currentPriceChange can be negative, but if so, will have a magnitude&#13;
            // less that _startingPrice. Thus, this result will always end up positive.&#13;
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;&#13;
&#13;
            return uint256(currentPrice);&#13;
        }&#13;
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
}&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Pausable&#13;
 * @dev Base contract which allows children to implement an emergency stop mechanism.&#13;
 */&#13;
contract Pausable is Ownable {&#13;
  event Pause();&#13;
  event Unpause();&#13;
&#13;
  bool public paused = false;&#13;
&#13;
&#13;
  /**&#13;
   * @dev modifier to allow actions only when the contract IS paused&#13;
   */&#13;
  modifier whenNotPaused() {&#13;
    require(!paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev modifier to allow actions only when the contract IS NOT paused&#13;
   */&#13;
  modifier whenPaused {&#13;
    require(paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to pause, triggers stopped state&#13;
   */&#13;
  function pause() onlyOwner whenNotPaused returns (bool) {&#13;
    paused = true;&#13;
    Pause();&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to unpause, returns to normal state&#13;
   */&#13;
  function unpause() onlyOwner whenPaused returns (bool) {&#13;
    paused = false;&#13;
    Unpause();&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
&#13;
/// @title Clock auction for non-fungible tokens.&#13;
/// @notice We omit a fallback function to prevent accidental sends to this contract.&#13;
contract ClockAuction is Pausable, ClockAuctionBase {&#13;
&#13;
    /// @dev The ERC-165 interface signature for ERC-721.&#13;
    ///  Ref: https://github.com/ethereum/EIPs/issues/165&#13;
    ///  Ref: https://github.com/ethereum/EIPs/issues/721&#13;
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);&#13;
&#13;
    /// @dev Constructor creates a reference to the NFT ownership contract&#13;
    ///  and verifies the owner cut is in the valid range.&#13;
    /// @param _nftAddress - address of a deployed contract implementing&#13;
    ///  the Nonfungible Interface.&#13;
    /// @param _cut - percent cut the owner takes on each auction, must be&#13;
    ///  between 0-10,000.&#13;
    function ClockAuction(address _nftAddress, uint256 _cut) public {&#13;
        require(_cut &lt;= 10000);&#13;
        ownerCut = _cut;&#13;
&#13;
        ERC721 candidateContract = ERC721(_nftAddress);&#13;
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));&#13;
        nonFungibleContract = candidateContract;&#13;
    }&#13;
&#13;
    /// @dev Remove all Ether from the contract, which is the owner's cuts&#13;
    ///  as well as any Ether sent directly to the contract address.&#13;
    ///  Always transfers to the NFT contract, but can be called either by&#13;
    ///  the owner or the NFT contract.&#13;
    function withdrawBalance() external {&#13;
        address nftAddress = address(nonFungibleContract);&#13;
&#13;
        require(&#13;
            msg.sender == owner ||&#13;
            msg.sender == nftAddress&#13;
        );&#13;
        // We are using this boolean method to make sure that even if one fails it will still work&#13;
        bool res = nftAddress.send(this.balance);&#13;
    }&#13;
&#13;
    /// @dev Creates and begins a new auction.&#13;
    /// @param _tokenId - ID of token to auction, sender must be owner.&#13;
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.&#13;
    /// @param _endingPrice - Price of item (in wei) at end of auction.&#13;
    /// @param _duration - Length of time to move between starting&#13;
    ///  price and ending price (in seconds).&#13;
    /// @param _seller - Seller, if not the message sender&#13;
    function createAuction(&#13;
        uint256 _tokenId,&#13;
        uint256 _startingPrice,&#13;
        uint256 _endingPrice,&#13;
        uint256 _duration,&#13;
        address _seller&#13;
    )&#13;
        external&#13;
        whenNotPaused&#13;
    {&#13;
        // Sanity check that no inputs overflow how many bits we've allocated&#13;
        // to store them in the auction struct.&#13;
        require(_startingPrice == uint256(uint128(_startingPrice)));&#13;
        require(_endingPrice == uint256(uint128(_endingPrice)));&#13;
        require(_duration == uint256(uint64(_duration)));&#13;
&#13;
        require(_owns(msg.sender, _tokenId));&#13;
        _escrow(msg.sender, _tokenId);&#13;
        Auction memory auction = Auction(&#13;
            _seller,&#13;
            uint128(_startingPrice),&#13;
            uint128(_endingPrice),&#13;
            uint64(_duration),&#13;
            uint64(now)&#13;
        );&#13;
        _addAuction(_tokenId, auction);&#13;
    }&#13;
&#13;
    /// @dev Bids on an open auction, completing the auction and transferring&#13;
    ///  ownership of the NFT if enough Ether is supplied.&#13;
    /// @param _tokenId - ID of token to bid on.&#13;
    function bid(uint256 _tokenId)&#13;
        external&#13;
        payable&#13;
        whenNotPaused&#13;
    {&#13;
        // _bid will throw if the bid or funds transfer fails&#13;
        _bid(_tokenId, msg.value);&#13;
        _transfer(msg.sender, _tokenId);&#13;
    }&#13;
&#13;
    /// @dev Cancels an auction that hasn't been won yet.&#13;
    ///  Returns the NFT to original owner.&#13;
    /// @notice This is a state-modifying function that can&#13;
    ///  be called while the contract is paused.&#13;
    /// @param _tokenId - ID of token on auction&#13;
    function cancelAuction(uint256 _tokenId)&#13;
        external&#13;
    {&#13;
        Auction storage auction = tokenIdToAuction[_tokenId];&#13;
        require(_isOnAuction(auction));&#13;
        address seller = auction.seller;&#13;
        require(msg.sender == seller);&#13;
        _cancelAuction(_tokenId, seller);&#13;
    }&#13;
&#13;
    /// @dev Cancels an auction when the contract is paused.&#13;
    ///  Only the owner may do this, and NFTs are returned to&#13;
    ///  the seller. This should only be used in emergencies.&#13;
    /// @param _tokenId - ID of the NFT on auction to cancel.&#13;
    function cancelAuctionWhenPaused(uint256 _tokenId)&#13;
        whenPaused&#13;
        onlyOwner&#13;
        external&#13;
    {&#13;
        Auction storage auction = tokenIdToAuction[_tokenId];&#13;
        require(_isOnAuction(auction));&#13;
        _cancelAuction(_tokenId, auction.seller);&#13;
    }&#13;
&#13;
    /// @dev Returns auction info for an NFT on auction.&#13;
    /// @param _tokenId - ID of NFT on auction.&#13;
    function getAuction(uint256 _tokenId)&#13;
        external&#13;
        view&#13;
        returns&#13;
    (&#13;
        address seller,&#13;
        uint256 startingPrice,&#13;
        uint256 endingPrice,&#13;
        uint256 duration,&#13;
        uint256 startedAt&#13;
    ) {&#13;
        Auction storage auction = tokenIdToAuction[_tokenId];&#13;
        require(_isOnAuction(auction));&#13;
        return (&#13;
            auction.seller,&#13;
            auction.startingPrice,&#13;
            auction.endingPrice,&#13;
            auction.duration,&#13;
            auction.startedAt&#13;
        );&#13;
    }&#13;
&#13;
    /// @dev Returns the current price of an auction.&#13;
    /// @param _tokenId - ID of the token price we are checking.&#13;
    function getCurrentPrice(uint256 _tokenId)&#13;
        external&#13;
        view&#13;
        returns (uint256)&#13;
    {&#13;
        Auction storage auction = tokenIdToAuction[_tokenId];&#13;
        require(_isOnAuction(auction));&#13;
        return _currentPrice(auction);&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
/// @title Clock auction modified for sale of kitties&#13;
/// @notice We omit a fallback function to prevent accidental sends to this contract.&#13;
contract SaleClockAuction is ClockAuction {&#13;
&#13;
    // @dev Sanity check that allows us to ensure that we are pointing to the&#13;
    //  right auction in our setSaleAuctionAddress() call.&#13;
    bool public isSaleClockAuction = true;&#13;
    &#13;
    // Tracks last 5 sale price of gen0 kitty sales&#13;
    uint256 public gen0SaleCount;&#13;
    uint256[5] public lastGen0SalePrices;&#13;
&#13;
    // Delegate constructor&#13;
    function SaleClockAuction(address _nftAddr, uint256 _cut) public&#13;
        ClockAuction(_nftAddr, _cut) {}&#13;
&#13;
    /// @dev Creates and begins a new auction.&#13;
    /// @param _tokenId - ID of token to auction, sender must be owner.&#13;
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.&#13;
    /// @param _endingPrice - Price of item (in wei) at end of auction.&#13;
    /// @param _duration - Length of auction (in seconds).&#13;
    /// @param _seller - Seller, if not the message sender&#13;
    function createAuction(&#13;
        uint256 _tokenId,&#13;
        uint256 _startingPrice,&#13;
        uint256 _endingPrice,&#13;
        uint256 _duration,&#13;
        address _seller&#13;
    )&#13;
        external&#13;
    {&#13;
        // Sanity check that no inputs overflow how many bits we've allocated&#13;
        // to store them in the auction struct.&#13;
        require(_startingPrice == uint256(uint128(_startingPrice)));&#13;
        require(_endingPrice == uint256(uint128(_endingPrice)));&#13;
        require(_duration == uint256(uint64(_duration)));&#13;
&#13;
        require(msg.sender == address(nonFungibleContract));&#13;
        _escrow(_seller, _tokenId);&#13;
        Auction memory auction = Auction(&#13;
            _seller,&#13;
            uint128(_startingPrice),&#13;
            uint128(_endingPrice),&#13;
            uint64(_duration),&#13;
            uint64(now)&#13;
        );&#13;
        _addAuction(_tokenId, auction);&#13;
    }&#13;
&#13;
    /// @dev Updates lastSalePrice if seller is the nft contract&#13;
    /// Otherwise, works the same as default bid method.&#13;
    function bid(uint256 _tokenId)&#13;
        external&#13;
        payable&#13;
    {&#13;
        // _bid verifies token ID size&#13;
        address seller = tokenIdToAuction[_tokenId].seller;&#13;
        uint256 price = _bid(_tokenId, msg.value);&#13;
        _transfer(msg.sender, _tokenId);&#13;
&#13;
        // If not a gen0 auction, exit&#13;
        if (seller == address(nonFungibleContract)) {&#13;
            // Track gen0 sale prices&#13;
            lastGen0SalePrices[gen0SaleCount % 5] = price;&#13;
            gen0SaleCount++;&#13;
        }&#13;
    }&#13;
&#13;
    function averageGen0SalePrice() external view returns (uint256) {&#13;
        uint256 sum = 0;&#13;
        for (uint256 i = 0; i &lt; 5; i++) {&#13;
            sum += lastGen0SalePrices[i];&#13;
        }&#13;
        return sum / 5;&#13;
    }&#13;
&#13;
}