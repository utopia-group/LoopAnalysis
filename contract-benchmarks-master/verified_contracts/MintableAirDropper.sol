pragma solidity 0.4.24;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/ZTXInterface.sol

contract ZTXInterface {
    function transferOwnership(address _newOwner) public;
    function mint(address _to, uint256 amount) public returns (bool);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function unpause() public;
}

// File: contracts/airdropper/AirDropperCore.sol

/**
 * @title AirDropperCore
 * @author Gustavo Guimaraes - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5a3d2f292e3b2c351a202f362f283f2a2f38363339743335">[email protected]</a>&gt;&#13;
 * @dev Contract for the ZTX airdrop&#13;
 */&#13;
contract AirDropperCore is Ownable {&#13;
    using SafeMath for uint256;&#13;
&#13;
    mapping (address =&gt; bool) public claimedAirdropTokens;&#13;
&#13;
    uint256 public numOfCitizensWhoReceivedDrops;&#13;
    uint256 public tokenAmountPerUser;&#13;
    uint256 public airdropReceiversLimit;&#13;
&#13;
    ZTXInterface public ztx;&#13;
&#13;
    event TokenDrop(address indexed receiver, uint256 amount);&#13;
&#13;
    /**&#13;
     * @dev Constructor for the airdrop contract&#13;
     * @param _airdropReceiversLimit Cap of airdrop receivers&#13;
     * @param _tokenAmountPerUser Number of tokens done per user&#13;
     * @param _ztx ZTX contract address&#13;
     */&#13;
    constructor(uint256 _airdropReceiversLimit, uint256 _tokenAmountPerUser, ZTXInterface _ztx) public {&#13;
        require(&#13;
            _airdropReceiversLimit != 0 &amp;&amp;&#13;
            _tokenAmountPerUser != 0 &amp;&amp;&#13;
            _ztx != address(0),&#13;
            "constructor params cannot be empty"&#13;
        );&#13;
        airdropReceiversLimit = _airdropReceiversLimit;&#13;
        tokenAmountPerUser = _tokenAmountPerUser;&#13;
        ztx = ZTXInterface(_ztx);&#13;
    }&#13;
&#13;
    function triggerAirDrops(address[] recipients)&#13;
        external&#13;
        onlyOwner&#13;
    {&#13;
        for (uint256 i = 0; i &lt; recipients.length; i++) {&#13;
            triggerAirDrop(recipients[i]);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Distributes tokens to recipient addresses&#13;
     * @param recipient address to receive airdropped token&#13;
     */&#13;
    function triggerAirDrop(address recipient)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        numOfCitizensWhoReceivedDrops = numOfCitizensWhoReceivedDrops.add(1);&#13;
&#13;
        require(&#13;
            numOfCitizensWhoReceivedDrops &lt;= airdropReceiversLimit &amp;&amp;&#13;
            !claimedAirdropTokens[recipient],&#13;
            "Cannot give more tokens than airdropShare and cannot airdrop to an address that already receive tokens"&#13;
        );&#13;
&#13;
        claimedAirdropTokens[recipient] = true;&#13;
&#13;
        // eligible citizens for airdrop receive tokenAmountPerUser in ZTX&#13;
        sendTokensToUser(recipient, tokenAmountPerUser);&#13;
        emit TokenDrop(recipient, tokenAmountPerUser);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Can be overridden to add sendTokensToUser logic. The overriding function&#13;
     * should call super.sendTokensToUser() to ensure the chain is&#13;
     * executed entirely.&#13;
     * @param recipient Address to receive airdropped tokens&#13;
     * @param tokenAmount Number of rokens to receive&#13;
     */&#13;
    function sendTokensToUser(address recipient, uint256 tokenAmount) internal {&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/airdropper/MintableAirDropper.sol&#13;
&#13;
/**&#13;
 * @title MintableAirDropper&#13;
 * @author Gustavo Guimaraes - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f99e8c8a8d988f96b9838c958c8b9c898c9b95909ad79096">[email protected]</a>&gt;&#13;
 * @dev Airdrop contract that mints ZTX tokens&#13;
 */&#13;
contract MintableAirDropper is AirDropperCore {&#13;
    /**&#13;
     * @dev Constructor for the airdrop contract.&#13;
     * NOTE: airdrop must be the token owner in order to mint ZTX tokens&#13;
     * @param _airdropReceiversLimit Cap of airdrop receivers&#13;
     * @param _tokenAmountPerUser Number of tokens done per user&#13;
     * @param _ztx ZTX contract address&#13;
     */&#13;
    constructor&#13;
        (&#13;
            uint256 _airdropReceiversLimit,&#13;
            uint256 _tokenAmountPerUser,&#13;
            ZTXInterface _ztx&#13;
        )&#13;
        public&#13;
        AirDropperCore(_airdropReceiversLimit, _tokenAmountPerUser, _ztx)&#13;
    {}&#13;
&#13;
    /**&#13;
     * @dev override sendTokensToUser logic&#13;
     * @param recipient Address to receive airdropped tokens&#13;
     * @param tokenAmount Number of rokens to receive&#13;
     */&#13;
    function sendTokensToUser(address recipient, uint256 tokenAmount) internal {&#13;
        ztx.mint(recipient, tokenAmount);&#13;
        super.sendTokensToUser(recipient, tokenAmount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Self-destructs contract&#13;
     */&#13;
    function kill(address newZuluOwner) external onlyOwner {&#13;
        require(&#13;
            numOfCitizensWhoReceivedDrops &gt;= airdropReceiversLimit,&#13;
            "only able to kill contract when numOfCitizensWhoReceivedDrops equals or is higher than airdropReceiversLimit"&#13;
        );&#13;
&#13;
        ztx.unpause();&#13;
        ztx.transferOwnership(newZuluOwner);&#13;
        selfdestruct(owner);&#13;
    }&#13;
}