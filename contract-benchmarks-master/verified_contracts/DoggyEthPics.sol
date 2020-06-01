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
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="89edecfdecc9e8f1e0e6e4f3ece7a7eae6">[email protected]</a>&gt; (https://github.com/dete)&#13;
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
contract DoggyEthPics is ERC721, Ownable {&#13;
&#13;
  event DoggyCreated(uint256 tokenId, string name, address owner);&#13;
  event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);&#13;
  event Transfer(address from, address to, uint256 tokenId);&#13;
&#13;
  string public constant NAME = "DoggyEthPics";&#13;
  string public constant SYMBOL = "DoggyPicsToken";&#13;
&#13;
  uint256 private startingPrice = 0.01 ether;&#13;
&#13;
  mapping (uint256 =&gt; address) public doggyIdToOwner;&#13;
&#13;
  mapping (uint256 =&gt; address) public doggyIdToDivs;&#13;
&#13;
  mapping (address =&gt; uint256) private ownershipTokenCount;&#13;
&#13;
  mapping (uint256 =&gt; address) public doggyIdToApproved;&#13;
&#13;
  mapping (uint256 =&gt; uint256) private doggyIdToPrice;&#13;
&#13;
  /*** DATATYPES ***/&#13;
  struct Doggy {&#13;
    string name;&#13;
  }&#13;
&#13;
  Doggy[] private doggies;&#13;
&#13;
  function approve(address _to, uint256 _tokenId) public { //ERC721&#13;
    // Caller must own token.&#13;
    require(_owns(msg.sender, _tokenId));&#13;
    doggyIdToApproved[_tokenId] = _to;&#13;
    Approval(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  function balanceOf(address _owner) public view returns (uint256 balance) { //ERC721&#13;
    return ownershipTokenCount[_owner];&#13;
  }&#13;
&#13;
  function createDoggyToken(string _name, uint256 _price) private {&#13;
    _createDoggy(_name, msg.sender, _price);&#13;
  }&#13;
&#13;
  function create3DoggiesTokens() public onlyContractOwner {&#13;
     uint256 totalDoggies = totalSupply();&#13;
	 &#13;
	 require (totalDoggies&lt;1); // only 3 tokens for start&#13;
	 &#13;
	 for (uint8 i=1; i&lt;=3; i++)&#13;
		_createDoggy("EthDoggy", address(this), startingPrice);&#13;
	&#13;
  }&#13;
  &#13;
  function getDoggy(uint256 _tokenId) public view returns (string doggyName, uint256 sellingPrice, address owner) {&#13;
    Doggy storage doggy = doggies[_tokenId];&#13;
    doggyName = doggy.name;&#13;
    sellingPrice = doggyIdToPrice[_tokenId];&#13;
    owner = doggyIdToOwner[_tokenId];&#13;
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
    owner = doggyIdToOwner[_tokenId];&#13;
    require(owner != address(0));&#13;
  }&#13;
&#13;
  // Allows someone to send ether and obtain the token&#13;
  function purchase(uint256 _tokenId) public payable {&#13;
    address oldOwner = doggyIdToOwner[_tokenId];&#13;
    address newOwner = msg.sender;&#13;
&#13;
    uint256 sellingPrice = doggyIdToPrice[_tokenId];&#13;
&#13;
    require(oldOwner != newOwner);&#13;
    require(_addressNotNull(newOwner));&#13;
    require(msg.value &gt;= sellingPrice);&#13;
&#13;
    uint256 payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 9), 10)); //90% to previous owner&#13;
    uint256 divs_payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 1), 20)); //5% divs&#13;
    &#13;
	address divs_address = doggyIdToDivs[_tokenId];&#13;
	&#13;
    // Next price will rise on 50%&#13;
    doggyIdToPrice[_tokenId] = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 3), 2)); &#13;
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
    TokenSold(_tokenId, sellingPrice, doggyIdToPrice[_tokenId], oldOwner, newOwner, doggies[_tokenId].name);&#13;
	&#13;
    if (msg.value &gt; sellingPrice) { //if excess pay&#13;
	    uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);&#13;
		msg.sender.transfer(purchaseExcess);&#13;
	}&#13;
  }&#13;
  &#13;
  function changeDoggy(uint256 _tokenId) public payable { //&#13;
    require(doggyIdToPrice[_tokenId] &gt;= 1 ether);&#13;
	&#13;
    require(doggyIdToOwner[_tokenId] == msg.sender &amp;&amp; msg.value == 20 finney); //tax 0.02eth for change&#13;
	&#13;
	uint256 newPrice1 =  uint256(SafeMath.div(SafeMath.mul(doggyIdToPrice[_tokenId], 3), 10)); //30%&#13;
	uint256 newPrice2 =  uint256(SafeMath.div(SafeMath.mul(doggyIdToPrice[_tokenId], 7), 10)); //70%&#13;
    &#13;
    //get two doggies within one&#13;
	createDoggyToken("EthDoggy", newPrice1);&#13;
	createDoggyToken("EthDoggy", newPrice2);&#13;
	&#13;
	doggyIdToOwner[_tokenId] = address(this); //return changed doggy to doggypics&#13;
	doggyIdToPrice[_tokenId] = 10 finney;&#13;
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
    address oldOwner = doggyIdToOwner[_tokenId];&#13;
&#13;
    require(_addressNotNull(newOwner));&#13;
    require(_approved(newOwner, _tokenId));&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
  }&#13;
