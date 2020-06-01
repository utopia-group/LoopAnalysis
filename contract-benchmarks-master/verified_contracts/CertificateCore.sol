pragma solidity ^0.4.23;

// File: contracts/Ownable.sol

/**
     * @title Ownable
     * @dev The Ownable contract has an owner address, and provides basic authorization control
     * functions, this simplifies the implementation of "user permissions".
     */
    contract Ownable {
      address public owner;
    
      event OwnershipRenounced(address indexed previousOwner);
      event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
      /**
       * @dev The Ownable constructor sets the original `owner` of the contract to the sender
       * account.
       */
      //function Ownable() public {
      constructor() public {
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
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
      }
    
      /**
       * @dev Allows the current owner to relinquish control of the contract.
       */
      function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
      }
    }

// File: contracts/CeoOwner.sol

contract CeoOwner is Ownable{

	// The primary address which is permitted to interact with the contract
	// Address of wallet account on WEB3.js account.
	address public ceoAddress; 

	modifier onlyCEO() {
		require(msg.sender == ceoAddress);
		_;
	}

}

// File: contracts/ReentrancyGuard.sol

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="dfadbab2bcb09fed">[email protected]</a>π.com&gt;&#13;
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
// File: contracts/SafeMath.sol&#13;
&#13;
/**&#13;
     * @title SafeMath&#13;
     * @dev Math operations with safety checks that throw on error&#13;
     */&#13;
     library SafeMath {&#13;
      &#13;
      /**&#13;
      * @dev Multiplies two numbers, throws on overflow.&#13;
      */&#13;
      function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
        if (a == 0) {&#13;
          return 0;&#13;
        }&#13;
        c = a * b;&#13;
        assert(c / a == b);&#13;
        return c;&#13;
      }&#13;
      &#13;
      /**&#13;
      * @dev Integer division of two numbers, truncating the quotient.&#13;
      */&#13;
      function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
        // uint256 c = a / b;&#13;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
        return a / b;&#13;
      }&#13;
      &#13;
      /**&#13;
      * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
      */&#13;
      function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
      }&#13;
      &#13;
      /**&#13;
      * @dev Adds two numbers, throws on overflow.&#13;
      */&#13;
      function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
        c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
      }&#13;
    }&#13;
