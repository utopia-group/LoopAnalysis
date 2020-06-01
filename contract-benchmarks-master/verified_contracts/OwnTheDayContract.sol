// OwnTheDay-Token Source code
// copyright 2018 xeroblood <https://owntheday.io>

pragma solidity 0.4.19;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
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

    /* Withdraw */
    /*
    NOTICE: These functions withdraw the developer's cut which is left
    in the contract. User funds are immediately sent to the old
    owner in `claimDay`, no user funds are left in the contract.
    */
    function withdrawAll() public onlyOwner {
        owner.transfer(this.balance);
    }

    function withdrawAmount(uint256 _amount) public onlyOwner {
        require(_amount <= this.balance);
        owner.transfer(_amount);
    }

    function contractBalance() public view returns (uint256) {
        return this.balance;
    }
}


/**
* @title Pausable
* @dev Base contract which allows children to implement an emergency stop mechanism.
*/
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        Unpause();
    }
}


/**
* @title Helps contracts guard agains reentrancy attacks.
* @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7b091e1618143b49">[email protected]</a>π.com&gt;&#13;
* @notice If you mark a function `nonReentrant`, you should also&#13;
* mark it `external`.&#13;
*/&#13;
contract ReentrancyGuard {&#13;
&#13;
    /**&#13;
    * @dev We use a single lock for the whole contract.&#13;
    */&#13;
    bool private reentrancyLock = false;&#13;
&#13;
    /**&#13;
    * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
    * @notice If you mark a function `nonReentrant`, you should also&#13;
    * mark it `external`. Calling one nonReentrant function from&#13;
    * another is not supported. Instead, you can implement a&#13;
    * `private` function doing the actual work, and a `external`&#13;
    * wrapper marked as `nonReentrant`.&#13;
    */&#13;
    modifier nonReentrant() {&#13;
        require(!reentrancyLock);&#13;
        reentrancyLock = true;&#13;
        _;&#13;
        reentrancyLock = false;&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
* @title ERC721 interface&#13;
* @dev see https://github.com/ethereum/eips/issues/721&#13;
*/&#13;
contract ERC721 {&#13;
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);&#13;
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);&#13;
&#13;
    function balanceOf(address _owner) public view returns (uint256 _balance);&#13;
    function ownerOf(uint256 _tokenId) public view returns (address _owner);&#13;
    function transfer(address _to, uint256 _tokenId) public;&#13;
    function approve(address _to, uint256 _tokenId) public;&#13;
    function takeOwnership(uint256 _tokenId) public;&#13;
}&#13;
&#13;
&#13;
/// @title Own the Day!&#13;
/// @author xeroblood (https://owntheday.io)&#13;
contract OwnTheDayContract is ERC721, Pausable, ReentrancyGuard {&#13;
    using SafeMath for uint256;&#13;
&#13;
    event Bought (uint256 indexed _dayIndex, address indexed _owner, uint256 _price);&#13;
    event Sold (uint256 indexed _dayIndex, address indexed _owner, uint256 _price);&#13;
&#13;
    // Total amount of tokens&#13;
    uint256 private totalTokens;&#13;
    bool private mintingFinished = false;&#13;
&#13;
    // Mapping from token ID to owner&#13;
    mapping (uint256 =&gt; address) public tokenOwner;&#13;
&#13;
    // Mapping from token ID to approved address&#13;
    mapping (uint256 =&gt; address) public tokenApprovals;&#13;
&#13;
    // Mapping from owner to list of owned token IDs&#13;
    mapping (address =&gt; uint256[]) public ownedTokens;&#13;
&#13;
    // Mapping from token ID to index of the owner tokens list&#13;
    mapping(uint256 =&gt; uint256) public ownedTokensIndex;&#13;
&#13;
    /// @dev A mapping from Day Index to Current Price.&#13;
    ///  Initial Price set at 1 finney (1/1000th of an ether).&#13;
    mapping (uint256 =&gt; uint256) public dayIndexToPrice;&#13;
&#13;
    /// @dev A mapping from Day Index to the address owner. Days with&#13;
    ///  no valid owner address are assigned to contract owner.&#13;
    //mapping (uint256 =&gt; address) public dayIndexToOwner;      // &lt;---  redundant with tokenOwner&#13;
&#13;
    /// @dev A mapping from Account Address to Nickname.&#13;
    mapping (address =&gt; string) public ownerAddressToName;&#13;
&#13;
    /**&#13;
    * @dev Guarantees msg.sender is owner of the given token&#13;
    * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender&#13;
    */&#13;
    modifier onlyOwnerOf(uint256 _tokenId) {&#13;
        require(ownerOf(_tokenId) == msg.sender);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier canMint() {&#13;
        require(!mintingFinished);&#13;
        _;&#13;
    }&#13;
&#13;
    function name() public pure returns (string _name) {&#13;
        return "OwnTheDay.io Days";&#13;
    }&#13;
&#13;
    function symbol() public pure returns (string _symbol) {&#13;
        return "DAYS";&#13;
    }&#13;
&#13;
    /// @dev Creates the initial day tokens available (this is the minting process)&#13;
    function createInitialDays(uint256 _count) public onlyOwner canMint {&#13;
        require(totalTokens &lt; 366 &amp;&amp; _count &gt; 0);&#13;
        for (uint256 i = 0; i &lt; _count &amp;&amp; totalTokens &lt; 366; i++) {&#13;
            _mint(msg.sender, totalTokens);&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Assigns initial days to owners during minting period.&#13;
    /// This is only used during migration from old contract to new contract (this one).&#13;
    function assignInitialDays(address _to, uint256 _tokenId, uint256 _price) public onlyOwner canMint {&#13;
        require(msg.sender != address(0));&#13;
        require(_to != address(0));&#13;
        require(_tokenId &gt;= 0 &amp;&amp; _tokenId &lt; 366);&#13;
        require(_price &gt;= 1 finney);&#13;
&#13;
        tokenOwner[_tokenId] = _to;&#13;
        uint256 length = balanceOf(_to);&#13;
        ownedTokens[_to].push(_tokenId);&#13;
        ownedTokensIndex[_tokenId] = length;&#13;
        totalTokens = totalTokens.add(1);&#13;
        dayIndexToPrice[_tokenId] = _price;&#13;
        Transfer(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    function finishMinting() public onlyOwner {&#13;
        require(!mintingFinished);&#13;
        mintingFinished = true;&#13;
    }&#13;
&#13;
    function isMintingFinished() public view returns (bool) {&#13;
        return mintingFinished;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Gets the total amount of tokens stored by the contract&#13;
    * @return uint256 representing the total amount of tokens&#13;
    */&#13;
    function totalSupply() public view returns (uint256) {&#13;
        return totalTokens;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Gets the balance of the specified address&#13;
    * @param _owner address to query the balance of&#13;
    * @return uint256 representing the amount owned by the passed address&#13;
    */&#13;
    function balanceOf(address _owner) public view returns (uint256) {&#13;
        return ownedTokens[_owner].length;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Gets the list of tokens owned by a given address&#13;
    * @param _owner address to query the tokens of&#13;
    * @return uint256[] representing the list of tokens owned by the passed address&#13;
    */&#13;
    function tokensOf(address _owner) public view returns (uint256[]) {&#13;
        return ownedTokens[_owner];&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Gets the owner of the specified token ID&#13;
    * @param _tokenId uint256 ID of the token to query the owner of&#13;
    * @return owner address currently marked as the owner of the given token ID&#13;
    */&#13;
    function ownerOf(uint256 _tokenId) public view returns (address) {&#13;
        address owner = tokenOwner[_tokenId];&#13;
        require(owner != address(0));&#13;
        return owner;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Gets the approved address to take ownership of a given token ID&#13;
    * @param _tokenId uint256 ID of the token to query the approval of&#13;
    * @return address currently approved to take ownership of the given token ID&#13;
    */&#13;
    function approvedFor(uint256 _tokenId) public view returns (address) {&#13;
        return tokenApprovals[_tokenId];&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Transfers the ownership of a given token ID to another address&#13;
    * @param _to address to receive the ownership of the given token ID&#13;
    * @param _tokenId uint256 ID of the token to be transferred&#13;
    */&#13;
    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {&#13;
        clearApprovalAndTransfer(msg.sender, _to, _tokenId);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Approves another address to claim for the ownership of the given token ID&#13;
    * @param _to address to be approved for the given token ID&#13;
    * @param _tokenId uint256 ID of the token to be approved&#13;
    */&#13;
    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {&#13;
        address owner = ownerOf(_tokenId);&#13;
        require(_to != owner);&#13;
        if (approvedFor(_tokenId) != 0 || _to != 0) {&#13;
            tokenApprovals[_tokenId] = _to;&#13;
            Approval(owner, _to, _tokenId);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Claims the ownership of a given token ID&#13;
    * @param _tokenId uint256 ID of the token being claimed by the msg.sender&#13;
    */&#13;
    function takeOwnership(uint256 _tokenId) public {&#13;
        require(isApprovedFor(msg.sender, _tokenId));&#13;
        clearApprovalAndTransfer(ownerOf(_tokenId), msg.sender, _tokenId);&#13;
    }&#13;
&#13;
    /// @dev Calculate the Final Sale Price after the Owner-Cut has been calculated&#13;
    function calculateOwnerCut(uint256 _price) public pure returns (uint256) {&#13;
        if (_price &gt; 5000 finney) {&#13;
            return _price.mul(2).div(100);&#13;
        } else if (_price &gt; 500 finney) {&#13;
            return _price.mul(3).div(100);&#13;
        } else if (_price &gt; 250 finney) {&#13;
            return _price.mul(4).div(100);&#13;
        }&#13;
        return _price.mul(5).div(100);&#13;
    }&#13;
&#13;
    /// @dev Calculate the Price Increase based on the current Purchase Price&#13;
    function calculatePriceIncrease(uint256 _price) public pure returns (uint256) {&#13;
        if (_price &gt; 5000 finney) {&#13;
            return _price.mul(15).div(100);&#13;
        } else if (_price &gt; 2500 finney) {&#13;
            return _price.mul(18).div(100);&#13;
        } else if (_price &gt; 500 finney) {&#13;
            return _price.mul(26).div(100);&#13;
        } else if (_price &gt; 250 finney) {&#13;
            return _price.mul(36).div(100);&#13;
        }&#13;
        return _price; // 100% increase&#13;
    }&#13;
&#13;
    /// @dev Gets the Current (or Default) Price of a Day&#13;
    function getPriceByDayIndex(uint256 _dayIndex) public view returns (uint256) {&#13;
        require(_dayIndex &gt;= 0 &amp;&amp; _dayIndex &lt; 366);&#13;
        uint256 price = dayIndexToPrice[_dayIndex];&#13;
        if (price == 0) { price = 1 finney; }&#13;
        return price;&#13;
    }&#13;
&#13;
    /// @dev Sets the Nickname for an Account Address&#13;
    function setAccountNickname(string _nickname) public whenNotPaused {&#13;
        require(msg.sender != address(0));&#13;
        require(bytes(_nickname).length &gt; 0);&#13;
        ownerAddressToName[msg.sender] = _nickname;&#13;
    }&#13;
&#13;
    /// @dev Claim a Day for Your Very Own!&#13;
    /// The Purchase Price is Paid to the Previous Owner&#13;
    function claimDay(uint256 _dayIndex) public nonReentrant whenNotPaused payable {&#13;
        require(msg.sender != address(0));&#13;
        require(_dayIndex &gt;= 0 &amp;&amp; _dayIndex &lt; 366);&#13;
&#13;
        address buyer = msg.sender;&#13;
        address seller = tokenOwner[_dayIndex];&#13;
        require(msg.sender != seller); // Prevent buying from self&#13;
&#13;
        uint256 amountPaid = msg.value;&#13;
        uint256 purchasePrice = dayIndexToPrice[_dayIndex];&#13;
        if (purchasePrice == 0) {&#13;
            purchasePrice = 1 finney; // == 0.001 ether or 1000000000000000 wei&#13;
        }&#13;
        require(amountPaid &gt;= purchasePrice);&#13;
&#13;
        // If too much was paid, track the change to be returned&#13;
        uint256 changeToReturn = 0;&#13;
        if (amountPaid &gt; purchasePrice) {&#13;
            changeToReturn = amountPaid.sub(purchasePrice);&#13;
            amountPaid -= changeToReturn;&#13;
        }&#13;
&#13;
        // Calculate New Purchase Price and update storage&#13;
        uint256 priceIncrease = calculatePriceIncrease(purchasePrice);&#13;
        uint256 newPurchasePrice = purchasePrice.add(priceIncrease);&#13;
        dayIndexToPrice[_dayIndex] = newPurchasePrice;&#13;
&#13;
        // Calculate Sale Price after Dev-Cut&#13;
        //  - Dev-Cut is left in the contract&#13;
        //  - Sale Price is transfered to seller immediately&#13;
        uint256 ownerCut = calculateOwnerCut(amountPaid);&#13;
        uint256 salePrice = amountPaid.sub(ownerCut);&#13;
&#13;
        // Fire Claim Events&#13;
        Bought(_dayIndex, buyer, purchasePrice);&#13;
        Sold(_dayIndex, seller, purchasePrice);&#13;
&#13;
        // Transfer token&#13;
        clearApprovalAndTransfer(seller, buyer, _dayIndex);&#13;
&#13;
        // Transfer Funds&#13;
        if (seller != address(0)) {&#13;
            seller.transfer(salePrice);&#13;
        }&#13;
        if (changeToReturn &gt; 0) {&#13;
            buyer.transfer(changeToReturn);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Mint token function&#13;
    * @param _to The address that will own the minted token&#13;
    * @param _tokenId uint256 ID of the token to be minted by the msg.sender&#13;
    */&#13;
    function _mint(address _to, uint256 _tokenId) internal {&#13;
        require(_to != address(0));&#13;
        addToken(_to, _tokenId);&#13;
        Transfer(0x0, _to, _tokenId);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Tells whether the msg.sender is approved for the given token ID or not&#13;
    * This function is not private so it can be extended in further implementations like the operatable ERC721&#13;
    * @param _owner address of the owner to query the approval of&#13;
    * @param _tokenId uint256 ID of the token to query the approval of&#13;
    * @return bool whether the msg.sender is approved for the given token ID or not&#13;
    */&#13;
    function isApprovedFor(address _owner, uint256 _tokenId) internal view returns (bool) {&#13;
        return approvedFor(_tokenId) == _owner;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Internal function to clear current approval and transfer the ownership of a given token ID&#13;
    * @param _from address which you want to send tokens from&#13;
    * @param _to address which you want to transfer the token to&#13;
    * @param _tokenId uint256 ID of the token to be transferred&#13;
    */&#13;
    function clearApprovalAndTransfer(address _from, address _to, uint256 _tokenId) internal {&#13;
        require(_to != address(0));&#13;
        require(_to != ownerOf(_tokenId));&#13;
        require(ownerOf(_tokenId) == _from);&#13;
&#13;
        clearApproval(_from, _tokenId);&#13;
        removeToken(_from, _tokenId);&#13;
        addToken(_to, _tokenId);&#13;
        Transfer(_from, _to, _tokenId);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Internal function to clear current approval of a given token ID&#13;
    * @param _tokenId uint256 ID of the token to be transferred&#13;
    */&#13;
    function clearApproval(address _owner, uint256 _tokenId) private {&#13;
        require(ownerOf(_tokenId) == _owner);&#13;
        tokenApprovals[_tokenId] = 0;&#13;
        Approval(_owner, 0, _tokenId);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Internal function to add a token ID to the list of a given address&#13;
    * @param _to address representing the new owner of the given token ID&#13;
    * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address&#13;
    */&#13;
    function addToken(address _to, uint256 _tokenId) private {&#13;
        require(tokenOwner[_tokenId] == address(0));&#13;
        tokenOwner[_tokenId] = _to;&#13;
        uint256 length = balanceOf(_to);&#13;
        ownedTokens[_to].push(_tokenId);&#13;
        ownedTokensIndex[_tokenId] = length;&#13;
        totalTokens = totalTokens.add(1);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Internal function to remove a token ID from the list of a given address&#13;
    * @param _from address representing the previous owner of the given token ID&#13;
    * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address&#13;
    */&#13;
    function removeToken(address _from, uint256 _tokenId) private {&#13;
        require(ownerOf(_tokenId) == _from);&#13;
&#13;
        uint256 tokenIndex = ownedTokensIndex[_tokenId];&#13;
        uint256 lastTokenIndex = balanceOf(_from).sub(1);&#13;
        uint256 lastToken = ownedTokens[_from][lastTokenIndex];&#13;
&#13;
        tokenOwner[_tokenId] = 0;&#13;
        ownedTokens[_from][tokenIndex] = lastToken;&#13;
        ownedTokens[_from][lastTokenIndex] = 0;&#13;
        // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are&#13;
        // going to be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we&#13;
        // are first swapping the lastToken to the first position, and then dropping the element placed in the last&#13;
        // position of the list&#13;
&#13;
        ownedTokens[_from].length--;&#13;
        ownedTokensIndex[_tokenId] = 0;&#13;
        ownedTokensIndex[lastToken] = tokenIndex;&#13;
        totalTokens = totalTokens.sub(1);&#13;
    }&#13;
}