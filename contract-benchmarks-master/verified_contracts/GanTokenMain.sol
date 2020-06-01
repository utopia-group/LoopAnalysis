pragma solidity ^0.4.21;

/// @title ERC-165 Standard Interface Detection
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}


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







/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
contract ERC721 is ERC165 {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

/// @title ERC-721 Non-Fungible Token Standard
interface ERC721TokenReceiver {
	function onERC721Received(address _from, uint256 _tokenId, bytes data) external returns(bytes4);
}

/// @title ERC-721 Non-Fungible Token Standard, optional metadata extension
interface ERC721Metadata /* is ERC721 */ {
    function name() external pure returns (string _name);
    function symbol() external pure returns (string _symbol);
    function tokenURI(uint256 _tokenId) external view returns (string);
}

/// @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
interface ERC721Enumerable /* is ERC721 */ {
    function totalSupply() external view returns (uint256);
    function tokenByIndex(uint256 _index) external view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}





/// @title A reusable contract to comply with ERC-165
/// @author William Entriken (https://phor.net)
contract PublishInterfaces is ERC165 {
    /// @dev Every interface that we support
    mapping(bytes4 => bool) internal supportedInterfaces;

    function PublishInterfaces() internal {
        supportedInterfaces[0x01ffc9a7] = true; // ERC165
    }

    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return supportedInterfaces[interfaceID] && (interfaceID != 0xffffffff);
    }
}




/// @title The external contract that is responsible for generating metadata for GanTokens,
///  it has one function that will return the data as bytes.
contract Metadata {

    /// @dev Given a token Id, returns a string with metadata
    function getMetadata(uint256 _tokenId, string) public pure returns (bytes32[4] buffer, uint256 count) {
        if (_tokenId == 1) {
            buffer[0] = "Hello World! :D";
            count = 15;
        } else if (_tokenId == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            count = 49;
        } else if (_tokenId == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            count = 128;
        }
    }

}


