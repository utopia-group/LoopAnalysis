pragma solidity ^0.4.15;

// File: contracts/interfaces/IEditions.sol

contract IEditions {

    function createEdition(uint _tokenId) external;
    function pendingEditionsOf(address _of) public constant returns (
        uint[] tokens,
        uint[] startedAt,
        uint[] completedAt,
        uint8[] currentCounts,
        uint8[] limitCounts
    );
    function counter(uint _tokenId) public
        constant returns (uint8 current, uint8 limit);
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
    /// @dev Adapted from memcpy() by @arachnid (Nick Johnson &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5d3c2f3c3e353334391d33322939322973333829">[email protected]</a>&gt;)&#13;
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
    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2a4b584b494244434e6a44455e4e455e04444f5e">[email protected]</a>&gt;)&#13;
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
// File: contracts/BitpaintingEditions.sol&#13;
&#13;
contract BitpaintingEditions is PaintingOwnership, IEditions {&#13;
&#13;
    event EditionCreated(&#13;
        address creator,&#13;
        uint parentId,&#13;
        uint editionId,&#13;
        uint8 parentSpeed);&#13;
&#13;
    function createEdition(uint _tokenId) external whenNotPaused {&#13;
        address creator = msg.sender;&#13;
        require(creator == _ownerOf(_tokenId));&#13;
        require(bitpaintingStorage.isReady(_tokenId));&#13;
        require(!bitpaintingStorage.hasEditionInProgress(_tokenId));&#13;
        require(bitpaintingStorage.hasEmptyEditionSlots(_tokenId));&#13;
        require(!bitpaintingStorage.isOnAuction(_tokenId));&#13;
&#13;
        bitpaintingStorage.createEditionMeta(_tokenId);&#13;
        uint editionId = bitpaintingStorage.getOffsetIndex();&#13;
        uint8 _generation =&#13;
            bitpaintingStorage.getPaintingGeneration(_tokenId) + 1;&#13;
        uint8 _speed = 10;&#13;
        uint _artistId = bitpaintingStorage.getPaintingArtistId(_tokenId);&#13;
        _createPainting(creator, editionId, _tokenId, _generation, _speed, _artistId, now + 1);&#13;
        bitpaintingStorage.decreaseSpeed(_tokenId);&#13;
&#13;
        uint8 speed = bitpaintingStorage.getPaintingSpeed(_tokenId);&#13;
        EditionCreated(creator, _tokenId, editionId, speed);&#13;
    }&#13;
&#13;
    function pendingEditionsOf(address _of) public constant returns (&#13;
            uint[] tokens,&#13;
            uint[] startedAt,&#13;
            uint[] completedAt,&#13;
            uint8[] currentCounts,&#13;
            uint8[] limitCounts&#13;
        ) {&#13;
&#13;
        uint tokenCount = totalSupply();&#13;
        uint length = balanceOf(_of);&#13;
        uint pointer;&#13;
&#13;
        tokens = new uint[](length);&#13;
        startedAt = new uint[](length);&#13;
        completedAt = new uint[](length);&#13;
        currentCounts = new uint8[](length);&#13;
        limitCounts = new uint8[](length);&#13;
&#13;
        for(uint index = 0; index &lt; tokenCount; index++) {&#13;
            uint tokenId = bitpaintingStorage.getPaintingIdAtIndex(index);&#13;
&#13;
            if (tokenId == 0) {&#13;
                continue;&#13;
            }&#13;
&#13;
            if (_ownerOf(tokenId) != _of) {&#13;
                continue;&#13;
            }&#13;
&#13;
            if (bitpaintingStorage.isReady(tokenId)) {&#13;
                continue;&#13;
            }&#13;
&#13;
            uint _startedAt;&#13;
            uint _completedAt;&#13;
            (,,_startedAt, _completedAt,,) = bitpaintingStorage.getPainting(tokenId);&#13;
            uint8 _current;&#13;
            uint8 _limit;&#13;
            (_current, _limit) = counter(tokenId);&#13;
&#13;
            tokens[pointer] = tokenId;&#13;
            startedAt[pointer] = _startedAt;&#13;
            completedAt[pointer] = _completedAt;&#13;
            currentCounts[pointer] = _current;&#13;
            limitCounts[pointer] = _limit;&#13;
&#13;
            pointer++;&#13;
        }&#13;
    }&#13;
&#13;
    function counter(uint _tokenId) public&#13;
        constant returns (uint8 current, uint8 limit) {&#13;
&#13;
        uint8 gen = bitpaintingStorage.getPaintingGeneration(_tokenId);&#13;
        if (gen == 0) {&#13;
            current = 1;&#13;
            limit = 1;&#13;
        } else {&#13;
            uint original = bitpaintingStorage.getPaintingOriginal(_tokenId);&#13;
            uint8[3] memory counts = bitpaintingStorage.getEditionsCount(original);&#13;
            uint8[3] memory limits = bitpaintingStorage.getEditionLimits(original);&#13;
            current = counts[gen - 1];&#13;
            limit = limits[gen - 1];&#13;
        }&#13;
    }&#13;
&#13;
    function signature() external constant returns (uint _signature) {&#13;
        return uint(keccak256("editions"));&#13;
    }&#13;
&#13;
}