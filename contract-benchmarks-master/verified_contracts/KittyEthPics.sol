pragma solidity ^0.4.19;

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

contract Ownable {

  address public contractOwner;

  event ContractOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    contractOwner = msg.sender;
  }

  modifier onlyContractOwner() {
    require(msg.sender == contractOwner);
    _;
  }

  function transferContractOwnership(address _newOwner) public onlyContractOwner {
    require(_newOwner != address(0));
    ContractOwnershipTransferred(contractOwner, _newOwner);
    contractOwner = _newOwner;
  }
  
  function payoutFromContract() public onlyContractOwner {
      contractOwner.transfer(this.balance);
  }  

}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="92f6f7e6f7d2f3eafbfdffe8f7fcbcf1fd">[email protected]</a>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
  // Required methods&#13;
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
  // Optional&#13;
  // function name() public view returns (string name);&#13;
  // function symbol() public view returns (string symbol);&#13;
  // function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenId);&#13;
  // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);&#13;
  // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);&#13;
}&#13;
&#13;
contract KittyEthPics is ERC721, Ownable {&#13;
&#13;
  event KittyCreated(uint256 tokenId, string name, address owner);&#13;
  event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);&#13;
  event Transfer(address from, address to, uint256 tokenId);&#13;
&#13;
  string public constant NAME = "KittyEthPics";&#13;
  string public constant SYMBOL = "KittyPicsToken";&#13;
&#13;
  uint256 private startingPrice = 0.01 ether;&#13;
&#13;
  mapping (uint256 =&gt; address) public kittyIdToOwner;&#13;
&#13;
  mapping (uint256 =&gt; address) public kittyIdToDivs;&#13;
&#13;
  mapping (address =&gt; uint256) private ownershipTokenCount;&#13;
&#13;
  mapping (uint256 =&gt; address) public kittyIdToApproved;&#13;
&#13;
  mapping (uint256 =&gt; uint256) private kittyIdToPrice;&#13;
&#13;
  /*** DATATYPES ***/&#13;
  struct Kitty {&#13;
    string name;&#13;
  }&#13;
&#13;
  Kitty[] private kitties;&#13;
&#13;
  function approve(address _to, uint256 _tokenId) public { //ERC721&#13;
    // Caller must own token.&#13;
    require(_owns(msg.sender, _tokenId));&#13;
    kittyIdToApproved[_tokenId] = _to;&#13;
    Approval(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  function balanceOf(address _owner) public view returns (uint256 balance) { //ERC721&#13;
    return ownershipTokenCount[_owner];&#13;
  }&#13;
&#13;
  function createKittyToken(string _name, uint256 _price) private {&#13;
    _createKitty(_name, msg.sender, _price);&#13;
  }&#13;
&#13;
  function create21KittiesTokens() public onlyContractOwner {&#13;
     uint256 totalKitties = totalSupply();&#13;
	 &#13;
	 require (totalKitties&lt;1); // only 21 tokens for start&#13;
	 &#13;
	 for (uint8 i=1; i&lt;=21; i++)&#13;
		_createKitty("EthKitty", address(this), startingPrice);&#13;
	&#13;
  }&#13;
  &#13;
  function getKitty(uint256 _tokenId) public view returns (string kittyName, uint256 sellingPrice, address owner) {&#13;
    Kitty storage kitty = kitties[_tokenId];&#13;
    kittyName = kitty.name;&#13;
    sellingPrice = kittyIdToPrice[_tokenId];&#13;
    owner = kittyIdToOwner[_tokenId];&#13;
  }&#13;
&#13;
  function implementsERC721() public pure returns (bool) {&#13;
    return true;&#13;
  }&#13;
&#13;
  function name() public pure returns (string) { //ERC721&#13;
    return NAME;&#13;
  }&#13;
&#13;
  function ownerOf(uint256 _tokenId) public view returns (address owner) { //ERC721&#13;
    owner = kittyIdToOwner[_tokenId];&#13;
    require(owner != address(0));&#13;
  }&#13;
&#13;
  // Allows someone to send ether and obtain the token&#13;
  function purchase(uint256 _tokenId) public payable {&#13;
    address oldOwner = kittyIdToOwner[_tokenId];&#13;
    address newOwner = msg.sender;&#13;
&#13;
    uint256 sellingPrice = kittyIdToPrice[_tokenId];&#13;
&#13;
    require(oldOwner != newOwner);&#13;
    require(_addressNotNull(newOwner));&#13;
    require(msg.value &gt;= sellingPrice);&#13;
&#13;
    uint256 payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 8), 10)); //80% to previous owner&#13;
    uint256 divs_payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 1), 10)); //10% divs&#13;
    &#13;
	address divs_address = kittyIdToDivs[_tokenId];&#13;
	&#13;
    // Next price will rise on 300%&#13;
    kittyIdToPrice[_tokenId] = uint256(SafeMath.mul(sellingPrice, 3));&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
