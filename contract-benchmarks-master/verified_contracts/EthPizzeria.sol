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
/// @author Dieter Shirley <<span class="__cf_email__" data-cfemail="abcfcedfceebcad3c2c4c6d1cec585c8c4">[email protected]</span>&gt; (https://github.com/dete)&#13;
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
contract EthPizzeria is ERC721, Ownable {&#13;
&#13;
  event PizzaCreated(uint256 tokenId, string name, address owner);&#13;
  event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);&#13;
  event Transfer(address from, address to, uint256 tokenId);&#13;
&#13;
  string public constant NAME = "EthPizzeria";&#13;
  string public constant SYMBOL = "PizzeriaToken";&#13;
&#13;
  uint256 private startingPrice = 0.01 ether;&#13;
&#13;
  mapping (uint256 =&gt; address) public pizzaIdToOwner;&#13;
&#13;
  mapping (uint256 =&gt; address) public pizzaIdToDivs;&#13;
&#13;
  mapping (address =&gt; uint256) private ownershipTokenCount;&#13;
&#13;
  mapping (uint256 =&gt; address) public pizzaIdToApproved;&#13;
&#13;
  mapping (uint256 =&gt; uint256) private pizzaIdToPrice;&#13;
&#13;
  /*** DATATYPES ***/&#13;
  struct Pizza {&#13;
    string name;&#13;
  }&#13;
&#13;
  Pizza[] private pizzas;&#13;
&#13;
  function approve(address _to, uint256 _tokenId) public { //ERC721&#13;
    // Caller must own token.&#13;
    require(_owns(msg.sender, _tokenId));&#13;
    pizzaIdToApproved[_tokenId] = _to;&#13;
    Approval(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  function balanceOf(address _owner) public view returns (uint256 balance) { //ERC721&#13;
    return ownershipTokenCount[_owner];&#13;
  }&#13;
&#13;
  function createPizzaToken(string _name, uint256 _price) private {&#13;
    _createPizza(_name, msg.sender, _price);&#13;
  }&#13;
&#13;
  function create21PizzasTokens() public onlyContractOwner {&#13;
     uint256 totalPizzas = totalSupply();&#13;
	 &#13;
	 require (totalPizzas&lt;1); // only 21 tokens for start&#13;
	 &#13;
	 for (uint8 i=1; i&lt;=21; i++)&#13;
		_createPizza("EthPizza", address(this), startingPrice);&#13;
	&#13;
  }&#13;
  &#13;
  function getPizza(uint256 _tokenId) public view returns (string pizzaName, uint256 sellingPrice, address owner) {&#13;
    Pizza storage pizza = pizzas[_tokenId];&#13;
    pizzaName = pizza.name;&#13;
    sellingPrice = pizzaIdToPrice[_tokenId];&#13;
    owner = pizzaIdToOwner[_tokenId];&#13;
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
    owner = pizzaIdToOwner[_tokenId];&#13;
    require(owner != address(0));&#13;
  }&#13;
&#13;
  // Allows someone to send ether and obtain the token&#13;
  function purchase(uint256 _tokenId) public payable {&#13;
    address oldOwner = pizzaIdToOwner[_tokenId];&#13;
    address newOwner = msg.sender;&#13;
&#13;
    uint256 sellingPrice = pizzaIdToPrice[_tokenId];&#13;
&#13;
    require(oldOwner != newOwner);&#13;
    require(_addressNotNull(newOwner));&#13;
    require(msg.value &gt;= sellingPrice);&#13;
&#13;
    uint256 payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 97), 100)); //97% to previous owner&#13;
    uint256 divs_payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 25), 1000)); //2,5% divs&#13;
    &#13;
	address divs_address = pizzaIdToDivs[_tokenId];&#13;
	&#13;
    // Next price will rise on 30%&#13;
    pizzaIdToPrice[_tokenId] = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 130), 100));&#13;
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
    TokenSold(_tokenId, sellingPrice, pizzaIdToPrice[_tokenId], oldOwner, newOwner, pizzas[_tokenId].name);&#13;
	&#13;
    if (msg.value &gt; sellingPrice) { //if excess pay&#13;
	    uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);&#13;
		msg.sender.transfer(purchaseExcess);&#13;
	}&#13;
  }&#13;
  &#13;
  function changePizza(uint256 _tokenId) public payable { //&#13;
&#13;
    require(pizzaIdToOwner[_tokenId] == msg.sender &amp;&amp; msg.value == 10 finney); //tax 0.01eth for change&#13;
	&#13;
	uint256 newPrice =  SafeMath.div(pizzaIdToPrice[_tokenId], 2);&#13;
    &#13;
    //get two pizzas within one&#13;
	createPizzaToken("EthPizza", newPrice);&#13;
	createPizzaToken("EthPizza", newPrice);&#13;
	&#13;
	pizzaIdToOwner[_tokenId] = address(this); //return changed pizza to pizzeria&#13;
	pizzaIdToPrice[_tokenId] = 10 finney;&#13;
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
    address oldOwner = pizzaIdToOwner[_tokenId];&#13;
&#13;
    require(_addressNotNull(newOwner));&#13;
    require(_approved(newOwner, _tokenId));&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
  }&#13;
