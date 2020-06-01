pragma solidity ^0.4.18;

contract TittyBase {

    event Transfer(address indexed from, address indexed to);
    event Creation(address indexed from, uint256 tittyId, uint256 wpId);
    event AddAccessory(uint256 tittyId, uint256 accessoryId);

    struct Accessory {

        uint256 id;
        string name;
        uint256 price;
        bool isActive;

    }

    struct Titty {

        uint256 id;
        string name;
        string gender;
        uint256 originalPrice;
        uint256 salePrice;
        uint256[] accessories;
        bool forSale;
    }

    //Storage
    Titty[] Titties;
    Accessory[] Accessories;
    mapping (uint256 => address) public tittyIndexToOwner;
    mapping (address => uint256) public ownerTittiesCount;
    mapping (uint256 => address) public tittyApproveIndex;

    function _transfer(address _from, address _to, uint256 _tittyId) internal {

        ownerTittiesCount[_to]++;

        tittyIndexToOwner[_tittyId] = _to;
        if (_from != address(0)) {
            ownerTittiesCount[_from]--;
            delete tittyApproveIndex[_tittyId];
        }

        Transfer(_from, _to);

    }

    function _changeTittyPrice (uint256 _newPrice, uint256 _tittyId) internal {

        require(tittyIndexToOwner[_tittyId] == msg.sender);
        Titty storage _titty = Titties[_tittyId];
        _titty.salePrice = _newPrice;

        Titties[_tittyId] = _titty;
    }

    function _setTittyForSale (bool _forSale, uint256 _tittyId) internal {

        require(tittyIndexToOwner[_tittyId] == msg.sender);
        Titty storage _titty = Titties[_tittyId];
        _titty.forSale = _forSale;

        Titties[_tittyId] = _titty;
    }

    function _changeName (string _name, uint256 _tittyId) internal {

        require(tittyIndexToOwner[_tittyId] == msg.sender);
        Titty storage _titty = Titties[_tittyId];
        _titty.name = _name;

        Titties[_tittyId] = _titty;
    }

    function addAccessory (uint256 _id, string _name, uint256 _price, uint256 tittyId ) internal returns (uint) {

        Accessory memory _accessory = Accessory({

            id: _id,
            name: _name,
            price: _price,
            isActive: true

        });

        Titty storage titty = Titties[tittyId];
        uint256 newAccessoryId = Accessories.push(_accessory) - 1;
        titty.accessories.push(newAccessoryId);
        AddAccessory(tittyId, newAccessoryId);

        return newAccessoryId;

    }

    function totalAccessories(uint256 _tittyId) public view returns (uint256) {

        Titty storage titty = Titties[_tittyId];
        return titty.accessories.length;

    }

    function getAccessory(uint256 _tittyId, uint256 _aId) public view returns (uint256 id, string name,  uint256 price, bool active) {

        Titty storage titty = Titties[_tittyId];
        uint256 accId = titty.accessories[_aId];
        Accessory storage accessory = Accessories[accId];
        id = accessory.id;
        name = accessory.name;
        price = accessory.price;
        active = accessory.isActive;

    }

    function createTitty (uint256 _id, string _gender, uint256 _price, address _owner, string _name) internal returns (uint) {
        
        Titty memory _titty = Titty({
            id: _id,
            name: _name,
            gender: _gender,
            originalPrice: _price,
            salePrice: _price,
            accessories: new uint256[](0),
            forSale: false
        });

        uint256 newTittyId = Titties.push(_titty) - 1;

        Creation(
            _owner,
            newTittyId,
            _id
        );

        _transfer(0, _owner, newTittyId);
        return newTittyId;
    }

    

}


/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1f7b7a6b7a5f7e67767072657a71317c70">[email protected]</a>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
    function implementsERC721() public pure returns (bool);&#13;
    function totalSupply() public view returns (uint256 total);&#13;
    function balanceOf(address _owner) public view returns (uint256 balance);&#13;
    function ownerOf(uint256 _tokenId) public view returns (address owner);&#13;
    function approve(address _to, uint256 _tokenId) public;&#13;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;&#13;
    function transfer(address _to, uint256 _tokenId) public;&#13;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);&#13;
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);&#13;
&#13;
    // Optional&#13;
    // function name() public view returns (string name);&#13;
    // function symbol() public view returns (string symbol);&#13;
    // function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenId);&#13;
    // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract TittyOwnership is TittyBase, ERC721 {&#13;
&#13;
    string public name = "CryptoTittes";&#13;
    string public symbol = "CT";&#13;
&#13;
    function implementsERC721() public pure returns (bool) {&#13;
        return true;&#13;
    }&#13;
&#13;
    function _isOwner(address _user, uint256 _tittyId) internal view returns (bool) {&#13;
        return tittyIndexToOwner[_tittyId] == _user;&#13;
    }&#13;
&#13;
    function _approve(uint256 _tittyId, address _approved) internal {&#13;
         tittyApproveIndex[_tittyId] = _approved; &#13;
    }&#13;
