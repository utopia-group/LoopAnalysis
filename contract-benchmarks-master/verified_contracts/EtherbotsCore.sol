pragma solidity ^0.4.18;



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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



 // Pause functionality taken from OpenZeppelin. License below.
 /* The MIT License (MIT)
 Copyright (c) 2016 Smart Contract Solutions, Inc.
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions: */

 /**
  * @title Pausable
  * @dev Base contract which allows children to implement an emergency stop mechanism.
  */
contract Pausable is Ownable {

  event SetPaused(bool paused);

  // starts unpaused
  bool public paused = false;

  /* @dev modifier to allow actions only when the contract IS paused */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /* @dev modifier to allow actions only when the contract IS NOT paused */
  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    SetPaused(paused);
    return true;
  }

  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    SetPaused(paused);
    return true;
  }
}

contract EtherbotsPrivileges is Pausable {
  event ContractUpgrade(address newContract);

}



// This contract implements both the original ERC-721 standard and
// the proposed 'deed' standard of 841
// I don't know which standard will eventually be adopted - support both for now


/// @title Interface for contracts conforming to ERC-721: Deed Standard
/// @author William Entriken (https://phor.net), et. al.
/// @dev Specification at https://github.com/ethereum/eips/841
/// can read the comments there
contract ERC721 {

    // COMPLIANCE WITH ERC-165 (DRAFT)

    /// @dev ERC-165 (draft) interface signature for itself
    bytes4 internal constant INTERFACE_SIGNATURE_ERC165 =
        bytes4(keccak256("supportsInterface(bytes4)"));

    /// @dev ERC-165 (draft) interface signature for ERC721
    bytes4 internal constant INTERFACE_SIGNATURE_ERC721 =
         bytes4(keccak256("ownerOf(uint256)")) ^
         bytes4(keccak256("countOfDeeds()")) ^
         bytes4(keccak256("countOfDeedsByOwner(address)")) ^
         bytes4(keccak256("deedOfOwnerByIndex(address,uint256)")) ^
         bytes4(keccak256("approve(address,uint256)")) ^
         bytes4(keccak256("takeOwnership(uint256)"));

    function supportsInterface(bytes4 _interfaceID) external pure returns (bool);

    // PUBLIC QUERY FUNCTIONS //////////////////////////////////////////////////

    function ownerOf(uint256 _deedId) public view returns (address _owner);
    function countOfDeeds() external view returns (uint256 _count);
    function countOfDeedsByOwner(address _owner) external view returns (uint256 _count);
    function deedOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _deedId);

    // TRANSFER MECHANISM //////////////////////////////////////////////////////

    event Transfer(address indexed from, address indexed to, uint256 indexed deedId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed deedId);

    function approve(address _to, uint256 _deedId) external payable;
    function takeOwnership(uint256 _deedId) external payable;
}

/// @title Metadata extension to ERC-721 interface
/// @author William Entriken (https://phor.net)
/// @dev Specification at https://github.com/ethereum/eips/issues/XXXX
contract ERC721Metadata is ERC721 {

    bytes4 internal constant INTERFACE_SIGNATURE_ERC721Metadata =
        bytes4(keccak256("name()")) ^
        bytes4(keccak256("symbol()")) ^
        bytes4(keccak256("deedUri(uint256)"));

    function name() public pure returns (string n);
    function symbol() public pure returns (string s);

    /// @notice A distinct URI (RFC 3986) for a given token.
    /// @dev If:
    ///  * The URI is a URL
    ///  * The URL is accessible
    ///  * The URL points to a valid JSON file format (ECMA-404 2nd ed.)
    ///  * The JSON base element is an object
    ///  then these names of the base element SHALL have special meaning:
    ///  * "name": A string identifying the item to which `_deedId` grants
    ///    ownership
    ///  * "description": A string detailing the item to which `_deedId` grants
    ///    ownership
    ///  * "image": A URI pointing to a file of image/* mime type representing
    ///    the item to which `_deedId` grants ownership
    ///  Wallets and exchanges MAY display this to the end user.
    ///  Consider making any images at a width between 320 and 1080 pixels and
    ///  aspect ratio between 1.91:1 and 4:5 inclusive.
    function deedUri(uint256 _deedId) external view returns (string _uri);
}

/// @title Enumeration extension to ERC-721 interface
/// @author William Entriken (https://phor.net)
/// @dev Specification at https://github.com/ethereum/eips/issues/XXXX
contract ERC721Enumerable is ERC721Metadata {

    /// @dev ERC-165 (draft) interface signature for ERC721
    bytes4 internal constant INTERFACE_SIGNATURE_ERC721Enumerable =
        bytes4(keccak256("deedByIndex()")) ^
        bytes4(keccak256("countOfOwners()")) ^
        bytes4(keccak256("ownerByIndex(uint256)"));

    function deedByIndex(uint256 _index) external view returns (uint256 _deedId);
    function countOfOwners() external view returns (uint256 _count);
    function ownerByIndex(uint256 _index) external view returns (address _owner);
}

contract ERC721Original {

    bytes4 constant INTERFACE_SIGNATURE_ERC721Original =
        bytes4(keccak256("totalSupply()")) ^
        bytes4(keccak256("balanceOf(address)")) ^
        bytes4(keccak256("ownerOf(uint256)")) ^
        bytes4(keccak256("approve(address,uint256)")) ^
        bytes4(keccak256("takeOwnership(uint256)")) ^
        bytes4(keccak256("transfer(address,uint256)"));

    // Core functions
    function implementsERC721() public pure returns (bool);
    function totalSupply() public view returns (uint256 _totalSupply);
    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint _tokenId) public view returns (address _owner);
    function approve(address _to, uint _tokenId) external payable;
    function transferFrom(address _from, address _to, uint _tokenId) public;
    function transfer(address _to, uint _tokenId) public payable;

    // Optional functions
    function name() public pure returns (string _name);
    function symbol() public pure returns (string _symbol);
    function tokenOfOwnerByIndex(address _owner, uint _index) external view returns (uint _tokenId);
    function tokenMetadata(uint _tokenId) public view returns (string _infoUrl);

    // Events
    // event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    // event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
}

contract ERC721AllImplementations is ERC721Original, ERC721Enumerable {

}