&#13;
    // Pay previous tokenOwner if owner is not contract&#13;
    if (oldOwner != address(this)) {&#13;
      oldOwner.transfer(payment); //&#13;
    }&#13;
&#13;
    // Pay winner tokenOwner if owner is not contract&#13;
    if (divs_address != address(this)) {&#13;
      divs_address.transfer(divs_payment); //&#13;
    }&#13;
&#13;
    TokenSold(_tokenId, sellingPrice, kittyIdToPrice[_tokenId], oldOwner, newOwner, kitties[_tokenId].name);&#13;
	&#13;
    if (msg.value &gt; sellingPrice) { //if excess pay&#13;
	    uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);&#13;
		msg.sender.transfer(purchaseExcess);&#13;
	}&#13;
  }&#13;
  &#13;
  function changeKitty(uint256 _tokenId) public payable { //&#13;
&#13;
    require(kittyIdToOwner[_tokenId] == msg.sender &amp;&amp; msg.value == 20 finney); //tax 0.02eth for change&#13;
	&#13;
	uint256 newPrice =  SafeMath.div(kittyIdToPrice[_tokenId], 2);&#13;
    &#13;
    //get two kitties within one&#13;
	createKittyToken("EthKitty", newPrice);&#13;
	createKittyToken("EthKitty", newPrice);&#13;
	&#13;
	kittyIdToOwner[_tokenId] = address(this); //return changed kitty to kittypics&#13;
	kittyIdToPrice[_tokenId] = 10 finney;&#13;
	 &#13;
  }&#13;
&#13;
&#13;
  function symbol() public pure returns (string) { //ERC721&#13;
    return SYMBOL;&#13;
  }&#13;
&#13;
&#13;
  function takeOwnership(uint256 _tokenId) public { //ERC721&#13;
    address newOwner = msg.sender;&#13;
    address oldOwner = kittyIdToOwner[_tokenId];&#13;
&#13;
    require(_addressNotNull(newOwner));&#13;
    require(_approved(newOwner, _tokenId));&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
  }&#13;
&#13;
  function priceOf(uint256 _tokenId) public view returns (uint256 price) { //for web site view&#13;
    return kittyIdToPrice[_tokenId];&#13;
  }&#13;
