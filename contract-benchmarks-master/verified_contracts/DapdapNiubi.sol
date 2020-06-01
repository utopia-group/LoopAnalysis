pragma solidity ^0.4.24;

/**
* Issued by
*   __                        __                                     
*  /\ \                      /\ \                       __           
*  \_\ \     __     _____    \_\ \     __     _____    /\_\    ___   
*  /'_` \  /'__`\  /\ '__`\  /'_` \  /'__`\  /\ '__`\  \/\ \  / __`\ 
* /\ \L\ \/\ \L\.\_\ \ \L\ \/\ \L\ \/\ \L\.\_\ \ \L\ \__\ \ \/\ \L\ \
* \ \___,_\ \__/.\_\\ \ ,__/\ \___,_\ \__/.\_\\ \ ,__/\_\\ \_\ \____/
*  \/__,_ /\/__/\/_/ \ \ \/  \/__,_ /\/__/\/_/ \ \ \/\/_/ \/_/\/___/ 
*                    \ \_\                     \ \_\                
*                     \/_/                      \/_/                
*
* dapdapToken(dapdap)
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

  function max(uint a, uint b) internal pure returns (uint) {
    if (a > b) return a;
    else return b;
  }

  function min(uint a, uint b) internal pure returns (uint) {
    if (a < b) return a;
    else return b;
  }
}


/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="84e0e1f0e1c4e5fcedebe9fee1eaaae7eb">[email protected]</a>&gt; (https://github.com/dete)&#13;
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
    // function supportsInterface(bytes4 _interfaceID) external view returns (bool);&#13;
}&#13;
&#13;
contract DapdapNiubi is ERC721{&#13;
  using SafeMath for uint256;&#13;
&#13;
  event Bought (uint256 indexed _itemId, address indexed _owner, uint256 _price);&#13;
  event Sold (uint256 indexed _itemId, address indexed _owner, uint256 _price);&#13;
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);&#13;
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);&#13;
&#13;
  address private owner;&#13;
  mapping (address=&gt;bool) admins;&#13;
  mapping (uint =&gt; address) public mapOwnerOfMedal;&#13;
  mapping (uint256 =&gt; address) public approvedOfItem;&#13;
&#13;
  // typeId &#13;
  // 0 for bronze &#13;
  // 1 for silver &#13;
  // 2 for gold&#13;
  // 3 for diamond&#13;
  // 4 for starlight&#13;
  // 5 for king&#13;
  struct Medal {&#13;
      uint medalId;&#13;
      uint typeId;&#13;
      address owner;&#13;
  }&#13;
&#13;
  Medal[] public listedMedal;&#13;
&#13;
  function DapdapNiubi() public {&#13;
      owner = msg.sender;&#13;
      admins[owner] = true;&#13;
  }&#13;
&#13;
  /* Modifiers */&#13;
  modifier onlyOwner() {&#13;
    require(owner == msg.sender);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier onlyAdmins() {&#13;
    require(admins[msg.sender]);&#13;
    _;&#13;
  }&#13;
&#13;
  /* Owner */&#13;
  function setOwner (address _owner) onlyOwner() public {&#13;
    owner = _owner;&#13;
  }&#13;
&#13;
  function addAdmin (address _admin) onlyOwner() public {&#13;
    admins[_admin] = true;&#13;
  }&#13;
&#13;
  function removeAdmin (address _admin) onlyOwner() public {&#13;
    delete admins[_admin];&#13;
  }&#13;
&#13;
  function getMedalInfo(uint medalId) public view returns(uint, uint, address) {&#13;
      require(medalId&lt;listedMedal.length);&#13;
      Medal memory medal = listedMedal[medalId];&#13;
      return (medal.medalId, medal.typeId, medal.owner);&#13;
  }&#13;
&#13;
  // 4. synthesis system&#13;
  function issueMedal(address userAddress) public onlyAdmins {&#13;
      Medal memory medal = Medal(listedMedal.length, 0, userAddress);&#13;
      mapOwnerOfMedal[listedMedal.length] = userAddress;&#13;
      listedMedal.push(medal);&#13;
    }&#13;
    &#13;
    function issueSuperMetal(address userAddress, uint typeId) public onlyOwner {&#13;
        require(typeId&lt;=5);&#13;
        Medal memory medal = Medal(listedMedal.length, typeId, userAddress);&#13;
        mapOwnerOfMedal[listedMedal.length] = userAddress;&#13;
        listedMedal.push(medal);&#13;
    }&#13;
&#13;
  function mergeMedal(uint medalId1, uint medalId2) public {&#13;
      require(medalId1 &lt; listedMedal.length);&#13;
      require(medalId2 &lt; listedMedal.length);&#13;
      require(listedMedal[medalId1].owner == msg.sender);&#13;
      require(listedMedal[medalId2].owner == msg.sender);&#13;
      require(listedMedal[medalId1].typeId == listedMedal[medalId2].typeId);&#13;
      require(listedMedal[medalId1].typeId &lt;= 4);&#13;
      &#13;
      uint newTypeId = listedMedal[medalId1].typeId + 1;&#13;
      require(newTypeId &lt;= 5);&#13;
      // generate medal&#13;
      listedMedal[medalId1].owner = address(0);&#13;
      listedMedal[medalId2].owner = address(0);&#13;
      mapOwnerOfMedal[medalId1] = address(0);&#13;
      Medal memory medal = Medal(listedMedal.length, newTypeId, msg.sender);&#13;
      mapOwnerOfMedal[listedMedal.length] = msg.sender;&#13;
      listedMedal.push(medal);&#13;
    }&#13;
&#13;
  function getContractBalance() public view returns(uint) {&#13;
      return address(this).balance;&#13;
  }&#13;
&#13;
&#13;
  /* Withdraw */&#13;
  /*&#13;
    NOTICE: These functions withdraw the developer's cut which is left&#13;
    in the contract by `buy`. User funds are immediately sent to the old&#13;
    owner in `buy`, no user funds are left in the contract.&#13;
  */&#13;
  function withdrawAll () onlyAdmins() public {&#13;
   msg.sender.transfer(address(this).balance);&#13;
  }&#13;
&#13;
  function withdrawAmount (uint256 _amount) onlyAdmins() public {&#13;
    msg.sender.transfer(_amount);&#13;
  }&#13;
&#13;
  /* ERC721 */&#13;
&#13;
  function name() public pure returns (string) {&#13;
    return "dapdap.io";&#13;
  }&#13;
&#13;
  function symbol() public pure returns (string) {&#13;
    return "DAPDAP";&#13;
  }&#13;
&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return listedMedal.length;&#13;
  }&#13;
