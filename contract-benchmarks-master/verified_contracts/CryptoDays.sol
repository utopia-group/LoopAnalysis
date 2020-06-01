// CryptoDays Source code
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
* @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a4d6c1c9c7cbe496">[email protected]</a>π.com&gt;&#13;
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
/// @title Crypto Days Base - Controls Ownership of Contract and retreiving Funds&#13;
/// @author xeroblood (https://owntheday.io)&#13;
contract CryptoDaysBase is Pausable, ReentrancyGuard {&#13;
    using SafeMath for uint256;&#13;
&#13;
    event BalanceCollected(address collector, uint256 amount);&#13;
&#13;
    /// @dev A mapping from Day Index to the address owner. Days with&#13;
    ///  no valid owner address are assigned to contract owner.&#13;
    mapping (address =&gt; uint256) public availableForWithdraw;&#13;
&#13;
    function contractBalance() public view returns (uint256) {&#13;
        return this.balance;&#13;
    }&#13;
&#13;
    function withdrawBalance() public nonReentrant {&#13;
        require(msg.sender != address(0));&#13;
        require(availableForWithdraw[msg.sender] &gt; 0);&#13;
        require(availableForWithdraw[msg.sender] &lt;= this.balance);&#13;
        uint256 amount = availableForWithdraw[msg.sender];&#13;
        availableForWithdraw[msg.sender] = 0;&#13;
        BalanceCollected(msg.sender, amount);&#13;
        msg.sender.transfer(amount);&#13;
    }&#13;
&#13;
    /// @dev Calculate the Final Sale Price after the Owner-Cut has been calculated&#13;
    function calculateOwnerCut(uint256 price) public pure returns (uint256) {&#13;
        uint8 percentCut = 5;&#13;
        if (price &gt; 5500 finney) {&#13;
            percentCut = 2;&#13;
        } else if (price &gt; 1250 finney) {&#13;
            percentCut = 3;&#13;
        } else if (price &gt; 250 finney) {&#13;
            percentCut = 4;&#13;
        }&#13;
        return price.mul(percentCut).div(100);&#13;
    }&#13;
&#13;
    /// @dev Calculate the Price Increase based on the current Purchase Price&#13;
    function calculatePriceIncrease(uint256 price) public pure returns (uint256) {&#13;
        uint8 percentIncrease = 100;&#13;
        if (price &gt; 5500 finney) {&#13;
            percentIncrease = 13;&#13;
        } else if (price &gt; 2750 finney) {&#13;
            percentIncrease = 21;&#13;
        } else if (price &gt; 1250 finney) {&#13;
            percentIncrease = 34;&#13;
        } else if (price &gt; 250 finney) {&#13;
            percentIncrease = 55;&#13;
        }&#13;
        return price.mul(percentIncrease).div(100);&#13;
    }&#13;
}&#13;
&#13;
&#13;
/// @title Crypto Days!  Own the Day!&#13;
/// @author xeroblood (https://owntheday.io)&#13;
contract CryptoDays is CryptoDaysBase {&#13;
    using SafeMath for uint256;&#13;
&#13;
    event DayClaimed(address buyer, address seller, uint16 dayIndex, uint256 newPrice);&#13;
&#13;
    /// @dev A mapping from Day Index to Current Price.&#13;
    ///  Initial Price set at 1 finney (1/1000th of an ether).&#13;
    mapping (uint16 =&gt; uint256) public dayIndexToPrice;&#13;
&#13;
    /// @dev A mapping from Day Index to the address owner. Days with&#13;
    ///  no valid owner address are assigned to contract owner.&#13;
    mapping (uint16 =&gt; address) public dayIndexToOwner;&#13;
&#13;
    /// @dev A mapping from Account Address to Nickname.&#13;
    mapping (address =&gt; string) public ownerAddressToName;&#13;
&#13;
    /// @dev Gets the Current (or Default) Price of a Day&#13;
    function getPriceByDayIndex(uint16 dayIndex) public view returns (uint256) {&#13;
        require(dayIndex &gt;= 0 &amp;&amp; dayIndex &lt; 366);&#13;
        uint256 price = dayIndexToPrice[dayIndex];&#13;
        if (price == 0) { price = 1 finney; }&#13;
        return price;&#13;
    }&#13;
&#13;
    /// @dev Sets the Nickname for an Account Address&#13;
    function setAccountNickname(string nickname) public whenNotPaused {&#13;
        require(msg.sender != address(0));&#13;
        require(bytes(nickname).length &gt; 0);&#13;
        ownerAddressToName[msg.sender] = nickname;&#13;
    }&#13;
&#13;
    /// @dev Claim a Day for Your Very Own!&#13;
    /// The Purchase Price is Paid to the Previous Owner&#13;
    function claimDay(uint16 dayIndex) public nonReentrant whenNotPaused payable {&#13;
        require(msg.sender != address(0));&#13;
        require(dayIndex &gt;= 0 &amp;&amp; dayIndex &lt; 366);&#13;
&#13;
        // Prevent buying from self&#13;
        address buyer = msg.sender;&#13;
        address seller = dayIndexToOwner[dayIndex];&#13;
        require(buyer != seller);&#13;
&#13;
        // Get Amount Paid&#13;
        uint256 amountPaid = msg.value;&#13;
&#13;
        // Get Current Purchase Price from Index and ensure enough was Paid&#13;
        uint256 purchasePrice = dayIndexToPrice[dayIndex];&#13;
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
        dayIndexToPrice[dayIndex] = newPurchasePrice;&#13;
&#13;
        // Calculate Sale Price after Owner-Cut and update Owner Balance&#13;
        uint256 ownerCut = calculateOwnerCut(amountPaid);&#13;
        uint256 salePrice = amountPaid.sub(ownerCut);&#13;
        availableForWithdraw[owner] += ownerCut;&#13;
&#13;
        // Assign Day to New Owner&#13;
        dayIndexToOwner[dayIndex] = buyer;&#13;
&#13;
        // Fire Claim Event&#13;
        DayClaimed(buyer, seller, dayIndex, newPurchasePrice);&#13;
&#13;
        // Transfer Funds (Initial sales are made to contract)&#13;
        if (seller != address(0)) {&#13;
            availableForWithdraw[seller] += salePrice;&#13;
        } else {&#13;
            availableForWithdraw[owner] += salePrice;&#13;
        }&#13;
        if (changeToReturn &gt; 0) {&#13;
            buyer.transfer(changeToReturn);&#13;
        }&#13;
    }&#13;
}