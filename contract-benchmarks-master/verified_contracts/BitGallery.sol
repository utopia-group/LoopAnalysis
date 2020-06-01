pragma solidity 0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
        return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

/**
 * @title Heritable
 * @dev The Heritable contract provides ownership transfer capabilities, in the
 * case that the current owner stops "heartbeating". Only the heir can pronounce the
 * owner's death.
 */
contract Heritable is Ownable {
    address public heir;

    // Time window the owner has to notify they are alive.
    uint public heartbeatTimeout;

    // Timestamp of the owner's death, as pronounced by the heir.
    uint public timeOfDeath;

    event HeirChanged(address indexed owner, address indexed newHeir);
    event OwnerHeartbeated(address indexed owner);
    event OwnerProclaimedDead(address indexed owner, address indexed heir, uint timeOfDeath);
    event HeirOwnershipClaimed(address indexed previousOwner, address indexed newOwner);


    /**
    * @dev Throw an exception if called by any account other than the heir's.
    */
    modifier onlyHeir() {
        require(msg.sender == heir);
        _;
    }


    /**
    * @notice Create a new Heritable Contract with heir address 0x0.
    * @param _heartbeatTimeout time available for the owner to notify they are alive,
    * before the heir can take ownership.
    */
    function Heritable(uint _heartbeatTimeout) public {
        setHeartbeatTimeout(_heartbeatTimeout);
    }

    function setHeir(address newHeir) public onlyOwner {
        require(newHeir != owner);
        heartbeat();
        HeirChanged(owner, newHeir);
        heir = newHeir;
    }

    /**
    * @dev set heir = 0x0
    */
    function removeHeir() public onlyOwner {
        heartbeat();
        heir = 0;
    }

    /**
    * @dev Heir can pronounce the owners death. To claim the ownership, they will
    * have to wait for `heartbeatTimeout` seconds.
    */
    function proclaimDeath() public onlyHeir {
        require(owner != heir); // added
        require(ownerLives());
        OwnerProclaimedDead(owner, heir, timeOfDeath);
        timeOfDeath = now;
    }

    /**
    * @dev Owner can send a heartbeat if they were mistakenly pronounced dead.
    */
    function heartbeat() public onlyOwner {
        OwnerHeartbeated(owner);
        timeOfDeath = 0;
    }

    /**
    * @dev Allows heir to transfer ownership only if heartbeat has timed out.
    */
    function claimHeirOwnership() public onlyHeir {
        require(!ownerLives());
        require(now >= timeOfDeath + heartbeatTimeout);
        OwnershipTransferred(owner, heir);
        HeirOwnershipClaimed(owner, heir);
        owner = heir;
        timeOfDeath = 0;
    }

    function setHeartbeatTimeout(uint newHeartbeatTimeout) internal onlyOwner {
        require(ownerLives());
        heartbeatTimeout = newHeartbeatTimeout;
    }

    function ownerLives() internal view returns (bool) {
        return timeOfDeath == 0;
    }
}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="355150415075544d5c5a584f505b1b565a">[email protected]</a>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
    // Required methods&#13;
    function approve(address _to, uint _tokenId) public;&#13;
    function balanceOf(address _owner) public view returns (uint balance);&#13;
    function implementsERC721() public pure returns (bool);&#13;
    function ownerOf(uint _tokenId) public view returns (address addr);&#13;
    function takeOwnership(uint _tokenId) public;&#13;
    function totalSupply() public view returns (uint total);&#13;
    function transferFrom(address _from, address _to, uint _tokenId) public;&#13;
    function transfer(address _to, uint _tokenId) public;&#13;
&#13;
    event Transfer(address indexed from, address indexed to, uint tokenId);&#13;
    event Approval(address indexed owner, address indexed approved, uint tokenId);&#13;
