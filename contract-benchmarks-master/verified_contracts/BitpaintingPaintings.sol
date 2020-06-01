pragma solidity ^0.4.15;

// File: contracts/interfaces/IAuctions.sol

contract IAuctions {

    function currentPrice(uint _tokenId) public constant returns (uint256);
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration) public;
    function createReleaseAuction(
        uint _tokenId,
        uint _startingPrice,
        uint _endingPrice,
        uint _startedAt,
        uint _duration) public;
    function cancelAuction(uint256 _tokenId) external;
    function cancelAuctionWhenPaused(uint256 _tokenId) external;
    function bid(uint256 _tokenId, address _owner) external payable;
    function market() public constant returns (
        uint[] tokens,
        address[] sellers,
        uint8[] generations,
        uint8[] speeds,
        uint[] prices
    );
    function auctionsOf(address _of) public constant returns (
        uint[] tokens,
        uint[] prices
    );
    function signature() external constant returns (uint _signature);
}

// File: contracts/interfaces/IPaintings.sol

contract IPaintings {
    function createPainting(uint _tokenId) external;
    function sendAsGift(address _to, uint _tokenId) external;
    function collectionOf(address _of) public constant returns (
        uint[] tokens,
        bool[] pending,
        bool[] forSale,
        bool[] locked,
        uint8[] generations,
        uint8[] speeds
    );
    function collectionCountsOf(address _of)
        public constant returns (uint total, uint pending, uint forSale);
    function signature() external constant returns (uint _signature);
}

// File: contracts/interfaces/IStorage.sol