&#13;
  function priceOf(uint256 _tokenId) public view returns (uint256 price) { //for web site view&#13;
    return doggyIdToPrice[_tokenId];&#13;
  }&#13;
&#13;
  function ALLownersANDprices(uint256 _startDoggyId) public view returns (address[] owners, address[] divs, uint256[] prices) { //for web site view&#13;
	&#13;
	uint256 totalDoggies = totalSupply();&#13;
	&#13;
    if (totalDoggies == 0 || _startDoggyId &gt;= totalDoggies) {&#13;
        // Return an empty array&#13;
      return (new address[](0),new address[](0),new uint256[](0));&#13;
    }&#13;
	&#13;
	uint256 indexTo;&#13;
	if (totalDoggies &gt; _startDoggyId+1000)&#13;
		indexTo = _startDoggyId + 1000;&#13;
	else 	&#13;
		indexTo = totalDoggies;&#13;
		&#13;
    uint256 totalResultDoggies = indexTo - _startDoggyId;		&#13;
		&#13;
	address[] memory owners_res = new address[](totalResultDoggies);&#13;
	address[] memory divs_res = new address[](totalResultDoggies);&#13;
	uint256[] memory prices_res = new uint256[](totalResultDoggies);&#13;
	&#13;
	for (uint256 doggyId = _startDoggyId; doggyId &lt; indexTo; doggyId++) {&#13;
	  owners_res[doggyId - _startDoggyId] = doggyIdToOwner[doggyId];&#13;
	  divs_res[doggyId - _startDoggyId] = doggyIdToDivs[doggyId];&#13;
	  prices_res[doggyId - _startDoggyId] = doggyIdToPrice[doggyId];&#13;
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
      uint256 totalDoggies = totalSupply();&#13;
      uint256 resultIndex = 0;&#13;
&#13;
      uint256 doggyId;&#13;
      for (doggyId = 0; doggyId &lt;= totalDoggies; doggyId++) {&#13;
        if (doggyIdToOwner[doggyId] == _owner) {&#13;
          result[resultIndex] = doggyId;&#13;
          resultIndex++;&#13;
        }&#13;
      }&#13;
      return result;&#13;
    }&#13;
  }&#13;
&#13;
  function totalSupply() public view returns (uint256 total) { //ERC721&#13;
    return doggies.length;&#13;
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
    return doggyIdToApproved[_tokenId] == _to;&#13;
  }&#13;
&#13;
  function _createDoggy(string _name, address _owner, uint256 _price) private {&#13;
    Doggy memory _doggy = Doggy({&#13;
      name: _name&#13;
    });&#13;
    uint256 newDoggyId = doggies.push(_doggy) - 1;&#13;
&#13;
    require(newDoggyId == uint256(uint32(newDoggyId))); //check maximum limit of tokens&#13;
&#13;
    DoggyCreated(newDoggyId, _name, _owner);&#13;
&#13;
    doggyIdToPrice[newDoggyId] = _price;&#13;
	doggyIdToDivs[newDoggyId] = _owner; //dividents address;&#13;
&#13;
    _transfer(address(0), _owner, newDoggyId);&#13;
  }&#13;
&#13;
  function _owns(address _checkedAddr, uint256 _tokenId) private view returns (bool) {&#13;
    return _checkedAddr == doggyIdToOwner[_tokenId];&#13;
  }&#13;
&#13;
function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
    ownershipTokenCount[_to]++;&#13;
    doggyIdToOwner[_tokenId] = _to;&#13;
&#13;
    // When creating new doggies _from is 0x0, but we can't account that address.&#13;
    if (_from != address(0)) {&#13;
      ownershipTokenCount[_from]--;&#13;
      // clear any previously approved ownership exchange&#13;
      delete doggyIdToApproved[_tokenId];&#13;
    }&#13;
&#13;
    // Emit the transfer event.&#13;
    Transfer(_from, _to, _tokenId);&#13;
  }&#13;
}