pragma solidity ^0.4.18;



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


/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */

contract Ownable {
    address public owner;
    function Ownable() {
    owner = msg.sender;
    }

  modifier onlyOwner() {
    if (msg.sender == owner)
      _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) owner = newOwner;
  }

}

// @title Interface for contracts conforming to ERC-721 Non-Fungible Tokens
// @author Dieter Shirley <span class="__cf_email__" data-cfemail="096d6c7d6c496871606664736c67276a66">[email protected]</span> (httpsgithub.comdete)&#13;
contract ERC721 {&#13;
    //Required methods&#13;
    function approve(address _to, uint256 _tokenId) public;&#13;
    function balanceOf(address _owner) public view returns (uint256 balance);&#13;
    function implementsERC721() public pure returns (bool);&#13;
    function ownerOf(uint256 _tokenId) public view returns (address addr);&#13;
    function takeOwnership(uint256 _tokenId) public;&#13;
    function totalSupply() public view returns (uint256 total);&#13;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;&#13;
    function transfer(address _to, uint256 _tokenId) public;&#13;
&#13;
    event Transfer(address indexed from, address indexed to, uint256 tokenId);&#13;
    event Approval(address indexed owner, address indexed approved, uint256 tokenId);&#13;
&#13;
    //Optional&#13;
    //function name() public view returns (string name);&#13;
    //function symbol() public view returns (string symbol);&#13;
    //function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenId);&#13;
    //function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);&#13;
}&#13;
&#13;
&#13;
contract Avatarium is Ownable, ERC721 {&#13;
&#13;
&#13;
    // --- Events --- //&#13;
&#13;
&#13;
    // @dev The Birth event is fired, whenever a new Avatar has been created.&#13;
    event Birth(&#13;
        uint256 tokenId, &#13;
        string name, &#13;
        address owner);&#13;
&#13;
    // @dev The TokenSold event is fired, whenever a token is sold.&#13;
    event TokenSold(&#13;
        uint256 tokenId, &#13;
        uint256 oldPrice, &#13;
        uint256 newPrice, &#13;
        address prevOwner, &#13;
        address winner, &#13;
        string name);&#13;
    &#13;
    &#13;
    // --- Constants --- //&#13;
&#13;
&#13;
    // The name and the symbol of the NFT, as defined in ERC-721.&#13;
    string public constant NAME = "Avatarium";&#13;
    string public constant SYMBOL = "ΛV";&#13;
&#13;
    // Prices and iteration steps&#13;
    uint256 private startingPrice = 0.02 ether;&#13;
    uint256 private firstIterationLimit = 0.05 ether;&#13;
    uint256 private secondIterationLimit = 0.5 ether;&#13;
&#13;
    // Addresses that can execute important functions.&#13;
    address public addressCEO;&#13;
    address public addressCOO;&#13;
&#13;
&#13;
    // --- Storage --- //&#13;
&#13;
&#13;
    // @dev A mapping from Avatar ID to the owner's address.&#13;
    mapping (uint =&gt; address) public avatarIndexToOwner;&#13;
&#13;
    // @dev A mapping from the owner's address to the tokens it owns.&#13;
    mapping (address =&gt; uint256) public ownershipTokenCount;&#13;
&#13;
    // @dev A mapping from Avatar's ID to an address that has been approved&#13;
    // to call transferFrom().&#13;
    mapping (uint256 =&gt; address) public avatarIndexToApproved;&#13;
&#13;
    // @dev A private mapping from Avatar's ID to its price.&#13;
    mapping (uint256 =&gt; uint256) private avatarIndexToPrice;&#13;
&#13;
&#13;
    // --- Datatypes --- //&#13;
&#13;
&#13;
    // The main struct&#13;
    struct Avatar {&#13;
        string name;&#13;
    }&#13;
&#13;
    Avatar[] public avatars;&#13;
&#13;
&#13;
    // --- Access Modifiers --- //&#13;
&#13;
&#13;
    // @dev Access only to the CEO-functionality.&#13;
    modifier onlyCEO() {&#13;
        require(msg.sender == addressCEO);&#13;
        _;&#13;
    }&#13;
&#13;
    // @dev Access only to the COO-functionality.&#13;
    modifier onlyCOO() {&#13;
        require(msg.sender == addressCOO);&#13;
        _;&#13;
    }&#13;
&#13;
    // @dev Access to the C-level in general.&#13;
    modifier onlyCLevel() {&#13;
        require(msg.sender == addressCEO || msg.sender == addressCOO);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    // --- Constructor --- //&#13;
&#13;
&#13;
    function Avatarium() public {&#13;
        addressCEO = msg.sender;&#13;
        addressCOO = msg.sender;&#13;
    }&#13;
&#13;
&#13;
    // --- Public functions --- //&#13;
&#13;
&#13;
    //@dev Assigns a new address as the CEO. Only available to the current CEO.&#13;
    function setCEO(address _newCEO) public onlyCEO {&#13;
        require(_newCEO != address(0));&#13;
&#13;
        addressCEO = _newCEO;&#13;
    }&#13;
&#13;
    // @dev Assigns a new address as the COO. Only available to the current COO.&#13;
    function setCOO(address _newCOO) public onlyCEO {&#13;
        require(_newCOO != address(0));&#13;
&#13;
        addressCOO = _newCOO;&#13;
    }&#13;
&#13;
    // @dev Grants another address the right to transfer a token via &#13;
    // takeOwnership() and transferFrom()&#13;
    function approve(address _to, uint256 _tokenId) public {&#13;
        // Check the ownership&#13;
        require(_owns(msg.sender, _tokenId));&#13;
&#13;
        avatarIndexToApproved[_tokenId] = _to;&#13;
&#13;
        // Fire the event&#13;
        Approval(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    // @dev Checks the balanse of the address, ERC-721 compliance&#13;
    function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
        return ownershipTokenCount[_owner];&#13;
    }&#13;
&#13;
    // @dev Creates a new Avatar&#13;
    function createAvatar(string _name, uint256 _rank) public onlyCLevel {&#13;
        _createAvatar(_name, address(this), _rank);&#13;
    }&#13;
&#13;
    // @dev Returns the information on a certain Avatar&#13;
    function getAvatar(uint256 _tokenId) public view returns (&#13;
        string avatarName,&#13;
        uint256 sellingPrice,&#13;
        address owner&#13;
    ) {&#13;
        Avatar storage avatar = avatars[_tokenId];&#13;
        avatarName = avatar.name;&#13;
        sellingPrice = avatarIndexToPrice[_tokenId];&#13;
        owner = avatarIndexToOwner[_tokenId];&#13;
    }&#13;
&#13;
    function implementsERC721() public pure returns (bool) {&#13;
        return true;&#13;
    }&#13;
&#13;
    // @dev Queries the owner of the token.&#13;
    function ownerOf(uint256 _tokenId) public view returns (address owner) {&#13;
        owner = avatarIndexToOwner[_tokenId];&#13;
        require(owner != address(0));&#13;
    }&#13;
&#13;
    function payout(address _to) public onlyCLevel {&#13;
        _payout(_to);&#13;
    }&#13;
&#13;
    // @dev Allows to purchase an Avatar for Ether.&#13;
    function purchase(uint256 _tokenId) public payable {&#13;
        address oldOwner = avatarIndexToOwner[_tokenId];&#13;
        address newOwner = msg.sender;&#13;
&#13;
        uint256 sellingPrice = avatarIndexToPrice[_tokenId];&#13;
&#13;
        require(oldOwner != newOwner);&#13;
        require(_addressNotNull(newOwner));&#13;
        require(msg.value == sellingPrice);&#13;
&#13;
        uint256 payment = uint256(SafeMath.div(&#13;
                                  SafeMath.mul(sellingPrice, 94), 100));&#13;
        uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);&#13;
&#13;
        // Updating prices&#13;
        if (sellingPrice &lt; firstIterationLimit) {&#13;
        // first stage&#13;
            avatarIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 200), 94);&#13;
        } else if (sellingPrice &lt; secondIterationLimit) {&#13;
        // second stage&#13;
            avatarIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 120), 94);&#13;
        } else {&#13;
        // third stage&#13;
            avatarIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 115), 94);&#13;
        }&#13;
