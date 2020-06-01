pragma solidity ^0.4.18;

// File: contracts-origin/AetherAccessControl.sol

/// @title A facet of AetherCore that manages special access privileges.
/// @dev See the AetherCore contract documentation to understand how the various contract facets are arranged.
contract AetherAccessControl {
    // This facet controls access control for Laputa. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the AetherCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from AetherCore and its auction contracts.
    //
    //     - The COO: The COO can release properties to auction.
    //
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.

    /// @dev Emited when contract is upgraded - See README.md for updgrade plan
    event ContractUpgrade(address newContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) public onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function setCFO(address _newCFO) public onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) public onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    function withdrawBalance() external onlyCFO {
        cfoAddress.transfer(this.balance);
    }


    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() public onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}

// File: contracts-origin/AetherBase.sol

/// @title Base contract for Aether. Holds all common structs, events and base variables.
/// @author Project Aether (https://www.aether.city)
/// @dev See the PropertyCore contract documentation to understand how the various contract facets are arranged.
contract AetherBase is AetherAccessControl {
    /*** EVENTS ***/

    /// @dev The Construct event is fired whenever a property updates.
    event Construct (
      address indexed owner,
      uint256 propertyId,
      PropertyClass class,
      uint8 x,
      uint8 y,
      uint8 z,
      uint8 dx,
      uint8 dz,
      string data
    );

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every
    ///  time a property ownership is assigned.
    event Transfer(
      address indexed from,
      address indexed to,
      uint256 indexed tokenId
    );

    /*** DATA ***/

    enum PropertyClass { DISTRICT, BUILDING, UNIT }

    /// @dev The main Property struct. Every property in Aether is represented
    ///  by a variant of this structure.
    struct Property {
        uint32 parent;
        PropertyClass class;
        uint8 x;
        uint8 y;
        uint8 z;
        uint8 dx;
        uint8 dz;
    }

    /*** STORAGE ***/

    /// @dev Ensures that property occupies unique part of the universe.
    bool[100][100][100] public world;

    /// @dev An array containing the Property struct for all properties in existence. The ID
    ///  of each property is actually an index into this array.
    Property[] properties;

    /// @dev An array containing the district addresses in existence.
    uint256[] districts;

    /// @dev A measure of world progression.
    uint256 public progress;

    /// @dev The fee associated with constructing a unit property.
    uint256 public unitCreationFee = 0.05 ether;

    /// @dev Keeps track whether updating data is paused.
    bool public updateEnabled = true;

    /// @dev A mapping from property IDs to the address that owns them. All properties have
    ///  some valid owner address, even gen0 properties are created with a non-zero owner.
    mapping (uint256 => address) public propertyIndexToOwner;

    /// @dev A mapping from property IDs to the data that is stored on them.
    mapping (uint256 => string) public propertyIndexToData;

    /// @dev A mapping from owner address to count of tokens that address owns.
    ///  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    /// @dev Mappings between property nodes.
    mapping (uint256 => uint256) public districtToBuildingsCount;
    mapping (uint256 => uint256[]) public districtToBuildings;
    mapping (uint256 => uint256) public buildingToUnitCount;
    mapping (uint256 => uint256[]) public buildingToUnits;

    /// @dev A mapping from building propertyId to unit construction privacy.
    mapping (uint256 => bool) public buildingIsPublic;

    /// @dev A mapping from PropertyIDs to an address that has been approved to call
    ///  transferFrom(). Each Property can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public propertyIndexToApproved;

    /// @dev Assigns ownership of a specific Property to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
      // since the number of properties is capped to 2^32
      // there is no way to overflow this
      ownershipTokenCount[_to]++;
      // transfer ownership
      propertyIndexToOwner[_tokenId] = _to;
      // When creating new properties _from is 0x0, but we can't account that address.
      if (_from != address(0)) {
          ownershipTokenCount[_from]--;
          // clear any previously approved ownership exchange
          delete propertyIndexToApproved[_tokenId];
      }
      // Emit the transfer event.
      Transfer(_from, _to, _tokenId);
    }

    function _createUnit(
      uint256 _parent,
      uint256 _x,
      uint256 _y,
      uint256 _z,
      address _owner
    )
        internal
        returns (uint)
    {
      require(_x == uint256(uint8(_x)));
      require(_y == uint256(uint8(_y)));
      require(_z == uint256(uint8(_z)));
      require(!world[_x][_y][_z]);
      world[_x][_y][_z] = true;
      return _createProperty(
        _parent,
        PropertyClass.UNIT,
        _x,
        _y,
        _z,
        0,
        0,
        _owner
      );
    }

    function _createBuilding(
      uint256 _parent,
      uint256 _x,
      uint256 _y,
      uint256 _z,
      uint256 _dx,
      uint256 _dz,
      address _owner,
      bool _public
    )
        internal
        returns (uint)
    {
      require(_x == uint256(uint8(_x)));
      require(_y == uint256(uint8(_y)));
      require(_z == uint256(uint8(_z)));
      require(_dx == uint256(uint8(_dx)));
      require(_dz == uint256(uint8(_dz)));

      // Looping over world space.
      for(uint256 i = 0; i < _dx; i++) {
          for(uint256 j = 0; j <_dz; j++) {
              if (world[_x + i][0][_z + j]) {
                  revert();
              }
              world[_x + i][0][_z + j] = true;
          }
      }

      uint propertyId = _createProperty(
        _parent,
        PropertyClass.BUILDING,
        _x,
        _y,
        _z,
        _dx,
        _dz,
        _owner
      );

      districtToBuildingsCount[_parent]++;
      districtToBuildings[_parent].push(propertyId);
      buildingIsPublic[propertyId] = _public;
      return propertyId;
    }

    function _createDistrict(
      uint256 _x,
      uint256 _z,
      uint256 _dx,
      uint256 _dz
    )
        internal
        returns (uint)
    {
      require(_x == uint256(uint8(_x)));
      require(_z == uint256(uint8(_z)));
      require(_dx == uint256(uint8(_dx)));
      require(_dz == uint256(uint8(_dz)));

      uint propertyId = _createProperty(
        districts.length,
        PropertyClass.DISTRICT,
        _x,
        0,
        _z,
        _dx,
        _dz,
        cooAddress
      );

      districts.push(propertyId);
      return propertyId;

    }


    /// @dev An internal method that creates a new property and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Construct event
    ///  and a Transfer event.
    function _createProperty(
        uint256 _parent,
        PropertyClass _class,
        uint256 _x,
        uint256 _y,
        uint256 _z,
        uint256 _dx,
        uint256 _dz,
        address _owner
    )
        internal
        returns (uint)
    {
        require(_x == uint256(uint8(_x)));
        require(_y == uint256(uint8(_y)));
        require(_z == uint256(uint8(_z)));
        require(_dx == uint256(uint8(_dx)));
        require(_dz == uint256(uint8(_dz)));
        require(_parent == uint256(uint32(_parent)));
        require(uint256(_class) <= 3);

        Property memory _property = Property({
            parent: uint32(_parent),
            class: _class,
            x: uint8(_x),
            y: uint8(_y),
            z: uint8(_z),
            dx: uint8(_dx),
            dz: uint8(_dz)
        });
        uint256 _tokenId = properties.push(_property) - 1;

        // It's never going to happen, 4 billion properties is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(_tokenId <= 4294967295);

        Construct(
            _owner,
            _tokenId,
            _property.class,
            _property.x,
            _property.y,
            _property.z,
            _property.dx,
            _property.dz,
            ""
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, _tokenId);

        return _tokenId;
    }

    /// @dev Computing height of a building with respect to city progression.
    function _computeHeight(
      uint256 _x,
      uint256 _z,
      uint256 _height
    ) internal view returns (uint256) {
        uint256 x = _x < 50 ? 50 - _x : _x - 50;
        uint256 z = _z < 50 ? 50 - _z : _z - 50;
        uint256 distance = x > z ? x : z;
        if (distance > progress) {
          return 1;
        }
        uint256 scale = 100 - (distance * 100) / progress ;
        uint256 height = 2 * progress * _height * scale / 10000;
        return height > 0 ? height : 1;
    }

    /// @dev Convenience function to see if this building has room for a unit.
    function canCreateUnit(uint256 _buildingId)
        public
        view
        returns(bool)
    {
      Property storage _property = properties[_buildingId];
      if (_property.class == PropertyClass.BUILDING &&
            (buildingIsPublic[_buildingId] ||
              propertyIndexToOwner[_buildingId] == msg.sender)
      ) {
        uint256 totalVolume = _property.dx * _property.dz *
          (_computeHeight(_property.x, _property.z, _property.y) - 1);
        uint256 totalUnits = buildingToUnitCount[_buildingId];
        return totalUnits < totalVolume;
      }
      return false;
    }

    /// @dev This internal function skips all validation checks. Ensure that
    //   canCreateUnit() is required before calling this method.
    function _createUnitHelper(uint256 _buildingId, address _owner)
        internal
        returns(uint256)
    {
        // Grab a reference to the property in storage.
        Property storage _property = properties[_buildingId];
        uint256 totalArea = _property.dx * _property.dz;
        uint256 index = buildingToUnitCount[_buildingId];

        // Calculate next location.
        uint256 y = index / totalArea + 1;
        uint256 intermediate = index % totalArea;
        uint256 z = intermediate / _property.dx;
        uint256 x = intermediate % _property.dx;

        uint256 unitId = _createUnit(
          _buildingId,
          x + _property.x,
          y,
          z + _property.z,
          _owner
        );

        buildingToUnitCount[_buildingId]++;
        buildingToUnits[_buildingId].push(unitId);

        // Return the new unit's ID.
        return unitId;
    }

    /// @dev Update allows for setting a building privacy.
    function updateBuildingPrivacy(uint _tokenId, bool _public) public {
        require(propertyIndexToOwner[_tokenId] == msg.sender);
        buildingIsPublic[_tokenId] = _public;
    }

    /// @dev Update allows for setting the data associated to a property.
    function updatePropertyData(uint _tokenId, string _data) public {
        require(updateEnabled);
        address _owner = propertyIndexToOwner[_tokenId];
        require(msg.sender == _owner);
        propertyIndexToData[_tokenId] = _data;
        Property memory _property = properties[_tokenId];
        Construct(
            _owner,
            _tokenId,
            _property.class,
            _property.x,
            _property.y,
            _property.z,
            _property.dx,
            _property.dz,
            _data
        );
    }
}