contract GanNFT is ERC165, ERC721, ERC721Enumerable, PublishInterfaces, Ownable {

  function GanNFT() internal {
      supportedInterfaces[0x80ac58cd] = true; // ERC721
      supportedInterfaces[0x5b5e139f] = true; // ERC721Metadata
      supportedInterfaces[0x780e9d63] = true; // ERC721Enumerable
      supportedInterfaces[0x8153916a] = true; // ERC721 + 165 (not needed)
  }

  bytes4 private constant ERC721_RECEIVED = bytes4(keccak256("onERC721Received(address,uint256,bytes)"));

  // @dev claim price taken for each new GanToken
  // generating a new token will be free in the beinging and later changed
  uint256 public claimPrice = 0;

  // @dev max supply for token
  uint256 public maxSupply = 300;

  // The contract that will return tokens metadata
  Metadata public erc721Metadata;

  /// @dev list of all owned token ids
  uint256[] public tokenIds;

  /// @dev a mpping for all tokens
  mapping(uint256 => address) public tokenIdToOwner;

  /// @dev mapping to keep owner balances
  mapping(address => uint256) public ownershipCounts;

  /// @dev mapping to owners to an array of tokens that they own
  mapping(address => uint256[]) public ownerBank;

  /// @dev mapping to approved ids
  mapping(uint256 => address) public tokenApprovals;

  /// @dev The authorized operators for each address
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  /// @notice A descriptive name for a collection of NFTs in this contract
  function name() external pure returns (string) {
      return "GanToken";
  }

  /// @notice An abbreviated name for NFTs in this contract
  function symbol() external pure returns (string) {
      return "GT";
  }

  /// @dev Set the address of the sibling contract that tracks metadata.
  /// Only the contract creater can call this.
  /// @param _contractAddress The location of the contract with meta data
  function setMetadataAddress(address _contractAddress) public onlyOwner {
      erc721Metadata = Metadata(_contractAddress);
  }

  modifier canTransfer(uint256 _tokenId, address _from, address _to) {
    address owner = tokenIdToOwner[_tokenId];
    require(tokenApprovals[_tokenId] == _to || owner == _from || operatorApprovals[_to][_to]);
    _;
  }
  /// @notice checks to see if a sender owns a _tokenId
  /// @param _tokenId The identifier for an NFT
  modifier owns(uint256 _tokenId) {
    require(tokenIdToOwner[_tokenId] == msg.sender);
    _;
  }

  /// @dev This emits any time the ownership of a GanToken changes.
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  /// @dev This emits when the approved addresses for a GanToken is changed or reaffirmed.
  /// The zero address indicates there is no owner and it get reset on a transfer
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  /// @dev This emits when an operator is enabled or disabled for an owner.
  ///  The operator can manage all NFTs of the owner.
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  /// @notice allow the owner to set the supply max
  function setMaxSupply(uint max) external payable onlyOwner {
    require(max > tokenIds.length);

    maxSupply = max;
  }

  /// @notice allow the owner to set a new fee for creating a GanToken
  function setClaimPrice(uint256 price) external payable onlyOwner {
    claimPrice = price;
  }

  /// @dev Required for ERC-721 compliance.
  function balanceOf(address _owner) external view returns (uint256 balance) {
    balance = ownershipCounts[_owner];
  }

  /// @notice Gets the onwner of a an NFT
  /// @param _tokenId The identifier for an NFT
  /// @dev Required for ERC-721 compliance.
  function ownerOf(uint256 _tokenId) external view returns (address owner) {
    owner = tokenIdToOwner[_tokenId];
  }

  /// @notice returns all owners' tokens will return an empty array
  /// if the address has no tokens
  /// @param _owner The address of the owner in question
  function tokensOfOwner(address _owner) external view returns (uint256[]) {
    uint256 tokenCount = ownershipCounts[_owner];

    if (tokenCount == 0) {
      return new uint256[](0);
    }

    uint256[] memory result = new uint256[](tokenCount);

    for (uint256 i = 0; i < tokenCount; i++) {
      result[i] = ownerBank[_owner][i];
    }

    return result;
  }

  /// @dev creates a list of all the tokenIds
  function getAllTokenIds() external view returns (uint256[]) {
    uint256[] memory result = new uint256[](tokenIds.length);
    for (uint i = 0; i < result.length; i++) {
      result[i] = tokenIds[i];
    }

    return result;
  }

  /// @notice Create a new GanToken with a id and attaches an owner
  /// @param _noise The id of the token that's being created
  function newGanToken(uint256 _noise) external payable {
    require(msg.sender != address(0));
    require(tokenIdToOwner[_noise] == 0x0);
    require(tokenIds.length < maxSupply);
    require(msg.value >= claimPrice);

    tokenIds.push(_noise);
    ownerBank[msg.sender].push(_noise);
    tokenIdToOwner[_noise] = msg.sender;
    ownershipCounts[msg.sender]++;

    emit Transfer(address(0), msg.sender, 0);
  }

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
  /// @param data Additional data with no specified format, sent in call to `_to`
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public payable
  {
      _safeTransferFrom(_from, _to, _tokenId, data);
  }

  /// @notice Transfers the ownership of an NFT from one address to another address
  /// @dev This works identically to the other function with an extra data parameter,
  ///  except this function just sets data to ""
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable
  {
      _safeTransferFrom(_from, _to, _tokenId, "");
  }

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
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
    require(_to != 0x0);
    require(_to != address(this));
    require(tokenApprovals[_tokenId] == msg.sender);
    require(tokenIdToOwner[_tokenId] == _from);

    _transfer(_tokenId, _to);
  }

  /// @notice Grant another address the right to transfer a specific token via
  ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
  /// @dev The zero address indicates there is no approved address.
  /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized
  ///  operator of the current owner.
  /// @dev Required for ERC-721 compliance.
  /// @param _to The address to be granted transfer approval. Pass address(0) to
  ///  clear all approvals.
  /// @param _tokenId The ID of the Kitty that can be transferred if this call succeeds.
  function approve(address _to, uint256 _tokenId) external owns(_tokenId) payable {
      // Register the approval (replacing any previous approval).
      tokenApprovals[_tokenId] = _to;

      emit Approval(msg.sender, _to, _tokenId);
  }

  /// @notice Enable or disable approval for a third party ("operator") to manage
  ///  all your asset.
  /// @dev Emits the ApprovalForAll event
  /// @param _operator Address to add to the set of authorized operators.
  /// @param _approved True if the operators is approved, false to revoke approval
  function setApprovalForAll(address _operator, bool _approved) external {
      operatorApprovals[msg.sender][_operator] = _approved;
      emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  /// @notice Get the approved address for a single NFT
  /// @param _tokenId The NFT to find the approved address for
  /// @return The approved address for this NFT, or the zero address if there is none
  function getApproved(uint256 _tokenId) external view returns (address) {
      return tokenApprovals[_tokenId];
  }

  /// @notice Query if an address is an authorized operator for another address
  /// @param _owner The address that owns the NFTs
  /// @param _operator The address that acts on behalf of the owner
  /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
  function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
      return operatorApprovals[_owner][_operator];
  }

  /// @notice Count NFTs tracked by this contract
  /// @return A count of valid NFTs tracked by this contract, where each one of
  ///  them has an assigned and queryable owner not equal to the zero address
  /// @dev Required for ERC-721 compliance.
  function totalSupply() external view returns (uint256) {
    return tokenIds.length;
  }

  /// @notice Enumerate valid NFTs
  /// @param _index A counter less than `totalSupply()`
  /// @return The token identifier for index the `_index`th NFT 0 if it doesn't exist,
  function tokenByIndex(uint256 _index) external view returns (uint256) {
      return tokenIds[_index];
  }

  /// @notice Enumerate NFTs assigned to an owner
  /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
  ///  `_owner` is the zero address, representing invalid NFTs.
  /// @param _owner An address where we are interested in NFTs owned by them
  /// @param _index A counter less than `balanceOf(_owner)`
  /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
  ///   (sort order not specified)
  function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _tokenId) {
      require(_owner != address(0));
      require(_index < ownerBank[_owner].length);
      _tokenId = ownerBank[_owner][_index];
  }

  function _transfer(uint256 _tokenId, address _to) internal {
    require(_to != address(0));

    address from = tokenIdToOwner[_tokenId];
    uint256 tokenCount = ownershipCounts[from];
    // remove from ownerBank and replace the deleted token id
    for (uint256 i = 0; i < tokenCount; i++) {
      uint256 ownedId = ownerBank[from][i];
      if (_tokenId == ownedId) {
        delete ownerBank[from][i];
        if (i != tokenCount) {
          ownerBank[from][i] = ownerBank[from][tokenCount - 1];
        }
        break;
      }
    }

    ownershipCounts[from]--;
    ownershipCounts[_to]++;
    ownerBank[_to].push(_tokenId);

    tokenIdToOwner[_tokenId] = _to;
    tokenApprovals[_tokenId] = address(0);
    emit Transfer(from, _to, 1);
  }

  /// @dev Actually perform the safeTransferFrom
  function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data)
      private
      canTransfer(_tokenId, _from, _to)
  {
      address owner = tokenIdToOwner[_tokenId];

      require(owner == _from);
      require(_to != address(0));
      require(_to != address(this));
      _transfer(_tokenId, _to);


      // Do the callback after everything is done to avoid reentrancy attack
      uint256 codeSize;
      assembly { codeSize := extcodesize(_to) }
      if (codeSize == 0) {
          return;
      }
      bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(_from, _tokenId, data);
      require(retval == ERC721_RECEIVED);
  }

  /// @dev Adapted from memcpy() by @arachnid (Nick Johnson <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="adccdfcccec5c3c4c9edc3c2d9c9c2d983c3c8d9">[email protected]</a>&gt;)&#13;
  ///  This method is licenced under the Apache License.&#13;
  ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol&#13;
  function _memcpy(uint _dest, uint _src, uint _len) private pure {&#13;
      // Copy word-length chunks while possible&#13;
      for(; _len &gt;= 32; _len -= 32) {&#13;
          assembly {&#13;
              mstore(_dest, mload(_src))&#13;
          }&#13;
          _dest += 32;&#13;
          _src += 32;&#13;
      }&#13;
&#13;
      // Copy remaining bytes&#13;
      uint256 mask = 256 ** (32 - _len) - 1;&#13;
      assembly {&#13;
          let srcpart := and(mload(_src), not(mask))&#13;
          let destpart := and(mload(_dest), mask)&#13;
          mstore(_dest, or(destpart, srcpart))&#13;
      }&#13;
  }&#13;