&#13;
  function priceOf(uint256 _tokenId) public view returns (uint256 price) { //for web site view&#13;
    return pizzaIdToPrice[_tokenId];&#13;
  }&#13;
&#13;
  function ALLownersANDprices(uint256 _startPizzaId) public view returns (address[] owners, address[] divs, uint256[] prices) { //for web site view&#13;
	&#13;
	uint256 totalPizzas = totalSupply();&#13;
	&#13;
    if (totalPizzas == 0 || _startPizzaId &gt;= totalPizzas) {&#13;
        // Return an empty array&#13;
      return (new address[](0),new address[](0),new uint256[](0));&#13;
    }&#13;
	&#13;
	uint256 indexTo;&#13;
	if (totalPizzas &gt; _startPizzaId+1000)&#13;
		indexTo = _startPizzaId + 1000;&#13;
	else 	&#13;
		indexTo = totalPizzas;&#13;
		&#13;
    uint256 totalResultPizzas = indexTo - _startPizzaId;		&#13;
		&#13;
	address[] memory owners_res = new address[](totalResultPizzas);&#13;
	address[] memory divs_res = new address[](totalResultPizzas);&#13;
	uint256[] memory prices_res = new uint256[](totalResultPizzas);&#13;
	&#13;
	for (uint256 pizzaId = _startPizzaId; pizzaId &lt; indexTo; pizzaId++) {&#13;
	  owners_res[pizzaId - _startPizzaId] = pizzaIdToOwner[pizzaId];&#13;
	  divs_res[pizzaId - _startPizzaId] = pizzaIdToDivs[pizzaId];&#13;
	  prices_res[pizzaId - _startPizzaId] = pizzaIdToPrice[pizzaId];&#13;
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
      uint256[] memory divs = new uint256[](tokenCount);&#13;
      uint256 totalPizzas = totalSupply();&#13;
      uint256 resultIndex = 0;&#13;
&#13;
      uint256 pizzaId;&#13;
      for (pizzaId = 0; pizzaId &lt;= totalPizzas; pizzaId++) {&#13;
        if (pizzaIdToOwner[pizzaId] == _owner) {&#13;
          result[resultIndex] = pizzaId;&#13;
          resultIndex++;&#13;
        }&#13;
      }&#13;
      return result;&#13;
    }&#13;
  }&#13;
&#13;
  function totalSupply() public view returns (uint256 total) { //ERC721&#13;
    return pizzas.length;&#13;
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
    return pizzaIdToApproved[_tokenId] == _to;&#13;
  }&#13;
&#13;
  function _createPizza(string _name, address _owner, uint256 _price) private {&#13;
    Pizza memory _pizza = Pizza({&#13;
      name: _name&#13;
    });&#13;
    uint256 newPizzaId = pizzas.push(_pizza) - 1;&#13;
&#13;
    require(newPizzaId == uint256(uint32(newPizzaId))); //check maximum limit of tokens&#13;
&#13;
    PizzaCreated(newPizzaId, _name, _owner);&#13;
&#13;
    pizzaIdToPrice[newPizzaId] = _price;&#13;
	pizzaIdToDivs[newPizzaId] = _owner; //dividents address;&#13;
&#13;
    _transfer(address(0), _owner, newPizzaId);&#13;
  }&#13;
&#13;
  function _owns(address _checkedAddr, uint256 _tokenId) private view returns (bool) {&#13;
    return _checkedAddr == pizzaIdToOwner[_tokenId];&#13;
  }&#13;
&#13;
function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
    ownershipTokenCount[_to]++;&#13;
    pizzaIdToOwner[_tokenId] = _to;&#13;
&#13;
    // When creating new pizzas _from is 0x0, but we can't account that address.&#13;
    if (_from != address(0)) {&#13;
      ownershipTokenCount[_from]--;&#13;
      // clear any previously approved ownership exchange&#13;
      delete pizzaIdToApproved[_tokenId];&#13;
    }&#13;
&#13;
    // Emit the transfer event.&#13;
    Transfer(_from, _to, _tokenId);&#13;
  }&#13;
}