&#13;
  function balanceOf (address _owner) public view returns (uint256 _balance) {&#13;
    uint counter = 0;&#13;
&#13;
    for (uint i = 0; i &lt; listedMedal.length; i++) {&#13;
      if (ownerOf(listedMedal[i].medalId) == _owner) {&#13;
        counter++;&#13;
      }&#13;
    }&#13;
&#13;
    return counter;&#13;
  }&#13;
&#13;
  function ownerOf (uint256 _itemId) public view returns (address _owner) {&#13;
    return mapOwnerOfMedal[_itemId];&#13;
  }&#13;
&#13;
  function tokensOf (address _owner) public view returns (uint[]) {&#13;
    uint[] memory result = new uint[](balanceOf(_owner));&#13;
&#13;
    uint256 itemCounter = 0;&#13;
    for (uint256 i = 0; i &lt; listedMedal.length; i++) {&#13;
      if (ownerOf(i) == _owner) {&#13;
        result[itemCounter] = listedMedal[i].medalId;&#13;
        itemCounter += 1;&#13;
      }&#13;
    }&#13;
    return result;&#13;
  }&#13;
&#13;
  function tokenExists (uint256 _itemId) public view returns (bool _exists) {&#13;
    return mapOwnerOfMedal[_itemId] != address(0);&#13;
  }&#13;
&#13;
  function approvedFor(uint256 _itemId) public view returns (address _approved) {&#13;
    return approvedOfItem[_itemId];&#13;
  }&#13;
&#13;
  function approve(address _to, uint256 _itemId) public {&#13;
    require(msg.sender != _to);&#13;
    require(tokenExists(_itemId));&#13;
    require(ownerOf(_itemId) == msg.sender);&#13;
&#13;
    if (_to == 0) {&#13;
      if (approvedOfItem[_itemId] != 0) {&#13;
        delete approvedOfItem[_itemId];&#13;
        emit Approval(msg.sender, 0, _itemId);&#13;
      }&#13;
    } else {&#13;
      approvedOfItem[_itemId] = _to;&#13;
      emit Approval(msg.sender, _to, _itemId);&#13;
    }&#13;
  }&#13;
&#13;
  /* Transferring a country to another owner will entitle the new owner the profits from `buy` */&#13;
  function transfer(address _to, uint256 _itemId) public {&#13;
    require(msg.sender == ownerOf(_itemId));&#13;
    _transfer(msg.sender, _to, _itemId);&#13;
  }&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _itemId) public {&#13;
    require(approvedFor(_itemId) == msg.sender);&#13;
    _transfer(_from, _to, _itemId);&#13;
  }&#13;
&#13;
  function _transfer(address _from, address _to, uint256 _itemId) internal {&#13;
    require(tokenExists(_itemId));&#13;
    require(ownerOf(_itemId) == _from);&#13;
    require(_to != address(0));&#13;
    require(_to != address(this));&#13;
    &#13;
    mapOwnerOfMedal[_itemId] = _to;&#13;
    listedMedal[_itemId].owner = _to;&#13;
    approvedOfItem[_itemId] = 0;&#13;
&#13;
    emit Transfer(_from, _to, _itemId);&#13;
  }&#13;
&#13;
  /* Read */&#13;
  function isAdmin (address _admin) public view returns (bool _isAdmin) {&#13;
    return admins[_admin];&#13;
  }&#13;
&#13;
  /* Util */&#13;
  function isContract(address addr) internal view returns (bool) {&#13;
    uint size;&#13;
    assembly { size := extcodesize(addr) } // solium-disable-line&#13;
    return size &gt; 0;&#13;
  }&#13;
}&#13;
&#13;
interface IItemRegistry {&#13;
  function itemsForSaleLimit (uint256 _from, uint256 _take) external view returns (uint256[] _items);&#13;
  function ownerOf (uint256 _itemId) external view returns (address _owner);&#13;
  function priceOf (uint256 _itemId) external view returns (uint256 _price);&#13;
}