pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
   @title ERC827 interface, an extension of ERC20 token standard

   Interface of a ERC827 token, following the ERC20 standard with extra
   methods to transfer value and data and execute calls in transfers and
   approvals.
 */
contract ERC827 is ERC20 {

  function approve( address _spender, uint256 _value, bytes _data ) public returns (bool);
  function transfer( address _to, uint256 _value, bytes _data ) public returns (bool);
  function transferFrom( address _from, address _to, uint256 _value, bytes _data ) public returns (bool);

}

contract AccessControl {
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
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
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
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        paused = false;
    }
}

/// @title 
contract TournamentInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isTournament() public pure returns (bool);
    function isPlayerIdle(address _owner, uint256 _playerId) public view returns (bool);
}

/// @title Base contract for BS. Holds all common structs, events and base variables.
contract BSBase is AccessControl {
    /*** EVENTS ***/

    /// @dev The Birth event is fired whenever a new player comes into existence. 
    event Birth(address owner, uint32 playerId, uint16 typeId, uint8 attack, uint8 defense, uint8 stamina, uint8 xp, uint8 isKeeper, uint16 skillId);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a player
    ///  ownership is assigned, including births.
    event Transfer(address from, address to, uint256 tokenId);

    struct Player {
        uint16 typeId;
        uint8 attack;
        uint8 defense;
        uint8 stamina;
        uint8 xp;
        uint8 isKeeper;
        uint16 skillId;
        uint8 isSkillOn;
    }

    Player[] players;
    uint256 constant commonPlayerCount = 10;
    uint256 constant totalPlayerSupplyLimit = 80000000;
    mapping (uint256 => address) public playerIndexToOwner;
    mapping (address => uint256) ownershipTokenCount;
    mapping (uint256 => address) public playerIndexToApproved;
    /// SaleClockAuction public saleAuction;
    ERC827 public joyTokenContract;
    TournamentInterface public tournamentContract;

    /// @dev Assigns ownership of a specific Player to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // since the number of players is capped to 2^32
        // there is no way to overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        playerIndexToOwner[_tokenId] = _to;
        // When creating new player _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete playerIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    function _createPlayer(
        address _owner,
        uint256 _typeId,
        uint256 _attack,
        uint256 _defense,
        uint256 _stamina,
        uint256 _xp,
        uint256 _isKeeper,
        uint256 _skillId
    )
        internal
        returns (uint256)
    {
        Player memory _player = Player({
            typeId: uint16(_typeId), 
            attack: uint8(_attack), 
            defense: uint8(_defense), 
            stamina: uint8(_stamina),
            xp: uint8(_xp),
            isKeeper: uint8(_isKeeper),
            skillId: uint16(_skillId),
            isSkillOn: 0
        });
        uint256 newPlayerId = players.push(_player) - 1;

        require(newPlayerId <= totalPlayerSupplyLimit);

        // emit the birth event
        Birth(
            _owner,
            uint32(newPlayerId),
            _player.typeId,
            _player.attack,
            _player.defense,
            _player.stamina,
            _player.xp,
            _player.isKeeper,
            _player.skillId
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newPlayerId);

        return newPlayerId;
    }
}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d4b0b1a0b194b5acbdbbb9aeb1bafab7bb">[email protected]</a>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
    // Required methods&#13;
    function totalSupply() public view returns (uint256 total);&#13;
    function balanceOf(address _owner) public view returns (uint256 balance);&#13;
    function ownerOf(uint256 _tokenId) public view returns (address owner);&#13;
    function approve(address _to, uint256 _tokenId) public;&#13;
    function transfer(address _to, uint256 _tokenId) public;&#13;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;&#13;
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
    function supportsInterface(bytes4 _interfaceID) public view returns (bool);&#13;
}&#13;
&#13;
/// @title The facet of the BS core contract that manages ownership, ERC-721 (draft) compliant.&#13;
contract BSOwnership is BSBase, ERC721 {&#13;
&#13;
    /// @notice Name and symbol of the non fungible token, as defined in ERC721.&#13;
    string public constant name = "BitSoccer Player";&#13;
    string public constant symbol = "BSP";&#13;
&#13;
    bytes4 constant InterfaceSignature_ERC165 =&#13;
        bytes4(keccak256("supportsInterface(bytes4)"));&#13;
&#13;
    bytes4 constant InterfaceSignature_ERC721 =&#13;
        bytes4(keccak256("name()")) ^&#13;
        bytes4(keccak256("symbol()")) ^&#13;
        bytes4(keccak256("totalSupply()")) ^&#13;
        bytes4(keccak256("balanceOf(address)")) ^&#13;
        bytes4(keccak256("ownerOf(uint256)")) ^&#13;
        bytes4(keccak256("approve(address,uint256)")) ^&#13;
        bytes4(keccak256("transfer(address,uint256)")) ^&#13;
        bytes4(keccak256("transferFrom(address,address,uint256)")) ^&#13;
        bytes4(keccak256("tokensOfOwner(address)"));&#13;
&#13;
    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).&#13;
    ///  Returns true for any standardized interfaces implemented by this contract. We implement&#13;
    ///  ERC-165 (obviously!) and ERC-721.&#13;
    function supportsInterface(bytes4 _interfaceID) public view returns (bool)&#13;
    {&#13;
        // DEBUG ONLY&#13;
        //require((InterfaceSignature_ERC165 == 0x01ffc9a7) &amp;&amp; (InterfaceSignature_ERC721 == 0x9f40b779));&#13;
&#13;
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));&#13;
    }&#13;
