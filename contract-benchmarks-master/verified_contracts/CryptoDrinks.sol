pragma solidity ^0.4.21;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

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
/// @author Dieter Shirley <<span class="__cf_email__" data-cfemail="e286879687a2839a8b8d8f98878ccc818d">[email protected]</span>&gt; (https://github.com/dete)&#13;
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
  // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);&#13;
}&#13;
&#13;
contract CryptoDrinks is ERC721, Ownable {&#13;
&#13;
  event DrinkCreated(uint256 tokenId, string name, address owner);&#13;
  event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);&#13;
  event Transfer(address from, address to, uint256 tokenId);&#13;
&#13;
  string public constant NAME = "CryptoDrinks";&#13;
  string public constant SYMBOL = "DrinksToken";&#13;
&#13;
  uint256 private startingPrice = 0.02 ether;&#13;
  &#13;
  uint256 private startTime = now;&#13;
&#13;
  mapping (uint256 =&gt; address) public drinkIdToOwner;&#13;
&#13;
  mapping (address =&gt; uint256) private ownershipTokenCount;&#13;
&#13;
  mapping (uint256 =&gt; address) public drinkIdToApproved;&#13;
&#13;
  mapping (uint256 =&gt; uint256) private drinkIdToPrice;&#13;
&#13;
  /*** DATATYPES ***/&#13;
  struct Drink {&#13;
    string name;&#13;
  }&#13;
&#13;
  Drink[] private drinks;&#13;
&#13;
  function approve(address _to, uint256 _tokenId) public { //ERC721&#13;
    // Caller must own token.&#13;
    require(_owns(msg.sender, _tokenId));&#13;
    drinkIdToApproved[_tokenId] = _to;&#13;
    Approval(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  function balanceOf(address _owner) public view returns (uint256 balance) { //ERC721&#13;
    return ownershipTokenCount[_owner];&#13;
  }&#13;
&#13;
  function createOneDrink(string _name) public onlyContractOwner {&#13;
    _createDrink(_name, address(this), startingPrice);&#13;
  }&#13;
&#13;
  function createManyDrinks() public onlyContractOwner {&#13;
     uint256 totalDrinks = totalSupply();&#13;
	 &#13;
     require (totalDrinks &lt; 1);&#13;
	 &#13;
 	 _createDrink("Barmen", address(this), 1 ether);&#13;
 	 _createDrink("Vodka", address(this), startingPrice);&#13;
	 _createDrink("Wine", address(this), startingPrice);&#13;
	 _createDrink("Cognac", address(this), startingPrice);&#13;
	 _createDrink("Martini", address(this), startingPrice);&#13;
	 _createDrink("Beer", address(this), startingPrice);&#13;
	 _createDrink("Tequila", address(this), startingPrice);&#13;
	 _createDrink("Whiskey", address(this), startingPrice);&#13;
	 _createDrink("Baileys", address(this), startingPrice);&#13;
	 _createDrink("Champagne", address(this), startingPrice);&#13;
  }&#13;
  &#13;
  function getDrink(uint256 _tokenId) public view returns (string drinkName, uint256 sellingPrice, address owner) {&#13;
    Drink storage drink = drinks[_tokenId];&#13;
    drinkName = drink.name;&#13;
    sellingPrice = drinkIdToPrice[_tokenId];&#13;
    owner = drinkIdToOwner[_tokenId];&#13;
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
    owner = drinkIdToOwner[_tokenId];&#13;
    require(owner != address(0));&#13;
  }&#13;
&#13;
  // Allows someone to send ether and obtain the token&#13;
  function purchase(uint256 _tokenId) public payable {&#13;
  &#13;
	require (now - startTime &gt;= 10800 || _tokenId==0); //3 hours&#13;
	&#13;
    address oldOwner = drinkIdToOwner[_tokenId];&#13;
    address newOwner = msg.sender;&#13;
&#13;
    uint256 sellingPrice = drinkIdToPrice[_tokenId];&#13;
&#13;
    require(oldOwner != newOwner);&#13;
    require(_addressNotNull(newOwner));&#13;
    require(msg.value &gt;= sellingPrice);&#13;
&#13;
    uint256 payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 9), 10)); //90% to previous owner&#13;
    uint256 barmen_payment = uint256(SafeMath.div(sellingPrice, 10)); //10% to barmen&#13;