contract EtherbotsBase is EtherbotsPrivileges {


    function EtherbotsBase() public {
    //   scrapyard = address(this);
    }
    /*** EVENTS ***/

    ///  Forge fires when a new part is created - 4 times when a crate is opened,
    /// and once when a battle takes place. Also has fires when
    /// parts are combined in the furnace.
    event Forge(address owner, uint256 partID, Part part);

    ///  Transfer event as defined in ERC721.
    event Transfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/
    ///  The main struct representation of a robot part. Each robot in Etherbots is represented by four copies
    ///  of this structure, one for each of the four parts comprising it:
    /// 1. Right Arm (Melee),
    /// 2. Left Arm (Defence),
    /// 3. Head (Turret),
    /// 4. Body.
    // store token id on this?
     struct Part {
        uint32 tokenId;
        uint8 partType;
        uint8 partSubType;
        uint8 rarity;
        uint8 element;
        uint32 battlesLastDay;
        uint32 experience;
        uint32 forgeTime;
        uint32 battlesLastReset;
    }

    // Part type - can be shared with other part factories.
    uint8 constant DEFENCE = 1;
    uint8 constant MELEE = 2;
    uint8 constant BODY = 3;
    uint8 constant TURRET = 4;

    // Rarity - can be shared with other part factories.
    uint8 constant STANDARD = 1;
    uint8 constant SHADOW = 2;
    uint8 constant GOLD = 3;


    // Store a user struct
    // in order to keep track of experience and perk choices.
    // This perk tree is a binary tree, efficiently encodable as an array.
    // 0 reflects no perk selected. 1 is first choice. 2 is second. 3 is both.
    // Each choice costs experience (deducted from user struct).

    /*** ~~~~~ROBOT PERKS~~~~~ ***/
    // PERK 1: ATTACK vs DEFENCE PERK CHOICE.
    // Choose
    // PERK TWO ATTACK/ SHOOT, or DEFEND/DODGE
    // PERK 2: MECH vs ELEMENTAL PERK CHOICE ---
    // Choose steel and electric (Mech path), or water and fire (Elemetal path)
    // (... will the mechs win the war for Ethertopia? or will the androids
    // be deluged in flood and fire? ...)
    // PERK 3: Commit to a specific elemental pathway:
    // 1. the path of steel: the iron sword; the burning frying pan!
    // 2. the path of electricity: the deadly taser, the fearsome forcefield
    // 3. the path of water: high pressure water blasters have never been so cool
    // 4. the path of fire!: we will hunt you down, Aang...


    struct User {
        // address userAddress;
        uint32 numShards; //limit shards to upper bound eg 10000
        uint32 experience;
        uint8[32] perks;
    }

    //Maintain an array of all users.
    // User[] public users;

    // Store a map of the address to a uint representing index of User within users
    // we check if a user exists at multiple points, every time they acquire
    // via a crate or the market. Users can also manually register their address.
    mapping ( address => User ) public addressToUser;

    // Array containing the structs of all parts in existence. The ID
    // of each part is an index into this array.
    Part[] parts;

    // Mapping from part IDs to to owning address. Should always exist.
    mapping (uint256 => address) public partIndexToOwner;

    //  A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count. REMOVE?
    mapping (address => uint256) addressToTokensOwned;

    // Mapping from Part ID to an address approved to call transferFrom().
    // maximum of one approved address for transfer at any time.
    mapping (uint256 => address) public partIndexToApproved;

    address auction;
    // address scrapyard;

    // Array to store approved battle contracts.
    // Can only ever be added to, not removed from.
    // Once a ruleset is published, you will ALWAYS be able to use that contract
    address[] approvedBattles;


    function getUserByAddress(address _user) public view returns (uint32, uint8[32]) {
        return (addressToUser[_user].experience, addressToUser[_user].perks);
    }

    //  Transfer a part to an address
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // No cap on number of parts
        // Very unlikely to ever be 2^256 parts owned by one account
        // Shouldn't waste gas checking for overflow
        // no point making it less than a uint --> mappings don't pack
        addressToTokensOwned[_to]++;
        // transfer ownership
        partIndexToOwner[_tokenId] = _to;
        // New parts are transferred _from 0x0, but we can't account that address.
        if (_from != address(0)) {
            addressToTokensOwned[_from]--;
            // clear any previously approved ownership exchange
            delete partIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    function getPartById(uint _id) external view returns (
        uint32 tokenId,
        uint8 partType,
        uint8 partSubType,
        uint8 rarity,
        uint8 element,
        uint32 battlesLastDay,
        uint32 experience,
        uint32 forgeTime,
        uint32 battlesLastReset
    ) {
        Part memory p = parts[_id];
        return (p.tokenId, p.partType, p.partSubType, p.rarity, p.element, p.battlesLastDay, p.experience, p.forgeTime, p.battlesLastReset);
    }


    function substring(string str, uint startIndex, uint endIndex) internal pure returns (string) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for (uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }

    // helper functions adapted from  Jossie Calderon on stackexchange
    function stringToUint32(string s) internal pure returns (uint32) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint i = 0; i < b.length; i++) { // c = b[i] was not needed
            if (b[i] >= 48 && b[i] <= 57) {
                result = result * 10 + (uint(b[i]) - 48); // bytes and int are not compatible with the operator -.
            }
        }
        return uint32(result);
    }

    function stringToUint8(string s) internal pure returns (uint8) {
        return uint8(stringToUint32(s));
    }

    function uintToString(uint v) internal pure returns (string) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i); // i + 1 is inefficient
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1]; // to avoid the off-by-one error
        }
        string memory str = string(s);
        return str;
    }
}
contract EtherbotsNFT is EtherbotsBase, ERC721Enumerable, ERC721Original {
    function supportsInterface(bytes4 _interfaceID) external pure returns (bool) {
        return (_interfaceID == ERC721Original.INTERFACE_SIGNATURE_ERC721Original) ||
            (_interfaceID == ERC721.INTERFACE_SIGNATURE_ERC721) ||
            (_interfaceID == ERC721Metadata.INTERFACE_SIGNATURE_ERC721Metadata) ||
            (_interfaceID == ERC721Enumerable.INTERFACE_SIGNATURE_ERC721Enumerable);
    }
    function implementsERC721() public pure returns (bool) {
        return true;
    }

    function name() public pure returns (string _name) {
      return "Etherbots";
    }

    function symbol() public pure returns (string _smbol) {
      return "ETHBOT";
    }

    // total supply of parts --> as no parts are ever deleted, this is simply
    // the total supply of parts ever created
    function totalSupply() public view returns (uint) {
        return parts.length;
    }

    /// @notice Returns the total number of deeds currently in existence.
    /// @dev Required for ERC-721 compliance.
    function countOfDeeds() external view returns (uint256) {
        return parts.length;
    }

    //--/ internal function    which checks whether the token with id (_tokenId)
    /// is owned by the (_claimant) address
    function owns(address _owner, uint256 _tokenId) public view returns (bool) {
        return (partIndexToOwner[_tokenId] == _owner);
    }

    /// internal function    which checks whether the token with id (_tokenId)
    /// is owned by the (_claimant) address
    function ownsAll(address _owner, uint256[] _tokenIds) public view returns (bool) {
        require(_tokenIds.length > 0);
        for (uint i = 0; i < _tokenIds.length; i++) {
            if (partIndexToOwner[_tokenIds[i]] != _owner) {
                return false;
            }
        }
        return true;
    }

    function _approve(uint256 _tokenId, address _approved) internal {
        partIndexToApproved[_tokenId] = _approved;
    }

    function _approvedFor(address _newOwner, uint256 _tokenId) internal view returns (bool) {
        return (partIndexToApproved[_tokenId] == _newOwner);
    }

    function ownerByIndex(uint256 _index) external view returns (address _owner){
        return partIndexToOwner[_index];
    }

    // returns the NUMBER of tokens owned by (_owner)
    function balanceOf(address _owner) public view returns (uint256 count) {
        return addressToTokensOwned[_owner];
    }

    function countOfDeedsByOwner(address _owner) external view returns (uint256) {
        return balanceOf(_owner);
    }

    // transfers a part to another account
    function transfer(address _to, uint256 _tokenId) public whenNotPaused payable {
        // payable for ERC721 --> don't actually send eth @<span class="__cf_email__" data-cfemail="8dd2cd">[email protected]</span>&#13;
        require(msg.value == 0);&#13;
&#13;
        // Safety checks to prevent accidental transfers to common accounts&#13;
        require(_to != address(0));&#13;
        require(_to != address(this));&#13;
        // can't transfer parts to the auction contract directly&#13;
        require(_to != address(auction));&#13;
        // can't transfer parts to any of the battle contracts directly&#13;
        for (uint j = 0; j &lt; approvedBattles.length; j++) {&#13;
            require(_to != approvedBattles[j]);&#13;
        }&#13;
&#13;
        // Cannot send tokens you don't own&#13;
        require(owns(msg.sender, _tokenId));&#13;
&#13;
        // perform state changes necessary for transfer&#13;
        _transfer(msg.sender, _to, _tokenId);&#13;
    }&#13;
    // transfers a part to another account&#13;
&#13;
    function transferAll(address _to, uint256[] _tokenIds) public whenNotPaused payable {&#13;
        require(msg.value == 0);&#13;
&#13;
        // Safety checks to prevent accidental transfers to common accounts&#13;
        require(_to != address(0));&#13;
        require(_to != address(this));&#13;
        // can't transfer parts to the auction contract directly&#13;
        require(_to != address(auction));&#13;
        // can't transfer parts to any of the battle contracts directly&#13;
        for (uint j = 0; j &lt; approvedBattles.length; j++) {&#13;
            require(_to != approvedBattles[j]);&#13;
        }&#13;
&#13;
        // Cannot send tokens you don't own&#13;
        require(ownsAll(msg.sender, _tokenIds));&#13;
&#13;
        for (uint k = 0; k &lt; _tokenIds.length; k++) {&#13;
            // perform state changes necessary for transfer&#13;
            _transfer(msg.sender, _to, _tokenIds[k]);&#13;
        }&#13;
&#13;
&#13;
    }&#13;
&#13;
&#13;
    // approves the (_to) address to use the transferFrom function on the token with id (_tokenId)&#13;
    // if you want to clear all approvals, simply pass the zero address&#13;
    function approve(address _to, uint256 _deedId) external whenNotPaused payable {&#13;
        // payable for ERC721 --&gt; don't actually send eth @<span class="__cf_email__" data-cfemail="5d021d">[email protected]</span>&#13;
        require(msg.value == 0);&#13;
// use internal function?&#13;
        // Cannot approve the transfer of tokens you don't own&#13;
        require(owns(msg.sender, _deedId));&#13;
&#13;
        // Store the approval (can only approve one at a time)&#13;
        partIndexToApproved[_deedId] = _to;&#13;
&#13;
        Approval(msg.sender, _to, _deedId);&#13;
    }&#13;
&#13;
    // approves many token ids&#13;
    function approveMany(address _to, uint256[] _tokenIds) external whenNotPaused payable {&#13;
&#13;
        for (uint i = 0; i &lt; _tokenIds.length; i++) {&#13;
            uint _tokenId = _tokenIds[i];&#13;
&#13;
            // Cannot approve the transfer of tokens you don't own&#13;
            require(owns(msg.sender, _tokenId));&#13;
&#13;
            // Store the approval (can only approve one at a time)&#13;
            partIndexToApproved[_tokenId] = _to;&#13;
            //create event for each approval? _tokenId guaranteed to hold correct value?&#13;
            Approval(msg.sender, _to, _tokenId);&#13;
        }&#13;
    }&#13;
&#13;
    // transfer the part with id (_tokenId) from (_from) to (_to)&#13;
    // (_to) must already be approved for this (_tokenId)&#13;
    function transferFrom(address _from, address _to, uint256 _tokenId) public whenNotPaused {&#13;
&#13;
        // Safety checks to prevent accidents&#13;
        require(_to != address(0));&#13;
        require(_to != address(this));&#13;
&#13;
        // sender must be approved&#13;
        require(partIndexToApproved[_tokenId] == msg.sender);&#13;
        // from must currently own the token&#13;
        require(owns(_from, _tokenId));&#13;
&#13;
        // Reassign ownership (also clears pending approvals and emits Transfer event).&#13;
        _transfer(_from, _to, _tokenId);&#13;
    }&#13;
&#13;
    // returns the current owner of the token with id = _tokenId&#13;
    function ownerOf(uint256 _deedId) public view returns (address _owner) {&#13;
        _owner = partIndexToOwner[_deedId];&#13;
        // must result false if index key not found&#13;
        require(_owner != address(0));&#13;
    }&#13;
&#13;
    // returns a dynamic array of the ids of all tokens which are owned by (_owner)&#13;
    // Looping through every possible part and checking it against the owner is&#13;
    // actually much more efficient than storing a mapping or something, because&#13;
    // it won't be executed as a transaction&#13;
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {&#13;
        uint256 totalParts = totalSupply();&#13;
&#13;
        return tokensOfOwnerWithinRange(_owner, 0, totalParts);&#13;
  &#13;
    }&#13;
&#13;
    function tokensOfOwnerWithinRange(address _owner, uint _start, uint _numToSearch) public view returns(uint256[] ownerTokens) {&#13;
        uint256 tokenCount = balanceOf(_owner);&#13;
&#13;
        uint256[] memory tmpResult = new uint256[](tokenCount);&#13;
        if (tokenCount == 0) {&#13;
            return tmpResult;&#13;
        }&#13;
&#13;
        uint256 resultIndex = 0;&#13;
        for (uint partId = _start; partId &lt; _start + _numToSearch; partId++) {&#13;
            if (partIndexToOwner[partId] == _owner) {&#13;
                tmpResult[resultIndex] = partId;&#13;
                resultIndex++;&#13;
                if (resultIndex == tokenCount) { //found all tokens accounted for, no need to continue&#13;
                    break;&#13;
                }&#13;
            }&#13;
        }&#13;
&#13;
        // copy number of tokens found in given range&#13;
        uint resultLength = resultIndex;&#13;
        uint256[] memory result = new uint256[](resultLength);&#13;
        for (uint i=0; i&lt;resultLength; i++) {&#13;
            result[i] = tmpResult[i];&#13;
        }&#13;
        return result;&#13;
    }&#13;
&#13;
&#13;
&#13;
    //same issues as above&#13;
    // Returns an array of all part structs owned by the user. Free to call.&#13;
    function getPartsOfOwner(address _owner) external view returns(bytes24[]) {&#13;
        uint256 totalParts = totalSupply();&#13;
&#13;
        return getPartsOfOwnerWithinRange(_owner, 0, totalParts);&#13;
    }&#13;
    &#13;
    // This is public so it can be called by getPartsOfOwner. It should NOT be called by another contract&#13;
    // as it is very gas hungry.&#13;
    function getPartsOfOwnerWithinRange(address _owner, uint _start, uint _numToSearch) public view returns(bytes24[]) {&#13;
        uint256 tokenCount = balanceOf(_owner);&#13;
&#13;
        uint resultIndex = 0;&#13;
        bytes24[] memory result = new bytes24[](tokenCount);&#13;
        for (uint partId = _start; partId &lt; _start + _numToSearch; partId++) {&#13;
            if (partIndexToOwner[partId] == _owner) {&#13;
                result[resultIndex] = _partToBytes(parts[partId]);&#13;
                resultIndex++;&#13;
            }&#13;
        }&#13;
        return result; // will have 0 elements if tokenCount == 0&#13;
    }&#13;
&#13;
&#13;
    function _partToBytes(Part p) internal pure returns (bytes24 b) {&#13;
        b = bytes24(p.tokenId);&#13;
&#13;
        b = b &lt;&lt; 8;&#13;
        b = b | bytes24(p.partType);&#13;
&#13;
        b = b &lt;&lt; 8;&#13;
        b = b | bytes24(p.partSubType);&#13;
&#13;
        b = b &lt;&lt; 8;&#13;
        b = b | bytes24(p.rarity);&#13;
&#13;
        b = b &lt;&lt; 8;&#13;
        b = b | bytes24(p.element);&#13;
&#13;
        b = b &lt;&lt; 32;&#13;
        b = b | bytes24(p.battlesLastDay);&#13;
&#13;
        b = b &lt;&lt; 32;&#13;
        b = b | bytes24(p.experience);&#13;
&#13;
        b = b &lt;&lt; 32;&#13;
        b = b | bytes24(p.forgeTime);&#13;
&#13;
        b = b &lt;&lt; 32;&#13;
        b = b | bytes24(p.battlesLastReset);&#13;
    }&#13;
&#13;
    uint32 constant FIRST_LEVEL = 1000;&#13;
    uint32 constant INCREMENT = 1000;&#13;
&#13;
    // every level, you need 1000 more exp to go up a level&#13;
    function getLevel(uint32 _exp) public pure returns(uint32) {&#13;
        uint32 c = 0;&#13;
        for (uint32 i = FIRST_LEVEL; i &lt;= FIRST_LEVEL + _exp; i += c * INCREMENT) {&#13;
            c++;&#13;
        }&#13;
        return c;&#13;
    }&#13;
&#13;
    string metadataBase = "https://api.etherbots.io/api/";&#13;
&#13;
&#13;
    function setMetadataBase(string _base) external onlyOwner {&#13;
        metadataBase = _base;&#13;
    }&#13;
&#13;
    // part type, subtype,&#13;
    // have one internal function which lets us implement the divergent interfaces&#13;
    function _metadata(uint256 _id) internal view returns(string) {&#13;
        Part memory p = parts[_id];&#13;
        return strConcat(strConcat(&#13;
            metadataBase,&#13;
            uintToString(uint(p.partType)),&#13;
            "/",&#13;
            uintToString(uint(p.partSubType)),&#13;
            "/"&#13;
        ), uintToString(uint(p.rarity)), "", "", "");&#13;
    }&#13;
&#13;
    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string){&#13;
        bytes memory _ba = bytes(_a);&#13;
        bytes memory _bb = bytes(_b);&#13;
        bytes memory _bc = bytes(_c);&#13;
        bytes memory _bd = bytes(_d);&#13;
        bytes memory _be = bytes(_e);&#13;
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);&#13;
        bytes memory babcde = bytes(abcde);&#13;
        uint k = 0;&#13;
        for (uint i = 0; i &lt; _ba.length; i++) babcde[k++] = _ba[i];&#13;
        for (i = 0; i &lt; _bb.length; i++) babcde[k++] = _bb[i];&#13;
        for (i = 0; i &lt; _bc.length; i++) babcde[k++] = _bc[i];&#13;
        for (i = 0; i &lt; _bd.length; i++) babcde[k++] = _bd[i];&#13;
        for (i = 0; i &lt; _be.length; i++) babcde[k++] = _be[i];&#13;
        return string(babcde);&#13;
    }&#13;