&#13;
    // Internal utility functions: These functions all assume that their input arguments&#13;
    // are valid. We leave it to public methods to sanitize their inputs and follow&#13;
    // the required logic.&#13;
&#13;
    /// @dev Checks if a given address is the current owner of a particular Player.&#13;
    /// @param _claimant the address we are validating against.&#13;
    /// @param _tokenId player id, only valid when &gt; 0&#13;
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {&#13;
        return playerIndexToOwner[_tokenId] == _claimant;&#13;
    }&#13;
&#13;
    function _isIdle(address _owner, uint256 _tokenId) internal view returns (bool) {&#13;
        return (tournamentContract == address(0) || tournamentContract.isPlayerIdle(_owner, _tokenId));&#13;
    }&#13;
&#13;
    /// @dev Checks if a given address currently has transferApproval for a particular Player.&#13;
    /// @param _claimant the address we are confirming player is approved for.&#13;
    /// @param _tokenId player id, only valid when &gt; 0&#13;
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {&#13;
        return playerIndexToApproved[_tokenId] == _claimant;&#13;
    }&#13;
&#13;
    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous&#13;
    ///  approval. Setting _approved to address(0) clears all transfer approval.&#13;
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because&#13;
    ///  _approve() and transferFrom() are used together for putting players on auction, and&#13;
    ///  there is no value in spamming the log with Approval events in that case.&#13;
    function _approve(uint256 _tokenId, address _approved) internal {&#13;
        playerIndexToApproved[_tokenId] = _approved;&#13;
    }&#13;
&#13;
    /// @notice Returns the number of players owned by a specific address.&#13;
    /// @param _owner The owner address to check.&#13;
    /// @dev Required for ERC-721 compliance&#13;
    function balanceOf(address _owner) public view returns (uint256 count) {&#13;
        return ownershipTokenCount[_owner];&#13;
    }&#13;
&#13;
    /// @notice Transfers a Player to another address. If transferring to a smart&#13;
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or&#13;
    ///  BSPlayers specifically) or your Player may be lost forever. Seriously.&#13;
    /// @param _to The address of the recipient, can be a user or contract.&#13;
    /// @param _tokenId The ID of the player to transfer.&#13;
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
        // Disallow transfers to this contract to prevent accidental misuse.&#13;
        require(_to != address(this));&#13;