&#13;
	address barmen = ownerOf(0);&#13;
	&#13;
    // Next price will in 2 times more if it less then 1 ether.&#13;
	if (sellingPrice &gt;= 1 ether)&#13;
		drinkIdToPrice[_tokenId] = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 3), 2));&#13;
	else 	&#13;
		drinkIdToPrice[_tokenId] = uint256(SafeMath.mul(sellingPrice, 2));&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
&#13;
    // Pay previous tokenOwner if owner is not contract&#13;
    if (oldOwner != address(this)) {&#13;
      oldOwner.transfer(payment); //&#13;
    }&#13;
&#13;
    // Pay 10% to barmen, if drink sold&#13;
	// token 0 not drink, its barmen&#13;
    if (_tokenId &gt; 0) {&#13;
      barmen.transfer(barmen_payment); //&#13;
    }&#13;
&#13;
    TokenSold(_tokenId, sellingPrice, drinkIdToPrice[_tokenId], oldOwner, newOwner, drinks[_tokenId].name);&#13;
	&#13;
    if (msg.value &gt; sellingPrice) { //if excess pay&#13;
	    uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);&#13;
		msg.sender.transfer(purchaseExcess);&#13;
	}&#13;
  }&#13;
&#13;
  function secondsAfterStart() public view returns (uint256) { //ERC721&#13;
    return uint256(now - startTime);&#13;
  }&#13;
  &#13;
  function symbol() public pure returns (string) { //ERC721&#13;
    return SYMBOL;&#13;
  }&#13;
&#13;
&#13;
  function takeOwnership(uint256 _tokenId) public { //ERC721&#13;
    address newOwner = msg.sender;&#13;
    address oldOwner = drinkIdToOwner[_tokenId];&#13;
&#13;
    require(_addressNotNull(newOwner));&#13;
    require(_approved(newOwner, _tokenId));&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
  }&#13;
&#13;
  function priceOf(uint256 _tokenId) public view returns (uint256 price) { //for web site view&#13;
    return drinkIdToPrice[_tokenId];&#13;
  }&#13;
  &#13;
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) { //for web site view&#13;
    uint256 tokenCount = balanceOf(_owner);&#13;
    if (tokenCount == 0) {&#13;
        // Return an empty array&#13;
      return new uint256[](0);&#13;
    } else {&#13;
      uint256[] memory result = new uint256[](tokenCount);&#13;
      uint256 totalDrinks = totalSupply();&#13;
      uint256 resultIndex = 0;&#13;
&#13;
      uint256 drinkId;&#13;
      for (drinkId = 0; drinkId &lt;= totalDrinks; drinkId++) {&#13;
        if (drinkIdToOwner[drinkId] == _owner) {&#13;
          result[resultIndex] = drinkId;&#13;
          resultIndex++;&#13;
        }&#13;
      }&#13;
      return result;&#13;
    }&#13;
  }&#13;
&#13;
  function totalSupply() public view returns (uint256 total) { //ERC721&#13;
    return drinks.length;&#13;
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
    return drinkIdToApproved[_tokenId] == _to;&#13;
  }&#13;
&#13;
  function _createDrink(string _name, address _owner, uint256 _price) private {&#13;
    Drink memory _drink = Drink({&#13;
      name: _name&#13;
    });&#13;
    uint256 newDrinkId = drinks.push(_drink) - 1;&#13;
&#13;
    require(newDrinkId == uint256(uint32(newDrinkId))); //check maximum limit of tokens&#13;
&#13;
    DrinkCreated(newDrinkId, _name, _owner);&#13;
&#13;
    drinkIdToPrice[newDrinkId] = _price;&#13;
&#13;
    _transfer(address(0), _owner, newDrinkId);&#13;
  }&#13;
&#13;
  function _owns(address _checkedAddr, uint256 _tokenId) private view returns (bool) {&#13;
    return _checkedAddr == drinkIdToOwner[_tokenId];&#13;
  }&#13;
&#13;
function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
    ownershipTokenCount[_to]++;&#13;
    drinkIdToOwner[_tokenId] = _to;&#13;
&#13;
    // When creating new drinks _from is 0x0, but we can't account that address.&#13;
    if (_from != address(0)) {&#13;
      ownershipTokenCount[_from]--;&#13;
      // clear any previously approved ownership exchange&#13;
      delete drinkIdToApproved[_tokenId];&#13;
    }&#13;
&#13;
    // Emit the transfer event.&#13;
    Transfer(_from, _to, _tokenId);&#13;
  }&#13;
}