&#13;
    // Optional&#13;
    // function name() public view returns (string name);&#13;
    // function symbol() public view returns (string symbol);&#13;
    // function tokenOfOwnerByIndex(address _owner, uint _index) external view returns (uint tokenId);&#13;
    // function tokenMetadata(uint _tokenId) public view returns (string infoUrl);&#13;
}&#13;
&#13;
contract BitArtToken is Heritable, ERC721 {&#13;
    string public constant NAME = "BitGallery";&#13;
    string public constant SYMBOL = "BitArt";&#13;
&#13;
    struct Art {&#13;
        bytes32 data;&#13;
    }&#13;
&#13;
    Art[] internal arts;&#13;
&#13;
    mapping (uint =&gt; address) public tokenOwner;&#13;
    mapping (address =&gt; uint) public ownedTokenCount;&#13;
    mapping (uint =&gt; address) public tokenApprovals;&#13;
&#13;
    event Transfer(address from, address to, uint tokenId);&#13;
    event Approval(address owner, address approved, uint tokenId);&#13;
&#13;
    // 30 days to change owner&#13;
    function BitArtToken() Heritable(2592000) public {}&#13;
&#13;
    function tokensOf(address _owner) external view returns(uint[]) {&#13;
        uint tokenCount = balanceOf(_owner);&#13;
&#13;
        if (tokenCount == 0) {&#13;
            return new uint[](0);&#13;
        } else {&#13;
            uint[] memory result = new uint[](tokenCount);&#13;
            uint totaltokens = totalSupply();&#13;
            uint index = 0;&#13;
            &#13;
            for (uint tokenId = 0; tokenId &lt; totaltokens; tokenId++) {&#13;
                if (tokenOwner[tokenId] == _owner) {&#13;
                    result[index] = tokenId;&#13;
                    index++;&#13;
                }&#13;
            }&#13;
            &#13;
            return result;&#13;
        }&#13;
    }&#13;
&#13;
    function approve(address _to, uint _tokenId) public {&#13;
        require(_owns(msg.sender, _tokenId));&#13;
        tokenApprovals[_tokenId] = _to;&#13;
        Approval(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    function balanceOf(address _owner) public view returns (uint balance) {&#13;
        return ownedTokenCount[_owner];&#13;
    }&#13;
&#13;
    function getArts() public view returns (bytes32[]) {&#13;
        uint count = totalSupply();&#13;
        bytes32[] memory result = new bytes32[](count);&#13;
&#13;
        for (uint i = 0; i &lt; count; i++) {&#13;
            result[i] = arts[i].data;&#13;
        }&#13;
&#13;
        return result;&#13;
    }&#13;
&#13;
    function implementsERC721() public pure returns (bool) {&#13;
        return true;&#13;
    }&#13;
&#13;
    function name() public pure returns (string) {&#13;
        return NAME;&#13;
    }&#13;
&#13;
    function ownerOf(uint _tokenId) public view returns (address owner) {&#13;
        owner = tokenOwner[_tokenId];&#13;
        require(_addressNotNull(owner));&#13;
    }&#13;
&#13;
    function symbol() public pure returns (string) {&#13;
        return SYMBOL;&#13;
    }&#13;
&#13;
    function takeOwnership(uint _tokenId) public {&#13;
        address newOwner = msg.sender;&#13;
        require(_addressNotNull(newOwner));&#13;
        require(_approved(newOwner, _tokenId));&#13;
        address oldOwner = tokenOwner[_tokenId];&#13;
&#13;
        _transfer(oldOwner, newOwner, _tokenId);&#13;
    }&#13;
&#13;
    function totalSupply() public view returns (uint total) {&#13;
        return arts.length;&#13;
    }&#13;
&#13;
    function transfer(address _to, uint _tokenId) public {&#13;
        require(_owns(msg.sender, _tokenId));&#13;
        require(_addressNotNull(_to));&#13;
&#13;
        _transfer(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint _tokenId) public {&#13;
        require(_owns(_from, _tokenId));&#13;
        require(_approved(_to, _tokenId));&#13;
        require(_addressNotNull(_to));&#13;
&#13;
        _transfer(_from, _to, _tokenId);&#13;
    }&#13;
&#13;
    function _mint(address _to, uint256 _tokenId) internal {&#13;
        require(_to != address(0));&#13;
        require(tokenOwner[_tokenId] == address(0));&#13;
&#13;
        _transfer(0x0, _to, _tokenId);&#13;
    }&#13;
&#13;
    function _transfer(address _from, address _to, uint _tokenId) internal {&#13;
        require(_from != _to);&#13;
        ownedTokenCount[_to]++;&#13;
        tokenOwner[_tokenId] = _to;&#13;
&#13;
        if (_addressNotNull(_from)) {&#13;
            ownedTokenCount[_from]--;&#13;
            delete tokenApprovals[_tokenId];&#13;
        }&#13;
&#13;
        Transfer(_from, _to, _tokenId);&#13;
    }&#13;
&#13;
    function _addressNotNull(address _address) private pure returns (bool) {&#13;
        return _address != address(0);&#13;
    }&#13;
&#13;
    function _approved(address _to, uint _tokenId) private view returns (bool) {&#13;
        return tokenApprovals[_tokenId] == _to;&#13;
    }&#13;
&#13;
    function _owns(address _claimant, uint _tokenId) private view returns (bool) {&#13;
        return _claimant == tokenOwner[_tokenId];&#13;
    }&#13;
}&#13;
&#13;
contract BitAuction is BitArtToken {&#13;
    using SafeMath for uint;&#13;
&#13;
    struct Auction {&#13;
        uint basePrice;&#13;
        uint64 time1;&#13;
        uint64 time2;&#13;
        uint8 pct1;&#13;
        uint8 pct2;&#13;
        uint8 discount;&#13;
    }&#13;
&#13;
    uint internal _auctionStartsAfter;&#13;
    uint internal _auctionDuration;&#13;
    uint internal _auctionFee;&#13;
&#13;
    mapping (uint =&gt; Auction) public tokenAuction;&#13;
&#13;
    event AuctionRulesChanged(uint startsAfter, uint duration, uint fee);&#13;
    event NewAuction(uint tokenId, uint discount);&#13;
    event NewSaleDiscount(uint tokenId, uint discount);&#13;
&#13;
    function BitAuction() public { }&#13;
&#13;
    function setSaleDiscount(uint _tokenId, uint _discount) external {      &#13;
        require(ownerOf(_tokenId) == msg.sender);&#13;
        require(_discount &lt;= 90);&#13;
        require(_discount &gt;= 10);&#13;
&#13;
        Auction storage auction = tokenAuction[_tokenId];&#13;
        require(auction.basePrice &gt; 0);        &#13;
        require(auction.time2 &lt;= now);&#13;
        auction.discount = uint8(_discount);&#13;
&#13;
        NewSaleDiscount(_tokenId, _discount);&#13;
    }&#13;
&#13;
    function canPurchase(uint _tokenId) public view returns (bool) {&#13;
        Auction storage auction = tokenAuction[_tokenId];&#13;
        require(auction.time1 &gt; 0);&#13;
        return (now &gt;= auction.time1 &amp;&amp; priceOf(_tokenId) &gt; 0);&#13;
    }&#13;
&#13;
    function getPrices(uint[] _ids) public view returns (uint[]) {&#13;
        uint count = _ids.length;&#13;
        bool isEmpty = count == 0;&#13;
&#13;
        if (isEmpty) {&#13;
            count = totalSupply();&#13;
        }&#13;
&#13;
        uint[] memory result = new uint[](count);&#13;
        &#13;
        for (uint i = 0; i &lt; count; i++) {&#13;
            uint tokenId = isEmpty ? i : _ids[i];&#13;
            result[i] = priceOf(tokenId);&#13;
        }        &#13;
        &#13;
        return result;&#13;
    }&#13;
&#13;
    function priceOf(uint _tokenId) public view returns (uint) {&#13;
        Auction storage auction = tokenAuction[_tokenId];&#13;
        return _currentPrice(auction);&#13;
    }&#13;
&#13;
    function setAuctionDurationRules(uint _timeAfter, uint _duration, uint _fee) public onlyOwner {  &#13;
        require(_timeAfter &gt;= 0 seconds);&#13;
        require(_timeAfter &lt;= 7 days);&#13;
        require(_duration &gt;= 24 hours);&#13;
        require(_duration &lt;= 30 days);&#13;
        require(_fee &gt;= 1);&#13;
        require(_fee &lt;= 5);&#13;
        &#13;
        _auctionStartsAfter = _timeAfter;&#13;
        _auctionDuration = _duration;&#13;
        _auctionFee = _fee;&#13;
&#13;
        AuctionRulesChanged(_timeAfter, _duration, _fee);&#13;
    }&#13;
&#13;
    function _createCustomAuction(uint _tokenId, uint _basePrice, uint _time1, uint _time2, uint _pct1, uint _pct2) private {&#13;
        require(_time1 &gt;= now);&#13;
        require(_time2 &gt;= _time1);&#13;
        require(_pct1 &gt; 0);&#13;
        require(_pct2 &gt; 0);&#13;
        &#13;
        Auction memory auction = Auction({&#13;
            basePrice: _basePrice, &#13;
            time1: uint64(_time1), &#13;
            time2: uint64(_time2), &#13;
            pct1: uint8(_pct1), &#13;
            pct2: uint8(_pct2), &#13;
            discount: 0           &#13;
        });&#13;
&#13;
        tokenAuction[_tokenId] = auction;&#13;
    }&#13;
&#13;
    function _createNewTokenAuction(uint _tokenId, uint _basePrice) internal {&#13;
        _createCustomAuction(_tokenId, _basePrice, now, now + _auctionStartsAfter + _auctionDuration, 100, 10);&#13;
    }&#13;
&#13;
    function _createStandartAuction(uint _tokenId, uint _basePrice) internal {&#13;
        uint start = now + _auctionStartsAfter;&#13;
        _createCustomAuction(_tokenId, _basePrice, start, start + _auctionDuration, 200, 110);&#13;
    }&#13;
&#13;
    function _currentPrice(Auction _auction) internal view returns (uint) {&#13;
        if (_auction.discount &gt; 0) {&#13;
            return uint((_auction.basePrice * (100 - _auction.discount)) / 100);&#13;
        }&#13;
&#13;
        uint _startingPrice = uint((_auction.basePrice * _auction.pct1) / 100);&#13;
&#13;
        if (_auction.time1 &gt; now) {&#13;
            return _startingPrice;&#13;
        }&#13;
&#13;
        uint _secondsPassed = uint(now - _auction.time1);&#13;
        uint _duration = uint(_auction.time2 - _auction.time1);&#13;
        uint _endingPrice = uint((_auction.basePrice * _auction.pct2) / 100);&#13;
&#13;
        if (_secondsPassed &gt;= _duration) {&#13;
            return _endingPrice;&#13;
        } else {&#13;
            int totalPriceChange = int(_endingPrice) - int(_startingPrice);&#13;
            int currentPriceChange = totalPriceChange * int(_secondsPassed) / int(_duration);&#13;
            int currentPrice = int(_startingPrice) + currentPriceChange;&#13;
&#13;
            return uint(currentPrice);&#13;
        }&#13;
    }&#13;
&#13;
    function _computePrice(uint _secondsPassed, uint _duration, uint _startingPrice, uint _endingPrice) private pure returns (uint) {&#13;
        if (_secondsPassed &gt;= _duration) {&#13;
            return _endingPrice;&#13;
        } else {&#13;
            int totalPriceChange = int(_endingPrice) - int(_startingPrice);&#13;
            int currentPriceChange = totalPriceChange * int(_secondsPassed) / int(_duration);&#13;
            int currentPrice = int(_startingPrice) + currentPriceChange;&#13;
&#13;
            return uint(currentPrice);&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
contract BitGallery is BitAuction {&#13;
    using SafeMath for uint;&#13;
&#13;
    string public infoMessage;&#13;
&#13;
    event TokenSold(uint tokenId, uint price, address from, address to);&#13;
    event NewToken(uint tokenId, string metadata);&#13;
&#13;
    function BitGallery() public {&#13;
        setAuctionDurationRules(24 hours, 6 days, 3);&#13;
&#13;
        setMessage("Our web site is www.bitgallery.co");                          &#13;
    }&#13;
&#13;
    function() public payable {}&#13;
&#13;
    function addArt(string _keyData, uint _basePrice) public onlyOwner {&#13;
        return addArtTo(address(this), _keyData, _basePrice);&#13;
    }&#13;
&#13;
    function addArtTo(address _owner, string _keyData, uint _basePrice) public onlyOwner {&#13;
        require(_basePrice &gt;= 1 finney);&#13;
        &#13;
        Art memory _art = Art({&#13;
            data: keccak256(_keyData)&#13;
        });&#13;
&#13;
        uint tokenId = arts.push(_art) - 1;&#13;
        NewToken(tokenId, _keyData);&#13;
        _mint(_owner, tokenId);&#13;
        _createNewTokenAuction(tokenId, _basePrice);&#13;
    }&#13;
&#13;
    function artExists(string _keydata) public view returns (bool) {&#13;
        for (uint i = 0; i &lt; totalSupply(); i++) {&#13;
            if (arts[i].data == keccak256(_keydata)) {&#13;
                return true;&#13;
            }&#13;
        }&#13;
&#13;
        return false;&#13;
    }&#13;
&#13;
    function fullDataOf(uint _tokenId) public view returns (&#13;
        uint basePrice,&#13;
        uint64 time1,&#13;
        uint64 time2,&#13;
        uint8 pct1,&#13;
        uint8 pct2,&#13;
        uint8 discount,&#13;
        uint currentPrice,&#13;
        bool _canPurchase,&#13;
        address owner&#13;
    ) {&#13;
        Auction storage auction = tokenAuction[_tokenId];&#13;
        basePrice = auction.basePrice;&#13;
        time1 = auction.time1;&#13;
        time2 = auction.time2;&#13;
        pct1 = auction.pct1;&#13;
        pct2 = auction.pct2;&#13;
        discount = auction.discount;&#13;
        currentPrice = priceOf(_tokenId);&#13;
        _canPurchase = canPurchase(_tokenId);&#13;
        owner = ownerOf(_tokenId);&#13;
    }&#13;
&#13;
    function payout(address _to) public onlyOwner {&#13;
        require(_to != address(this));&#13;
        &#13;
        if (_to == address(0)) { &#13;
            _to = msg.sender;&#13;
        }&#13;
&#13;
        _to.transfer(this.balance);&#13;
    }&#13;
&#13;
    function purchase(uint _tokenId) public payable {&#13;
        Auction storage auction = tokenAuction[_tokenId];&#13;
        require(now &gt;= auction.time1);&#13;
        uint price = _currentPrice(auction);&#13;
        require(msg.value &gt;= price);&#13;
&#13;
        uint payment = uint((price * (100 - _auctionFee)) / 100);&#13;
        uint purchaseExcess = msg.value - price;&#13;
        _createStandartAuction(_tokenId, price);&#13;
&#13;
        address from = ownerOf(_tokenId);&#13;
        address to = msg.sender;&#13;
        _transfer(from, to, _tokenId);&#13;
&#13;
        if (from != address(this)) {&#13;
            from.transfer(payment);&#13;
        }&#13;
&#13;
        TokenSold(_tokenId, price, from, to);&#13;
        msg.sender.transfer(purchaseExcess);&#13;
    }&#13;
&#13;
    function setMessage(string _message) public onlyOwner {        &#13;
        infoMessage = _message;&#13;
    }&#13;
}