&#13;
        // Disallow transfers to the auction contracts to prevent accidental&#13;
        // misuse. Auction contracts should only take ownership of players&#13;
        // through the allow + transferFrom flow.&#13;
        // require(_to != address(saleAuction));&#13;
&#13;
        // You can only send your own player.&#13;
        require(_owns(msg.sender, _tokenId));&#13;
        require(_isIdle(msg.sender, _tokenId));&#13;
&#13;
        // Reassign ownership, clear pending approvals, emit Transfer event.&#13;
        _transfer(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    /// @notice Grant another address the right to transfer a specific Player via&#13;
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.&#13;
    /// @param _to The address to be granted transfer approval. Pass address(0) to&#13;
    ///  clear all approvals.&#13;
    /// @param _tokenId The ID of the Player that can be transferred if this call succeeds.&#13;
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
        require(_isIdle(msg.sender, _tokenId));&#13;
&#13;
        // Register the approval (replacing any previous approval).&#13;
        _approve(_tokenId, _to);&#13;
&#13;
        // Emit approval event.&#13;
        Approval(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    /// @notice Transfer a Player owned by another address, for which the calling address&#13;
    ///  has previously been granted transfer approval by the owner.&#13;
    /// @param _from The address that owns the Player to be transfered.&#13;
    /// @param _to The address that should take ownership of the Player. Can be any address,&#13;
    ///  including the caller.&#13;
    /// @param _tokenId The ID of the player to be transferred.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function transferFrom(&#13;
        address _from,&#13;
        address _to,&#13;
        uint256 _tokenId&#13;
    )&#13;
        public&#13;
        whenNotPaused&#13;
    {&#13;
        // Safety check to prevent against an unexpected 0x0 default.&#13;
        require(_to != address(0));&#13;
        // Disallow transfers to this contract to prevent accidental misuse.&#13;
        require(_to != address(this));&#13;
        // Check for approval and valid ownership&#13;
        require(_approvedFor(msg.sender, _tokenId));&#13;
        require(_owns(_from, _tokenId));&#13;
        require(_isIdle(_from, _tokenId));&#13;
&#13;
        // Reassign ownership (also clears pending approvals and emits Transfer event).&#13;
        _transfer(_from, _to, _tokenId);&#13;
    }&#13;
&#13;
    /// @notice Returns the total number of Players currently in existence.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function totalSupply() public view returns (uint) {&#13;
        return players.length;&#13;
    }&#13;
&#13;
    /// @notice Returns the address currently assigned ownership of a given Player.&#13;
    /// @dev Required for ERC-721 compliance.&#13;
    function ownerOf(uint256 _tokenId)&#13;
        public&#13;
        view&#13;
        returns (address owner)&#13;
    {&#13;
        owner = playerIndexToOwner[_tokenId];&#13;
&#13;
        require(owner != address(0));&#13;
    }&#13;