contract IStorage {
    function isOwner(address _address) public constant returns (bool);

    function isAllowed(address _address) external constant returns (bool);
    function developer() public constant returns (address);
    function setDeveloper(address _address) public;
    function addAdmin(address _address) public;
    function isAdmin(address _address) public constant returns (bool);
    function removeAdmin(address _address) public;
    function contracts(uint _signature) public returns (address _address);

    function exists(uint _tokenId) external constant returns (bool);
    function paintingsCount() public constant returns (uint);
    function increaseOwnershipTokenCount(address _address) public;
    function decreaseOwnershipTokenCount(address _address) public;
    function setOwnership(uint _tokenId, address _address) public;
    function getPainting(uint _tokenId)
        external constant returns (address, uint, uint, uint, uint8, uint8);
    function createPainting(
        address _owner,
        uint _tokenId,
        uint _parentId,
        uint8 _generation,
        uint8 _speed,
        uint _artistId,
        uint _releasedAt) public;
    function approve(uint _tokenId, address _claimant) external;
    function isApprovedFor(uint _tokenId, address _claimant)
        external constant returns (bool);
    function createEditionMeta(uint _tokenId) public;
    function getPaintingOwner(uint _tokenId)
        external constant returns (address);
    function getPaintingGeneration(uint _tokenId)
        public constant returns (uint8);
    function getPaintingSpeed(uint _tokenId)
        external constant returns (uint8);
    function getPaintingArtistId(uint _tokenId)
        public constant returns (uint artistId);
    function getOwnershipTokenCount(address _address)
        external constant returns (uint);
    function isReady(uint _tokenId) public constant returns (bool);
    function getPaintingIdAtIndex(uint _index) public constant returns (uint);
    function lastEditionOf(uint _index) public constant returns (uint);
    function getPaintingOriginal(uint _tokenId)
        external constant returns (uint);
    function canBeBidden(uint _tokenId) public constant returns (bool _can);

    function addAuction(
        uint _tokenId,
        uint _startingPrice,
        uint _endingPrice,
        uint _duration,
        address _seller) public;
    function addReleaseAuction(
        uint _tokenId,
        uint _startingPrice,
        uint _endingPrice,
        uint _startedAt,
        uint _duration) public;
    function initAuction(
        uint _tokenId,
        uint _startingPrice,
        uint _endingPrice,
        uint _startedAt,
        uint _duration,
        address _seller,
        bool _byTeam) public;
    function _isOnAuction(uint _tokenId) internal constant returns (bool);
    function isOnAuction(uint _tokenId) external constant returns (bool);
    function removeAuction(uint _tokenId) public;
    function getAuction(uint256 _tokenId)
        external constant returns (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt);
    function getAuctionSeller(uint256 _tokenId)
        public constant returns (address);
    function getAuctionEnd(uint _tokenId)
        public constant returns (uint);
    function canBeCanceled(uint _tokenId) external constant returns (bool);
    function getAuctionsCount() public constant returns (uint);
    function getTokensOnAuction() public constant returns (uint[]);
    function getTokenIdAtIndex(uint _index) public constant returns (uint);
    function getAuctionStartedAt(uint256 _tokenId) public constant returns (uint);

    function getOffsetIndex() public constant returns (uint);
    function nextOffsetIndex() public returns (uint);
    function canCreateEdition(uint _tokenId, uint8 _generation)
        public constant returns (bool);
    function isValidGeneration(uint8 _generation)
        public constant returns (bool);
    function increaseGenerationCount(uint _tokenId, uint8 _generation) public;
    function getEditionsCount(uint _tokenId) external constant returns (uint8[3]);
    function setLastEditionOf(uint _tokenId, uint _editionId) public;
    function setEditionLimits(uint _tokenId, uint8 _gen1, uint8 _gen2, uint8 _gen3) public;
    function getEditionLimits(uint _tokenId) external constant returns (uint8[3]);

    function hasEditionInProgress(uint _tokenId) external constant returns (bool);
    function hasEmptyEditionSlots(uint _tokenId) external constant returns (bool);

    function setPaintingName(uint _tokenId, string _name) public;
    function setPaintingArtist(uint _tokenId, string _name) public;
    function purgeInformation(uint _tokenId) public;
    function resetEditionLimits(uint _tokenId) public;
    function resetPainting(uint _tokenId) public;
    function decreaseSpeed(uint _tokenId) public;
    function isCanceled(uint _tokenId) public constant returns (bool _is);
    function totalPaintingsCount() public constant returns (uint _total);
    function isSecondary(uint _tokenId) public constant returns (bool _is);
    function secondarySaleCut() public constant returns (uint8 _cut);
    function sealForChanges(uint _tokenId) public;
    function canBeChanged(uint _tokenId) public constant returns (bool _can);

    function getPaintingName(uint _tokenId) public constant returns (string);
    function getPaintingArtist(uint _tokenId) public constant returns (string);

    function signature() external constant returns (bytes4);
}

// File: contracts/libs/Ownable.sol

/**
* @title Ownable
* @dev Manages ownership of the contracts
*/
contract Ownable {

    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function isOwner(address _address) public constant returns (bool) {
        return _address == owner;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }

}