&#13;
    /// @notice A distinct URI (RFC 3986) for a given token.&#13;
    /// @dev If:&#13;
    ///  * The URI is a URL&#13;
    ///  * The URL is accessible&#13;
    ///  * The URL points to a valid JSON file format (ECMA-404 2nd ed.)&#13;
    ///  * The JSON base element is an object&#13;
    ///  then these names of the base element SHALL have special meaning:&#13;
    ///  * "name": A string identifying the item to which `_deedId` grants&#13;
    ///    ownership&#13;
    ///  * "description": A string detailing the item to which `_deedId` grants&#13;
    ///    ownership&#13;
    ///  * "image": A URI pointing to a file of image/* mime type representing&#13;
    ///    the item to which `_deedId` grants ownership&#13;
    ///  Wallets and exchanges MAY display this to the end user.&#13;
    ///  Consider making any images at a width between 320 and 1080 pixels and&#13;
    ///  aspect ratio between 1.91:1 and 4:5 inclusive.&#13;
    function deedUri(uint256 _deedId) external view returns (string _uri){&#13;
        return _metadata(_deedId);&#13;
    }&#13;
&#13;
    /// returns a metadata URI&#13;
    function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl) {&#13;
        return _metadata(_tokenId);&#13;
    }&#13;
&#13;
    function takeOwnership(uint256 _deedId) external payable {&#13;
        // payable for ERC721 --&gt; don't actually send eth @<span class="__cf_email__" data-cfemail="b3ecf3">[email protected]</span>&#13;
        require(msg.value == 0);&#13;
&#13;
        address _from = partIndexToOwner[_deedId];&#13;
&#13;
        require(_approvedFor(msg.sender, _deedId));&#13;
&#13;
        _transfer(_from, msg.sender, _deedId);&#13;
    }&#13;
&#13;
    // parts are stored sequentially&#13;
    function deedByIndex(uint256 _index) external view returns (uint256 _deedId){&#13;
        return _index;&#13;
    }&#13;
&#13;
    function countOfOwners() external view returns (uint256 _count){&#13;
        // TODO: implement this&#13;
        return 0;&#13;
    }&#13;
&#13;
// thirsty function&#13;
    function tokenOfOwnerByIndex(address _owner, uint _index) external view returns (uint _tokenId){&#13;
        return _tokenOfOwnerByIndex(_owner, _index);&#13;
    }&#13;
&#13;
// code duplicated&#13;
    function _tokenOfOwnerByIndex(address _owner, uint _index) private view returns (uint _tokenId){&#13;
        // The index should be valid.&#13;
        require(_index &lt; balanceOf(_owner));&#13;
&#13;
        // can loop through all without&#13;
        uint256 seen = 0;&#13;
        uint256 totalTokens = totalSupply();&#13;
&#13;
        for (uint i = 0; i &lt; totalTokens; i++) {&#13;
            if (partIndexToOwner[i] == _owner) {&#13;
                if (seen == _index) {&#13;
                    return i;&#13;
                }&#13;
                seen++;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function deedOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _deedId){&#13;
        return _tokenOfOwnerByIndex(_owner, _index);&#13;
    }&#13;
}&#13;
&#13;
// the contract which all battles must implement&#13;
// allows for different types of battles to take place&#13;
contract PerkTree is EtherbotsNFT {&#13;
    // The perktree is represented in a uint8[32] representing a binary tree&#13;
    // see the number of perks active&#13;
    // buy a new perk&#13;
    // 0: Prestige level -&gt; starts at 0;&#13;
    // next row of tree&#13;
    // 1: offensive moves 2: defensive moves&#13;
    // next row of tree&#13;
    // 3: melee attack 4: turret shooting 5: defend arm 6: body dodge&#13;
    // next row of tree&#13;
    // 7: mech melee 8: android melee 9: mech turret 10: android turret&#13;
    // 11: mech defence 12: android defence 13: mech body 14: android body&#13;
    //next row of tree&#13;
    // 15: melee electric 16: melee steel 17: melee fire 18: melee water&#13;
    // 19: turret electric 20: turret steel 21: turret fire 22: turret water&#13;
    // 23: defend electric 24: defend steel 25: defend fire 26: defend water&#13;
    // 27: body electric 28: body steel 29: body fire 30: body water&#13;
    function _leftChild(uint8 _i) internal pure returns (uint8) {&#13;
        return 2*_i + 1;&#13;
    }&#13;
    function _rightChild(uint8 _i) internal pure returns (uint8) {&#13;
        return 2*_i + 2;&#13;
    }&#13;
    function _parent(uint8 _i) internal pure returns (uint8) {&#13;
        return (_i-1)/2;&#13;
    }&#13;
&#13;
&#13;
    uint8 constant PRESTIGE_INDEX = 0;&#13;
    uint8 constant PERK_COUNT = 30;&#13;
&#13;
    event PrintPerk(string,uint8,uint8[32]);&#13;
&#13;
    function _isValidPerkToAdd(uint8[32] _perks, uint8 _index) internal pure returns (bool) {&#13;
        // a previously unlocked perk is not a valid perk to add.&#13;
        if ((_index==PRESTIGE_INDEX) || (_perks[_index] &gt; 0)) {&#13;
            return false;&#13;
        }&#13;
        // perk not valid if any ancestor not unlocked&#13;
        for (uint8 i = _parent(_index); i &gt; PRESTIGE_INDEX; i = _parent(i)) {&#13;
            if (_perks[i] == 0) {&#13;
                return false;&#13;
            }&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
    // sum of perks (excluding prestige)&#13;
    function _sumActivePerks(uint8[32] _perks) internal pure returns (uint256) {&#13;
        uint32 sum = 0;&#13;
        //sum from after prestige_index, to count+1 (for prestige index).&#13;
        for (uint8 i = PRESTIGE_INDEX+1; i &lt; PERK_COUNT+1; i++) {&#13;
            sum += _perks[i];&#13;
        }&#13;
        return sum;&#13;
    }&#13;
&#13;
    // you can unlock a new perk every two levels (including prestige when possible)&#13;
    function choosePerk(uint8 _i) external {&#13;
        require((_i &gt;= PRESTIGE_INDEX) &amp;&amp; (_i &lt; PERK_COUNT+1));&#13;
        User storage currentUser = addressToUser[msg.sender];&#13;
        uint256 _numActivePerks = _sumActivePerks(currentUser.perks);&#13;
        bool canPrestige = (_numActivePerks == PERK_COUNT);&#13;
&#13;
        //add prestige value to sum of perks&#13;
        _numActivePerks += currentUser.perks[PRESTIGE_INDEX] * PERK_COUNT;&#13;
        require(_numActivePerks &lt; getLevel(currentUser.experience) / 2);&#13;
&#13;
        if (_i == PRESTIGE_INDEX) {&#13;
            require(canPrestige);&#13;
            _prestige();&#13;
        } else {&#13;
            require(_isValidPerkToAdd(currentUser.perks, _i));&#13;
            _addPerk(_i);&#13;
        }&#13;
        PerkChosen(msg.sender, _i);&#13;
    }&#13;
&#13;
    function _addPerk(uint8 perk) internal {&#13;
        addressToUser[msg.sender].perks[perk]++;&#13;
    }&#13;
&#13;
    function _prestige() internal {&#13;
        User storage currentUser = addressToUser[msg.sender];&#13;
        for (uint8 i = 1; i &lt; currentUser.perks.length; i++) {&#13;
            currentUser.perks[i] = 0;&#13;
        }&#13;
        currentUser.perks[PRESTIGE_INDEX]++;&#13;
    }&#13;
&#13;
    event PerkChosen(address indexed upgradedUser, uint8 indexed perk);&#13;
&#13;
}&#13;
&#13;
// Central collection of storage on which all other contracts depend.&#13;
// Contains structs for parts, users and functions which control their&#13;
// transferrence.&#13;
&#13;
&#13;
// Auction contract, facilitating statically priced sales, as well as &#13;
// inflationary and deflationary pricing for items.&#13;
// Relies heavily on the ERC721 interface and so most of the methods&#13;
// are tightly bound to that implementation&#13;
contract NFTAuctionBase is Pausable {&#13;
&#13;
    ERC721AllImplementations public nftContract;&#13;
    uint256 public ownerCut;&#13;
    uint public minDuration;&#13;
    uint public maxDuration;&#13;
&#13;
    // Represents an auction on an NFT (in this case, Robot part)&#13;
    struct Auction {&#13;
        // address of part owner&#13;
        address seller;&#13;
        // wei price of listing&#13;
        uint256 startPrice;&#13;
        // wei price of floor&#13;
        uint256 endPrice;&#13;
        // duration of sale in seconds.&#13;
        uint64 duration;&#13;
        // Time when sale started&#13;
        // Reset to 0 after sale concluded&#13;
        uint64 start;&#13;
    }&#13;
&#13;
    function NFTAuctionBase() public {&#13;
        minDuration = 60 minutes;&#13;
        maxDuration = 30 days; // arbitrary&#13;
    }&#13;
&#13;
    // map of all tokens and their auctions&#13;
    mapping (uint256 =&gt; Auction) tokenIdToAuction;&#13;
&#13;
    event AuctionCreated(uint256 tokenId, uint256 startPrice, uint256 endPrice, uint64 duration, uint64 start);&#13;
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);&#13;
    event AuctionCancelled(uint256 tokenId);&#13;
&#13;
    // returns true if the token with id _partId is owned by the _claimant address&#13;
    function _owns(address _claimant, uint256 _partId) internal view returns (bool) {&#13;
        return nftContract.ownerOf(_partId) == _claimant;&#13;
    }&#13;
&#13;
   // returns false if auction start time is 0, likely from uninitialised struct&#13;
    function _isActiveAuction(Auction _auction) internal pure returns (bool) {&#13;
        return _auction.start &gt; 0;&#13;
    }&#13;
    &#13;
    // assigns ownership of the token with id = _partId to this contract&#13;
    // must have already been approved&#13;
    function _escrow(address, uint _partId) internal {&#13;
        // throws on transfer fail&#13;
        nftContract.takeOwnership(_partId);&#13;
    }&#13;
&#13;
    // transfer the token with id = _partId to buying address&#13;
    function _transfer(address _purchasor, uint256 _partId) internal {&#13;
        // successful purchaseder must takeOwnership of _partId&#13;
        // nftContract.approve(_purchasor, _partId); &#13;
               // actual transfer&#13;
                nftContract.transfer(_purchasor, _partId);&#13;
&#13;
    }&#13;
&#13;
    // creates&#13;
    function _newAuction(uint256 _partId, Auction _auction) internal {&#13;
&#13;
        require(_auction.duration &gt;= minDuration);&#13;
        require(_auction.duration &lt;= maxDuration);&#13;
&#13;
        tokenIdToAuction[_partId] = _auction;&#13;
&#13;
        AuctionCreated(uint256(_partId),&#13;
            uint256(_auction.startPrice),&#13;
            uint256(_auction.endPrice),&#13;
            uint64(_auction.duration),&#13;
            uint64(_auction.start)&#13;
        );&#13;
    }&#13;
&#13;
    function setMinDuration(uint _duration) external onlyOwner {&#13;
        minDuration = _duration;&#13;
    }&#13;
&#13;
    function setMaxDuration(uint _duration) external onlyOwner {&#13;
        maxDuration = _duration;&#13;
    }&#13;
&#13;
    /// Removes auction from public view, returns token to the seller&#13;
    function _cancelAuction(uint256 _partId, address _seller) internal {&#13;
        _removeAuction(_partId);&#13;
        _transfer(_seller, _partId);&#13;
        AuctionCancelled(_partId);&#13;
    }&#13;
&#13;
    event PrintEvent(string, address, uint);&#13;
&#13;
    // Calculates price and transfers purchase to owner. Part is NOT transferred to buyer.&#13;
    function _purchase(uint256 _partId, uint256 _purchaseAmount) internal returns (uint256) {&#13;
&#13;
        Auction storage auction = tokenIdToAuction[_partId];&#13;
&#13;
        // check that this token is being auctioned&#13;
        require(_isActiveAuction(auction));&#13;
&#13;
        // enforce purchase &gt;= the current price&#13;
        uint256 price = _currentPrice(auction);&#13;
        require(_purchaseAmount &gt;= price);&#13;
&#13;
        // Store seller before we delete auction.&#13;
        address seller = auction.seller;&#13;
&#13;
        // Valid purchase. Remove auction to prevent reentrancy.&#13;
        _removeAuction(_partId);&#13;
&#13;
        // Transfer proceeds to seller (if there are any!)&#13;
        if (price &gt; 0) {&#13;
            &#13;
            // Calculate and take fee from purchase&#13;
&#13;
            uint256 auctioneerCut = _computeFee(price);&#13;
            uint256 sellerProceeds = price - auctioneerCut;&#13;
&#13;
            PrintEvent("Seller, proceeds", seller, sellerProceeds);&#13;
&#13;
            // Pay the seller&#13;
            seller.transfer(sellerProceeds);&#13;
        }&#13;
&#13;
        // Calculate excess funds and return to buyer.&#13;
        uint256 purchaseExcess = _purchaseAmount - price;&#13;
&#13;
        PrintEvent("Sender, excess", msg.sender, purchaseExcess);&#13;
        // Return any excess funds. Reentrancy again prevented by deleting auction.&#13;
        msg.sender.transfer(purchaseExcess);&#13;
&#13;
        AuctionSuccessful(_partId, price, msg.sender);&#13;
&#13;
        return price;&#13;
    }&#13;
&#13;
    // returns the current price of the token being auctioned in _auction&#13;
    function _currentPrice(Auction storage _auction) internal view returns (uint256) {&#13;
        uint256 secsElapsed = now - _auction.start;&#13;
        return _computeCurrentPrice(&#13;
            _auction.startPrice,&#13;
            _auction.endPrice,&#13;
            _auction.duration,&#13;
            secsElapsed&#13;
        );&#13;
    }&#13;
&#13;
    // Checks if NFTPart is currently being auctioned.&#13;
    // function _isBeingAuctioned(Auction storage _auction) internal view returns (bool) {&#13;
    //     return (_auction.start &gt; 0);&#13;
    // }&#13;
&#13;
    // removes the auction of the part with id _partId&#13;
    function _removeAuction(uint256 _partId) internal {&#13;
        delete tokenIdToAuction[_partId];&#13;
    }&#13;
&#13;
    // computes the current price of an deflating-price auction &#13;
    function _computeCurrentPrice( uint256 _startPrice, uint256 _endPrice, uint256 _duration, uint256 _secondsPassed ) internal pure returns (uint256 _price) {&#13;
        _price = _startPrice;&#13;
        if (_secondsPassed &gt;= _duration) {&#13;
            // Has been up long enough to hit endPrice.&#13;
            // Return this price floor.&#13;
            _price = _endPrice;&#13;
            // this is a statically price sale. Just return the price.&#13;
        }&#13;
        else if (_duration &gt; 0) {&#13;
            // This auction contract supports auctioning from any valid price to any other valid price.&#13;
            // This means the price can dynamically increase upward, or downard.&#13;
            int256 priceDifference = int256(_endPrice) - int256(_startPrice);&#13;
            int256 currentPriceDifference = priceDifference * int256(_secondsPassed) / int256(_duration);&#13;
            int256 currentPrice = int256(_startPrice) + currentPriceDifference;&#13;
&#13;
            _price = uint256(currentPrice);&#13;
        }&#13;
        return _price;&#13;
    }&#13;
&#13;
    // Compute percentage fee of transaction&#13;
&#13;
    function _computeFee (uint256 _price) internal view returns (uint256) {&#13;
        return _price * ownerCut / 10000; &#13;
    }&#13;
&#13;
}&#13;
&#13;
// Clock auction for NFTParts.&#13;
// Only timed when pricing is dynamic (i.e. startPrice != endPrice).&#13;
// Else, this becomes an infinite duration statically priced sale,&#13;
// resolving when succesfully purchase for or cancelled.&#13;
&#13;
contract DutchAuction is NFTAuctionBase, EtherbotsPrivileges {&#13;
&#13;
    // The ERC-165 interface signature for ERC-721.&#13;
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0xda671b9b);&#13;
 &#13;
    function DutchAuction(address _nftAddress, uint256 _fee) public {&#13;
        require(_fee &lt;= 10000);&#13;
        ownerCut = _fee;&#13;
&#13;
        ERC721AllImplementations candidateContract = ERC721AllImplementations(_nftAddress);&#13;
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));&#13;
        nftContract = candidateContract;&#13;
    }&#13;
