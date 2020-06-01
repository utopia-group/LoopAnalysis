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
/// @author Dieter Shirley <<span class="__cf_email__" data-cfemail="f692938293b6978e9f999b8c9398d89599">[email protected]</span>&gt; (https://github.com/dete)&#13;
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
contract CTAuction {&#13;
&#13;
    struct Auction {&#13;
        // Parameters of the auction. Times are either&#13;
        // absolute unix timestamps (seconds since 1970-01-01)&#13;
        // or time periods in seconds.&#13;
        uint auctionEnd;&#13;
&#13;
        // Current state of the auction.&#13;
        address highestBidder;&#13;
        uint highestBid;&#13;
&#13;
        //Minumin Bid Set by the beneficiary&#13;
        uint minimumBid;&#13;
&#13;
        // Set to true at the end, disallows any change&#13;
        bool ended;&#13;
&#13;
        //Titty being Auctioned&#13;
        uint titty;&#13;
&#13;
        //Beneficiary&#13;
        address beneficiary;&#13;
&#13;
        //buynow price&#13;
        uint buyNowPrice;&#13;
    }&#13;
&#13;
    Auction[] Auctions;&#13;
&#13;
    address public owner; &#13;
    address public ctWallet; &#13;
    address public tittyContractAddress;&#13;
&#13;
    // Allowed withdrawals of previous bids&#13;
    mapping(address =&gt; uint) pendingReturns;&#13;
&#13;
    // CriptoTitty Contract&#13;
    TittyPurchase public tittyContract;&#13;
&#13;
    // Events that will be fired on changes.&#13;
    event HighestBidIncreased(uint auction, address bidder, uint amount);&#13;
    event AuctionEnded(address winner, uint amount);&#13;
    event BuyNow(address buyer, uint amount);&#13;
    event AuctionCancel(uint auction);&#13;
    event NewAuctionCreated(uint auctionId, uint titty);&#13;
    event DidNotFinishYet(uint time, uint auctionTime);&#13;
    event NotTheContractOwner(address owner, address sender);&#13;
&#13;
    // The following is a so-called natspec comment,&#13;
    // recognizable by the three slashes.&#13;
    // It will be shown when the user is asked to&#13;
    // confirm a transaction.&#13;
&#13;
    /// Create a simple auction with `_biddingTime`&#13;
    /// seconds bidding time on behalf of the&#13;
    /// beneficiary address `_beneficiary`.&#13;
    function CTAuction(&#13;
        address _tittyPurchaseAddress,&#13;
        address _wallet&#13;
    ) public &#13;
    {   &#13;
        tittyContractAddress = _tittyPurchaseAddress;&#13;
        tittyContract = TittyPurchase(_tittyPurchaseAddress);&#13;
        ctWallet = _wallet;&#13;
        owner = msg.sender; &#13;
    }&#13;
&#13;
    function createAuction(uint _biddingTime, uint _titty, uint _minimumBid, uint _buyNowPrice) public {&#13;
&#13;
        address ownerAddress = tittyContract.ownerOf(_titty);&#13;
        require(msg.sender == ownerAddress);&#13;
&#13;
        Auction memory auction = Auction({&#13;
            auctionEnd: now + _biddingTime,&#13;
            titty: _titty,&#13;
            beneficiary: msg.sender,&#13;
            highestBidder: 0,&#13;
            highestBid: 0,&#13;
            ended: false,&#13;
            minimumBid: _minimumBid,&#13;
            buyNowPrice: _buyNowPrice&#13;
        });&#13;
&#13;
        uint auctionId = Auctions.push(auction) - 1;&#13;
        NewAuctionCreated(auctionId, _titty);&#13;
    }&#13;
&#13;
    function getTittyOwner(uint _titty) public view returns (address) {&#13;
        address ownerAddress = tittyContract.ownerOf(_titty);&#13;
        return ownerAddress;&#13;
    } &#13;
&#13;
    /// Bid on an auction with the value sent&#13;
    /// together with this transaction.&#13;
    /// The value will only be refunded if the&#13;
    /// auction is not won.&#13;
    function bid(uint _auction) public payable {&#13;
&#13;
        Auction memory auction = Auctions[_auction];&#13;
&#13;
        // Revert the call if the bidding&#13;
        // period is over.&#13;
        require(now &lt;= auction.auctionEnd);&#13;
&#13;
        // Revert the call value is less than the minimumBid.&#13;
        require(msg.value &gt;= auction.minimumBid);&#13;
&#13;
        // If the bid is not higher, send the&#13;
        // money back.&#13;
        require(msg.value &gt; auction.highestBid);&#13;
&#13;
        if (auction.highestBid != 0) {&#13;
            // Sending back the money by simply using&#13;
            // highestBidder.send(highestBid) is a security risk&#13;
            // because it could execute an untrusted contract.&#13;
            // It is always safer to let the recipients&#13;
            // withdraw their money themselves.&#13;
            pendingReturns[auction.highestBidder] += auction.highestBid;&#13;
        }&#13;
        auction.highestBidder = msg.sender;&#13;
        auction.highestBid = msg.value;&#13;
        Auctions[_auction] = auction;&#13;
        HighestBidIncreased(_auction, msg.sender, msg.value);&#13;
    }&#13;
&#13;
    function buyNow(uint _auction) public payable {&#13;
&#13;
        Auction memory auction = Auctions[_auction];&#13;
&#13;
        require(now &gt;= auction.auctionEnd); // auction has ended&#13;
        require(!auction.ended); // this function has already been called&#13;
&#13;
        //Require that the value sent is the buyNowPrice Set by the Owner/Benneficary&#13;
        require(msg.value == auction.buyNowPrice);&#13;
&#13;
        //Require that there are no bids&#13;
        require(auction.highestBid == 0);&#13;
&#13;
        // End Auction&#13;
        auction.ended = true;&#13;
        Auctions[_auction] = auction;&#13;
        BuyNow(msg.sender, msg.value);&#13;
&#13;
        // Send the Funds&#13;
        tittyContract.transferFrom(auction.beneficiary, msg.sender, auction.titty);&#13;
        uint fee = calculateFee(msg.value);&#13;
        ctWallet.transfer(fee);&#13;
        auction.beneficiary.transfer(msg.value-fee);&#13;
    }&#13;
&#13;
    /// Withdraw a bid that was overbid.&#13;
    function withdraw() public returns (bool) {&#13;
        uint amount = pendingReturns[msg.sender];&#13;
        require(amount &gt; 0);&#13;
        // It is important to set this to zero because the recipient&#13;
        // can call this function again as part of the receiving call&#13;
        // before `send` returns.&#13;
        pendingReturns[msg.sender] = 0;&#13;
&#13;
        if (!msg.sender.send(amount)) {&#13;
            // No need to call throw here, just reset the amount owing&#13;
            pendingReturns[msg.sender] = amount;&#13;
            return false;&#13;
        }&#13;
        &#13;
        return true;&#13;
    }&#13;
&#13;
    function auctionCancel(uint _auction) public {&#13;
&#13;
        Auction memory auction = Auctions[_auction];&#13;
&#13;
        //has to be the beneficiary&#13;
        require(msg.sender == auction.beneficiary);&#13;
&#13;
        //Auction Ended&#13;
        require(now &gt;= auction.auctionEnd);&#13;
&#13;
        //has no maxbid &#13;
        require(auction.highestBid == 0);&#13;
&#13;
        auction.ended = true;&#13;
        Auctions[_auction] = auction;&#13;
        AuctionCancel(_auction);&#13;
&#13;
    }&#13;
&#13;
    /// End the auction and send the highest bid&#13;
    /// to the beneficiary and 10% to CT.&#13;
    function auctionEnd(uint _auction) public {&#13;
&#13;
        // Just cryptotitties CEO can end the auction&#13;
        require (owner == msg.sender);&#13;
&#13;
        Auction memory auction = Auctions[_auction];&#13;
&#13;
        require (now &gt;= auction.auctionEnd); // auction has ended&#13;
        require(!auction.ended); // this function has already been called&#13;
&#13;
        // End Auction&#13;
        auction.ended = true;&#13;
        Auctions[_auction] = auction;&#13;
        AuctionEnded(auction.highestBidder, auction.highestBid);&#13;
        if (auction.highestBid != 0) {&#13;
            // Send the Funds&#13;
            tittyContract.transferFrom(auction.beneficiary, auction.highestBidder, auction.titty);&#13;
            uint fee = calculateFee(auction.highestBid);&#13;
            ctWallet.transfer(fee);&#13;
            auction.beneficiary.transfer(auction.highestBid-fee);&#13;
        }&#13;
&#13;
    }&#13;
&#13;
    function getAuctionInfo(uint _auction) public view returns (uint end, address beneficiary, uint maxBid, address maxBidder) {&#13;
&#13;
        Auction storage auction = Auctions[_auction];&#13;
&#13;
        end = auction.auctionEnd;&#13;
        beneficiary = auction.beneficiary;&#13;
        maxBid = auction.highestBid;&#13;
        maxBidder = auction.highestBidder;&#13;
    }&#13;
&#13;
    function calculateFee (uint256 _price) internal pure returns(uint) {&#13;
        return (_price * 10)/100;&#13;
    }&#13;
}