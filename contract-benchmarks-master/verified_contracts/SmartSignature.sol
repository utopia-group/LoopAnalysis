/// Smart Signature Beta v0.1

pragma solidity ^0.4.20;

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

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<span class="__cf_email__" data-cfemail="462223322306273e2f292b3c2328682529">[email protected]</span>&gt; (https://github.com/dete)&#13;
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
    function name() public view returns (string name);&#13;
    function symbol() public view returns (string symbol);&#13;
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);&#13;
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);&#13;
&#13;
    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)&#13;
    // function supportsInterface(bytes4 _interfaceID) external view returns (bool);&#13;
}&#13;
&#13;
contract SmartSignature is ERC721{&#13;
  using SafeMath for uint256;&#13;
&#13;
  event Bought (uint256 indexed _tokenId, address indexed _owner, uint256 _price);&#13;
  event Sold (uint256 indexed _tokenId, address indexed _owner, uint256 _price);&#13;
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);&#13;
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);&#13;
&#13;
  address private owner;&#13;
  &#13;
  uint256 counter;&#13;
  mapping (uint256 =&gt; address) private ownerOftoken;&#13;
  mapping (uint256 =&gt; uint256) private priceOftoken;&#13;
  mapping (uint256 =&gt; address) private approvedOftoken;&#13;
  mapping (uint256 =&gt; address) private creatorOftoken;&#13;
  mapping (uint256 =&gt; uint256) private parentOftoken;&#13;
  mapping (uint256 =&gt; uint256) private balanceOfToken;  &#13;
  mapping (uint256 =&gt; uint256) private freeOftoken;  &#13;
&#13;
  function SmartSignature () public {&#13;
    owner = msg.sender;&#13;
    creatorOftoken[counter] = ownerOftoken[counter] = msg.sender;&#13;
    priceOftoken[counter] = 1 ether;&#13;
    parentOftoken[counter] = 0;&#13;
    freeOftoken[counter] = now + 120;    &#13;
    counter += 1;    &#13;
  }&#13;
&#13;
  /* Modifiers */&#13;
  modifier onlyOwner(uint256 _tokenId) {&#13;
    require(ownerOftoken[_tokenId] == msg.sender);&#13;
    _;&#13;
  }&#13;
  &#13;
  modifier onlyCreator(uint256 _tokenId) {&#13;
    require(creatorOftoken[_tokenId] == msg.sender);&#13;
    _;&#13;
  }  &#13;
&#13;
  /* Owner */&#13;
  function setCreator (address _creator, uint _tokenId) onlyCreator(_tokenId) public {&#13;
    creatorOftoken[_tokenId] = _creator;&#13;
  }&#13;
&#13;
  /* Withdraw */&#13;
&#13;
  function withdrawAllFromToken (uint256 _tokenId) onlyCreator(_tokenId) public {&#13;
    uint256 t = balanceOfToken[_tokenId];&#13;
    uint256 r = t / 20;&#13;
    balanceOfToken[_tokenId] = 0;&#13;
    balanceOfToken[parentOftoken[_tokenId]] += r;&#13;
    msg.sender.transfer(t - r);      &#13;
  }&#13;
&#13;
  function withdrawAmountFromToken (uint256 _tokenId, uint256 t) onlyCreator(_tokenId) public {&#13;
    if (t &gt; balanceOfToken[_tokenId]) t = balanceOfToken[_tokenId];&#13;
    uint256 r = t / 20;&#13;
    balanceOfToken[_tokenId] = 0;&#13;
    balanceOfToken[parentOftoken[_tokenId]] += r;&#13;
    msg.sender.transfer(t - r); &#13;
  }&#13;
  &#13;
  function withdrawAll() public {&#13;
      require(msg.sender == owner);&#13;
      owner.transfer(this.balance);&#13;
  }&#13;
&#13;
  /* Buying */&#13;
  function calculateNextPrice (uint256 _price) public view returns (uint256 _nextPrice) {&#13;
    return _price.mul(117).div(98);&#13;
  }&#13;