&#13;
    // Remove all ether from the contract. This will be marketplace fees.&#13;
    // Transfers to the NFT contract. &#13;
    // Can be called by owner or NFT contract.&#13;
&#13;
    function withdrawBalance() external {&#13;
        address nftAddress = address(nftContract);&#13;
&#13;
        require(msg.sender == owner || msg.sender == nftAddress);&#13;
&#13;
        nftAddress.transfer(this.balance);&#13;
    }&#13;
&#13;
    event PrintEvent(string, address, uint);&#13;
&#13;
    // Creates an auction and lists it.&#13;
    function createAuction( uint256 _partId, uint256 _startPrice, uint256 _endPrice, uint256 _duration, address _seller ) external whenNotPaused {&#13;
        // Sanity check that no inputs overflow how many bits we've allocated&#13;
        // to store them in the auction struct.&#13;
        require(_startPrice == uint256(uint128(_startPrice)));&#13;
        require(_endPrice == uint256(uint128(_endPrice)));&#13;
        require(_duration == uint256(uint64(_duration)));&#13;
        require(_startPrice &gt;= _endPrice);&#13;
&#13;
        require(msg.sender == address(nftContract));&#13;
        _escrow(_seller, _partId);&#13;
        Auction memory auction = Auction(&#13;
            _seller,&#13;
            uint128(_startPrice),&#13;
            uint128(_endPrice),&#13;
            uint64(_duration),&#13;
            uint64(now) //seconds uint &#13;
        );&#13;
        PrintEvent("Auction Start", 0x0, auction.start);&#13;
        _newAuction(_partId, auction);&#13;
    }&#13;
&#13;
&#13;
    // SCRAPYARD PRICING LOGIC&#13;