&#13;
    function _approveFor(address _user, uint256 _tittyId) internal view returns (bool) {&#13;
         return tittyApproveIndex[_tittyId] == _user; &#13;
    }&#13;
&#13;
    function totalSupply() public view returns (uint256 total) {&#13;
        return Titties.length - 1;&#13;
    }&#13;
&#13;
    function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
        return ownerTittiesCount[_owner];&#13;
    }&#13;
    &#13;
    function ownerOf(uint256 _tokenId) public view returns (address owner) {&#13;
        owner = tittyIndexToOwner[_tokenId];&#13;
        require(owner != address(0));&#13;
    }&#13;
&#13;
    function approve(address _to, uint256 _tokenId) public {&#13;
        require(_isOwner(msg.sender, _tokenId));&#13;
        _approve(_tokenId, _to);&#13;
        Approval(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _tokenId) public {&#13;
        require(_approveFor(msg.sender, _tokenId));&#13;
        require(_isOwner(_from, _tokenId));&#13;
&#13;
        _transfer(_from, _to, _tokenId);&#13;
        &#13;
&#13;
    }&#13;
    function transfer(address _to, uint256 _tokenId) public {&#13;
        require(_to != address(0));&#13;
        require(_isOwner(msg.sender, _tokenId));&#13;
&#13;
        _transfer(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
&#13;
&#13;
}&#13;
&#13;
contract TittyPurchase is TittyOwnership {&#13;
&#13;
    address private wallet;&#13;
    address private boat;&#13;
&#13;
    function TittyPurchase(address _wallet, address _boat) public {&#13;
        wallet = _wallet;&#13;
        boat = _boat;&#13;
&#13;
        createTitty(0, "unissex", 1000000000, address(0), "genesis");&#13;
    }&#13;
&#13;
    function purchaseNew(uint256 _id, string _name, string _gender, uint256 _price) public payable {&#13;
&#13;
        if (msg.value == 0 &amp;&amp; msg.value != _price)&#13;
            revert();&#13;
&#13;
        uint256 boatFee = calculateBoatFee(msg.value);&#13;
        createTitty(_id, _gender, _price, msg.sender, _name);&#13;
        wallet.transfer(msg.value - boatFee);&#13;
        boat.transfer(boatFee);&#13;
&#13;
    }&#13;
&#13;
    function purchaseExistent(uint256 _tittyId) public payable {&#13;
&#13;
        Titty storage titty = Titties[_tittyId];&#13;
        uint256 fee = calculateFee(titty.salePrice);&#13;
        if (msg.value == 0 &amp;&amp; msg.value != titty.salePrice)&#13;
            revert();&#13;
        &#13;
        uint256 val = msg.value - fee;&#13;
        address owner = tittyIndexToOwner[_tittyId];&#13;
        _approve(_tittyId, msg.sender);&#13;
        transferFrom(owner, msg.sender, _tittyId);&#13;
        owner.transfer(val);&#13;
        wallet.transfer(fee);&#13;
&#13;
    }&#13;
&#13;
    function purchaseAccessory(uint256 _tittyId, uint256 _accId, string _name, uint256 _price) public payable {&#13;
&#13;
        if (msg.value == 0 &amp;&amp; msg.value != _price)&#13;
            revert();&#13;
&#13;
        wallet.transfer(msg.value);&#13;
        addAccessory(_accId, _name, _price,  _tittyId);&#13;
        &#13;
        &#13;
    }&#13;
&#13;
    function getAmountOfTitties() public view returns(uint) {&#13;
        return Titties.length;&#13;
    }&#13;
&#13;
    function getLatestId() public view returns (uint) {&#13;
        return Titties.length - 1;&#13;
    }&#13;
&#13;
    function getTittyByWpId(address _owner, uint256 _wpId) public view returns (bool own, uint256 tittyId) {&#13;
        &#13;
        for (uint256 i = 1; i&lt;=totalSupply(); i++) {&#13;
            Titty storage titty = Titties[i];&#13;
            bool isOwner = _isOwner(_owner, i);&#13;
            if (titty.id == _wpId &amp;&amp; isOwner) {&#13;
                return (true, i);&#13;
            }&#13;
        }&#13;
        &#13;
        return (false, 0);&#13;
    }&#13;
&#13;
    function belongsTo(address _account, uint256 _tittyId) public view returns (bool) {&#13;
        return _isOwner(_account, _tittyId);&#13;
    }&#13;
&#13;
    function changePrice(uint256 _price, uint256 _tittyId) public {&#13;
        _changeTittyPrice(_price, _tittyId);&#13;
    }&#13;
&#13;
    function changeName(string _name, uint256 _tittyId) public {&#13;
        _changeName(_name, _tittyId);&#13;
    }&#13;
&#13;
    function makeItSellable(uint256 _tittyId) public {&#13;
        _setTittyForSale(true, _tittyId);&#13;
    }&#13;
&#13;
    function calculateFee (uint256 _price) internal pure returns(uint) {&#13;
        return (_price * 10)/100;&#13;
    }&#13;
&#13;
    function calculateBoatFee (uint256 _price) internal pure returns(uint) {&#13;
        return (_price * 25)/100;&#13;
    }&#13;
&#13;
    function() external {}&#13;
&#13;
    function getATitty(uint256 _tittyId)&#13;
        public &#13;
        view &#13;
        returns (&#13;
        uint256 id,&#13;
        string name,&#13;
        string gender,&#13;
        uint256 originalPrice,&#13;
        uint256 salePrice,&#13;
        bool forSale&#13;
        ) {&#13;
&#13;
            Titty storage titty = Titties[_tittyId];&#13;
            id = titty.id;&#13;
            name = titty.name;&#13;
            gender = titty.gender;&#13;
            originalPrice = titty.originalPrice;&#13;
            salePrice = titty.salePrice;&#13;
            forSale = titty.forSale;&#13;
        }&#13;
&#13;
}&#13;
&#13;
contract CTBoatGame {&#13;
&#13;
    address private wallet;&#13;
    address private contractOwner;&#13;
    uint endDate;&#13;
&#13;
    uint256 votePrice = 3 finney;&#13;
&#13;
    TittyPurchase public tittyContract;&#13;
&#13;
    struct Vote {&#13;
        uint256 totalRaised;&#13;
        uint256 votes;&#13;
    }&#13;
&#13;
    Vote[] votes;&#13;
    mapping (uint256 =&gt; uint256) public tittyVotes;&#13;
&#13;
    event Voted(uint voteId, uint titty);&#13;
    &#13;
    function CTBoatGame(address _wallet, address _tittyPurchaseAddress, uint _endDate) public {&#13;
        wallet = _wallet;&#13;
        contractOwner = msg.sender;&#13;
        endDate = _endDate;&#13;
        tittyContract = TittyPurchase(_tittyPurchaseAddress);&#13;
        &#13;
        &#13;
    }&#13;
&#13;
    function doVote (uint256 _tittyId, uint256 _amount) public payable {&#13;
&#13;
        require (now &lt; endDate);&#13;
        &#13;
        uint256 total = calculatePrice(_amount);&#13;
        if (msg.value &lt; 0 || msg.value != total)&#13;
            revert();&#13;
&#13;
        uint256 voteId = tittyVotes[_tittyId];&#13;
        if (voteId == 0) {&#13;
            voteId = _createVote(_tittyId, _amount, total);&#13;
            tittyVotes[_tittyId] = voteId;&#13;
        } else {&#13;
            Vote storage vote = votes[voteId];&#13;
            _addVote(vote, voteId, _amount, total);&#13;
        }&#13;
&#13;
        Voted(voteId, _tittyId);&#13;
        &#13;
        address ownerAddress = tittyContract.ownerOf(_tittyId);&#13;
&#13;
        uint256 charityFee = calculateCharityFee(msg.value);&#13;
        uint256 ownerFee = calculateOwnerFee(msg.value);&#13;
        ownerAddress.transfer(ownerFee);&#13;
        wallet.transfer(msg.value - (charityFee + ownerFee));&#13;
&#13;
    }&#13;
&#13;
    function transferToCharity(address _charity) public {&#13;
        &#13;
        require(msg.sender == contractOwner);&#13;
        _charity.transfer(this.balance);&#13;
&#13;
    }&#13;
&#13;
    function calculatePrice(uint256 _amount) internal view returns (uint) {&#13;
        return votePrice * _amount;&#13;
    }&#13;
&#13;
    function getOwner(uint256 id) public view returns (address owner) {&#13;
        owner = tittyContract.ownerOf(id);&#13;
    }&#13;
&#13;
    function _createVote (uint256 _tittyId, uint256 _amount, uint256 _value) internal returns (uint) {&#13;
&#13;
        Vote memory newVote = Vote({&#13;
            totalRaised: _value,&#13;
            votes: _amount&#13;
        });&#13;
&#13;
        uint256 voteId = votes.push(newVote) - 1;&#13;
        tittyVotes[_tittyId] = voteId;&#13;
&#13;
        return voteId;&#13;
    }&#13;
&#13;
    function _addVote (Vote vote, uint256 voteId, uint256 _amount, uint256 _value) internal {&#13;
&#13;
        vote.totalRaised = vote.totalRaised + _value;&#13;
        vote.votes = vote.votes + _amount;&#13;
        votes[voteId] = vote;&#13;
&#13;
    }&#13;
&#13;
    function getNumberOfVotes (uint256 _tittyId) public view returns (uint256, uint256) {&#13;
&#13;
        uint256 voteId = tittyVotes[_tittyId];&#13;
        Vote storage vote = votes[voteId];&#13;
&#13;
        return (vote.votes, vote.totalRaised);&#13;
&#13;
    }&#13;
&#13;
    function calculateCharityFee (uint256 _price) internal pure returns(uint) {&#13;
        return (_price * 70)/100;&#13;
    }&#13;
    &#13;
    function calculateOwnerFee (uint256 _price) internal pure returns(uint) {&#13;
        return (_price * 25)/100;&#13;
    }&#13;
&#13;
    function() external {}&#13;
&#13;
&#13;
}