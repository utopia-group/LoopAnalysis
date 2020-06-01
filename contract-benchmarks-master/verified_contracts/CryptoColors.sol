pragma solidity ^0.4.18;

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3b5f5e4f5e7b5a43525456415e55155854">[email protected]</a>&gt; (https://github.com/dete)&#13;
&#13;
contract ERC721 {&#13;
  // Required methods&#13;
  function totalSupply() public view returns (uint256 total);&#13;
  function balanceOf(address _owner) public view returns (uint256 balance);&#13;
  function ownerOf(uint256 _tokenId) public view returns (address addr);&#13;
  function approve(address _to, uint256 _tokenId) public;&#13;
  function takeOwnership(uint256 _tokenId) public;&#13;
  function transfer(address _to, uint256 _tokenId) public;&#13;
  function transferFrom(address _from, address _to, uint256 _tokenId) public;&#13;
&#13;
  //Events&#13;
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);&#13;
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);&#13;
}&#13;
&#13;
contract CryptoColors is ERC721 {&#13;
&#13;
  /*** EVENTS ***/&#13;
&#13;
  /// @dev The Released event is fired whenever a new color is released.&#13;
  event Released(uint256 tokenId, string name, address owner);&#13;
&#13;
  /// @dev The ColorSold event is fired whenever a color is sold.&#13;
  event ColorSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);&#13;
&#13;
  /// @dev Transfer event as defined in current draft of ERC721.&#13;
  /// ownership is assigned, including initial color listings.&#13;
  event Transfer(address from, address to, uint256 tokenId);&#13;
&#13;
  /*** CONSTANTS ***/&#13;
  /// @notice Name and symbol of the non fungible token, as defined in ERC721.&#13;
  string public constant NAME = "CryptoColors";&#13;
  string public constant SYMBOL = "COLOR";&#13;
&#13;
  uint256 private constant PROMO_CREATION_LIMIT = 1000000;&#13;
  uint256 private startingPrice = 0.001 ether;&#13;
  uint256 private firstStepLimit =  0.05 ether;&#13;
  uint256 private secondStepLimit = 0.5 ether;&#13;
&#13;
&#13;
  /*** STORAGE ***/&#13;
  /// @dev A mapping from color IDs to the address that owns them. All colors have&#13;
  ///  some valid owner address.&#13;
  mapping (uint256 =&gt; address) public colorIndexToOwner;&#13;
&#13;
  // @dev A mapping from owner address to count of tokens that address owns.&#13;
  //  Used internally inside balanceOf() to resolve ownership count.&#13;
  mapping (address =&gt; uint256) private ownershipTokenCount;&#13;
&#13;
  /// @dev A mapping from colorIDs to an address that has been approved to call&#13;
  ///  transferFrom(). Each color can only have one approved address for transfer&#13;
  ///  at any time. A zero value means no approval is outstanding.&#13;
  mapping (uint256 =&gt; address) public colorIndexToApproved;&#13;
&#13;
  // @dev A mapping from colorIDs to the price of the token.&#13;
  mapping (uint256 =&gt; uint256) private colorIndexToPrice;&#13;
&#13;
  // The address of the CEO&#13;
  address public ceoAddress;&#13;
&#13;
  // Keeps track of the total promo colors released&#13;
  uint256 public promoCreatedCount;&#13;
&#13;
  /*** DATATYPES ***/&#13;
  struct Color{&#13;
    uint8 R;&#13;
    uint8 G;&#13;
    uint8 B;&#13;
    string name;&#13;
  }&#13;
&#13;
  // Storage array of all colors. Indexed by colorId.&#13;
  Color[] private colors;&#13;
&#13;
&#13;
  /*** ACCESS MODIFIERS ***/&#13;
  /// @dev Access modifier for CEO-only functionality&#13;
  modifier onlyCEO() {&#13;
    require(msg.sender == ceoAddress);&#13;
    _;&#13;
  }&#13;
&#13;
  /*** CONSTRUCTOR ***/&#13;
  function CryptoColors() public {&#13;
    ceoAddress = msg.sender;&#13;
  }&#13;
&#13;
  /*** PUBLIC FUNCTIONS ***/&#13;
&#13;
  /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.&#13;
  /// @param _newCEO The address of the new CEO&#13;
  function setCEO(address _newCEO) public onlyCEO {&#13;
    require(_newCEO != address(0));&#13;
&#13;
    ceoAddress = _newCEO;&#13;
  }&#13;
&#13;
  /// @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().&#13;
  /// @param _to The address to be granted transfer approval. Pass address(0) to clear all approvals.&#13;
  /// @param _tokenId The ID of the color that can be transferred if this call succeeds.&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function approve(address _to, uint256 _tokenId) public {&#13;
    // Caller must own token.&#13;
    require(_owns(msg.sender, _tokenId));&#13;
&#13;
    colorIndexToApproved[_tokenId] = _to;&#13;
    Approval(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  /// For querying balance of a particular account&#13;
  /// @param _owner The address for balance query&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
    return ownershipTokenCount[_owner];&#13;
  }&#13;