&#13;
// File: contracts/CertificateCore.sol&#13;
&#13;
contract CertificateCore is CeoOwner, ReentrancyGuard { &#13;
   &#13;
    using SafeMath for uint256; &#13;
&#13;
    uint256 public constant KEY_CREATION_LIMIT = 10000;&#13;
    uint256 public totalSupplyOfKeys;&#13;
    uint256 public totalReclaimedKeys;&#13;
    &#13;
    // Track who is making the deposits and the amount made&#13;
    mapping(address =&gt; uint256) public balanceOf; &#13;
&#13;
    // Main data structure to hold all of the public keys   &#13;
    mapping(address =&gt; bool) public allThePublicKeys;&#13;
    &#13;
    // A bonus deposit has been made&#13;
    event DepositBonusEvent(address sender, uint256 amount); &#13;
    &#13;
    // A new certificate has been successfully sold and a deposit added&#13;
    event DepositCertificateSaleEvent(address sender, address publicKey, uint256 amount);&#13;
&#13;
    // A certificate has been payed out.&#13;
    event CertPayedOutEvent(address sender, address recpublicKey, uint256 payoutValue);&#13;
    &#13;
&#13;
    constructor(address _ceoAddress) public{&#13;
        require(_ceoAddress != address(0));&#13;
        owner = msg.sender;&#13;
        ceoAddress = _ceoAddress;&#13;
    }&#13;
 &#13;
    &#13;
    /**&#13;
     *&#13;
     * Main function for creating certificates&#13;
     * &#13;
     */&#13;
    //function createANewCert(address _publicKey, uint256 _amount) external payable onlyCEO{&#13;
    function depositCertificateSale(address _publicKey, uint256 _amount) external payable onlyCEO{&#13;
        require(msg.sender != address(0));&#13;
        require(_amount &gt; 0);&#13;
        require(msg.value == _amount);&#13;
        require(_publicKey != address(0));&#13;
        require(totalSupplyOfKeys &lt; KEY_CREATION_LIMIT);&#13;
        require(totalReclaimedKeys &lt; KEY_CREATION_LIMIT);&#13;
 &#13;
        require(!allThePublicKeys[_publicKey]);&#13;
&#13;
        allThePublicKeys[_publicKey]=true;&#13;
        totalSupplyOfKeys ++;&#13;
&#13;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);&#13;
        &#13;
        emit DepositCertificateSaleEvent(msg.sender, _publicKey, _amount);&#13;
    }&#13;
    &#13;
    /**&#13;
     *  Allow the CEO to deposit ETH without creating a new certificate&#13;
     * &#13;
     * */&#13;
    //function deposit(uint256 _amount) external payable onlyCEO {&#13;
    function depositBonus(uint256 _amount) external payable onlyCEO {&#13;
        require(_amount &gt; 0);&#13;
        require(msg.value == _amount);&#13;
      &#13;
        require((totalSupplyOfKeys &gt; 0) &amp;&amp; (totalSupplyOfKeys &lt; KEY_CREATION_LIMIT));&#13;
        require(totalReclaimedKeys &lt; KEY_CREATION_LIMIT);&#13;
      &#13;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);&#13;
        &#13;
        emit DepositBonusEvent(msg.sender, _amount);&#13;
    }&#13;
    &#13;
    /**&#13;
     * Payout a certificate. &#13;
     * &#13;
     */&#13;
    function payoutACert(bytes32 _msgHash, uint8 _v, bytes32 _r, bytes32 _s) external nonReentrant{&#13;
        require(msg.sender != address(0));&#13;
        require(address(this).balance &gt; 0);&#13;
        require(totalSupplyOfKeys &gt; 0);&#13;
        require(totalReclaimedKeys &lt; KEY_CREATION_LIMIT);&#13;
         &#13;
        address _recoveredAddress = ecrecover(_msgHash, _v, _r, _s);&#13;
        require(allThePublicKeys[_recoveredAddress]);&#13;
    &#13;
        allThePublicKeys[_recoveredAddress]=false;&#13;
&#13;
        uint256 _validKeys = totalSupplyOfKeys.sub(totalReclaimedKeys);&#13;
        uint256 _payoutValue = address(this).balance.div(_validKeys);&#13;
&#13;
        msg.sender.transfer(_payoutValue);&#13;
        emit CertPayedOutEvent(msg.sender, _recoveredAddress, _payoutValue);&#13;
        &#13;
        totalReclaimedKeys ++;&#13;
    }&#13;
 &#13;
     /**&#13;
     * Update payout value per certificate.&#13;
     */&#13;
     //&#13;
     // debug only. remove in Live deploy.&#13;
     // do this operation on the Dapp side.&#13;
    function calculatePayout() view external returns(&#13;
        uint256 _etherValue&#13;
        ){&#13;
        uint256 _validKeys = totalSupplyOfKeys.sub(totalReclaimedKeys);&#13;
        // Last key has been paid out.&#13;
        if(_validKeys == 0){&#13;
            _etherValue = 0;&#13;
        }else{&#13;
            _etherValue = address(this).balance.div(_validKeys);&#13;
        }&#13;
    }&#13;
 &#13;
 &#13;
    /**&#13;
     * Check to see if a Key has been payed out or if it's still valid&#13;
     */&#13;
    function checkIfValidKey(address _publicKey) view external{ // external&#13;
        require(_publicKey != address(0));&#13;
        require(allThePublicKeys[_publicKey]);&#13;
    }&#13;
&#13;
    function getBalance() view external returns(&#13;
         uint256 contractBalance&#13;
    ){&#13;
        contractBalance = address(this).balance;&#13;
    }&#13;
    &#13;
    /**&#13;
     * Saftey Mechanism&#13;
     * &#13;
     */&#13;
    function kill() external onlyOwner &#13;
    { &#13;
        selfdestruct(owner); &#13;
    }&#13;
 &#13;
    /**&#13;
     * Payable fallback function.&#13;
     * No Tipping! &#13;
     * &#13;
     */&#13;
    //function () payable public{&#13;
    //    throw;&#13;
    //}&#13;
    &#13;
}&#13;
&#13;
// File: contracts/Migrations.sol&#13;
&#13;
contract Migrations {&#13;
  address public owner;&#13;
  uint public last_completed_migration;&#13;
&#13;
  modifier restricted() {&#13;
    if (msg.sender == owner) _;&#13;
  }&#13;
&#13;
  //function Migrations() public {&#13;
  constructor() public {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
  function setCompleted(uint completed) public restricted {&#13;
    last_completed_migration = completed;&#13;
  }&#13;
&#13;
  function upgrade(address new_address) public restricted {&#13;
    Migrations upgraded = Migrations(new_address);&#13;
    upgraded.setCompleted(last_completed_migration);&#13;
  }&#13;
}