&#13;
  function calculateDevCut (uint256 _price) public view returns (uint256 _devCut) {&#13;
    return _price.div(20); // 5%&#13;
  }&#13;
&#13;
  function buy (uint256 _tokenId) payable public {&#13;
    require(priceOf(_tokenId) &gt; 0);&#13;
    require(ownerOf(_tokenId) != address(0));&#13;
    require(msg.value &gt;= priceOf(_tokenId));&#13;
    require(ownerOf(_tokenId) != msg.sender);&#13;
    require(!isContract(msg.sender));&#13;
    require(msg.sender != address(0));&#13;
&#13;
    address oldOwner = ownerOf(_tokenId);&#13;
    address newOwner = msg.sender;&#13;
    uint256 price = priceOf(_tokenId);&#13;
    uint256 excess = msg.value.sub(price);&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
    priceOftoken[_tokenId] = nextPriceOf(_tokenId);&#13;
&#13;
    Bought(_tokenId, newOwner, price);&#13;
    Sold(_tokenId, oldOwner, price);&#13;
&#13;
    // Devevloper's cut which is left in contract and accesed by&#13;
    // `withdrawAll` and `withdrawAmountTo` methods.&#13;
    uint256 devCut = calculateDevCut(price);&#13;
&#13;
    // Transfer payment to old owner minus the developer's cut.&#13;
    oldOwner.transfer(price.sub(devCut));&#13;
    uint256 shareHolderCut = devCut.div(20);&#13;
    ownerOftoken[parentOftoken[_tokenId]].transfer(shareHolderCut);&#13;
    balanceOfToken[_tokenId] += devCut.sub(shareHolderCut);&#13;
&#13;
    if (excess &gt; 0) {&#13;
      newOwner.transfer(excess);&#13;
    }&#13;
  }&#13;
&#13;
  /* ERC721 */&#13;
&#13;
  function name() public view returns (string name) {&#13;
    return "smartsignature.io";&#13;
  }&#13;
&#13;
  function symbol() public view returns (string symbol) {&#13;
    return "SSI";&#13;
  }&#13;
&#13;
  function totalSupply() public view returns (uint256 _totalSupply) {&#13;
    return counter;&#13;
  }&#13;
&#13;
  function balanceOf (address _owner) public view returns (uint256 _balance) {&#13;
    uint256 counter = 0;&#13;
&#13;
    for (uint256 i = 0; i &lt; counter; i++) {&#13;
      if (ownerOf(i) == _owner) {&#13;
        counter++;&#13;
      }&#13;
    }&#13;
&#13;
    return counter;&#13;
  }&#13;
&#13;
  function ownerOf (uint256 _tokenId) public view returns (address _owner) {&#13;
    return ownerOftoken[_tokenId];&#13;
  }&#13;
  &#13;
  function creatorOf (uint256 _tokenId) public view returns (address _creator) {&#13;
    return creatorOftoken[_tokenId];&#13;
  }  &#13;
  &#13;
  function parentOf (uint256 _tokenId) public view returns (uint256 _parent) {&#13;
    return parentOftoken[_tokenId];&#13;
  }    &#13;
  &#13;
  function freeOf (uint256 _tokenId) public view returns (uint256 _free) {&#13;
    return freeOftoken[_tokenId];&#13;
  }    &#13;
  &#13;
  function balanceFromToken (uint256 _tokenId) public view returns (uint256 _balance) {&#13;
    return balanceOfToken[_tokenId];&#13;
  }      &#13;
  &#13;
  function tokensOf (address _owner) public view returns (uint256[] _tokenIds) {&#13;
    uint256[] memory tokens = new uint256[](balanceOf(_owner));&#13;
&#13;
    uint256 tokenCounter = 0;&#13;
    for (uint256 i = 0; i &lt; counter; i++) {&#13;
      if (ownerOf(i) == _owner) {&#13;
        tokens[tokenCounter] = i;&#13;
        tokenCounter += 1;&#13;
      }&#13;
    }&#13;
&#13;
    return tokens;&#13;
  }&#13;