// File: contracts/libs/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
    * @dev modifier to allow actions only when the contract IS paused
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev modifier to allow actions only when the contract IS NOT paused
    */
    modifier whenPaused {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function _pause() internal whenNotPaused {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function _unpause() internal whenPaused {
        paused = false;
        Unpause();
    }
}

// File: contracts/libs/BitpaintingBase.sol

contract BitpaintingBase is Pausable {
    /*** EVENTS ***/
    event Create(uint _tokenId,
        address _owner,
        uint _parentId,
        uint8 _generation,
        uint _createdAt,
        uint _completedAt);

    event Transfer(address from, address to, uint256 tokenId);

    IStorage public bitpaintingStorage;

    modifier canPauseUnpause() {
        require(msg.sender == owner || msg.sender == bitpaintingStorage.developer());
        _;
    }

    function setBitpaintingStorage(address _address) public onlyOwner {
        require(_address != address(0));
        bitpaintingStorage = IStorage(_address);
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public canPauseUnpause whenNotPaused {
        super._pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() external canPauseUnpause whenPaused {
        super._unpause();
    }

    function canUserReleaseArtwork(address _address)
        public constant returns (bool _can) {
        return (bitpaintingStorage.isOwner(_address)
            || bitpaintingStorage.isAdmin(_address)
            || bitpaintingStorage.isAllowed(_address));
    }

    function canUserCancelArtwork(address _address)
        public constant returns (bool _can) {
        return (bitpaintingStorage.isOwner(_address)
            || bitpaintingStorage.isAdmin(_address));
    }

    modifier canReleaseArtwork() {
        require(canUserReleaseArtwork(msg.sender));
        _;
    }

    modifier canCancelArtwork() {
        require(canUserCancelArtwork(msg.sender));
        _;
    }

    /// @dev Assigns ownership of a specific Painting to an address.
    function _transfer(address _from, address _to, uint256 _tokenId)
        internal {
        bitpaintingStorage.setOwnership(_tokenId, _to);
        Transfer(_from, _to, _tokenId);
    }

    function _createOriginalPainting(uint _tokenId, uint _artistId, uint _releasedAt) internal {
        address _owner = owner;
        uint _parentId = 0;
        uint8 _generation = 0;
        uint8 _speed = 10;
        _createPainting(_owner, _tokenId, _parentId, _generation, _speed, _artistId, _releasedAt);
    }

    function _createPainting(
        address _owner,
        uint _tokenId,
        uint _parentId,
        uint8 _generation,
        uint8 _speed,
        uint _artistId,
        uint _releasedAt
    )
        internal
    {
        require(_tokenId == uint256(uint32(_tokenId)));
        require(_parentId == uint256(uint32(_parentId)));
        require(_generation == uint256(uint8(_generation)));

        bitpaintingStorage.createPainting(
            _owner, _tokenId, _parentId, _generation, _speed, _artistId, _releasedAt);

        uint _createdAt;
        uint _completedAt;
        (,,_createdAt, _completedAt,,) = bitpaintingStorage.getPainting(_tokenId);

        // emit the create event
        Create(
            _tokenId,
            _owner,
            _parentId,
            _generation,
            _createdAt,
            _completedAt
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, _tokenId);
    }

}

// File: contracts/libs/ERC721.sol

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bfdbdacbdaffdec7d6d0d2c5dad191dcd0">[email protected]</a>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
    // Required methods&#13;
    function totalSupply() public constant returns (uint256 total);&#13;
    function balanceOf(address _owner) public constant returns (uint256 balance);&#13;
    function ownerOf(uint256 _tokenId) external constant returns (address owner);&#13;
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
    function supportsInterface(bytes4 _interfaceID) external constant returns (bool);&#13;
}&#13;
&#13;
// File: contracts/libs/ERC721Metadata.sol&#13;
&#13;
/// @title The external contract that is responsible for generating metadata for the kitties,&#13;
///  it has one function that will return the data as bytes.&#13;
contract ERC721Metadata {&#13;
    /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.&#13;
    function getMetadata(uint256 _tokenId, string) public constant returns (bytes32[4] buffer, uint256 count) {&#13;
        if (_tokenId == 1) {&#13;
            buffer[0] = "Hello World! :D";&#13;
            count = 15;&#13;
        } else if (_tokenId == 2) {&#13;
            buffer[0] = "I would definitely choose a medi";&#13;
            buffer[1] = "um length string.";&#13;
            count = 49;&#13;
        } else if (_tokenId == 3) {&#13;
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";&#13;
            buffer[1] = "st accumsan dapibus augue lorem,";&#13;
            buffer[2] = " tristique vestibulum id, libero";&#13;
            buffer[3] = " suscipit varius sapien aliquam.";&#13;
            count = 128;&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/libs/PaintingOwnership.sol&#13;
&#13;
contract PaintingOwnership is BitpaintingBase, ERC721 {&#13;
&#13;
    /// @notice Name and symbol of the non fungible token, as defined in ERC721.&#13;
    string public constant name = "BitPaintings";&#13;
    string public constant symbol = "BP";&#13;
&#13;
    ERC721Metadata public erc721Metadata;&#13;
&#13;
    bytes4 constant InterfaceSignature_ERC165 =&#13;
        bytes4(keccak256('supportsInterface(bytes4)'));&#13;
&#13;
    bytes4 constant InterfaceSignature_ERC721 =&#13;
        bytes4(keccak256('name()')) ^&#13;
        bytes4(keccak256('symbol()')) ^&#13;
        bytes4(keccak256('totalSupply()')) ^&#13;
        bytes4(keccak256('balanceOf(address)')) ^&#13;
        bytes4(keccak256('ownerOf(uint256)')) ^&#13;
        bytes4(keccak256('approve(address,uint256)')) ^&#13;
        bytes4(keccak256('transfer(address,uint256)')) ^&#13;
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^&#13;
        bytes4(keccak256('tokensOfOwner(address)')) ^&#13;
        bytes4(keccak256('tokenMetadata(uint256,string)'));&#13;
&#13;
    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).&#13;
    ///  Returns true for any standardized interfaces implemented by this contract. We implement&#13;
    ///  ERC-165 (obviously!) and ERC-721.&#13;
    function supportsInterface(bytes4 _interfaceID) external constant returns (bool)&#13;
    {&#13;
        // DEBUG ONLY&#13;
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) &amp;&amp; (InterfaceSignature_ERC721 == 0x9a20483d));&#13;
&#13;
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));&#13;
    }&#13;
&#13;
    /// @dev Set the address of the sibling contract that tracks metadata.&#13;
    ///  CEO only.&#13;
    function setMetadataAddress(address _contractAddress) public onlyOwner {&#13;
        erc721Metadata = ERC721Metadata(_contractAddress);&#13;
    }&#13;
&#13;
    function _owns(address _claimant, uint256 _tokenId) internal constant returns (bool) {&#13;
        return bitpaintingStorage.getPaintingOwner(_tokenId) == _claimant;&#13;
    }&#13;
&#13;
    function balanceOf(address _owner) public constant returns (uint256 count) {&#13;
        return bitpaintingStorage.getOwnershipTokenCount(_owner);&#13;
    }&#13;
&#13;
    function _approve(uint256 _tokenId, address _approved) internal {&#13;
        bitpaintingStorage.approve(_tokenId, _approved);&#13;
    }&#13;
&#13;
    function _approvedFor(address _claimant, uint256 _tokenId)&#13;
        internal constant returns (bool) {&#13;
        return bitpaintingStorage.isApprovedFor(_tokenId, _claimant);&#13;
    }&#13;
&#13;
    function transfer(&#13;
        address _to,&#13;
        uint256 _tokenId&#13;
    )&#13;
        external&#13;
        whenNotPaused&#13;
    {&#13;
        require(_to != address(0));&#13;
        require(_to != address(this));&#13;
        require(_owns(msg.sender, _tokenId));&#13;
&#13;
        _transfer(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    function approve(&#13;
      address _to,&#13;
      uint256 _tokenId&#13;
    )&#13;
      external&#13;
      whenNotPaused&#13;
    {&#13;
      require(_owns(msg.sender, _tokenId));&#13;
      _approve(_tokenId, _to);&#13;
&#13;
      Approval(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    function transferFrom(&#13;
      address _from,&#13;
      address _to,&#13;
      uint256 _tokenId&#13;
    )&#13;
        external whenNotPaused {&#13;
        _transferFrom(_from, _to, _tokenId);&#13;
    }&#13;
&#13;
    function _transferFrom(&#13;
      address _from,&#13;
      address _to,&#13;
      uint256 _tokenId&#13;
    )&#13;
        internal&#13;
        whenNotPaused&#13;
    {&#13;
        require(_to != address(0));&#13;
        require(_to != address(this));&#13;
        require(_approvedFor(msg.sender, _tokenId));&#13;
        require(_owns(_from, _tokenId));&#13;
&#13;
        _transfer(_from, _to, _tokenId);&#13;
    }&#13;
&#13;
    function totalSupply() public constant returns (uint) {&#13;
      return bitpaintingStorage.paintingsCount();&#13;
    }&#13;
&#13;
    function ownerOf(uint256 _tokenId)&#13;
        external constant returns (address) {&#13;
        return _ownerOf(_tokenId);&#13;
    }&#13;
&#13;
    function _ownerOf(uint256 _tokenId)&#13;
        internal constant returns (address) {&#13;
        return bitpaintingStorage.getPaintingOwner(_tokenId);&#13;
    }&#13;
&#13;
    function tokensOfOwner(address _owner)&#13;
        external constant returns(uint256[]) {&#13;
        uint256 tokenCount = balanceOf(_owner);&#13;
&#13;
        if (tokenCount == 0) {&#13;
          return new uint256[](0);&#13;
        }&#13;
&#13;
        uint256[] memory result = new uint256[](tokenCount);&#13;
        uint256 totalCats = totalSupply();&#13;
        uint256 resultIndex = 0;&#13;
&#13;
        uint256 paintingId;&#13;
&#13;
        for (paintingId = 1; paintingId &lt;= totalCats; paintingId++) {&#13;
            if (bitpaintingStorage.getPaintingOwner(paintingId) == _owner) {&#13;
                result[resultIndex] = paintingId;&#13;
                resultIndex++;&#13;
            }&#13;
        }&#13;
&#13;
        return result;&#13;
    }&#13;
&#13;
    /// @dev Adapted from memcpy() by @arachnid (Nick Johnson &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c8a9baa9aba0a6a1ac88a6a7bcaca7bce6a6adbc">[email protected]</a>&gt;)&#13;
    ///  This method is licenced under the Apache License.&#13;
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol&#13;
    function _memcpy(uint _dest, uint _src, uint _len) private constant {&#13;
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
    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="66071407050e080f022608091202091248080312">[email protected]</a>&gt;)&#13;
    ///  This method is licenced under the Apache License.&#13;
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol&#13;
    function _toString(bytes32[4] _rawBytes, uint256 _stringLength) private constant returns (string) {&#13;
      var outputString = new string(_stringLength);&#13;
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
    /// @notice Returns a URI pointing to a metadata package for this token conforming to&#13;
    ///  ERC-721 (https://github.com/ethereum/EIPs/issues/721)&#13;
    /// @param _tokenId The ID number of the Kitty whose metadata should be returned.&#13;
    function tokenMetadata(uint256 _tokenId, string _preferredTransport) external constant returns (string infoUrl) {&#13;
      require(erc721Metadata != address(0));&#13;
      bytes32[4] memory buffer;&#13;
      uint256 count;&#13;
      (buffer, count) = erc721Metadata.getMetadata(_tokenId, _preferredTransport);&#13;
&#13;
      return _toString(buffer, count);&#13;
    }&#13;
&#13;
    function withdraw() external onlyOwner {&#13;
        owner.transfer(this.balance);&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/BitpaintingPaintings.sol&#13;
&#13;
contract BitpaintingPaintings is PaintingOwnership, IPaintings {&#13;
&#13;
    uint version = 2;&#13;
&#13;
    function release(&#13;
        uint _tokenId,&#13;
        uint _artistId,&#13;
        uint _releasedAt,&#13;
        uint8[] _gens,&#13;
        uint _auctionStartingPrice,&#13;
        uint _auctionEndingPrice,&#13;
        uint _auctionDuration,&#13;
        string _artist,&#13;
        string _name&#13;
    ) external canReleaseArtwork whenNotPaused {&#13;
        _createOriginalPainting(_tokenId, _artistId, _releasedAt);&#13;
        _approve(_tokenId, owner);&#13;
        bitpaintingStorage.setEditionLimits(_tokenId, _gens[0], _gens[1],_gens[2]);&#13;
        auctionsContract().createReleaseAuction(&#13;
            _tokenId,&#13;
            _auctionStartingPrice,&#13;
            _auctionEndingPrice,&#13;
            _releasedAt,&#13;
            _auctionDuration);&#13;
        bitpaintingStorage.setPaintingArtist(_tokenId, _artist);&#13;
        bitpaintingStorage.setPaintingName(_tokenId, _name);&#13;
    }&#13;
&#13;
    function releaseNow(&#13;
        uint _tokenId,&#13;
        uint _artistId,&#13;
        uint8[] _gens,&#13;
        uint _auctionStartingPrice,&#13;
        uint _auctionEndingPrice,&#13;
        uint _auctionDuration,&#13;
        string _artist,&#13;
        string _name&#13;
    ) external canReleaseArtwork whenNotPaused {&#13;
        uint _releasedAt = now;&#13;
        _createOriginalPainting(_tokenId, _artistId, _releasedAt);&#13;
        _approve(_tokenId, owner);&#13;
        bitpaintingStorage.setEditionLimits(_tokenId, _gens[0], _gens[1],_gens[2]);&#13;
        auctionsContract().createReleaseAuction(&#13;
            _tokenId,&#13;
            _auctionStartingPrice,&#13;
            _auctionEndingPrice,&#13;
            now, // _releasedAt&#13;
            _auctionDuration);&#13;
        bitpaintingStorage.setPaintingArtist(_tokenId, _artist);&#13;
        bitpaintingStorage.setPaintingName(_tokenId, _name);&#13;
    }&#13;
&#13;
    function cancel(uint _tokenId) external canCancelArtwork whenNotPaused {&#13;
        require(bitpaintingStorage.isOnAuction(_tokenId));&#13;
        require(bitpaintingStorage.canBeChanged(_tokenId));&#13;
&#13;
        bitpaintingStorage.resetPainting(_tokenId);&#13;
        bitpaintingStorage.removeAuction(_tokenId);&#13;
        bitpaintingStorage.resetEditionLimits(_tokenId);&#13;
        bitpaintingStorage.purgeInformation(_tokenId);&#13;
    }&#13;
&#13;
    function auctionsContract() internal returns (IAuctions auctions){&#13;
        uint _signature = uint(keccak256("auctions"));&#13;
        return IAuctions(bitpaintingStorage.contracts(_signature));&#13;
    }&#13;
&#13;
    function createPainting(uint _tokenId)&#13;
        external canReleaseArtwork whenNotPaused {&#13;
        _createOriginalPainting(_tokenId, 1, now);&#13;
        _approve(_tokenId, owner);&#13;
    }&#13;
&#13;
    function sendAsGift(address _to, uint _tokenId) external whenNotPaused {&#13;
        require(_to != address(0));&#13;
        require(_to != address(this));&#13;
        require(_owns(msg.sender, _tokenId));&#13;
        require(bitpaintingStorage.isReady(_tokenId));&#13;
        require(!bitpaintingStorage.hasEditionInProgress(_tokenId));&#13;
&#13;
        if (bitpaintingStorage.isOnAuction(_tokenId)) {&#13;
            bitpaintingStorage.removeAuction(_tokenId);&#13;
        }&#13;
&#13;
        bitpaintingStorage.sealForChanges(_tokenId);&#13;
        _transfer(msg.sender, _to, _tokenId);&#13;
        bitpaintingStorage.increaseOwnershipTokenCount(_to);&#13;
        bitpaintingStorage.decreaseOwnershipTokenCount(msg.sender);&#13;
    }&#13;
&#13;
    function allTokenIds() public constant returns (uint[] tokenIds) {&#13;
        uint len = bitpaintingStorage.totalPaintingsCount();&#13;
        uint resultLen = bitpaintingStorage.paintingsCount();&#13;
        tokenIds = new uint[](resultLen);&#13;
        uint pointer = 0;&#13;
        for (uint index = 0; index &lt; len; index++) {&#13;
            uint token = bitpaintingStorage.getPaintingIdAtIndex(index);&#13;
            if (bitpaintingStorage.isCanceled(token)) {&#13;
                continue;&#13;
            }&#13;
            tokenIds[pointer] = token;&#13;
            pointer++;&#13;
        }&#13;
    }&#13;
&#13;
    function collectionOf(address _of) public constant returns (&#13;
            uint[] tokens,&#13;
            bool[] pending,&#13;
            bool[] forSale,&#13;
            bool[] locked,&#13;
            uint8[] generations,&#13;
            uint8[] speeds&#13;
        ) {&#13;
&#13;
        uint tokenCount = bitpaintingStorage.totalPaintingsCount();&#13;
        uint length = balanceOf(_of);&#13;
        uint pointer;&#13;
&#13;
        tokens = new uint[](length);&#13;
        pending = new bool[](length);&#13;
        forSale = new bool[](length);&#13;
        locked = new bool[](length);&#13;
        generations = new uint8[](length);&#13;
        speeds = new uint8[](length);&#13;
&#13;
        for(uint index = 0; index &lt; tokenCount; index++) {&#13;
            uint tokenId = bitpaintingStorage.getPaintingIdAtIndex(index);&#13;
&#13;
            if (_ownerOf(tokenId) != _of) {&#13;
                continue;&#13;
            }&#13;
&#13;
            uint _createdAt;&#13;
            (,,_createdAt,,,) = bitpaintingStorage.getPainting(tokenId);&#13;
            if (_createdAt == 0) {&#13;
                continue;&#13;
            }&#13;
&#13;
            tokens[pointer] = tokenId;&#13;
            pending[pointer] = !bitpaintingStorage.isReady(tokenId);&#13;
            forSale[pointer] = (bitpaintingStorage.getAuctionStartedAt(tokenId) &gt; 0);&#13;
            uint edition = bitpaintingStorage.lastEditionOf(tokenId);&#13;
            if (edition == 0) {&#13;
                locked[pointer] = false;&#13;
            } else {&#13;
                locked[pointer] = !bitpaintingStorage.isReady(edition);&#13;
            }&#13;
            generations[pointer] = bitpaintingStorage.getPaintingGeneration(tokenId);&#13;
            speeds[pointer] = bitpaintingStorage.getPaintingSpeed(tokenId);&#13;
&#13;
            pointer++;&#13;
        }&#13;
&#13;
    }&#13;
&#13;
    function collectionCountsOf(address _of) public constant&#13;
        returns (uint total, uint pending, uint forSale) {&#13;
        uint tokenCount = totalSupply();&#13;
&#13;
        for(uint index = 0; index &lt; tokenCount; index++) {&#13;
            uint tokenId = bitpaintingStorage.getPaintingIdAtIndex(index);&#13;
&#13;
            if (_ownerOf(tokenId) != _of) {&#13;
                continue;&#13;
            }&#13;
&#13;
            total++;&#13;
&#13;
            if (bitpaintingStorage.isReady(tokenId)) {&#13;
                if (bitpaintingStorage.getAuctionStartedAt(tokenId) &gt; 0) {&#13;
                    forSale++;&#13;
                }&#13;
&#13;
                continue;&#13;
            }&#13;
&#13;
            if (!bitpaintingStorage.isReady(tokenId)) {&#13;
                pending++;&#13;
                continue;&#13;
            }&#13;
&#13;
        }&#13;
&#13;
    }&#13;
&#13;
    function signature() external constant returns (uint _signature) {&#13;
        return uint(keccak256("paintings"));&#13;
    }&#13;
&#13;
}