&#13;
  /// @dev Creates a new color with the given name, with given _price and assignes it to an address.&#13;
  function createPromoColor(uint256 _R, uint256 _G, uint256 _B, string _name, address _owner, uint256 _price) public onlyCEO {&#13;
    require(promoCreatedCount &lt; PROMO_CREATION_LIMIT);&#13;
&#13;
    address colorOwner = _owner;&#13;
    if (colorOwner == address(0)) {&#13;
      colorOwner = ceoAddress;&#13;
    }&#13;
&#13;
    if (_price &lt;= 0) {&#13;
      _price = startingPrice;&#13;
    }&#13;
&#13;
    promoCreatedCount++;&#13;
    _createColor(_R, _G, _B, _name, colorOwner, _price);&#13;
  }&#13;
&#13;
  /// @dev Creates a new color with the given name and assigns it to the contract.&#13;
  function createContractColor(uint256 _R, uint256 _G, uint256 _B, string _name) public onlyCEO {&#13;
    _createColor(_R, _G, _B, _name, address(this), startingPrice);&#13;
  }&#13;
&#13;
  /// @notice Returns all the relevant information about a specific color.&#13;
  /// @param _tokenId The Id of the color of interest.&#13;
  function getColor(uint256 _tokenId) public view returns (uint256 R, uint256 G, uint256 B, string colorName, uint256 sellingPrice, address owner) {&#13;
    Color storage col = colors[_tokenId];&#13;
&#13;
    R = col.R;&#13;
    G = col.G;&#13;
    B = col.B;&#13;
    colorName = col.name;&#13;
    sellingPrice = colorIndexToPrice[_tokenId];&#13;
    owner = colorIndexToOwner[_tokenId];&#13;
  }&#13;
&#13;
  /// For querying owner of token&#13;
  /// @param _tokenId The colorId for owner inquiry&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function ownerOf(uint256 _tokenId) public view returns (address owner) {&#13;
    owner = colorIndexToOwner[_tokenId];&#13;
    require(owner != address(0));&#13;
  }&#13;
&#13;
  function payout(address _to) public onlyCEO {&#13;
    _payout(_to);&#13;
  }&#13;
&#13;
  // Allows someone to send ether and obtain the token&#13;
  function purchase(uint256 _tokenId) public payable {&#13;
    address oldOwner = colorIndexToOwner[_tokenId];&#13;
    address newOwner = msg.sender;&#13;
&#13;
    uint256 sellingPrice = colorIndexToPrice[_tokenId];&#13;
&#13;
    // Making sure token owner is not sending to self&#13;
    require(oldOwner != newOwner);&#13;
&#13;
    // Safety check to prevent against an unexpected 0x0 default.&#13;
    require(_addressNotNull(newOwner));&#13;
&#13;
    // Making sure sent amount is greater than or equal to the sellingPrice&#13;
    require(msg.value &gt;= sellingPrice);&#13;
&#13;
    uint256 payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 93), 100));&#13;
    uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);&#13;
&#13;
    // Update prices&#13;
    if (sellingPrice &lt; firstStepLimit) {&#13;
      // first stage&#13;
      colorIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 200), 93);&#13;
    } else if (sellingPrice &lt; secondStepLimit) {&#13;
      // second stage&#13;
      colorIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 150), 93);&#13;
    } else {&#13;
      // third stage&#13;
      colorIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 115), 93);&#13;
    }&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
&#13;
    // Pay previous tokenOwner if owner is not contract&#13;
    if (oldOwner != address(this)) {&#13;
      oldOwner.transfer(payment);&#13;
    }&#13;
&#13;
    ColorSold(_tokenId, sellingPrice, colorIndexToPrice[_tokenId], oldOwner, newOwner, colors[_tokenId].name);&#13;
&#13;
    msg.sender.transfer(purchaseExcess);&#13;
  }&#13;
&#13;
  function priceOf(uint256 _tokenId) public view returns (uint256 price) {&#13;
    return colorIndexToPrice[_tokenId];&#13;
  }&#13;
&#13;
&#13;
  /// @notice Allow pre-approved user to take ownership of a color&#13;
  /// @param _tokenId The ID of the color that can be transferred if this call succeeds.&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function takeOwnership(uint256 _tokenId) public {&#13;
    address newOwner = msg.sender;&#13;
    address oldOwner = colorIndexToOwner[_tokenId];&#13;
&#13;
    // Safety check to prevent against an unexpected 0x0 default.&#13;
    require(_addressNotNull(newOwner));&#13;
&#13;
    // Making sure transfer is approved&#13;
    require(_approved(newOwner, _tokenId));&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
  }&#13;