&#13;
        _transfer(oldOwner, newOwner, _tokenId);&#13;
&#13;
        // Pay previous token Owner, if it's not the contract&#13;
        if (oldOwner != address(this)) {&#13;
            oldOwner.transfer(payment);&#13;
        }&#13;
&#13;
        // Fire event&#13;
        &#13;
        TokenSold(&#13;
            _tokenId,&#13;
            sellingPrice,&#13;
            avatarIndexToPrice[_tokenId],&#13;
            oldOwner,&#13;
            newOwner,&#13;
            avatars[_tokenId].name);&#13;
&#13;
        // Transferring excessess back to the sender&#13;
        msg.sender.transfer(purchaseExcess);&#13;
    }&#13;
&#13;
    // @dev Queries the price of a token.&#13;
    function priceOf(uint256 _tokenId) public view returns (uint256 price) {&#13;
        return avatarIndexToPrice[_tokenId];&#13;
    }&#13;
    &#13;
    //@dev Allows pre-approved user to take ownership of a token.&#13;
    function takeOwnership(uint256 _tokenId) public {&#13;
        address newOwner = msg.sender;&#13;
        address oldOwner = avatarIndexToOwner[_tokenId];&#13;
&#13;
        // Safety check to prevent against an unexpected 0x0 default.&#13;
        require(_addressNotNull(newOwner));&#13;
&#13;
        //Making sure transfer is approved&#13;
        require(_approved(newOwner, _tokenId));&#13;
&#13;
        _transfer(oldOwner, newOwner, _tokenId);&#13;
    }&#13;