&#13;
    /// @notice Returns a list of all Player IDs assigned to an address.&#13;
    /// @param _owner The owner whose Players we are interested in.&#13;
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly&#13;
    ///  expensive (it walks the entire Player array looking for players belonging to owner),&#13;
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and&#13;
    ///  not contract-to-contract calls.&#13;
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {&#13;
        uint256 tokenCount = balanceOf(_owner);&#13;
&#13;
        uint256[] memory result = new uint256[](tokenCount+commonPlayerCount);&#13;
        uint256 resultIndex = 0;&#13;
&#13;
        uint256 playerId;&#13;
        for (playerId = 1; playerId &lt;= commonPlayerCount; playerId++) {&#13;
            result[resultIndex] = playerId;&#13;
            resultIndex++;&#13;
        }&#13;
&#13;
        if (tokenCount == 0) {&#13;
            return result;&#13;
        } else {&#13;
            uint256 totalPlayers = totalSupply();&#13;
&#13;
            for (; playerId &lt; totalPlayers; playerId++) {&#13;
                if (playerIndexToOwner[playerId] == _owner) {&#13;
                    result[resultIndex] = playerId;&#13;
                    resultIndex++;&#13;
                }&#13;
            }&#13;
&#13;
            return result;&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
/// @title &#13;
interface RandomPlayerInterface {&#13;
    /// @dev simply a boolean to indicate this is the contract we expect to be&#13;
    function isRandomPlayer() public pure returns (bool);&#13;
&#13;
    /// @return a random player&#13;
    function gen() public returns (uint256 typeId, uint256 attack, uint256 defense, uint256 stamina, uint256 xp, uint256 isKeeper, uint256 skillId);&#13;
}&#13;
&#13;
contract BSMinting is BSOwnership {&#13;
        /// @dev The address of the sibling contract that is used to generate player&#13;
    ///  genetic combination algorithm.&#13;
    using SafeMath for uint256;&#13;
    RandomPlayerInterface public randomPlayer;&#13;
&#13;
    uint256 constant public exchangePlayerTokenCount = 100 * (10**18);&#13;
&#13;
    uint256 constant promoCreationPlayerLimit = 50000;&#13;
&#13;
    uint256 public promoCreationPlayerCount;&#13;
&#13;
    uint256 public promoEndTime;&#13;
    mapping (address =&gt; uint256) public userToken2PlayerCount;&#13;
&#13;
    event ExchangePlayer(address indexed user, uint256 count);&#13;
&#13;
    function BSMinting() public {&#13;
        promoEndTime = now + 2 weeks;&#13;
    }&#13;
&#13;
    function setPromoEndTime(uint256 _endTime) external onlyCOO {&#13;
        promoEndTime = _endTime;&#13;
    }&#13;
&#13;
    /// @dev Update the address of the generator contract, can only be called by the CEO.&#13;
    /// @param _address An address of a contract instance to be used from this point forward.&#13;
    function setRandomPlayerAddress(address _address) external onlyCEO {&#13;
        RandomPlayerInterface candidateContract = RandomPlayerInterface(_address);&#13;
&#13;
        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117&#13;
        require(candidateContract.isRandomPlayer());&#13;
&#13;
        // Set the new contract address&#13;
        randomPlayer = candidateContract;&#13;
    }&#13;
&#13;
    function createPromoPlayer(address _owner, uint256 _typeId, uint256 _attack, uint256 _defense,&#13;
            uint256 _stamina, uint256 _xp, uint256 _isKeeper, uint256 _skillId) external onlyCOO {&#13;
        address sender = _owner;&#13;
        if (sender == address(0)) {&#13;
             sender = cooAddress;&#13;
        }&#13;
&#13;
        require(promoCreationPlayerCount &lt; promoCreationPlayerLimit);&#13;
        promoCreationPlayerCount++;&#13;
        _createPlayer(sender, _typeId, _attack, _defense, _stamina, _xp, _isKeeper, _skillId);&#13;
    }&#13;
&#13;
    function token2Player(address _sender, uint256 _count) public whenNotPaused returns (bool) {&#13;
        require(msg.sender == address(joyTokenContract) || msg.sender == _sender);&#13;
        require(_count &gt; 0);&#13;
        uint256 totalTokenCount = _count.mul(exchangePlayerTokenCount);&#13;
        require(joyTokenContract.transferFrom(_sender, cfoAddress, totalTokenCount));&#13;
&#13;
        uint256 typeId;&#13;
        uint256 attack;&#13;
        uint256 defense;&#13;
        uint256 stamina;&#13;
        uint256 xp;&#13;
        uint256 isKeeper;&#13;
        uint256 skillId;&#13;
        for (uint256 i = 0; i &lt; _count; i++) {&#13;
            (typeId, attack, defense, stamina, xp, isKeeper, skillId) = randomPlayer.gen();&#13;
            _createPlayer(_sender, typeId, attack, defense, stamina, xp, isKeeper, skillId);&#13;
        }&#13;
&#13;
        if (now &lt; promoEndTime) {&#13;
            _onPromo(_sender, _count);&#13;
        }&#13;
        ExchangePlayer(_sender, _count);&#13;
        return true;&#13;
    }&#13;
&#13;
    function _onPromo(address _sender, uint256 _count) internal {&#13;
        uint256 userCount = userToken2PlayerCount[_sender];&#13;
        uint256 userCountNow = userCount.add(_count);&#13;
        userToken2PlayerCount[_sender] = userCountNow;&#13;
        if (userCount == 0) {&#13;
            _createPlayer(_sender, 14, 88, 35, 58, 1, 0, 56);&#13;
        }&#13;
        if (userCount &lt; 5 &amp;&amp; userCountNow &gt;= 5) {&#13;
            _createPlayer(_sender, 13, 42, 80, 81, 1, 0, 70);&#13;
        }&#13;
    }&#13;
&#13;
    function createCommonPlayer() external onlyCOO returns (uint256)&#13;
    {&#13;
        require(players.length == 0);&#13;
        players.length++;&#13;
&#13;
        uint16 commonTypeId = 1;&#13;
        address commonAdress = address(0);&#13;
&#13;
        _createPlayer(commonAdress, commonTypeId++, 40, 12, 25, 1, 0, 0);&#13;
        _createPlayer(commonAdress, commonTypeId++, 16, 32, 39, 3, 0, 0);&#13;
        _createPlayer(commonAdress, commonTypeId++, 30, 35, 13, 3, 0, 0);&#13;
        _createPlayer(commonAdress, commonTypeId++, 22, 30, 24, 5, 0, 0);&#13;
        _createPlayer(commonAdress, commonTypeId++, 25, 14, 43, 3, 0, 0);&#13;
        _createPlayer(commonAdress, commonTypeId++, 15, 40, 22, 5, 0, 0);&#13;
        _createPlayer(commonAdress, commonTypeId++, 17, 39, 25, 3, 0, 0);&#13;
        _createPlayer(commonAdress, commonTypeId++, 41, 22, 13, 3, 0, 0);&#13;
        _createPlayer(commonAdress, commonTypeId++, 30, 31, 28, 1, 0, 0);&#13;
        _createPlayer(commonAdress, commonTypeId++, 13, 45, 11, 3, 1, 0);&#13;
&#13;
        require(commonPlayerCount+1 == players.length);&#13;
        return commonPlayerCount;&#13;
    }&#13;
}&#13;
&#13;
/// @title &#13;
contract SaleClockAuctionInterface {&#13;
    /// @dev simply a boolean to indicate this is the contract we expect to be&#13;
    function isSaleClockAuction() public pure returns (bool);&#13;
    function createAuction(uint256 _tokenId, uint256 _startingPrice, uint256 _endingPrice, uint256 _duration, address _seller) external;&#13;
}&#13;
&#13;
/// @title Handles creating auctions for sale and siring of players.&#13;
///  This wrapper of ReverseAuction exists only so that users can create&#13;
///  auctions with only one transaction.&#13;
contract BSAuction is BSMinting {&#13;
&#13;
    /// @dev The address of the ClockAuction contract that handles sales of players. &#13;
    SaleClockAuctionInterface public saleAuction;&#13;
&#13;
    /// @dev Sets the reference to the sale auction.&#13;
    /// @param _address - Address of sale contract.&#13;
    function setSaleAuctionAddress(address _address) public onlyCEO {&#13;
        SaleClockAuctionInterface candidateContract = SaleClockAuctionInterface(_address);&#13;
&#13;
        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117&#13;
        require(candidateContract.isSaleClockAuction());&#13;
&#13;
        // Set the new contract address&#13;
        saleAuction = candidateContract;&#13;
    }&#13;
&#13;
    /// @dev Put a player up for auction.&#13;
    ///  Does some ownership trickery to create auctions in one tx.&#13;
    function createSaleAuction(&#13;
        uint256 _playerId,&#13;
        uint256 _startingPrice,&#13;
        uint256 _endingPrice,&#13;
        uint256 _duration&#13;
    )&#13;
        public&#13;
        whenNotPaused&#13;
    {&#13;
        // Auction contract checks input sizes&#13;
        // If player is already on any auction, this will throw&#13;
        // because it will be owned by the auction contract.&#13;
        require(_owns(msg.sender, _playerId));&#13;
        _approve(_playerId, saleAuction);&#13;
        // Sale auction throws if inputs are invalid and clears&#13;
        // transfer and sire approval after escrowing the player.&#13;
        saleAuction.createAuction(&#13;
            _playerId,&#13;
            _startingPrice,&#13;
            _endingPrice,&#13;
            _duration,&#13;
            msg.sender&#13;
        );&#13;
    }&#13;
}&#13;
&#13;
contract GlobalDefines {&#13;
    uint8 constant TYPE_SKILL_ATTRI_ATTACK = 0;&#13;
    uint8 constant TYPE_SKILL_ATTRI_DEFENSE = 1;&#13;
    uint8 constant TYPE_SKILL_ATTRI_STAMINA = 2;&#13;
    uint8 constant TYPE_SKILL_ATTRI_GOALKEEPER = 3;&#13;
}&#13;
&#13;
/// @title Interface for PlayerInterface&#13;
contract PlayerInterface {&#13;
    function checkOwner(address _owner, uint32[11] _ids) public view returns (bool);&#13;
    function queryPlayerType(uint32[11] _ids) public view returns (uint32[11] playerTypes);&#13;
    function queryPlayer(uint32 _id) public view returns (uint16[8]);&#13;
    function queryPlayerUnAwakeSkillIds(uint32[11] _playerIds) public view returns (uint16[11] playerUnAwakeSkillIds);&#13;
    function tournamentResult(uint32[3][11][32] _playerAwakeSkills) public;&#13;
}&#13;
&#13;
contract BSCore is GlobalDefines, BSAuction, PlayerInterface {&#13;
&#13;
    // This is the main BS contract.&#13;
&#13;
    /// @notice Creates the main BS smart contract instance.&#13;
    function BSCore() public {&#13;
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
    /// @dev Sets the reference to the JOY token contract.&#13;
    /// @param _address - Address of JOY token contract.&#13;
    function setJOYTokenAddress(address _address) external onlyCOO {&#13;
        // Set the new contract address&#13;
        joyTokenContract = ERC827(_address);&#13;
    }&#13;
&#13;
    /// @dev Sets the reference to the Tournament token contract.&#13;
    /// @param _address - Address of Tournament token contract.&#13;
    function setTournamentAddress(address _address) external onlyCOO {&#13;
        TournamentInterface candidateContract = TournamentInterface(_address);&#13;
&#13;
        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117&#13;
        require(candidateContract.isTournament());&#13;
&#13;
        // Set the new contract address&#13;
        tournamentContract = candidateContract;&#13;
    }&#13;
&#13;
    function() external {&#13;
        revert();&#13;
    }&#13;
&#13;
    function withdrawJOYTokens() external onlyCFO {&#13;
        uint256 value = joyTokenContract.balanceOf(address(this));&#13;
        joyTokenContract.transfer(cfoAddress, value);&#13;
    }&#13;
&#13;
    /// @notice Returns all the relevant information about a specific player.&#13;
    /// @param _id The ID of the player of interest.&#13;
    function getPlayer(uint256 _id)&#13;
        external&#13;
        view&#13;
        returns (&#13;
        uint256 typeId,&#13;
        uint256 attack,&#13;
        uint256 defense,&#13;
        uint256 stamina,&#13;
        uint256 xp,&#13;
        uint256 isKeeper,&#13;
        uint256 skillId,&#13;
        uint256 isSkillOn&#13;
    ) {&#13;
        Player storage player = players[_id];&#13;
&#13;
        typeId = uint256(player.typeId);&#13;
        attack = uint256(player.attack);&#13;
        defense = uint256(player.defense);&#13;
        stamina = uint256(player.stamina);&#13;
        xp = uint256(player.xp);&#13;
        isKeeper = uint256(player.isKeeper);&#13;
        skillId = uint256(player.skillId);&#13;
        isSkillOn = uint256(player.isSkillOn);&#13;
    }&#13;
&#13;
    function checkOwner(address _owner, uint32[11] _ids) public view returns (bool) {&#13;
        for (uint256 i = 0; i &lt; _ids.length; i++) {&#13;
            uint256 _id = _ids[i];&#13;
            if ((_id &lt;= 0 || _id &gt; commonPlayerCount) &amp;&amp; !_owns(_owner, _id)) {&#13;
                return false;&#13;
            }&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
    function queryPlayerType(uint32[11] _ids) public view returns (uint32[11] playerTypes) {&#13;
        for (uint256 i = 0; i &lt; _ids.length; i++) {&#13;
            uint256 _id = _ids[i];&#13;
            Player storage player = players[_id];&#13;
            playerTypes[i] = player.typeId;&#13;
        }&#13;
    }&#13;
&#13;
    function queryPlayer(uint32 _id)&#13;
        public&#13;
        view&#13;
        returns (&#13;
        uint16[8]&#13;
    ) {&#13;
        Player storage player = players[_id];&#13;
        return [player.typeId, player.attack, player.defense, player.stamina, player.xp, player.isKeeper, player.skillId, player.isSkillOn];&#13;
    }&#13;
&#13;
    function queryPlayerUnAwakeSkillIds(uint32[11] _playerIds)&#13;
        public&#13;
        view&#13;
        returns (&#13;
        uint16[11] playerUnAwakeSkillIds&#13;
    ) {&#13;
        for (uint256 i = 0; i &lt; _playerIds.length; i++) {&#13;
            Player storage player = players[_playerIds[i]];&#13;
            if (player.skillId &gt; 0 &amp;&amp; player.isSkillOn == 0)&#13;
            {&#13;
                playerUnAwakeSkillIds[i] = player.skillId;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function tournamentResult(uint32[3][11][32] _playerAwakeSkills) public {&#13;
        require(msg.sender == address(tournamentContract));&#13;
&#13;
        for (uint8 i = 0; i &lt; 32; i++) {&#13;
            for (uint8 j = 0; j &lt; 11; j++) {&#13;
                uint32 _id = _playerAwakeSkills[i][j][0];&#13;
                Player storage player = players[_id];&#13;
                if (player.skillId &gt; 0 &amp;&amp; player.isSkillOn == 0) {&#13;
                    uint32 skillType = _playerAwakeSkills[i][j][1];&#13;
                    uint8 skillAddAttri = uint8(_playerAwakeSkills[i][j][2]);&#13;
&#13;
                    if (skillType == TYPE_SKILL_ATTRI_ATTACK) {&#13;
                        player.attack += skillAddAttri;&#13;
                        player.isSkillOn = 1;&#13;
                    }&#13;
&#13;
                    if (skillType == TYPE_SKILL_ATTRI_DEFENSE) {&#13;
                        player.defense += skillAddAttri;&#13;
                        player.isSkillOn = 1;&#13;
                    }&#13;
&#13;
                    if (skillType == TYPE_SKILL_ATTRI_STAMINA) {&#13;
                        player.stamina += skillAddAttri;&#13;
                        player.isSkillOn = 1;&#13;
                    }&#13;
&#13;
                    if (skillType == TYPE_SKILL_ATTRI_GOALKEEPER &amp;&amp; player.isKeeper == 0) {&#13;
                        player.isKeeper = 1;&#13;
                        player.isSkillOn = 1;&#13;
                    }&#13;
                }&#13;
            }&#13;
        }&#13;
    }&#13;
}