&#13;
    uint8 constant LAST_CONSIDERED = 5;&#13;
    uint8 public scrapCounter = 0;&#13;
    uint[5] public lastScrapPrices;&#13;
    &#13;
    // Purchases an open auction&#13;
    // Will transfer ownership if successful.&#13;
    &#13;
    function purchase(uint256 _partId) external payable whenNotPaused {&#13;
        address seller = tokenIdToAuction[_partId].seller;&#13;
&#13;
        // _purchase will throw if the purchase or funds transfer fails&#13;
        uint256 price = _purchase(_partId, msg.value);&#13;
        _transfer(msg.sender, _partId);&#13;
        &#13;
        // If the seller is the scrapyard, track price information.&#13;
        if (seller == address(nftContract)) {&#13;
&#13;
            lastScrapPrices[scrapCounter] = price;&#13;
            if (scrapCounter == LAST_CONSIDERED - 1) {&#13;
                scrapCounter = 0;&#13;
            } else {&#13;
                scrapCounter++;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function averageScrapPrice() public view returns (uint) {&#13;
        uint sum = 0;&#13;
        for (uint8 i = 0; i &lt; LAST_CONSIDERED; i++) {&#13;
            sum += lastScrapPrices[i];&#13;
        }&#13;
        return sum / LAST_CONSIDERED;&#13;
    }&#13;
&#13;
    // Allows a user to cancel an auction before it's resolved.&#13;
    // Returns the part to the seller.&#13;
&#13;
    function cancelAuction(uint256 _partId) external {&#13;
        Auction storage auction = tokenIdToAuction[_partId];&#13;
        require(_isActiveAuction(auction));&#13;
        address seller = auction.seller;&#13;
        require(msg.sender == seller);&#13;
        _cancelAuction(_partId, seller);&#13;
    }&#13;
&#13;
    // returns the current price of the auction of a token with id _partId&#13;
    function getCurrentPrice(uint256 _partId) external view returns (uint256) {&#13;
        Auction storage auction = tokenIdToAuction[_partId];&#13;
        require(_isActiveAuction(auction));&#13;
        return _currentPrice(auction);&#13;
    }&#13;
&#13;
    //  Returns the details of an auction from its _partId.&#13;
    function getAuction(uint256 _partId) external view returns ( address seller, uint256 startPrice, uint256 endPrice, uint256 duration, uint256 startedAt ) {&#13;
        Auction storage auction = tokenIdToAuction[_partId];&#13;
        require(_isActiveAuction(auction));&#13;
        return ( auction.seller, auction.startPrice, auction.endPrice, auction.duration, auction.start);&#13;
    }&#13;
&#13;
    // Allows owner to cancel an auction.&#13;
    // ONLY able to be used when contract is paused,&#13;
    // in the case of emergencies.&#13;
    // Parts returned to seller as it's equivalent to them &#13;
    // calling cancel.&#13;
    function cancelAuctionWhenPaused(uint256 _partId) whenPaused onlyOwner external {&#13;
        Auction storage auction = tokenIdToAuction[_partId];&#13;
        require(_isActiveAuction(auction));&#13;
        _cancelAuction(_partId, auction.seller);&#13;
    }&#13;
}&#13;
&#13;
contract EtherbotsAuction is PerkTree {&#13;
&#13;
    // Sets the reference to the sale auction.&#13;
&#13;
    function setAuctionAddress(address _address) external onlyOwner {&#13;
        require(_address != address(0));&#13;
        DutchAuction candidateContract = DutchAuction(_address);&#13;
&#13;
        // Set the new contract address&#13;
        auction = candidateContract;&#13;
    }&#13;
&#13;
    // list a part for auction.&#13;
&#13;
    function createAuction(&#13;
        uint256 _partId,&#13;
        uint256 _startPrice,&#13;
        uint256 _endPrice,&#13;
        uint256 _duration ) external whenNotPaused &#13;
    {&#13;
&#13;
&#13;
        // user must have current control of the part&#13;
        // will lose control if they delegate to the auction&#13;
        // therefore no duplicate auctions!&#13;
        require(owns(msg.sender, _partId));&#13;
&#13;
        _approve(_partId, auction);&#13;
&#13;
        // will throw if inputs are invalid&#13;
        // will clear transfer approval&#13;
        DutchAuction(auction).createAuction(_partId,_startPrice,_endPrice,_duration,msg.sender);&#13;
    }&#13;
&#13;
    // transfer balance back to core contract&#13;
    function withdrawAuctionBalance() external onlyOwner {&#13;
        DutchAuction(auction).withdrawBalance();&#13;
    }&#13;
&#13;
    // SCRAP FUNCTION&#13;
  &#13;
    // This takes scrapped parts and automatically relists them on the market.&#13;
    // Provides a good floor for entrance into the game, while keeping supply&#13;
    // constant as these parts were already in circulation.&#13;
&#13;
    // uint public constant SCRAPYARD_STARTING_PRICE = 0.1 ether;&#13;
    uint scrapMinStartPrice = 0.05 ether; // settable minimum starting price for sanity&#13;
    uint scrapMinEndPrice = 0.005 ether;  // settable minimum ending price for sanity&#13;
    uint scrapAuctionDuration = 2 days;&#13;
    &#13;
    function setScrapMinStartPrice(uint _newMinStartPrice) external onlyOwner {&#13;
        scrapMinStartPrice = _newMinStartPrice;&#13;
    }&#13;
    function setScrapMinEndPrice(uint _newMinEndPrice) external onlyOwner {&#13;
        scrapMinEndPrice = _newMinEndPrice;&#13;
    }&#13;
    function setScrapAuctionDuration(uint _newScrapAuctionDuration) external onlyOwner {&#13;
        scrapAuctionDuration = _newScrapAuctionDuration;&#13;
    }&#13;
 &#13;
    function _createScrapPartAuction(uint _scrapPartId) internal {&#13;
        // if (scrapyard == address(this)) {&#13;
        _approve(_scrapPartId, auction);&#13;
        &#13;
        DutchAuction(auction).createAuction(&#13;
            _scrapPartId,&#13;
            _getNextAuctionPrice(), // gen next auction price&#13;
            scrapMinEndPrice,&#13;
            scrapAuctionDuration,&#13;
            address(this)&#13;
        );&#13;
        // }&#13;
    }&#13;
&#13;
    function _getNextAuctionPrice() internal view returns (uint) {&#13;
        uint avg = DutchAuction(auction).averageScrapPrice();&#13;
        // add 30% to the average&#13;
        // prevent runaway pricing&#13;
        uint next = avg + ((30 * avg) / 100);&#13;
        if (next &lt; scrapMinStartPrice) {&#13;
            next = scrapMinStartPrice;&#13;
        }&#13;
        return next;&#13;
    }&#13;
&#13;
}&#13;
&#13;
contract PerksRewards is EtherbotsAuction {&#13;
    ///  An internal method that creates a new part and stores it. This&#13;
    ///  method doesn't do any checking and should only be called when the&#13;
    ///  input data is known to be valid. Will generate both a Forge event&#13;
    ///  and a Transfer event.&#13;
   function _createPart(uint8[4] _partArray, address _owner) internal returns (uint) {&#13;
        uint32 newPartId = uint32(parts.length);&#13;
        assert(newPartId == parts.length);&#13;
&#13;
        Part memory _part = Part({&#13;
            tokenId: newPartId,&#13;
            partType: _partArray[0],&#13;
            partSubType: _partArray[1],&#13;
            rarity: _partArray[2],&#13;
            element: _partArray[3],&#13;
            battlesLastDay: 0,&#13;
            experience: 0,&#13;
            forgeTime: uint32(now),&#13;
            battlesLastReset: uint32(now)&#13;
        });&#13;
        assert(newPartId == parts.push(_part) - 1);&#13;
&#13;
        // emit the FORGING!!!&#13;
        Forge(_owner, newPartId, _part);&#13;
&#13;
        // This will assign ownership, and also emit the Transfer event as&#13;
        // per ERC721 draft&#13;
        _transfer(0, _owner, newPartId);&#13;
&#13;
        return newPartId;&#13;
    }&#13;
&#13;
    uint public PART_REWARD_CHANCE = 995;&#13;
    // Deprecated subtypes contain the subtype IDs of legacy items&#13;
    // which are no longer available to be redeemed in game.&#13;
    // i.e. subtype ID 14 represents lambo body, presale exclusive.&#13;
    // a value of 0 represents that subtype (id within range)&#13;
    // as being deprecated for that part type (body, turret, etc)&#13;
    uint8[] public defenceElementBySubtypeIndex;&#13;
    uint8[] public meleeElementBySubtypeIndex;&#13;
    uint8[] public bodyElementBySubtypeIndex;&#13;
    uint8[] public turretElementBySubtypeIndex;&#13;
    // uint8[] public defenceElementBySubtypeIndex = [1,2,4,3,4,1,3,3,2,1,4];&#13;
    // uint8[] public meleeElementBySubtypeIndex = [3,1,3,2,3,4,2,2,1,1,1,1,4,4];&#13;
    // uint8[] public bodyElementBySubtypeIndex = [2,1,2,3,4,3,1,1,4,2,3,4,1,0,1]; // no more lambos :'(&#13;
    // uint8[] public turretElementBySubtypeIndex = [4,3,2,1,2,1,1,3,4,3,4];&#13;
&#13;
    function setRewardChance(uint _newChance) external onlyOwner {&#13;
        require(_newChance &gt; 980); // not too hot&#13;
        require(_newChance &lt;= 1000); // not too cold&#13;
        PART_REWARD_CHANCE = _newChance; // just right&#13;
        // come at me goldilocks&#13;
    }&#13;
    // The following functions DON'T create parts, they add new parts&#13;
    // as possible rewards from the reward pool.&#13;
&#13;
&#13;
    function addDefenceParts(uint8[] _newElement) external onlyOwner {&#13;
        for (uint8 i = 0; i &lt; _newElement.length; i++) {&#13;
            defenceElementBySubtypeIndex.push(_newElement[i]);&#13;
        }&#13;
        // require(defenceElementBySubtypeIndex.length &lt; uint(uint8(-1)));&#13;
    }&#13;
    function addMeleeParts(uint8[] _newElement) external onlyOwner {&#13;
        for (uint8 i = 0; i &lt; _newElement.length; i++) {&#13;
            meleeElementBySubtypeIndex.push(_newElement[i]);&#13;
        }&#13;
        // require(meleeElementBySubtypeIndex.length &lt; uint(uint8(-1)));&#13;
    }&#13;
    function addBodyParts(uint8[] _newElement) external onlyOwner {&#13;
        for (uint8 i = 0; i &lt; _newElement.length; i++) {&#13;
            bodyElementBySubtypeIndex.push(_newElement[i]);&#13;
        }&#13;
        // require(bodyElementBySubtypeIndex.length &lt; uint(uint8(-1)));&#13;
    }&#13;
    function addTurretParts(uint8[] _newElement) external onlyOwner {&#13;
        for (uint8 i = 0; i &lt; _newElement.length; i++) {&#13;
            turretElementBySubtypeIndex.push(_newElement[i]);&#13;
        }&#13;
        // require(turretElementBySubtypeIndex.length &lt; uint(uint8(-1)));&#13;
    }&#13;
    // Deprecate subtypes. Once a subtype has been deprecated it can never be&#13;
    // undeprecated. Starting with lambo!&#13;
    function deprecateDefenceSubtype(uint8 _subtypeIndexToDeprecate) external onlyOwner {&#13;
        defenceElementBySubtypeIndex[_subtypeIndexToDeprecate] = 0;&#13;
    }&#13;
&#13;
    function deprecateMeleeSubtype(uint8 _subtypeIndexToDeprecate) external onlyOwner {&#13;
        meleeElementBySubtypeIndex[_subtypeIndexToDeprecate] = 0;&#13;
    }&#13;
&#13;
    function deprecateBodySubtype(uint8 _subtypeIndexToDeprecate) external onlyOwner {&#13;
        bodyElementBySubtypeIndex[_subtypeIndexToDeprecate] = 0;&#13;
    }&#13;
&#13;
    function deprecateTurretSubtype(uint8 _subtypeIndexToDeprecate) external onlyOwner {&#13;
        turretElementBySubtypeIndex[_subtypeIndexToDeprecate] = 0;&#13;
    }&#13;
&#13;
    // function _randomIndex(uint _rand, uint8 _startIx, uint8 _endIx, uint8 _modulo) internal pure returns (uint8) {&#13;
    //     require(_startIx &lt; _endIx);&#13;
    //     bytes32 randBytes = bytes32(_rand);&#13;
    //     uint result = 0;&#13;
    //     for (uint8 i=_startIx; i&lt;_endIx; i++) {&#13;
    //         result = result | uint8(randBytes[i]);&#13;
    //         result &lt;&lt; 8;&#13;
    //     }&#13;
    //     uint8 resultInt = uint8(uint(result) % _modulo);&#13;
    //     return resultInt;&#13;
    // }&#13;
&#13;
&#13;
    // This function takes a random uint, an owner and randomly generates a valid part.&#13;
    // It then transfers that part to the owner.&#13;
    function _generateRandomPart(uint _rand, address _owner) internal {&#13;
        // random uint 20 in length - MAYBE 20.&#13;
        // first randomly gen a part type&#13;
        _rand = uint(keccak256(_rand));&#13;
        uint8[4] memory randomPart;&#13;
        randomPart[0] = uint8(_rand % 4) + 1;&#13;
        _rand = uint(keccak256(_rand));&#13;
&#13;
        // randomPart[0] = _randomIndex(_rand,0,4,4) + 1; // 1, 2, 3, 4, =&gt; defence, melee, body, turret&#13;
&#13;
        if (randomPart[0] == DEFENCE) {&#13;
            randomPart[1] = _getRandomPartSubtype(_rand,defenceElementBySubtypeIndex);&#13;
            randomPart[3] = _getElement(defenceElementBySubtypeIndex, randomPart[1]);&#13;
&#13;
        } else if (randomPart[0] == MELEE) {&#13;
            randomPart[1] = _getRandomPartSubtype(_rand,meleeElementBySubtypeIndex);&#13;
            randomPart[3] = _getElement(meleeElementBySubtypeIndex, randomPart[1]);&#13;
&#13;
        } else if (randomPart[0] == BODY) {&#13;
            randomPart[1] = _getRandomPartSubtype(_rand,bodyElementBySubtypeIndex);&#13;
            randomPart[3] = _getElement(bodyElementBySubtypeIndex, randomPart[1]);&#13;
&#13;
        } else if (randomPart[0] == TURRET) {&#13;
            randomPart[1] = _getRandomPartSubtype(_rand,turretElementBySubtypeIndex);&#13;
            randomPart[3] = _getElement(turretElementBySubtypeIndex, randomPart[1]);&#13;
&#13;
        }&#13;
        _rand = uint(keccak256(_rand));&#13;
        randomPart[2] = _getRarity(_rand);&#13;
        // randomPart[2] = _getRarity(_randomIndex(_rand,8,12,3)); // rarity&#13;
        _createPart(randomPart, _owner);&#13;
    }&#13;
&#13;
    function _getRandomPartSubtype(uint _rand, uint8[] elementBySubtypeIndex) internal pure returns (uint8) {&#13;
        require(elementBySubtypeIndex.length &lt; uint(uint8(-1)));&#13;
        uint8 subtypeLength = uint8(elementBySubtypeIndex.length);&#13;
        require(subtypeLength &gt; 0);&#13;
        uint8 subtypeIndex = uint8(_rand % subtypeLength);&#13;
        // uint8 subtypeIndex = _randomIndex(_rand,4,8,subtypeLength);&#13;
        uint8 count = 0;&#13;
        while (elementBySubtypeIndex[subtypeIndex] == 0) {&#13;
            subtypeIndex++;&#13;
            count++;&#13;
            if (subtypeIndex == subtypeLength) {&#13;
                subtypeIndex = 0;&#13;
            }&#13;
            if (count &gt; subtypeLength) {&#13;
                break;&#13;
            }&#13;
        }&#13;
        require(elementBySubtypeIndex[subtypeIndex] != 0);&#13;
        return subtypeIndex + 1;&#13;
    }&#13;
&#13;
&#13;
    function _getRarity(uint rand) pure internal returns (uint8) {&#13;
        uint16 rarity = uint16(rand % 1000);&#13;
        if (rarity &gt;= 990) {  // 1% chance of gold&#13;
          return GOLD;&#13;
        } else if (rarity &gt;= 970) { // 2% chance of shadow&#13;
          return SHADOW;&#13;
        } else {&#13;
          return STANDARD;&#13;
        }&#13;
    }&#13;
&#13;
    function _getElement(uint8[] elementBySubtypeIndex, uint8 subtype) internal pure returns (uint8) {&#13;
        uint8 subtypeIndex = subtype - 1;&#13;
        return elementBySubtypeIndex[subtypeIndex];&#13;
    }&#13;
&#13;
    mapping(address =&gt; uint[]) pendingPartCrates ;&#13;
&#13;
    function getPendingPartCrateLength() external view returns (uint) {&#13;
        return pendingPartCrates[msg.sender].length;&#13;
    }&#13;
&#13;
    /// Put shards together into a new part-crate&#13;
    function redeemShardsIntoPending() external {&#13;
        User storage user = addressToUser[msg.sender];&#13;
         while (user.numShards &gt;= SHARDS_TO_PART) {&#13;
             user.numShards -= SHARDS_TO_PART;&#13;
             pendingPartCrates[msg.sender].push(block.number);&#13;
             // 256 blocks to redeem&#13;
         }&#13;
    }&#13;
&#13;
    function openPendingPartCrates() external {&#13;
        uint[] memory crates = pendingPartCrates[msg.sender];&#13;
        for (uint i = 0; i &lt; crates.length; i++) {&#13;
            uint pendingBlockNumber = crates[i];&#13;
            // can't open on the same timestamp&#13;
            require(block.number &gt; pendingBlockNumber);&#13;
&#13;
            var hash = block.blockhash(pendingBlockNumber);&#13;
&#13;
            if (uint(hash) != 0) {&#13;
                // different results for all different crates, even on the same block/same user&#13;
                // randomness is already taken care of&#13;
                uint rand = uint(keccak256(hash, msg.sender, i)); // % (10 ** 20);&#13;
                _generateRandomPart(rand, msg.sender);&#13;
            } else {&#13;
                // Do nothing, no second chances to secure integrity of randomness.&#13;
            }&#13;
        }&#13;
        delete pendingPartCrates[msg.sender];&#13;
    }&#13;
&#13;
    uint32 constant SHARDS_MAX = 10000;&#13;
&#13;
    function _addShardsToUser(User storage _user, uint32 _shards) internal {&#13;
        uint32 updatedShards = _user.numShards + _shards;&#13;
        if (updatedShards &gt; SHARDS_MAX) {&#13;
            updatedShards = SHARDS_MAX;&#13;
        }&#13;
        _user.numShards = updatedShards;&#13;
        ShardsAdded(msg.sender, _shards);&#13;
    }&#13;
&#13;
    // FORGING / SCRAPPING&#13;
    event ShardsAdded(address caller, uint32 shards);&#13;
    event Scrap(address user, uint partId);&#13;
&#13;
    uint32 constant SHARDS_TO_PART = 500;&#13;
    uint8 public scrapPercent = 60;&#13;
    uint8 public burnRate = 60; &#13;
&#13;
    function setScrapPercent(uint8 _newPercent) external onlyOwner {&#13;
        require((_newPercent &gt;= 50) &amp;&amp; (_newPercent &lt;= 90));&#13;
        scrapPercent = _newPercent;&#13;
    }&#13;
&#13;
    // function setScrapyard(address _scrapyard) external onlyOwner {&#13;
    //     scrapyard = _scrapyard;&#13;
    // }&#13;
&#13;
    function setBurnRate(uint8 _rate) external onlyOwner {&#13;
        burnRate = _rate;&#13;
    }&#13;
&#13;
&#13;
    uint public scrapCount = 0;&#13;
&#13;
    // scraps a part for shards&#13;
    function scrap(uint partId) external {&#13;
        require(owns(msg.sender, partId));&#13;
        User storage u = addressToUser[msg.sender];&#13;
        _addShardsToUser(u, (SHARDS_TO_PART * scrapPercent) / 100);&#13;
        Scrap(msg.sender, partId);&#13;
        // this doesn't need to be secure&#13;
        // no way to manipulate it apart from guaranteeing your parts are resold&#13;
        // or burnt&#13;
        if (uint(keccak256(scrapCount)) % 100 &gt;= burnRate) {&#13;
            _transfer(msg.sender, address(this), partId);&#13;
            _createScrapPartAuction(partId);&#13;
        } else {&#13;
            _transfer(msg.sender, address(0), partId);&#13;
        }&#13;
        scrapCount++;&#13;
    }&#13;
&#13;
}&#13;
&#13;
contract Mint is PerksRewards {&#13;
    &#13;
    // Owner only function to give an address new parts.&#13;
    // Strictly capped at 5000.&#13;
    // This will ONLY be used for promotional purposes (i.e. providing items for Wax/OPSkins partnership)&#13;
    // which we don't benefit financially from, or giving users who win the prize of designing a part &#13;
    // for the game, a single copy of that part.&#13;
    &#13;
    uint16 constant MINT_LIMIT = 5000;&#13;
    uint16 public partsMinted = 0;&#13;
&#13;
    function mintParts(uint16 _count, address _owner) public onlyOwner {&#13;
        require(_count &gt; 0 &amp;&amp; _count &lt;= 50);&#13;
        // check overflow&#13;
        require(partsMinted + _count &gt; partsMinted);&#13;
        require(partsMinted + _count &lt; MINT_LIMIT);&#13;
        &#13;
        addressToUser[_owner].numShards += SHARDS_TO_PART * _count;&#13;
        &#13;
        partsMinted += _count;&#13;
    }       &#13;
&#13;
    function mintParticularPart(uint8[4] _partArray, address _owner) public onlyOwner {&#13;
        require(partsMinted &lt; MINT_LIMIT);&#13;
        /* cannot create deprecated parts&#13;
        for (uint i = 0; i &lt; deprecated.length; i++) {&#13;
            if (_partArray[2] == deprecated[i]) {&#13;
                revert();&#13;
            }&#13;
        } */&#13;
        _createPart(_partArray, _owner);&#13;
        partsMinted++;&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
contract NewCratePreSale {&#13;
    &#13;
    // migration functions migrate the data from the previous contract in stages&#13;
    // all addresses are included for transparency and easy verification&#13;
    // however addresses with no robots (i.e. failed transaction and never bought properly) have been commented out.&#13;
    // to view the full list of state assignments, go to etherscan.io/address/{address} and you can view the verified&#13;
    mapping (address =&gt; uint[]) public userToRobots; &#13;
&#13;
    function _migrate(uint _index) external onlyOwner {&#13;
        bytes4 selector = bytes4(keccak256("setData()"));&#13;
        address a = migrators[_index];&#13;
        require(a.delegatecall(selector));&#13;
    }&#13;
    // source code - feel free to verify the migration&#13;
    address[6] migrators = [&#13;
        0x700FeBD9360ac0A0a72F371615427Bec4E4454E5, //0x97AE01893E42d6d33fd9851A28E5627222Af7BBB,&#13;
        0x72Cc898de0A4EAC49c46ccb990379099461342f6,&#13;
        0xc3cC48da3B8168154e0f14Bf0446C7a93613F0A7,&#13;
        0x4cC96f2Ddf6844323ae0d8461d418a4D473b9AC3,&#13;
        0xa52bFcb5FF599e29EE2B9130F1575BaBaa27de0A,&#13;
        0xe503b42AabdA22974e2A8B75Fa87E010e1B13584&#13;
    ];&#13;
    &#13;
    function NewCratePreSale() public payable {&#13;
        &#13;
            owner = msg.sender;&#13;
        // one time transfer of state from the previous contract&#13;
        // var previous = CratePreSale(0x3c7767011C443EfeF2187cf1F2a4c02062da3998); //MAINNET&#13;
&#13;
        // oldAppreciationRateWei = previous.appreciationRateWei();&#13;
        oldAppreciationRateWei = 100000000000000;&#13;
        appreciationRateWei = oldAppreciationRateWei;&#13;
  &#13;
        // oldPrice = previous.currentPrice();&#13;
        oldPrice = 232600000000000000;&#13;
        currentPrice = oldPrice;&#13;
&#13;
        // oldCratesSold = previous.cratesSold();&#13;
        oldCratesSold = 1075;&#13;
        cratesSold = oldCratesSold;&#13;
&#13;
        // Migration Rationale&#13;
        // due to solidity issues with enumerability (contract calls cannot return dynamic arrays etc)&#13;
        // no need for trust -&gt; can still use web3 to call the previous contract and check the state&#13;
        // will only change in the future if people send more eth&#13;
        // and will be obvious due to change in crate count. Any purchases on the old contract&#13;
        // after this contract is deployed will be fully refunded, and those robots bought will be voided. &#13;
        // feel free to validate any address on the old etherscan:&#13;
        // https://etherscan.io/address/0x3c7767011C443EfeF2187cf1F2a4c02062da3998&#13;
        // can visit the exact contracts at the addresses listed above&#13;
    }&#13;
&#13;
    // ------ STATE ------&#13;
    uint256 constant public MAX_CRATES_TO_SELL = 3900; // Max no. of robot crates to ever be sold&#13;
    uint256 constant public PRESALE_END_TIMESTAMP = 1518699600; // End date for the presale - no purchases can be made after this date - Midnight 16 Feb 2018 UTC&#13;
&#13;
    uint256 public appreciationRateWei;&#13;
    uint32 public cratesSold;&#13;
    uint256 public currentPrice;&#13;
&#13;
    // preserve these for later verification&#13;
    uint32 public oldCratesSold;&#13;
    uint256 public oldPrice;&#13;
    uint256 public oldAppreciationRateWei;&#13;
    // mapping (address =&gt; uint32) public userCrateCount; // replaced with more efficient method&#13;
    &#13;
&#13;
    // store the unopened crates of this user&#13;
    // actually stores the blocknumber of each crate &#13;
    mapping (address =&gt; uint[]) public addressToPurchasedBlocks;&#13;
    // store the number of expired crates for each user &#13;
    // i.e. crates where the user failed to open the crate within 256 blocks (~1 hour)&#13;
    // these crates will be able to be opened post-launch&#13;
    mapping (address =&gt; uint) public expiredCrates;&#13;
    // store the part information of purchased crates&#13;
&#13;
&#13;
&#13;
    function openAll() public {&#13;
        uint len = addressToPurchasedBlocks[msg.sender].length;&#13;
        require(len &gt; 0);&#13;
        uint8 count = 0;&#13;
        // len &gt; i to stop predicatable wraparound&#13;
        for (uint i = len - 1; i &gt;= 0 &amp;&amp; len &gt; i; i--) {&#13;
            uint crateBlock = addressToPurchasedBlocks[msg.sender][i];&#13;
            require(block.number &gt; crateBlock);&#13;
            // can't open on the same timestamp&#13;
            var hash = block.blockhash(crateBlock);&#13;
            if (uint(hash) != 0) {&#13;
                // different results for all different crates, even on the same block/same user&#13;
                // randomness is already taken care of&#13;
                uint rand = uint(keccak256(hash, msg.sender, i)) % (10 ** 20);&#13;
                userToRobots[msg.sender].push(rand);&#13;
                count++;&#13;
            } else {&#13;
                // all others will be expired&#13;
                expiredCrates[msg.sender] += (i + 1);&#13;
                break;&#13;
            }&#13;
        }&#13;
        CratesOpened(msg.sender, count);&#13;
        delete addressToPurchasedBlocks[msg.sender];&#13;
    }&#13;
&#13;
    // ------ EVENTS ------&#13;
    event CratesPurchased(address indexed _from, uint8 _quantity);&#13;
    event CratesOpened(address indexed _from, uint8 _quantity);&#13;
&#13;
    // ------ FUNCTIONS ------&#13;
    function getPrice() view public returns (uint256) {&#13;
        return currentPrice;&#13;
    }&#13;
&#13;
    function getRobotCountForUser(address _user) external view returns(uint256) {&#13;
        return userToRobots[_user].length;&#13;
    }&#13;
&#13;
    function getRobotForUserByIndex(address _user, uint _index) external view returns(uint) {&#13;
        return userToRobots[_user][_index];&#13;
    }&#13;
&#13;
    function getRobotsForUser(address _user) view public returns (uint[]) {&#13;
        return userToRobots[_user];&#13;
    }&#13;
&#13;
    function getPendingCratesForUser(address _user) external view returns(uint[]) {&#13;
        return addressToPurchasedBlocks[_user];&#13;
    }&#13;
&#13;
    function getPendingCrateForUserByIndex(address _user, uint _index) external view returns(uint) {&#13;
        return addressToPurchasedBlocks[_user][_index];&#13;
    }&#13;
&#13;
    function getExpiredCratesForUser(address _user) external view returns(uint) {&#13;
        return expiredCrates[_user];&#13;
    }&#13;
&#13;
    function incrementPrice() private {&#13;
        // Decrease the rate of increase of the crate price&#13;
        // as the crates become more expensive&#13;
        // to avoid runaway pricing&#13;
        // (halving rate of increase at 0.1 ETH, 0.2 ETH, 0.3 ETH).&#13;
        if ( currentPrice == 100000000000000000 ) {&#13;
            appreciationRateWei = 200000000000000;&#13;
        } else if ( currentPrice == 200000000000000000) {&#13;
            appreciationRateWei = 100000000000000;&#13;
        } else if (currentPrice == 300000000000000000) {&#13;
            appreciationRateWei = 50000000000000;&#13;
        }&#13;
        currentPrice += appreciationRateWei;&#13;
    }&#13;
&#13;
    function purchaseCrates(uint8 _cratesToBuy) public payable whenNotPaused {&#13;
        require(now &lt; PRESALE_END_TIMESTAMP); // Check presale is still ongoing.&#13;
        require(_cratesToBuy &lt;= 10); // Can only buy max 10 crates at a time. Don't be greedy!&#13;
        require(_cratesToBuy &gt;= 1); // Sanity check. Also, you have to buy a crate. &#13;
        require(cratesSold + _cratesToBuy &lt;= MAX_CRATES_TO_SELL); // Check max crates sold is less than hard limit&#13;
        uint256 priceToPay = _calculatePayment(_cratesToBuy);&#13;
         require(msg.value &gt;= priceToPay); // Check buyer sent sufficient funds to purchase&#13;
        if (msg.value &gt; priceToPay) { //overpaid, return excess&#13;
            msg.sender.transfer(msg.value-priceToPay);&#13;
        }&#13;
        //all good, payment received. increment number sold, price, and generate crate receipts!&#13;
        cratesSold += _cratesToBuy;&#13;
      for (uint8 i = 0; i &lt; _cratesToBuy; i++) {&#13;
            incrementPrice();&#13;
            addressToPurchasedBlocks[msg.sender].push(block.number);&#13;
        }&#13;
&#13;
        CratesPurchased(msg.sender, _cratesToBuy);&#13;
    } &#13;
&#13;
    function _calculatePayment (uint8 _cratesToBuy) private view returns (uint256) {&#13;
        &#13;
        uint256 tempPrice = currentPrice;&#13;
&#13;
        for (uint8 i = 1; i &lt; _cratesToBuy; i++) {&#13;
            tempPrice += (currentPrice + (appreciationRateWei * i));&#13;
        } // for every crate over 1 bought, add current Price and a multiple of the appreciation rate&#13;
          // very small edge case of buying 10 when you the appreciation rate is about to halve&#13;
          // is compensated by the great reduction in gas by buying N at a time.&#13;
        &#13;
        return tempPrice;&#13;
    }&#13;
&#13;
&#13;
    //owner only withdrawal function for the presale&#13;
    function withdraw() onlyOwner public {&#13;
        owner.transfer(this.balance);&#13;
    }&#13;
&#13;
    function addFunds() onlyOwner external payable {&#13;
&#13;
    }&#13;
&#13;
  event SetPaused(bool paused);&#13;
&#13;
  // starts unpaused&#13;
  bool public paused = false;&#13;
&#13;
  modifier whenNotPaused() {&#13;
    require(!paused);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier whenPaused() {&#13;
    require(paused);&#13;
    _;&#13;
  }&#13;
&#13;
  function pause() external onlyOwner whenNotPaused returns (bool) {&#13;
    paused = true;&#13;
    SetPaused(paused);&#13;
    return true;&#13;
  }&#13;
&#13;
  function unpause() external onlyOwner whenPaused returns (bool) {&#13;
    paused = false;&#13;
    SetPaused(paused);&#13;
    return true;&#13;
  }&#13;
&#13;
&#13;
  address public owner;&#13;
&#13;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);&#13;
&#13;
&#13;
&#13;
&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  function transferOwnership(address newOwner) public onlyOwner {&#13;
    require(newOwner != address(0));&#13;
    OwnershipTransferred(owner, newOwner);&#13;
    owner = newOwner;&#13;
  }&#13;
    &#13;
}&#13;
contract EtherbotsMigrations is Mint {&#13;
&#13;
    event CratesOpened(address indexed _from, uint8 _quantity);&#13;
    event OpenedOldCrates(address indexed _from);&#13;
    event MigratedCrates(address indexed _from, uint16 _quantity, bool isMigrationComplete);&#13;
&#13;
    address presale = 0xc23F76aEa00B775AADC8504CcB22468F4fD2261A;&#13;
    mapping(address =&gt; bool) public hasMigrated;&#13;
    mapping(address =&gt; bool) public hasOpenedOldCrates;&#13;
    mapping(address =&gt; uint[]) pendingCrates;&#13;
    mapping(address =&gt; uint16) public cratesMigrated;&#13;
&#13;
  &#13;
    // Element: copy for MIGRATIONS ONLY.&#13;
    string constant private DEFENCE_ELEMENT_BY_ID = "12434133214";&#13;
    string constant private MELEE_ELEMENT_BY_ID = "31323422111144";&#13;
    string constant private BODY_ELEMENT_BY_ID = "212343114234111";&#13;
    string constant private TURRET_ELEMENT_BY_ID = "43212113434";&#13;
&#13;
    // Once only function.&#13;
    // Transfers all pending and expired crates in the old contract&#13;
    // into pending crates in the current one.&#13;
    // Users can then open them on the new contract.&#13;
    // Should only rarely have to be called.&#13;
    // event oldpending(uint old);&#13;
&#13;
    function openOldCrates() external {&#13;
        require(hasOpenedOldCrates[msg.sender] == false);&#13;
        // uint oldPendingCrates = NewCratePreSale(presale).getPendingCrateForUserByIndex(msg.sender,0); // getting unrecognised opcode here --!&#13;
        // oldpending(oldPendingCrates);&#13;
        // require(oldPendingCrates == 0);&#13;
        _migrateExpiredCrates();&#13;
        hasOpenedOldCrates[msg.sender] = true;&#13;
        OpenedOldCrates(msg.sender);&#13;
    }&#13;
&#13;
    function migrate() external whenNotPaused {&#13;
        &#13;
        // Can't migrate twice .&#13;
        require(hasMigrated[msg.sender] == false);&#13;
        &#13;
        // require(NewCratePreSale(presale).getPendingCrateForUserByIndex(msg.sender,0) == 0);&#13;
        // No pending crates in the new contract allowed. Make sure you open them first.&#13;
        require(pendingCrates[msg.sender].length == 0);&#13;
        &#13;
        // If the user has old expired crates, don't let them migrate until they've&#13;
        // converted them to pending crates in the new contract.&#13;
        if (NewCratePreSale(presale).getExpiredCratesForUser(msg.sender) &gt; 0) {&#13;
            require(hasOpenedOldCrates[msg.sender]); &#13;
        }&#13;
&#13;
        // have to make a ton of calls unfortunately &#13;
        uint16 length = uint16(NewCratePreSale(presale).getRobotCountForUser(msg.sender));&#13;
&#13;
        // gas limit will be exceeded with *whale* etherbot players!&#13;
        // let's migrate their robots in batches of ten.&#13;
        // they can afford it&#13;
        bool isMigrationComplete = false;&#13;
        var max = length - cratesMigrated[msg.sender];&#13;
        if (max &gt; 9) {&#13;
            max = 9;&#13;
        } else { // final call - all robots will be migrated&#13;
            isMigrationComplete = true;&#13;
            hasMigrated[msg.sender] = true;&#13;
        }&#13;
        for (uint i = cratesMigrated[msg.sender]; i &lt; cratesMigrated[msg.sender] + max; i++) {&#13;
            var robot = NewCratePreSale(presale).getRobotForUserByIndex(msg.sender, i);&#13;
            var robotString = uintToString(robot);&#13;
            // MigratedBot(robotString);&#13;
&#13;
            _migrateRobot(robotString);&#13;
            &#13;
        }&#13;
        cratesMigrated[msg.sender] += max;&#13;
        MigratedCrates(msg.sender, cratesMigrated[msg.sender], isMigrationComplete);&#13;
    }&#13;
&#13;
    function _migrateRobot(string robot) private {&#13;
        var (melee, defence, body, turret) = _convertBlueprint(robot);&#13;
        // blueprints event&#13;
        // blueprints(body, turret, melee, defence);&#13;
        _createPart(melee, msg.sender);&#13;
        _createPart(defence, msg.sender);&#13;
        _createPart(turret, msg.sender);&#13;
        _createPart(body, msg.sender);&#13;
    }&#13;
&#13;
    function _getRarity(string original, uint8 low, uint8 high) pure private returns (uint8) {&#13;
        uint32 rarity = stringToUint32(substring(original,low,high));&#13;
        if (rarity &gt;= 950) {&#13;
          return GOLD; &#13;
        } else if (rarity &gt;= 850) {&#13;
          return SHADOW;&#13;
        } else {&#13;
          return STANDARD; &#13;
        }&#13;
    }&#13;
   &#13;
    function _getElement(string elementString, uint partId) pure private returns(uint8) {&#13;
        return stringToUint8(substring(elementString, partId-1,partId));&#13;
    }&#13;
&#13;
    // Actually part type&#13;
    function _getPartId(string original, uint8 start, uint8 end, uint8 partCount) pure private returns(uint8) {&#13;
        return (stringToUint8(substring(original,start,end)) % partCount) + 1;&#13;
    }&#13;
&#13;
    function userPendingCrateNumber(address _user) external view returns (uint) {&#13;
        return pendingCrates[_user].length;&#13;
    }    &#13;
    &#13;
    // convert old string representation of robot into 4 new ERC721 parts&#13;
  &#13;
    function _convertBlueprint(string original) pure private returns(uint8[4] body,uint8[4] melee, uint8[4] turret, uint8[4] defence ) {&#13;
&#13;
        /* ------ CONVERSION TIME ------ */&#13;
        &#13;
&#13;
        body[0] = BODY; &#13;
        body[1] = _getPartId(original, 3, 5, 15);&#13;
        body[2] = _getRarity(original, 0, 3);&#13;
        body[3] = _getElement(BODY_ELEMENT_BY_ID, body[1]);&#13;
        &#13;
        turret[0] = TURRET;&#13;
        turret[1] = _getPartId(original, 8, 10, 11);&#13;
        turret[2] = _getRarity(original, 5, 8);&#13;
        turret[3] = _getElement(TURRET_ELEMENT_BY_ID, turret[1]);&#13;
&#13;
        melee[0] = MELEE;&#13;
        melee[1] = _getPartId(original, 13, 15, 14);&#13;
        melee[2] = _getRarity(original, 10, 13);&#13;
        melee[3] = _getElement(MELEE_ELEMENT_BY_ID, melee[1]);&#13;
&#13;
        defence[0] = DEFENCE;&#13;
        var len = bytes(original).length;&#13;
        // string of number does not have preceding 0's&#13;
        if (len == 20) {&#13;
            defence[1] = _getPartId(original, 18, 20, 11);&#13;
        } else if (len == 19) {&#13;
            defence[1] = _getPartId(original, 18, 19, 11);&#13;
        } else { //unlikely to have length less than 19&#13;
            defence[1] = uint8(1);&#13;
        }&#13;
        defence[2] = _getRarity(original, 15, 18);&#13;
        defence[3] = _getElement(DEFENCE_ELEMENT_BY_ID, defence[1]);&#13;
&#13;
        // implicit return&#13;
    }&#13;
&#13;
    // give one more chance&#13;
    function _migrateExpiredCrates() private {&#13;
        // get the number of expired crates&#13;
        uint expired = NewCratePreSale(presale).getExpiredCratesForUser(msg.sender);&#13;
        for (uint i = 0; i &lt; expired; i++) {&#13;
            pendingCrates[msg.sender].push(block.number);&#13;
        }&#13;
    }&#13;
    // Users can open pending crates on the new contract.&#13;
    function openCrates() public whenNotPaused {&#13;
        uint[] memory pc = pendingCrates[msg.sender];&#13;
        require(pc.length &gt; 0);&#13;
        uint8 count = 0;&#13;
        for (uint i = 0; i &lt; pc.length; i++) {&#13;
            uint crateBlock = pc[i];&#13;
            require(block.number &gt; crateBlock);&#13;
            // can't open on the same timestamp&#13;
            var hash = block.blockhash(crateBlock);&#13;
            if (uint(hash) != 0) {&#13;
                // different results for all different crates, even on the same block/same user&#13;
                // randomness is already taken care of&#13;
                uint rand = uint(keccak256(hash, msg.sender, i)) % (10 ** 20);&#13;
                _migrateRobot(uintToString(rand));&#13;
                count++;&#13;
            }&#13;
        }&#13;
        CratesOpened(msg.sender, count);&#13;
        delete pendingCrates[msg.sender];&#13;
    }&#13;
&#13;
    &#13;
}&#13;
&#13;
contract Battle {&#13;
    // This struct does not exist outside the context of a battle&#13;
&#13;
    // the name of the battle type&#13;
    function name() external view returns (string);&#13;
    // the number of robots currently battling&#13;
    function playerCount() external view returns (uint count);&#13;
    // creates a new battle, with a submitted user string for initial input/&#13;
    function createBattle(address _creator, uint[] _partIds, bytes32 _commit, uint _revealLength) external payable returns (uint);&#13;
    // cancels the battle at battleID&#13;
    function cancelBattle(uint battleID) external;&#13;
    &#13;
    function winnerOf(uint battleId, uint index) external view returns (address);&#13;
    function loserOf(uint battleId, uint index) external view returns (address);&#13;
&#13;
    event BattleCreated(uint indexed battleID, address indexed starter);&#13;
    event BattleStage(uint indexed battleID, uint8 moveNumber, uint8[2] attackerMovesDefenderMoves, uint16[2] attackerDamageDefenderDamage);&#13;
    event BattleEnded(uint indexed battleID, address indexed winner);&#13;
    event BattleConcluded(uint indexed battleID);&#13;
    event BattlePropertyChanged(string name, uint previous, uint value);&#13;
}&#13;
contract EtherbotsBattle is EtherbotsMigrations {&#13;
&#13;
    // can never remove any of these contracts, can only add&#13;
    // once we publish a contract, you'll always be able to play by that ruleset&#13;
    // good for two player games which are non-susceptible to collusion&#13;
    // people can be trusted to choose the most beneficial outcome, which in this case&#13;
    // is the fairest form of gameplay.&#13;
    // fields which are vulnerable to collusion still have to be centrally controlled :(&#13;
    function addApprovedBattle(Battle _battle) external onlyOwner {&#13;
        approvedBattles.push(_battle);&#13;
    }&#13;
&#13;
    function _isApprovedBattle() internal view returns (bool) {&#13;
        for (uint8 i = 0; i &lt; approvedBattles.length; i++) {&#13;
            if (msg.sender == address(approvedBattles[i])) {&#13;
                return true;&#13;
            }&#13;
        }&#13;
        return false;&#13;
    }&#13;
&#13;
    modifier onlyApprovedBattles(){&#13;
        require(_isApprovedBattle());&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    function createBattle(uint _battleId, uint[] partIds, bytes32 commit, uint revealLength) external payable {&#13;
        // sanity check to make sure _battleId is a valid battle&#13;
        require(_battleId &lt; approvedBattles.length);&#13;
        //if parts are given, make sure they are owned&#13;
        if (partIds.length &gt; 0) {&#13;
            require(ownsAll(msg.sender, partIds));&#13;
        }&#13;
        //battle can decide number of parts required for battle&#13;
&#13;
        Battle battle = Battle(approvedBattles[_battleId]);&#13;
        // Transfer all to selected battle contract.&#13;
        for (uint i=0; i&lt;partIds.length; i++) {&#13;
            _approve(partIds[i], address(battle));&#13;
        }&#13;
        uint newDuelId = battle.createBattle.value(msg.value)(msg.sender, partIds, commit, revealLength);&#13;
        NewDuel(_battleId, newDuelId);&#13;
    }&#13;
&#13;
    event NewDuel(uint battleId, uint duelId);&#13;
&#13;
&#13;
    mapping(address =&gt; Reward[]) public pendingRewards;&#13;
    // actually probably just want a length getter here as default public mapping getters&#13;
    // are pretty expensive&#13;
&#13;
    function getPendingBattleRewardsCount(address _user) external view returns (uint) {&#13;
        return pendingRewards[_user].length;&#13;
    } &#13;
&#13;
    struct Reward {&#13;
        uint blocknumber;&#13;
        int32 exp;&#13;
    }&#13;
&#13;
    function addExperience(address _user, uint[] _partIds, int32[] _exps) external onlyApprovedBattles {&#13;
        address user = _user;&#13;
        require(_partIds.length == _exps.length);&#13;
        int32 sum = 0;&#13;
        for (uint i = 0; i &lt; _exps.length; i++) {&#13;
            sum += _addPartExperience(_partIds[i], _exps[i]);&#13;
        }&#13;
        _addUserExperience(user, sum);&#13;
        _storeReward(user, sum);&#13;
    }&#13;
&#13;
    // store sum.&#13;
    function _storeReward(address _user, int32 _battleExp) internal {&#13;
        pendingRewards[_user].push(Reward({&#13;
            blocknumber: 0,&#13;
            exp: _battleExp&#13;
        }));&#13;
    }&#13;
&#13;
    /* function _getExpProportion(int _exp) returns(int) {&#13;
        // assume max/min of 1k, -1k&#13;
        return 1000 + _exp + 1; // makes it between (1, 2001)&#13;
    } */&#13;
    uint8 bestMultiple = 3;&#13;
    uint8 mediumMultiple = 2;&#13;
    uint8 worstMultiple = 1;&#13;
    uint8 minShards = 1;&#13;
    uint8 bestProbability = 97;&#13;
    uint8 mediumProbability = 85;&#13;
    function _getExpMultiple(int _exp) internal view returns (uint8, uint8) {&#13;
        if (_exp &gt; 500) {&#13;
            return (bestMultiple,mediumMultiple);&#13;
        } else if (_exp &gt; 0) {&#13;
            return (mediumMultiple,mediumMultiple);&#13;
        } else {&#13;
            return (worstMultiple,mediumMultiple);&#13;
        }&#13;
    }&#13;
&#13;
    function setBest(uint8 _newBestMultiple) external onlyOwner {&#13;
        bestMultiple = _newBestMultiple;&#13;
    }&#13;
    function setMedium(uint8 _newMediumMultiple) external onlyOwner {&#13;
        mediumMultiple = _newMediumMultiple;&#13;
    }&#13;
    function setWorst(uint8 _newWorstMultiple) external onlyOwner {&#13;
        worstMultiple = _newWorstMultiple;&#13;
    }&#13;
    function setMinShards(uint8 _newMin) external onlyOwner {&#13;
        minShards = _newMin;&#13;
    }&#13;
    function setBestProbability(uint8 _newBestProb) external onlyOwner {&#13;
        bestProbability = _newBestProb;&#13;
    }&#13;
    function setMediumProbability(uint8 _newMinProb) external onlyOwner {&#13;
        mediumProbability = _newMinProb;&#13;
    }&#13;
&#13;
&#13;
&#13;
    function _calculateShards(int _exp, uint rand) internal view returns (uint16) {&#13;
        var (a, b) = _getExpMultiple(_exp);&#13;
        uint16 shards;&#13;
        uint randPercent = rand % 100;&#13;
        if (randPercent &gt; bestProbability) {&#13;
            shards = uint16(a * ((rand % 20) + 12) / b);&#13;
        } else if (randPercent &gt; mediumProbability) {&#13;
            shards = uint16(a * ((rand % 10) + 6) / b);  &#13;
        } else {&#13;
            shards = uint16((a * (rand % 5)) / b);       &#13;
        }&#13;
&#13;
        if (shards &lt; minShards) {&#13;
            shards = minShards;&#13;
        }&#13;
&#13;
        return shards;&#13;
    }&#13;
&#13;
    // convert wins into pending battle crates&#13;
    // Not to pending old crates (migration), nor pending part crates (redeemShards)&#13;
    function convertReward() external {&#13;
&#13;
        Reward[] storage rewards = pendingRewards[msg.sender];&#13;
&#13;
        for (uint i = 0; i &lt; rewards.length; i++) {&#13;
            if (rewards[i].blocknumber == 0) {&#13;
                rewards[i].blocknumber = block.number;&#13;
            }&#13;
        }&#13;
&#13;
    }&#13;
&#13;
    // in PerksRewards&#13;
    function redeemBattleCrates() external {&#13;
        uint8 count = 0;&#13;
        uint len = pendingRewards[msg.sender].length;&#13;
        require(len &gt; 0);&#13;
        for (uint i = 0; i &lt; len; i++) {&#13;
            Reward memory rewardStruct = pendingRewards[msg.sender][i];&#13;
            // can't open on the same timestamp&#13;
            require(block.number &gt; rewardStruct.blocknumber);&#13;
            // ensure user has converted all pendingRewards&#13;
            require(rewardStruct.blocknumber != 0);&#13;
&#13;
            var hash = block.blockhash(rewardStruct.blocknumber);&#13;
&#13;
            if (uint(hash) != 0) {&#13;
                // different results for all different crates, even on the same block/same user&#13;
                // randomness is already taken care of&#13;
                uint rand = uint(keccak256(hash, msg.sender, i));&#13;
                _generateBattleReward(rand,rewardStruct.exp);&#13;
                count++;&#13;
            } else {&#13;
                // Do nothing, no second chances to secure integrity of randomness.&#13;
            }&#13;
        }&#13;
        CratesOpened(msg.sender, count);&#13;
        delete pendingRewards[msg.sender];&#13;
    }&#13;
&#13;
    function _generateBattleReward(uint rand, int32 exp) internal {&#13;
        if (((rand % 1000) &gt; PART_REWARD_CHANCE) &amp;&amp; (exp &gt; 0)) {&#13;
            _generateRandomPart(rand, msg.sender);&#13;
        } else {&#13;
            _addShardsToUser(addressToUser[msg.sender], _calculateShards(exp, rand));&#13;
        }&#13;
    }&#13;
&#13;
    // don't need to do any scaling&#13;
    // should already have been done by previous stages&#13;
    function _addUserExperience(address user, int32 exp) internal {&#13;
        // never allow exp to drop below 0&#13;
        User memory u = addressToUser[user];&#13;
        if (exp &lt; 0 &amp;&amp; uint32(int32(u.experience) + exp) &gt; u.experience) {&#13;
            u.experience = 0;&#13;
            return;&#13;
        } else if (exp &gt; 0) {&#13;
            // check for overflow&#13;
            require(uint32(int32(u.experience) + exp) &gt; u.experience);&#13;
        }&#13;
        addressToUser[user].experience = uint32(int32(u.experience) + exp);&#13;
        //_addUserReward(user, exp);&#13;
    }&#13;
&#13;
    function setMinScaled(int8 _min) external onlyOwner {&#13;
        minScaled = _min;&#13;
    }&#13;
&#13;
    int8 minScaled = 25;&#13;
&#13;
    function _scaleExp(uint32 _battleCount, int32 _exp) internal view returns (int32) {&#13;
        if (_battleCount &lt;= 10) {&#13;
            return _exp; // no drop off&#13;
        }&#13;
        int32 exp =  (_exp * 10)/int32(_battleCount);&#13;
&#13;
        if (exp &lt; minScaled) {&#13;
            return minScaled;&#13;
        }&#13;
        return exp;&#13;
    }&#13;
&#13;
    function _addPartExperience(uint _id, int32 _baseExp) internal returns (int32) {&#13;
        // never allow exp to drop below 0&#13;
        Part storage p = parts[_id];&#13;
        if (now - p.battlesLastReset &gt; 24 hours) {&#13;
            p.battlesLastReset = uint32(now);&#13;
            p.battlesLastDay = 0;&#13;
        }&#13;
        p.battlesLastDay++;&#13;
        int32 exp = _baseExp;&#13;
        if (exp &gt; 0) {&#13;
            exp = _scaleExp(p.battlesLastDay, _baseExp);&#13;
        }&#13;
&#13;
        if (exp &lt; 0 &amp;&amp; uint32(int32(p.experience) + exp) &gt; p.experience) {&#13;
            // check for wrap-around&#13;
            p.experience = 0;&#13;
            return;&#13;
        } else if (exp &gt; 0) {&#13;
            // check for overflow&#13;
            require(uint32(int32(p.experience) + exp) &gt; p.experience);&#13;
        }&#13;
&#13;
        parts[_id].experience = uint32(int32(parts[_id].experience) + exp);&#13;
        return exp;&#13;
    }&#13;
&#13;
    function totalLevel(uint[] partIds) public view returns (uint32) {&#13;
        uint32 total = 0;&#13;
        for (uint i = 0; i &lt; partIds.length; i++) {&#13;
            total += getLevel(parts[partIds[i]].experience);&#13;
        }&#13;
        return total;&#13;
    }&#13;
&#13;
    //requires parts in order&#13;
    function hasOrderedRobotParts(uint[] partIds) external view returns(bool) {&#13;
        uint len = partIds.length;&#13;
        if (len != 4) {&#13;
            return false;&#13;
        }&#13;
        for (uint i = 0; i &lt; len; i++) {&#13;
            if (parts[partIds[i]].partType != i+1) {&#13;
                return false;&#13;
            }&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
}&#13;
&#13;
contract EtherbotsCore is EtherbotsBattle {&#13;
&#13;
    // The structure of Etherbots is modelled on CryptoKitties for obvious reasons:&#13;
    // ease of implementation, tried + tested etc.&#13;
    // it elides some features and includes some others.&#13;
&#13;
    // The full system is implemented in the following manner:&#13;
    //&#13;
    // EtherbotsBase    | Storage and base types&#13;
    // EtherbotsAccess  | Access Control - who can change which state vars etc.&#13;
    // EtherbotsNFT     | ERC721 Implementation&#13;
    // EtherbotsBattle  | Battle interface contract: only one implementation currently, but could add more later.&#13;
    // EtherbotsAuction | Auction interface contract&#13;
&#13;
&#13;
    function EtherbotsCore() public {&#13;
        // Starts paused.&#13;
        paused = true;&#13;
        owner = msg.sender;&#13;
    }&#13;
    &#13;
    &#13;
    function() external payable {&#13;
    }&#13;
&#13;
    function withdrawBalance() external onlyOwner {&#13;
        owner.transfer(this.balance);&#13;
    }&#13;
}