&#13;
  function tokenExists (uint256 _tokenId) public view returns (bool _exists) {&#13;
    return priceOf(_tokenId) &gt; 0;&#13;
  }&#13;
&#13;
  function approvedFor(uint256 _tokenId) public view returns (address _approved) {&#13;
    return approvedOftoken[_tokenId];&#13;
  }&#13;
&#13;
  function approve(address _to, uint256 _tokenId) public {&#13;
    require(msg.sender != _to);&#13;
    require(tokenExists(_tokenId));&#13;
    require(ownerOf(_tokenId) == msg.sender);&#13;
&#13;
    if (_to == 0) {&#13;
      if (approvedOftoken[_tokenId] != 0) {&#13;
        delete approvedOftoken[_tokenId];&#13;
        Approval(msg.sender, 0, _tokenId);&#13;
      }&#13;
    } else {&#13;
      approvedOftoken[_tokenId] = _to;&#13;
      Approval(msg.sender, _to, _tokenId);&#13;
    }&#13;
  }&#13;
&#13;
  /* Transferring a country to another owner will entitle the new owner the profits from `buy` */&#13;
  function transfer(address _to, uint256 _tokenId) public {&#13;
    require(msg.sender == ownerOf(_tokenId));&#13;
    _transfer(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _tokenId) public {&#13;
    require(approvedFor(_tokenId) == msg.sender);&#13;
    _transfer(_from, _to, _tokenId);&#13;
  }&#13;
&#13;
  function _transfer(address _from, address _to, uint256 _tokenId) internal {&#13;
    require(tokenExists(_tokenId));&#13;
    require(ownerOf(_tokenId) == _from);&#13;
    require(_to != address(0));&#13;
    require(_to != address(this));&#13;
&#13;
    ownerOftoken[_tokenId] = _to;&#13;
    approvedOftoken[_tokenId] = 0;&#13;
&#13;
    Transfer(_from, _to, _tokenId);&#13;
  }&#13;
&#13;
  /* Read */&#13;
&#13;
  function priceOf (uint256 _tokenId) public view returns (uint256 _price) {&#13;
    return priceOftoken[_tokenId];&#13;
  }&#13;
&#13;
  function nextPriceOf (uint256 _tokenId) public view returns (uint256 _nextPrice) {&#13;
    return calculateNextPrice(priceOf(_tokenId));&#13;
  }&#13;
&#13;
  function allOf (uint256 _tokenId) external view returns (address _owner, address _creator, uint256 _price, uint256 _nextPrice) {&#13;
    return (ownerOftoken[_tokenId], creatorOftoken[_tokenId], priceOftoken[_tokenId], nextPriceOf(_tokenId));&#13;
  }&#13;
&#13;
  /* Util */&#13;
  function isContract(address addr) internal view returns (bool) {&#13;
    uint size;&#13;
    assembly { size := extcodesize(addr) } // solium-disable-line&#13;
    return size &gt; 0;&#13;
  }&#13;
  &#13;
  function changePrice(uint256 _tokenId, uint256 _price) onlyOwner(_tokenId) public {&#13;
    require(now &gt;= freeOftoken[_tokenId]);&#13;
    priceOftoken[_tokenId] = _price;&#13;
  }&#13;
  &#13;
  function issueToken(uint256 _price, uint256 _frozen, uint256 _parent) public {&#13;
    require(_parent &lt;= counter);&#13;
    creatorOftoken[counter] = ownerOftoken[counter] = msg.sender;&#13;
    priceOftoken[counter] = _price;&#13;
    parentOftoken[counter] = _parent;&#13;
    freeOftoken[counter] = now + _frozen;&#13;
    counter += 1;&#13;
  }  &#13;
}