&#13;
  function ALLownersANDprices(uint256 _startKittyId) public view returns (address[] owners, address[] divs, uint256[] prices) { //for web site view&#13;
	&#13;
	uint256 totalKitties = totalSupply();&#13;
	&#13;
    if (totalKitties == 0 || _startKittyId &gt;= totalKitties) {&#13;
        // Return an empty array&#13;
      return (new address[](0),new address[](0),new uint256[](0));&#13;
    }&#13;
	&#13;
	uint256 indexTo;&#13;
	if (totalKitties &gt; _startKittyId+1000)&#13;
		indexTo = _startKittyId + 1000;&#13;
	else 	&#13;
		indexTo = totalKitties;&#13;
		&#13;
    uint256 totalResultKitties = indexTo - _startKittyId;		&#13;
		&#13;
	address[] memory owners_res = new address[](totalResultKitties);&#13;
	address[] memory divs_res = new address[](totalResultKitties);&#13;
	uint256[] memory prices_res = new uint256[](totalResultKitties);&#13;
	&#13;
	for (uint256 kittyId = _startKittyId; kittyId &lt; indexTo; kittyId++) {&#13;
	  owners_res[kittyId - _startKittyId] = kittyIdToOwner[kittyId];&#13;
	  divs_res[kittyId - _startKittyId] = kittyIdToDivs[kittyId];&#13;
	  prices_res[kittyId - _startKittyId] = kittyIdToPrice[kittyId];&#13;
	}&#13;
	&#13;
	return (owners_res, divs_res, prices_res);&#13;
  }&#13;
  &#13;
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerToken) { //ERC721 for web site view&#13;
    uint256 tokenCount = balanceOf(_owner);&#13;
    if (tokenCount == 0) {&#13;
        // Return an empty array&#13;
      return new uint256[](0);&#13;
    } else {&#13;
      uint256[] memory result = new uint256[](tokenCount);&#13;
      uint256 totalKitties = totalSupply();&#13;
      uint256 resultIndex = 0;&#13;
&#13;
      uint256 kittyId;&#13;
      for (kittyId = 0; kittyId &lt;= totalKitties; kittyId++) {&#13;
        if (kittyIdToOwner[kittyId] == _owner) {&#13;
          result[resultIndex] = kittyId;&#13;
          resultIndex++;&#13;
        }&#13;
      }&#13;
      return result;&#13;
    }&#13;
  }&#13;
&#13;
  function totalSupply() public view returns (uint256 total) { //ERC721&#13;
    return kitties.length;&#13;
  }&#13;
&#13;
  function transfer(address _to, uint256 _tokenId) public { //ERC721&#13;
    require(_owns(msg.sender, _tokenId));&#13;
    require(_addressNotNull(_to));&#13;
&#13;
	_transfer(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _tokenId) public { //ERC721&#13;
    require(_owns(_from, _tokenId));&#13;
    require(_approved(_to, _tokenId));&#13;
    require(_addressNotNull(_to));&#13;
&#13;
    _transfer(_from, _to, _tokenId);&#13;
  }&#13;
&#13;
&#13;
  /* PRIVATE FUNCTIONS */&#13;
  function _addressNotNull(address _to) private pure returns (bool) {&#13;
    return _to != address(0);&#13;
  }&#13;
&#13;
  function _approved(address _to, uint256 _tokenId) private view returns (bool) {&#13;
    return kittyIdToApproved[_tokenId] == _to;&#13;
  }&#13;
&#13;
  function _createKitty(string _name, address _owner, uint256 _price) private {&#13;
    Kitty memory _kitty = Kitty({&#13;
      name: _name&#13;
    });&#13;
    uint256 newKittyId = kitties.push(_kitty) - 1;&#13;
&#13;
    require(newKittyId == uint256(uint32(newKittyId))); //check maximum limit of tokens&#13;
&#13;
    KittyCreated(newKittyId, _name, _owner);&#13;
&#13;
    kittyIdToPrice[newKittyId] = _price;&#13;
	kittyIdToDivs[newKittyId] = _owner; //dividents address;&#13;
&#13;
    _transfer(address(0), _owner, newKittyId);&#13;
  }&#13;
&#13;
  function _owns(address _checkedAddr, uint256 _tokenId) private view returns (bool) {&#13;
    return _checkedAddr == kittyIdToOwner[_tokenId];&#13;
  }&#13;
&#13;
function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
    ownershipTokenCount[_to]++;&#13;
    kittyIdToOwner[_tokenId] = _to;&#13;
&#13;
    // When creating new kitties _from is 0x0, but we can't account that address.&#13;
    if (_from != address(0)) {&#13;
      ownershipTokenCount[_from]--;&#13;
      // clear any previously approved ownership exchange&#13;
      delete kittyIdToApproved[_tokenId];&#13;
    }&#13;
&#13;
    // Emit the transfer event.&#13;
    Transfer(_from, _to, _tokenId);&#13;
  }&#13;
}