&#13;
  /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b7d6c5d6d4dfd9ded3f7d9d8c3d3d8c399d9d2c3">[email protected]</a>&gt;)&#13;
  ///  This method is licenced under the Apache License.&#13;
  ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol&#13;
  function _toString(bytes32[4] _rawBytes, uint256 _stringLength) private pure returns (string) {&#13;
      string memory outputString = new string(_stringLength);&#13;
      uint256 outputPtr;&#13;
      uint256 bytesPtr;&#13;
&#13;
      assembly {&#13;
          outputPtr := add(outputString, 32)&#13;
          bytesPtr := _rawBytes&#13;
      }&#13;
&#13;
      _memcpy(outputPtr, bytesPtr, _stringLength);&#13;
&#13;
      return outputString;&#13;
  }&#13;
&#13;
&#13;
  /// @notice Returns a URI pointing to a metadata package for this token conforming to&#13;
  ///  ERC-721 (https://github.com/ethereum/EIPs/issues/721)&#13;
  /// @param _tokenId The ID number of the GanToken whose metadata should be returned.&#13;
  function tokenMetadata(uint256 _tokenId, string _preferredTransport) external view returns (string infoUrl) {&#13;
      require(erc721Metadata != address(0));&#13;
      uint256 count;&#13;
      bytes32[4] memory buffer;&#13;
&#13;
      (buffer, count) = erc721Metadata.getMetadata(_tokenId, _preferredTransport);&#13;
&#13;
      return _toString(buffer, count);&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
contract GanTokenMain is GanNFT {&#13;
&#13;
  struct Offer {&#13;
    bool isForSale;&#13;
    uint256 tokenId;&#13;
    address seller;&#13;
    uint value;          // in ether&#13;
    address onlySellTo;     // specify to sell only to a specific person&#13;
  }&#13;
&#13;
  struct Bid {&#13;
    bool hasBid;&#13;
    uint256 tokenId;&#13;
    address bidder;&#13;
    uint value;&#13;
  }&#13;
&#13;
  /// @dev mapping of balances for address&#13;
  mapping(address =&gt; uint256) public pendingWithdrawals;&#13;
&#13;
  /// @dev mapping of tokenId to to an offer&#13;
  mapping(uint256 =&gt; Offer) public ganTokenOfferedForSale;&#13;
&#13;
  /// @dev mapping bids to tokenIds&#13;
  mapping(uint256 =&gt; Bid) public tokenBids;&#13;
&#13;
  event BidForGanTokenOffered(uint256 tokenId, uint256 value, address sender);&#13;
  event BidWithdrawn(uint256 tokenId, uint256 value, address bidder);&#13;
  event GanTokenOfferedForSale(uint256 tokenId, uint256 minSalePriceInWei, address onlySellTo);&#13;
  event GanTokenNoLongerForSale(uint256 tokenId);&#13;
&#13;
&#13;
  /// @notice Allow a token owner to pull sale&#13;
  /// @param tokenId The id of the token that's created&#13;
  function ganTokenNoLongerForSale(uint256 tokenId) public payable owns(tokenId) {&#13;
    ganTokenOfferedForSale[tokenId] = Offer(false, tokenId, msg.sender, 0, 0x0);&#13;
&#13;
    emit GanTokenNoLongerForSale(tokenId);&#13;
  }&#13;
&#13;
  /// @notice Put a token up for sale&#13;
  /// @param tokenId The id of the token that's created&#13;
  /// @param minSalePriceInWei desired price of token&#13;
  function offerGanTokenForSale(uint tokenId, uint256 minSalePriceInWei) external payable owns(tokenId) {&#13;
    ganTokenOfferedForSale[tokenId] = Offer(true, tokenId, msg.sender, minSalePriceInWei, 0x0);&#13;
&#13;
    emit GanTokenOfferedForSale(tokenId, minSalePriceInWei, 0x0);&#13;
  }&#13;
&#13;
  /// @notice Create a new GanToken with a id and attaches an owner&#13;
  /// @param tokenId The id of the token that's being created&#13;
  function offerGanTokenForSaleToAddress(uint tokenId, address sendTo, uint256 minSalePriceInWei) external payable {&#13;
    require(tokenIdToOwner[tokenId] == msg.sender);&#13;
    ganTokenOfferedForSale[tokenId] = Offer(true, tokenId, msg.sender, minSalePriceInWei, sendTo);&#13;
&#13;
    emit GanTokenOfferedForSale(tokenId, minSalePriceInWei, sendTo);&#13;
  }&#13;
&#13;
  /// @notice Allows an account to buy a NFT gan token that is up for offer&#13;
  /// the token owner must set onlySellTo to the sender&#13;
  /// @param id the id of the token&#13;
  function buyGanToken(uint256 id) public payable {&#13;
    Offer memory offer = ganTokenOfferedForSale[id];&#13;
    require(offer.isForSale);&#13;
    require(offer.onlySellTo == msg.sender &amp;&amp; offer.onlySellTo != 0x0);&#13;
    require(msg.value == offer.value);&#13;
    require(tokenIdToOwner[id] == offer.seller);&#13;
&#13;
    safeTransferFrom(offer.seller, offer.onlySellTo, id);&#13;
&#13;
    ganTokenOfferedForSale[id] = Offer(false, id, offer.seller, 0, 0x0);&#13;
&#13;
    pendingWithdrawals[offer.seller] += msg.value;&#13;
  }&#13;
&#13;
  /// @notice Allows an account to enter a higher bid on a toekn&#13;
  /// @param tokenId the id of the token&#13;
  function enterBidForGanToken(uint256 tokenId) external payable {&#13;
    Bid memory existing = tokenBids[tokenId];&#13;
    require(tokenIdToOwner[tokenId] != msg.sender);&#13;
    require(tokenIdToOwner[tokenId] != 0x0);&#13;
    require(msg.value &gt; existing.value);&#13;
    if (existing.value &gt; 0) {&#13;
      // Refund the failing bid&#13;
      pendingWithdrawals[existing.bidder] += existing.value;&#13;
    }&#13;
&#13;
    tokenBids[tokenId] = Bid(true, tokenId, msg.sender, msg.value);&#13;
    emit BidForGanTokenOffered(tokenId, msg.value, msg.sender);&#13;
  }&#13;
&#13;
  /// @notice Allows the owner of a token to accept an outstanding bid for that token&#13;
  /// @param tokenId The id of the token that's being created&#13;
  /// @param price The desired price of token in wei&#13;
  function acceptBid(uint256 tokenId, uint256 price) external payable {&#13;
    require(tokenIdToOwner[tokenId] == msg.sender);&#13;
    Bid memory bid = tokenBids[tokenId];&#13;
    require(bid.value != 0);&#13;
    require(bid.value == price);&#13;
&#13;
    safeTransferFrom(msg.sender, bid.bidder, tokenId);&#13;
&#13;
    tokenBids[tokenId] = Bid(false, tokenId, address(0), 0);&#13;
    pendingWithdrawals[msg.sender] += bid.value;&#13;
  }&#13;
&#13;
  /// @notice Check is a given id is on sale&#13;
  /// @param tokenId The id of the token in question&#13;
  /// @return a bool whether of not the token is on sale&#13;
  function isOnSale(uint256 tokenId) external view returns (bool) {&#13;
    return ganTokenOfferedForSale[tokenId].isForSale;&#13;
  }&#13;
&#13;
  /// @notice Gets all the sale data related to a token&#13;
  /// @param tokenId The id of the token&#13;
  /// @return sale information&#13;
  function getSaleData(uint256 tokenId) public view returns (bool isForSale, address seller, uint value, address onlySellTo) {&#13;
    Offer memory offer = ganTokenOfferedForSale[tokenId];&#13;
    isForSale = offer.isForSale;&#13;
    seller = offer.seller;&#13;
    value = offer.value;&#13;
    onlySellTo = offer.onlySellTo;&#13;
  }&#13;
&#13;
  /// @notice Gets all the bid data related to a token&#13;
  /// @param tokenId The id of the token&#13;
  /// @return bid information&#13;
  function getBidData(uint256 tokenId) view public returns (bool hasBid, address bidder, uint value) {&#13;
    Bid memory bid = tokenBids[tokenId];&#13;
    hasBid = bid.hasBid;&#13;
    bidder = bid.bidder;&#13;
    value = bid.value;&#13;
  }&#13;
&#13;
  /// @notice Allows a bidder to withdraw their bid&#13;
  /// @param tokenId The id of the token&#13;
  function withdrawBid(uint256 tokenId) external payable {&#13;
      Bid memory bid = tokenBids[tokenId];&#13;
      require(tokenIdToOwner[tokenId] != msg.sender);&#13;
      require(tokenIdToOwner[tokenId] != 0x0);&#13;
      require(bid.bidder == msg.sender);&#13;
&#13;
      emit BidWithdrawn(tokenId, bid.value, msg.sender);&#13;
      uint amount = bid.value;&#13;
      tokenBids[tokenId] = Bid(false, tokenId, 0x0, 0);&#13;
      // Refund the bid money&#13;
      msg.sender.transfer(amount);&#13;
  }&#13;
&#13;
  /// @notice Allows a sender to withdraw any amount in the contrat&#13;
  function withdraw() external {&#13;
    uint256 amount = pendingWithdrawals[msg.sender];&#13;
    // Remember to zero the pending refund before&#13;
    // sending to prevent re-entrancy attacks&#13;
    pendingWithdrawals[msg.sender] = 0;&#13;
    msg.sender.transfer(amount);&#13;
  }&#13;
&#13;
}