// File: contracts-origin/ERC721Draft.sol

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<span class="__cf_email__" data-cfemail="c7a3a2b3a287a6bfaea8aabda2a9e9a4a8">[email protected]</span>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
    function implementsERC721() public pure returns (bool);&#13;
    function totalSupply() public view returns (uint256 total);&#13;
    function balanceOf(address _owner) public view returns (uint256 balance);&#13;
    function ownerOf(uint256 _tokenId) public view returns (address owner);&#13;
    function approve(address _to, uint256 _tokenId) public;&#13;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;&#13;
    function transfer(address _to, uint256 _tokenId) public;&#13;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);&#13;
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);&#13;
&#13;
    // Optional&#13;
    // function name() public view returns (string name);&#13;
    // function symbol() public view returns (string symbol);&#13;
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);&#13;
    // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);&#13;
}&#13;
&#13;
// File: contracts-origin/AetherOwnership.sol&#13;
&#13;
/// @title The facet of the Aether core contract that manages ownership, ERC-721 (draft) compliant.&#13;
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721&#13;
///  See the PropertyCore contract documentation to understand how the various contract facets are arranged.&#13;
contract AetherOwnership is AetherBase, ERC721 {&#13;
&#13;
    /// @notice Name and symbol of the non fungible token, as defined in ERC721.&#13;
    string public name = "Aether";&#13;
    string public symbol = "AETH";&#13;
&#13;
    function implementsERC721() public pure returns (bool)&#13;
    {&#13;
        return true;&#13;
    }&#13;
&#13;
    // Internal utility functions: These functions all assume that their input arguments&#13;
    // are valid. We leave it to public methods to sanitize their inputs and follow&#13;
    // the required logic.&#13;
&#13;
    /// @dev Checks if a given address is the current owner of a particular Property.&#13;
    /// @param _claimant the address we are validating against.&#13;
    /// @param _tokenId property id, only valid when &gt; 0&#13;
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {&#13;
        return propertyIndexToOwner[_tokenId] == _claimant;&#13;
    }&#13;
&#13;
    /// @dev Checks if a given address currently has transferApproval for a particular Property.&#13;
    /// @param _claimant the address we are confirming property is approved for.&#13;
    /// @param _tokenId property id, only valid when &gt; 0&#13;
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {&#13;
        return propertyIndexToApproved[_tokenId] == _claimant;&#13;
    }&#13;
&#13;
    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous&#13;
    ///  approval. Setting _approved to address(0) clears all transfer approval.&#13;
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because&#13;
    ///  _approve() and transferFrom() are used together for putting Properties on auction, and&#13;
    ///  there is no value in spamming the log with Approval events in that case.&#13;
    function _approve(uint256 _tokenId, address _approved) internal {&#13;
        propertyIndexToApproved[_tokenId] = _approved;&#13;
    }&#13;
&#13;
    /// @dev Transfers a property owned by this contract to the specified address.&#13;
    ///  Used to rescue lost properties. (There is no "proper" flow where this contract&#13;
    ///  should be the owner of any Property. This function exists for us to reassign&#13;
    ///  the ownership of Properties that users may have accidentally sent to our address.)&#13;
    /// @param _propertyId - ID of property&#13;
    /// @param _recipient - Address to send the property to&#13;
    function rescueLostProperty(uint256 _propertyId, address _recipient) public onlyCOO whenNotPaused {&#13;
        require(_owns(this, _propertyId));&#13;
        _transfer(this, _recipient, _propertyId);&#13;
    }&#13;
&#13;
    /// @notice Returns the number of Properties owned by a specific address.&#13;
    /// @param _owner The owner address to check.&#13;
    /// @dev Required for ERC-721 compliance&#13;
    function balanceOf(address _owner) public view returns (uint256 count) {&#13;
        return ownershipTokenCount[_owner];&#13;
    }&#13;
&#13;
    /// @notice Transfers a Property to another address. If transferring to a smart&#13;
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or&#13;
    ///  Laputa specifically) or your Property may be lost forever. Seriously.&#13;
    /// @param _to The address of the recipient, can be a user or contract.&#13;
    /// @param _tokenId The ID of the Property to transfer.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function transfer(&#13;
        address _to,&#13;
        uint256 _tokenId&#13;
    )&#13;
        public&#13;
        whenNotPaused&#13;
    {&#13;
        // Safety check to prevent against an unexpected 0x0 default.&#13;
        require(_to != address(0));&#13;
        // You can only send your own property.&#13;
        require(_owns(msg.sender, _tokenId));&#13;
&#13;
        // Reassign ownership, clear pending approvals, emit Transfer event.&#13;
        _transfer(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    /// @notice Grant another address the right to transfer a specific Property via&#13;
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.&#13;
    /// @param _to The address to be granted transfer approval. Pass address(0) to&#13;
    ///  clear all approvals.&#13;
    /// @param _tokenId The ID of the Property that can be transferred if this call succeeds.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function approve(&#13;
        address _to,&#13;
        uint256 _tokenId&#13;
    )&#13;
        public&#13;
        whenNotPaused&#13;
    {&#13;
        // Only an owner can grant transfer approval.&#13;
        require(_owns(msg.sender, _tokenId));&#13;
&#13;
        // Register the approval (replacing any previous approval).&#13;
        _approve(_tokenId, _to);&#13;
&#13;
        // Emit approval event.&#13;
        Approval(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    /// @notice Transfer a Property owned by another address, for which the calling address&#13;
    ///  has previously been granted transfer approval by the owner.&#13;
    /// @param _from The address that owns the Property to be transfered.&#13;
    /// @param _to The address that should take ownership of the Property. Can be any address,&#13;
    ///  including the caller.&#13;
    /// @param _tokenId The ID of the Property to be transferred.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function transferFrom(&#13;
        address _from,&#13;
        address _to,&#13;
        uint256 _tokenId&#13;
    )&#13;
        public&#13;
        whenNotPaused&#13;
    {&#13;
        // Check for approval and valid ownership&#13;
        require(_approvedFor(msg.sender, _tokenId));&#13;
        require(_owns(_from, _tokenId));&#13;
&#13;
        // Reassign ownership (also clears pending approvals and emits Transfer event).&#13;
        _transfer(_from, _to, _tokenId);&#13;
    }&#13;
&#13;
    /// @notice Returns the total number of Properties currently in existence.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function totalSupply() public view returns (uint) {&#13;
        return properties.length;&#13;
    }&#13;
&#13;
    function totalDistrictSupply() public view returns(uint count) {&#13;
        return districts.length;&#13;
    }&#13;
&#13;
    /// @notice Returns the address currently assigned ownership of a given Property.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function ownerOf(uint256 _tokenId)&#13;
        public&#13;
        view&#13;
        returns (address owner)&#13;
    {&#13;
        owner = propertyIndexToOwner[_tokenId];&#13;
&#13;
        require(owner != address(0));&#13;
    }&#13;
&#13;
&#13;
    /// @notice Returns a list of all Property IDs assigned to an address.&#13;
    /// @param _owner The owner whose Properties we are interested in.&#13;
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly&#13;
    ///  expensive (it walks the entire Kitty array looking for cats belonging to owner),&#13;
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and&#13;
    ///  not contract-to-contract calls.&#13;
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {&#13;
        uint256 tokenCount = balanceOf(_owner);&#13;
&#13;
        if (tokenCount == 0) {&#13;
            // Return an empty array&#13;
            return new uint256[](0);&#13;
        } else {&#13;
            uint256[] memory result = new uint256[](tokenCount);&#13;
            uint256 totalProperties = totalSupply();&#13;
            uint256 resultIndex = 0;&#13;
&#13;
            // We count on the fact that all properties have IDs starting at 1 and increasing&#13;
            // sequentially up to the totalProperties count.&#13;
            uint256 tokenId;&#13;
&#13;
            for (tokenId = 1; tokenId &lt;= totalProperties; tokenId++) {&#13;
                if (propertyIndexToOwner[tokenId] == _owner) {&#13;
                    result[resultIndex] = tokenId;&#13;
                    resultIndex++;&#13;
                }&#13;
            }&#13;
&#13;
            return result;&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
// File: contracts-origin/Auction/ClockAuctionBase.sol&#13;
&#13;
/// @title Auction Core&#13;
/// @dev Contains models, variables, and internal methods for the auction.&#13;
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
    /// @dev DON'T give me your money.&#13;
    function() external {}&#13;
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
        // Check that the incoming bid is higher than the current&#13;
        // price&#13;
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
            //  Calculate the auctioneer's cut.&#13;
            // (NOTE: _computeCut() is guaranteed to return a&#13;
            //  value &lt;= price, so this subtraction can't go negative.)&#13;
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
// File: zeppelin-solidity/contracts/ownership/Ownable.sol&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  function Ownable() {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) onlyOwner {&#13;
    if (newOwner != address(0)) {&#13;
      owner = newOwner;&#13;
    }&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol&#13;
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
// File: contracts-origin/Auction/ClockAuction.sol&#13;
&#13;
/// @title Clock auction for non-fungible tokens.&#13;
contract ClockAuction is Pausable, ClockAuctionBase {&#13;
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
        require(candidateContract.implementsERC721());&#13;
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
        nftAddress.transfer(this.balance);&#13;
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
        public&#13;
        whenNotPaused&#13;
        canBeStoredWith128Bits(_startingPrice)&#13;
        canBeStoredWith128Bits(_endingPrice)&#13;
        canBeStoredWith64Bits(_duration)&#13;
    {&#13;
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
        public&#13;
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
        public&#13;
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
        public&#13;
    {&#13;
        Auction storage auction = tokenIdToAuction[_tokenId];&#13;
        require(_isOnAuction(auction));&#13;
        _cancelAuction(_tokenId, auction.seller);&#13;
    }&#13;
&#13;
    /// @dev Returns auction info for an NFT on auction.&#13;
    /// @param _tokenId - ID of NFT on auction.&#13;
    function getAuction(uint256 _tokenId)&#13;
        public&#13;
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
        public&#13;
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
// File: contracts-origin/Auction/AetherClockAuction.sol&#13;
&#13;
/// @title Clock auction modified for sale of property&#13;
contract AetherClockAuction is ClockAuction {&#13;
&#13;
    // @dev Sanity check that allows us to ensure that we are pointing to the&#13;
    //  right auction in our setSaleAuctionAddress() call.&#13;
    bool public isAetherClockAuction = true;&#13;
&#13;
    // Tracks last 5 sale price of gen0 property sales&#13;
    uint256 public saleCount;&#13;
    uint256[5] public lastSalePrices;&#13;
&#13;
    // Delegate constructor&#13;
    function AetherClockAuction(address _nftAddr, uint256 _cut) public&#13;
      ClockAuction(_nftAddr, _cut) {}&#13;
&#13;
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
        public&#13;
        canBeStoredWith128Bits(_startingPrice)&#13;
        canBeStoredWith128Bits(_endingPrice)&#13;
        canBeStoredWith64Bits(_duration)&#13;
    {&#13;
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
        public&#13;
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
            lastSalePrices[saleCount % 5] = price;&#13;
            saleCount++;&#13;
        }&#13;
    }&#13;
&#13;
    function averageSalePrice() public view returns (uint256) {&#13;
        uint256 sum = 0;&#13;
        for (uint256 i = 0; i &lt; 5; i++) {&#13;
            sum += lastSalePrices[i];&#13;
        }&#13;
        return sum / 5;&#13;
    }&#13;
}&#13;
&#13;
// File: contracts-origin/AetherAuction.sol&#13;
&#13;
/// @title Handles creating auctions for sale and siring of properties.&#13;
///  This wrapper of ReverseAuction exists only so that users can create&#13;
///  auctions with only one transaction.&#13;
contract AetherAuction is AetherOwnership{&#13;
&#13;
    /// @dev The address of the ClockAuction contract that handles sales of Aether. This&#13;
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are&#13;
    ///  initiated every 15 minutes.&#13;
    AetherClockAuction public saleAuction;&#13;
&#13;
    /// @dev Sets the reference to the sale auction.&#13;
    /// @param _address - Address of sale contract.&#13;
    function setSaleAuctionAddress(address _address) public onlyCEO {&#13;
        AetherClockAuction candidateContract = AetherClockAuction(_address);&#13;
&#13;
        // NOTE: verify that a contract is what we expect&#13;
        require(candidateContract.isAetherClockAuction());&#13;
&#13;
        // Set the new contract address&#13;
        saleAuction = candidateContract;&#13;
    }&#13;
&#13;
    /// @dev Put a property up for auction.&#13;
    ///  Does some ownership trickery to create auctions in one tx.&#13;
    function createSaleAuction(&#13;
        uint256 _propertyId,&#13;
        uint256 _startingPrice,&#13;
        uint256 _endingPrice,&#13;
        uint256 _duration&#13;
    )&#13;
        public&#13;
        whenNotPaused&#13;
    {&#13;
        // Auction contract checks input sizes&#13;
        // If property is already on any auction, this will throw&#13;
        // because it will be owned by the auction contract.&#13;
        require(_owns(msg.sender, _propertyId));&#13;
        _approve(_propertyId, saleAuction);&#13;
        // Sale auction throws if inputs are invalid and clears&#13;
        // transfer and sire approval after escrowing the property.&#13;
        saleAuction.createAuction(&#13;
            _propertyId,&#13;
            _startingPrice,&#13;
            _endingPrice,&#13;
            _duration,&#13;
            msg.sender&#13;
        );&#13;
    }&#13;
&#13;
    /// @dev Transfers the balance of the sale auction contract&#13;
    /// to the AetherCore contract. We use two-step withdrawal to&#13;
    /// prevent two transfer calls in the auction bid function.&#13;
    function withdrawAuctionBalances() external onlyCOO {&#13;
        saleAuction.withdrawBalance();&#13;
    }&#13;
}&#13;
&#13;
// File: contracts-origin/AetherConstruct.sol&#13;
&#13;
// Auction wrapper functions&#13;
&#13;
&#13;
/// @title all functions related to creating property&#13;
contract AetherConstruct is AetherAuction {&#13;
&#13;
    uint256 public districtLimit = 16;&#13;
    uint256 public startingPrice = 1 ether;&#13;
    uint256 public auctionDuration = 1 days;&#13;
&#13;
    /// @dev Units can be contructed within public and owned buildings.&#13;
    function createUnit(uint256 _buildingId)&#13;
        public&#13;
        payable&#13;
        returns(uint256)&#13;
    {&#13;
        require(canCreateUnit(_buildingId));&#13;
        require(msg.value &gt;= unitCreationFee);&#13;
        if (msg.value &gt; unitCreationFee)&#13;
            msg.sender.transfer(msg.value - unitCreationFee);&#13;
        uint256 propertyId = _createUnitHelper(_buildingId, msg.sender);&#13;
        return propertyId;&#13;
    }&#13;
&#13;
    /// @dev Creation of unit properties. Only callable by COO&#13;
    function createUnitOmni(&#13;
      uint32 _buildingId,&#13;
      address _owner&#13;
    )&#13;
      public&#13;
      onlyCOO&#13;
    {&#13;
        if (_owner == address(0)) {&#13;
             _owner = cooAddress;&#13;
        }&#13;
        require(canCreateUnit(_buildingId));&#13;
        _createUnitHelper(_buildingId, _owner);&#13;
    }&#13;
&#13;
    /// @dev Creation of building properties. Only callable by COO&#13;
    function createBuildingOmni(&#13;
      uint32 _districtId,&#13;
      uint8 _x,&#13;
      uint8 _y,&#13;
      uint8 _z,&#13;
      uint8 _dx,&#13;
      uint8 _dz,&#13;
      address _owner,&#13;
      bool _open&#13;
    )&#13;
      public&#13;
      onlyCOO&#13;
    {&#13;
        if (_owner == address(0)) {&#13;
             _owner = cooAddress;&#13;
        }&#13;
        _createBuilding(_districtId, _x, _y, _z, _dx, _dz, _owner, _open);&#13;
    }&#13;
&#13;
    /// @dev Creation of district properties, up to a limit. Only callable by COO&#13;
    function createDistrictOmni(&#13;
      uint8 _x,&#13;
      uint8 _z,&#13;
      uint8 _dx,&#13;
      uint8 _dz&#13;
    )&#13;
      public&#13;
      onlyCOO&#13;
    {&#13;
      require(districts.length &lt; districtLimit);&#13;
      _createDistrict(_x, _z, _dx, _dz);&#13;
    }&#13;
&#13;
&#13;
    /// @dev Creates a new property with the given details and&#13;
    ///  creates an auction for it. Only callable by COO.&#13;
    function createBuildingAuction(&#13;
      uint32 _districtId,&#13;
      uint8 _x,&#13;
      uint8 _y,&#13;
      uint8 _z,&#13;
      uint8 _dx,&#13;
      uint8 _dz,&#13;
      bool _open&#13;
    ) public onlyCOO {&#13;
        uint256 propertyId = _createBuilding(_districtId, _x, _y, _z, _dx, _dz, address(this), _open);&#13;
        _approve(propertyId, saleAuction);&#13;
&#13;
        saleAuction.createAuction(&#13;
            propertyId,&#13;
            _computeNextPrice(),&#13;
            0,&#13;
            auctionDuration,&#13;
            address(this)&#13;
        );&#13;
    }&#13;
&#13;
    /// @dev Updates the minimum payment required for calling createUnit(). Can only&#13;
    ///  be called by the COO address.&#13;
    function setUnitCreationFee(uint256 _value) public onlyCOO {&#13;
        unitCreationFee = _value;&#13;
    }&#13;
&#13;
    /// @dev Update world progression factor allowing for buildings to grow taller&#13;
    //   as the city expands. Only callable by COO.&#13;
    function setProgress(uint256 _progress) public onlyCOO {&#13;
        require(_progress &lt;= 100);&#13;
        require(_progress &gt; progress);&#13;
        progress = _progress;&#13;
    }&#13;
&#13;
    /// @dev Set property data updates flag. Only callable by COO.&#13;
    function setUpdateState(bool _updateEnabled) public onlyCOO {&#13;
        updateEnabled = _updateEnabled;&#13;
    }&#13;
&#13;
    /// @dev Computes the next auction starting price, given the average of the past&#13;
    ///  5 prices + 50%.&#13;
    function _computeNextPrice() internal view returns (uint256) {&#13;
        uint256 avePrice = saleAuction.averageSalePrice();&#13;
&#13;
        // sanity check to ensure we don't overflow arithmetic (this big number is 2^128-1).&#13;
        require(avePrice &lt; 340282366920938463463374607431768211455);&#13;
&#13;
        uint256 nextPrice = avePrice + (avePrice / 2);&#13;
&#13;
        // We never auction for less than starting price&#13;
        if (nextPrice &lt; startingPrice) {&#13;
            nextPrice = startingPrice;&#13;
        }&#13;
&#13;
        return nextPrice;&#13;
    }&#13;
}&#13;
&#13;
// File: contracts-origin/AetherCore.sol&#13;
&#13;
/// @title Aether: A city on the Ethereum blockchain.&#13;
/// @author Axiom Zen (https://www.axiomzen.co)&#13;
contract AetherCore is AetherConstruct {&#13;
&#13;
    // This is the main Aether contract. In order to keep our code seperated into logical sections,&#13;
    // we've broken it up in two ways.  The auctions are seperate since their logic is somewhat complex&#13;
    // and there's always a risk of subtle bugs. By keeping them in their own contracts, we can upgrade&#13;
    // them without disrupting the main contract that tracks property ownership.&#13;
    //&#13;
    // Secondly, we break the core contract into multiple files using inheritence, one for each major&#13;
    // facet of functionality of Aether. This allows us to keep related code bundled together while still&#13;
    // avoiding a single giant file with everything in it. The breakdown is as follows:&#13;
    //&#13;
    //      - AetherBase: This is where we define the most fundamental code shared throughout the core&#13;
    //             functionality. This includes our main data storage, constants and data types, plus&#13;
    //             internal functions for managing these items.&#13;
    //&#13;
    //      - AetherAccessControl: This contract manages the various addresses and constraints for operations&#13;
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.&#13;
    //&#13;
    //      - AetherOwnership: This provides the methods required for basic non-fungible token&#13;
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).&#13;
    //&#13;
    //      - AetherAuction: Here we have the public methods for auctioning or bidding on property.&#13;
    //             The actual auction functionality is handled in two sibling contracts while auction&#13;
    //             creation and bidding is mostly mediated through this facet of the core contract.&#13;
    //&#13;
    //      - AetherConstruct: This final facet contains the functionality we use for creating new gen0 cats.&#13;
&#13;
    //             the community is new).&#13;
&#13;
    // Set in case the core contract is broken and an upgrade is required&#13;
    address public newContractAddress;&#13;
&#13;
    /// @notice Creates the main Aether smart contract instance.&#13;
    function AetherCore() public {&#13;
        // Starts paused.&#13;
        paused = true;&#13;
&#13;
        // the creator of the contract is the initial CEO&#13;
        ceoAddress = msg.sender;&#13;
&#13;
        // the creator of the contract is also the initial COO&#13;
        cooAddress = msg.sender;&#13;
    }&#13;
&#13;
    /// @dev Used to mark the smart contract as upgraded, in case there is a serious&#13;
    ///  breaking bug. This method does nothing but keep track of the new contract and&#13;
    ///  emit a message indicating that the new address is set. It's up to clients of this&#13;
    ///  contract to update to the new contract address in that case. (This contract will&#13;
    ///  be paused indefinitely if such an upgrade takes place.)&#13;
    /// @param _v2Address new address&#13;
    function setNewAddress(address _v2Address) public onlyCEO whenPaused {&#13;
        // See README.md for updgrade plan&#13;
        newContractAddress = _v2Address;&#13;
        ContractUpgrade(_v2Address);&#13;
    }&#13;
&#13;
    /// @notice No tipping!&#13;
    /// @dev Reject all Ether from being sent here, unless it's from one of the&#13;
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)&#13;
    function() external payable {&#13;
        require(&#13;
            msg.sender == address(saleAuction)&#13;
        );&#13;
    }&#13;
&#13;
    /// @notice Returns all the relevant information about a specific property.&#13;
    /// @param _id The ID of the property of interest.&#13;
    function getProperty(uint256 _id)&#13;
        public&#13;
        view&#13;
        returns (&#13;
        uint32 parent,&#13;
        uint8 class,&#13;
        uint8 x,&#13;
        uint8 y,&#13;
        uint8 z,&#13;
        uint8 dx,&#13;
        uint8 dz,&#13;
        uint8 height&#13;
    ) {&#13;
        Property storage property = properties[_id];&#13;
        parent = uint32(property.parent);&#13;
        class = uint8(property.class);&#13;
&#13;
        height = uint8(property.y);&#13;
        if (property.class == PropertyClass.BUILDING) {&#13;
          y = uint8(_computeHeight(property.x, property.z, property.y));&#13;
        } else {&#13;
          y = uint8(property.y);&#13;
        }&#13;
&#13;
        x = uint8(property.x);&#13;
        z = uint8(property.z);&#13;
        dx = uint8(property.dx);&#13;
        dz = uint8(property.dz);&#13;
    }&#13;
&#13;
    /// @dev Override unpause so it requires all external contract addresses&#13;
    ///  to be set before contract can be unpaused. Also, we can't have&#13;
    ///  newContractAddress set either, because then the contract was upgraded.&#13;
    function unpause() public onlyCEO whenPaused {&#13;
        require(saleAuction != address(0));&#13;
        require(newContractAddress == address(0));&#13;
        // Actually unpause the contract.&#13;
        super.unpause();&#13;
    }&#13;
}