&#13;
  /// @param _owner The owner whose color tokens we are interested in.&#13;
  /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly&#13;
  ///  expensive (it walks the entire colors array looking for colors belonging to owner),&#13;
  ///  but it also returns a dynamic array, which is only supported for web3 calls, and&#13;
  ///  not contract-to-contract calls.&#13;
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {&#13;
    uint256 tokenCount = balanceOf(_owner);&#13;
    if (tokenCount == 0) {&#13;
        // Return an empty array&#13;
      return new uint256[](0);&#13;
    } else {&#13;
      uint256[] memory result = new uint256[](tokenCount);&#13;
      uint256 totalcolors = totalSupply();&#13;
      uint256 resultIndex = 0;&#13;
&#13;
      uint256 colorId;&#13;
      for (colorId = 0; colorId &lt;= totalcolors; colorId++) {&#13;
        if (colorIndexToOwner[colorId] == _owner) {&#13;
          result[resultIndex] = colorId;&#13;
          resultIndex++;&#13;
        }&#13;
      }&#13;
      return result;&#13;
    }&#13;
  }&#13;
&#13;
  /// For querying totalSupply of token&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function totalSupply() public view returns (uint256 total) {&#13;
    return colors.length;&#13;
  }&#13;
&#13;
  /// Owner initates the transfer of the token to another account&#13;
  /// @param _to The address for the token to be transferred to.&#13;
  /// @param _tokenId The ID of the color that can be transferred if this call succeeds.&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function transfer(address _to, uint256 _tokenId) public {&#13;
    require(_owns(msg.sender, _tokenId));&#13;
    require(_addressNotNull(_to));&#13;
&#13;
    _transfer(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  /// Third-party initiates transfer of token from address _from to address _to&#13;
  /// @param _from The address for the token to be transferred from.&#13;
  /// @param _to The address for the token to be transferred to.&#13;
  /// @param _tokenId The ID of the color that can be transferred if this call succeeds.&#13;
  /// @dev Required for ERC-721 compliance.&#13;
  function transferFrom(address _from, address _to, uint256 _tokenId) public {&#13;
    require(_owns(_from, _tokenId));&#13;
    require(_approved(_to, _tokenId));&#13;
    require(_addressNotNull(_to));&#13;
&#13;
    _transfer(_from, _to, _tokenId);&#13;
  }&#13;
&#13;
  /*** PRIVATE FUNCTIONS ***/&#13;
  /// Safety check on _to address to prevent against an unexpected 0x0 default.&#13;
  function _addressNotNull(address _to) private pure returns (bool) {&#13;
    return _to != address(0);&#13;
  }&#13;
&#13;
  /// For checking approval of transfer for address _to&#13;
  function _approved(address _to, uint256 _tokenId) private view returns (bool) {&#13;
    return colorIndexToApproved[_tokenId] == _to;&#13;
  }&#13;
&#13;
  /// For creating color&#13;
  function _createColor(uint256 _R, uint256 _G, uint256 _B, string _name, address _owner, uint256 _price) private {&#13;
    require(_R == uint256(uint8(_R)));&#13;
    require(_G == uint256(uint8(_G)));&#13;
    require(_B == uint256(uint8(_B)));&#13;
&#13;
    Color memory _color = Color({&#13;
        R: uint8(_R),&#13;
        G: uint8(_G),&#13;
        B: uint8(_B),&#13;
        name: _name&#13;
    });&#13;
&#13;
    uint256 newColorId = colors.push(_color) - 1;&#13;
&#13;
    require(newColorId == uint256(uint32(newColorId)));&#13;
&#13;
    Released(newColorId, _name, _owner);&#13;
&#13;
    colorIndexToPrice[newColorId] = _price;&#13;
&#13;
    // This will assign ownership, and also emit the Transfer event as&#13;
    // per ERC721 draft&#13;
    _transfer(address(0), _owner, newColorId);&#13;
  }&#13;
&#13;
  /// Check for color ownership&#13;
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {&#13;
    return claimant == colorIndexToOwner[_tokenId];&#13;
  }&#13;
&#13;
  /// For paying out balance on contract&#13;
  function _payout(address _to) private {&#13;
    if (_to == address(0)) {&#13;
      ceoAddress.transfer(this.balance);&#13;
    } else {&#13;
      _to.transfer(this.balance);&#13;
    }&#13;
  }&#13;
&#13;
  /// @dev Assigns ownership of a specific Color to an address.&#13;
  function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
    // Since the number of colors is capped to 2^32 we can't overflow this&#13;
    ownershipTokenCount[_to]++;&#13;
    //transfer ownership&#13;
    colorIndexToOwner[_tokenId] = _to;&#13;
&#13;
    // When creating new colors _from is 0x0, but we can't account that address.&#13;
    if (_from != address(0)) {&#13;
      ownershipTokenCount[_from]--;&#13;
      // clear any previously approved ownership exchange&#13;
      delete colorIndexToApproved[_tokenId];&#13;
    }&#13;
&#13;
    // Emit the transfer event.&#13;
    Transfer(_from, _to, _tokenId);&#13;
  }&#13;
}&#13;
&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, throws on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
    uint256 c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
}