&#13;
    // @dev Required for ERC-721 compliance.&#13;
    function totalSupply() public view returns (uint256 total) {&#13;
        return avatars.length;&#13;
    }&#13;
&#13;
    // @dev Owner initates the transfer of the token to another account.&#13;
    function transfer(&#13;
        address _to,&#13;
        uint256 _tokenId&#13;
    ) public {&#13;
        require(_owns(msg.sender, _tokenId));&#13;
        require(_addressNotNull(_to));&#13;
&#13;
        _transfer(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    // @dev Third-party initiates transfer of token from address _from to&#13;
    // address _to.&#13;
    function transferFrom(&#13;
        address _from,&#13;
        address _to,&#13;
        uint256 _tokenId&#13;
    ) public {&#13;
        require(_owns(_from, _tokenId));&#13;
        require(_approved(_to, _tokenId));&#13;
        require(_addressNotNull(_to));&#13;
&#13;
        _transfer(_from, _to, _tokenId);&#13;
    }&#13;
&#13;
&#13;
    // --- Private Functions --- // &#13;
&#13;
&#13;
    // Safety check on _to address to prevent against an unexpected 0x0 default.&#13;
    function _addressNotNull(address _to) private pure returns (bool) {&#13;
        return _to != address(0);&#13;
    }&#13;
&#13;
    // For checking approval of transfer for address _to&#13;
    function _approved(address _to, uint256 _tokenId)&#13;
    private &#13;
    view &#13;
    returns (bool) {&#13;
        return avatarIndexToApproved[_tokenId] == _to;&#13;
    }&#13;
&#13;
    // For creating Avatars.&#13;
    function _createAvatar(&#13;
        string _name,&#13;
        address _owner, &#13;
        uint256 _rank) &#13;
        private {&#13;
    &#13;
    // Getting the startingPrice&#13;
    uint256 _price;&#13;
    if (_rank == 1) {&#13;
        _price = startingPrice;&#13;
    } else if (_rank == 2) {&#13;
        _price = 2 * startingPrice;&#13;
    } else if (_rank == 3) {&#13;
        _price = SafeMath.mul(4, startingPrice);&#13;
    } else if (_rank == 4) {&#13;
        _price = SafeMath.mul(8, startingPrice);&#13;
    } else if (_rank == 5) {&#13;
        _price = SafeMath.mul(16, startingPrice);&#13;
    } else if (_rank == 6) {&#13;
        _price = SafeMath.mul(32, startingPrice);&#13;
    } else if (_rank == 7) {&#13;
        _price = SafeMath.mul(64, startingPrice);&#13;
    } else if (_rank == 8) {&#13;
        _price = SafeMath.mul(128, startingPrice);&#13;
    } else if (_rank == 9) {&#13;
        _price = SafeMath.mul(256, startingPrice);&#13;
    } &#13;
&#13;
    Avatar memory _avatar = Avatar({name: _name});&#13;
&#13;
    uint256 newAvatarId = avatars.push(_avatar) - 1;&#13;
&#13;
    avatarIndexToPrice[newAvatarId] = _price;&#13;
&#13;
    // Fire event&#13;
    Birth(newAvatarId, _name, _owner);&#13;
&#13;
    // Transfer token to the contract&#13;
    _transfer(address(0), _owner, newAvatarId);&#13;
    }&#13;
&#13;
    // @dev Checks for token ownership.&#13;
    function _owns(address claimant, uint256 _tokenId) &#13;
    private &#13;
    view &#13;
    returns (bool) {&#13;
        return claimant == avatarIndexToOwner[_tokenId];&#13;
    }&#13;
&#13;
    // @dev Pays out balance on contract&#13;
    function _payout(address _to) private {&#13;
        if (_to == address(0)) {&#13;
            addressCEO.transfer(this.balance);&#13;
        } else {&#13;
            _to.transfer(this.balance);&#13;
        }&#13;
    }&#13;
&#13;
    // @dev Assigns ownership of a specific Avatar to an address.&#13;
    function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
        ownershipTokenCount[_to]++;&#13;
        avatarIndexToOwner[_tokenId] = _to;&#13;
&#13;
        if (_from != address(0)) {&#13;
            ownershipTokenCount[_from]--;&#13;
            delete avatarIndexToApproved[_tokenId];&#13;
        }&#13;
&#13;
        // Fire event&#13;
        Transfer(_from, _to, _tokenId);&#13;
    }&#13;
}